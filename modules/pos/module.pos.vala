using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class SB_ModulePos : SBGtkModule, ISBModule
	{
		public string Id{get{return this._moduleId;}}
		public string Name{get{return this._name;}}
		public string Description{get{return this._description;}}
		public string Author{get{return this._author;}}
		public double Version{get{return this._version;}}
		public string LibraryName{get{return "Pos";}}
		
		construct
		{
			this._moduleId 		= "mod_pos";
			this._name			= "Point of Sale Module";
			this._description 	= "";
			this._author 		= "Sintic Bolivia";
			this._version 		= 1.0;
			this.resourceFile 	= "./modules/pos.gresource";
			this.resourceNs		= "/net/sinticbolivia/Pos";
		}
		public void Enabled()
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string file = "";
			if( dbh.Engine == "sqlite3" )
				file = "sql/pos.sqlite3.sql";
			else if( dbh.Engine == "mysql" )
				file = "sql/pos.mysql.sql";
				
			string[] queries = this.GetSQLFromResource(file);
			foreach(string q in queries)
			{
				dbh.Execute(q);
			}
			//##add necessary permissions
			string[,] perms = 
			{
				{"manage_sales", "", SBText.__("Manage Sales")},
				{"make_sales", "", SBText.__("Make Sales")},
				{"refund_sales", "", SBText.__("Refund Sales")}
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
		public void Unload()
		{
		}
		public void Init()
		{
			this.LoadResources();
			this.AddHooks();
		}
		protected void AddHooks()
		{
			var hook0 = new SBModuleHook(){HookName = "init_menu_management", handler = init_menu_management};
			SBModules.add_action("init_menu_management", ref hook0);
			var hook1 = new SBModuleHook(){HookName = "init_sidebar", handler = init_sidebar};
			SBModules.add_action("init_sidebar", ref hook1);
			var hook2 = new SBModuleHook(){HookName = "config_build", handler = this.hook_config_build};
			SBModules.add_action("config_build", ref hook2);
			var hook3 = new SBModuleHook(){HookName = "build_customer_form", handler = this.hook_build_customer_form};
			SBModules.add_action("build_customer_form", ref hook3);
		}
		public static void init_sidebar(SBModuleArgs<HashMap> args)
		{
			var user = (SBUser)SBGlobals.GetVar("user");
			var data = (HashMap<string, Widget>)args.GetData();
			var box = (Box)data["quickicons"];
			var nb = (SBNotebook)SBGlobals.GetVar("notebook");
			var btn_pos = new Button();
			btn_pos.image = new Image.from_pixbuf((SBModules.GetModule("Pos") as SBGtkModule).GetPixbuf("sale-icon-48x48.png"));
			btn_pos.show();
			btn_pos.clicked.connect( () => 
			{
				string pos_gui = (string)(SBGlobals.GetVar("config") as SBConfig).GetValue("pos_gui", "standard");
				
				string tab_id = "pos-%s".printf(pos_gui);
				if( !user.HasPermission("make_sales") )
				{
					var err = new InfoDialog("error")
					{
						Title = SBText.__("Point of Sale Error"),
						Message = SBText.__("You don't have enough permission to make sales.")
					};
					err.run();
					err.destroy();
					nb.RemovePage(tab_id);
					return;
				}
				if( nb.GetPage(tab_id) == null )
				{
					Widget? w = null;
					if( pos_gui == "retail" )
					{
						w = new WidgetRetailPos();
					}
					else if(pos_gui == "standard") 
					{
						w = new WidgetPOS();
						(w as WidgetPOS).TabId = tab_id;
						(w as WidgetPOS).Dbh = SBFactory.GetNewDbHandlerFromConfig((SBConfig)SBGlobals.GetVar("config"));
						(w as WidgetPOS).ShowStoreSelector();
					}
						
					nb.AddPage(tab_id, SBText.__("Point of Sale (Retail)"), w);
					w.show();
					
				}
				nb.SetCurrentPageById(tab_id);
			});
			box.add(btn_pos);
			
		}
		public static void init_menu_management(SBModuleArgs<Gtk.Menu> args)
		{
			var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
			var user = (SBUser)SBGlobals.GetVar("user");
			var menu = (Gtk.Menu)args.GetData();
			var mi_pos = new Gtk.ImageMenuItem.with_label(SBText.__("Point of Sale"));
			mi_pos.image = new Image.from_pixbuf((SBModules.GetModule("Pos") as SBGtkModule).GetPixbuf("pos01-25x25.png"));
			mi_pos.show();
			mi_pos.submenu = new Gtk.Menu();
			menu.add(mi_pos);
			
			var mi_payment_method = new Gtk.MenuItem.with_label(SBText.__("Payment Methods"));
			mi_payment_method.show();
			mi_payment_method.activate.connect( () => 
			{
				if( notebook.GetPage("payment-methods") == null )
				{
					var w = new WidgetPaymentMethods();
					w.show();
					notebook.AddPage("payment-methods", SBText.__("Payment Methods"), w);
				}
				notebook.SetCurrentPageById("payment-methods");
			});
			mi_pos.submenu.add(mi_payment_method);
			
			var mi_levels = new Gtk.MenuItem.with_label(SBText.__("Price Levels"));
			mi_levels.show();
			mi_levels.activate.connect( () => 
			{
				if( notebook.GetPage("price-levels") == null )
				{
					var w = new WidgetPriceLevels();
					w.show();
					notebook.AddPage("price-levels", SBText.__("Price Levels"), w);
				}
				notebook.SetCurrentPageById("price-levels");
			});
			mi_pos.submenu.add(mi_levels);
			//##promotional prices
			var mi_pp = new Gtk.MenuItem.with_label(SBText.__("Promotional Prices"));
			mi_pp.show();
			mi_pp.activate.connect( () => 
			{
				if( notebook.GetPage("promo-prices") == null )
				{
					var w = new WidgetPromotionalPrices();
					w.show();
					notebook.AddPage("promo-prices", SBText.__("Promotional Prices"), w);
				}
				notebook.SetCurrentPageById("promo-prices");
			});
			mi_pos.submenu.add(mi_pp);
			
			var mi_rpos = new Gtk.MenuItem.with_label(SBText.__("Point of Sale"));
			mi_rpos.show();
			mi_rpos.activate.connect( () => 
			{
				string pos_gui = (string)(SBGlobals.GetVar("config") as SBConfig).GetValue("pos_gui", "standard");
				
				string tab_id = "pos-%s".printf(pos_gui);
				if( !user.HasPermission("make_sales") )
				{
					var err = new InfoDialog("error")
					{
						Title = SBText.__("Point of Sale Error"),
						Message = SBText.__("You don't have enough permission to make sales.")
					};
					err.run();
					err.destroy();
					return;
				}
				if( notebook.GetPage(tab_id) == null )
				{
					Widget? w = null;
					if( pos_gui == "retail" )
						w = new WidgetRetailPos();
					else if(pos_gui == "standard") 
					{
						w = new WidgetPOS();
						(w as WidgetPOS).TabId = tab_id;
						(w as WidgetPOS).Dbh = SBFactory.GetNewDbHandlerFromConfig((SBConfig)SBGlobals.GetVar("config"));
						(w as WidgetPOS).ShowStoreSelector();
					}
					notebook.AddPage(tab_id, SBText.__("Point of Sale"), w);
					w.show();
					
				}
				notebook.SetCurrentPageById(tab_id);
			});
			mi_pos.submenu.add(mi_rpos);
		}
		protected void hook_config_build(SBModuleArgs<Widget> args)
		{
			var notebook = (Notebook)args.GetData();
			var w = new WidgetPosConfig();
			w.show();
			notebook.append_page(w, new Label(SBText.__("Point of Sale")));
		}
		protected void hook_build_customer_form(SBModuleArgs<Widget> args)
		{
			var data = (HashMap<string, Value?>)args.GetData();
			var grid_groups = (Grid)data["grid_groups"];
			var w = new WidgetCustomerPriceGroups();
			
			grid_groups.attach(w.label1, 0, 1, 1, 1);
			grid_groups.attach(w.comboboxPriceGroups, 1, 1, 1, 1);
		}
	}
}
public Type sb_get_module_libpos_type(Module users_module)
{
	return typeof(EPos.SB_ModulePos);
}
