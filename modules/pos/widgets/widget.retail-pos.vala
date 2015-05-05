using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetRetailPos : Box
	{
		protected	Builder			ui;
		protected	Box				boxRetailPos;
		protected	Label			labelStoreName;
		protected	Label			labelCashierUsername;
		protected	Label			labelTicketCode;
		protected	Label			labelShift;
		protected	Label			labelDate;
		protected	Label			labelTime;
		protected	Label			labelCustomer;
		protected	Label			labelTaxRate;
		protected	Image			imageCustomer;
		protected	TreeView		treeviewOrderItems;
		protected	Entry			entryBarcode;
		protected	Label			labelSubTotal;
		protected	Label			labelSalesTax;
		protected	Label			labelTotal;
		protected	Button			buttonComments;
		protected	Button			buttonHold;
		protected	Button			buttonLookup;
		protected	Button			buttonCustomer;
		protected	Button			buttonCalculator;
		protected	Button			buttonCount;
		protected	Button			buttonReqValidation;
		protected	Button			buttonDrawer;
		protected	Button			buttonConvertToCurrency;
		protected	Button			buttonTender;
		protected	Button			buttonRecall;
		
		protected	InfoDialog		CommentsDialog;
		protected	TextView		textviewComments;
		
		protected	SBStore			store 	= null;
		protected	int				CustomerId = 0;
		protected	HashMap<string, Value?>		Customer;
		protected	double			taxRate = 0;
		protected	Gdk.Pixbuf		deleteIcon;
		
		enum Columns
		{
			COUNT,
			PRODUCT_CODE,
			PRODUCT_NAME,
			QUANTITY,
			UOM,
			PRICE,
			SUBTOTAL,
			TAX,
			TOTAL,
			DELETE,
			PRODUCT_ID,
			N_COLS
		}
		public WidgetRetailPos()
		{
			this.ui			= (SBModules.GetModule("Pos") as SBGtkModule).GetGladeUi("retail-pos.glade");
			this.boxRetailPos		= (Box)this.ui.get_object("boxRetailPos");
			this.labelStoreName		= (Label)this.ui.get_object("labelStoreName");
			this.labelCashierUsername	= (Label)this.ui.get_object("labelCashierUsername");
			this.labelTicketCode		= (Label)this.ui.get_object("labelTicketCode");
			this.labelShift				= (Label)this.ui.get_object("labelShift");
			this.labelDate				= (Label)this.ui.get_object("labelDate");
			this.labelTime				= (Label)this.ui.get_object("labelTime");
			this.labelCustomer			= (Label)this.ui.get_object("labelCustomer");
			this.labelTaxRate			= (Label)this.ui.get_object("labelTaxRate");
			this.imageCustomer			= (Image)this.ui.get_object("imageCustomer");
			this.treeviewOrderItems 	= (TreeView)this.ui.get_object("treeviewOrderItems");
			this.entryBarcode			= (Entry)this.ui.get_object("entryBarcode");
			this.labelSubTotal			= (Label)this.ui.get_object("labelSubTotal");
			this.labelSalesTax			= (Label)this.ui.get_object("labelSalesTax");
			this.labelTotal				= (Label)this.ui.get_object("labelTotal");
			this.buttonComments		= (Button)this.ui.get_object("buttonComments");
			this.buttonHold			= (Button)this.ui.get_object("buttonHold");
			this.buttonLookup		= (Button)this.ui.get_object("buttonLookup");
			this.buttonCustomer		= (Button)this.ui.get_object("buttonCustomer");
			this.buttonCalculator	= (Button)this.ui.get_object("buttonCalculator");
			this.buttonCount		= (Button)this.ui.get_object("buttonCount");
			this.buttonReqValidation	= (Button)this.ui.get_object("buttonReqValidation");
			this.buttonDrawer			= (Button)this.ui.get_object("buttonDrawer");
			this.buttonConvertToCurrency= (Button)this.ui.get_object("buttonConvertToCurrency");
			this.buttonTender			= (Button)this.ui.get_object("buttonTender");
			this.buttonRecall			= (Button)this.ui.get_object("buttonRecall");
			
			this.textviewComments		= new TextView();
			this.boxRetailPos.reparent(this);
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			this.deleteIcon = (SBModules.GetModule("Pos") as SBGtkModule).GetPixbuf("delete-icon-24x24.png");
			this.labelDate.label = new DateTime.now_local().format("%Y-%m-%d");
			this.labelTime.label = new DateTime.now_local().format("%H:%M:%S");
			this.imageCustomer.pixbuf = (SBModules.GetModule("Pos") as SBGtkModule).GetPixbuf("customer-48x48.png");
			this.labelCustomer.label = "";
			this.treeviewOrderItems.model = new ListStore(Columns.N_COLS,
				typeof(int), //count
				typeof(string), //product code
				typeof(string), //product name
				typeof(int), //quantity
				typeof(string), //UOM
				typeof(string), //price
				typeof(string), //subtotal
				typeof(string), //tax
				typeof(string), //total
				typeof(Gdk.Pixbuf), //delete image
				typeof(int) //product id
			);
			string[,] cols= 
			{
				{"#", "text", "60", "center", "", ""},
				{SBText.__("Code"), "text", "120", "left", "", ""},
				{SBText.__("Product"), "text", "250", "left", "", ""},
				{SBText.__("Quantity"), "text", "60", "center", "editable", ""},
				{SBText.__("U.O.M."), "text", "120", "left", "", ""},
				{SBText.__("Price"), "text", "100", "right", "", ""},
				{SBText.__("Sub Total"), "text", "100", "right", "", ""},
				{SBText.__("Tax"), "text", "100", "right", "", ""},
				{SBText.__("Total"), "text", "100", "right", "", ""},
				{SBText.__("Remove"), "pixbuf", "48", "center", "", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewOrderItems);
			this.treeviewOrderItems.get_column(Columns.DELETE).set_data<string>("action", "delete");
			this.treeviewOrderItems.rules_hint = true;
			//build comments dialog
			this.CommentsDialog = new InfoDialog("info")
			{
				Title = SBText.__("Comments"),
				Message = SBText.__("Sale Comments:")
			};
			this.CommentsDialog.get_style_context().add_class("dialog-retail-comments");
			this.CommentsDialog.set_size_request(350, 200);
			var scroll = new ScrolledWindow(null, null){expand = true};
			scroll.add_with_viewport(this.textviewComments);
			scroll.show_all();
			
			this.CommentsDialog.get_content_area().add(scroll);
		}
		protected void SetEvents()
		{
			var cell_qty = (this.treeviewOrderItems.get_column(Columns.QUANTITY).get_cells().nth_data(0) as CellRendererText);
			cell_qty.edited.connect(this.OnCellQuantityEdited);
			this.treeviewOrderItems.button_release_event.connect(this.OnTreeViewOrderItemsButtonReleaseEvent);
			
			this.entryBarcode.key_release_event.connect(this.OnEntryBarcodeKeyReleaseEvent);
			this.buttonComments.clicked.connect(this.OnButtonCommentsClicked);
			this.buttonHold.clicked.connect(this.OnButtonHoldClicked);
			this.buttonLookup.clicked.connect(this.OnButtonLookupClicked);
			this.buttonCustomer.clicked.connect(this.OnButtonCustomerClicked);
			this.buttonCalculator.clicked.connect(this.OnButtonCalculatorClicked);
			this.buttonRecall.clicked.connect(this.OnButtonRecallClicked);
			this.realize.connect( () => 
			{
				this.SetShortcutsEvents();
			});
			this.show.connect(this.OnRetailPosShow);
		}
		protected void OnRetailPosShow()
		{
			string tab_id = "retail-pos";
			HashMap<string, Value?>? store = null;
			var user = (SBUser)SBGlobals.GetVar("user");
			var nb = (SBNotebook)SBGlobals.GetVar("notebook");
			int store_id = int.parse(user.GetMeta("store_id"));
			
			if( user.HasPermission("manage_stores") )
			{
				var w = new DialogStoreSelector();
				w.modal = true;
				w.show();
				w.destroy.connect( () => 
				{
					this.store = w.GetStore();
					if( this.store != null )
					{
						int tax_id = int.parse(this.store.Get("tax_id"));
						var tax_rate = EPosHelper.GetTaxRate(tax_id);
						this.taxRate = (double)tax_rate["rate"];
						this.labelStoreName.label = this.store.Name;
						this.labelCashierUsername.label = user.Username;
						this.labelTaxRate.label = "%.2f%s".printf(this.taxRate, "%");
					}
					else
					{
						nb.RemovePage(tab_id);
					}
				});
				
			}
			else if( store_id > 0 )
			{
				//##get user store
				this.store = new SBStore.from_id(store_id);
				int tax_id = int.parse(this.store.Get("tax_id"));
				var tax_rate = EPosHelper.GetTaxRate(tax_id);
				this.taxRate = (double)tax_rate["rate"];
				this.labelStoreName.label = this.store.Name;
				this.labelCashierUsername.label = user.Username;
				this.labelTaxRate.label = "%.2f%s".printf(this.taxRate, "%");
			}
			else
			{
				var err = new InfoDialog("error")
				{
					Title = SBText.__("Error"),
					Message = SBText.__("Your user does not have any store assigned, please contact with administrator.")
				};
				err.run();
				err.destroy();
				nb.RemovePage(tab_id);
			}
		}
		
		protected void OnCellQuantityEdited(string path, string new_text)
		{
			TreeIter iter;
			int new_qty = int.parse(new_text.strip());
			this.treeviewOrderItems.model.get_iter(out iter, new TreePath.from_string(path));
			(this.treeviewOrderItems.model as ListStore).set_value(iter, Columns.QUANTITY, new_qty);
			
			this.CalculateRowTotal(iter);
			this.CalculateTotals();
		}
		protected bool OnTreeViewOrderItemsButtonReleaseEvent(Gdk.EventButton event)
		{
			TreePath path;
			TreeViewColumn col;
			TreeIter iter;
			TreeModel model;
			int cell_x, cell_y;
			
			if( !this.treeviewOrderItems.get_path_at_pos((int)event.x, (int)event.y, out path, out col, out cell_x, out cell_y) )
				return false;
			if( !this.treeviewOrderItems.get_selection().get_selected(out model, out iter) )
				return false;
			string action = col.get_data<string>("action");
			if( action == "delete" )
			{
				this.RemoveItem(iter);
			}
			return true;
		}
		protected bool OnEntryBarcodeKeyReleaseEvent(Gdk.EventKey event)
		{
			if( event.keyval != 65293 )
			{
				return true;
			}
			string barcode = this.entryBarcode.text.strip();
			if( barcode.length <= 0 )
			{
				return true;
			}
			int id = EPosHelper.FindProductBy("barcode", barcode);
			if( id > 0 )
			{
				this.AddProduct(id);
				this.entryBarcode.text = "";
			}
			
			return true;
		}
		protected void OnButtonCommentsClicked()
		{
			this.CommentsDialog.run();
			this.CommentsDialog.hide();
		}
		protected void OnButtonHoldClicked()
		{
			int sale_id = this.RegisterSale("hold");
			if( sale_id <= 0 )
				return;
				
			var msg = new InfoDialog()
			{
				Title = SBText.__("Hold Sale"),
				Message = SBText.__("The sale has been placed with \"hold\" status.")
			};
			msg.run();
			msg.destroy();
			this.ResetSale();
		}
		protected void OnButtonLookupClicked()
		{
			//int product_id = 0;
			var win = new WindowLookupProducts();
			win.StoreId = (this.store != null) ? this.store.Id : -1;
			win.modal = true;
			win.show();
			win.destroy.connect( () => 
			{
				//product_id = win.ProductId;
				this.AddProduct(win.ProductId);
			});
		}
		protected void OnButtonCustomerClicked()
		{
			var win = new WindowCustomerLookup();
			win.modal = true;
			win.show();
			win.destroy.connect( () => 
			{
				this.CustomerId = win.CustomerId;
				if( this.CustomerId > 0 )
				{
					this.Customer = EPosHelper.GetCustomer(this.CustomerId);
					this.labelCustomer.label = "%s %s".printf((string)this.Customer["first_name"], (string)this.Customer["first_name"]);
				}
				else
				{
					this.labelCustomer.label = SBText.__("[No assigned]");
				}
			});
		}
		protected void OnButtonCalculatorClicked()
		{
			string command = "";
			
			if( SBOS.GetOS().IsLinux() )
			{
				//string? prg = Environment.find_program_in_path("evince");
				if( Environment.find_program_in_path("mate-calc") != null )
				{
					command = "mate-calc";
				}
				else if( Environment.find_program_in_path("gnome-calculator") != null )
				{
					command = "gnome-calculator";
				}
			}
			else if( SBOS.GetOS().IsWindows() )
			{
				command = SBFileHelper.SanitizePath("calc.exe");
			}	
			
			if( command == "" )
			{
				var err = new InfoDialog("error")
				{
					Title = SBText.__("Calculator error"),
					Message = SBText.__("The application can found a valid calculator in your system.")
				};
				err.run();
				err.destroy();
				return;
			}
			//Posix.pid_t pid = Posix.fork();
			//Posix.system(command);
			//exit(1);
			try
			{
				GLib.Process.spawn_command_line_async(command);
			}
			catch(GLib.SpawnError e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
		}
		protected void OnButtonRecallClicked()
		{
			var win = new WindowSearchOrders();
			win.modal = true;
			win.Status = "hold";
			win.ComboboxStatus.visible = false;
			win.show();
			win.destroy.connect( () => 
			{
				var sale = win.GetOrder();
				if( sale != null )
				{
					this.SetSaleData(sale);
				}
			});
		}
		protected void SetShortcutsEvents()
		{
			Gdk.Window gdk_win = this.get_parent_window();
			void* main_win;
			gdk_win.get_user_data(out main_win);
			//(this.get_toplevel() as Window).key_press_event.connect( (e) => 
			(main_win as Window).key_press_event.connect( (e) => 
			{
				stdout.printf("key code str: %s\n", e.str);
				Gdk.ModifierType mod;
				uint barcode, f1_code, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11;
				
				Gtk.accelerator_parse("<Control>b", out barcode, out mod);
				Gtk.accelerator_parse("F1", out f1_code, out mod);
				Gtk.accelerator_parse("F3", out f2, out mod);
				Gtk.accelerator_parse("F3", out f3, out mod);
				Gtk.accelerator_parse("F4", out f4, out mod);
				Gtk.accelerator_parse("F5", out f5, out mod);
				Gtk.accelerator_parse("F6", out f6, out mod);
				Gtk.accelerator_parse("F7", out f7, out mod);
				Gtk.accelerator_parse("F8", out f8, out mod);
				Gtk.accelerator_parse("F9", out f9, out mod);
				Gtk.accelerator_parse("F10", out f10, out mod);
				Gtk.accelerator_parse("F11", out f11, out mod);
				
				var args = (Gdk.EventKey)e;
				if( args.keyval == barcode )
				{
					this.entryBarcode.grab_focus();
					return true;
				}
				if( args.keyval == f1_code )
				{
					GLib.Signal.emit_by_name(this.buttonComments, "clicked");
					return true;
				}
				if( args.keyval == f2 )
				{
					GLib.Signal.emit_by_name(this.buttonHold, "clicked");
					return true;
				}
				if( args.keyval == f3 )
				{
					GLib.Signal.emit_by_name(this.buttonLookup, "clicked");
					return true;
				}
				if( args.keyval == f4 )
				{
					GLib.Signal.emit_by_name(this.buttonCustomer, "clicked");
					return true;
				}
				if( args.keyval == f5 )
				{
					GLib.Signal.emit_by_name(this.buttonCalculator, "clicked");
					return true;
				}
				if( args.keyval == f11 )
				{
					GLib.Signal.emit_by_name(this.buttonRecall, "clicked");
					return true;
				}
				//##return false to mark the event as no consumed
				return false;
			});
		}
		public void AddProduct(int product_id, int quantity = 1)
		{
			if( product_id <= 0 )
				return;
			bool exists = false;
			int  i = 0;
			//##check if product already exists into treeview
			this.treeviewOrderItems.model.foreach( (model, path, iter) => 
			{
				Value id, qty, v_price;
				model.get_value(iter, Columns.PRODUCT_ID, out id);
				model.get_value(iter, Columns.QUANTITY, out qty);
				model.get_value(iter, Columns.PRICE, out v_price);
				
				if( (int)id == product_id )
				{
					double price = double.parse((string)v_price);
					double subtotal = (price * ((int)qty + quantity));
					double tax	=  subtotal * (this.taxRate / 100);
					double total = subtotal + tax;
					exists = true;
					//##update product quantity
					(model as ListStore).set_value(iter, Columns.QUANTITY, (int)qty + quantity);
					(model as ListStore).set_value(iter, Columns.SUBTOTAL, "%.2f".printf(subtotal));
					(model as ListStore).set_value(iter, Columns.TAX, "%.2f".printf(tax));
					(model as ListStore).set_value(iter, Columns.TOTAL, "%.2f".printf(total));
					
				}
				i++;
				return false;
			});
			if( exists )
			{
				this.CalculateTotals();
				return;
			}
			var prod = new SBProduct.from_id(product_id);
			
			double subtotal = (prod.Price * quantity);
			double tax	=  subtotal * (this.taxRate / 100);
			double total = subtotal + tax;
						
			TreeIter iter;
			(this.treeviewOrderItems.model as ListStore).append(out iter);
			(this.treeviewOrderItems.model as ListStore).set(iter,
				Columns.COUNT, (i == 0) ? 1 : i,
				Columns.PRODUCT_CODE, prod.Code,
				Columns.PRODUCT_NAME, prod.Name,
				Columns.QUANTITY, quantity,
				Columns.UOM, "",
				Columns.PRICE, "%.2f".printf(prod.Price),
				Columns.SUBTOTAL, "%.2f".printf(subtotal),
				Columns.TAX, "%.2f".printf(tax),
				Columns.TOTAL, "%.2f".printf(total),
				Columns.DELETE, this.deleteIcon,
				Columns.PRODUCT_ID, prod.Id
			);
			this.CalculateTotals();
		}
		protected void CalculateRowTotal(TreeIter iter)
		{
			Value v_qty, v_price;
			//model.get_value(iter, Columns.PRODUCT_ID, out id);
			this.treeviewOrderItems.model.get_value(iter, Columns.QUANTITY, out v_qty);
			this.treeviewOrderItems.model.get_value(iter, Columns.PRICE, out v_price);
				
			double price 	= double.parse((string)v_price);
			double subtotal = (price * (int)v_qty);
			double tax		= subtotal * (this.taxRate / 100);
			double total 	= subtotal + tax;
			//##update row values
			//(model as ListStore).set_value(iter, Columns.QUANTITY, (int)qty + quantity);
			(this.treeviewOrderItems.model as ListStore).set_value(iter, Columns.SUBTOTAL, "%.2f".printf(subtotal));
			(this.treeviewOrderItems.model as ListStore).set_value(iter, Columns.TAX, "%.2f".printf(tax));
			(this.treeviewOrderItems.model as ListStore).set_value(iter, Columns.TOTAL, "%.2f".printf(total));
		}
		protected void RemoveItem(TreeIter iter)
		{
			GLib.Value product_id, qty, price, tax_rate;
			
			(this.treeviewOrderItems.model as ListStore).get_value(iter, Columns.QUANTITY, out qty);
			(this.treeviewOrderItems.model as ListStore).get_value(iter, Columns.PRICE, out price);
			(this.treeviewOrderItems.model as ListStore).get_value(iter, Columns.PRODUCT_ID, out product_id);
			
			if( (int)qty > 1 )
			{
				(this.treeviewOrderItems.model as ListStore).set_value(iter, Columns.QUANTITY, ((int)qty - 1));
				this.CalculateRowTotal(iter);
			}
			else
			{
				(this.treeviewOrderItems.model as ListStore).remove(iter);
			}
			this.CalculateTotals();
		}
		protected void CalculateTotals()
		{
			double subtotal = 0, total_tax = 0, total_sale = 0;
			
			this.treeviewOrderItems.model.foreach( (model, path, iter) => 
			{
				Value v_id, v_qty, v_price, v_subtotal, v_tax, v_total;
				
				model.get_value(iter, Columns.PRODUCT_ID, out v_id);
				model.get_value(iter, Columns.QUANTITY, out v_qty);
				model.get_value(iter, Columns.PRICE, out v_price);
				model.get_value(iter, Columns.SUBTOTAL, out v_subtotal);
				model.get_value(iter, Columns.TAX, out v_tax);
				model.get_value(iter, Columns.TOTAL, out v_total);
				
				subtotal 	+= double.parse((string)v_subtotal);
				total_tax	+= double.parse((string)v_tax);
				total_sale	+= double.parse((string)v_total);
								
				return false;
			});
			this.labelSubTotal.label 	= "%.2f".printf(subtotal);
			this.labelSalesTax.label 	= "%.2f".printf(total_tax);
			this.labelTotal.label		= "%.2f".printf(total_sale);
		}
		protected int RegisterSale(string status = "sold")
		{
			if( this.CustomerId <= 0 )
			{
				var err = new InfoDialog("error")
				{
					Title = SBText.__("Sale error"),
					Message = SBText.__("You need to select a customer")
				};
				err.run();
				err.destroy();
				return 0;
			}
			TreeIter iter;
			if( !this.treeviewOrderItems.model.get_iter_first(out iter) )
			{
				var err = new InfoDialog("error")
				{
					Title = SBText.__("Sale error"),
					Message = SBText.__("You need to add atleast one product to order.")
				};
				err.run();
				err.destroy();
				return 0;
			}
			
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var user = (SBUser)SBGlobals.GetVar("user");
			double subtotal 	= double.parse(this.labelSubTotal.label);
			double tax_total 	= double.parse(this.labelSalesTax.label);
			double total		= double.parse(this.labelTotal.label);
			string cdate		= new DateTime.now_local().format("%Y-%m-%d %H:%M:%S");
			var sale = new HashMap<string, Value?>();
			sale.set("code", "");
			sale.set("store_id", this.store.Id);
			sale.set("cashier_id", user.Id);
			sale.set("customer_id", this.CustomerId);
			sale.set("notes", this.textviewComments.buffer.text.strip());
			sale.set("sub_total", subtotal);
			sale.set("tax_rate", this.taxRate);
			sale.set("tax_amount", tax_total);
			sale.set("discount_total", 0);
			sale.set("total", total);
			sale.set("status", status);
			sale.set("last_modification_date", cdate);
			sale.set("creation_date", cdate);
			dbh.BeginTransaction();
			int sale_id = (int)dbh.Insert("sales", sale);
			
			//##insert sale items
			this.treeviewOrderItems.model.foreach( (model, path, iter) => 
			{
				Value product_id, product_name, qty, price, sub_total, tax_amount, itotal;
				model.get_value(iter, Columns.PRODUCT_ID, out product_id);
				model.get_value(iter, Columns.PRODUCT_NAME, out product_name);
				model.get_value(iter, Columns.QUANTITY, out qty);
				model.get_value(iter, Columns.PRICE, out price);
				model.get_value(iter, Columns.SUBTOTAL, out sub_total);
				model.get_value(iter, Columns.TAX, out tax_amount);
				model.get_value(iter, Columns.TOTAL, out itotal);
				
				var item = new HashMap<string, Value?>();
				item.set("sale_id", sale_id);
				item.set("product_id", (int)product_id);
				item.set("product_name", (string)product_name);
				item.set("quantity", (int)qty);
				item.set("price", double.parse((string)price));
				item.set("sub_total", double.parse((string)sub_total));
				item.set("tax_rate", this.taxRate);
				item.set("tax_amount", double.parse((string)tax_amount));
				item.set("discount", 0);
				item.set("total", double.parse((string)itotal));
				item.set("status", status);
				item.set("last_modification_date", cdate);
				item.set("creation_date", cdate);
				dbh.Insert("sale_items", item);
				return false;
			});
			dbh.EndTransaction();
			
			return sale_id;
		}
		protected void ResetSale()
		{
			this.CustomerId = 0;
			this.Customer = null;
			this.labelCustomer.label = "";
			this.textviewComments.buffer.text = "";
			
			(this.treeviewOrderItems.model as ListStore).clear();
			this.labelSubTotal.label = "0.00";
			this.labelSalesTax.label = "0.00";
			this.labelTotal.label = "0.00";
		}
		protected void SetSaleData(ESale sale)
		{
			size_t length;
			string json = Json.gobject_to_data(sale, out length);
			stdout.printf("%s\n", json);
			this.CustomerId = int.parse((string)sale.Customer["customer_id"]);
			this.Customer	= sale.Customer;
			this.textviewComments.buffer.text = sale.Notes;
			this.labelCustomer.label = "%s %s".printf((string)this.Customer["first_name"], (string)this.Customer["last_name"]);
			//##set order ITEMS
			TreeIter iter;
			int i = 1;
			foreach(var item in sale.Items)
			{
				(this.treeviewOrderItems.model as ListStore).append(out iter);
				(this.treeviewOrderItems.model as ListStore).set(iter,
					Columns.COUNT, i,
					Columns.PRODUCT_CODE, "prod.Code",
					Columns.PRODUCT_NAME, item.ProductName,
					Columns.QUANTITY, item.Quantity,
					Columns.UOM, "",
					Columns.PRICE, "%.2f".printf(item.Price),
					Columns.SUBTOTAL, "%.2f".printf(item.SubTotal),
					Columns.TAX, "%.2f".printf(item.TaxAmount),
					Columns.TOTAL, "%.2f".printf(item.Total),
					Columns.DELETE, this.deleteIcon,
					Columns.PRODUCT_ID, item.ProductId
				);
				i++;
			}
			this.labelSubTotal.label = "%.2f".printf(sale.SubTotal);
			this.labelSalesTax.label = "%.2f".printf(sale.TaxAmount);
			this.labelTotal.label = "%.2f".printf(sale.Total);
		}
	}
}
