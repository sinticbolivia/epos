using GLib;
using Gtk;
using Gee;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetQuotes : Gtk.Box
	{
		protected Builder		ui;
		protected Box			boxQuotes;
		protected Image			image1;
		protected Label			labelTitle;
		protected Button		buttonNew;
		protected Button		buttonEdit;
		protected Button        buttonDelete;
		protected Button		buttonPrint;
		protected Button		buttonPreview;
		protected ComboBox		comboboxStores;
		protected ComboBox		comboboxStatus;
		protected TreeView		treeviewQuotes;
		protected enum			Columns
		{
			COUNT,
			QUOTE_ID,
			CODE,
			ITEMS,
			TOTAL,
			STATUS,
			CREATION_DATE,
			EXPIRATION_DATE,
			N_COLS
		}
		public WidgetQuotes()
		{
			this.orientation = Orientation.VERTICAL;
			
			this.ui = (SBModules.GetModule("Quotes") as SBGtkModule).GetGladeUi("quotes.glade");
			this.boxQuotes				= (Box)this.ui.get_object("boxQuotes");
			this.image1					= (Image)this.ui.get_object("image1");
			this.buttonNew				= (Button)this.ui.get_object("buttonNew");
			this.buttonEdit				= (Button)this.ui.get_object("buttonEdit");
			this.buttonDelete          = (Button)this.ui.get_object("buttonDelete");
			this.buttonPrint			= (Button)this.ui.get_object("buttonPrint");
			this.buttonPreview			= (Button)this.ui.get_object("buttonPreview");
			this.comboboxStores			= (ComboBox)this.ui.get_object("comboboxStores");
			this.comboboxStatus			= (ComboBox)this.ui.get_object("comboboxStatus");
			this.treeviewQuotes			= (TreeView)this.ui.get_object("treeviewQuotes");
			this.boxQuotes.reparent(this);
			this.Build();
			this.FillForm();
			this.SetEvents();
			
		}
		protected void Build()
		{
			this.image1.pixbuf = (SBModules.GetModule("Quotes") as SBGtkModule).GetPixbuf("quote-52x64.png");
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
			this.treeviewQuotes.model = new ListStore(Columns.N_COLS,
				typeof(int), //count
				typeof(int), //quote id
				typeof(string), //code
				typeof(int), //items
				typeof(string), //total,
				typeof(string), //status
				typeof(string), //creation date
				typeof(string) //expiration date
			);
			string[,] columns = 
			{
				{"#", "text", "70", "center", "", ""},
				{SBText.__("ID"), "text", "70", "center", "", ""},
				{SBText.__("Code"), "text", "120", "left", "", ""},
				{SBText.__("Items"), "text", "50", "center", "", ""},
				{SBText.__("Total"), "text", "90", "right", "", ""},
				{SBText.__("Status"), "markup", "80", "center", "", ""},
				{SBText.__("Creation Date"), "text", "130", "right", "", ""},
				{SBText.__("Expiration date"), "text", "130", "right", "", ""}				
			};
			GtkHelper.BuildTreeViewColumns(columns, ref this.treeviewQuotes);
			this.treeviewQuotes.rules_hint = true;
			
		}
		protected void FillForm()
		{
			TreeIter iter;
			//##fill stores
			var stores = EPosHelper.GetStores();
			
			foreach(var store in stores)
			{
				(this.comboboxStores.model as ListStore).append(out iter);
				(this.comboboxStores.model as ListStore).set(iter, 0, store.Name, 1, store.Id.to_string());
			}
			this.comboboxStores.active_id = "-1";
			string[,] statuses = 
			{
			    {SBText.__("Created"), "created"},
			    {SBText.__("Completed"), "completed"},
			    {SBText.__("Expired"), "expired"},
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
			this.buttonDelete.clicked.connect(this.OnButtonDeleteClicked);
			this.buttonPreview.clicked.connect(this.OnButtonPreviewClicked);
		}
		protected void OnComboBoxStoresChanged()
		{
		    if( this.comboboxStores.active_id == null || this.comboboxStores.active_id == "-1")
		    {
		        (this.treeviewQuotes.model as ListStore).clear();
		        return;
		    }
		    int store_id = int.parse(this.comboboxStores.active_id);
		    string? status = null;
		    if( this.comboboxStatus.active_id != null & this.comboboxStatus.active_id != "-1")
		    {
		        status = this.comboboxStatus.active_id;
		    }
		    this.GetQuotes(store_id, status);
		}
		protected void OnComboBoxStatusChanged()
		{
		    if( this.comboboxStores.active_id == null || this.comboboxStores.active_id == "-1")
		    {
		        (this.treeviewQuotes.model as ListStore).clear();
		        return;
		    }
		    int store_id = int.parse(this.comboboxStores.active_id);
		    string? status = null;
		    if( this.comboboxStatus.active_id != "-1")
		    {
		        status = this.comboboxStatus.active_id;
		    }
		    this.GetQuotes(store_id, status);
		}
		protected void OnButtonNewClicked()
		{
			var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
			string tab_id = "new-quote";
			if( notebook.GetPage(tab_id) == null )
			{
				var w = new WidgetNewQuote();
				w.set_data<string>("tab_id", tab_id);
				w.show();
				notebook.AddPage(tab_id, SBText.__("New Quote"), w);
			}
			notebook.SetCurrentPageById(tab_id);
		}
		protected void OnButtonEditClicked()
		{
		    TreeModel model;
		    TreeIter iter;
		    
		    if( !this.treeviewQuotes.get_selection().get_selected(out model, out iter) )
		    {
		        return;
		    }
		    Value v_id;
		    model.get_value(iter, Columns.QUOTE_ID, out v_id);
		    /*
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
			*/
		}
		protected void OnButtonDeleteClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewQuotes.get_selection().get_selected(out model, out iter) )
			{
				var err = new InfoDialog("error")
				{
					Title = SBText.__("Preview error"),
					Message = SBText.__("You need to select a quote.")
				};
				err.run();
				err.destroy();
				return;
			}
			Value id;
			model.get_value(iter, Columns.QUOTE_ID, out id);
			/*
			var order = new PurchaseOrder.from_id((int)order_id);
			var nb = (SBNotebook)SBGlobals.GetVar("notebook");
			var w = new EPos.WidgetReceivePurchaseOrder(order);
			w.show();
			string tab_id = "receive-purchase-order-%d".printf(order.Id);
			nb.AddPage(tab_id, SBText.__("Receive Order"), w);
			nb.SetCurrentPageById(tab_id);
			*/
		}
		protected void OnButtonPreviewClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewQuotes.get_selection().get_selected(out model, out iter) )
			{
				var err = new InfoDialog("error")
				{
					Title = SBText.__("Preview error"),
					Message = SBText.__("You need to select a quote.")
				};
				err.run();
				err.destroy();
				return;
			}
			Value qid;
			model.get_value(iter, Columns.QUOTE_ID, out qid);
			//##get company data
			string company_data = SBParameter.Get("company");
			HashMap<string, string> company = SinticBolivia.Utils.JsonDecode(company_data);
			var	user		= (SBUser)SBGlobals.GetVar("user");
			var quote 		= new Quote.from_id((int)qid);
			var customer	= EPosHelper.GetCustomer(quote.CustomerId);
			quote.GetDbItems();
			
			float font_size = 8;
			
			//##create new report instance
			var report = new Reports.PdfReport();
			//stdout.printf("page available width: %.2f\n", catalog.pageAvailableSpace);
			report.WriteText(SBText.__("Quotation", "mod_quotes"), "center", 17);
			
			var table = new Reports.PdfTable(report.pdf, 
											report.page, 
											report.font, 
											report.pageAvailableSpace, 
											report.XPos, 
											report.YPos)
			{
				Report = report
			};
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
									
			string order_data = "Quote#: %s\n".printf(quote.Code);
			order_data += "Date: %s\n" .printf(new DateTime.now_local().format("%Y-%m-%d"))+
							"Customer: %s\n".printf((string)customer["code"])+
							"Sales Rep.: %s %s\n".printf(user.Firstname, user.Lastname);
			
			string logo_path = "images/%s".printf((company.has_key("logo")) ? (string)company["logo"] : "share/images/company_logo.png");
			
			if( !FileUtils.test(logo_path, FileTest.EXISTS) )
				logo_path = "share/images/logo.png";
				
			string[] logo_parts = SBFileHelper.GetParts(logo_path);
			
			HPDF.Image? logo_img = null;
			var pix = new Gdk.Pixbuf.from_file(logo_path);
			
			if( logo_parts[1] == "jpg" || logo_parts[1] == "jpeg" )
			{
				/*
				if( pix.height > 200)
				{
					pix = pix.scale_simple(200, 200, Gdk.InterpType.BILINEAR);
					uint8[] buffer0;
					pix.save_to_buffer(out buffer0, "jpeg");
					logo_img = report.pdf.LoadJpegImageFromMem(buffer0, (uint)pix.get_byte_length());
				}
				else*/
				{
					logo_img = report.pdf.LoadJpegImageFromFile(SBFileHelper.SanitizePath(logo_path));
				}
			}
			else if( logo_parts[1] == "png" )
			{
				/*
				if( pix.height > 200)
				{
					pix = pix.scale_simple(200, 200, Gdk.InterpType.BILINEAR);
					uint8[] buffer1;
					pix.save_to_buffer(out buffer1, "png");
					logo_img = report.pdf.LoadPngImageFromMem(buffer1, (uint)pix.get_byte_length());
				}
				else*/
				{
					logo_img = report.pdf.LoadPngImageFromFile(SBFileHelper.SanitizePath(logo_path));
				}
				
			}
				
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
			
			report.WriteText("\n\n\n", "left", 17);
			
			var table1 = new Reports.PdfTable(report.pdf, 
											report.page, 
											report.font, 
											report.pageAvailableSpace, 
											report.XPos, 
											report.YPos - table.Height - 10)
			{
				Report = report
			};
			table1.SetColumnsWidth({10,40,50});
			cell = table1.AddCell();
			cell.Border = false;
			cell.FontSize = font_size;
			cell.SetText(SBText.__("To:", "mod_quotes"));
			
			cell = table1.AddCell();
			cell.Border = false;
			cell.FontSize = font_size;
			cell.SetText("%s %s".printf((string)customer["first_name"], (string)customer["last_name"]));
			table1.Draw();
			report.WriteText("\n\n\n", "left", 17);
			
			//##details table
			var details_table = new Reports.PdfTable(report.pdf, 
													report.page, 
													report.font, 
													report.pageAvailableSpace, 
													report.XPos, 
													report.YPos - table.Height - 10 - table1.Height - 10)
			{
				Report = report
			};
													
			details_table.SetColumnsWidth({15f, 40, 10f, 10f, 10f, 15f});		
											
			cell 			= details_table.AddCell();
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.SetText(SBText.__("Code", "mod_quotes"));
			
			cell 			= details_table.AddCell();
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.SetText(SBText.__("Product", "mod_quotes"));
			
			cell 			= details_table.AddCell();
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.Align		= "center";
			cell.SetText(SBText.__("Quantity", "mod_quotes"));
			
			cell 			= details_table.AddCell();
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.Align		= "center";
			cell.SetText(SBText.__("Price", "mod_quotes"));
			
			cell 			= details_table.AddCell();
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.Align		= "center";
			cell.SetText(SBText.__("Tax", "mod_quotes"));
			
			cell 			= details_table.AddCell();
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.Align		= "center";
			cell.SetText(SBText.__("Total", "mod_quotes"));
			
			foreach(var item in quote.Items)
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
				cell.Align		= "right";
				cell.SetText("%.2f".printf(prod.Price));
				
				cell 			= details_table.AddCell();
				cell.FontSize 	= font_size;
				cell.Border		= false;
				cell.Align		= "right";
				cell.SetText("%.2f".printf(item.GetDouble("total_tax")));
				
				cell 			= details_table.AddCell();
				cell.FontSize 	= font_size;
				cell.Border		= false;
				cell.Align		= "right";
				cell.SetText("%.2f".printf(item.GetDouble("total")));
			}
			//##insert blank rows
			for(int i = 0; i < 3;i++)
			{
				cell 			= details_table.AddCell();
				cell.Span		= 6;
				cell.FontSize 	= font_size;
				cell.Border	= false;
				cell.SetText("");
			}
			cell 			= details_table.AddCell();
			cell.Span		= 5;
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.Align		= "right";
			cell.SetText(SBText.__("Sub Total:", "mod_quotes"));
			
			cell 			= details_table.AddCell();
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.Align		= "right";
			cell.SetText("%.2f".printf(quote.SubTotal));
			
			cell 			= details_table.AddCell();
			cell.Span		= 5;
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.Align		= "right";
			cell.SetText(SBText.__("Sales Tax:", "mod_quotes"));
			
			cell 			= details_table.AddCell();
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.Align		= "right";
			cell.SetText("%.2f".printf(quote.TaxTotal));
			
			cell 			= details_table.AddCell();
			cell.Span		= 5;
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.Align		= "right";
			cell.SetText(SBText.__("Total:", "mod_quotes"));
			
			cell 			= details_table.AddCell();
			cell.FontSize 	= font_size;
			cell.LeftBorder	= false;
			cell.RightBorder	= false;
			cell.Align		= "right";
			cell.SetText("%.2f".printf(quote.Total));
			
			details_table.Draw();
			
			//catalog.Save();			
			report.Preview("quote");
		}
		protected void RefreshQuotes()
		{
			if( this.comboboxStores.active_id == null || this.comboboxStores.active_id == "-1")
		    {
		        (this.treeviewQuotes.model as ListStore).clear();
		        return;
		    }
		    int store_id = int.parse(this.comboboxStores.active_id);
		    string? status = null;
		    if( this.comboboxStatus.active_id != "-1")
		    {
		        status = this.comboboxStatus.active_id;
		    }
		    this.GetQuotes(store_id, status);
		}
		protected void GetQuotes(int store_id, string? status = null, int page = 1, int limit = 100)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT q.*, s.store_name "+
			                "FROM quotes q, stores s "+
							"WHERE q.store_id = %d "+
							"AND q.store_id = s.store_id ";
			if( status != null )
			{
			    query += "AND q.status = '%s' ".printf(status);
			}
							
			query += "ORDER BY q.creation_date DESC";
			query = query.printf(store_id);
			var rows = dbh.GetResults(query);
			(this.treeviewQuotes.model as ListStore).clear();
			TreeIter iter;
			int i = 1;
			foreach(var row in rows)
			{
			    string _status = row.Get("status");
			    string status_color = "#000";
			    if(_status == "created")
			    {
			        status_color = "#e0e470";
			    }
			    else if(_status == "completed")
			    {
			        status_color = "#64ae51";
			    }
			    else if(_status == "expired")
			    {
			        status_color = "red";
			    }
				(this.treeviewQuotes.model as ListStore).append(out iter);
				(this.treeviewQuotes.model as ListStore).set(iter,
				    Columns.COUNT, i,
				    Columns.QUOTE_ID, row.GetInt("quote_id"),
				    Columns.CODE, row.Get("code"),
				    Columns.ITEMS, row.GetInt("items"),
				    Columns.TOTAL, "%.2f".printf(row.GetDouble("total")),
				    Columns.STATUS, "<span color=\"%s\" font_weight=\"bold\">%s</span>".printf(status_color, _status),
				    Columns.CREATION_DATE, row.Get("creation_date"),
				    Columns.EXPIRATION_DATE, row.Get("expiration_date")
				);
				i++;
			}
		}
	}
}
