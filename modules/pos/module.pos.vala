using GLib;
using Gee;
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
				file = "";
			else if( dbh.Engine == "mysql" )
				file = "sql/pos.mysql.sql";
				
			string[] queries = this.GetSQLFromResource(file);
			foreach(string q in queries)
			{
				dbh.Execute(q);
			}
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
		}
	}
}
public Type sb_get_module_type(Module users_module)
{
	return typeof(EPos.SB_ModulePos);
}
