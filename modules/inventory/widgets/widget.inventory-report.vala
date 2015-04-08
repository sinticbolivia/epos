using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Gtk;
using Gtk;

namespace EPos
{
	class WidgetInventoryReport : Gtk.Box
	{
		protected Builder 	ui;
		protected Window	windowInventoryReport;
		protected Box		boxInventoryReport;
		protected Image		imageTitle;
		protected Label		labelTotalCost;
		protected Label		labelTotalProducts;
		protected ComboBox	comboboxStores;
		protected Button	buttonExport2Excel;
		protected Button	buttonPrint;
		protected TreeView	treeviewProducts;
		
		public WidgetInventoryReport()
		{
			//this.ui = SB_ModuleInventory.GetGladeUi("inventory-report.glade");
			this.ui = (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("inventory-report.glade");
			//##get widget
			this.windowInventoryReport	= (Window)this.ui.get_object("windowInventoryReport");
			this.boxInventoryReport		= (Box)this.ui.get_object("boxInventoryReport");
			this.imageTitle				= (Image)this.ui.get_object("imageTitle");
			this.labelTotalCost			= (Label)this.ui.get_object("labelTotalCost");
			this.labelTotalProducts		= (Label)this.ui.get_object("labelTotalProducts");
			this.comboboxStores			= (ComboBox)this.ui.get_object("comboboxStores");
			this.buttonExport2Excel		= (Button)this.ui.get_object("buttonExport2Excel");
			this.buttonPrint			= (Button)this.ui.get_object("buttonPrint");
			this.treeviewProducts		= (TreeView)this.ui.get_object("treeviewProducts");
			this.Build();
			this.SetEvents();
			this.boxInventoryReport.reparent(this);
		}
		protected void Build()
		{
			
			Gdk.Pixbuf pixbuf0 = null, pixbuf1 = null;
			try
			{
				/*
				var input_stream = SB_ModuleInventory.res_data.open_stream("/net/sinticbolivia/Inventory/images/inventory-report-icon-64x64.png", 
																		ResourceLookupFlags.NONE);
				*/
				this.imageTitle.pixbuf	= (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("inventory-report-icon-64x64.png");//new Gdk.Pixbuf.from_stream(input_stream);
				/*
				input_stream = SB_ModuleInventory.res_data.open_stream("/net/sinticbolivia/Inventory/images/excel-icon-24x24.png", 
																		ResourceLookupFlags.NONE);
				*/
				this.buttonExport2Excel.image = new Image.from_pixbuf((SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("excel-icon-24x24.png")/*new Gdk.Pixbuf.from_stream(input_stream)*/);
					
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			this.comboboxStores.model = new ListStore(2, typeof(string), typeof(string));
			this.comboboxStores.id_column = 1;
			var cell = new CellRendererText();
			this.comboboxStores.pack_start(cell, false);
			this.comboboxStores.set_attributes(cell, "text", 0);
			TreeIter iter;
			(this.comboboxStores.model as ListStore).append(out iter);
			(this.comboboxStores.model as ListStore).set(iter, 0, SBText.__("-- store --"), 1, "-1");
			this.comboboxStores.active_id = "-1";
			//##fill stores
			foreach(var store in InventoryHelper.GetStores())
			{
				(this.comboboxStores.model as ListStore).append(out iter);
				(this.comboboxStores.model as ListStore).set(iter, 0, store.Name, 1, store.Id.to_string());
			}
			this.buttonExport2Excel.label = "";
			//##build treeview
			this.treeviewProducts.rules_hint = true;
			this.treeviewProducts.model = new ListStore(7,
				typeof(int), //count
				typeof(string), //code
				typeof(string), //product name
				typeof(string), //cost
				typeof(string), //price
				typeof(int), //existence
				typeof(int) //min quantity
			);
			string[,] columns = 
			{
				{"#", "text", "70", "center"},
				{SBText.__("Code"), "text", "80", "left"},
				{SBText.__("Product"), "text", "250", "left"},
				{SBText.__("Cost"), "text", "70", "right"},
				{SBText.__("Price"), "text", "70", "right"},
				{SBText.__("Existence"), "text", "70", "center"},
				{SBText.__("Min. Qty"), "text", "70", "center"}
			};
			/*
			foreach(string row in columns)
			{
				stdout.printf("%s\n", row);
			}
			*/
			for(int i = 0; i < columns.length[0]; i++)
			{
				float align = 0f;
				if( columns[i,3] == "center" ) align = 0.5f;
				if( columns[i,3] == "right" ) align = 1f;
				var the_cell = new CellRendererText(){width = int.parse(columns[i,2]), xalign = align};
				
				this.treeviewProducts.insert_column_with_attributes(
					i,
					columns[i,0],
					the_cell,
					columns[i,1],
					i
				);
				
			}
		}
		protected void SetEvents()
		{
			this.comboboxStores.changed.connect(this.OnComboBoxStoresChanged);
			this.buttonExport2Excel.clicked.connect(this.OnButtonExport2ExcelClicked);
		}
		protected void OnComboBoxStoresChanged()
		{
			if( this.comboboxStores.active_id == null )
				return;
			if( this.comboboxStores.active_id == "-1" )
				return;
			TreeIter iter;
			
			(this.treeviewProducts.model as ListStore).clear();
			
			int store_id = int.parse(this.comboboxStores.active_id);
			long total_prods = 0;
			var prods = InventoryHelper.GetStoreProducts(store_id, 1, -1, out total_prods);
			int i = 1;
			
			double total_cost = 0f;
			foreach(var p in prods)
			{
				total_cost += p.Cost * p.Quantity;
				(this.treeviewProducts.model as ListStore).append(out iter);
				(this.treeviewProducts.model as ListStore).set(iter, 
					0, i,
					1, p.Code,
					2, p.Name,
					3, "%.2f".printf(p.Cost),
					4, "%.2f".printf(p.Price),
					5, p.Quantity,
					6, p.MinStock
				);
				i++;
			}
			this.labelTotalProducts.set_markup("<span size=\"12000\">"+total_prods.to_string()+"</span>");
			this.labelTotalCost.set_markup("<span size=\"12000\">%.2f %s</span>".printf(total_cost, "$"));
		}
		protected void OnButtonExport2ExcelClicked()
		{
			if( this.comboboxStores.active_id == null )
				return;
			if( this.comboboxStores.active_id == "-1" )
				return;
				
			string xls_file = "inventory-report-%s.xlsx".printf(new DateTime.now_local().format("%Y-%m-%d"));
			var wb = new Excel.Workbook(xls_file);
			var sheet = wb.AddWorkSheet("inventory");
			var format = wb.AddFormat();
			format.SetBold();
			format.SetFontColor(Excel.Format.DefinedColors.LXW_COLOR_WHITE);
			format.SetBgColor(Excel.Format.DefinedColors.LXW_COLOR_BLUE);
			format.SetAlign(Excel.Format.Alignments.LXW_ALIGN_CENTER);
			
			int store_id = int.parse(this.comboboxStores.active_id);
			long total_prods = 0;
			var prods = InventoryHelper.GetStoreProducts(store_id, 1, -1, out total_prods);
			int row = 0;
			double total_cost = 0;
			int total_qty = 0;
			//write headers
			sheet.WriteString(row, 0, SBText.__("Code"), format);
			sheet.WriteString(row, 1, SBText.__("Product"), format);
			sheet.WriteString(row, 2, SBText.__("Cost"), format);
			sheet.WriteString(row, 3, SBText.__("Price"), format);
			sheet.WriteString(row, 4, SBText.__("Existence"), format);
			sheet.WriteString(row, 5, SBText.__("Min. Qty"), format);
			row++;
			foreach(var p in prods)
			{
				sheet.WriteString(row, 0, p.Code, null);
				sheet.WriteString(row, 1, p.Name, null);
				sheet.WriteString(row, 2, "%.2f".printf(p.Cost), null);
				sheet.WriteString(row, 3, "%.2f".printf(p.Price), null);
				sheet.WriteNumber(row, 4, p.Quantity);
				sheet.WriteNumber(row, 5, p.MinStock);
				total_cost += p.Cost * p.Quantity;
				total_qty += p.Quantity;
				row++;
			}
			sheet.WriteString(row, 0, SBText.__("Total"), format);
			sheet.WriteString(row, 1, "");
			sheet.WriteNumber(row, 2, total_cost, format);
			sheet.WriteString(row, 3, "");
			sheet.WriteNumber(row, 4, total_qty, format);
			sheet.WriteString(row, 5, "");
			wb.Close();
			if( SBOS.GetOS().IsLinux() )
			{
				Posix.system("xdg-open %s &".printf(xls_file));
				//Posix.execvp("/usr/bin/xdg-open", {"./" + xls_file});
			}
			else if( SBOS.GetOS().IsWindows() )
			{
			}
		}
	}
}
