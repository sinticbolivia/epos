using GLib;
using Gtk;
using Gee;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace Woocommerce
{
	public class SB_ModuleInventory : SBGtkModule, ISBModule
	{
		public string Id{get{return this._moduleId;}}
		public string Name{get{return this._name;}}
		public string Description{get{return this._description;}}
		public string Author{get{return this._author;}}
		public double Version{get{return this._version;}}
		public string LibraryName{get{return "Inventory";}}
		
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
		public void Enabled()
		{
			this.LoadResources();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string sql_file = "";
			
			if(dbh.Engine == "sqlite3") 
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
			while( (line = ds.read_line()) != null )
			{
				sql += line;
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
			dbh.EndTransaction();
		}		
		public void Disabled()
		{
		}
		public void Load()
		{
			
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
			
			SBModules.add_action("init_sidebar", ref hook);
			SBModules.add_action("init_menu_management", ref hook1);
			SBModules.add_action("reports_menu", ref hook2);
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
			var notebook	= (SBNotebook)data.get("notebook");
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
						var inv = new WidgetIventory();
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
			
			var menuitem_inventory = new Gtk.MenuItem.with_label(SBText.__("Inventory"));
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
					var inv = new WidgetIventory();
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
	}
}
public Type sb_get_module_type(Module inventory_module)
{
	return typeof(Woocommerce.SB_ModuleInventory);
}
