using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;

namespace EPos.Woocommerce
{
	public class WidgetWoocommerceProducts : Box
	{
		protected	Builder			ui;
		protected	Box				box1;
		protected	Image			image1;
		protected	ComboBox		comboboxStore;
		protected	ComboBox		comboboxCategories;
		protected	Button			buttonDetails;
		protected	Button			buttonSync;
		protected	Entry			entrySearch;
		protected	ComboBox		comboboxSearchBy;
		protected	TreeView		treeviewProducts;
		protected	enum			Columns
		{
			SELECT,
			COUNT,
			IMAGE,
			ID,
			WOO_ID,
			TITLE,
			SKU,
			QUANTITY,
			PRICE,
			CATEGORIES,
			N_COLS
		}
		protected	int				storeId = 0;
		protected	bool			lockCategoriesEvent = false;
		protected	WindowSyncProductsProgress	windowProgress;
		
		public WidgetWoocommerceProducts()
		{
			this.ui					= (SBModules.GetModule("Woocommerce") as SBGtkModule).GetGladeUi("products.glade");
			this.box1				= (Box)this.ui.get_object("box1");
			this.image1				= (Image)this.ui.get_object("image1");
			this.comboboxStore		= (ComboBox)this.ui.get_object("comboboxStore");
			this.comboboxCategories	= (ComboBox)this.ui.get_object("comboboxCategories");
			this.buttonDetails		= (Button)this.ui.get_object("buttonDetails");
			this.buttonSync			= (Button)this.ui.get_object("buttonSync");
			this.entrySearch		= (Entry)this.ui.get_object("entrySearch");
			this.comboboxSearchBy	= (ComboBox)this.ui.get_object("comboboxSearchBy");
			this.treeviewProducts	= (TreeView)this.ui.get_object("treeviewProducts");
			this.box1.reparent(this);
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			this.image1.pixbuf = (SBModules.GetModule("Woocommerce") as SBGtkModule).GetPixbuf("woocommerce_logo-64x64.png");
			//##builder combobox stores
			this.comboboxStore.model = new ListStore(2, typeof(string), typeof(string));
			var cell = new CellRendererText();
			this.comboboxStore.pack_start(cell, true);
			this.comboboxStore.set_attributes(cell, "text", 0);
			this.comboboxStore.id_column = 1;
			//##build combobox categories
			this.comboboxCategories.model = new TreeStore(2, typeof(string), typeof(string));
			cell = new CellRendererText();
			this.comboboxCategories.pack_start(cell, true);
			this.comboboxCategories.set_attributes(cell, "text", 0);
			this.comboboxCategories.id_column = 1;
			
			this.treeviewProducts.model = new ListStore(Columns.N_COLS,
				typeof(bool), //select
				typeof(int), //count
				typeof(Gdk.Pixbuf),
				typeof(int), //ID
				typeof(int), //Woo id
				typeof(string), //title
				typeof(string), //sku
				typeof(int), //qty
				typeof(string), //price
				typeof(string) //categories
			);
			string[,] cols = 
			{
				{SBText.__("Select"), "toggle", "40", "center", "", ""},
				{"#", "text", "40", "center", "", ""},
				{SBText.__("Image"), "pixbuf", "80", "center", "", ""},
				{SBText.__("ID"), "text", "40", "center", "", ""},
				{SBText.__("Woo ID"), "text", "40", "center", "", ""},
				{SBText.__("Title"), "text", "180", "left", "", ""},
				{SBText.__("SKU"), "text", "180", "left", "", ""},
				{SBText.__("Qty"), "text", "50", "center", "", ""},
				{SBText.__("Price"), "text", "60", "right", "", ""},
				{SBText.__("Categories"), "text", "220", "left", "", ""},
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewProducts);
			this.treeviewProducts.rules_hint = true;
			//##refresh stores
			TreeIter iter;
			(this.comboboxStore.model as ListStore).append(out iter);
			(this.comboboxStore.model as ListStore).set(iter, 
				0, SBText.__("-- store --"),
				1, "-1"
			);
			foreach(var store in WCHelper.GetStores())
			{
				(this.comboboxStore.model as ListStore).append(out iter);
				(this.comboboxStore.model as ListStore).set(iter, 
					0, store.Name,
					1, store.Id.to_string()
				);
			}
			this.comboboxStore.active_id = "-1";
		}
		protected void SetEvents()
		{
			this.comboboxStore.changed.connect(this.OnComboBoxStoreChanged);
			this.comboboxCategories.changed.connect(this.OnComboBoxCategoriesChanged);
			this.buttonSync.clicked.connect(this.OnButtonSyncClicked);
		}
		protected void OnComboBoxStoreChanged()
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1" )
			{
				(this.comboboxCategories.model as TreeStore).clear();
				return;
			}
			this.lockCategoriesEvent = true;
			this.SetStoreCategories(int.parse(this.comboboxStore.active_id));
			this.RefreshProducts(int.parse(this.comboboxStore.active_id));
			this.lockCategoriesEvent = false;
		}
		protected void OnComboBoxCategoriesChanged()
		{
			if( this.lockCategoriesEvent )
				return;
			int store_id = int.parse(this.comboboxStore.active_id);
			if( this.comboboxCategories.active_id == null || this.comboboxCategories.active_id == "-1" )
			{
				this.RefreshProducts(store_id);
				return;
			}
			int category_id = int.parse(this.comboboxCategories.active_id);
			this.RefreshProducts(store_id, category_id);
		}
		protected void SetStoreCategories(int store_id)
		{
			(this.comboboxCategories.model as TreeStore).clear();
			
			TreeIter iter;
			(this.comboboxCategories.model as TreeStore).append(out iter, null);
			(this.comboboxCategories.model as TreeStore).set(iter,
				0, SBText.__("-- categories --"),
				1, "-1"
			);
			foreach(var cat in EPosHelper.GetCategories(store_id))
			{
				(this.comboboxCategories.model as TreeStore).append(out iter, null);
				(this.comboboxCategories.model as TreeStore).set(iter,
					0, cat.Name,
					1, cat.Id.to_string()
				);
				TreeIter child_iter;
				foreach(var child in cat.Childs)
				{
					(this.comboboxCategories.model as TreeStore).append(out child_iter, iter);
					(this.comboboxCategories.model as TreeStore).set(child_iter,
						0, child.Name,
						1, child.Id.to_string()
					);
					TreeIter schild_iter;
					foreach(var schild in child.Childs)
					{
						(this.comboboxCategories.model as TreeStore).append(out schild_iter, child_iter);
						(this.comboboxCategories.model as TreeStore).set(schild_iter,
							0, schild.Name,
							1, schild.Id.to_string()
						);
					}
				}
			}
			this.comboboxCategories.active_id = "-1";
		}
		protected void RefreshProducts(int store_id, int cat_id = 0)
		{
			ArrayList<SBProduct> products;
			if( cat_id > 0 )
			{
				products = EPosHelper.GetCategoryProducts(cat_id);
			}
			else
			{
				products = EPosHelper.GetStoreProducts(store_id);
			}
			(this.treeviewProducts.model as ListStore).clear();
			Gdk.Pixbuf place_holder = (SBModules.GetModule("Woocommerce") as SBGtkModule).GetPixbuf("placeholder-80x80.png");
			TreeIter iter;
			int i = 1;
			
			foreach(var prod in products)
			{
				string store_folder = "images/store_%d/".printf(prod.StoreId);
				string thumb = prod.GetThumbnail();
				if( thumb != "" )
				{
					thumb = store_folder + thumb;
				}
				(this.treeviewProducts.model as ListStore).append(out iter);
				(this.treeviewProducts.model as ListStore).set(iter,
					Columns.SELECT, false,
					Columns.COUNT, i,
					Columns.IMAGE, (thumb != "") ? new Gdk.Pixbuf.from_file(thumb): place_holder,
					Columns.ID, prod.Id,
					Columns.WOO_ID, prod.GetInt("extern_id"),
					Columns.TITLE, prod.Name,
					Columns.SKU, prod.Code,
					Columns.QUANTITY, prod.Quantity,
					Columns.PRICE, "%.2f".printf(prod.Price),
					Columns.CATEGORIES, prod.Meta["wc_categories"] != null ? (string)prod.Meta["wc_categories"] : ""
				);
				i++;
			}
		}
		protected void OnButtonSyncClicked()
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1" )
			{
				var err = new InfoDialog()
				{
					Title = SBText.__("Products Synchronization error"),
					Message = SBText.__("You need to select a store")
				};
				err.run();
				err.destroy();
				return;
			}
			this.storeId = int.parse(this.comboboxStore.active_id);
			try
			{
				this.windowProgress = new WindowSyncProductsProgress();
				this.windowProgress.show();
				Thread<int> thread = new Thread<int>.try ("Woocommerce Sync Products thread", this.SyncProducts);
			}
			catch(GLib.Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
		}
		protected int SyncProducts()
		{
			var cfg = (SBConfig)SBGlobals.GetVar("config");
			string url = SBStore.SGetMeta(this.storeId, "woocommerce_url");
			string key = SBStore.SGetMeta(this.storeId, "woocommerce_key");
			string secret = SBStore.SGetMeta(this.storeId, "woocommerce_secret");
			var sync = new SBWCSync(url, key, secret);
			sync.Dbh = SBFactory.GetNewDbHandlerFromConfig(cfg);
			sync.SyncProducts(this.storeId, 
				(totals, imported, item_name, message) => 
				{
					GLib.Idle.add( () => 
					{
						if( item_name != "" )
							this.windowProgress.labelProductName.label = item_name;
						this.windowProgress.labelImportedProducts.label = "%d".printf(imported);
						this.windowProgress.labelTotalProducts.label = "%d".printf(totals);
						double fraction = (imported * 100) / totals;
						this.windowProgress.progressbarGlobal.fraction = fraction / 100;
						return false;
					});
				},
				(current_num_bytes, total_num_bytes) => 
				{
					GLib.Idle.add( () => 
					{
						this.windowProgress.labelBytes.label = "%d of %d bytes".printf((int)current_num_bytes, (int)total_num_bytes);
						double fraction = (current_num_bytes * 100) / total_num_bytes;
						this.windowProgress.progressbarDownload.fraction = fraction / 100;
						return false;
					});
				}
			);
			sync.Dbh.Close();
			
			GLib.Idle.add( () => 
			{
				this.RefreshProducts(this.storeId);
				return false;
			});
			return 0;
		}
	}
}
