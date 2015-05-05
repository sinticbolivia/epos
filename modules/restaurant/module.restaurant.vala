using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace Woocommerce
{
	public class SB_ModuleRestaurant : SBGtkModule, ISBModule
	{
		public string Id{get{return this._moduleId;}}
		public string Name{get{return this._name;}}
		public string Description{get{return this._description;}}
		public string Author{get{return this._author;}}
		public double Version{get{return this._version;}}
		public string LibraryName{get{return "Restaurant";}}
		
		protected string 	resourceFile = "./modules/restaurant.gresource";
		protected string	resourceNs = "/net/sinticbolivia/Restaurant";
		public	static	Resource	res_data;
		
		//##declare glade interfaces
		public	static		Builder	ui_restaurant;
		
		public void Enabled()
		{
			//var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
		}
		public void Disabled()
		{
		}
		public void Load()
		{
			this._moduleId = "mod_restaurant";
			this._name= "Restaurant Module";
			this._description = "A module for restaurant";
			this._author = "Sintic Bolivia";
			this._version = 1.0;
		
			try
			{
				if( FileUtils.test(this.resourceFile, FileTest.EXISTS) )
				{
					SB_ModuleRestaurant.res_data = Resource.load(this.resourceFile);
					size_t ui_size;
					uint32 flags;
					
					SB_ModuleRestaurant.res_data.get_info("%s/ui/environments.glade".printf(this.resourceNs), 
															ResourceLookupFlags.NONE, 
															out ui_size,
															out flags);
					InputStream ui_stream = SB_ModuleRestaurant.res_data.open_stream("%s/ui/environments.glade".printf(this.resourceNs), 
													ResourceLookupFlags.NONE);
					uint8[] data = new uint8[ui_size];
					size_t length;
					ui_stream.read_all(data, out length);
					
					SB_ModuleRestaurant.ui_restaurant = new Builder();
					SB_ModuleRestaurant.ui_restaurant.add_from_string((string)data, length);
					
					
				}
				else
				{
					stderr.printf("Resource file for %s does not exists\n", this.Name);
				}
			}
			catch(GLib.Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
		}
		public void Unload()
		{
		}
		public void Init()
		{
			var hook0 = new SBModuleHook(){HookName = "init_menu_management", handler = init_menu_management};
			var hook1 = new SBModuleHook(){HookName = "init_sidebar", handler = hook_init_sidebar};
			var hook2 = new SBModuleHook(){HookName = "inventory_tabs", handler = hook_inventory_tabs};
			SBModules.add_action("init_menu_management", ref hook0);
			SBModules.add_action("init_sidebar", ref hook1);
			SBModules.add_action("inventory_tabs", ref hook2);
		}
		public static Builder? GetGladeUi(string ui_file)
		{
			size_t ui_size;
			uint32 flags;
			size_t length;
			string ui_res = "/net/sinticbolivia/Restaurant/ui/%s".printf(ui_file);
			
			var builder = new Builder();
			
			try
			{
				SB_ModuleRestaurant.res_data.get_info(ui_res, 
													ResourceLookupFlags.NONE, 
													out ui_size,
													out flags);
				var ui_stream = SB_ModuleRestaurant.res_data.open_stream(ui_res, ResourceLookupFlags.NONE);
				uint8[] data = new uint8[ui_size];
				ui_stream.read_all(data, out length);
				
				builder.add_from_string((string)data, length);
			}
			catch(GLib.Error e)
			{
				stderr.printf("ERROR LOADING GLADE FILE: %s, ERROR:%s\n", ui_file, e.message);
				builder = null;
			}
			
					
			return builder;
			
		}
		public static void init_menu_management(SBModuleArgs<Gtk.Menu> args)
		{
			var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
			var menu = (Gtk.Menu)args.GetData();
			
			var menuItemRestaurant = new Gtk.MenuItem.with_label(SBText.__("Restaurant"));
			menuItemRestaurant.show();
			var restaurant_menu = new Gtk.Menu();
			restaurant_menu.show();
			menuItemRestaurant.set_submenu(restaurant_menu);
			menu.add(menuItemRestaurant);
			
			var menu_item_manage = new Gtk.MenuItem.with_label(SBText.__("Environments and Tables"));
			menu_item_manage.show();
			restaurant_menu.add(menu_item_manage);
			menu_item_manage.activate.connect( () => 
			{
				if( notebook.GetPage("restaurant-envs") == null )
				{
					var w = new WidgetEnvironments();
					w.show();
					notebook.AddPage("restaurant-envs", SBText.__("Restaurant"), w);
				}
				notebook.SetCurrentPageById("restaurant-envs");
			});
		}
		public static void hook_init_sidebar(SBModuleArgs<HashMap> args)
		{
			var data 			= (HashMap<string, Widget>)args.GetData();
			var notebook 		= (SBNotebook)data["notebook"];
			var box_quick_icons	= (Box)data["quickicons"];
			
			var button = new Button();
			button.show();
			button.tooltip_text = SBText.__("Tables");
			try
			{
				var input_stream = SB_ModuleRestaurant.res_data.open_stream("/net/sinticbolivia/Restaurant/images/tables-48x48.jpg", ResourceLookupFlags.NONE);
				button.image = new Image();
				(button.image as Image).pixbuf = new Gdk.Pixbuf.from_stream(input_stream);
			}
			catch(GLib.Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			box_quick_icons.add(button);
			button.clicked.connect( () => 
			{
				if( notebook.GetPage("pos-tables") == null )
				{
					
				}
				notebook.SetCurrentPageById("pos-tables");
			});
		}
		public static void hook_inventory_tabs(SBModuleArgs<HashMap> args)
		{
			var data = (HashMap<string, Widget>)args.GetData();
			var notebook = (Notebook)data["notebook"];
			int total_pages = notebook.get_n_pages();
			var widget = new WidgetRestautantOptions();
			widget.show();
			notebook.insert_page(widget, new Label(SBText.__("Product Options")), total_pages);
			
		}
	}
}
public Type sb_get_module_type(Module restaurant_module)
{
	return typeof(Woocommerce.SB_ModuleRestaurant);
}
