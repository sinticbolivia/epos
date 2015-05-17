using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class SB_ModuleQuotes : SBGtkModule, ISBModule
	{
		public string Id{get{return this._moduleId;}}
		public string Name{get{return this._name;}}
		public string Description{get{return this._description;}}
		public string Author{get{return this._author;}}
		public double Version{get{return this._version;}}
		public string LibraryName{get{return "Quotes";}}
		public string	Dependencies{get{return "Pos";}}
		construct
		{
			this._moduleId 		= "mod_quotes";
			this._name			= "Quotes Module";
			this._description 	= "";
			this._author 		= "Sintic Bolivia";
			this._version 		= 1.0;
			this.resourceFile 	= "./modules/quotes.gresource";
			this.resourceNs		= "/net/sinticbolivia/Pos/Quotes";
		}
		public void Enabled()
		{
			this.LoadResources();
			
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string file = "";
			if( dbh.Engine == "sqlite3" )
				file = "sql/quotes.sqlite3.sql";
			else if( dbh.Engine == "mysql" )
				file = "sql/quotes.mysql.sql";
				
			string[] queries = this.GetSQLFromResource(file);
			foreach(string q in queries)
			{
				dbh.Execute(q);
			}
			
			string[,] perms = 
			{
				{"manage_quotes", "", SBText.__("Manage Quotes")},
				{"create_quote", "", SBText.__("Create Quote")},
				{"edit_quote", "", SBText.__("Edit Quote")},
				{"delete_quote", "", SBText.__("Delete Quote")}
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
			var hook0 = new SBModuleHook(){HookName = "menu_item_point_of_sale", handler = this.hook_menu_item_point_of_sale};
			SBModules.add_action("menu_item_point_of_sale", ref hook0);
		}
		protected void hook_menu_item_point_of_sale(SBModuleArgs<Gtk.MenuItem> args)
		{
			var nb		= (SBNotebook)SBGlobals.GetVar("notebook");
			var mi_pos = (Gtk.MenuItem)args.GetData();
			var mi_quotes = new Gtk.ImageMenuItem.with_label(SBText.__("Quotes"));
			mi_quotes.show();
			mi_quotes.image = new Image.from_pixbuf( this.GetPixbuf("quote-25x25.png") );
			mi_quotes.activate.connect( () => 
			{
				string tab_id = "sales-quotes";
				if( nb.GetPage(tab_id) == null )
				{
					var w = new WidgetQuotes();
					w.set_data<string>("tab_id", tab_id);
					w.show();
					nb.AddPage(tab_id, SBText.__("Quotes"), w);
				}
				nb.SetCurrentPageById(tab_id);
			});
			mi_pos.submenu.add(mi_quotes);
		}
	}
}
public Type sb_get_module_libquotes_type(Module quotes_module)
{
	return typeof(EPos.SB_ModuleQuotes);
}
