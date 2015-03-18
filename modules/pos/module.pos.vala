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
				string tab_id = "retail-pos";
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
				if(nb.GetPage(tab_id) == null )
				{
					var w = new WidgetRetailPos();
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
			
			var menu = (Gtk.Menu)args.GetData();
			var mi_pos = new Gtk.MenuItem.with_label(SBText.__("Point of Sale"));
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
			
			var mi_rpos = new Gtk.MenuItem.with_label(SBText.__("Point of Sale"));
			mi_rpos.show();
			mi_rpos.activate.connect( () => 
			{
				if( notebook.GetPage("retail-pos") == null )
				{
					var w = new EPos.WidgetRetailPos();
					w.show();
					notebook.AddPage("retail-pos", SBText.__("Point of Sale"), w);
				}
				notebook.SetCurrentPageById("retail-pos");
			});
			mi_pos.submenu.add(mi_rpos);
		}
	}
}
public Type sb_get_module_libpos_type(Module users_module)
{
	return typeof(EPos.SB_ModulePos);
}
