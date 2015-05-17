using GLib;
using Gtk;
using Gee;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class SB_ModuleCustomers : SBGtkModule, ISBModule
	{
		public string Id{get{return this._moduleId;}}
		public string Name{get{return this._name;}}
		public string Description{get{return this._description;}}
		public string Author{get{return this._author;}}
		public double Version{get{return this._version;}}
		public string LibraryName{get{return "Customers";}}
		public string	Dependencies{get{return "";}}
		/*
		public static 	Resource res_data;
		public static	Builder	ui_products;
		public static	Builder ui_new_product;
		public static	SBNotebook notebook;
		*/
		construct
		{
			this._moduleId 		= "mod_customers";
			this._name			= "Customers Module";
			this._description 	= "Module to manage your customers.";
			this._author 		= "Sintic Bolivia";
			this._version 		= 1.0;
			
			this.resourceNs		= "/net/sinticbolivia/Customers";
			this.resourceFile 	= "./modules/customers.gresource";
		}
		
		public void Enabled()
		{
			this.LoadResources();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string sql_file = "";
			if( dbh.Engine == "sqlite3" )
			{
				sql_file = "sql/customers.sqlite3.sql";
			}
			else if( dbh.Engine == "mysql" )
			{
				sql_file = "sql/customers.mysql.sql";
			}
			
			string[] queries = this.GetSQLFromResource(sql_file);
			foreach(string q in queries)
			{
				dbh.Execute(q);
			}
			/*
			var istream = (InputStream)this.GetInputStream(sql_file);
			var ds = new DataInputStream(istream);
			string sql = "";
			string? line = "";
			while( (line = ds.read_line()) != null )
			{
				sql += line;
			}
			dbh.Execute(sql);
			*/
			string[,] perms = 
			{
				{"manage_customers", "", SBText.__("Manage Customers")},
				{"create_customers", "", SBText.__("Create Customers")},
				{"edit_customers", "", SBText.__("Edit Customers")},
				{"delete_customers", "", SBText.__("Delete Products")},
				{"manage_customer_groups", "", SBText.__("Manage Customer Groups")},
				{"create_customer_groups", "", SBText.__("Create Customer Groups")},
				{"edit_customer_groups", "", SBText.__("Edit Customer Groups")},
				{"delete_customer_groups", "", SBText.__("Delete Customer Groups")}
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
			this.AddHooks();
		}
		public void Unload()
		{
			stdout.printf("Module Customers unloaded\n");
		}
		protected void AddHooks()
		{
			var hook1 = new SBModuleHook();
			hook1.HookName = "init_menu_management";
			hook1.handler	= (ActionHandler)SB_ModuleCustomers.init_menu_management;
			SBModules.add_action("init_menu_management", ref hook1);
		}
		public static void init_menu_management(SBModuleArgs<Gtk.Menu> args)
		{
			var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
			var menu = (Gtk.Menu)args.GetData();
			var menuitem_customers = new Gtk.MenuItem.with_label(SBText.__("Customers"));
			menuitem_customers.show();
			menuitem_customers.submenu = new Gtk.Menu();
			menu.add(menuitem_customers);
			
			var mi_groups = new Gtk.MenuItem.with_label(SBText.__("Groups"));
			mi_groups.show();
			mi_groups.activate.connect( () => 
			{
				if( notebook.GetPage("customer-groups") == null )
				{
					var w = new WidgetCustomerGroups();
					w.show();
					notebook.AddPage("customer-groups", SBText.__("Groups"), w);
				}
				notebook.SetCurrentPageById("customer-groups");
			});
			menuitem_customers.submenu.add(mi_groups);
			
			var mi_cust = new Gtk.MenuItem.with_label(SBText.__("Customers"));
			mi_cust.show();
			mi_cust.activate.connect( () => 
			{
				if( notebook.GetPage("customers") == null )
				{
					var w = new WidgetCustomers();
					w.show();
					notebook.AddPage("customers", SBText.__("Customers"), w);
				}
				notebook.SetCurrentPageById("customers");
			});
			menuitem_customers.submenu.add(mi_cust);
			
			
		}
	}
}
public Type sb_get_module_libcustomers_type(Module customers_module)
{
	return typeof(EPos.SB_ModuleCustomers);
}
