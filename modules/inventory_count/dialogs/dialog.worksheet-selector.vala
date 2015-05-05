using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class DialogWorksheetSelector : Dialog
	{
		protected	Label			labelTitle;
		protected	ScrolledWindow	scrolledwindow1;
		protected	TreeView		treeviewWorksheets;
		protected	Button 			buttonCancel;
		protected	Button 			buttonSelect;
		protected	int				countId;
		public		signal			void		OnSelected(int count_id, int[] worksheets);
		public		bool			MultipleSelection
		{
			get
			{
				return (this.treeviewWorksheets.get_selection().mode == SelectionMode.MULTIPLE);
			}
			set
			{
				if( value )
					this.treeviewWorksheets.get_selection().mode = SelectionMode.MULTIPLE;
				else
					this.treeviewWorksheets.get_selection().mode = SelectionMode.SINGLE;
			}
			default = false;
		}
		public DialogWorksheetSelector(int count_id)
		{
			this.countId = count_id;
			this.title = SBText.__("Select worksheet");
			this.set_size_request(400, 400);
			this.labelTitle = new Label(SBText.__("Select worksheet"));
			this.scrolledwindow1 = new ScrolledWindow(null, null){expand = true};
			this.treeviewWorksheets = new TreeView(){expand = true};
			this.buttonCancel 		= (Button)this.add_button(SBText.__("Cancel"), ResponseType.CANCEL);
			this.buttonSelect 		= (Button)this.add_button(SBText.__("Select"), ResponseType.OK);
			this.Build();
			this.Fill();
			this.SetEvents();
		}
		protected void Build()
		{
			this.treeviewWorksheets.model = new ListStore(3, 
				typeof(int),
				typeof(string), 
				typeof(int)
			);
			GtkHelper.BuildTreeViewColumns({
					{SBText.__("#"), "text", "50", "center", "", ""},
					{SBText.__("Worksheet"), "text", "350", "left", "", ""}
				}, 
				ref this.treeviewWorksheets);
				
			this.scrolledwindow1.add(this.treeviewWorksheets);
			this.get_content_area().add(this.labelTitle);
			this.get_content_area().add(this.scrolledwindow1);
			this.get_content_area().show_all();
		}
		protected void SetEvents()
		{
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
			this.buttonSelect.clicked.connect(this.OnButtonSelectClicked);
		}
		protected void Fill()
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM inventory_count_results WHERE count_id = %d GROUP BY result_number".printf(this.countId);
			TreeIter iter;
			int i = 1;
			foreach(var row in dbh.GetResults(query))
			{
				(this.treeviewWorksheets.model as ListStore).append(out iter);
				(this.treeviewWorksheets.model as ListStore).set(iter,
					0, i,
					1, "Worksheet %d".printf(row.GetInt("result_number")),
					2, row.GetInt("result_number")
				);
				i++;
			}
		}
		protected void OnButtonCancelClicked()
		{
			this.destroy();
		}
		protected void OnButtonSelectClicked()
		{
			/*
			TreeModel model;
			TreeIter iter;
			if( !this.treeviewWorksheets.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			*/
			int rows = this.treeviewWorksheets.get_selection().count_selected_rows();
			if( rows <= 0 )
			{
				return;
			}
			int[] ids = new int[rows];
			
			int i = 0;
			this.treeviewWorksheets.get_selection().selected_foreach( (_model, _path, _iter) => 
			{
				stdout.printf("select \n");
				Value result_number;
				_model.get_value(_iter, 2, out result_number);
				ids[i] = (int)result_number;
				i++;
			});
			this.OnSelected(this.countId, ids);
			
			this.destroy();
		}
	}
}
