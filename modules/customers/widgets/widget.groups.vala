using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetCustomerGroups : Box
	{
		protected	Builder			ui;
		protected	Box				box1;
		protected	Image			image1;
		protected	Button			buttonNew;
		protected	Button			buttonEdit;
		protected	Button			buttonDelete;
		protected	TreeView		treeviewGroups;
		
		public WidgetCustomerGroups()
		{
			this.expand = true;
			this.ui			= (SBModules.GetModule("Customers") as SBGtkModule).GetGladeUi("groups.glade");
			this.box1		= (Box)this.ui.get_object("box1");
			this.image1		= (Image)this.ui.get_object("image1");
			this.buttonNew		= (Button)this.ui.get_object("buttonNew");
			this.buttonEdit		= (Button)this.ui.get_object("buttonEdit");
			this.buttonDelete	= (Button)this.ui.get_object("buttonDelete");
			this.treeviewGroups	= (TreeView)this.ui.get_object("treeviewGroups");
			this.box1.expand = true;
			this.box1.reparent(this);
			this.Build();
			this.Refresh();
			this.SetEvents();
		}
		protected void Build()
		{
			this.image1.pixbuf	= (SBModules.GetModule("Customers") as SBGtkModule).GetPixbuf("group_people-64x64.png");
			this.treeviewGroups.model = new ListStore(3,
				typeof(int), //count
				typeof(int), //id
				typeof(string) //group name
			);
			string[,] cols = 
			{
				{"#", "text", "50", "center", "", ""},
				{SBText.__("ID"), "text", "70", "center", "", ""},
				{SBText.__("Group"), "text", "250", "left", "editable", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewGroups);
			this.treeviewGroups.rules_hint = true;
		}
		protected void SetEvents()
		{
			var cell_group_name = (CellRendererText)this.treeviewGroups.get_column(2).get_cells().nth_data(0);
			
		}
		protected void Refresh()
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("customer_groups").OrderBy("name", "ASC");
			int  i = 1;
			TreeIter iter;
			(this.treeviewGroups.model as ListStore).clear();
			foreach(var row in dbh.GetResults(null))
			{
				(this.treeviewGroups.model as ListStore).append(out iter);
				(this.treeviewGroups.model as ListStore).set(iter,
					0, i,
					1, row.GetInt("group_id"),
					2, row.Get("name")
				);
				i++;
			}
		}
	}
}
