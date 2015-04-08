using GLib;
using Gtk;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;
using SinticBolivia.Gtk;

namespace EPos
{
	public class WidgetInventory : Gtk.Box
	{
		protected Builder	ui;
		
		protected   Window	    windowProducts;
		protected   Box         boxProducts = null;
		
		//##stores widgets declaration
		protected   Image		imageStores;
		protected   Label		labelStoresTitle;
		protected   Paned		panedBranches;
		protected   Button	    buttonAddStore;
		protected   Button	    buttonEditStore;
		protected   Button  	buttonDeleteStore;
		protected   Entry		entrySearchStore;
		protected   TreeView	treeviewStores;
		protected   Box		    boxStore;
		protected 	Entry		entryStoreName;
		protected 	Entry		entryStoreAddress;
		protected	ComboBox	comboboxTax;
		protected	ComboBox	comboboxSalesDocument;
		protected	ComboBox	comboboxPurchaseDocument;
		protected	ComboBox	comboboxRefundDocument;
		protected	ComboBox	comboboxAdjustmentDoc;
		protected 	Button		buttonSaveStore;
		protected 	Button		buttonCancelStore;
		//##categories widgets declaration
		protected Paned		panedCategories;
		protected Image		imageCategories;
		protected Button	buttonNewCategory;
		protected Button	buttonEditCategory;
		protected Button	buttonDeleteCategory;
		protected TreeView	treeviewCategories;
		protected ComboBox	comboboxCategoriesStore;
		protected Entry		entryCategoryName;
		protected TextView	textviewCategoryDescription;
		protected ComboBox	comboboxParentCategory;
		protected ComboBox	comboboxCategoryStore;
		protected Button	buttonSaveCategory;
		protected Button	buttonCancelCategory;
		//##products widgets declaration
		protected Image		imageProducts;
		protected ButtonBox	buttonboxProducts;
		protected Button	buttonNewProduct;
		protected Button	buttonEditProduct;
		protected Button	buttonDeleteProduct;
		protected ComboBox	comboboxStore;
		protected ComboBox	comboboxCategory;
		protected Button	buttonRefreshProducts;
		protected Entry		entrySearchProduct;
		protected ComboBox	comboboxProductSearchBy;
		protected TreeView	treeviewProducts;
		protected Button	buttonFirst;
		protected Button	buttonPrev;
		protected Button	buttonNext;
		protected Button	buttonLast;
		protected Label		labelTotalProducts;
		protected Label		labelViewProducts;
		protected Label		labelViewTotal;
		protected	bool	lockCategoryEvent = false;
		protected	int		productsPage{get;set;default = 1;}
		
		//##useful members
		protected int		_category_id = 0;
		protected int		_store_id = 0;
		protected int		_product_id = 0;
		
		enum ProductColumns
		{
			COUNT,
			ID,
			PIXBUF, //product image
			NAME, //product name
			BARCODE, //barcode
			QTY, //quantity
			COST, //cost
			PRICE, //price 
			N_COLUMNS
		}
		
