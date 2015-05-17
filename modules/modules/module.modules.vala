using GLib;
using Gtk;
using Gee;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class SB_ModuleModules : SBGtkModule, ISBModule
	{
		public string Id{get{return this._moduleId;}}
		public string Name{get{return this._name;}}
		public string Description{get{return this._description;}}
		public string Author{get{return this._author;}}
		public double Version{get{return this._version;}}
		public string LibraryName{get{return "Modules";}}
		public string	Dependencies{get{return "";}}
		construct
		{
			this._moduleId 		= "mod_modules";
			this._name			= "Modules";
			this._description 	= "";
			this._author 		= "Sintic Bolivia";
			this._version 		= 1.0;
			
			this.resourceNs		= "/net/sinticbolivia/Modules";
			this.resourceFile 	= "./modules/modules.gresource";
		}
		public void Enabled()
		{
			
		}		
		public void Disabled()
		{
		}
		public void Load()
		{
			
		}
		public void Init()
		{
			try
			{
				if( FileUtils.test(this.resourceFile, FileTest.EXISTS) )
				{
					this.res_data = Resource.load(this.resourceFile);
					
				}
				else
				{
					stderr.printf("Resource file for modules \"%s\" module does not exists\n".printf(this.resourceFile));
				}
			}
			catch(GLib.Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM modules WHERE status = 'enabled'";
			foreach(SBDBRow row in dbh.GetResults(query))
			{
				if( row.Get("module_key") == "mod_users" ) continue;
				
				ISBModule mod = SBModules.GetModule(row.Get("library_name"));
				stdout.printf("Inititalizing module %s\n", mod.Name);
				mod.Init();
				
			}
			
			this.AddHooks();
		}
		public void Unload()
		{
			stdout.printf("Module Modules unloaded\n");
		}
		protected void AddHooks()
		{
			var hook1 = new SBModuleHook();
			hook1.HookName = "init_menu_management";
			hook1.handler	= (ActionHandler)SB_ModuleModules.init_menu_management;
			SBModules.add_action("init_menu_management", ref hook1);
		}
		public static void init_menu_management(SBModuleArgs<Gtk.Menu> args)
		{
			var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
			var menu = (Gtk.Menu)args.GetData();
			var menuitem_customers = new Gtk.MenuItem.with_label(SBText.__("Modules Management"));
			menuitem_customers.show();
			menu.add(menuitem_customers);
			menuitem_customers.activate.connect( () => 
			{
				if( notebook.GetPage("modules") == null )
				{
					var w = new WidgetModules();
					w.show();
					notebook.AddPage("modules", SBText.__("Modules Management"), w);
				}
				notebook.SetCurrentPageById("modules");
			});
		}
	}
}
public Type sb_get_module_libmodules_type(Module customers_module)
{
	return typeof(EPos.SB_ModuleModules);
}
