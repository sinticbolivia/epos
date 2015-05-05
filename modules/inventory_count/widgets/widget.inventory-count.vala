using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetInventoryCount : Box
	{
		protected 	Builder			ui;
		protected	Box				box1;
		protected	Image			image1;
		protected	Button			buttonNew;
		protected	Button			buttonEdit;
		protected	Button			buttonDelete;
		protected	Button			buttonPrint;
		protected	Button 			buttonSubmitWorkSheet;
		protected	Button 			buttonEditWorksheet;
		protected	Button 			buttonCompareWorksheets;
		protected	ComboBox		comboboxStore;
		protected	TreeView		treeviewCounts;
		protected	enum			Columns
		{
			COUNT,
			ID,
			DESCRIPTION,
			TOTAL_PRODUCTS,
			STATUS,
			CREATION_DATE,
			N_COLS
		}
		protected	int				selectedCountId = 0;
		public WidgetInventoryCount()
		{
			this.expand 	= true;
			this.ui			= (SBModules.GetModule("InventoryCount") as SBGtkModule).GetGladeUi("inventory-count.glade");
			this.box1		= (Box)this.ui.get_object("box1");
			this.image1		= (Image)this.ui.get_object("image1");
			this.buttonNew	= (Button)this.ui.get_object("buttonNew");
			this.buttonEdit	= (Button)this.ui.get_object("buttonEdit");
			this.buttonDelete	= (Button)this.ui.get_object("buttonDelete");
			this.buttonPrint	= (Button)this.ui.get_object("buttonPrint");
			this.buttonSubmitWorkSheet	= (Button)this.ui.get_object("buttonSubmitWorkSheet");
			this.buttonEditWorksheet	= (Button)this.ui.get_object("buttonEditWorksheet");
			this.buttonCompareWorksheets	= (Button)this.ui.get_object("buttonCompareWorksheets");
			this.comboboxStore	= (ComboBox)this.ui.get_object("comboboxStore");
			this.treeviewCounts	= (TreeView)this.ui.get_object("treeviewCounts");
			this.box1.reparent(this);
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			this.box1.expand = true;
			this.image1.pixbuf	= (SBModules.GetModule("InventoryCount") as SBGtkModule).GetPixbuf("inventory-count-icon-64x64.png");
			this.comboboxStore.model = new ListStore(2, typeof(string), typeof(string));
			var cell = new CellRendererText();
			this.comboboxStore.pack_start(cell, true);
			this.comboboxStore.set_attributes(cell, "text", 0);
			this.comboboxStore.id_column = 1;
			TreeIter iter;
			(this.comboboxStore.model as ListStore).append(out iter);
			(this.comboboxStore.model as ListStore).set(iter,
				0, SBText.__("-- store --"),
				1, "-1"
			);
			foreach(var store in InventoryHelper.GetStores())
			{
				(this.comboboxStore.model as ListStore).append(out iter);
				(this.comboboxStore.model as ListStore).set(iter,
					0, store.Name,
					1, store.Id.to_string()
				);
			}
			this.comboboxStore.active_id = "-1";
			//##build treeview
			this.treeviewCounts.model = new ListStore(Columns.N_COLS,
				typeof(int), //count
				typeof(int), //id
				typeof(string), //description
				typeof(int), //total products
				typeof(string), //status
				typeof(string) //creation date
			);
			string[,] cols = 
			{
				{SBText.__("#"), "text", "50", "center", "", ""},
				{SBText.__("ID"), "text", "50", "center", "", ""},
				{SBText.__("Description"), "text", "350", "left", "", ""},
				{SBText.__("Products"), "text", "50", "center", "", ""},
				{SBText.__("Status"), "text", "150", "center", "", ""},
				{SBText.__("Date"), "text", "150", "right", "", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewCounts);
			this.treeviewCounts.rules_hint = true;
		}
		protected void SetEvents()
		{
			this.buttonNew.clicked.connect(this.OnButtonNewClicked);
			this.buttonPrint.clicked.connect(this.OnButtonPrintClicked);
			this.buttonSubmitWorkSheet.clicked.connect(this.OnButtonSubmitWorkSheetClicked);
			this.buttonEditWorksheet.clicked.connect(this.OnButtonEditWorksheetClicked);
			this.buttonCompareWorksheets.clicked.connect(this.OnButtonCompareWorksheetsClicked);
			this.comboboxStore.changed.connect(this.OnComboBoxStoreChanged);
			
		}
		protected void OnButtonNewClicked()
		{
			var nb = (SBNotebook)SBGlobals.GetVar("notebook");
			if( nb.GetPage("new-inventory-count") == null )
			{
				var w = new WidgetNewInventoryCount();
				w.show();
				nb.AddPage("new-inventory-count", SBText.__("New Inventory Count"), w);
			}
			
			nb.SetCurrentPageById("new-inventory-count");
		}
		protected void OnButtonPrintClicked()
		{
			TreeModel model;
			TreeIter iter;
			if( !this.treeviewCounts.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			Value count_id;
			model.get_value(iter, Columns.ID, out count_id);
			
			//##create new report instance
			int font_size = 8;
			var catalog = new EPos.Catalog();
			//stdout.printf("page available width: %.2f\n", catalog.pageAvailableSpace);
			catalog.WriteText(SBText.__("Inventory Count - Worksheet"), "center", 17);
			var table = new EPos.PdfTable(catalog.pdf, 
											catalog.page, 
											catalog.font, 
											catalog.pageAvailableSpace, 
											catalog.XPos, 
											catalog.YPos);
			table.PdfCatalog = catalog;
			table.SetColumnsWidth({5,20,45,15,15});
			//##write table headers
			var cell = table.AddCell();
			cell.Border = true;
			cell.FontSize = font_size;
			cell.Align = "center";
			cell.SetText(SBText.__("No."));
			
			cell = table.AddCell();
			cell.Border = true;
			cell.FontSize = font_size;
			cell.Align = "center";
			cell.SetText(SBText.__("Code"));
			
			cell = table.AddCell();
			cell.Border = true;
			cell.FontSize = font_size;
			cell.Align = "center";
			cell.SetText(SBText.__("Product"));
			
			cell = table.AddCell();
			cell.Border = true;
			cell.FontSize = font_size;
			cell.Align = "center";
			cell.SetText(SBText.__("Units"));
			
			cell = table.AddCell();
			cell.Border = true;
			cell.FontSize = font_size;
			cell.Align = "center";
			cell.SetText(SBText.__("Case No."));
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			//dbh.Select("*").From("inventory_count_products").Where("count_id = %d".printf((int)count_id));
			string query = "SELECT * FROM inventory_count_products WHERE count_id = %d".printf((int)count_id);
			//stdout.printf("QUERY:%s\n", query);
			int i = 1;
			foreach(var item in dbh.GetResults(query))
			{
				var prod = new SBProduct.from_id(item.GetInt("product_id"));
				cell = table.AddCell();
				cell.Border = true;
				cell.FontSize = font_size;
				cell.Align = "center";
				cell.SetText("%d".printf(i));
				i++;
				
				cell = table.AddCell();
				cell.Border = true;
				cell.FontSize = font_size;
				cell.Align = "center";
				cell.SetText(prod.Code);
				
				cell = table.AddCell();
				cell.Border = true;
				cell.FontSize = font_size;
				cell.Align = "left";
				cell.SetText(prod.Name);
				
				cell = table.AddCell();
				cell.Border = true;
				cell.FontSize = font_size;
				cell.Align = "center";
				cell.SetText("");
				
				cell = table.AddCell();
				cell.Border = true;
				cell.FontSize = font_size;
				cell.Align = "center";
				cell.SetText("");
			}
			table.Draw();
			catalog.Preview("inventory-worksheet");
		}
		protected void OnButtonSubmitWorkSheetClicked()
		{
			TreeModel model;
			TreeIter iter;
			if( !this.treeviewCounts.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			Value count_id;
			model.get_value(iter, Columns.ID, out count_id);
			var nb = (SBNotebook)SBGlobals.GetVar("notebook");
			var w = new WidgetWorksheet();
			w.FillProducts((int)count_id);
			string tab_id = "worksheet-%d".printf((int)count_id);
			w.set_data<string>("tab_id", tab_id);
			nb.AddPage(tab_id, SBText.__("Inventory Worksheet"), w);
			nb.SetCurrentPageById(tab_id);
		}
		protected void OnButtonEditWorksheetClicked()
		{
			TreeModel model;
			TreeIter iter;
			if( !this.treeviewCounts.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			Value count_id;
			model.get_value(iter, Columns.ID, out count_id);
			var dlg = new DialogWorksheetSelector((int)count_id){modal = true};
			dlg.OnSelected.connect(this.OnWorksheetsSelected);
			dlg.show();
		}
		protected void OnButtonCompareWorksheetsClicked()
		{
			TreeModel model;
			TreeIter iter;
			if( !this.treeviewCounts.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			
			Value count_id;
			model.get_value(iter, Columns.ID, out count_id);
			var dlg = new DialogWorksheetSelector((int)count_id){modal = true};
			dlg.MultipleSelection = true;
			dlg.OnSelected.connect(this.OnWorksheetsCompareSelected);
			dlg.show();
		}
		protected void OnWorksheetsSelected(int count_id, int[] results)
		{
			int result_number = results[0];
			var nb = (SBNotebook)SBGlobals.GetVar("notebook");
			stdout.printf("%d => %d\n", count_id, result_number);
			string tab_id = "worksheet-result-%d".printf(result_number);
			
			if( nb.GetPage(tab_id) == null )
			{
				var w = new WidgetWorksheet();
				w.set_data<string>("tab_id", tab_id);
				w.SetWorksheet(count_id, (int)result_number);
				w.show();
				nb.AddPage(tab_id, SBText.__("Edit Inventory Worksheet"), w);
			}
			nb.SetCurrentPageById(tab_id);
		}
		protected void OnWorksheetsCompareSelected(int count_id, int[] results)
		{
			if( results.length <= 1 )
			{
				var err = new InfoDialog("error")
				{
					Title = SBText.__("Compare worksheets"),
					Message = SBText.__("You need to select atleast two worksheets.")
				};
				err.run();
				err.destroy();
				return;
			}
			var nb = (SBNotebook)SBGlobals.GetVar("notebook");
			string tab_id = "compare-worksheets";
			if( nb.GetPage(tab_id) == null )
			{
				var w = new WidgetCompareWorksheets();
				w.show();
				w.set_data<string>("tab_id", tab_id);
				nb.AddPage(tab_id, SBText.__("Compare Worksheets"), w);
				//##append worksheets
				foreach(int result_number in results)
				{
					w.AppendWorksheet(count_id, result_number);
				}
				w.CalculateResults();
			}
			nb.SetCurrentPageById(tab_id);
		}
		protected void OnComboBoxStoreChanged()
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1" )
			{
				(this.treeviewCounts.model as ListStore).clear();
				return;
			}
			int store_id = int.parse(this.comboboxStore.active_id);
			this.Refresh(store_id);
		}
		protected void Refresh(int store_id)
		{
			(this.treeviewCounts.model as ListStore).clear();
			TreeIter iter;
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("inventory_counts").Where("store_id = %d".printf(store_id)).
				OrderBy("creation_date", "DESC");
			int i = 1;
			foreach(var row in dbh.GetResults(null))
			{
				(this.treeviewCounts.model as ListStore).append(out iter);
				(this.treeviewCounts.model as ListStore).set(iter,
					Columns.COUNT, i,
					Columns.ID,	row.GetInt("count_id"),
					Columns.DESCRIPTION, row.Get("description"),
					Columns.TOTAL_PRODUCTS, 0,
					Columns.STATUS, row.Get("status"),
					Columns.CREATION_DATE, row.Get("creation_date")
				);
				i++;
			}
		}
	}
}
