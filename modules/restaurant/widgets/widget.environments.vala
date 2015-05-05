using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace Woocommerce
{
	public class WidgetEnvironments : Box
	{
		protected	Window		windowRestaurant;
		protected	Box			boxRestaurant;
		protected 	Image 		image1;
		protected	TreeView	treeviewEnvironments;
		protected	Image		imageEnvironment;
		protected	Button		buttonEnvImage;
		protected	Button		buttonNewEnv;
		protected	Button		buttonDeleteEnv;
		protected	TreeView	treeviewTables;
		protected	Image		imageTable;
		protected 	Button		buttonTableImage;
		protected	Button		buttonNewTable;
		protected	Button		buttonDeleteTable;
		
		protected	int			current_env_id = 0;
		
		protected static int instances;
		static construct
		{
			WidgetEnvironments.instances = 0;
		}
		public WidgetEnvironments()
		{
			this.windowRestaurant		= (Window)SB_ModuleRestaurant.ui_restaurant.get_object("windowRestaurant");
			this.boxRestaurant			= (Box)SB_ModuleRestaurant.ui_restaurant.get_object("boxRestaurant");
			this.image1					= (Image)SB_ModuleRestaurant.ui_restaurant.get_object("image1");
			this.treeviewEnvironments	= (TreeView)SB_ModuleRestaurant.ui_restaurant.get_object("treeviewEnvironments");
			this.buttonEnvImage			= (Button)SB_ModuleRestaurant.ui_restaurant.get_object("buttonEnvImage");
			this.imageEnvironment		= (Image)SB_ModuleRestaurant.ui_restaurant.get_object("imageEnvironment");
			this.buttonNewEnv			= (Button)SB_ModuleRestaurant.ui_restaurant.get_object("buttonNewEnv");
			this.buttonDeleteEnv		= (Button)SB_ModuleRestaurant.ui_restaurant.get_object("buttonDeleteEnv");
			this.treeviewTables			= (TreeView)SB_ModuleRestaurant.ui_restaurant.get_object("treeviewTables");
			this.buttonTableImage		= (Button)SB_ModuleRestaurant.ui_restaurant.get_object("buttonTableImage");
			this.imageTable				= (Image)SB_ModuleRestaurant.ui_restaurant.get_object("imageTable");
			this.buttonNewTable			= (Button)SB_ModuleRestaurant.ui_restaurant.get_object("buttonNewTable");
			this.buttonDeleteTable		= (Button)SB_ModuleRestaurant.ui_restaurant.get_object("buttonDeleteTable");
			
			if( WidgetEnvironments.instances == 0 )
			{
				this.Build();
			}
			this.SetEvents();
			WidgetEnvironments.instances++;
			this.RefreshEnvironments();
			this.boxRestaurant.reparent(this);
		}
		protected void Build()
		{
			try
			{
				var stream = SB_ModuleRestaurant.res_data.open_stream("/net/sinticbolivia/Restaurant/images/tables-64x64.jpg", 
																ResourceLookupFlags.NONE);
				this.image1.pixbuf = new Gdk.Pixbuf.from_stream(stream);
				var stream0 = SB_ModuleRestaurant.res_data.open_stream("/net/sinticbolivia/Restaurant/images/dining-icon-64x64.jpg", 
																ResourceLookupFlags.NONE);
				this.imageEnvironment.pixbuf = new Gdk.Pixbuf.from_stream(stream0);
				var stream1 = SB_ModuleRestaurant.res_data.open_stream("/net/sinticbolivia/Restaurant/images/table-icon-64x64.png", 
																ResourceLookupFlags.NONE);
				this.imageTable.pixbuf = new Gdk.Pixbuf.from_stream(stream1);
				
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			this.treeviewEnvironments.model = new ListStore(2, typeof(int), typeof(string));
			this.treeviewEnvironments.insert_column_with_attributes(0, SBText.__("Id"),
														new CellRendererText(){width = 100},
														"text", 0);
			this.treeviewEnvironments.insert_column_with_attributes(1, SBText.__("Name"),
														new CellRendererText()
														{
															width = 150, editable = true
														},
														"text", 1);
			
			this.treeviewTables.model = new ListStore(2, typeof(int), typeof(string));
			this.treeviewTables.insert_column_with_attributes(0, SBText.__("Id"), 
											new CellRendererText(){width = 100}, 
											"text", 0);
			this.treeviewTables.insert_column_with_attributes(1, 
											SBText.__("Name"), 
											new CellRendererText(){width = 150, editable = true}, 
											"text", 1);
		}
		protected void SetEvents()
		{
			this.destroy.connect( () => 
			{
				this.boxRestaurant.reparent(this.windowRestaurant);
			});
			this.treeviewEnvironments.cursor_changed.connect( () => 
			//this.treeviewEnvironments.move_cursor.connect( () => 
			{
				TreeModel model;
				TreeIter iter;
				if( this.treeviewEnvironments.get_selection().get_selected(out model, out iter) )
				{
					Value v_env_id;
					this.treeviewEnvironments.model.get_value(iter, 0, out v_env_id);
					this.RefreshTables((int)v_env_id);
					this.current_env_id = (int)v_env_id;
				}
				
			});
			(this.treeviewEnvironments.get_column(1).get_cells().first().data as CellRendererText).
				edited.connect(this.OnEnvironmenNameEdited);
			this.buttonNewEnv.clicked.connect(this.OnButtonNewEnvClicked);
			this.buttonDeleteEnv.clicked.connect(this.OnButtonDeleteEnvClicked);
			(this.treeviewTables.get_column(1).get_cells().first().data as CellRendererText).
				edited.connect(this.OnTableNameEdited);
			this.buttonNewTable.clicked.connect(this.OnButtonNewTableClicked);
			this.buttonDeleteTable.clicked.connect(this.OnButtonDeleteTableClicked);
		}
		protected void RefreshEnvironments()
		{
			(this.treeviewEnvironments.model as ListStore).clear();
			var envs = (ArrayList<HashMap<string, Value?>>)RestaurantHelper.GetEnvironments();
			TreeIter iter;
			foreach(HashMap<string, Value?> env in envs)
			{
				(this.treeviewEnvironments.model as ListStore).append(out iter);
				(this.treeviewEnvironments.model as ListStore).set(iter, 0, (int)env["environment_id"], 1, (string)env["name"]);
			}
		}
		protected void RefreshTables(int env_id)
		{
			(this.treeviewTables.model as ListStore).clear();
			var tables = (ArrayList<HashMap<string, Value?>>)RestaurantHelper.GetTables(env_id);
			TreeIter iter;
			foreach(var table in tables)
			{
				(this.treeviewTables.model as ListStore).append(out iter);
				(this.treeviewTables.model as ListStore).set(iter, 0, (int)table["table_id"], 1, (string)table["name"]);
			}
		}
		protected void OnButtonNewEnvClicked()
		{
			TreeIter iter;
			(this.treeviewEnvironments.model as ListStore).append(out iter);
			var path = this.treeviewEnvironments.model.get_path(iter);
			var column = this.treeviewEnvironments.get_column(1);
			var cell	= (CellRendererText)column.get_cells().first().data;
			this.treeviewEnvironments.set_cursor_on_cell(path, column, cell, true);
			
		}
		protected void OnButtonDeleteEnvClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewEnvironments.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			Value v_env_id;
			this.treeviewEnvironments.model.get_value(iter, 0, out v_env_id);
			if( (int)v_env_id <= 0 )
				return;
			RestaurantHelper.DeleteEnvironment((int)v_env_id);
			this.RefreshEnvironments();
		}
		protected void OnEnvironmenNameEdited(string path, string new_text)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			TreeIter iter;
			this.treeviewEnvironments.model.get_iter(out iter, new TreePath.from_string(path));
			(this.treeviewEnvironments.model as ListStore).set_value(iter, 1, new_text);
			Value v_env_id, v_env_name;
			this.treeviewEnvironments.model.get_value(iter, 0, out v_env_id);
			this.treeviewEnvironments.model.get_value(iter, 1, out v_env_name);
			
			var date = new DateTime.now_local();
			var data = new HashMap<string, Value?>();
			data.set("name", (string)v_env_name);
			data.set("last_modification_date", date.format("%Y-%m-%d %H:%M:%S"));
			if( (int)v_env_id == 0 )
			{
				
				data.set("creation_date", date.format("%Y-%m-%d %H:%M:%S"));
				dbh.Insert("rest_environments", data);
			}
			else
			{
				var w = new HashMap<string, Value?>();
				w.set("environment_id", (int)v_env_id);
				dbh.Update("rest_environments", data, w);
			}
			this.RefreshEnvironments();
			
		}
		protected void OnTableNameEdited(string path, string new_text)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			TreeIter iter;
			this.treeviewTables.model.get_iter(out iter, new TreePath.from_string(path));
			(this.treeviewTables.model as ListStore).set_value(iter, 1, new_text);
			Value v_table_id, v_table_name;
			this.treeviewTables.model.get_value(iter, 0, out v_table_id);
			this.treeviewTables.model.get_value(iter, 1, out v_table_name);
			
			var date = new DateTime.now_local();
			var data = new HashMap<string, Value?>();
			data.set("name", (string)v_table_name);
			data.set("last_modification_date", date.format("%Y-%m-%d %H:%M:%S"));
			if( (int)v_table_id == 0 )
			{
				data.set("environment_id", this.current_env_id);
				data.set("creation_date", date.format("%Y-%m-%d %H:%M:%S"));
				dbh.Insert("rest_tables", data);
			}
			else
			{
				var w = new HashMap<string, Value?>();
				w.set("table_id", (int)v_table_id);
				dbh.Update("rest_tables", data, w);
			}
			this.RefreshTables(this.current_env_id);
		}
		protected void OnButtonNewTableClicked()
		{
			TreeIter iter;
			(this.treeviewTables.model as ListStore).append(out iter);
			var path = this.treeviewTables.model.get_path(iter);
			var column = this.treeviewTables.get_column(1);
			var cell	= (CellRendererText)column.get_cells().first().data;
			this.treeviewTables.set_cursor_on_cell(path, column, cell, true);
		}
		protected void OnButtonDeleteTableClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewTables.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			Value v_id;
			this.treeviewTables.model.get_value(iter, 0, out v_id);
			if( (int)v_id <= 0 )
				return;
			RestaurantHelper.DeleteTable((int)v_id);
			this.RefreshTables(this.current_env_id);
		}
	}
}