		public WidgetInventory()
		{
			GLib.Object();
			//this.ui					= SB_ModuleInventory.GetGladeUi("products.glade");
			this.ui = (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("products.glade");
			this.windowProducts		= (Window)this.ui.get_object("windowProducts");
			this.boxProducts 		= (Box)this.ui.get_object("boxProducts");
			var image1				= (Image)this.ui.get_object("image1");
			try
			{
				image1.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("inventory-icon-64x64.png");
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			
			//##get branches widget
			this.imageStores		= (Image)this.ui.get_object("imageStores");
			this.labelStoresTitle	= (Label)this.ui.get_object("labelStoresTitle");
			this.panedBranches		= (Paned)this.ui.get_object("panedBranches");
			this.buttonAddStore		= (Button)this.ui.get_object("buttonAddStore");
			this.buttonEditStore	= (Button)this.ui.get_object("buttonEditStore");
			this.buttonDeleteStore	= (Button)this.ui.get_object("buttonDeleteStore");
			this.entrySearchStore	= (Entry)this.ui.get_object("entrySearchStore");
			this.treeviewStores		= (TreeView)this.ui.get_object("treeviewStores");
			this.boxStore			= (Box)this.ui.get_object("boxStore");
			this.entryStoreName		= (Entry)this.ui.get_object("entryStoreName");
			this.entryStoreAddress	= (Entry)this.ui.get_object("entryStoreAddress");
			this.comboboxTax		= (ComboBox)this.ui.get_object("comboboxTax");
			this.comboboxSalesDocument		= (ComboBox)this.ui.get_object("comboboxSalesDocument");
			this.comboboxPurchaseDocument	= (ComboBox)this.ui.get_object("comboboxPurchaseDocument");
			this.comboboxRefundDocument		= (ComboBox)this.ui.get_object("comboboxRefundDocument");
			this.comboboxAdjustmentDoc		= (ComboBox)this.ui.get_object("comboboxAdjustmentDoc");
			this.buttonSaveStore	= (Button)this.ui.get_object("buttonSaveStore");
			this.buttonCancelStore	= (Button)this.ui.get_object("buttonCancelStore");
			//##get categories widgets
			this.panedCategories	= (Paned)this.ui.get_object("panedCategories");
			this.imageCategories	= (Image)this.ui.get_object("imageCategories");
			this.buttonNewCategory	= (Button)this.ui.get_object("buttonNewCategory");
			this.buttonEditCategory = (Button)this.ui.get_object("buttonEditCategory");
			this.buttonDeleteCategory 		= (Button)this.ui.get_object("buttonDeleteCategory");
			this.comboboxCategoriesStore 	= (ComboBox)this.ui.get_object("comboboxCategoriesStore");
			this.treeviewCategories	= (TreeView)this.ui.get_object("treeviewCategories");
			this.entryCategoryName	= (Entry)this.ui.get_object("entryCategoryName");
			this.textviewCategoryDescription = (TextView)this.ui.get_object("textviewCategoryDescription");
			this.comboboxParentCategory = (ComboBox)this.ui.get_object("comboboxParentCategory");
			this.comboboxCategoryStore 	= (ComboBox)this.ui.get_object("comboboxCategoryStore");
			this.buttonSaveCategory		= (Button)this.ui.get_object("buttonSaveCategory");
			this.buttonCancelCategory	= (Button)this.ui.get_object("buttonCancelCategory");
			//##get products widgets
			this.imageProducts			= (Image)this.ui.get_object("imageProducts");
			this.buttonboxProducts		= (ButtonBox)this.ui.get_object("buttonboxProducts");
			this.buttonNewProduct		= (Button)this.ui.get_object("buttonNewProduct");
			this.buttonEditProduct		= (Button)this.ui.get_object("buttonEditProduct");
			this.buttonDeleteProduct	= (Button)this.ui.get_object("buttonDeleteProduct");
			this.comboboxStore			= (ComboBox)this.ui.get_object("comboboxStore");
			this.comboboxCategory		= (ComboBox)this.ui.get_object("comboboxCategory");
			this.buttonRefreshProducts	= (Button)this.ui.get_object("buttonRefreshProducts");
			this.entrySearchProduct		= (Entry)this.ui.get_object("entrySearchProduct");
			this.comboboxProductSearchBy= (ComboBox)this.ui.get_object("comboboxProductSearchBy");
			this.treeviewProducts		= (TreeView)this.ui.get_object("treeviewProducts");
			this.buttonFirst			= (Button)this.ui.get_object("buttonFirst");
			this.buttonPrev				= (Button)this.ui.get_object("buttonPrev");
			this.buttonNext				= (Button)this.ui.get_object("buttonNext");
			this.buttonLast				= (Button)this.ui.get_object("buttonLast");
			this.labelTotalProducts		= (Label)this.ui.get_object("labelTotalProducts");
			this.labelViewProducts		= (Label)this.ui.get_object("labelViewProducts");
			this.labelViewTotal			= (Label)this.ui.get_object("labelViewTotal");
			
			this.BuildStores();
			this.BuildCategories();
			this.BuildProducts();
			
			this.RefreshStores();
			//this.RefreshCategories();
			//this.RefreshProducts();
			
			this.SetEvents();
			this.boxProducts.reparent(this);	
			
			var args = new SBModuleArgs<HashMap>();		
			var data = new HashMap<string, Widget>();
			data.set("notebook", (Notebook)this.ui.get_object("notebookInventory"));
			args.SetData(data);
			SBModules.do_action("inventory_tabs", args);
		}
		protected void SetEvents()
		{
			/*
			if( this.buttonSaveStore.clicked.list_ids != null) 
				return;
			*/
			
			this.size_allocate.connect( (allocation) => 
			{
				//int h = this.get_allocated_height();
				int w = this.get_allocated_width();
				//stdout.printf("%dx%d\n", w, h);
				//this.panedBranches.position = (int)((70*w)/100);
				this.panedCategories.position = (int)(w * 0.6);
			});
			/*
			this.panedCategories.size_allocate.connect( (allocation) => 
			{
				this.panedCategories.position = (int)(this.panedCategories.get_allocated_width() * 0.6);
			});
			*/
			//##set store events
			this.buttonAddStore.clicked.connect(this.OnButtonAddStoreClicked);
			this.buttonEditStore.clicked.connect(this.OnButtonEditStoreClicked);
			this.buttonDeleteStore.clicked.connect(this.OnButtonDeleteStoreClicked);
			this.buttonSaveStore.clicked.connect(this.OnButtonSaveStoreClicked);
			this.buttonCancelStore.clicked.connect(this.OnButtonCancelStoreClicked);
			
			//##set categories events
			this.comboboxCategoriesStore.changed.connect(this.OnComboBoxCategoriesStoreChanged);
			this.buttonNewCategory.clicked.connect(this.OnButtonNewCategoryClicked);
			this.buttonEditCategory.clicked.connect(this.OnButtonEditCategoryClicked);
			this.buttonDeleteCategory.clicked.connect(this.OnButtonDeleteCategoryClicked);
			this.buttonSaveCategory.clicked.connect(this.OnButtonSaveCategoryClicked);
			//##set products events
			this.buttonNewProduct.clicked.connect(this.OnButtonNewProductClicked);
			this.buttonEditProduct.clicked.connect(this.OnButtonEditProductClicked);
			this.comboboxStore.changed.connect(this.OnComboboxStoreChanged);
			this.comboboxCategory.changed.connect(this.OnComboboxCategoryChanged);
			this.buttonRefreshProducts.clicked.connect(this.OnButtonRefreshProductsClicked);
			this.buttonPrev.clicked.connect( () => 
			{
				this.productsPage = (this.productsPage <= 0 ) ? 1 : this.productsPage - 1;
			});
			this.buttonNext.clicked.connect( () => 
			{
				this.productsPage = this.productsPage + 1;
			});
			this.notify["productsPage"].connect( () => 
			{
				int store_id = (this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1") ? -1 : int.parse(this.comboboxStore.active_id);
				int cat_id = (this.comboboxCategory.active_id == null || this.comboboxCategory.active_id == "-1") ? -1 : int.parse(this.comboboxCategory.active_id);
				this.RefreshProducts(store_id, cat_id);
			});
		}
		protected void BuildStores()
		{
			try
			{
				this.imageStores.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("store-64x48.png");
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			
			this.treeviewStores.model = new ListStore(2, typeof(int), typeof(string));
			if( this.treeviewStores.get_columns().length() > 0 )
			{
				return;
			}
			this.treeviewStores.insert_column_with_attributes(0, "Id", 
											new CellRendererText(){width = 70},
											"text", 0);
			this.treeviewStores.insert_column_with_attributes(1, "Name", 
											new CellRendererText(){width = 300},
											"text", 1);
			//##build tax combobox
			this.comboboxTax.model = new ListStore(2, typeof(string), typeof(string));
			var cell = new CellRendererText();
			this.comboboxTax.pack_start(cell, true);
			this.comboboxTax.set_attributes(cell, "text", 0);
			this.comboboxTax.id_column = 1;
			//##get taxes
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM tax_rates ORDER BY name ASC";
			var rows = dbh.GetResults(query);
			TreeIter iter;
			(this.comboboxTax.model as ListStore).append(out iter);
			(this.comboboxTax.model as ListStore).set(iter,
				0, SBText.__("-- tax --"),
				1, "-1" 
			);
			foreach(SBDBRow row in rows)
			{
				(this.comboboxTax.model as ListStore).append(out iter);
				(this.comboboxTax.model as ListStore).set(iter,
					0, row.Get("name"),
					1, row.Get("tax_id") 
				);
			}
			this.comboboxTax.active_id = "-1";
			//##build sales document
			this.comboboxSalesDocument.model = new ListStore(2, typeof(string), typeof(string));
			cell = new CellRendererText();
			this.comboboxSalesDocument.pack_start(cell, true);
			this.comboboxSalesDocument.set_attributes(cell, "text", 0);
			this.comboboxSalesDocument.id_column = 1;
			(this.comboboxSalesDocument.model as ListStore).append(out iter);
			(this.comboboxSalesDocument.model as ListStore).set(iter, 
				0, SBText.__("-- document --"),
				1, "-1"
			);
			query = "SELECT * FROM transaction_types ORDER BY transaction_name";
			rows = dbh.GetResults(query);
			foreach(var row in rows)
			{
				(this.comboboxSalesDocument.model as ListStore).append(out iter);
				(this.comboboxSalesDocument.model as ListStore).set(iter, 
					0, "%s (%s)".printf(row.Get("transaction_name"), row.Get("transaction_key")),
					1, row.Get("transaction_type_id")
				);
			}
			this.comboboxSalesDocument.active_id = "-1";
			//##build purchase document
			this.comboboxPurchaseDocument.model = new ListStore(2, typeof(string), typeof(string));
			cell = new CellRendererText();
			this.comboboxPurchaseDocument.pack_start(cell, true);
			this.comboboxPurchaseDocument.set_attributes(cell, "text", 0);
			this.comboboxPurchaseDocument.id_column = 1;
			(this.comboboxPurchaseDocument.model as ListStore).append(out iter);
			(this.comboboxPurchaseDocument.model as ListStore).set(iter, 
				0, SBText.__("-- document --"),
				1, "-1"
			);
			
			foreach(var row in rows)
			{
				(this.comboboxPurchaseDocument.model as ListStore).append(out iter);
				(this.comboboxPurchaseDocument.model as ListStore).set(iter, 
					0, "%s (%s)".printf(row.Get("transaction_name"), row.Get("transaction_key")),
					1, row.Get("transaction_type_id")
				);
			}
			this.comboboxPurchaseDocument.active_id = "-1";
			//##build refund document
			this.comboboxRefundDocument.model = new ListStore(2, typeof(string), typeof(string));
			cell = new CellRendererText();
			this.comboboxRefundDocument.pack_start(cell, true);
			this.comboboxRefundDocument.set_attributes(cell, "text", 0);
			this.comboboxRefundDocument.id_column = 1;
			(this.comboboxRefundDocument.model as ListStore).append(out iter);
			(this.comboboxRefundDocument.model as ListStore).set(iter, 
				0, SBText.__("-- document --"),
				1, "-1"
			);
			//##build adjustment combobox
			this.comboboxAdjustmentDoc.model = new ListStore(2, typeof(string), typeof(string));
			cell = new CellRendererText();
			this.comboboxAdjustmentDoc.pack_start(cell, true);
			this.comboboxAdjustmentDoc.set_attributes(cell, "text", 0);
			this.comboboxAdjustmentDoc.id_column = 1;
			(this.comboboxAdjustmentDoc.model as ListStore).append(out iter);
			(this.comboboxAdjustmentDoc.model as ListStore).set(iter, 
				0, SBText.__("-- document --"),
				1, "-1"
			);
			
			foreach(var row in rows)
			{
				(this.comboboxRefundDocument.model as ListStore).append(out iter);
				(this.comboboxRefundDocument.model as ListStore).set(iter, 
					0, "%s (%s)".printf(row.Get("transaction_name"), row.Get("transaction_key")),
					1, row.Get("transaction_type_id")
				);
				(this.comboboxAdjustmentDoc.model as ListStore).append(out iter);
				(this.comboboxAdjustmentDoc.model as ListStore).set(iter, 
					0, "%s (%s)".printf(row.Get("transaction_name"), row.Get("transaction_key")),
					1, row.Get("transaction_type_id")
				);
			}
			this.comboboxRefundDocument.active_id = "-1";
			this.comboboxAdjustmentDoc.active_id = "-1";
			//##call hooks
			var args = new SBModuleArgs<HashMap>();
			var data = new HashMap<string, Value?>();
			data.set("box_store", this.boxStore);
			data.set("store_id", this._store_id);
			args.SetData(data);
			SBModules.do_action("box_store", args);
		}
		protected void BuildCategories()
		{
			try
			{
				this.imageCategories.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("categories-icon-64x64.png");
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			
			this.treeviewCategories.model = new TreeStore(3,
										typeof(int),
										typeof(string), //category name 
										typeof(string) //category store
			);
			this.treeviewCategories.rules_hint = true;
			if( this.treeviewCategories.get_columns().length() <= 0 )
			{
				this.treeviewCategories.insert_column_with_attributes(0, "Id",
										new CellRendererText(){width = 70},
										"text", 0
				);
				this.treeviewCategories.insert_column_with_attributes(1, "Name",
											new CellRendererText(){width = 250},
											"text", 1
				);
				this.treeviewCategories.insert_column_with_attributes(2, "Store",
											new CellRendererText(){width = 200},
											"text", 2
				);
			}
			
			this.comboboxCategoriesStore.model = new ListStore(2, typeof(string), typeof(string));
			this.comboboxCategoriesStore.id_column = 1;
			
			if( (this.comboboxCategoriesStore.get_child() as CellView).get_cells().length() <= 0 )
			{
				var cell = new CellRendererText();
				this.comboboxCategoriesStore.pack_start(cell, false);
				this.comboboxCategoriesStore.set_attributes(cell, "text", 0);
			}
			
			this.comboboxCategoriesStore.show_all();
			
			this.comboboxParentCategory.model = new TreeStore(2, typeof(string), typeof(string));
			this.comboboxParentCategory.id_column = 1;
			
			if( (this.comboboxParentCategory.get_child() as CellView).get_cells().length() <= 0 )
			{
				var cell = new CellRendererText();
				this.comboboxParentCategory.pack_start(cell, false);
				this.comboboxParentCategory.set_attributes(cell, "text", 0);
			}
			
			this.comboboxParentCategory.show_all();
			
			this.comboboxCategoryStore.model = new ListStore(2, typeof(string), typeof(string));
			this.comboboxCategoryStore.id_column = 1;
			
			if( (this.comboboxCategoryStore.get_child() as CellView).get_cells().length() <= 0 )
			{
				var cell = new CellRendererText();
				this.comboboxCategoryStore.pack_start(cell, false);
				this.comboboxCategoryStore.set_attributes(cell, "text", 0);
			}
			
			this.comboboxCategoryStore.show_all();
			
			//stdout.printf("child => %s\n", this.comboboxCategoriesStore.get_child().name);
		}
		protected void BuildProducts()
		{
			try
			{
				this.imageProducts.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("products-icon-48x48.png");
			}
			catch(GLib.Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			TreeIter iter;
			
			var cell = new CellRendererText();
			this.comboboxProductSearchBy.model = new ListStore(2, typeof(string), typeof(string));
			this.comboboxProductSearchBy.pack_start(cell, false);
			this.comboboxProductSearchBy.set_attributes(cell, "text", 0);
			this.comboboxProductSearchBy.set_id_column(1);
			(this.comboboxProductSearchBy.model as ListStore).append(out iter);
			(this.comboboxProductSearchBy.model as ListStore).set(iter, 0, SBText.__("-- search --"), 1, "-1");
			(this.comboboxProductSearchBy.model as ListStore).append(out iter);
			(this.comboboxProductSearchBy.model as ListStore).set(iter, 0, SBText.__("Id"), 1, "id");
			(this.comboboxProductSearchBy.model as ListStore).append(out iter);
			(this.comboboxProductSearchBy.model as ListStore).set(iter, 0, SBText.__("Code"), 1, "code");
			(this.comboboxProductSearchBy.model as ListStore).append(out iter);
			(this.comboboxProductSearchBy.model as ListStore).set(iter, 0, SBText.__("Barcode"), 1, "barcode");
			(this.comboboxProductSearchBy.model as ListStore).append(out iter);
			(this.comboboxProductSearchBy.model as ListStore).set(iter, 0, SBText.__("Serial Number"), 1, "sn");
			(this.comboboxProductSearchBy.model as ListStore).append(out iter);
			(this.comboboxProductSearchBy.model as ListStore).set(iter, 0, SBText.__("Name"), 1, "name");
			this.comboboxProductSearchBy.active_id = "name";
			cell = new CellRendererText();
			this.comboboxStore.model = new ListStore(2, typeof(string), typeof(string));
			this.comboboxStore.set_id_column(1);
			this.comboboxStore.pack_start(cell, false);
			this.comboboxStore.set_attributes(cell, "text", 0);
			(this.comboboxStore.model as ListStore).append(out iter);
			(this.comboboxStore.model as ListStore).set(iter, 0, SBText.__("-- store --"), 1, "-1");
			
			var stores = (ArrayList<SBStore>)InventoryHelper.GetStores();
			foreach(var store in stores)
			{
				(this.comboboxStore.model as ListStore).append(out iter);
				(this.comboboxStore.model as ListStore).set(iter, 0, store.Name, 1, store.Id.to_string());
			}
			this.comboboxStore.active_id = "-1";
			
			cell = new CellRendererText();
			this.comboboxCategory.model = new TreeStore(2, typeof(string), typeof(string));
			this.comboboxCategory.pack_start(cell, false);
			this.comboboxCategory.set_attributes(cell, "text", 0);
			this.comboboxCategory.set_id_column(1);
			(this.comboboxCategory.model as TreeStore).append(out iter, null);
			(this.comboboxCategory.model as TreeStore).set(iter, 0, SBText.__("-- category --"), 1, "-1");
			
			this.treeviewProducts.model = new ListStore(ProductColumns.N_COLUMNS, 
														typeof(int), //count
														typeof(int), //product id
														typeof(Gdk.Pixbuf), //product image
														typeof(string), //product name
														typeof(string), //barcode
														typeof(int), //quantity
														typeof(string), //cost
														typeof(string) //price 
											);
			string [,] cols	= 
			{
				{SBText.__("#"), "text", "40", "center", ""},
				{SBText.__("ID"), "text", "70", "center", ""},
				{SBText.__("Image"), "pixbuf", "64", "center", ""},
				{SBText.__("Product"), "text", "250", "left", ""},
				{SBText.__("Barcode"), "text", "200", "left", ""},
				{SBText.__("Quantity"), "text", "80", "center", ""},
				{SBText.__("Cost"), "text", "100", "right", ""},
				{SBText.__("Price"), "text", "100", "right", ""},
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewProducts);
			/*							
			this.treeviewProducts.insert_column_with_attributes(ProductColumns.NAME, SBText.__("Product"), 
										new CellRendererText()
										{
											width = 250,
											wrap_mode = Pango.WrapMode.WORD_CHAR,
											wrap_width = 250
										},
										"text", 
										ProductColumns.NAME);
			*/
			
			var ops = new MenuToolButton.from_stock("gtk-select-color");
			ops.menu = new Gtk.Menu();
			ops.show_all();
			ops.menu.get_style_context().add_class("white-menu");
			this.buttonboxProducts.pack_end(ops, false, false);
			this.buttonboxProducts.set_child_packing(ops, false, false, 0, PackType.END);
			var print_catalog = new ImageMenuItem.with_label(SBText.__("Print Catalog"));
			print_catalog.always_show_image = true;
			print_catalog.show();
			try
			{
				var img = new Image();
				img.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("catalog-icon-24x24.png");
				print_catalog.set_image(img);
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			(ops.menu as Gtk.Menu).add(print_catalog);
			print_catalog.activate.connect(this.OnPrintCatalogActivated);
			//##add print labels
			var print_labels = new ImageMenuItem.with_label(SBText.__("Print Labels"));
			print_labels.show();
			try
			{
				var img = new Image();
				img.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("label-icon-24x24.png");//new Gdk.Pixbuf.from_stream(input_stream);
				print_labels.set_image(img);
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			(ops.menu as Gtk.Menu).add(print_labels);
			print_labels.activate.connect(this.OnPrintLabelsActivated);
			
			var args = new SBModuleArgs<ButtonBox>();
			args.SetData(this.buttonboxProducts);
			var args1 = new SBModuleArgs<MenuToolButton>();
			args1.SetData(ops);
			
			SBModules.do_action("product_buttonbox", args);
			SBModules.do_action("products_ops", args1);
			
		}
		protected void RefreshStores()
		{
			(this.treeviewStores.model as ListStore).clear();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM stores ORDER BY store_name ASC";
							
			TreeIter iter;
			foreach(var row in dbh.GetResults(query))
			{
				(this.treeviewStores.model as ListStore).append(out iter);
				(this.treeviewStores.model as ListStore).set(iter, 
										0, int.parse(row.Get("store_id")),
										1, row.Get("store_name")
				);
			}
		}
		protected void RefreshCategories(int store_id = 0)
		{
			(this.treeviewCategories.model as TreeStore).clear();
			(this.comboboxParentCategory.model as TreeStore).clear();
			if( store_id == 0)
				(this.comboboxCategoriesStore.model as ListStore).clear();
				
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			if( store_id == 0 )
			{
				//string query = "SELECT * FROM stores ORDER BY store_name ASC";
				dbh.Select("*").From("stores").OrderBy("store_name", "ASC");
				TreeIter s_iter;
				(this.comboboxCategoriesStore.model as ListStore).append(out s_iter);
				(this.comboboxCategoriesStore.model as ListStore).set(s_iter, 0, "-- store --", 1, "-1");
				foreach(var row in dbh.GetResults(null))
				{
					(this.comboboxCategoriesStore.model as ListStore).append(out s_iter);
					(this.comboboxCategoriesStore.model as ListStore).set(s_iter, 0, row.Get("store_name"), 1, row.Get("store_id"));
					/*
					(this.treeviewCategories.model as TreeStore).append(out s_iter);
					(this.treeviewCategories.model as TreeStore).set(s_iter, 0, row.Get(""));
					*/
				}
				this.comboboxCategoriesStore.active_id = "-1";
			}
			else if( store_id > 0 )
			{
				var store = new SBStore.from_id(store_id);
				var cats = (ArrayList<SBLCategory>)InventoryHelper.GetCategories(store_id);			
				TreeIter c_iter, p_iter;
											
				(this.comboboxParentCategory.model as TreeStore).append(out p_iter, null);
				(this.comboboxParentCategory.model as TreeStore).set(p_iter,
												0, SBText.__("-- parent --"),
												1, "-1"
				);
				this.comboboxParentCategory.active_id = "-1";
				if( cats.size > 0)
				{
					foreach(var cat in cats)
					{
						(this.treeviewCategories.model as TreeStore).append(out c_iter, null);
						(this.treeviewCategories.model as TreeStore).set(c_iter, 
												0, cat.Id,
												1, cat.Name,
												2, store.Name
						);
						(this.comboboxParentCategory.model as TreeStore).append(out p_iter, null);
						(this.comboboxParentCategory.model as TreeStore).set(p_iter,
														0, cat.Name,
														1, cat.Id.to_string()
						);
						if(cat.Childs.size > 0 )
						{
							TreeIter subiter, p_subiter;
							foreach(var subcat in cat.Childs)
							{
								(this.treeviewCategories.model as TreeStore).append(out subiter, c_iter);
								(this.treeviewCategories.model as TreeStore).set(subiter, 
														0, subcat.Id,
														1, subcat.Name,
														2, store.Name
								);
								
								(this.comboboxParentCategory.model as TreeStore).append(out p_subiter, p_iter);
								(this.comboboxParentCategory.model as TreeStore).set(p_subiter,
																0, subcat.Name,
																1, subcat.Id.to_string()
								);
							}
						}
					}
				}
				
			}
			//##fill category form
			TreeIter iter;
			//(this.comboboxParentCategory.model as ListStore).clear();
			(this.comboboxCategoryStore.model as ListStore).clear();
			/*
			string query = "SELECT * FROM categories WHERE parent = 0 ORDER BY name ASC";
			if( dbh.Query(query) > 0 )
			{
				(this.comboboxParentCategory.model as ListStore).append(out iter);
				(this.comboboxParentCategory.model as ListStore).set(iter, 0, "-- parent --", 1, "-1");
				foreach(var row in dbh.Rows)
				{
					(this.comboboxParentCategory.model as ListStore).append(out iter);
					(this.comboboxParentCategory.model as ListStore).set(iter, 0, row.Get("name"), 1, row.Get("category_id"));
				}
				this.comboboxParentCategory.active_id = "-1";
			}
			*/
			string query = "SELECT * FROM stores ORDER BY store_name ASC";
			var rows = dbh.GetResults(query);
			if( rows.size > 0 )
			{
				(this.comboboxCategoryStore.model as ListStore).append(out iter);
				(this.comboboxCategoryStore.model as ListStore).set(iter, 0, "-- store --", 1, "-1");
					
				foreach(var row in rows)
				{
					(this.comboboxCategoryStore.model as ListStore).append(out iter);
					(this.comboboxCategoryStore.model as ListStore).set(iter, 0, row.Get("store_name"), 1, row.Get("store_id"));
				}
				this.comboboxCategoryStore.active_id = "-1";
			}
			//query = "SELECT * FROM categories ORDER BY name ASC";
			
		}
		protected void RefreshProducts(int store_id = -1, int category_id = -1)
		{
			stdout.printf("RefreshProducts(%d, %d)\n", store_id, category_id);
			int rows_per_page = 100;
			long total_rows = 0;
			var products = new ArrayList<SBProduct>();
			if( category_id > 0 )
			{
				products = InventoryHelper.GetCategoryProducts(category_id, this.productsPage, rows_per_page, out total_rows);
			}
			else if( store_id > 0 )
				products = InventoryHelper.GetStoreProducts(store_id, this.productsPage, rows_per_page, out total_rows);
			else
				products = InventoryHelper.GetProducts(this.productsPage, rows_per_page, out total_rows);
			long total_pages = (long)Math.ceil(total_rows / rows_per_page);
			this.labelViewProducts.label = "%d".printf(this.productsPage);
			this.labelViewTotal.label = "%ld".printf(total_pages);
			//this.treeviewProducts.hide();
			(this.treeviewProducts.model as ListStore).clear();
			
			TreeIter iter;
			int row = 1;
			string images_path = SBFileHelper.SanitizePath("images/store_%d/".printf(store_id));
			
			foreach(var prod in products)
			{
				Gdk.Pixbuf pixbuf = null;
				try
				{	
					string? thumb = prod.GetThumbnail();
					string img_file = "%s%s".printf(images_path, (thumb != null) ? thumb : "fault.no.gif");
					
					if( FileUtils.test(img_file, FileTest.EXISTS) )
					{
						//stdout.printf("Product image: %s\n", img_file);
						//pixbuf = new Gdk.Pixbuf.from_file_at_scale("images/%s".printf(prod.ImageFiles.get(0)), 64, 64, false);
						pixbuf = new Gdk.Pixbuf.from_file(img_file);
						
						if( pixbuf.width > 64)
						{
							//stdout.printf("Resizing image\n");
							pixbuf = pixbuf.scale_simple(64, 64, Gdk.InterpType.BILINEAR);
						}
						
					}
					else
					{
						pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("placeholder-64x64.png");
						
					}
					
				}
				catch(Error e)
				{
					stderr.printf("ERROR: %s\n", e.message);
				}
				
				(this.treeviewProducts.model as ListStore).append(out iter);
				(this.treeviewProducts.model as ListStore).set(iter, 
										ProductColumns.COUNT, row,
										ProductColumns.ID, prod.Id,
										ProductColumns.PIXBUF, pixbuf,
										ProductColumns.NAME, prod.Name,
										ProductColumns.BARCODE, prod.Barcode,
										ProductColumns.QTY, prod.Quantity,
										ProductColumns.COST, "%.2lf".printf(prod.Cost),
										ProductColumns.PRICE, "%.2lf".printf(prod.Price)
				);
				
				//##Set cell colors
				//var col = (TreeViewColumn)this.treeviewProducts.get_column(ProductColumns.QTY);
				//var cell = (CellRendererText)col.get_cells().nth_data(row);
				//if( prod.Quantity > 0 )
				//{
				//	cell.foreground = "darkgreen";
					//cell.background = "green";
				//}
				//else
				//{
				//	//cell.foreground = "darkgreen";
				//	cell.foreground = "red";
				//}
				
				row++;
			}
			//this.treeviewProducts.show();
			this.labelTotalProducts.label = total_rows.to_string();
			//this.labelViewProducts.label = products.size.to_string();
			//this.labelViewTotal.label = total_rows.to_string();
		}
		protected void OnButtonAddStoreClicked()
		{
			this.entryStoreName.text = "";
			this.entryStoreAddress.text = "";
			this.entryStoreName.grab_focus();
			
		}
		protected void OnButtonEditStoreClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewStores.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			Value v_store_id;
			model.get_value(iter, 0, out v_store_id);
			dbh.Select("*").From("stores").Where("store_id = %d".printf((int)v_store_id));
			var row = dbh.GetRow(null);
			if( row == null )
				return;
			
			this._store_id = int.parse(row.Get("store_id"));
			this.entryStoreName.text = row.Get("store_name");
			this.entryStoreAddress.text	= row.Get("store_address");
			this.comboboxTax.active_id = row.Get("tax_id");
			this.comboboxSalesDocument.active_id = row.Get("sales_transaction_type_id");
			this.comboboxPurchaseDocument.active_id = row.Get("purchase_transaction_type_id");
			this.comboboxRefundDocument.active_id = row.Get("refund_transaction_type_id");
			this.comboboxAdjustmentDoc.active_id	= SBStore.SGetMeta(row.GetInt("store_id"), "adjustment_doc");
			var data1 = new HashMap<string, Value?>();
			data1.set("box_store", this.boxStore);
			data1.set("store_id", (int)v_store_id);
			var args = new SBModuleArgs<HashMap>();
			args.SetData(data1);
			SBModules.do_action("edit_store", args);
		}
		protected void OnButtonDeleteStoreClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewStores.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			
			var msg = new MessageDialog(null, DialogFlags.MODAL, MessageType.QUESTION, ButtonsType.YES_NO, 
						SBText.__("Are you sure to delete store?\n All products and categories will be deleted as well.")
			);
			msg.title = SBText.__("Confirm store deletion.");
			if( msg.run() == ResponseType.NO )
			{
				msg.destroy();
				return;
			}
			msg.destroy();
			Value v_store_id;
			model.get_value(iter, 0, out v_store_id);
			
			InventoryHelper.DeleteStore((int)v_store_id);
			this.RefreshStores();
		}
		protected void OnButtonSaveStoreClicked()
		{
			string store_name 		= this.entryStoreName.text.strip();
			string store_address	= this.entryStoreAddress.text.strip();
			
			if( store_name.length <= 0)
			{
				this.entryStoreName.grab_focus();
				var box = (Box)this.ui.get_object("box3");
				var msg = new InfoBar(){message_type = MessageType.ERROR};
				var close_btn = new Button.with_label(SBText.__("Close"));
				close_btn.show();
				close_btn.clicked.connect( () => 
				{
					msg.destroy();
				});
				var label = new Label(SBText.__("Please enter a valid store name."));
				label.show();
				msg.show();
				(msg.get_action_area() as Box).pack_start(close_btn, false, false);
				(msg.get_content_area() as Box).pack_start(label, false, false);
				box.add(msg);
		
				return;
			}
			if( store_address.length <= 0)
			{
				var box = (Box)this.ui.get_object("box3");
				var msg = new InfoBar(){message_type = MessageType.ERROR};
				var close_btn = new Button.with_label(SBText.__("Close"));
				close_btn.show();
				close_btn.clicked.connect( () => 
				{
					msg.destroy();
				});
				var label = new Label(SBText.__("Please enter a valid store address."));
				label.show();
				msg.show();
				(msg.get_action_area() as Box).pack_start(close_btn, false, false);
				(msg.get_content_area() as Box).pack_start(label, false, false);
				box.add(msg);
				this.entryStoreAddress.grab_focus();
				return;
			}
			int tax_id = 0;
			if( this.comboboxTax.active_id != null )
			{
				tax_id = int.parse(this.comboboxTax.active_id);
			}
			string store_key = "";
			var	regex = /\s+/i;
			try
			{
				store_key	= regex.replace(store_name.down(), store_name.length, 0, "-");
			}
			catch(GLib.Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			//string store_type = "local";
			var date = new DateTime.now_local(); 
			string cdate = date.format("%Y-%m-%d %H:%M:%S");
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			HashMap<string, Value?> data =  new HashMap<string, Value?>();
			data.set("store_name", store_name);
			data.set("store_address", store_address);
			data.set("store_key", store_key);
			data.set("store_description", "");
			data.set("sales_transaction_type_id", int.parse(this.comboboxSalesDocument.active_id));
			data.set("purchase_transaction_type_id", int.parse(this.comboboxPurchaseDocument.active_id));
			data.set("refund_transaction_type_id", int.parse(this.comboboxRefundDocument.active_id));
			data.set("tax_id", tax_id);
			data.set("last_modification_date", cdate);
			
			if( this._store_id <= 0 )
			{
				data.set("creation_date", cdate);
				this._store_id = (int)dbh.Insert("stores", data);
				var msg = new InfoDialog()
				{ 
					Title 	= SBText.__("Store created"),
					Message = SBText.__("The store has been created")
				};
				
				msg.run();
				msg.dispose();
			}
			else
			{
				HashMap<string, Value?> w = new HashMap<string, Value?>();
				w.set("store_id", this._store_id);
				dbh.Update("stores", data, w);
				var msg = new InfoDialog()
				{
					Title = SBText.__("Store updated"),
					Message = SBText.__("The store has been updated")
				};
				
				msg.run();
				msg.dispose();
			}
			SBStore.SUpdateMeta(this._store_id, "adjustment_doc", this.comboboxAdjustmentDoc.active_id);
			var data1 = new HashMap<string, Value?>();
			data1.set("box_store", this.boxStore);
			data1.set("store_id", this._store_id);
			var args = new SBModuleArgs<HashMap>();
			args.SetData(data1);
			SBModules.do_action("save_store", args);
			
			this.entryStoreName.text = "";
			this.entryStoreAddress.text = "";
			this._store_id = 0;
			this.RefreshStores();
		}
		protected void OnButtonCancelStoreClicked()
		{
		}
		protected void OnButtonNewCategoryClicked()
		{
			this.entryCategoryName.text 					= "";
			this.textviewCategoryDescription.buffer.text	= "";
			this.comboboxParentCategory.active_id 			= "-1";
			this.comboboxCategoryStore.active_id 			= "-1";
			
			this._category_id = 0;
			this.entryCategoryName.grab_focus();
			
		}
		protected void OnButtonEditCategoryClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewCategories.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			Value v_category_id;
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			model.get_value(iter, 0, out v_category_id);
			string query = "SELECT * FROM categories WHERE category_id = %d".printf((int)v_category_id);
			var row = dbh.GetRow(query);
			if( row == null )
				return;
			
			this.entryCategoryName.text = row.Get("name");
			string parent_id = row.Get("parent");
			string store_id		= row.Get("store_id");
			this.comboboxParentCategory.active_id = (parent_id != "0") ? parent_id : "-1";
			this.comboboxCategoryStore.active_id = (store_id != "0") ? store_id : "-1";
			this.entryCategoryName.grab_focus();
			
			this._category_id = (int)v_category_id;
		}
		protected void OnButtonDeleteCategoryClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewCategories.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			var msg_confirm = new InfoDialog()
			{
				Title = SBText.__("Delete category"),
				Message = SBText.__("Are you sure to delete the category?")
			};
			var btn = msg_confirm.add_button(SBText.__("Yes"), ResponseType.YES);
			btn.get_style_context().add_class("button-green");
			if( msg_confirm.run() != Gtk.ResponseType.YES)
			{
				msg_confirm.destroy();
				return;
			}
			msg_confirm.destroy();
			
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			Value v_category_id;
			model.get_value(iter, 0, out v_category_id);
			string query = "DELETE FROM categories WHERE category_id = %d".printf((int)v_category_id); 
			dbh.Execute(query);
			var msg = new InfoDialog()
			{
				Title = SBText.__("Category deleted"),
				Message = SBText.__("The category has been deleted")
			};
			msg.run();
			msg.destroy();
			this.RefreshCategories();
		}
		protected void OnComboBoxCategoriesStoreChanged()
		{
			TreeIter iter;
			if( !this.comboboxCategoriesStore.model.get_iter_first(out iter) )
				return;
			
			if( this.comboboxCategoriesStore.active_id == null || this.comboboxCategoriesStore.active_id == "-1" )
				return;
			
			int store_id = int.parse(this.comboboxCategoriesStore.active_id);
			this.RefreshCategories(store_id);
		}
		protected void OnButtonSaveCategoryClicked()
		{
			string category_name = this.entryCategoryName.text.strip();
			string description		= this.textviewCategoryDescription.buffer.text.strip();
			string parent_id		= (this.comboboxParentCategory.active_id == "-1") ? "0" : this.comboboxParentCategory.active_id;
			string store_id			= (this.comboboxCategoryStore.active_id == "-1") ? "0" : this.comboboxCategoryStore.active_id;
			//int extern_id = 0;
			
			if( category_name.length <= 0 )
			{
				this.entryCategoryName.grab_focus();
				return;
			}
			if( store_id == "0" )
			{
				this.comboboxCategoryStore.grab_focus();
				return;
			}
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var date = new DateTime.now_local();
			HashMap<string, Value?> data = new HashMap<string, Value?>();
			data.set("name", category_name);
			data.set("description", description);
			data.set("parent", int.parse(parent_id));
			data.set("store_id", int.parse(store_id));
			data.set("extern_id", "NULL");
			if( this._category_id == 0 )
			{
				data.set("creation_date", date.format("%Y-%m-%d %H:%M:%S"));
				dbh.Insert("categories", data);
				var msg = new MessageDialog(null, DialogFlags.MODAL, MessageType.INFO, ButtonsType.OK, 
													SBText.__("The category has been created"));
				msg.title = SBText.__("Category created");
				msg.run();
				msg.dispose();
			
			}
			else
			{
				HashMap<string, Value?> w = new HashMap<string, Value?>();
				w.set("category_id", this._category_id);
				dbh.Update("categories", data, w);
				var msg = new MessageDialog(null, DialogFlags.MODAL, MessageType.INFO, ButtonsType.OK, 
													"The category has been updated");
				msg.title = "Category updated";
				msg.run();
				msg.dispose();
				this._category_id = 0;
			}
						
			this.RefreshCategories(int.parse(store_id));
		}
		protected void OnButtonNewProductClicked()
		{
			var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
			if( notebook.GetPage("new-product") == null )
			{
				var w = new WidgetNewProduct();
				w.show();
				notebook.AddPage("new-product", SBText.__("New Product"), w);
			}
			notebook.SetCurrentPageById("new-product");
		}
		protected void OnButtonEditProductClicked()
		{
			TreeModel model;
			TreeIter iter;
			if( !this.treeviewProducts.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			Value v_pid;
			this.treeviewProducts.model.get_value(iter, ProductColumns.ID, out v_pid);
			var prod = new EProduct.from_id((int)v_pid);
			var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
			if( notebook.GetPage("edit-product") == null )
			{
				var w = new WidgetNewProduct.with_product(prod);
				w.show();
				notebook.AddPage("edit-product", "Edit Product", w);
			}
			notebook.SetCurrentPageById("edit-product");
		}
		protected void OnComboboxStoreChanged()
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1" )
			{
				(this.treeviewProducts.model as ListStore).clear();
				return;
			}
			int store_id = int.parse(this.comboboxStore.active_id);
			this.lockCategoryEvent = true;
			var categories = (ArrayList<SBLCategory>)InventoryHelper.GetCategories(store_id);
			(this.comboboxCategory.model as TreeStore).clear();
			TreeIter iter;
			(this.comboboxCategory.model as TreeStore).append(out iter, null);
			(this.comboboxCategory.model as TreeStore).set(iter, 0, SBText.__("-- category --"), 1, "-1");
				
			foreach(SBLCategory cat in categories)
			{
				//TreeIter iter;
				(this.comboboxCategory.model as TreeStore).append(out iter, null);
				(this.comboboxCategory.model as TreeStore).set(iter, 0, cat.Name, 1, cat.Id.to_string());
			}
			this.comboboxCategory.active_id = "-1";
			this.RefreshProducts(store_id);
			this.lockCategoryEvent = false;
		}
		protected void OnComboboxCategoryChanged()
		{
			if( this.lockCategoryEvent )
				return;
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1" )
			{
				return;
			}
			if( this.comboboxCategory.active_id == null)
			{
				return;
			}
			int store_id = int.parse(this.comboboxStore.active_id);
			if(  this.comboboxCategory.active_id == "-1"  )
			{
				this.RefreshProducts(store_id);
				return;
			}
			
			int category_id = int.parse(this.comboboxCategory.active_id);
			this.RefreshProducts(store_id, category_id);
		}
		protected void OnButtonRefreshProductsClicked()
		{
			int store_id = (this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1") ? -1 : int.parse(this.comboboxStore.active_id);
			int cat_id = (this.comboboxCategory.active_id == null || this.comboboxCategory.active_id == "-1") ? -1 : int.parse(this.comboboxCategory.active_id);
			this.RefreshProducts(store_id, cat_id);
			
		}
		protected void OnPrintCatalogActivated()
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1" )
			{
				return;
			}
			if( this.comboboxCategory.active_id == null )
			{
				return;
			}
			int store_id	= int.parse(this.comboboxStore.active_id);
			int cat_id		= int.parse(this.comboboxCategory.active_id);
			
			var cats = new ArrayList<SBLCategory>();
			if( cat_id > 0 )
			{
				long total_prods = 0;
				cats.add(new SBLCategory.from_id(cat_id));
				//var prods = InventoryHelper.GetCategoryProducts(cat_id, 1, -1, out total_prods);
			}
			else
			{
				cats = InventoryHelper.GetCategories(store_id);
			}
			/*
			var catalog = new Catalog();
			catalog.WriteText(SBText.__("Products Catalog"), "center", 24);
			catalog.WriteText(SBText.__("Date: %s").printf(new DateTime.now_local().format("%Y-%m-%d")), "left", 12);
			catalog.SetColumnsWidth({10, 20, 50, 20});
			catalog.SetTableHeaders({SBText.__("No."), SBText.__("Code"), SBText.__("Name"), SBText.__("Price")});
			
			int ci = 1;
			foreach(var cat in cats)
			{
				catalog.AddCell("%d. %s".printf(ci, cat.Name), "left", 12, true, 4);
				
				int pc = 1;
				long total_prods = 0;
				var prods = (ArrayList<SBProduct>)InventoryHelper.GetCategoryProducts(cat.Id, 1, -1, out total_prods);
				
				foreach(var prod in prods)
				{
					catalog.AddCell(pc.to_string(), "center");
					catalog.AddCell(prod.Id.to_string(), "center");
					catalog.AddCell(prod.Name);
					catalog.AddCell("%.2f".printf(prod.Price));
					pc++;
				}
				
				ci++;
			}
			catalog.Draw();
			catalog.Preview();
			//var img = HPDF.LoadJpegImageFromFile(pdf, "/home/marcelo/Pictures/cd_1_angle-90x90.jpg");
			//page.DrawImage(img, margin, height - 98, img.GetWidth(), img.GetHeight());
			*/
		}
		protected void OnPrintLabelsActivated()
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1" )
			{
				return;
			}
			if( this.comboboxCategory.active_id == null )
			{
				return;
			}
			int store_id	= int.parse(this.comboboxStore.active_id);
			int cat_id		= int.parse(this.comboboxCategory.active_id);
			
			var cats = new ArrayList<SBLCategory>();
			if( cat_id > 0 )
			{
				cats.add(new SBLCategory.from_id(cat_id));
			}
			else
			{
				cats = InventoryHelper.GetCategories(store_id);
			}
			/*
			var catalog = new Catalog();
			catalog.WriteText(SBText.__("Products Labels"), "center", 24);
			//catalog.WriteText(SBText.__("Products Labels"), "center", 24);
			//catalog.WriteText(SBText.__("Products Labels"), "center", 24);
			catalog.SetColumnsWidth({20, 20, 20, 20, 20});
						
			foreach(var cat in cats)
			{
				catalog.AddCell(cat.Name, "left", 12, !false, 5);
				
				long total_prods = 0;
				var prods = (ArrayList<SBProduct>)InventoryHelper.GetCategoryProducts(cat.Id, 1, -1, out total_prods);
				foreach(var prod in prods)
				{
					string label_text = "%s $%.2f".printf(prod.Name, prod.Price);
					catalog.AddCell(label_text, "center");
				}
				
			}
			catalog.Draw();
			catalog.Preview("labels");
			*/
		}
	}
}
