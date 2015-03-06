using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Database;
using SinticBolivia.Gtk;

namespace EPos
{
	public class WindowLookupProducts : Window
	{
		protected	Builder		ui;
		protected	Box			boxLookupProducts;
		protected	Image		image1;
		protected	ComboBox	comboboxStores;
		protected	Entry		entryKeyword;
		protected	ComboBox	comboboxSearchBy;
		protected	TreeView	treeviewProducts;
		protected	Button		buttonClose;
		protected	Button		buttonSelect;
		
		public		int			StoreId
		{
			set
			{
				this.comboboxStores.active_id = value.to_string();
				this.comboboxStores.visible = false;
			}
		}
		public		int			ProductId = 0;
		
		protected 	enum		Columns
		{
			COUNT,
			ID,
			CODE,
			NAME,
			PRICE,
			N_COLS
		}
		public WindowLookupProducts()
		{
			this.title				= SBText.__("Lookup Products");
			this.set_size_request(500, 350);
			this.ui					= (SBModules.GetModule("Pos") as SBGtkModule).
											GetGladeUi("window.lookup-products.glade");
			this.boxLookupProducts	= (Box)this.ui.get_object("boxLookupProducts");
			this.image1				= (Image)this.ui.get_object("image1");
			this.comboboxStores		= (ComboBox)this.ui.get_object("comboboxStores");
			this.entryKeyword		= (Entry)this.ui.get_object("entryKeyword");
			this.comboboxSearchBy	= (ComboBox)this.ui.get_object("comboboxSearchBy");
			this.treeviewProducts	= (TreeView)this.ui.get_object("treeviewProducts");
			this.buttonClose		= (Button)this.ui.get_object("buttonClose");
			this.buttonSelect		= (Button)this.ui.get_object("buttonSelect");
			
			this.boxLookupProducts.reparent(this);
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			this.image1.pixbuf		= (SBModules.GetModule("Pos") as SBGtkModule).GetPixbuf("product-lookup-48x48.png");
			this.comboboxStores.model = new ListStore(2, typeof(string), typeof(string));
			var cell = new CellRendererText();
			this.comboboxStores.pack_start(cell, true);
			this.comboboxStores.set_attributes(cell, "text", 0);
			this.comboboxStores.id_column = 1;
			TreeIter iter;
			foreach(var store in EPosHelper.GetStores())
			{
				(this.comboboxStores.model as ListStore).append(out iter);
				(this.comboboxStores.model as ListStore).set(iter,
					0, store.Name,
					1, store.Id.to_string()
				);
			}
			this.comboboxSearchBy.model = new ListStore(2, typeof(string), typeof(string));
			cell = new CellRendererText();
			this.comboboxSearchBy.pack_start(cell, true);
			this.comboboxSearchBy.set_attributes(cell, "text", 0);
			this.comboboxSearchBy.id_column = 1;
			string[,] searchs = 
			{
				{SBText.__("ID"), "id"}, 
				{SBText.__("Code"), "code"}, 
				{SBText.__("Name"), "name"}, 
				{SBText.__("Barcode"), "barcode"}
			};
			for(int i = 0; i < searchs.length[0]; i++)
			{
				(this.comboboxSearchBy.model as ListStore).append(out iter);
				(this.comboboxSearchBy.model as ListStore).set(iter,
					0, searchs[i, 0],
					1, searchs[i, 1]
				);
			}
			this.comboboxSearchBy.active_id = "name";
			
			this.treeviewProducts.model = new ListStore(Columns.N_COLS,
				typeof(int),//count
				typeof(int), //id
				typeof(string), //code
				typeof(string), //name
				typeof(string) //price
			);
			string[,] cols = 
			{
				{"#", "text", "60", "center", "", ""},
				{SBText.__("ID"), "text", "60", "center", "", ""},
				{SBText.__("Code"), "text", "100", "left", "", ""},
				{SBText.__("Name"), "text", "220", "left", "", ""},
				{SBText.__("Price"), "text", "60", "right", "", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewProducts);
			this.treeviewProducts.rules_hint = true;
		}
		protected void SetEvents()
		{
			this.entryKeyword.key_release_event.connect(this.OnEntryKeywordKeyReleaseEvent);
			this.treeviewProducts.row_activated.connect(this.OnTreeViewProductsRowActivated);
			this.buttonClose.clicked.connect( () => 
			{
				this.destroy();
			});
			this.buttonSelect.clicked.connect(this.OnButtonSelectClicked);
		}
		protected bool OnEntryKeywordKeyReleaseEvent(Gdk.EventKey event)
		{
			if( event.keyval == 65364 || event.keyval == 65362)
			{
				return true;
			}
			if( this.comboboxStores.active_id == null || this.comboboxStores.active_id == "-1" )
			{
				var err = new InfoDialog()
				{
					Title = SBText.__("Lookup error"),
					Message = SBText.__("You need to select a store.")
				};
				err.run();
				err.destroy();
				return true;
			}
			int store_id = int.parse(this.comboboxStores.active_id);
			string keyword = this.entryKeyword.text.strip();
			if( keyword.length <= 0 )
				return true;
			
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM products WHERE store_id = %d AND ".printf(store_id);
			string search_by = (this.comboboxSearchBy.active_id != null) ? this.comboboxSearchBy.active_id : "name";
			
			if( search_by == "id" )
			{
				query += "product_id = '%d'".printf(int.parse(keyword));
			}
			else if( search_by == "code" )
			{
				query += "product_code LIKE '%s'".printf("%"+keyword+"%");
			}
			else if( search_by == "name" )
			{
				query += "product_name LIKE '%s'".printf("%" + keyword + "%");
			}
			else if( search_by == "barcode" )
			{
				query += "product_barcode LIKE '%s'".printf("%" + keyword + "%");
			}
							
			var rows = dbh.GetResults(query);
			(this.treeviewProducts.model as ListStore).clear();
			TreeIter iter;
			int i = 1;
			foreach(var row in rows)
			{
				(this.treeviewProducts.model as ListStore).append(out iter);
				(this.treeviewProducts.model as ListStore).set(iter,
					Columns.COUNT, i,
					Columns.ID, row.GetInt("product_id"),
					Columns.CODE, row.Get("product_code"),
					Columns.NAME, row.Get("product_name"),
					Columns.PRICE, "%.2f".printf(row.GetDouble("product_price"))
				);
				i++;
			}
			return true;
		}
		protected void OnTreeViewProductsRowActivated(TreePath path, TreeViewColumn column)
		{
			GLib.Signal.emit_by_name(this.buttonSelect, "clicked");
		}
		protected void OnButtonSelectClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewProducts.get_selection().get_selected(out model, out iter) )
			{
				var err = new InfoDialog()
				{
					Title = SBText.__("Lookup error"),
					Message = SBText.__("You need to select a product.")
				};
				err.run();
				err.destroy();
				return;
			}
			Value product_id;
			model.get_value(iter, Columns.ID, out product_id);
			this.ProductId = (int)product_id;
			this.destroy();
		}
	}
}
