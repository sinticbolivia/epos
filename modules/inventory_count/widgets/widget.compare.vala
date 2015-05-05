using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetCompareWorksheets : Box
	{
		protected	Image			image1;
		protected	Label			labelTitle;
		protected	Notebook		notebook;
		protected	Box				boxResults;
		protected	TreeView		treeviewResults;
		protected	Button 			buttonPrintResults;
		protected	ButtonBox		buttonbox1;
		protected	Button			buttonClose;
		protected	Gdk.Pixbuf		pixbufCheck;
		protected	Gdk.Pixbuf		pixbufCross;
		protected	enum			Columns
		{
			COUNT,
			ID,
			CODE,
			NAME,
			PASS,
			UNITS,
			CASES,
			N_COLS
		}
		protected	ArrayList<WidgetWorksheet>		worksheets;
				
		public WidgetCompareWorksheets()
		{
			this.image1				= new Image.from_pixbuf((SBModules.GetModule("InventoryCount") as SBGtkModule).GetPixbuf("compare-64x64.png"));
			this.labelTitle			= new Label(SBText.__("Compare Worksheets"));
			this.notebook			= new Notebook();
			this.boxResults			= new Box(Orientation.VERTICAL, 5);
			this.treeviewResults	= new TreeView()
			{
				rules_hint 			= true,
				enable_grid_lines 	= TreeViewGridLines.BOTH
			};
			this.pixbufCheck		= (SBModules.GetModule("InventoryCount") as SBGtkModule).GetPixbuf("check-25x25.png");
			this.pixbufCross		= (SBModules.GetModule("InventoryCount") as SBGtkModule).GetPixbuf("cross-25x25.png");
			this.buttonPrintResults	= new Button.from_stock("gtk-print");
			this.buttonbox1			= new ButtonBox(Orientation.HORIZONTAL){halign = Align.END};
			this.buttonClose 		= new Button.with_label(SBText.__("Close"));
			this.worksheets			= new ArrayList<WidgetWorksheet>();
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			this.orientation = Orientation.VERTICAL;
			this.spacing = 5;
			
			this.labelTitle.get_style_context().add_class("widget-title");
			var box = new Box(Orientation.HORIZONTAL, 5);
			box.add(this.image1);
			box.add(this.labelTitle);
			this.add(box);
			this.add(this.notebook);
			this.buttonClose.get_style_context().add_class("button-red");
			this.buttonbox1.add(this.buttonClose);
			this.add(this.buttonbox1);
			//##build box results
			this.treeviewResults.model = new ListStore(Columns.N_COLS,
				typeof(int), //count
				typeof(int), //product id
				typeof(string), //product code,
				typeof(string), //product name
				typeof(Gdk.Pixbuf), //check/cross
				typeof(int), //units
				typeof(int) //cases
			);
			string[,] cols = 
			{
				{SBText.__("#"), "text", "50", "center", "", ""},
				{SBText.__("ID"), "text", "80", "center", "", ""},
				{SBText.__("Code"), "text", "150", "left", "", ""},
				{SBText.__("Product"), "text", "400", "left", "", ""},
				{SBText.__("Pass"), "pixbuf", "30", "center", "", ""},
				{SBText.__("Units"), "text", "60", "center", "editable", ""},
				{SBText.__("Cases"), "text", "60", "center", "editable", ""},
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewResults);
			var scroll = new ScrolledWindow(null, null){expand = true};
			scroll.add(this.treeviewResults);
			this.boxResults.add(scroll);
			this.boxResults.add(this.buttonPrintResults);
			this.boxResults.show_all();
			this.show_all();
		}
		protected void SetEvents()
		{
			this.buttonClose.clicked.connect(this.OnButtonCloseClicked);
			this.buttonPrintResults.clicked.connect(this.OnButtonPrintResultsClicked);
		}
		protected void OnButtonCloseClicked()
		{
			this.destroy();
			string tab_id = this.get_data<string>("tab_id");
			var nb = (SBNotebook)SBGlobals.GetVar("notebook");
			nb.RemovePage(tab_id);
		}
		protected void OnButtonPrintResultsClicked()
		{
		}
		public void AppendWorksheet(int count_id, int result_number)
		{
			//var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var w = new WidgetWorksheet()
			{
				ShowButtons = false,
				Editable	= false
			};
			w.SetWorksheet(count_id, result_number);
			this.worksheets.add(w);
			w.show();
			this.notebook.append_page(w, new Label(SBText.__("Worksheet #%d").printf(result_number)));
		}
		public void CalculateResults()
		{
			this.notebook.append_page(this.boxResults, new Label(SBText.__("Compare Results")));
			var ws1 = (WidgetWorksheet)this.worksheets.get(0);
			var ws2 = (WidgetWorksheet)this.worksheets.get(1);
			//##get total rows
			int total_rows = ws1.Model.iter_n_children(null);
			int i = 1;
			TreeIter iter_ws1, iter_ws2;
			ws1.Model.get_iter_first(out iter_ws1);
			ws2.Model.get_iter_first(out iter_ws2);
			Value product_id, product_code, product_name, ws1_units, ws1_cases, ws2_units, ws2_cases;
			ws1.Model.get_value(iter_ws1, WidgetWorksheet.Columns.UNITS, out ws1_units);
			ws1.Model.get_value(iter_ws1, WidgetWorksheet.Columns.CASES, out ws1_cases);
			ws2.Model.get_value(iter_ws2, WidgetWorksheet.Columns.UNITS, out ws2_units);
			ws2.Model.get_value(iter_ws2, WidgetWorksheet.Columns.CASES, out ws2_cases);
			ws2.Model.get_value(iter_ws2, WidgetWorksheet.Columns.ID, out product_id);
			ws2.Model.get_value(iter_ws2, WidgetWorksheet.Columns.CODE, out product_code);
			ws2.Model.get_value(iter_ws2, WidgetWorksheet.Columns.NAME, out product_name);
			
			int cases_diff = ((int)ws1_cases - (int)ws2_cases);
			int units_diff = ((int)ws1_units - (int)ws2_units);
			TreeIter iter;
			(this.treeviewResults.model as ListStore).append(out iter);
			(this.treeviewResults.model as ListStore).set(iter,
				Columns.COUNT, i,
				Columns.ID, (int)product_id,
				Columns.CODE, (string)product_code,
				Columns.NAME, (string)product_name,
				Columns.PASS, (cases_diff == 0 && units_diff == 0) ? this.pixbufCheck : this.pixbufCross,
				Columns.UNITS, units_diff,
				Columns.CASES, cases_diff
			);
			i++;
			for(int j = 0; j < (total_rows - 1); j++)
			{
				ws1.Model.iter_next(ref iter_ws1);
				ws1.Model.get_value(iter_ws1, WidgetWorksheet.Columns.UNITS, out ws1_units);
				ws1.Model.get_value(iter_ws1, WidgetWorksheet.Columns.CASES, out ws1_cases);
				ws2.Model.iter_next(ref iter_ws2);
				ws2.Model.get_value(iter_ws2, WidgetWorksheet.Columns.UNITS, out ws2_units);
				ws2.Model.get_value(iter_ws2, WidgetWorksheet.Columns.CASES, out ws2_cases);
				ws2.Model.get_value(iter_ws2, WidgetWorksheet.Columns.ID, out product_id);
				ws2.Model.get_value(iter_ws2, WidgetWorksheet.Columns.CODE, out product_code);
				ws2.Model.get_value(iter_ws2, WidgetWorksheet.Columns.NAME, out product_name);
				cases_diff = ((int)ws1_cases - (int)ws2_cases);
				units_diff = ((int)ws1_units - (int)ws2_units);
				
				(this.treeviewResults.model as ListStore).append(out iter);
				(this.treeviewResults.model as ListStore).set(iter,
					Columns.COUNT, i,
					Columns.ID, (int)product_id,
					Columns.CODE, (string)product_code,
					Columns.NAME, (string)product_name,
					Columns.PASS, (cases_diff == 0 && units_diff == 0) ? this.pixbufCheck : this.pixbufCross,
					Columns.UNITS, units_diff,
					Columns.CASES, cases_diff
				);
				i++;
			}
		}
	}
}
