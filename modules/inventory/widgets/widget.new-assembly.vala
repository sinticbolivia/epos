using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WindowNewAssembly : Window
	{
		protected 	Builder 			ui;
		protected	Box					boxNewAssembly;
		protected	Image				image1;
		protected	Label				labelTitle;
		protected	Entry				entryName;
		protected	TextView			textviewDescription;
		protected	TreeView			treeview1;
		protected	Entry				entrySearchProduct;
		protected	Entry				entryRequiredQty;
		protected	ComboBox			comboboxUOM;
		protected	Button				buttonAdd;
		protected	Button				buttonCancel;
		protected	Button				buttonSave;
		
		public		int					StoreId{get;set;}
		protected	int					AssemblyId = 0;
		
		public WindowNewAssembly()
		{
			this.ui						= (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("new-assembly.glade");
			this.boxNewAssembly			= (Box)this.ui.get_object("boxNewAssembly");
			this.image1					= (Image)this.ui.get_object("image1");
			this.labelTitle				= (Label)this.ui.get_object("labelTitle");
			this.entryName				= (Entry)this.ui.get_object("entryName");
			this.textviewDescription	= (TextView)this.ui.get_object("textviewDescription");
			this.treeview1				= (TreeView)this.ui.get_object("treeview1");
			this.entrySearchProduct		= (Entry)this.ui.get_object("entrySearchProduct");
			this.entryRequiredQty		= (Entry)this.ui.get_object("entryRequiredQty");
			this.comboboxUOM			= (ComboBox)this.ui.get_object("comboboxUOM");
			this.buttonAdd				= (Button)this.ui.get_object("buttonAddProduct");
			this.buttonCancel			= (Button)this.ui.get_object("buttonCancel");
			this.buttonSave				= (Button)this.ui.get_object("buttonSave");
			
			this.boxNewAssembly.reparent(this);
			this.Build();
			this.FillForm();
			this.SetEvents();
			this.title = SBText.__("New Assembly");
		}
		protected void Build()
		{
			try
			{
				this.image1.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("assembly-64x64.png");
			}
			catch(GLib.Error e)
			{
				stdout.printf("ERROR: %s\n".printf(e.message));
			}
			string[,] cols = 
			{
				{"#", "text", "70", "center", "", ""},
				{SBText.__("Component Id"), "text", "70", "center", "", ""},
				{SBText.__("Name"), "text", "250", "left", "", ""},
				{SBText.__("Qty Required"), "text", "70", "center", "", ""},
				{SBText.__("UOM"), "text", "90", "left", "", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeview1);
			this.treeview1.model = new ListStore(6, 
				typeof(int), 
				typeof(int), 
				typeof(string), 
				typeof(int), 
				typeof(string),
				typeof(int) //uom id
			);
			//##build product search completion
			this.entrySearchProduct.completion = new EntryCompletion();
			this.entrySearchProduct.completion.model = new ListStore(2, typeof(int), typeof(string));
			this.entrySearchProduct.completion.text_column = 1;
			this.entrySearchProduct.completion.clear();
			var cell = new CellRendererText();
			this.entrySearchProduct.completion.pack_start(cell, false);
			this.entrySearchProduct.completion.add_attribute(cell, "text", 0);
			cell = new CellRendererText();
			this.entrySearchProduct.completion.pack_start(cell, false);
			this.entrySearchProduct.completion.add_attribute(cell, "text", 1);
			//##build UOM combobox
			this.comboboxUOM.model = new ListStore(2, typeof(string), typeof(string));
			cell = new CellRendererText();
			this.comboboxUOM.pack_start(cell, false);
			this.comboboxUOM.set_attributes(cell, "text", 0);
			this.comboboxUOM.id_column = 1;
			
		}
		protected void FillForm()
		{
			TreeIter iter;
			(this.comboboxUOM.model as ListStore).append(out iter);
			(this.comboboxUOM.model as ListStore).set(iter,
				0, SBText.__("-- unit of measure --"),
				1, "-1"
			);
			foreach(var uom in InventoryHelper.GetUnitOfMeasures())
			{
				(this.comboboxUOM.model as ListStore).append(out iter);
				(this.comboboxUOM.model as ListStore).set(iter,
					0, (string)uom["name"],
					1, ((int)uom["measure_id"]).to_string()
				);
			}
			this.comboboxUOM.active_id = "-1";
		}
		protected void SetEvents()
		{
			this.entrySearchProduct.key_release_event.connect(this.OnEntrySearchProductKeyReleaseEvent);
			this.entrySearchProduct.completion.match_selected.connect(this.OnSearchProductMatchCompletion);
			this.buttonAdd.clicked.connect(this.OnButtonAddClicked);
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
			this.buttonSave.clicked.connect(this.OnButtonSaveClicked);
		}
		protected bool OnEntrySearchProductKeyReleaseEvent(Gdk.EventKey event)
		{
			//skip up, down keys
			if( event.keyval == 65364 || event.keyval == 65362)
			{
				return true;
			}
			(this.entrySearchProduct.completion.model as ListStore).clear();
			string keyword = this.entrySearchProduct.text.strip();
			if( keyword.length <= 0 )
			{
				return true;
			}
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = """SELECT * FROM products
							WHERE store_id = %d
							AND product_name LIKE '%s'""".printf(this.StoreId, "%"+keyword+"%");
			var prods = dbh.GetResults(query);
			//long total = 0;
			//var prods = Woocommerce.InventoryHelper.GetStoreProducts(this.StoreId, 1, -1, out total);
			TreeIter iter;
			foreach(var p in prods)
			{
				(this.entrySearchProduct.completion.model as ListStore).append(out iter);
				(this.entrySearchProduct.completion.model as ListStore).set(iter,
					0, p.GetInt("product_id"),
					1, p.Get("product_name")
				);
			}
			return true;
		}
		protected bool OnSearchProductMatchCompletion(TreeModel model, TreeIter iter)
		{
			Value product_id, product_name;
			
			model.get_value(iter, 0, out product_id);
			model.get_value(iter, 1, out product_name);
			
			this.entrySearchProduct.set_data<int>("product_id", (int)product_id);
			this.entrySearchProduct.text = (string)product_name;
			
			return true;
		}
		protected void OnButtonAddClicked()
		{
			int? product_id = this.entrySearchProduct.get_data<int>("product_id");
			if( product_id == null || product_id <= 0 )
			{
				return;
			}
			int qty = int.parse(this.entryRequiredQty.text.strip());
			if( qty <= 0 )
			{
				this.entryRequiredQty.grab_focus();
				return;
			}
			if( this.comboboxUOM.active_id == null || this.comboboxUOM.active_id == "-1" )
			{
				this.comboboxUOM.grab_focus();
				return;
			}
			int uom_id = int.parse(this.comboboxUOM.active_id);
			this.AddProduct(product_id, qty, uom_id);
			
			this.entrySearchProduct.set_data<int>("product_id", 0);
		}
		protected void AddProduct(int product_id, int qty, int uom_id)
		{
			var prod = new EProduct.from_id(product_id);
			int i = 0;
			bool exists = false;
			this.treeview1.model.foreach( (_model, _path, _iter) => 
			{
				Value pid;
				_model.get_value(_iter, 1, out pid);
				if( prod.Id == (int)pid )
				{
					exists = true;
				}
				i++;
				return false;
			});
			if( exists )
			{
				var msg = new InfoDialog("error")
				{
					Title = SBText.__("Error adding component"),
					Message = SBText.__("The component is already assigned to this assembly")
				};
				msg.run();
				msg.destroy();
				return;
			}
			var uom = InventoryHelper.GetUnitOfMeasure(uom_id);
			
			TreeIter iter;
			(this.treeview1.model as ListStore).append(out iter);
			(this.treeview1.model as ListStore).set(iter, 
				0, i + 1,
				1, prod.Id,
				2, prod.Name,
				3, qty, 
				4, (string)uom["name"],
				5, (int)uom["measure_id"]
			);
		}
		protected void OnButtonCancelClicked()
		{
			this.destroy();
		}
		protected void OnButtonSaveClicked()
		{
			string name = this.entryName.text.strip();
			string desc = this.textviewDescription.buffer.text.strip();
			if( name.length <= 0 )
			{
				this.entryName.grab_focus();
				return;
			}
			var prods = new ArrayList<HashMap<string, Value?>>();
			this.treeview1.model.foreach( (_model, _path, _iter) => 
			{
				Value vid, vqty, vuom_id;
				_model.get_value(_iter, 1, out vid);
				_model.get_value(_iter, 3, out vqty); 
				_model.get_value(_iter, 5, out vuom_id);
				
				var p = new HashMap<string, Value?>();
				p.set("product_id", (int)vid);
				p.set("qty_required", (int)vqty);
				p.set("unit_measure_id", (int)vuom_id);
				prods.add(p);
				return false;
			});
			if( prods.size <= 0 )
			{
				var msg = new InfoDialog("error")
				{
					Title = SBText.__("Error creation assembly"),
					Message = SBText.__("There are no products into assembly")
				};
				msg.run();
				msg.destroy();
				return;
			}
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			
			string cdate = new DateTime.now_local().format("%Y-%m-%d %H:%M:%S");
			var assembly = new HashMap<string, Value?>();
			assembly.set("name", name);
			assembly.set("description", desc);
			assembly.set("store_id", this.StoreId);
			assembly.set("last_modification_date", cdate);
			
			if( this.AssemblyId <= 0 )
			{
				
				assembly.set("creation_date", cdate);
				this.AssemblyId = (int)dbh.Insert("assemblies", assembly);
				
				string code = "ASM-%d".printf(this.AssemblyId);
				string query = "UPDATE assemblies SET code = '%s' WHERE assembly_id = %d".printf(code, this.AssemblyId);
				dbh.Execute(query);
			}
			else
			{
				var w = new HashMap<string, Value?>();
				w.set("assembly_id", this.AssemblyId);
				dbh.Update("assemblies", assembly, w);
				string q = "DELETE FROM assemblie2product WHERE assembly_id = %d".printf(this.AssemblyId);
				dbh.Execute(q);
			}
			//##insert assemblies
			foreach(var p in prods)
			{
				p.set("assembly_id", this.AssemblyId);
				p.set("creation_date", cdate);
				dbh.Insert("assemblie2product", p);
			}
			
			this.AssemblyId = 0;
			var msg = new InfoDialog("success")
			{
				Title = SBText.__("Assembly created"),
				Message	 = SBText.__("The assembly has been created")
			};
			msg.run();
			msg.destroy();
			GLib.Signal.emit_by_name(this.buttonCancel, "clicked");
		}
		public void SetAssembly(EAssembly assembly)
		{
			this.title = this.labelTitle.label = SBText.__("Edit Assembly");
			this.AssemblyId = assembly.Id;
			this.entryName.text = assembly.Name;
			this.textviewDescription.buffer.text = assembly.Description;
			int i = 1;
			foreach(EAssemblyComponent com in assembly.Components)
			{
				TreeIter iter;
				(this.treeview1.model as ListStore).append(out iter);
				(this.treeview1.model as ListStore).set(iter, 
					0, i,
					1, com.ProductId,
					2, com.Product.Name,
					3, com.QtyRequired, 
					4, "UOM",
					5, 0
				);
				i++;
			}
			
			this.entryName.grab_focus();
		}
	}
}
