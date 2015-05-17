using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class SB_ModuleInventoryCount : SBGtkModule, ISBModule
	{
		public string Id{get{return this._moduleId;}}
		public string Name{get{return this._name;}}
		public string Description{get{return this._description;}}
		public string Author{get{return this._author;}}
		public double Version{get{return this._version;}}
		public string LibraryName{get{return "InventoryCount";}}
		public string	Dependencies{get{return "Inventory";}}
		
		construct
		{
			this._moduleId 		= "mod_inventory_count";
			this._name			= "Inventory Count Module";
			this._description 	= "";
			this._author 		= "Sintic Bolivia";
			this._version 		= 1.0;
			
			this.resourceNs		= "/net/sinticbolivia/Inventory";
			this.resourceFile 	= "./modules/inventory-count.gresource";
		}
		public void Enabled()
		{
			this.LoadResources();
			
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string file = "";
			if( dbh.Engine == "sqlite3" )
				file = "sql/inventory-count.sqlite3.sql";
			else if( dbh.Engine == "mysql" )
				file = "sql/inventory-count.mysql.sql";
				
			string[] queries = this.GetSQLFromResource(file);
			foreach(string q in queries)
			{
				dbh.Execute(q);
			}
			
			string[,] perms = 
			{
				{"manage_inventory_counts", "", SBText.__("Manage Inventory Counts")},
				{"create_inventory_count", "", SBText.__("Create Inventory Count")},
				{"edit_inventory_count", "", SBText.__("Edit Inventory Count")},
				{"delete_inventory_count", "", SBText.__("Delete Inventory Count")}
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
			var hook0 = new SBModuleHook(){HookName = "menu_item_inventory", handler = this.hook_menu_item_inventory};
			SBModules.add_action("menu_item_inventory", ref hook0);
		}
		protected void hook_menu_item_inventory(SBModuleArgs<Gtk.MenuItem> args)
		{
			var nb = (SBNotebook)SBGlobals.GetVar("notebook");
			var inventory_menu = (Gtk.MenuItem)args.GetData();
			
			var mi_count = new Gtk.MenuItem.with_label(SBText.__("Physical Count"));
			mi_count.show();
			mi_count.activate.connect( () => 
			{
				if(nb.GetPage("inventory-count")==null)
				{
					var w = new WidgetInventoryCount();
					w.show();
					nb.AddPage("inventory-count", SBText.__("Inventory Count"), w);
				}
				nb.SetCurrentPageById("inventory-count");
			});
			inventory_menu.submenu.add(mi_count);
			
		}
	}
}
public Type sb_get_module_libinventorycount_type(Module inventory_count_module)
{
	return typeof(EPos.SB_ModuleInventoryCount);
}
