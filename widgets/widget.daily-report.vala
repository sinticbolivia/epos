using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Database;
using SinticBolivia.Gtk;

namespace EPos
{
	public class WidgetDailyReport : Box
	{
		protected	enum		Columns
		{
			NUM,
			PRODUCT_ID,
			PRODUCT_NAME,
			PRODUCT_QTY,
			PRODUCT_PRICE,
			TOTAL_PRODUCT_SALES,
			NUM_COLS
		}
		protected	Box			boxHead;
		protected	Image		imageHead;
		protected 	Label		labelTitle;
		protected	Box			boxButtons;
		protected	Box			boxFilters;
		protected	Box			boxTotals;
		protected	ComboBox		comboboxStore;
		protected	SBDatePicker	datepicker;
		protected	Button		buttonBuildReport;
		protected	Button		buttonPrint;
		protected	Button		buttonExport2Excel;
		protected	TreeView	treeviewItems;
		protected	Grid		gridTotals;
		protected	Label		labelTotalProducts;
		protected	Label		labelTotalSales;
		protected	Entry		entryTotalProducts;
		protected	Entry		entryTotalSales;
		
		public WidgetDailyReport()
		{
			this.orientation = Orientation.VERTICAL;
			this.spacing = 5;
			
			this.boxHead		= new Box(Orientation.HORIZONTAL, 5);
			this.imageHead		= new Image.from_file(SBFileHelper.SanitizePath("share/images/reports-icon-64x64.png"));
			this.labelTitle		= new Label("<span size=\"15000\">" + SBText.__("Daily Report") + "</span>")
			{
				use_markup = true
			};
			this.boxButtons		= new Box(Orientation.HORIZONTAL, 3);
			this.boxFilters		= new Box(Orientation.HORIZONTAL, 3){homogeneous = false, expand = false};
			this.boxTotals		= new Box(Orientation.HORIZONTAL, 3);
			this.boxTotals.show();
			this.comboboxStore  = new ComboBox(){expand = false,vexpand = false, hexpand=false, valign = Gtk.Align.START};
			
			this.datepicker		= new SBDatePicker();
			this.datepicker.Icon = GtkHelper.GetPixbuf("share/images/calendar-icon-16x16.png");
			this.datepicker.show();
			this.buttonBuildReport	= new Button.with_label(SBText.__("Build Report"))
			{
				expand = false,
				vexpand = false, 
				hexpand=false,
				valign = Gtk.Align.START
			};
			this.buttonBuildReport.show();
			this.buttonPrint		= new Button();
			this.buttonPrint.image	= new Image.from_file(SBFileHelper.SanitizePath("share/images/excel-48x48.png"));
			this.buttonPrint.show();
			this.buttonExport2Excel			= new Button();
			this.buttonExport2Excel.image	= new Image.from_file(SBFileHelper.SanitizePath("share/images/print-icon-48x48.png"));
			this.buttonExport2Excel.show();
			
			this.treeviewItems	= new TreeView(){rules_hint = true};
			this.treeviewItems.show();
			this.gridTotals		= new Grid();
			this.labelTotalProducts	= new Label(SBText.__("Total Products:")){xalign = 1f};
			this.labelTotalSales	= new Label(SBText.__("Total Sales:")){xalign = 1f};
			this.entryTotalProducts = new Entry(){xalign = 1f};
			this.entryTotalSales	= new Entry(){xalign = 1f};
			
			//##build head
			this.boxHead.add(this.imageHead);
			this.boxHead.add(this.labelTitle);
			this.boxHead.show_all();
			//##build filters
			this.boxFilters.add(this.comboboxStore);
			this.boxFilters.add(this.datepicker);
			this.boxFilters.add(this.buttonBuildReport);
			this.boxFilters.add(this.buttonPrint);
			this.boxFilters.add(this.buttonExport2Excel);
			this.boxFilters.show_all();
			//##build totals
			this.gridTotals.attach(this.labelTotalProducts, 0, 0, 1, 1);
			this.gridTotals.attach(this.labelTotalSales, 0, 1, 1, 1);
			this.gridTotals.attach(this.entryTotalProducts, 1, 0, 1, 1);
			this.gridTotals.attach(this.entryTotalSales, 1, 1, 1, 1);
			this.gridTotals.show_all();
			
			this.boxTotals.pack_end(this.gridTotals);
			this.boxTotals.set_child_packing(this.gridTotals, false, false, 0, PackType.END);
			this.add(boxHead);
			this.add(boxFilters);
			var scroll = new ScrolledWindow(null, null){expand = true};
			scroll.add_with_viewport(this.treeviewItems);
			scroll.show();
			this.add(scroll);
			this.add(this.boxTotals);
			
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			var cell = new CellRendererText();
			this.comboboxStore.pack_start(cell, false);
			this.comboboxStore.set_attributes(cell, "text", 0);
			this.comboboxStore.model = new ListStore(2, typeof(string), typeof(string));
			this.comboboxStore.id_column = 1;
			//##build treeview model
			this.treeviewItems.model = new ListStore(Columns.NUM_COLS, 
					typeof(int), 
					typeof(int), //product id
					typeof(string), //product name
					typeof(int), //quantity
					typeof(string), //price
					typeof(string) //total product sales
			);
			//##build treeview columns
			this.treeviewItems.insert_column_with_attributes(Columns.NUM,
				SBText.__("#"),
				new CellRendererText(){width = 70, xalign = 0.5f},
				"text",
				Columns.NUM
			);
			this.treeviewItems.insert_column_with_attributes(Columns.PRODUCT_ID,
				SBText.__("ID"),
				new CellRendererText(){width = 70, xalign = 0.5f},
				"text",
				Columns.PRODUCT_ID
			);
			this.treeviewItems.insert_column_with_attributes(Columns.PRODUCT_NAME,
				SBText.__("Product"),
				new CellRendererText(){width = 200, xalign = 0f},
				"text",
				Columns.PRODUCT_NAME
			);
			this.treeviewItems.insert_column_with_attributes(Columns.PRODUCT_QTY,
				SBText.__("Quantity"),
				new CellRendererText(){width = 70, xalign = 0.5f},
				"text",
				Columns.PRODUCT_QTY
			);
			this.treeviewItems.insert_column_with_attributes(Columns.PRODUCT_PRICE,
				SBText.__("Sale Price (AVG)"),
				new CellRendererText(){width = 70, xalign = 1f},
				"text",
				Columns.PRODUCT_PRICE
			);
			this.treeviewItems.insert_column_with_attributes(Columns.TOTAL_PRODUCT_SALES,
				SBText.__("Total"),
				new CellRendererText(){width = 100, xalign = 1f},
				"text",
				Columns.TOTAL_PRODUCT_SALES
			);
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			//##fill stores
			TreeIter iter;
			(this.comboboxStore.model as ListStore).append(out iter);
			(this.comboboxStore.model as ListStore).set(iter, 0, SBText.__("-- store --"), 1, "-1");
			this.comboboxStore.active_id = "-1";
			string query = "SELECT * FROM stores ORDER BY store_name ASC";
			
			var rows = dbh.GetResults(query);
			if(rows.size > 0 )
			{
				foreach(var row in rows)
				{
					var store = new SBStore();
					store.SetDbData(row);
					(this.comboboxStore.model as ListStore).append(out iter);
					(this.comboboxStore.model as ListStore).set(iter, 0, store.Name, 1, store.Id.to_string());
				}
			}
		}
		protected void SetEvents()
		{
			this.buttonBuildReport.clicked.connect(this.OnButtonBuildReportClicked);
			this.buttonPrint.clicked.connect(this.OnButtonPrintClicked);
			this.buttonExport2Excel.clicked.connect(this.OnButtonExport2ExcelClicked);
		}
		protected void OnButtonBuildReportClicked()
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1")
			{
				return;
			}
			int store_id = int.parse(this.comboboxStore.active_id);
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string date = this.datepicker.DateString;
			string query = "SELECT transaction_id FROM transactions "+
							"WHERE status = 'sold' "+
							"AND store_id = %d "+
							"AND DATE(creation_date) = '%s'";
			query = query.printf(store_id, date);
			var rows = dbh.GetResults(query);
			if( rows.size <= 0 )
			{
				var msg = new MessageDialog(null, DialogFlags.MODAL, MessageType.INFO, ButtonsType.OK, 
				SBText.__("There are no sales register on that date."));
				msg.run();
				msg.destroy();
				return;
			}
			string report_q = "SELECT object_id, p.product_name, sum(object_quantity) AS quantity, AVG(object_price) AS price, SUM(total) AS total "+
								"FROM transaction_items ti, products p "+
								"WHERE transaction_id IN(%s) "+
								"AND object_id = p.product_id "+
								"GROUP BY object_id";
			report_q = report_q.printf(query);
			stdout.printf("query: %s\n", report_q);
			var items = dbh.GetResults(report_q);
			(this.treeviewItems.model as ListStore).clear();
			TreeIter iter;
			int i = 1;
			double total_sales = 0;
			int total_products = 0;
			foreach(var row in items)
			{
				(this.treeviewItems.model as ListStore).append(out iter);
				(this.treeviewItems.model as ListStore).set(iter, 
						Columns.NUM, i,
						Columns.PRODUCT_ID, row.GetInt("object_id"),
						Columns.PRODUCT_NAME, row.Get("product_name"),
						Columns.PRODUCT_QTY, row.GetInt("quantity"),
						Columns.PRODUCT_PRICE, "%.2lf".printf(row.GetDouble("price")),
						Columns.TOTAL_PRODUCT_SALES, "%.2lf".printf(row.GetDouble("total"))
				);
				total_products += row.GetInt("quantity");
				total_sales += row.GetDouble("total");
				i++;
			}
			this.entryTotalProducts.text = total_products.to_string();
			this.entryTotalSales.text = "%.2lf".printf(total_sales);
		}
		protected void OnButtonPrintClicked()
		{
			
		}
		protected void OnButtonExport2ExcelClicked()
		{
		}
	}
}
