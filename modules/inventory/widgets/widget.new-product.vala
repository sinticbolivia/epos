using GLib;
using Gtk;
using Gee;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;
using Woocommerce;

namespace EPos
{
	public class WidgetNewProduct : Box
	{
		protected	Builder		ui;
		
		protected	Window		windowNewProduct;
		protected	Box			boxNewProduct;
		protected 	Notebook	notebook1;
		protected	ComboBox	comboboxCategories;
		protected	ComboBox	comboboxDepartment;
		protected	TextView	textviewDescription;
		protected	Entry		entryCode;
		protected	Button		buttonGenerateCode;
		protected	Entry		entryName;
		protected	Entry		entryBarcode;
		protected	ComboBox	comboboxItemType;
		protected	ComboBox	comboboxUnitofMeasure;
		protected	ComboBox	comboboxStatus;
		protected	Frame		frameTags;
		protected	Box			boxTags;
		protected	Entry		entryTag;
		protected	Button		buttonAddTag;
		protected	TreeView	treeviewTags;
		protected	ComboBox	comboboxTaxRates;
		protected	Entry		entryCost;
		protected	Entry		entryPrice;
		protected	Entry		entryPrice2;
		protected	ComboBox	comboboxStoreBranch;
		protected	Entry		entryQuantity;
		protected	Entry		entryMinQuantity;
		protected	CheckButton	checkbuttonUsesStock;
		protected	Viewport			viewport1;
		protected	Fixed				fixedImages;
		protected	ScrolledWindow		scrolledwindowSn;
		protected	Entry				entrySn;
		protected	TreeView			treeviewSn;
		protected	TreeView			treeviewSuppliers;
		protected	Entry				entrySearchSupplier;
		protected	Button				buttonAddSupplier;
		protected	Button				buttonAddSn;
		protected	Button				buttonRemoveSn;
		protected	Button				buttonAddImage;
		protected	Button				buttonCancel;
		protected	Button				buttonSave;
		
		protected	SBProduct	product = null;
		protected	int			fixedWidth = 0;
		protected	int			fixedX = 0;
		protected	int 		fixedY = 0;
		protected	int			fixedRow = 0;
		protected	int			fixedCol = 0;
		
