using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetPriceLevels : Box
	{
		protected	Builder		ui;
		protected	Box			box1;
		protected	Image		image1;
		protected	Button		buttonNew;
		protected	Button		buttonEdit;
		protected	Button		buttonDelete;
		protected	TreeView	treeviewLevels;
		
		public WidgetPriceLevels()
		{
			this.expand = true;
			this.ui	= (SBModules.GetModule("Pos") as SBGtkModule).GetGladeUi("price-levels.glade");
			this.box1		= (Box)this.ui.get_object("box1");
			this.image1		= (Image)this.ui.get_object("image1");
			this.buttonNew		= (Button)this.ui.get_object("buttonNew");
			this.buttonEdit		= (Button)this.ui.get_object("buttonEdit");
			this.buttonDelete	= (Button)this.ui.get_object("buttonDelete");
			this.treeviewLevels	= (TreeView)this.ui.get_object("treeviewLevels");
			this.box1.reparent(this);
			this.Build();
			this.Refresh();
			this.SetEvents();
		}
		protected void Build()
		{
			this.image1.pixbuf = (SBModules.GetModule("Pos") as SBGtkModule).GetPixbuf("price-levels.png");
			this.box1.expand = true;
			this.treeviewLevels.model = new ListStore(4,
				typeof(int),
				typeof(int),
				typeof(string),
				typeof(string)
			);
			string[,] cols = 
			{
				{"#", "text", "50", "center", "", ""},
				{SBText.__("ID"), "text", "50", "center", "", ""},
				{SBText.__("Level"), "text", "250", "left", "editable", ""},
				{SBText.__("Percentage"), "text", "90", "right", "editable", ""},
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewLevels);
			this.treeviewLevels.rules_hint = true;
		}
		protected void SetEvents()
		{
			this.buttonNew.clicked.connect(this.OnButtonNewClicked);
			this.buttonEdit.clicked.connect(this.OnButtonEditClicked);
			this.buttonDelete.clicked.connect(this.OnButtonDeleteClicked);
			var cell_level = (CellRendererText)this.treeviewLevels.get_column(2).get_cells().nth_data(0);
			cell_level.edited.connect(this.OnCellLevelEdited);
			var cell_percent = (CellRendererText)this.treeviewLevels.get_column(3).get_cells().nth_data(0);
			cell_percent.edited.connect(this.OnCellPercentEdited);
		}
		protected void OnButtonNewClicked()
		{
			int i = 0;
			this.treeviewLevels.model.foreach( () => 
			{
				i++;
				return false;
			});
			TreeIter iter;
			(this.treeviewLevels.model as ListStore).append(out iter);
			(this.treeviewLevels.model as ListStore).set(iter, 
				0, i + 1,
				1, 0
			);
			
			
			TreePath path = this.treeviewLevels.model.get_path(iter);
			this.treeviewLevels.set_cursor(path, this.treeviewLevels.get_column(2), true);
		}
		protected void OnButtonEditClicked()
		{
			TreeModel model;
			TreeIter iter;
			if( !this.treeviewLevels.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			TreePath path = this.treeviewLevels.model.get_path(iter);
			this.treeviewLevels.set_cursor(path, this.treeviewLevels.get_column(2), true);
		}
		protected void OnButtonDeleteClicked()
		{
		}
		protected void OnCellLevelEdited(string path, string new_text)
		{
			if( new_text.strip().length <= 0 )
			{
				var err = new InfoDialog("error")
				{
					Title = SBText.__("Price Level Error"),
					Message = SBText.__("You need to set the price level name.")
				};
				err.run();
				err.destroy();
				this.treeviewLevels.set_cursor(new TreePath.from_string(path), this.treeviewLevels.get_column(2), true);
				return;
			}
			TreeIter iter;
			this.treeviewLevels.model.get_iter_from_string(out iter, path);
			(this.treeviewLevels.model as ListStore).set_value(iter, 2, new_text.strip());
			this.SaveRow(iter);
			this.treeviewLevels.set_cursor(new TreePath.from_string(path), this.treeviewLevels.get_column(3), true);
		}
		protected void OnCellPercentEdited(string path, string new_text)
		{
			double percent = double.parse(new_text.strip());
			TreeIter iter;
			this.treeviewLevels.model.get_iter_from_string(out iter, path);
			(this.treeviewLevels.model as ListStore).set_value(iter, 3, "%.2f".printf(percent));
			this.SaveRow(iter);
		}
		protected void SaveRow(TreeIter iter)
		{
			Value id, name, v_percent;
			this.treeviewLevels.model.get_value(iter, 1, out id);
			this.treeviewLevels.model.get_value(iter, 2, out name);
			this.treeviewLevels.model.get_value(iter, 3, out v_percent);
			double percent = double.parse((string)v_percent);
			string cdate = new DateTime.now_local().format("%Y-%m-%d %H:%M:%S");
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var data = new HashMap<string, Value?>();
			data.set("name", (string)name);
			data.set("percentage", percent);
			data.set("last_modification_date", cdate);
			int level_id = (int)id;
			if( level_id <= 0 )
			{
				data.set("creation_date", cdate);
				level_id = (int)dbh.Insert("price_levels", data);
			}
			else
			{
				//data["percentage"] = double.parse((string)percent);
				var where = new HashMap<string, Value?>();
				where.set("level_id", level_id);
				dbh.Update("price_levels", data, where);
			}
			(this.treeviewLevels.model as ListStore).set(iter, 
				1, level_id,
				2, (string)name,
				3, "%.2f".printf(percent)
			);
		}
		protected void Refresh()
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("price_levels");
			(this.treeviewLevels.model as ListStore).clear();
			int i = 1;
			TreeIter iter;
			foreach(var row in dbh.GetResults(null))
			{
				(this.treeviewLevels.model as ListStore).append(out iter);
				(this.treeviewLevels.model as ListStore).set(iter,
					0, i,
					1, row.GetInt("level_id"),
					2, row.Get("name"),
					3, "%.2f".printf(row.GetDouble("percentage"))
				);
				i++;
			}
		}
	}
}
