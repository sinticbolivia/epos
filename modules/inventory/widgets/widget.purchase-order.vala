using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Database;
using SinticBolivia.Gtk;
using EPos;

namespace Woocommerce
{
	public class WidgetPurchaseOrder : Gtk.Box
	{
		protected 	Builder 		ui;
		protected 	Box				boxPurchaseOrder;
		protected	Image			image1;
		protected 	Label			labelTitle;
		protected 	ComboBox		comboboxStores;
		protected	SBDatePicker	datepickerOrderDate;
		protected	SBDatePicker	datepickerDeliveryDate;
		protected	ComboBox		comboboxSuppliers;
		protected 	Entry			entryDetails;
		protected 	Entry			entrySearchProduct;
		protected 	SpinButton		spinbuttonProductQty;
		protected 	ComboBox		comboboxSearchType;
		protected 	Button			buttonAddProduct;
		protected 	TreeView		treeviewProducts;
		protected 	ButtonBox		buttonbox1;
		protected 	Button			buttonCancel;
		protected 	Button			buttonSave;
		protected	Label			labelSubTotal;
		protected	Label			labelTotalTax;
		protected 	Label			labelTotal;
		protected 	int				total_items = 0;
		protected 	PurchaseOrder	order = null;
		
		protected enum		Columns
		{
			COUNT,
			PRODUCT_NAME,
			CURRENT_QTY,
			QTY,
			COST,
			SUB_TOTAL,
			TAX,
			TOTAL,
			IMAGE,
			PRODUCT_ID,
			TAX_RATE,
			N
		}
		public string Title
		{
			set{this.labelTitle.label = value;}
		}
		public WidgetPurchaseOrder()
		{
			//this.ui = SB_ModuleInventory.GetGladeUi("purchase-order.glade");
			this.ui = ((SBModules.GetModule("Inventory") as SBGtkModule)).GetGladeUi("purchase-order.glade");
			this.expand = true;			
			
			this.boxPurchaseOrder		= (Box)this.ui.get_object("boxPurchaseOrder");
			this.image1					= (Image)this.ui.get_object("image1");
			this.labelTitle				= (Label)this.ui.get_object("labelTitle");
			this.comboboxStores			= (ComboBox)this.ui.get_object("comboboxStores");
			var grid2					= (Grid)this.ui.get_object("grid2");
			this.datepickerOrderDate	= new SBDatePicker();
			this.datepickerDeliveryDate	= new SBDatePicker();
			
			this.datepickerOrderDate.show();
			this.datepickerDeliveryDate.show();
			grid2.attach(this.datepickerOrderDate, 3, 0, 1, 1);
			grid2.attach(this.datepickerDeliveryDate, 5, 0, 1, 1);
			
			this.comboboxSuppliers		= (ComboBox)this.ui.get_object("comboboxSuppliers");
			this.entryDetails			= (Entry)this.ui.get_object("entryDetails");
			this.entrySearchProduct		= (Entry)this.ui.get_object("entrySearchProduct");
			this.spinbuttonProductQty	= (SpinButton)this.ui.get_object("spinbuttonProductQty");
			this.comboboxSearchType		= (ComboBox)this.ui.get_object("comboboxSearchType");
			this.buttonAddProduct		= (Button)this.ui.get_object("buttonAddProduct");
			this.treeviewProducts		= (TreeView)this.ui.get_object("treeviewProducts");
			this.buttonbox1				= (ButtonBox)this.ui.get_object("buttonbox1");
			this.buttonCancel			= (Button)this.ui.get_object("buttonCancel");
			this.buttonSave				= (Button)this.ui.get_object("buttonSave");
			this.labelSubTotal			= (Label)this.ui.get_object("labelSubTotal");
			this.labelTotalTax			= (Label)this.ui.get_object("labelTotalTax");
			this.labelTotal				= (Label)this.ui.get_object("labelTotal");
			this.boxPurchaseOrder.reparent(this);
			this.Build();
			this.FillForm();
			this.SetEvents();

		}
		protected void Build()
		{
			this.image1.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("purchase-order-icon-64x64.png");
			this.datepickerOrderDate.DateString = new DateTime.now_local().format("%Y-%m-%d");
			this.datepickerDeliveryDate.DateString = new DateTime.now_local().format("%Y-%m-%d");
			//##build stores combobox
			TreeIter iter;
			this.comboboxStores.model = new ListStore(2, typeof(string), typeof(string));
			var cell0 = new CellRendererText();
			this.comboboxStores.pack_start(cell0, true);
			this.comboboxStores.add_attribute(cell0, "text", 0);
			this.comboboxStores.id_column = 1;
			(this.comboboxStores.model as ListStore).append(out iter);
			(this.comboboxStores.model as ListStore).set(iter, 0, SBText.__("-- store --"), 1, "-1");
			
			//##build combobox suppliers
			this.comboboxSuppliers.model = new ListStore(2, typeof(string), typeof(string));
			//cell0 = new CellRendererText();
			//this.comboboxSuppliers.pack_start(cell0, false);
			//this.comboboxSuppliers.add_attribute(cell0, "text", 0);
			this.comboboxSuppliers.entry_text_column = 0;
			this.comboboxSuppliers.id_column = 1;
			
			
			//##build entry completion
			this.entrySearchProduct.completion = new EntryCompletion();
			
			this.entrySearchProduct.completion.model = new ListStore(3,
				typeof(int),
				typeof(string),
				typeof(string)
			);
			this.entrySearchProduct.completion.text_column = 1;
			this.entrySearchProduct.completion.clear(); //remove all cellrenderers
			
			var cell = new CellRendererText();
			this.entrySearchProduct.completion.pack_start(cell, false);
			this.entrySearchProduct.completion.add_attribute(cell, "text", 0);
			cell = new CellRendererText();
			this.entrySearchProduct.completion.pack_start(cell, false);
			this.entrySearchProduct.completion.add_attribute(cell, "markup", 2);
			this.entrySearchProduct.completion.set_match_func( (completion, key, iter) => 
			{
				if( key == null )
					return false;
					
				Value v_str;
				
				this.entrySearchProduct.completion.model.get_value(iter, 1, out v_str);
				if( (v_str as string).down().index_of(key.down()) != -1 )
				{
					return true;
				}
				return false;
			});
			//##end entry completion
			
			//##build search type combobox
			cell0 = new CellRendererText();
			this.comboboxSearchType.pack_start(cell0, true);
			this.comboboxSearchType.add_attribute(cell0, "text", 0);
			this.comboboxSearchType.active_id = "product_name";
			//##build treeview 
			this.treeviewProducts.model = new ListStore(Columns.N,
				typeof(int), //counter
				typeof(string), //product
				typeof(int), //stock on hand
				typeof(int), //quantity
				typeof(string), //cost
				typeof(string), //subtotal
				typeof(string), //tax
				typeof(string), //total
				typeof(Gdk.Pixbuf), //remove
				typeof(int), //product id
				typeof(string) //tax rate
			);
			string[,] columns = 
			{
				{"#", "text", "70", "center", ""},
				{SBText.__("Product"), "text", "250", "left", ""},
				{SBText.__("Stock on Hand"), "text", "50", "center", ""},
				{SBText.__("Quantity"), "text", "50", "center", "editable"},
				{SBText.__("Cost"), "text", "70", "right", "editable"},
				{SBText.__("Sub Total"), "text", "70", "right", ""},
				{SBText.__("Tax"), "text", "70", "right", ""},
				{SBText.__("Total"), "text", "70", "right", "editable"},
				{SBText.__("Remove"), "pixbuf", "70", "center", ""}
			};
			
			SinticBolivia.Gtk.GtkHelper.BuildTreeViewColumns(columns, ref this.treeviewProducts);
			this.treeviewProducts.rules_hint = true;
			this.treeviewProducts.get_column(Columns.IMAGE).set_data<string>("action", "remove_item");
			this.buttonCancel.get_style_context().add_class("button-cancel");
			this.buttonSave.get_style_context().add_class("button-green");
		}
		protected void SetEvents()
		{
			this.entrySearchProduct.key_release_event.connect(this.OnEntrySearchProductKeyReleaseEvent);
			this.entrySearchProduct.completion.match_selected.connect(this.OnCompletionMatchSelected);
			this.buttonAddProduct.clicked.connect(this.OnButtonAddProductClicked);
			var col = (TreeViewColumn)this.treeviewProducts.get_columns().nth_data(Columns.QTY);
			var cell = (CellRendererText)col.get_cells().nth_data(0);
			
			//##add event to update order item quantity
			cell.edited.connect( (path, new_text) => 
			{
				int qty = int.parse(new_text.strip());
				
				TreeIter iter;
				this.treeviewProducts.model.get_iter(out iter, new TreePath.from_string(path));
				(this.treeviewProducts.model as ListStore).set_value(iter, Columns.QTY, qty);
				this.calculateRowTotal(iter);
				this.calculateTotals();
			});
			
			this.treeviewProducts.button_release_event.connect(this.OnTreeViewProductsButtonReleaseEvent);
			this.buttonSave.clicked.connect(this.OnButtonSaveClicked);
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
		}
		protected void FillForm()
		{
			//var dbh = (SBDatabase)SBGlobarl.GetVar("dbh");
			var stores = (ArrayList<SBStore>)InventoryHelper.GetStores();
			TreeIter iter;
			foreach(SBStore store in stores)
			{
				(this.comboboxStores.model as ListStore).append(out iter);
				(this.comboboxStores.model as ListStore).set(iter, 0, store.Name, 1, store.Id.to_string());
			}
			this.comboboxStores.active_id = "-1";
			//##get suppliers
			(this.comboboxSuppliers.model as ListStore).append(out iter);
			(this.comboboxSuppliers.model as ListStore).set(iter,
				0, SBText.__("-- supplier --"),
				1, "-1"
			);
			foreach(var supplier in InventoryHelper.GetSuppliers())
			{
				(this.comboboxSuppliers.model as ListStore).append(out iter);
				(this.comboboxSuppliers.model as ListStore).set(iter,
					0, supplier.Name,
					1, supplier.Id.to_string()
				);
			}
			this.comboboxSuppliers.active_id = "-1";
		}
		protected bool OnEntrySearchProductKeyReleaseEvent(Gdk.EventKey event)
		{
			if( event.keyval == 65364 || event.keyval == 65362)
			{
				return true;
			}
			if(this.comboboxStores.active_id == null || this.comboboxStores.active_id == "-1")
				return true;
			int store_id = int.parse(this.comboboxStores.active_id);
			
			(this.entrySearchProduct.completion.model as ListStore).clear();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string str = this.entrySearchProduct.text.strip();
			string query = @"SELECT * FROM products WHERE product_name LIKE '%$str%' AND store_id = $store_id";

			
			var rows = (ArrayList<SBDBRow>)dbh.GetResults(query);
			TreeIter iter;
			
			foreach(var row in rows)
			{
				(this.entrySearchProduct.completion.model as ListStore).append(out iter);
				(this.entrySearchProduct.completion.model as ListStore).set(iter,
					0, row.GetInt("product_id"),
					1, row.Get("product_name"),
					2, "<span foreground=\"darkgreen\">%s</span>".printf(row.Get("product_name")) 
				);
				//stdout.printf("%s, %s\n", row.Get("product_id"), row.Get("product_name"));
			}
			//GLib.Signal.emit_by_name(this.entrySearchProduct, "changed");
			//GLib.Signal.emit_by_name(this.entrySearchProduct, "editing_done");
			return true;
		}
		protected bool OnCompletionMatchSelected(TreeModel model, TreeIter iter)
		{
			//TreeIter p_iter;
			Value v_pid, v_pname;
			model.get_value(iter, 0, out v_pid);
			model.get_value(iter, 1, out v_pname);
			
			this.entrySearchProduct.text = (string)v_pname;
			this.entrySearchProduct.set_data<int>("pid", (int)v_pid);
			this.spinbuttonProductQty.text = "1";
			this.spinbuttonProductQty.grab_focus();
			
			return true;
		}
		protected bool isProductInOrder(int product_id, out TreeIter o_iter)
		{
			bool exists = false;
			TreeIter iter;
			this.treeviewProducts.model.get_iter_first(out iter);
			do{
				Value v_pid;
				this.treeviewProducts.model.get_value(iter, Columns.PRODUCT_ID, out v_pid);
				if( (int)v_pid == product_id )
				{
					o_iter = iter;
					exists = true;
					break;
				}
			}while( this.treeviewProducts.model.iter_next(ref iter));
			
			return exists;
		}
		
