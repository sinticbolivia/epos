using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetProductsSearch : Box
	{
		protected	Builder			ui;
		protected	Box				box1;
		protected	Image			image1;
		protected	Entry			entrySearch;
		protected	ComboBox		comboboxSearchBy;
		protected	TreeView		treeviewProducts0;
		protected	TreeViewColumn	columnSelect;
		protected	CheckButton		checkbuttonSelect;
		protected	Button			buttonCancel;
		protected	Button			buttonSelect;
		
		public		ListStore		Model
		{
			get{return (ListStore)this.treeviewProducts0.model;}
		}
		public		Button			ButtonCancel{get;protected set;}
		
		public 		signal 			void 			OnSelected(ArrayList<SBProduct> products);
		
		protected	enum 			Columns	
		{
			SELECT,
			COUNT,
			ID,
			NAME,
			QUANTITY,
			PRICE,
			N_COLS
		}
		protected	int				storeId = 0;
		
		public WidgetProductsSearch()
		{
			this.ui					= (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("widget.product-search.glade");
			this.box1				= (Box)this.ui.get_object("box1");
			this.image1				= (Image)this.ui.get_object("image1");
			this.entrySearch		= (Entry)this.ui.get_object("entrySearch");
			this.comboboxSearchBy	= (ComboBox)this.ui.get_object("comboboxSearchBy");
			this.treeviewProducts0	= (TreeView)this.ui.get_object("treeviewProducts");
			this.buttonCancel		= (Button)this.ui.get_object("buttonCancel");
			this.buttonSelect		= (Button)this.ui.get_object("buttonSelect");
			this.box1.reparent(this);
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			this.image1.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("search-icon-64x64.png");
			var model = new ListStore(Columns.N_COLS, 
				typeof(bool), //select
				typeof(int), //count
				typeof(int), //product id
				typeof(string), //product name
				typeof(int), //quantity
				typeof(string) //price
			);
			this.treeviewProducts0.set_model(model);
			
			string[,] cols = 
			{
				{"Select", "toggle", "50", "center", "", ""},
				{"#", "text", "50", "center", "", ""},
				{"ID", "text", "50", "center", "", ""},
				{SBText.__("Product"), "text", "250", "left", "", ""},
				{SBText.__("Qty"), "text", "70", "center", "", ""},
				{SBText.__("Price"), "text", "90", "right", "", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewProducts0);
			this.treeviewProducts0.rules_hint = true;
			
			this.columnSelect = this.treeviewProducts0.get_column(Columns.SELECT);
			this.checkbuttonSelect = new CheckButton();
			this.checkbuttonSelect.show();
			this.columnSelect.widget		= this.checkbuttonSelect;
			this.columnSelect.clickable 	= true;
			//##build combobox search by
			var cell = new CellRendererText();
			this.comboboxSearchBy.model = new ListStore(2, typeof(string), typeof(string));
			this.comboboxSearchBy.pack_start(cell, true);
			this.comboboxSearchBy.set_attributes(cell, "text", 0);
			this.comboboxSearchBy.id_column = 1;
			string[,] searchs = 
			{
				{SBText.__("Name"), "name"},
				{SBText.__("ID"), "id"},
				{SBText.__("Code"), "code"},
				{SBText.__("Barcode"), "barcode"},
				{SBText.__("Tag"), "tag"}
			};
			TreeIter iter;
			for(int i = 0; i < searchs.length[0]; i++)
			{
				(this.comboboxSearchBy.model as ListStore).append(out iter);
				(this.comboboxSearchBy.model as ListStore).set(iter,
					0, searchs[i, 0],
					1, searchs[i, 1]
				);
			}
			this.comboboxSearchBy.active_id = "name";
			
		}
		protected void SetEvents()
		{
			this.entrySearch.key_release_event.connect(this.OnEntrySearchKeyReleaseEvent);
			this.columnSelect.clicked.connect( () => 
			{
				this.checkbuttonSelect.active = !this.checkbuttonSelect.active;
			});
			this.checkbuttonSelect.clicked.connect(this.OnCheckButtonSelectClicked);
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
			this.buttonSelect.clicked.connect(this.OnButtonSelectClicked);
		}
		protected void OnCheckButtonSelectClicked()
		{
			bool select = false;
			if( this.checkbuttonSelect.active )
			{
				select = true;
			}
			this.treeviewProducts0.model.foreach( (model, path, iter) => 
			{
				(model as ListStore).set_value(iter, Columns.SELECT, select);
				return false;
			});
		}
		protected void OnButtonCancelClicked()
		{
			this.destroy();
		}
		protected void OnButtonSelectClicked()
		{
			var products = new ArrayList<SBProduct>();
			this.treeviewProducts0.model.foreach( (model, path, iter) => 
			{
				Value selected;
				model.get_value(iter, Columns.SELECT, out selected);
				if( !(bool)selected )
					return false;
				Value id;
				model.get_value(iter, Columns.ID, out id);
				var p = new SBProduct.from_id((int)id);
				products.add(p);
				return false;
			});
			this.OnSelected(products);
		}
		public void Refresh(int store_id, ArrayList<SBProduct>? items = null)
		{
			this.storeId = store_id;
			long total_prods = 0;
			(this.treeviewProducts0.model as ListStore).clear();
			int i = 1;
			TreeIter iter;
			ArrayList<SBProduct> products = (items != null) ? items : 
											InventoryHelper.GetStoreProducts(store_id, 1, 100, out total_prods);
			foreach(var prod in products)
			{
				(this.treeviewProducts0.model as ListStore).append(out iter);
				(this.treeviewProducts0.model as ListStore).set(iter,
					Columns.SELECT, false,
					Columns.COUNT, i,
					Columns.ID, prod.Id,
					Columns.NAME, prod.Name,
					Columns.QUANTITY, prod.Quantity,
					Columns.PRICE, "%.2f".printf(prod.Price)
				);
				i++;
			}
			
		}
		protected TreeIter? GetSelected()
		{
			TreeModel model;
			TreeIter iter;
			if( !this.treeviewProducts0.get_selection().get_selected(out model, out iter) )
			{
				return null;
			}
			
			return iter;
		}
		protected bool OnEntrySearchKeyReleaseEvent(Gdk.EventKey e)
		{
			if( e.keyval != 65293 )
				return true;
				
			string keyword = this.entrySearch.text.strip();
			if( keyword.length <= 0 )
				return true;
				
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string columns = "p.*";
			string tables = "products p";
			string query = "SELECT %s FROM %s WHERE %s";
			string where = "store_id = %d ".printf(this.storeId);
			
			string search_by = "name";
			if( keyword.index_of(":") != -1 )
			{
				string[] parts = keyword.split(":");
				search_by = parts[0].strip().down();
				keyword		= parts[1].strip();
			}
			else
			{
				//##user combobox as search by
				if( this.comboboxSearchBy.active_id != null && this.comboboxSearchBy.active_id != "-1" )
				{
					search_by = this.comboboxSearchBy.active_id.down();
				}
			}
			if( search_by == "name" )
			{
				where += "AND product_name LIKE '%s'".printf("%" + keyword + "%");
			}
			else if( search_by == "id" )
			{
				where += "AND product_id = %d".printf(int.parse(keyword));
			}
			else if( search_by == "tag" )
			{
				columns += ",t.tag_id, t.tag";
				tables += ",tags t, product2tag p2t";
				where += "AND p.product_id = p2t.product_id ";
				where += "AND p2t.tag_id = t.tag_id ";
				where += "AND t.tag = '%s'".printf(keyword);
			}
			else if( search_by == "code" )
			{
				where += "AND product_code LIKE '%s'".printf("%" + keyword + "%");
			}
			else if( search_by == "barcode" )
			{
				where += "AND product_barcode LIKE '%s'".printf("%" + keyword + "%");
			}
			query = query.printf(columns, tables, where);
			stdout.printf("QUREY: %s\n", query);
			var prods = new ArrayList<SBProduct>();
			foreach(var row in dbh.GetResults(query))
			{
				var p = new SBProduct.with_db_data(row);
				prods.add(p);
			}
			this.Refresh(this.storeId, prods);
			return true;
		}
	}
}
