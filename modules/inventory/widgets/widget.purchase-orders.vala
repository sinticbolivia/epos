using GLib;
using Gtk;
using Gee;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetPurchaseOrders : Gtk.Box
	{
		protected Builder		ui;
		protected Box			boxPurchaseOrders;
		protected Image			image1;
		protected Label			labelTitle;
		protected Button		buttonNew;
		protected Button		buttonEdit;
		protected Button        buttonReceive;
		protected Button		buttonCancel;
		protected Button		buttonPrint;
		protected	Button		buttonPreview;
		protected ComboBox		comboboxStores;
		protected ComboBox		comboboxStatus;
		protected TreeView		treeviewOrders;
		protected enum			Columns
		{
			COUNT,
			STORE,
			ITEMS,
			TOTAL,
			DELIVERY_DATE,
			STATUS,
			CREATION_DATE,
			ORDER_ID,
			N_COLS
		}
		public WidgetPurchaseOrders()
		{
			this.orientation = Orientation.VERTICAL;
			
			//this.ui = SB_ModuleInventory.GetGladeUi("purchase-orders.glade");
			this.ui = (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("purchase-orders.glade");
			this.boxPurchaseOrders		= (Box)this.ui.get_object("boxPurchaseOrders");
			this.image1					= (Image)this.ui.get_object("image1");
			this.buttonNew				= (Button)this.ui.get_object("buttonNew");
			this.buttonEdit				= (Button)this.ui.get_object("buttonEdit");
			this.buttonReceive          = (Button)this.ui.get_object("buttonReceive");
			this.buttonCancel			= (Button)this.ui.get_object("buttonCancel");
			this.buttonPrint			= (Button)this.ui.get_object("buttonPrint");
			this.buttonPreview			= (Button)this.ui.get_object("buttonPreview");
			this.comboboxStores			= (ComboBox)this.ui.get_object("comboboxStores");
			this.comboboxStatus			= (ComboBox)this.ui.get_object("comboboxStatus");
			this.treeviewOrders			= (TreeView)this.ui.get_object("treeviewOrders");
			this.boxPurchaseOrders.reparent(this);
			this.Build();
			this.FillForm();
			this.SetEvents();
			
		}
		protected void Build()
		{
			this.image1.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("purchase-order-icon-64x64.png");
			this.buttonPrint.label = "";
			this.buttonPreview.label = "";
			TreeIter iter;
			var cell0 = new CellRendererText();
			this.comboboxStores.pack_start(cell0, true);
			this.comboboxStores.add_attribute(cell0, "text", 0);
			this.comboboxStores.model = new ListStore(2, typeof(string), typeof(string));
			(this.comboboxStores.model as ListStore).append(out iter);
			(this.comboboxStores.model as ListStore).set(iter, 0, SBText.__("-- stores --"), 1 , "-1");
			this.comboboxStores.id_column = 1;
			cell0 = new CellRendererText();
			this.comboboxStatus.pack_start(cell0, true);
			this.comboboxStatus.add_attribute(cell0, "text", 0);
			this.comboboxStatus.model = new ListStore(2, typeof(string), typeof(string));
			(this.comboboxStatus.model as ListStore).append(out iter);
			(this.comboboxStatus.model as ListStore).set(iter, 0, SBText.__("-- status --"), 1 , "-1");
			this.comboboxStatus.id_column = 1;
			//##build treeview
			this.treeviewOrders.model = new ListStore(Columns.N_COLS,
				typeof(int), //count
				typeof(string), //store
				typeof(int), //items
				typeof(string), //total,
				typeof(string), //delivery date
				typeof(string), //status
				typeof(string), //creation date
				typeof(int)
			);
			string[,] columns = 
			{
				{"#", "text", "70", "center", ""},
				{SBText.__("Store"), "text", "250", "left", ""},
				{SBText.__("Items"), "text", "50", "center", ""},
				{SBText.__("Total"), "text", "50", "right", ""},
				{SBText.__("Delivery date"), "text", "130", "right", ""},
				{SBText.__("Status"), "markup", "80", "center", ""},
				{SBText.__("Creation Date"), "text", "130", "right", ""}
			};
			GtkHelper.BuildTreeViewColumns(columns, ref this.treeviewOrders);
			
			this.treeviewOrders.rules_hint = true;
			
		}
		protected void FillForm()
		{
			TreeIter iter;
			//##fill stores
			var stores = (ArrayList<SBStore>)InventoryHelper.GetStores();
			
			foreach(SBStore store in stores)
			{
				(this.comboboxStores.model as ListStore).append(out iter);
				(this.comboboxStores.model as ListStore).set(iter, 0, store.Name, 1, store.Id.to_string());
			}
			this.comboboxStores.active_id = "-1";
			string[,] statuses = 
			{
			    {SBText.__("Waiting Orders"), "waiting"},
			    {SBText.__("Completed Orders"), "completed"},
			    {SBText.__("Cancelled Orders"), "cancelled"},
			};
			for(int i = 0; i < statuses.length[0]; i++)
			{
			    (this.comboboxStatus.model as ListStore).append(out iter);
			    (this.comboboxStatus.model as ListStore).set(iter, 0, statuses[i,0], 1, statuses[i,1]);
			}
			this.comboboxStatus.active_id = "-1";
		}
		protected void SetEvents()
		{
		    this.comboboxStores.changed.connect(this.OnComboBoxStoresChanged);
		    this.comboboxStatus.changed.connect(this.OnComboBoxStatusChanged);
			this.buttonNew.clicked.connect(this.OnButtonNewClicked);
			this.buttonEdit.clicked.connect(this.OnButtonEditClicked);
			this.buttonReceive.clicked.connect(this.OnButtonReceiveClicked);
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
			this.buttonPreview.clicked.connect(this.OnButtonPreviewClicked);
		}
		protected void OnComboBoxStoresChanged()
		{
		    if( this.comboboxStores.active_id == null || this.comboboxStores.active_id == "-1")
		    {
		        (this.treeviewOrders.model as ListStore).clear();
		        return;
		    }
		    int store_id = int.parse(this.comboboxStores.active_id);
		    string? status = null;
		    if( this.comboboxStatus.active_id != null & this.comboboxStatus.active_id != "-1")
		    {
		        status = this.comboboxStatus.active_id;
		    }
		    this.GetOrders(store_id, status);
		}
		protected void OnComboBoxStatusChanged()
		{
		    if( this.comboboxStores.active_id == null || this.comboboxStores.active_id == "-1")
		    {
		        (this.treeviewOrders.model as ListStore).clear();
		        return;
		    }
		    int store_id = int.parse(this.comboboxStores.active_id);
		    string? status = null;
		    if( this.comboboxStatus.active_id != "-1")
		    {
		        status = this.comboboxStatus.active_id;
		    }
		    this.GetOrders(store_id, status);
		}
		protected void OnButtonNewClicked()
		{
			
			var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
			if( notebook.GetPage("new-purchase-order") == null )
			{
				var w = new WidgetPurchaseOrder();
				w.show();
				notebook.AddPage("new-purchase-order", SBText.__("Purchase Order"), w);
			}
			notebook.SetCurrentPageById("new-purchase-order");
		}
		protected void OnButtonEditClicked()
		{
		    TreeModel model;
		    TreeIter iter;
		    
		    if( !this.treeviewOrders.get_selection().get_selected(out model, out iter) )
		    {
		        return;
		    }
		    Value v_oid;
		    model.get_value(iter, Columns.ORDER_ID, out v_oid);
		    var order = new PurchaseOrder.from_id((int)v_oid);
		    var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
			if( notebook.GetPage("edit-purchase-order") == null )
			{
				var w = new WidgetPurchaseOrder(){Title = SBText.__("Edit Purchase Order")};
				w.SetOrder(order);
				w.show();
				notebook.AddPage("edit-purchase-order", SBText.__("Edit Purchase Order"), w);
			}
			notebook.SetCurrentPageById("edit-purchase-order");
		}
		protected void OnButtonReceiveClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewOrders.get_selection().get_selected(out model, out iter) )
			{
				var err = new InfoDialog("error")
				{
					Title = SBText.__("Preview error"),
					Message = SBText.__("You need to select a purchase order.")
				};
				err.run();
				err.destroy();
				return;
			}
			Value order_id;
			model.get_value(iter, Columns.ORDER_ID, out order_id);
			var order = new PurchaseOrder.from_id((int)order_id);
			var nb = (SBNotebook)SBGlobals.GetVar("notebook");
			var w = new EPos.WidgetReceivePurchaseOrder(order);
			w.show();
			string tab_id = "receive-purchase-order-%d".printf(order.Id);
			nb.AddPage(tab_id, SBText.__("Receive Order"), w);
			nb.SetCurrentPageById(tab_id);
		}
		protected void OnButtonCancelClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewOrders.get_selection().get_selected(out model, out iter) )
			{
				var err = new InfoDialog("error")
				{
					Title = SBText.__("Cancel order error"),
					Message = SBText.__("You need to select an order.")
				};
				err.run();
				err.destroy();
				return;
			}
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			Value order_id;
			model.get_value(iter, Columns.ORDER_ID, out order_id);
			var confirm = new InfoDialog("info")
			{
				Title = SBText.__("Cancel order"),
				Message = SBText.__("Are you sure to cancel the order?")
			};
			var btn = (Button)confirm.add_button(SBText.__("Yes"), ResponseType.YES);
			btn.get_style_context().add_class("button-green");
			if( confirm.run() == ResponseType.YES )
			{
				var data = new HashMap<string, Value?>();
				data.set("status", "cancelled");
				var w = new HashMap<string, Value?>();
				w.set("order_id", (int)order_id);
				dbh.Update("purchase_orders", data, w);
			}
			confirm.destroy();
			this.RefreshOrders();
		}
		protected void OnButtonPreviewClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewOrders.get_selection().get_selected(out model, out iter) )
			{
				var err = new InfoDialog("error")
				{
					Title = SBText.__("Preview error"),
					Message = SBText.__("You need to select atleast one purchase order.")
				};
				err.run();
				err.destroy();
				return;
			}
			Value order_id;
			model.get_value(iter, Columns.ORDER_ID, out order_id);
			//##get company data
			string company_data = SBParameter.Get("company");
			HashMap<string, string> company = SinticBolivia.Utils.JsonDecode(company_data);
			
			var order = new PurchaseOrder.from_id((int)order_id);
			float font_size = 8;
			
			//##create new report instance
			var catalog = new EPos.Catalog();
			//stdout.printf("page available width: %.2f\n", catalog.pageAvailableSpace);
			catalog.WriteText(SBText.__("Purchase Order"), "center", 17);
			
			var table = new EPos.PdfTable(catalog.pdf, 
											catalog.page, 
											catalog.font, 
											catalog.pageAvailableSpace, 
											catalog.XPos, 
											catalog.YPos);
			table.SetColumnsWidth({25,50,25});
			
			string nums = "%s (P), %s (P), %s (F)".
							printf((company.has_key("phone_1")) ? (string)company["phone_1"] : "", 
									(company.has_key("phone_2")) ? (string)company["phone_2"] : "", 
									(company.has_key("fax")) ? (string)company["fax"] : "");
									
			string company_info = "%s\n%s\n\n%s\n%s".
									printf((company.has_key("company")) ? (string)company["company"] : "", 
											(company.has_key("address")) ? (string)company["address"] : "", 
											nums, 
											(company.has_key("email")) ? (string)company["email"] : "");
									
			string order_data = "PO#: %s\n".printf(order.Code);
			order_data += "Page: Page 0 of 0\n"+
								"Order date: date here\n"+
								"Delivery date: date here\n"+
								"Cancel date: date here\n"+
								"Terms code: xxxx";
			
			string logo_path = "images/%s".printf((company.has_key("logo")) ? (string)company["logo"] : "share/images/company_logo.png");
			
			if( !FileUtils.test(logo_path, FileTest.EXISTS) )
				logo_path = "share/images/logo.png";
				
			string[] logo_parts = SBFileHelper.GetParts(logo_path);
			HPDF.Image? logo_img = null;
			
			if( logo_parts[1] == "jpg" || logo_parts[1] == "jpeg" )
				logo_img = catalog.pdf.LoadJpegImageFromFile(SBFileHelper.SanitizePath(logo_path));
			else if( logo_parts[1] == "png" )
				logo_img = catalog.pdf.LoadPngImageFromFile(SBFileHelper.SanitizePath(logo_path));
				
			var cell = table.AddCell();
			cell.Border = false;
			//cell.FontSize = 6;
			cell.SetImage(logo_img);
			
			cell = table.AddCell();
			cell.Border = false;
			cell.FontSize = font_size;
			cell.SetText(company_info);
			
			cell = table.AddCell();
			cell.Border = false;
			cell.FontSize = font_size;
			cell.SetText(order_data);
			
			table.Draw();
			
			var table1 = new EPos.PdfTable(catalog.pdf, catalog.page, catalog.font, 
											catalog.pageAvailableSpace, 
											catalog.XPos, 
											catalog.YPos - table.Height - 10);
			table1.SetColumnsWidth({5,45,5,45});
			cell = table1.AddCell();
			cell.FontSize = font_size;
			cell.SetText("To:");
			cell = table1.AddCell();
			cell.FontSize = font_size;
			cell.SetText("MR EASTON BENNETT\nCOBBLA P.A\nMANCHESTER");
			cell = table1.AddCell();
			cell.FontSize = font_size;
			cell.SetText("Ship To:");
			cell = table1.AddCell();
			cell.FontSize = font_size;
			cell.SetText("MAIN STORE\n233 MARCUS GARVEY DRIVE\nKINGSTON 11");
			table1.Draw();
			
			
			//##details table
			var details_table = new EPos.PdfTable(catalog.pdf, catalog.page, catalog.font, 
													catalog.pageAvailableSpace, 
													catalog.XPos, 
													catalog.YPos - table.Height - 10 - table1.Height - 10);
													
			details_table.SetColumnsWidth({12.5f, 50, 12.5f, 12.5f, 12.5f});		
											
			cell 			= details_table.AddCell();
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.SetText(SBText.__("Item #"));
			
			cell 			= details_table.AddCell();
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.SetText(SBText.__("Description\n Vendor's Description"));
			
			cell 			= details_table.AddCell();
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.Align		= "center";
			cell.SetText(SBText.__("Quantity"));
			
			cell 			= details_table.AddCell();
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.Align		= "center";
			cell.SetText(SBText.__("U.O.M"));
			
			cell 			= details_table.AddCell();
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.Align		= "center";
			cell.SetText(SBText.__("Ext. Cost"));
			
			foreach(var item in order.Items)
			{
				var prod 		= new SBProduct.from_id(item.GetInt("product_id"));
				cell 			= details_table.AddCell();
				cell.FontSize 	= font_size;
				cell.Border		= false;
				cell.SetText(prod.Code);
				
				cell 			= details_table.AddCell();
				cell.FontSize 	= font_size;
				cell.Border		= false;
				cell.SetText(prod.Name);
				
				cell 			= details_table.AddCell();
				cell.FontSize 	= font_size;
				cell.Border		= false;
				cell.Align		= "center";
				cell.SetText(item.Get("quantity"));
				
				cell 			= details_table.AddCell();
				cell.FontSize 	= font_size;
				cell.Border		= false;
				cell.SetText("");
				
				cell 			= details_table.AddCell();
				cell.FontSize 	= font_size;
				cell.Border		= false;
				cell.Align		= "right";
				cell.SetText("%.2f".printf(item.GetDouble("total")));
			}
			
			cell 			= details_table.AddCell();
			cell.Span		= 4;
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.Align		= "right";
			cell.SetText(SBText.__("Subtotal:"));
			
			cell 			= details_table.AddCell();
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.Align		= "right";
			cell.SetText("%.2f".printf(order.SubTotal));
			
			cell 			= details_table.AddCell();
			cell.Span		= 4;
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.Align		= "right";
			cell.SetText(SBText.__("Sales Tax:"));
			
			cell 			= details_table.AddCell();
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.Align		= "right";
			cell.SetText("%.2f".printf(order.TaxTotal));
			
			cell 			= details_table.AddCell();
			cell.Span		= 4;
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.Align		= "right";
			cell.SetText(SBText.__("Total:"));
			
			cell 			= details_table.AddCell();
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.Align		= "right";
			cell.SetText("%.2f".printf(order.Total));
			
			details_table.Draw();
			
			//catalog.Save();			
			catalog.Preview();
		}
		protected void RefreshOrders()
		{
			if( this.comboboxStores.active_id == null || this.comboboxStores.active_id == "-1")
		    {
		        (this.treeviewOrders.model as ListStore).clear();
		        return;
		    }
		    int store_id = int.parse(this.comboboxStores.active_id);
		    string? status = null;
		    if( this.comboboxStatus.active_id != "-1")
		    {
		        status = this.comboboxStatus.active_id;
		    }
		    this.GetOrders(store_id, status);
		}
		protected void GetOrders(int store_id, string? status = null, int page = 1, int limit = 100)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT o.*, s.store_name "+
			                "FROM purchase_orders o, stores s "+
							"WHERE o.store_id = %d "+
							"AND o.store_id = s.store_id ";
			if( status != null )
			{
			    query += "AND o.status = '%s' ".printf(status);
			}
							
			query += "ORDER BY o.creation_date DESC";
			query = query.printf(store_id);
			stdout.printf("%s\n", query);
			var rows = (ArrayList<SBDBRow>)dbh.GetResults(query);
			(this.treeviewOrders.model as ListStore).clear();
			TreeIter iter;
			int i = 1;
			foreach(var row in rows)
			{
			    string _status = row.Get("status");
			    string status_color = "#000";
			    if(_status == "waiting")
			    {
			        status_color = "#e0e470";
			    }
			    else if(_status == "received")
			    {
			        status_color = "#64ae51";
			    }
			    else if(_status == "cancelled")
			    {
			        status_color = "red";
			    }
				(this.treeviewOrders.model as ListStore).append(out iter);
				(this.treeviewOrders.model as ListStore).set(iter,
				    Columns.COUNT, i,
				    Columns.STORE, row.Get("store_name"),
				    Columns.ITEMS, row.GetInt("items"),
				    Columns.TOTAL, "%.2f".printf(row.GetDouble("total")),
				    Columns.DELIVERY_DATE, row.Get("delivery_date"),
				    Columns.STATUS, "<span color=\"%s\" font_weight=\"bold\">%s</span>".printf(status_color, _status),
				    Columns.CREATION_DATE, row.Get("creation_date"),
				    Columns.ORDER_ID, row.GetInt("order_id")
				);
				i++;
			}
		}
	}
}
