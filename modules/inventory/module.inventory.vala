using GLib;
using Gtk;
using Gee;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class SB_ModuleInventory : SBGtkModule, ISBModule
	{
		public string Id{get{return this._moduleId;}}
		public string Name{get{return this._name;}}
		public string Description{get{return this._description;}}
		public string Author{get{return this._author;}}
		public double Version{get{return this._version;}}
		public string LibraryName{get{return "Inventory";}}
		public string	Dependencies{get{return "";}}
		construct
		{
			this._moduleId 		= "mod_inventory";
			this._name			= "Inventory Module";
			this._description 	= "";
			this._author 		= "Sintic Bolivia";
			this._version 		= 1.0;
			
			this.resourceNs		= "/net/sinticbolivia/Inventory";
			this.resourceFile 	= "./modules/inventory.gresource";
		}
		protected void ApplyPatches()
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			if( dbh.Engine == "mysql" )
			{
				string o_query = "SHOW columns FROM purchase_orders WHERE Field = 'r_subtotal'";
				if( dbh.GetRow(o_query) ==  null )
				{
					dbh.Execute("ALTER TABLE purchase_orders ADD COLUMN r_subtotal DECIMAL(10,2) AFTER total");
					dbh.Execute("ALTER TABLE purchase_orders ADD COLUMN r_total_tax DECIMAL(10,2) AFTER r_subtotal");
					dbh.Execute("ALTER TABLE purchase_orders ADD COLUMN r_discount DECIMAL(10,2) AFTER r_total_tax");
					dbh.Execute("ALTER TABLE purchase_orders ADD COLUMN r_total DECIMAL(10,2) AFTER r_discount");
					
					dbh.Execute("ALTER TABLE purchase_order_items ADD COLUMN r_subtotal DECIMAL(10,2) AFTER total");
					dbh.Execute("ALTER TABLE purchase_order_items ADD COLUMN r_total_tax DECIMAL(10,2) AFTER r_subtotal");
					dbh.Execute("ALTER TABLE purchase_order_items ADD COLUMN r_total DECIMAL(10,2) AFTER r_total_tax");
				}
				string query = "SHOW columns FROM purchase_order_items WHERE Field = 'status'";
				if( dbh.GetRow(query) == null )
				{
					dbh.Execute("ALTER TABLE purchase_order_items ADD COLUMN status VARCHAR(128) AFTER total");
					dbh.Execute("ALTER TABLE purchase_order_items ADD COLUMN quantity_received INT DEFAULT 0 AFTER quantity");
				}
			}
			else if( dbh.Engine == "sqlite" || dbh.Engine == "sqlite3" )
			{
			}
		}
		public void Enabled()
		{
			this.LoadResources();
			
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string sql_file = "";
			
			if(dbh.Engine == "sqlite" || dbh.Engine == "sqlite3") 
			{
				sql_file = "sql/inventory.sqlite3.sql";
			}
			else if( dbh.Engine == "mysql" )
			{
				sql_file = "sql/inventory.mysql.sql";
			}
			
			var istream = (InputStream)this.GetInputStream(sql_file);
			
			var ds = new DataInputStream(istream);
			string sql = "";
			string? line = "";
			try
			{
				while( (line = ds.read_line()) != null )
				{
					sql += line;
				}
			}
			catch(GLib.IOError e)
			{
			}
			//stdout.printf("SQL: %s\n", sql);
			foreach(string q in sql.split(";"))
			{
				if(q.strip().length <= 0) continue;
				dbh.Execute(q);
			}
			//##add necessary permissions
			string[,] perms = 
			{
				{"manage_products", "", SBText.__("Manage Products")},
				{"create_products", "", SBText.__("Create Products")},
				{"edit_products", "", SBText.__("Edit Products")},
				{"delete_products", "", SBText.__("Delete Products")},
				{"manage_categories", "", SBText.__("Manage Categories")},
				{"create_categories", "", SBText.__("Create Categories")},
				{"edit_categories", "", SBText.__("Edit Categories")},
				{"delete_categories", "", SBText.__("Delete Categories")},
				{"manage_suppliers", "", SBText.__("Manage Suppliers")},
				{"create_suppliers", "", SBText.__("Create Suppliers")},
				{"edit_suppliers", "", SBText.__("Edit Suppliers")},
				{"delete_suppliers", "", SBText.__("Delete Suppliers")},
				{"manage_departments", "", SBText.__("Manage Departments")},
				{"create_departments", "", SBText.__("Create Departments")},
				{"edit_departments", "", SBText.__("Edit Departments")},
				{"delete_departments", "", SBText.__("Delete Departments")},
				{"manage_stores", "", SBText.__("Manage Stores")},
				{"create_stores", "", SBText.__("Create Stores")},
				{"edit_stores", "", SBText.__("Edit Stores")},
				{"delete_stores", "", SBText.__("Delete Stores")},
				//##purchase permissions
				{"manage_purchase_orders", "", SBText.__("Manage Purchase Orders")},
				{"create_purchase_orders", "", SBText.__("Create Purchase Orders")},
				{"edit_purchase_orders", "", SBText.__("Edit Purchase Orders")},
				{"receive_purchase_orders", "", SBText.__("Receive Purchase Orders")},
				{"return_purchase_orders", "", SBText.__("Return Purchase Orders")},
				{"cancel_purchase_orders", "", SBText.__("Cancel Purchase Orders")}
			};
			
			dbh.BeginTransaction();
			for(int i = 0; i < perms.length[0]; i++)
			{
				dbh.Select("permission_id").From("permissions").Where("permission = '%s'".printf(perms[i,0]));
				if( dbh.GetRow(null) == null )
				{
					var p = new HashMap<string, Value?>();
					p.set("permission", perms[i,0]);
					p.set("label", perms[i,2]);
					dbh.Insert("permissions", p);
				}
			}
			this.ApplyPatches();
			dbh.EndTransaction();
		}		
		public void Disabled()
		{
		}
		public void Load()
		{
			/*
			string modules_path = "modules";
			string component_prefix = "lib%s".printf(this.LibraryName);
			try
			{
				var dir = File.new_for_path(modules_path);
				var enumerator = dir.enumerate_children(FileAttribute.STANDARD_NAME, 0);
				FileInfo file_info;
				while( (file_info = enumerator.next_file ()) != null ) 
				{
					if( file_info.get_name().index_of(component_prefix) != 1 )
					{
						stdout.printf ("Loading component: %s\n", file_info.get_name ());
						
					}
				}
			}
			catch(GLib.Error e)
			{
				stderr.printf ("Error: %s\n", e.message);
			}
			*/
		}
		public void Init()
		{
			this.LoadResources();
			
			SBModuleHook hook = new SBModuleHook();
			hook.HookName = "init_sidebar";
			hook.handler = (ActionHandler)SB_ModuleInventory.sidebar_init;
			
			var hook1 = new SBModuleHook();
			hook1.HookName = "init_menu_management";
			hook1.handler	= (ActionHandler)SB_ModuleInventory.init_menu_management;
			
			var hook2 = new SBModuleHook();
			hook2.HookName = "reports_menu";
			hook2.handler	= (ActionHandler)SB_ModuleInventory.hook_reports_menu;
			
			var hook3 = new SBModuleHook();
			hook3.HookName = "user_fields";
			hook3.handler	= (ActionHandler)SB_ModuleInventory.hook_user_fields;
			
			var hook4 = new SBModuleHook();
			hook4.HookName = "user_saved";
			hook4.handler	= (ActionHandler)SB_ModuleInventory.hook_user_saved;
			
			var hook5 = new SBModuleHook();
			hook5.HookName = "user_saved";
			hook5.handler	= (ActionHandler)SB_ModuleInventory.hook_set_user_data;
			
			SBModules.add_action("init_sidebar", ref hook);
			SBModules.add_action("init_menu_management", ref hook1);
			SBModules.add_action("reports_menu", ref hook2);
			SBModules.add_action("user_fields", ref hook3);
			SBModules.add_action("user_saved", ref hook4);
			SBModules.add_action("set_user_data", ref hook5);
			
		}
		public void Unload()
		{
			stdout.printf("Module Inventory unloaded\n");
		}
		
		//[CCode (has_target = false, has_type_id = false)]
		public static void sidebar_init(SBModuleArgs<HashMap> harg)
		{
			var data		= (HashMap<string,Widget>)harg.GetData();
			var quick_icons = (Box)data.get("quickicons");
			var notebook	= (SBNotebook)SBGlobals.GetVar("notebook");
			var btnProducts = new Button();
			btnProducts.tooltip_text = SBText.__("Products");
			//btnProducts.image = File.new_from_uri("resource:///net/sinticbolivia/Inventory/products-icon-48x48.png");
			try
			{
				btnProducts.image = new Image();
				(btnProducts.image as Image).pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("products-icon-48x48.png");
				btnProducts.show();
				btnProducts.clicked.connect( () => 
				{
					if( notebook.GetPage("inventory") == null )
					{
						var inv = new EPos.WidgetInventory();
						inv.show();
						notebook.AddPage("inventory", "Inventory", inv);
					}
					notebook.SetCurrentPageById("inventory");
					
				});
				quick_icons.add(btnProducts);		
			}
			catch(GLib.Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
		}
		public static void init_menu_management(SBModuleArgs<Gtk.Menu> args)
		{
			var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
			var menu = (Gtk.Menu)args.GetData();
			
			var menuitem_inventory = new Gtk.ImageMenuItem.with_label(SBText.__("Inventory"));
			menuitem_inventory.image = new Image.from_pixbuf((SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("inventory-25x25.png"));
			menuitem_inventory.submenu = new Gtk.Menu();
			menuitem_inventory.show();
			menu.add(menuitem_inventory);
			
			var menuitem_transactions = new Gtk.MenuItem.with_label(SBText.__("Transactions"));
			menuitem_transactions.show();
			menuitem_inventory.submenu.add(menuitem_transactions);
			menuitem_transactions.activate.connect( () => 
			{
				if( notebook.GetPage("transactions") == null )
				{
					var widget = new WidgetTransactions();
					widget.show();
					notebook.AddPage("transactions", SBText.__("Transactions"), widget);
				}
				notebook.SetCurrentPageById("transactions");
			});
			var menuitem_tt = new Gtk.MenuItem.with_label(SBText.__("Transaction Types"));
			menuitem_tt.show();
			menuitem_inventory.submenu.add(menuitem_tt);
			menuitem_tt.activate.connect( () => 
			{
				if( notebook.GetPage("transaction-types") == null )
				{
					var widget = new WidgetTransactionTypes();
					widget.show();
					notebook.AddPage("transaction-types", SBText.__("Transaction Types"), widget);
				}
				notebook.SetCurrentPageById("transaction-types");
			});
			
			var menuitem_purchase_order = new Gtk.MenuItem.with_label(SBText.__("Purchase Orders"));
			menuitem_purchase_order.show();
			menuitem_purchase_order.activate.connect( () => 
			{
				if( notebook.GetPage("purchase_orders") == null )
				{
					var w = new WidgetPurchaseOrders();
					w.show();
					notebook.AddPage("purchase_orders", SBText.__("Purchase Orders"), w);
				}
				notebook.SetCurrentPageById("purchase_orders");
			});
			menuitem_inventory.submenu.add(menuitem_purchase_order);
			
			var mi_transfer = new Gtk.MenuItem.with_label(SBText.__("Stock Transfers"));
			mi_transfer.show();
			mi_transfer.activate.connect( () => 
			{
				if( notebook.GetPage("stock_transfers") == null )
				{
					var w = new EPos.WidgetStockTransfers();
					w.show();
					notebook.AddPage("stock_transfers", SBText.__("Stock Transfers"), w);
				}
				notebook.SetCurrentPageById("stock_transfers");
			});
			menuitem_inventory.submenu.add(mi_transfer);
			
			var menuitem_supcats = new Gtk.MenuItem.with_label(SBText.__("Supplier Categories"));
			menuitem_supcats.show();
			menuitem_supcats.activate.connect( () => 
			{
				if( notebook.GetPage("supplier-categories") == null )
				{
					var w = new WidgetSupplierCategories();
					w.show();
					notebook.AddPage("supplier-categories", SBText.__("Supplier Categories"), w);
				}
				notebook.SetCurrentPageById("supplier-categories");
			});
			menuitem_inventory.submenu.add(menuitem_supcats);
			
			var menuitem_suppliers = new Gtk.MenuItem.with_label(SBText.__("Suppliers"));
			menuitem_suppliers.show();
			menuitem_suppliers.activate.connect( () => 
			{
				if( notebook.GetPage("suppliers") == null )
				{
					var w = new WidgetSuppliers();
					w.show();
					notebook.AddPage("suppliers", SBText.__("Suppliers"), w);
				}
				notebook.SetCurrentPageById("suppliers");
			});
			menuitem_inventory.submenu.add(menuitem_suppliers);
			
			var menuitem_products = new Gtk.MenuItem.with_label(SBText.__("Products"));
			menuitem_products.show();
			menuitem_products.activate.connect( () => 
			{
				if( notebook.GetPage("inventory") == null )
				{
					var inv = new WidgetInventory();
					inv.show();
					notebook.AddPage("inventory", "Inventory", inv);
				}
				notebook.SetCurrentPageById("inventory");
			});
			menuitem_inventory.submenu.add(menuitem_products);
			
			var mi_measurement = new Gtk.MenuItem.with_label(SBText.__("Unit of Measurement"));
			mi_measurement.show();
			mi_measurement.activate.connect( () => 
			{
				if( notebook.GetPage("unit-measurement") == null )
				{
					var w = new WidgetUnitOfMeasurement();
					w.show();
					notebook.AddPage("unit-measurement", SBText.__("Unit of Measurement"), w);
				}
				notebook.SetCurrentPageById("unit-measurement");
			});
			menuitem_inventory.submenu.add(mi_measurement);
			//##add currencies menu
			var mi_currencies = new Gtk.MenuItem.with_label(SBText.__("Currencies"));
			mi_currencies.show();
			mi_currencies.activate.connect( () => 
			{
				if( notebook.GetPage("currencies") == null )
				{
					var w = new WidgetCurrencies();
					w.show();
					notebook.AddPage("currencies", SBText.__("Currencies"), w);
				}
				notebook.SetCurrentPageById("currencies");
			});
			menuitem_inventory.submenu.add(mi_currencies);
			
			var mi_lines = new Gtk.MenuItem.with_label(SBText.__("Lines"));
			mi_lines.show();
			mi_lines.activate.connect( () => 
			{
				if( notebook.GetPage("product-lines") == null )
				{
					var w = new WidgetProductLines();
					w.show();
					notebook.AddPage("product-lines", SBText.__("Product Lines"), w);
				}
				notebook.SetCurrentPageById("product-lines");
			});
			menuitem_inventory.submenu.add(mi_lines);
			
			var mi_deps = new Gtk.MenuItem.with_label(SBText.__("Departments"));
			mi_deps.show();
			mi_deps.activate.connect( () => 
			{
				if( notebook.GetPage("product-deps") == null )
				{
					var w = new WidgetProductDepartments();
					w.show();
					notebook.AddPage("product-deps", SBText.__("Product Departments"), w);
				}
				notebook.SetCurrentPageById("product-deps");
			});
			menuitem_inventory.submenu.add(mi_deps);
			
			var mi_itypes = new Gtk.MenuItem.with_label(SBText.__("Item Types"));
			mi_itypes.show();
			mi_itypes.activate.connect( () => 
			{
				if( notebook.GetPage("item-types") == null )
				{
					var w = new EPos.WidgetItemTypes();
					w.show();
					notebook.AddPage("item-types", SBText.__("Item Types"), w);
				}
				notebook.SetCurrentPageById("item-types");
			});
			menuitem_inventory.submenu.add(mi_itypes);
			
			var mi_assemblies = new Gtk.MenuItem.with_label(SBText.__("Assemblies"));
			mi_assemblies.show();
			mi_assemblies.activate.connect( () => 
			{
				if( notebook.GetPage("assemblies") == null )
				{
					var w = new EPos.WidgetAssemblies();
					w.show();
					notebook.AddPage("assemblies", SBText.__("Assemblies"), w);
				}
				notebook.SetCurrentPageById("assemblies");
			});
			menuitem_inventory.submenu.add(mi_assemblies);
			
			var mi_adjust = new Gtk.MenuItem.with_label(SBText.__("Adjustments"));
			mi_adjust.show();
			mi_adjust.activate.connect( () => 
			{
				if( notebook.GetPage("adjustments") == null )
				{
					var w = new WidgetAdjustments();
					w.show();
					notebook.AddPage("adjustments", SBText.__("Adjustments"), w);
				}
				notebook.SetCurrentPageById("adjustments");
			});
			menuitem_inventory.submenu.add(mi_adjust);
			//##call hooks
			var args1 = new SBModuleArgs<Gtk.MenuItem>();
			args1.SetData(menuitem_inventory);
			SBModules.do_action("menu_item_inventory", args1);
		}
		public static void hook_reports_menu(SBModuleArgs<Gtk.Menu> args)
		{
			var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
			Gtk.MenuItem menu_reports = (Gtk.MenuItem)args.GetData();
			var menuitem_inventory_report = new Gtk.MenuItem.with_label(SBText.__("Inventory Report"));
			menuitem_inventory_report.show();
			menu_reports.submenu.add(menuitem_inventory_report);
			menuitem_inventory_report.activate.connect(() => 
			{
				if( notebook.GetPage("inventory-report") == null )
				{
					var widget = new WidgetInventoryReport();
					widget.show();
					notebook.AddPage("inventory-report", SBText.__("Iventory Report"), widget);
					notebook.SetCurrentPageById("inventory-report");
				}
			});
		}
		public static void hook_user_fields(SBModuleArgs<int> args)
		{
			Grid grid_fields = (Grid)args.GetData();
			var label_store = new Label(SBText.__("Store:")){xalign = 0};
			label_store.show();
			var comboboxStores = new ComboBox(){name = "combobox_stores"};
			comboboxStores.show();
			comboboxStores.model = new ListStore(2, typeof(string), typeof(string));
			comboboxStores.id_column = 1;
			var cell = new CellRendererText();
			comboboxStores.pack_start(cell, true);
			comboboxStores.set_attributes(cell, "text", 0);
			
			//##fill stores
			TreeIter iter;
			(comboboxStores.model as ListStore).append(out iter);
			(comboboxStores.model as ListStore).set(iter, 
				0, SBText.__("-- store --"),
				1, "-1"
			);
			var stores = InventoryHelper.GetStores();
			
			foreach(SBStore store in stores)
			{
				(comboboxStores.model as ListStore).append(out iter);
				(comboboxStores.model as ListStore).set(iter, 
					0, store.Name,
					1, store.Id.to_string()
				);
			}
			comboboxStores.active_id = "-1";
			/*
			stdout.printf("base_line_row: %d\n", grid_fields. get_baseline_row ());
			//grid_fields.foreach( (w) => 
			grid_fields.forall_internal(true,  (w) => 
			{
				stdout.printf("child: %s\n", w.name);
			});
			*/
			grid_fields.attach(label_store, 0, 4, 1, 1);
			grid_fields.attach(comboboxStores, 1, 4, 1, 1);
		}
		public static void hook_user_saved(SBModuleArgs<HashMap> args)
		{
			var data = (HashMap<string, Value?>)args.GetData();
			var grid_fields = (Grid)data["grid_fields"];
			int user_id		= (int)data["user_id"];
			grid_fields.foreach((w) => 
			{
				if( w.name == "combobox_stores" )
				{
					if( (w as ComboBox).active_id != null )
					{
						int store_id = int.parse((w as ComboBox).active_id);
						SBMeta.UpdateMeta("user_meta", "store_id", store_id.to_string(), "user_id", user_id);
					}
					
				}
			});
		}
		public static void hook_set_user_data(SBModuleArgs<HashMap> args)
		{
			var data = (HashMap<string, Value?>)args.GetData();
			int user_id 		= (int)data["user_id"];
			string store_id		= SBUser.SGetMeta(user_id, "store_id");
			Grid grid_fields 	= (Grid)data["grid_fields"];
			grid_fields.foreach( (w) => 
			{
				if( w.name == "combobox_stores" )
				{
					(w as ComboBox).active_id = store_id;
				}
			});
		}
	}
}
public Type sb_get_module_libinventory_type(Module inventory_module)
{
	return typeof(EPos.SB_ModuleInventory);
}