		protected void OnButtonAddProductClicked()
		{
			TreeIter p_iter;
			int pid = (int)this.entrySearchProduct.get_data<int>("pid");
			int qty = int.parse(this.spinbuttonProductQty.text.strip());
			if( pid <= 0 )
				return;
			if( qty <= 0 )
				return;
				
			if( this.isProductInOrder(pid, out p_iter) )
			{
				Value v_qty;//, v_cost;
				
				this.treeviewProducts.model.get_value(p_iter, Columns.QTY, out v_qty);
				//this.treeviewProducts.model.get_value(p_iter, Columns.COST, out v_cost);
				int new_qty = (int)v_qty + qty;
				//double total = new_qty * double.parse((string)v_cost);
				(this.treeviewProducts.model as ListStore).set_value(p_iter, Columns.QTY, new_qty);
				//(this.treeviewProducts.model as ListStore).set_value(p_iter, Columns.TOTAL, "%.2f".printf(total));
				this.calculateRowTotal(p_iter);
			}
			else
			{
				//##add new product to order
				var prod = new EProduct.from_id(pid);
				
				Gdk.Pixbuf remove_img = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("remove-20x20.png");//SB_ModuleInventory.GetPixbuf("remove-20x20.png");
				string? trid = EProduct.GetMeta(pid, "tax_rate_id");
				
				int tax_rate_id = (trid != null) ? int.parse(trid) : 0;
				
				double rate = 0;
				ETaxRate tax_rate = null;
				if( tax_rate_id > 0 )
				{
					tax_rate = new ETaxRate.from_id(tax_rate_id);
					rate = tax_rate.Rate;
				}
				double sub_total	= prod.Cost * qty;
				double product_tax 	= (prod.Cost * (rate / 100)) * qty;
				
				this.total_items++;
				(this.treeviewProducts.model as ListStore).append(out p_iter);
				(this.treeviewProducts.model as ListStore).set(p_iter, 
					Columns.COUNT, this.total_items,
					Columns.PRODUCT_NAME, prod.Name,
					Columns.CURRENT_QTY, prod.Quantity,
					Columns.QTY, qty,
					Columns.COST, "%.2f".printf(prod.Cost),
					Columns.SUB_TOTAL, "%.2f".printf(sub_total),
					Columns.TAX, "%.2f".printf(product_tax),
					Columns.TOTAL, "%.2f".printf( sub_total + product_tax),
					Columns.IMAGE, remove_img,
					Columns.PRODUCT_ID, prod.Id,
					Columns.TAX_RATE, rate.to_string()
				);
			}
			this.entrySearchProduct.set_data<int>("pid", 0);
			this.entrySearchProduct.text 	= "";
			this.spinbuttonProductQty.text 	= "";
			this.entrySearchProduct.grab_focus();
			this.calculateTotals();
		}
		protected void calculateRowTotal(TreeIter iter)
		{
			Value v_qty, v_cost, v_rate;
			
			this.treeviewProducts.model.get_value(iter, Columns.QTY, out v_qty);
			this.treeviewProducts.model.get_value(iter, Columns.COST, out v_cost);
			this.treeviewProducts.model.get_value(iter, Columns.TAX_RATE, out v_rate);
			
			double cost 		= double.parse((string)v_cost);
			double rate			= double.parse((string)v_rate);
			double sub_total	= (int)v_qty * cost;
			double tax_rate		= ((int)v_qty * cost) * (rate / 100);
			double total 		= sub_total + tax_rate;
			
			(this.treeviewProducts.model as ListStore).set_value(iter, Columns.SUB_TOTAL, "%.2f".printf(sub_total));
			(this.treeviewProducts.model as ListStore).set_value(iter, Columns.TAX, "%.2f".printf(tax_rate));
			(this.treeviewProducts.model as ListStore).set_value(iter, Columns.TOTAL, "%.2f".printf(total));
		}
		protected void calculateTotals()
		{
			double total_tax 	= 0;
			double total 		= 0;
			double sub_total 	= 0;
			
			this.treeviewProducts.model.foreach( (model, tree, iter) => 
			{
				Value v_subtotal, v_tax,v_total;
				model.get_value(iter, Columns.SUB_TOTAL, out v_subtotal);
				model.get_value(iter, Columns.TAX, out v_tax);
				model.get_value(iter, Columns.TOTAL, out v_total);
				
				total_tax 	+= double.parse((string)v_tax);
				sub_total	+= double.parse((string)v_subtotal);
				total 		+= double.parse((string)v_total);
				return false;
			});
			this.labelSubTotal.label	= "%.2f".printf(sub_total);
			this.labelTotalTax.label	= "%.2f".printf(total_tax);
			this.labelTotal.label 		= "%.2f".printf(total);
		}
		protected bool OnTreeViewProductsButtonReleaseEvent(Gdk.EventButton args)
		{
			TreePath path;
			TreeViewColumn column;
			int cell_x, cell_y;
			
			if( !this.treeviewProducts.get_path_at_pos((int)args.x, (int)args.y, out path, out column, out cell_x, out cell_y) )
				return false;
				
			string action = (string)column.get_data<string>("action");
			if( action == "remove_item" )
			{
				TreeModel model;
				TreeIter iter;
				if( this.treeviewProducts.get_selection().get_selected(out model, out iter) )
				{
					Value v_qty;//, v_cost, v_pid;
					model.get_value(iter, Columns.QTY, out v_qty);
					//model.get_value(iter, Columns.COST, out v_cost);
					//model.get_value(iter, Columns.PRODUCT_ID, out v_pid);
					
					int qty = (int)v_qty;
					if( qty > 1 )
					{
						qty--;
						//double total = qty * double.parse((string)v_cost);
						(model as ListStore).set_value(iter, Columns.QTY, qty);
						//(model as ListStore).set_value(iter, Columns.TOTAL, "%.2f".printf(total));
						this.calculateRowTotal(iter);
					}
					else
					{
						//##remove the treeview row
						(this.treeviewProducts.model as ListStore).remove(iter);
					}
					this.calculateTotals();
				}
			}
			return true;
		}
		protected void OnButtonSaveClicked()
		{
			if(this.comboboxStores.active_id == null || this.comboboxStores.active_id == "-1")
			{
				var err = new InfoDialog("error"){Title = SBText.__("Error"), Message = SBText.__("You need to select a store.")};
				err.run();
				err.destroy();
				return;
			}
			if( this.comboboxSuppliers.active_id == null || this.comboboxSuppliers.active_id == "-1" )
			{
				var err = new InfoDialog("error"){Title = SBText.__("Error"), Message = SBText.__("You need to select a supplier.")};
				err.run();
				err.destroy();
				return;
			}
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string cdate 	= new DateTime.now_local().format("%Y-%m-%d %H:%M:%S");
			int store_id 	= int.parse(this.comboboxStores.active_id);
			int supplier_id = int.parse(this.comboboxSuppliers.active_id);
			var store		= new SBStore.from_id(store_id);
			var transaction_type = new SBTransactionType.from_id(store.PurchaseTransactionTypeId); 
			double order_total = 0;
			double total_tax	= double.parse(this.labelTotalTax.label);
			double sub_total	= double.parse(this.labelSubTotal.label);
			
			int total_items = 0;
			//##get items
			var items = new ArrayList<HashMap>();
			this.treeviewProducts.model.foreach( (model, path, iter) => 
			{
				Value v_pid, v_qty, v_cost, v_subtotal, v_tax_rate, v_total_tax, v_total;
				
				model.get_value(iter, Columns.QTY, out v_qty);
				model.get_value(iter, Columns.COST, out v_cost);
				model.get_value(iter, Columns.SUB_TOTAL, out v_subtotal);
				model.get_value(iter, Columns.PRODUCT_ID, out v_pid);
				model.get_value(iter, Columns.TAX, out v_total_tax);
				model.get_value(iter, Columns.TAX_RATE, out v_tax_rate);
				model.get_value(iter, Columns.TOTAL, out v_total);
				
				//double item_total = (int)v_qty * double.parse((string)v_cost);
				double item_total = double.parse((string)v_total);
				order_total += item_total;
				var item = new HashMap<string, Value?>();
				item.set("product_id", (int)v_pid);
				item.set("quantity", (int)v_qty);
				item.set("supply_price", double.parse((string)v_cost));
				item.set("subtotal", double.parse((string)v_subtotal));
				item.set("tax_rate", double.parse((string)v_tax_rate));
				item.set("total_tax", double.parse((string)v_total_tax));
				item.set("discount", 0);
				item.set("total", item_total);
				item.set("last_modification_date", cdate);
				item.set("creation_date", cdate);
				items.add(item);
				total_items += (int)v_qty;
				return false;
			});
			var order = new HashMap<string, Value?>();
			order.set("store_id", store_id);
			order.set("supplier_id", supplier_id);
			order.set("items", total_items);
			order.set("subtotal", sub_total);
			order.set("total_tax", total_tax);
			order.set("discount", 0);
			order.set("total", order_total);
			order.set("details", this.entryDetails.text.strip());
			order.set("status", "waiting");
			order.set("order_date", this.datepickerOrderDate.DateString);
			order.set("delivery_date", this.datepickerDeliveryDate.DateString);
			order.set("last_modification_date", cdate);
				
			dbh.BeginTransaction();
			if( this.order == null )
			{
				//##create a new purchase order
				order.set("creation_date", cdate);
				
				long order_id = dbh.Insert("purchase_orders", order);
				//##Set purchar order code
				string code = "%s-%s".printf(transaction_type.Key, Utils.FillCeros((int)order_id, 6));
				var data = new HashMap<string, Value?>();
				var w = new HashMap<string, Value?>();
				data.set("code", code);
				w.set("order_id", order_id);
				dbh.Update("purcharse_orders", data, w);
				foreach(HashMap<string, Value?> item in items)
				{
					item.set("order_id", order_id);
					dbh.Insert("purchase_order_items", item);
				}
				
				var msg = new InfoDialog("success")
				{ 
					Title	= SBText.__("Purchase Order Placed"),
					Message = SBText.__("The order has been register and now it is waiting for stock.")
				};
				msg.run();
				msg.destroy();
			}
			else
			{
				//##update purchase order
				var w = new HashMap<string, Value?>();
				w.set("order_id", this.order.Id);
				dbh.Update("purchase_orders", order, w);
				dbh.Execute("DELETE FROM purchar_order_items WHERE order_id = %d".printf(this.order.Id));
				foreach(HashMap<string, Value?> item in items)
				{
					item.set("order_id", this.order.Id);
					dbh.Insert("purchase_order_items", item);
				}
				
				var msg = new MessageDialog(null, DialogFlags.MODAL, MessageType.INFO, ButtonsType.OK, 
											SBText.__("The order has been updated."),
											"title", SBText.__("Purchase Order Updated"));
				msg.run();
				msg.destroy();
				//##update order object
				this.order = new PurchaseOrder.from_id(this.order.Id);
			}
			dbh.EndTransaction();
			GLib.Signal.emit_by_name(this.buttonCancel, "clicked");
		}
		protected void OnButtonCancelClicked()
		{
			var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
			if( this.order == null)
				notebook.RemovePage("new-purchase-order");
			else
				notebook.RemovePage("edit-purchase-order");
		}
		public void SetOrder(PurchaseOrder order)
		{
			this.comboboxStores.active_id 	= order.StoreId.to_string();
			this.comboboxSuppliers.active_id = order.SupplierId.to_string();
			this.entryDetails.text 			= order.Details;
			this.labelSubTotal.label				= "%.2f".printf(order.SubTotal);
			this.labelTotalTax.label				= "%.2f".printf(order.TaxTotal);
			this.labelTotal.label 			= "%.2f".printf(order.Total);
			//fill items
			(this.treeviewProducts.model as ListStore).clear();
			TreeIter p_iter;
			
			foreach(SBDBRow item in order.Items)
			{
				//##add new product to order
				var prod = new SBProduct.from_id(item.GetInt("product_id"));

				Gdk.Pixbuf remove_img = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("remove-20x20.png");//SB_ModuleInventory.GetPixbuf("remove-20x20.png");
				this.total_items++;
				int qty = item.GetInt("quantity");
				double cost = item.GetDouble("supply_price");
				
				(this.treeviewProducts.model as ListStore).append(out p_iter);
				(this.treeviewProducts.model as ListStore).set(p_iter, 
					Columns.COUNT, this.total_items,
					Columns.PRODUCT_NAME, prod.Name,
					Columns.CURRENT_QTY, prod.Quantity,
					Columns.QTY, qty,
					Columns.COST, "%.2f".printf(cost),
					Columns.SUB_TOTAL, "%.2f".printf(item.GetDouble("subtotal")),
					Columns.TAX, "%.2f".printf(item.GetDouble("total_tax")),
					Columns.TOTAL, "%.2f".printf(qty * cost),
					Columns.IMAGE, remove_img,
					Columns.PRODUCT_ID, prod.Id,
					Columns.TAX_RATE, "%.2f".printf(item.GetDouble("tax_rate"))
				);
				this.calculateRowTotal(p_iter);
			}
			this.order = order;
			
			//##add button receive
			if( this.order.Status == "waiting" )
			{
				var btn_receive = new Button.with_label(SBText.__("Receive"));
				btn_receive.get_style_context().add_class("button-blue");
				btn_receive.show();
				btn_receive.clicked.connect(this.OnButtonReceiveClicked);
				this.buttonbox1.pack_start(btn_receive);
			}
			else if( this.order.Status == "completed" || this.order.Status == "cancelled" )
			{
				this.buttonSave.visible = false;
				this.buttonCancel.label = SBText.__("Close");
			}
			
		}
		protected void OnButtonReceiveClicked()
		{
			var w = new WidgetReceivePurchaseOrder(this.order);
			var nb = (SBNotebook)SBGlobals.GetVar("notebook");
			string tab_id = "receive-purchase-order-%d".printf(this.order.Id);
			
			nb.AddPage(tab_id, SBText.__("Receive Order #%s").printf(this.order.Code), w);
			nb.SetCurrentPageById(tab_id);
			/*
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.BeginTransaction();
			foreach(SBDBRow item in this.order.Items)
			{
				string query = "UPDATE products SET product_quantity = product_quantity + %d WHERE product_id = %d AND store_id = %d"
								.printf(item.GetInt("quantity"), item.GetInt("product_id"), this.order.StoreId);
				dbh.Execute(query);
			}
			string q = "UPDATE purchase_orders SET status = 'received' WHERE order_id = %d".printf(this.order.Id);
			dbh.Execute(q);
			dbh.EndTransaction();
			var msg = new MessageDialog(null, DialogFlags.MODAL, MessageType.INFO, ButtonsType.OK, 
											SBText.__("The order has been received and the product stock has been updated."),
											"title", SBText.__("Purchase Order Received"));
			msg.run();
			msg.destroy();
			GLib.Signal.emit_by_name(this.buttonCancel, "clicked");
			*/
		}
	}
}