		public WidgetNewProduct()
		{
			GLib.Object();
			//##get new product glade file
			this.ui = (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("new-product.glade");
					
			this.windowNewProduct		= (Window)this.ui.get_object("windowNewProduct");
			this.boxNewProduct 			= (Box)this.ui.get_object("boxNewProduct");
			this.entryCode				= (Entry)this.ui.get_object("entryCode");
			this.buttonGenerateCode		= (Button)this.ui.get_object("buttonGenerateCode");
			this.entryName				= (Entry)this.ui.get_object("entryName");
			this.notebook1				= (Notebook)this.ui.get_object("notebook1");
			this.comboboxCategories		= (ComboBox)this.ui.get_object("comboboxCategories");
			this.comboboxDepartment		= (ComboBox)this.ui.get_object("comboboxDepartment");
			this.textviewDescription	= (TextView)this.ui.get_object("textviewDescription");
			this.entryBarcode			= (Entry)this.ui.get_object("entryBarcode");
			this.comboboxItemType		= (ComboBox)this.ui.get_object("comboboxItemType");
			this.comboboxUnitofMeasure	= (ComboBox)this.ui.get_object("comboboxUnitofMeasure");
			this.comboboxStatus			= (ComboBox)this.ui.get_object("comboboxStatus");
			this.frameTags				= (Frame)this.ui.get_object("frameTags");
			this.boxTags				= (Box)this.ui.get_object("boxTags");
			this.entryTag				= (Entry)this.ui.get_object("entryTag");
			this.buttonAddTag			= (Button)this.ui.get_object("buttonAddTag");
			this.treeviewTags			= (TreeView)this.ui.get_object("treeviewTags");
			this.comboboxTaxRates		= (ComboBox)this.ui.get_object("comboboxTaxRates");
			this.entryCost				= (Entry)this.ui.get_object("entryCost");
			this.entryPrice				= (Entry)this.ui.get_object("entryPrice");
			this.entryPrice2			= (Entry)this.ui.get_object("entryPrice2");
			this.comboboxStoreBranch	= (ComboBox)this.ui.get_object("comboboxStoreBranch");
			this.entryQuantity			= (Entry)this.ui.get_object("entryQuantity");
			this.entryMinQuantity		= (Entry)this.ui.get_object("entryMinQuantity");
			this.checkbuttonUsesStock	= (CheckButton)this.ui.get_object("checkbuttonUsesStock");
			this.fixedImages			= (Fixed)this.ui.get_object("fixedImages");
			this.viewport1				= (Viewport)this.ui.get_object("viewport1");
			this.scrolledwindowSn		= (ScrolledWindow)this.ui.get_object("scrolledwindowSn");
			this.treeviewSn				= (TreeView)this.ui.get_object("treeviewSn");
			this.entrySn				= (Entry)this.ui.get_object("entrySn");
			this.treeviewSuppliers		= (TreeView)this.ui.get_object("treeviewSuppliers");
			this.entrySearchSupplier	= (Entry)this.ui.get_object("entrySearchSupplier");
			this.buttonAddSupplier		= (Button)this.ui.get_object("buttonAddSupplier");
			this.buttonAddSn			= (Button)this.ui.get_object("buttonAddSn");
			this.buttonRemoveSn			= (Button)this.ui.get_object("buttonRemoveSn");
			this.buttonAddImage			= (Button)this.ui.get_object("buttonAddImage");
			this.buttonCancel			= (Button)this.ui.get_object("buttonCancel");
			this.buttonSave				= (Button)this.ui.get_object("buttonSave");
			
			this.boxNewProduct.reparent(this);
			this.Build();
			this.SetEvents();
			this.fixedWidth = this.viewport1.get_allocated_width();
		}
		public WidgetNewProduct.with_product(owned SBProduct prod)
		{
			this();
			this.product = prod;
			
			this.entryCode.text = this.product.Code;
			this.entryName.text = this.product.Name;
			this.entryBarcode.text = this.product.Barcode;
			this.textviewDescription.buffer.text = this.product.Description;
			string? tax_rate_id = EProduct.GetMeta(prod.Id, "tax_rate_id");
			
			if( tax_rate_id != null )
			{
				this.comboboxTaxRates.active_id = tax_rate_id;
			}
			//this.entrySerialNumber.text = this.product.SerialNumber;
			this.entryCost.text = "%.2lf".printf(this.product.Cost);
			this.entryPrice.text = "%.2lf".printf(this.product.Price);
			this.entryPrice2.text = "%.2lf".printf(this.product.Price2);
			this.entryQuantity.text = this.product.Quantity.to_string();
			this.entryMinQuantity.text = this.product.MinStock.to_string();
			
			this.comboboxStoreBranch.active_id = this.product.StoreId.to_string();
			if( this.product.CategoriesIds.size > 0 )
			{
				stdout.printf("cat_id: %s\n", this.product.CategoriesIds.get(0).to_string());
				this.comboboxCategories.active_id = this.product.CategoriesIds.get(0).to_string();
			}
			this.comboboxDepartment.active_id = this.product.Get("department_id");
			this.comboboxUnitofMeasure.active_id = this.product.Get("product_unit_measure");
			this.comboboxStatus.active_id		= this.product.Status;
			//##set serial numbers
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("product_sn").Where("product_id = %d".printf(this.product.Id));
			TreeIter iter;
			int i = 1;
			foreach(var row in dbh.GetResults(null))
			{
				(this.treeviewSn.model as ListStore).append(out iter);
				(this.treeviewSn.model as ListStore).set(iter, 
					0, i,
					1, row.Get("sn")
				);
				i++;
			}
			//##set images
			foreach(var attach in this.product.Attachments)
			{
				string image_path = "images/store_%d/%s".printf(this.product.StoreId, attach.Get("file"));
				this.addImage(image_path, attach.GetInt("attachment_id"));
			}
			//##Set suppliers
			dbh.Select("s.*").
				From("suppliers s, product2suppliers p2s").
				Where("p2s.product_id = %d".printf(this.product.Id)).
				And("p2s.supplier_id = s.supplier_id");
				
			i = 1;
			foreach(var s in dbh.GetResults(null))
			{
				(this.treeviewSuppliers.model as ListStore).append(out iter);
				(this.treeviewSuppliers.model as ListStore).set(iter,
					0, i,
					1, s.Get("supplier_name"),
					2, s.Get("supplier_email"),
					3, s.Get("supplier_telephone_1"),
					4, s.GetInt("supplier_id")
				);
				i++;
			}
			//##set product tags
			string q = "SELECT t.*, p2t.id AS p2t_id FROM tags t, product2tag p2t "+
						"WHERE t.tag_id = p2t.tag_id "+
						"AND p2t.product_id = %d";
			foreach(var tag in dbh.GetResults(q.printf(this.product.Id)))
			{
				(this.treeviewTags.model as ListStore).append(out iter);
				(this.treeviewTags.model as ListStore).set(iter, 
					0, tag.Get("tag"),
					1, (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("remove-20x20.png"),
					2, tag.GetInt("p2t_id")
				);
			}
			this.frameTags.visible = true;
		}
		~WidgetNewProduct()
		{
			stdout.printf("widget.new-product.vala destroyed\n");
			this.fixedImages.get_children().foreach( (child) => 
			{
				(((Button)child).image as Image).pixbuf.dispose();
				(((Button)child).image as Image).dispose();
				child.dispose();
			});
			this.ui.dispose();
		}
		protected void Build()
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			
			TreeIter iter;
			this.comboboxTaxRates.model = new ListStore(2, typeof(string), typeof(string));
			var cell0 = new CellRendererText();
			this.comboboxTaxRates.pack_start(cell0, true);
			this.comboboxTaxRates.set_attributes(cell0, "text", 0);
			this.comboboxTaxRates.id_column = 1;
			(this.comboboxTaxRates.model as ListStore).append(out iter);
			(this.comboboxTaxRates.model as ListStore).set(iter, 
				0, SBText.__("-- tax rate --"),
				1, "-1"
			);
			dbh.Select("*").From("tax_rates");
			foreach(var rate in dbh.GetResults(null))
			{
				(this.comboboxTaxRates.model as ListStore).append(out iter);
				(this.comboboxTaxRates.model as ListStore).set(iter, 
					0, rate.Get("name"),
					1, rate.Get("tax_id")
				);
			}
			this.comboboxTaxRates.active_id = "-1";
			//TODO: set default tax rate from store
			
			this.comboboxItemType.model = new ListStore(2, typeof(string), typeof(string));
			cell0 = new CellRendererText();
			this.comboboxItemType.pack_start(cell0, false);
			this.comboboxItemType.set_attributes(cell0, "text", 0); 
			this.comboboxItemType.id_column = 1;
			
			(this.comboboxItemType.model as ListStore).append(out iter);
			(this.comboboxItemType.model as ListStore).set(iter, 
				0, SBText.__("-- item type --"), 
				1, "-1"
			);
			dbh.Select("*").From("item_types");
			foreach(var row in dbh.GetResults(null))
			{
				(this.comboboxItemType.model as ListStore).append(out iter);
				(this.comboboxItemType.model as ListStore).set(iter, 
					0, "%s - %s".printf(row.Get("code"), row.Get("name")), 
					1, row.Get("item_type_id")
				);
			}
			this.comboboxItemType.active_id = "-1";
			//##build U.O.M.
			this.comboboxUnitofMeasure.model = new ListStore(2, typeof(string), typeof(string));
			cell0 = new CellRendererText();
			this.comboboxUnitofMeasure.pack_start(cell0, false);
			this.comboboxUnitofMeasure.set_attributes(cell0, "text", 0);
			this.comboboxUnitofMeasure.id_column = 1;
			(this.comboboxUnitofMeasure.model as ListStore).append(out iter);
			(this.comboboxUnitofMeasure.model as ListStore).set(iter, 
				0, SBText.__("-- unit of measure --"), 
				1, "-1"
			);
			dbh.Select("*").From("unit_measures");
			foreach(var row in dbh.GetResults(null))
			{
				(this.comboboxUnitofMeasure.model as ListStore).append(out iter);
				(this.comboboxUnitofMeasure.model as ListStore).set(iter, 
					0, "%s - %s".printf(row.Get("code"), row.Get("name")), 
					1, row.Get("measure_id")
				);
			}
			this.comboboxUnitofMeasure.active_id = "-1";
			//##build statuses
			this.comboboxStatus.model = new ListStore(2, typeof(string), typeof(string));
			cell0 = new CellRendererText();
			this.comboboxStatus.pack_start(cell0, false);
			this.comboboxStatus.set_attributes(cell0, "text", 0);
			this.comboboxStatus.id_column = 1;
			
			string[,] statuses = 
			{
				{"-1", SBText.__("-- status --")},
				{"active", SBText.__("Active")},
				{"discontinued", SBText.__("Discontinued")}
			};
			
			for(int i = 0; i < statuses.length[0]; i++)
			{
				(this.comboboxStatus.model as ListStore).append(out iter);
				(this.comboboxStatus.model as ListStore).set(iter,
					0, statuses[i,1],
					1, statuses[i,0]
				);
			}
			this.comboboxStatus.active_id = "-1";
			//##build categories
			this.comboboxCategories.model = new ListStore(2, typeof(string), typeof(string));
			cell0 = new CellRendererText();
			this.comboboxCategories.pack_start(cell0, false);
			this.comboboxCategories.set_attributes(cell0, "text", 0);
			this.comboboxCategories.id_column = 1;
			this.comboboxCategories.sensitive = false;
			
			this.comboboxStoreBranch.model = new ListStore(2, typeof(string), typeof(string));
			var cell = new CellRendererText();
			this.comboboxStoreBranch.pack_start(cell, false);
			this.comboboxStoreBranch.set_attributes(cell, "text", 0);
			this.comboboxStoreBranch.set_id_column(1);
			(this.comboboxStoreBranch.model as ListStore).append(out iter);
			(this.comboboxStoreBranch.model as ListStore).set(iter, 0, SBText.__("-- store/branch --"), 1, "-1");
			var stores = (ArrayList<SBStore>)InventoryHelper.GetStores();
			foreach(var store in stores)
			{
				(this.comboboxStoreBranch.model as ListStore).append(out iter);
				(this.comboboxStoreBranch.model as ListStore).set(iter, 0, store.Name, 1, store.Id.to_string());
			}
			this.comboboxStoreBranch.active_id = "-1";
			//##build combobox departments
			cell = new CellRendererText();
			this.comboboxDepartment.pack_start(cell, false);
			this.comboboxDepartment.set_attributes(cell, "text", 0);
			this.comboboxDepartment.id_column = 1;
			this.comboboxDepartment.model = new ListStore(2, typeof(string), typeof(string));
			(this.comboboxDepartment.model as ListStore).append(out iter);
				(this.comboboxDepartment.model as ListStore).set(iter, 
					0, SBText.__("-- department --"),
					1, "-1"
			);
			this.comboboxDepartment.active_id = "-1";
			foreach(var dep in InventoryHelper.GetDepartments())
			{
				(this.comboboxDepartment.model as ListStore).append(out iter);
				(this.comboboxDepartment.model as ListStore).set(iter, 
					0, (string)dep["name"],
					1, ((int)dep["department_id"]).to_string()
				);
			}
			
			//##build serial numbers treeview
			this.treeviewSn.model = new ListStore(2, typeof(int), typeof(string));
			string[,] cols = 
			{
				{"#", "text", "100", "center", "", ""},
				{SBText.__("Serial Number"), "text", "250", "left", "", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewSn);
			//##build suppliers treeview
			this.treeviewSuppliers.model = new ListStore(5, 
				typeof(int), 
				typeof(string), 
				typeof(string),
				typeof(string),
				typeof(int)
			);
			string[,] cols1 = 
			{
				{"#", "text", "100", "center", "", ""},
				{SBText.__("Supplier"), "text", "200", "left", "", ""},
				{SBText.__("Email"), "text", "200", "left", "", ""},
				{SBText.__("Phone"), "text", "200", "left", "", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols1, ref this.treeviewSuppliers);
			//##build suppliers completion
			this.entrySearchSupplier.completion = new EntryCompletion();
			this.entrySearchSupplier.completion.model = new ListStore(2, typeof(int), typeof(string));
			this.entrySearchSupplier.completion.text_column = 1;
			this.entrySearchSupplier.completion.clear(); //remove all cellrenderers
			cell = new CellRendererText();
			this.entrySearchSupplier.completion.pack_start(cell, false);
			this.entrySearchSupplier.completion.add_attribute(cell, "text", 0);
			cell = new CellRendererText();
			this.entrySearchSupplier.completion.pack_start(cell, true);
			this.entrySearchSupplier.completion.add_attribute(cell, "text", 1);
			
			//##build tags
			this.entryTag.completion = new EntryCompletion();
			this.entryTag.completion.model = new ListStore(2, typeof(string), typeof(int));
			this.entryTag.completion.text_column = 0;
			this.entryTag.completion.set_match_func( (completion,key, iter) => {return true;});
			this.treeviewTags.model = new ListStore(3, typeof(string), typeof(Gdk.Pixbuf), typeof(int));
			GtkHelper.BuildTreeViewColumns({
					{SBText.__("Tag"), "text", "150", "left", "", ""}, 
					{SBText.__("x"), "pixbuf", "20", "center", "", ""}
				}, ref this.treeviewTags);
			this.treeviewTags.get_column(1).set_data<string>("action", "remove");
			this.frameTags.visible = false;
		}
		protected void SetEvents()
		{
			this.entryTag.key_release_event.connect(this.OnEntryTagKeyReleaseEvent);
			this.buttonAddTag.clicked.connect(this.OnButtonAddTagClicked);
			this.comboboxStoreBranch.changed.connect( () => 
			{
				if( this.comboboxStoreBranch.active_id != null && this.comboboxStoreBranch.active_id != "-1" )
				{
					int store_id = int.parse(this.comboboxStoreBranch.active_id);
					this.FillCategories(store_id);
					this.comboboxCategories.grab_focus();
				}
			});
			this.buttonAddImage.clicked.connect(this.OnButtonAddImageClicked);
			this.buttonAddSn.clicked.connect(this.OnButtonAddSnClicked);
			this.buttonRemoveSn.clicked.connect(this.OnButtonRemoveSnClicked);
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
			this.buttonSave.clicked.connect(this.OnButtonSaveClicked);
			this.entrySearchSupplier.key_release_event.connect(this.OnEntrySearchSupplierKeyReleaseEvent);
			this.entrySearchSupplier.completion.match_selected.connect(this.OnSearchSupplierCompletionMatchSelected);
			this.buttonAddSupplier.clicked.connect(this.OnButtonAddSupplierClicked);
			this.entryTag.completion.match_selected.connect(this.OnEntryTagMatchSelected);
			this.treeviewTags.button_release_event.connect(this.OnTreeViewTagsButtonReleaseEvent);
		}
		protected void FillCategories(int store_id)
		{
			//##fill categories
			TreeIter iter;
			(this.comboboxCategories.model as ListStore).clear();
			(this.comboboxCategories.model as ListStore).append(out iter);
			(this.comboboxCategories.model as ListStore).set(iter, 0, SBText.__("-- category --"), 1, "-1");
			this.comboboxCategories.active_id = "-1";
			
			var cats = (ArrayList<SBLCategory>)InventoryHelper.GetCategories(store_id);
			foreach(var cat in cats)
			{
				(this.comboboxCategories.model as ListStore).append(out iter);
				(this.comboboxCategories.model as ListStore).set(iter, 0, cat.Name, 1, cat.Id.to_string());
			}
			this.comboboxCategories.sensitive = true;
		}
		protected bool OnEntryTagKeyReleaseEvent(Gdk.EventKey e)
		{
			//##skip cursor arrows
			if( (e.keyval >= 65361 && e.keyval >= 65364) /*|| e.keyval == 65288*/)
			{
				return true;
			}
			string keyword = this.entryTag.text.strip();
			if( keyword.length <= 0 )
			{
				return true;
			}
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM tags WHERE tag LIKE '%s'".printf("%"+keyword+"%");
			(this.entryTag.completion.model as ListStore).clear();
			TreeIter iter;
			foreach(var tag in dbh.GetResults(query))
			{
				(this.entryTag.completion.model as ListStore).append(out iter);
				(this.entryTag.completion.model as ListStore).set(iter,
					0, tag.Get("tag"),
					1, tag.GetInt("tag_id")
				);
			}
			return true;
		}
		protected bool OnEntryTagMatchSelected(TreeModel model, TreeIter iter)
		{
			Value tag,tag_id;
			model.get_value(iter, 0, out tag);
			model.get_value(iter, 1, out tag_id);
			this.entryTag.text = (string)tag;
			this.buttonAddTag.set_data<int>("tag_id", (int)tag_id);
			stdout.printf("tag: %s, %d\n", (string)tag, (int)tag_id);
			return true;
		}
		/**
		 * Add tag to product
		 * 
		 */
		protected void OnButtonAddTagClicked()
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			int tag_id = 0;
			int p2t_id = 0;
			string tag = this.entryTag.text.strip();
			if( tag.length <= 0 )
				return;
			bool tag_in_product = false;
				
			tag_id 	= (this.buttonAddTag.get_data<int?>("tag_id") == null) ? 0 : (int)this.buttonAddTag.get_data<int>("tag_id");
			stdout.printf("tag_id: %d\n", tag_id);
			//##add selected tag
			if( tag_id > 0 )
			{
				//tag_id = (int)tag_id;
				//##check if product already has the tag
				string q = "SELECT * FROM product2tag WHERE tag_id = %d AND product_id = %d".
										printf(tag_id, this.product.Id);
				var trow = dbh.GetRow(q);
				stdout.printf("%s\n", q);
				if( trow == null )
				{
					stdout.printf("Adding tag \"%d\"  to product\n",tag_id);
					//##add tag to product
					var t2p = new HashMap<string, Value?>();
					t2p.set("product_id", this.product.Id);
					t2p.set("tag_id", (int)tag_id);
					p2t_id = (int)dbh.Insert("product2tag", t2p);
				}
				else
				{
					tag_in_product = true;
					p2t_id = trow.GetInt("id");
				}
				
			}
			else
			{
				//##the user has not selected an existent tag, so we need to create it
				var row = dbh.GetRow("SELECT * FROM tags WHERE tag = '%s'".printf(tag));
				if( row == null )
				{
					var ntag = new HashMap<string, Value?>();
					ntag.set("tag", tag);
					ntag.set("creation_date", new DateTime.now_local().format("%Y-%m-%d %H:%M:%S"));
					tag_id = (int)dbh.Insert("tags", ntag);
					/*
					//##add tag to product
					var t2p = new HashMap<string, Value?>();
					t2p.set("product_id", this.product.Id);
					t2p.set("tag_id", tag_id);
					p2t_id = (int)dbh.Insert("product2tag", t2p);
					*/
				}
				else
				{
					tag_id = row.GetInt("tag_id");
				}
				
				//##check if product already has the tag
				var trow = dbh.GetRow("SELECT * FROM product2tag WHERE tag_id = %d AND product_id = %d".
										printf(tag_id, this.product.Id));
				if( trow == null )
				{
					//##add tag to product
					var t2p = new HashMap<string, Value?>();
					t2p.set("product_id", this.product.Id);
					t2p.set("tag_id", tag_id);
					p2t_id = (int)dbh.Insert("product2tag", t2p);
				}
				else
				{
					tag_in_product = true;
				}
			}
			stdout.printf("tag_in_product: %s\n", tag_in_product.to_string());
			this.entryTag.text = "";
			this.buttonAddTag.set_data<int>("tag_id", 0);
			if( tag_in_product )
				return;
			TreeIter iter;
			(this.treeviewTags.model as ListStore).append(out iter);
			(this.treeviewTags.model as ListStore).set(iter,
				0, tag,
				1, (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("remove-20x20.png"),
				2, p2t_id
			);
			
		}
		protected bool OnTreeViewTagsButtonReleaseEvent(Gdk.EventButton args)
		{
			TreePath path;
			TreeViewColumn c;
			TreeIter iter;
			TreeModel model;
			int cell_x, cell_y;
			
			if( !this.treeviewTags.get_path_at_pos((int)args.x, (int)args.y, out path, out c, out cell_x, out cell_y) )
				return false;
		
			if( !this.treeviewTags.get_selection().get_selected(out model, out iter) )
				return false;
			
			string action = c.get_data<string>("action");
			if( action == "remove" )
			{
				//##remove tag id from product tags
				var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
				Value p2t_id;
				model.get_value(iter, 2, out p2t_id);
				dbh.Execute("DELETE FROM product2tag WHERE id = %d".printf((int)p2t_id));
				(this.treeviewTags.model as ListStore).remove(iter);
				
			}
			return false;
		}
		protected void OnButtonAddImageClicked()
		{
			var fc = new FileChooserDialog(SBText.__("Select product image"), null, 
											FileChooserAction.OPEN,
											SBText.__("_Cancel"),
											ResponseType.CANCEL,
											SBText.__("_Open"),
											ResponseType.ACCEPT
			);
			fc.select_multiple = true;
			var filter = new FileFilter();
			filter.add_mime_type("image/jpeg");
			filter.add_mime_type("image/png");
			filter.add_mime_type("image/gif");
			//filter.add_mime_type("image/bmp");
			fc.set_filter(filter);
			var img_preview = new Image();
			fc.set_preview_widget(img_preview);
			fc.update_preview.connect( () => 
			{
				string uri = fc.get_preview_uri();
				// We only display local files:
				if( uri != null && uri.has_prefix ("file://") == true) 
				{
					try 
					{
						Gdk.Pixbuf pixbuf = new Gdk.Pixbuf.from_file_at_scale (uri.substring (7), 150, 	150, true);
						img_preview.set_from_pixbuf (pixbuf);
						img_preview.show ();
					} 
					catch (Error e) 
					{
						img_preview.hide ();
					}
				} 
				else 
				{
					img_preview.hide ();
				}
			});
			/*
			int fixed_width = this.viewport1.get_allocated_width();
			int margin = 10;
			int button_width = 150;
			int button_height = 150;
			int total_cols = (int)Math.ceil(fixed_width / 150);
			stdout.printf("available space: %d\ntotal columns: %d\n", fixed_width, total_cols);
			*/
			
			// Process response:
			if( fc.run () == Gtk.ResponseType.ACCEPT) 
			{
				/*
				if( this.fixedX == 0 && this.fixedY == 0 )
				{
					this.fixedX += 5;
					this.fixedY += 5;
				}
				*/
				SList<string> uris = fc.get_uris ();
				//stdout.printf ("Selection:\n");
				foreach (string uri in uris)
				{
					this.addImage(uri);
				}
			}

			// Close the FileChooserDialog:
			fc.close ();
			//
			//stdout.printf("base_line_row: %d\n", this.gridImages.get_baseline_row());
		}
		protected void addImage(string filename, int id = 0)
		{
			//stdout.printf("fixed width:%d\n", this.fixedWidth);
			int margin = 10;
			int button_width = 150;
			int button_height = 150;
			int total_cols = (int)Math.ceil(this.fixedWidth / 150);
			
			if( this.fixedX == 0 && this.fixedY == 0 )
			{
				this.fixedX += 5;
				this.fixedY += 5;
			}
			var image = new Image();
			try
			{
				//image.pixbuf = new Gdk.Pixbuf.from_file_at_scale ((filename.index_of("file://") != -1) ? filename.substring (7) : filename, 150, 	150, false);
				image.pixbuf = new Gdk.Pixbuf.from_file( (filename.index_of("file://") != -1) ? filename.substring (7) : filename);
				if(image.pixbuf.width > 150)
				{
					image.pixbuf = image.pixbuf.scale_simple(150, 150, Gdk.InterpType.BILINEAR);
				}
				image.pixbuf.set_data<string>("uri", filename);
				image.pixbuf.set_data<int>("id", id);
			}
			catch(GLib.Error e)
			{
				if( e.code == 4 )
				{
					image.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("placeholder-80x80.png");
					stderr.printf("ERROR: %s, using placeholder\n", e.message);
				}
				else
				{
					stderr.printf("ERROR: %s, CODE: %d\n", e.message, e.code);
				}
			}
			image.show ();
			var overlay = new Overlay();
			var box = new Box(Orientation.VERTICAL, 0);
			var btn_remove_img = new Button.with_label(SBText.__("X")){valign = Align.CENTER,halign = Align.CENTER};
			overlay.show();
			box.show();
			btn_remove_img.hide();
			
			var button = new Button(){relief = ReliefStyle.NONE, image = image};
			button.set_events(Gdk.EventMask.ALL_EVENTS_MASK);
			button.show();
			button.set_size_request(button_width, button_height);
			//button.enter_notify_event.connect( () => 
			button.clicked.connect( () => 
			{
				btn_remove_img.show();
			});
			//button.leave_notify_event.connect( () => 
			button.focus_out_event.connect( () => 
			{
				btn_remove_img.hide();
				return true;
			});
			box.add(button);
			overlay.add(box);
			overlay.add_overlay(btn_remove_img);
			this.fixedImages.put(overlay, this.fixedX, this.fixedY);
			this.fixedX += button_width + margin;
			this.fixedCol++;
			if( this.fixedCol == total_cols)
			{
				this.fixedCol 	= 0;
				this.fixedX 	= 5;
				this.fixedY 	+= button_height + margin;
			}
		}
		protected void OnButtonCancelClicked()
		{
			var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
			if( this.product == null )
				notebook.RemovePage("new-product");
			else
				notebook.RemovePage("edit-product");
		}
		protected void OnButtonSaveClicked()
		{
			string product_code	= this.entryCode.text.strip();
			string product_name = this.entryName.text.strip();
			string barcode		= this.entryBarcode.text.strip();
			string description	= this.textviewDescription.buffer.text.strip();
			int	department_id	= (this.comboboxDepartment.active_id != null) ? int.parse(this.comboboxDepartment.active_id) : -1;
			int unit_measure_id	= this.comboboxUnitofMeasure.active_id != null ? int.parse(this.comboboxUnitofMeasure.active_id) : -1;
			string status		= this.comboboxStatus.active_id != null ? this.comboboxStatus.active_id : "active";
			double cost, price, price2;
			
			int store_id 		= (this.comboboxStoreBranch.active_id == null || this.comboboxStoreBranch.active_id == "-1") ? -1 :  int.parse(this.comboboxStoreBranch.active_id);
			int64 quantity = 0, min_quantity = 0;
			bool uses_stock = this.checkbuttonUsesStock.active;
			long pid = 0;
			string message = "";
			
			if( product_name.length <= 0 )
			{
				this.entryName.grab_focus();
				return;
			}
			if( !double.try_parse(this.entryCost.text.strip(), out cost) )
			{
				this.entryCost.grab_focus();
				return;
			}
			if( !double.try_parse(this.entryPrice.text.strip(), out price) )
			{
				this.entryPrice.grab_focus();
				return;
			}
			
			if( !double.try_parse(this.entryPrice2.text.strip(), out price2) )
			{
				price2 = 0.0;
			}
			if( store_id == -1 )
			{
				this.comboboxStoreBranch.grab_focus();
				this.notebook1.set_current_page(2);
				return;
			}
			int cat_id = 0;
			if( this.comboboxCategories.active_id != null && this.comboboxCategories.active_id != "-1" )
			{
				cat_id = int.parse(this.comboboxCategories.active_id);
			}
			if( !int64.try_parse(this.entryQuantity.text.strip(), out quantity) )
			{
				quantity = 0;
			}
			if( !int64.try_parse(this.entryMinQuantity.text.strip(), out min_quantity) )
			{
				min_quantity = 0;
			}
			
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var date = new DateTime.now_local();
			string cdate = date.format("%Y-%m-%d %H:%M:%S");
			var data = new HashMap<string, Value?>();
			data.set("product_code", product_code);
			data.set("product_name", product_name);
			data.set("product_description", description);
			data.set("product_barcode", barcode);
			data.set("product_unit_measure", unit_measure_id);
			data.set("product_cost", cost);
			data.set("product_price", price);
			data.set("product_price_2", price2);
			data.set("store_id", store_id);
			data.set("product_quantity", (int)quantity);
			data.set("min_stock", (int)min_quantity);
			data.set("department_id", department_id);
			data.set("status", status);
			data.set("last_modification_date", cdate);
			dbh.BeginTransaction();
			
			var meta = new HashMap<string, Value?>();
			meta.set("uses_stock", this.checkbuttonUsesStock.active ? "yes" : "no");
			meta.set("tax_rate_id", (this.comboboxTaxRates.active_id != null) ? this.comboboxTaxRates.active_id : "-1");
			
			//##insert a new product
			if( this.product == null )
			{
				data.set("creation_date", cdate);
				pid = dbh.Insert("products", data);
				message = SBText.__("The product has been created.");				
			}
			//##update product data
			else
			{
				pid = this.product.Id;
				var w = new HashMap<string, Value?>();
				w.set("product_id", pid);
				dbh.Update("products", data, w);
				message = SBText.__("The product has been updated.");
			}
			//##check if product code is empty
			if( product_code.length <= 0 )
			{
				product_code = Utils.FillCeros((int)pid);
				//##generate product code
				if( cat_id > 0 )
				{
					product_code = "%d-%s".printf(cat_id, product_code);
				}
				dbh.Execute("UPDATE products SET product_code = '%s' WHERE product_id = %ld".printf(product_code, pid));
			}
			//set product meta
			foreach(string key in meta.keys)
			{
				SBProduct.UpdateMeta((int)pid, key, meta[key]);
			}
			//##check images
			this.fixedImages.get_children().foreach( (overlay) => 
			{
				var box = (Box)(overlay as Overlay).get_child();
				var btn = (Button)box.get_children().first().data;
				date = new DateTime.now_local();
				cdate = date.format("%Y-%m-%d %H:%M:%S");
				string uri = (btn.image as Image).pixbuf.get_data<string>("uri");
				int attachment_id = (btn.image as Image).pixbuf.get_data<int>("id");
				if( attachment_id == 0 )
				{
					//stdout.printf("uri => %s\n", uri);
					string filename = Path.get_basename(uri);
					string[] parts = SBFileHelper.GetParts(filename);
					string image_file = SBFileHelper.GetUniqueFilename("images", filename);
					stdout.printf("%s\n", image_file);
					//insert product attachment
					var attach = new HashMap<string, Value?>();
					attach.set("object_type", "product");
					attach.set("object_id", pid);
					attach.set("title", image_file);
					attach.set("description", "");
					attach.set("type", "image");
					attach.set("mime", parts[0]);
					attach.set("file", image_file);
					attach.set("last_modification_date", cdate);
					attach.set("creation_date", cdate);
					dbh.Insert("attachments", attach);
					try
					{
						(btn.image as Image).pixbuf.save("images/%s".printf(image_file), (parts[1] == "jpg") ? "jpeg" : parts[1]);
					}				
					catch(GLib.Error e)
					{
						stderr.printf("ERROR SAVING IMAGE, %s\n", e.message);
					}
				}
			});
			//##delete categories
			string query = @"DELETE FROM product2category WHERE product_id = $pid";
			dbh.Execute(query);
			if( cat_id > 0 )
			{
				var cats = new HashMap<string, Value?>();
				cats.set("product_id", pid);
				cats.set("category_id", cat_id);
				//cat.set("creation_date", );
				dbh.Insert("product2category", cats);
			}
			//##delete all serial numbers
			query = "DELETE FROM product_sn WHERE product_id = %ld".printf(pid);
			dbh.Execute(query);
			this.treeviewSn.model.foreach( (_model, _path, _iter) => 
			{
				Value sn;
				_model.get_value(_iter, 1, out sn);
				
				var dsn = new HashMap<string, Value?>();
				dsn.set("product_id", pid);
				dsn.set("sn", sn);
				dsn.set("last_modification_date", cdate);
				dsn.set("creation_date", cdate);
				dbh.Insert("product_sn", dsn);
				return false;
			});
			//##delete all product suppliers
			query = "DELETE FROM product2suppliers WHERE product_id = %ld".printf(pid);
			dbh.Execute(query);
			this.treeviewSuppliers.model.foreach( (_model, _path, _iter) => 
			{
				Value sid;
				_model.get_value(_iter, 4, out sid);
				
				var p2s = new HashMap<string, Value?>();
				p2s.set("product_id", pid);
				p2s.set("supplier_id", (int)sid);
				p2s.set("creation_date", cdate);
				dbh.Insert("product2suppliers", p2s);
				return false;
			});
			dbh.EndTransaction();
			var dlg = new InfoDialog()
			{
				Title	= SBText.__("Product message"),
				Message = message
			};
			dlg.run();
			dlg.destroy();
		}
		protected void OnButtonAddSnClicked()
		{
			int i = 0;
			this.treeviewSn.model.foreach((model, path, iter) => 
			{
				i++;
				return false;
			});
			TreeIter iter;
			(this.treeviewSn.model as ListStore).append(out iter);
			string sn = this.entrySn.text.strip();
			(this.treeviewSn.model as ListStore).set(iter, 0, i + 1, 1, sn);
		}
		protected void OnButtonRemoveSnClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewSn.get_selection().get_selected(out model, out iter) )
				return;
			
			(this.treeviewSn.model as ListStore).remove(iter);
		}
		protected bool OnEntrySearchSupplierKeyReleaseEvent(Gdk.EventKey event)
		{
			//skip up, down keys
			if( event.keyval == 65364 || event.keyval == 65362)
			{
				return true;
			}
			
			(this.entrySearchSupplier.completion.model as ListStore).clear();
			string keyword = this.entrySearchSupplier.text.strip();
			if( keyword.length <= 0 )
			{
				return false;
			}
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM suppliers WHERE supplier_name LIKE '%s'".printf("%"+keyword+"%");
			TreeIter iter;
			foreach(var row in dbh.GetResults(query))
			{
				(this.entrySearchSupplier.completion.model as ListStore).append(out iter);
				(this.entrySearchSupplier.completion.model as ListStore).set(iter, 
					0, row.GetInt("supplier_id"),
					1, row.Get("supplier_name")
				);
			}
			
			return true;
		}
		protected bool OnSearchSupplierCompletionMatchSelected(TreeModel model, TreeIter iter)
		{
			Value supplier_id, supplier;
			
			model.get_value(iter, 0, out supplier_id);
			model.get_value(iter, 1, out supplier);
			this.entrySearchSupplier.set_data<int>("supplier_id", (int)supplier_id);
			this.entrySearchSupplier.text = (string)supplier;
			
			return true;
		}
		protected void OnButtonAddSupplierClicked()
		{
			int? supplier_id = this.entrySearchSupplier.get_data<int>("supplier_id");
			if( supplier_id == null || supplier_id <= 0 )
			{
				return;
			}
			/*
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("supplier_id").
				From("product2suppliers").
				Where("supplier_id = %d".printf(supplier_id)).
				And("product_id = %d".printf());
			*/
			var supplier = new ESupplier.from_id(supplier_id);
			this.AddSupplier(supplier);
			this.entrySearchSupplier.set_data<int>("supplier_id", 0);
			this.entrySearchSupplier.text = "";
			this.entrySearchSupplier.grab_focus();
		}
		protected void AddSupplier(ESupplier supplier)
		{
			TreeIter iter;
			bool exists = false;
			int i = 0;
			
			this.treeviewSuppliers.model.foreach((model, path, _iter) => 
			{
				Value sid;
				model.get_value(_iter, 4, out sid);
				if( supplier.Id == (int)sid )
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
					Title = SBText.__("Error adding supplier"),
					Message = SBText.__("The supplier is already assigned to this product")
				};
				msg.run();
				msg.destroy();
				return;
			}
			(this.treeviewSuppliers.model as ListStore).append(out iter);
			(this.treeviewSuppliers.model as ListStore).set(iter,
				0, i + 1,
				1, supplier.Name,
				2, supplier.Email,
				3, supplier.Telephone1,
				4, supplier.Id
			);
		}
	}
}
