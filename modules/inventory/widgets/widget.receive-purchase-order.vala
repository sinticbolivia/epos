using GLib;
using Gee;
using Gtk;
using SinticBolivia.Gtk;
using SinticBolivia;
using SinticBolivia.Database;
using Woocommerce;

namespace EPos
{
	public class WidgetReceivePurchaseOrder : Box
	{
		enum Columns
		{
			SELECTED,
			STATUS_COLOR,
			COUNT,
			PRODUCT_NAME,
			QTY_ORDERED,
			TOTAL_RECEIVED,
			QTY_RECEIVED,
			UNIT,
			COST,
			DISCOUNT,
			SUB_TOTAL,
			DISCOUNT_AMOUNT,
			TAX,
			TOTAL,
			ITEM_ID,
			PRODUCT_ID,
			TAX_RATE,
			STATUS,
			N_COLS
		}
		protected	Builder			ui;
		protected	Box				boxReceivePurchaseOrder;
		protected	Image			image1;
		protected	Label			labelPurchaseOrderCode;
		protected	Label			labelOrderDate;
		protected	Label			labelReceiverStore;
		protected	Label			labelSupplierName;
		protected	TreeView		treeviewOrderItems;
		protected	Label			labelProductTaxRate;
		protected	Label			labelSubTotal;
		protected	Label			labelTotalTax;
		protected	Label			labelTotalDiscount;
		protected	Label			labelTotal;
		protected	Button			buttonCancel;
		protected	Button			buttonReceive;
		protected	PurchaseOrder	order;
		
		public WidgetReceivePurchaseOrder(PurchaseOrder order)
		{
			this.order			= order;
			this.ui				= (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("receive-purchase-order.glade");
			this.boxReceivePurchaseOrder		= (Box)this.ui.get_object("boxReceivePurchaseOrder");
			this.image1							= (Image)this.ui.get_object("image1");
			this.labelPurchaseOrderCode			= (Label)this.ui.get_object("labelPurchaseOrderCode");
			this.labelOrderDate					= (Label)this.ui.get_object("labelOrderDate");
			this.labelReceiverStore				= (Label)this.ui.get_object("labelReceiverStore");
			this.labelSupplierName				= (Label)this.ui.get_object("labelSupplierName");
			this.treeviewOrderItems				= (TreeView)this.ui.get_object("treeviewOrderItems");
			this.labelProductTaxRate			= (Label)this.ui.get_object("labelProductTaxRate");
			this.labelSubTotal					= (Label)this.ui.get_object("labelSubTotal");
			this.labelTotalTax					= (Label)this.ui.get_object("labelTotalTax");
			this.labelTotalDiscount				= (Label)this.ui.get_object("labelTotalDiscount");
			this.labelTotal						= (Label)this.ui.get_object("labelTotal");
			this.buttonCancel					= (Button)this.ui.get_object("buttonCancel");
			this.buttonReceive					= (Button)this.ui.get_object("buttonReceive");
			
			this.boxReceivePurchaseOrder.reparent(this);
			this.Build();
			this.FillOrder();
			this.SetEvents();
		}
		protected void Build()
		{
			this.image1.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("receive-order-icon-64x64.png");
			this.treeviewOrderItems.model = new ListStore(Columns.N_COLS,
				typeof(bool), //selected
				typeof(string),
				typeof(int), //count
				typeof(string), //product name
				typeof(int), //qty ordered
				typeof(int),	//total received
				typeof(int), //qty received
				typeof(string), //U.O.M
				typeof(string), //cost
				typeof(string), //discount
				typeof(string), //sub total
				typeof(string), //discount amount
				typeof(string), //tax
				typeof(string), //total
				typeof(int),	//item id
				typeof(int),	//product id
				typeof(string),	//tax rate
				typeof(string)
			);
			string[,] cols = 
			{
				{"", "toggle", "30", "center", "", ""},
				{"", "markup", "30", "center", "", ""},
				{"#", "text", "40", "center", "", ""},
				{SBText.__("Product"), "text", "200", "left", "", ""},
				{SBText.__("Qty Ordered"), "text", "50", "center", "", ""},
				{SBText.__("Received so far"), "text", "50", "center", "", ""},
				{SBText.__("Qty to Receive"), "text", "50", "center", "editable", ""},
				{SBText.__("Unit"), "text", "100", "left", "", ""},
				{SBText.__("Cost"), "text", "80", "right", "", ""},
				{SBText.__("Discount %"), "text", "80", "right", "editable", ""},
				{SBText.__("Sub Total"), "text", "90", "right", "", ""},
				{SBText.__("Discount Amount"), "text", "100", "right", "", ""},
				{SBText.__("Tax"), "text", "70", "right", "", ""},
				{SBText.__("Total"), "text", "90", "right", "", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewOrderItems);
			this.treeviewOrderItems.rules_hint = true;
			//this.treeviewOrderItems.hover_selection = true;
			
		}
		protected void FillOrder()
		{
			this.labelPurchaseOrderCode.label 	= this.order.Code;
			this.labelReceiverStore.label		= "";
			this.labelSupplierName.label		= "";
			this.labelOrderDate.label = this.order.OrderDate;
			this.labelSubTotal.label = "%.2f".printf(this.order.SubTotal);
			this.labelTotalTax.label = "%.2f".printf(this.order.TaxTotal);
			this.labelTotal.label		= "%.2f".printf(this.order.Total);
			TreeIter iter;
			int i = 1;
			foreach(var item in this.order.Items)
			{
				string status = item.Get("status");
				string status_color = "<span bgcolor=\"%s\" fgcolor=\"%s\">%s</span>";
				if( status == "completed" )
				{
					status_color = status_color.printf("#73D216", "#73D216", status);
				}
				else if( status == "partially")
				{
					status_color = status_color.printf("#C4A000", "#C4A000", status);
				}
				else
				{
					status_color = status_color.printf("#CC0000", "#CC0000", status);
				}
				var prod = new EPos.EProduct.from_id(item.GetInt("product_id"));
				int qty_total_received = item.GetInt("quantity_received");
				int qty_ordered	= item.GetInt("quantity");
				int qty_to_receive = 0;
				
				if( qty_total_received > 0 && qty_total_received < qty_ordered )
				{
					qty_to_receive = qty_ordered - qty_total_received;
				}
				else
				{
					qty_to_receive = qty_ordered;
				}
				double tax_rate 	= item.GetDouble("tax_rate");
				double supply_price = item.GetDouble("supply_price");
				double subtotal 	= qty_to_receive * supply_price;
				double tax_amount 	= subtotal * (tax_rate/100);
				double total		= subtotal + tax_amount;
				
				(this.treeviewOrderItems.model as ListStore).append(out iter);
				(this.treeviewOrderItems.model as ListStore).set(iter,
					Columns.SELECTED, true,
					Columns.STATUS_COLOR, status_color,
					Columns.COUNT, i,
					Columns.PRODUCT_NAME, prod.Name,
					Columns.QTY_ORDERED, item.GetInt("quantity"),
					Columns.TOTAL_RECEIVED, qty_total_received,
					Columns.QTY_RECEIVED, qty_to_receive,
					Columns.UNIT, "",
					Columns.COST, "%.2f".printf(supply_price),
					Columns.DISCOUNT, "0.00",
					Columns.SUB_TOTAL, "%.2f".printf(subtotal),
					Columns.DISCOUNT_AMOUNT, "0.00",
					Columns.TAX, "%.2f".printf(tax_amount),
					Columns.TOTAL, "%.2f".printf(total),
					Columns.ITEM_ID, item.GetInt("item_id"),
					Columns.PRODUCT_ID, item.GetInt("product_id"),
					Columns.TAX_RATE, "%.2f".printf(tax_rate),
					Columns.STATUS, status
				);
				i++;
				
			}
			this.CalculateTotals();
			if( this.order.Status == "completed" || this.order.Status == "cancelled")
			{
				this.buttonReceive.visible = false;
				this.buttonCancel.label = SBText.__("Close");
			}
		}
		protected void SetEvents()
		{
			this.treeviewOrderItems.cursor_changed.connect( () => 
			{
				TreeModel model;
				TreeIter iter;
				this.treeviewOrderItems.get_selection().get_selected(out model, out iter);
				
				Value tax_rate;
				model.get_value(iter, Columns.TAX_RATE, out tax_rate);
				this.labelProductTaxRate.label = "%s".printf((string)tax_rate + "%");
				//stdout.printf("tax rate: %s\n", (string)tax_rate);
			});
			var cell_qty_received = (CellRendererText)this.treeviewOrderItems.get_column(Columns.QTY_RECEIVED).get_cells().nth_data(0);
			var cell_discount = (CellRendererText)this.treeviewOrderItems.get_column(Columns.DISCOUNT).get_cells().nth_data(0);
			cell_qty_received.edited.connect(this.OnCellQtyReceivedEdited);
			cell_discount.edited.connect(this.OnCellDiscountEdited);
			
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
			this.buttonReceive.clicked.connect(this.OnButtonReceiveClicked);
		}
		protected void OnCellQtyReceivedEdited(string path, string text)
		{
			int qty = int.parse(text.strip());
			Value v_qty_ordered, v_qty_received_so_far;
			TreeIter iter;
			this.treeviewOrderItems.model.get_iter(out iter, new TreePath.from_string(path));
			
			this.treeviewOrderItems.model.get_value(iter, Columns.QTY_ORDERED, out v_qty_ordered);
			this.treeviewOrderItems.model.get_value(iter, Columns.TOTAL_RECEIVED, out v_qty_received_so_far);
			
			int qty_left = (int)v_qty_ordered - (int)v_qty_received_so_far;
			
			if( qty > qty_left )
			{
				var info = new InfoDialog()
				{
					Title = SBText.__("Quantity received error"),
					Message = SBText.__("The quantity to receive is higher than the quantity you have ordered.")
				};
				info.run();
				info.destroy();
				qty = qty_left;
			}
			
			(this.treeviewOrderItems.model as ListStore).set_value(iter, Columns.QTY_RECEIVED, qty);
			this.CalculateRowTotal(iter);
			this.CalculateTotals();
		}
		protected void OnCellDiscountEdited(string path, string text)
		{
			double discount = double.parse(text.strip());
				
			TreeIter iter;
			this.treeviewOrderItems.model.get_iter(out iter, new TreePath.from_string(path));
			(this.treeviewOrderItems.model as ListStore).set_value(iter, Columns.DISCOUNT, "%.2f".printf(discount));
			this.CalculateRowTotal(iter);
			this.CalculateTotals();
		}
		protected void CalculateRowTotal(TreeIter iter)
		{
			Value v_qty_received, v_cost, v_discount, v_tax_rate;
			this.treeviewOrderItems.model.get_value(iter, Columns.QTY_RECEIVED, out v_qty_received);
			this.treeviewOrderItems.model.get_value(iter, Columns.COST, out v_cost);
			this.treeviewOrderItems.model.get_value(iter, Columns.DISCOUNT, out v_discount);
			this.treeviewOrderItems.model.get_value(iter, Columns.TAX_RATE, out v_tax_rate);
			
			int qty_received = (int)v_qty_received;
			double cost 	= double.parse((string)v_cost);
			double discount	= double.parse((string)v_discount);
			double tax_rate	= double.parse((string)v_tax_rate);
			
			double sub_total 		= qty_received * cost;
			double total_discount 	= sub_total * (discount / 100);
			double total_tax		= (sub_total - total_discount) * (tax_rate/100);
			double total			= (sub_total - total_discount) + total_tax;
			
			(this.treeviewOrderItems.model as ListStore).set(iter, 
				Columns.SUB_TOTAL, "%.2f".printf(sub_total),
				Columns.DISCOUNT_AMOUNT, "%.2f".printf(total_discount),
				Columns.TAX, "%.2f".printf(total_tax),
				Columns.TOTAL, "%.2f".printf(total)
			);
		}
		protected void CalculateTotals()
		{
			double sub_total 		= 0;
			double total_tax 		= 0;
			double total_discount	= 0;
			double total 			= 0;
			
			this.treeviewOrderItems.model.foreach( (model, tree, iter) => 
			{
				Value v_subtotal, v_tax, v_discount, v_total;
				model.get_value(iter, Columns.SUB_TOTAL, out v_subtotal);
				model.get_value(iter, Columns.TAX, out v_tax);
				model.get_value(iter, Columns.DISCOUNT_AMOUNT, out v_discount);
				model.get_value(iter, Columns.TOTAL, out v_total);
				
				sub_total		+= double.parse((string)v_subtotal);
				total_tax 		+= double.parse((string)v_tax);
				total_discount	+= double.parse((string)v_discount);
				total 			+= double.parse((string)v_total);
				return false;
			});
			this.labelSubTotal.label = "%.2f".printf(sub_total);
			this.labelTotalTax.label = "%.2f".printf(total_tax);
			this.labelTotalDiscount.label = "%.2f".printf(total_discount);
			this.labelTotal.label = "%.2f".printf(total);
		}
		protected void OnButtonCancelClicked()
		{
			var nb = (SBNotebook)SBGlobals.GetVar("notebook");
			nb.RemovePage("receive-purchase-order-%d".printf(this.order.Id));
		}
		protected void OnButtonReceiveClicked()
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			bool all_received = true;
			int total_items = 0;
			string delivery_notes = "";
			var delivery_items = new ArrayList<HashMap<string, Value?>>();
			this.treeviewOrderItems.model.foreach( (model, tree, iter) => 
			{
				Value v_selected, v_qty_ordered, v_qty_total_received, v_qty_received, v_discount, v_subtotal, v_tax_amount,
						v_total, v_item_id, v_product_id, v_current_status;
						
				model.get_value(iter, Columns.SELECTED, out v_selected);
				model.get_value(iter, Columns.QTY_ORDERED, out v_qty_ordered);
				model.get_value(iter, Columns.TOTAL_RECEIVED, out v_qty_total_received);
				model.get_value(iter, Columns.QTY_RECEIVED, out v_qty_received);
				model.get_value(iter, Columns.DISCOUNT_AMOUNT, out v_discount);
				model.get_value(iter, Columns.SUB_TOTAL, out v_subtotal);
				model.get_value(iter, Columns.TAX, out v_tax_amount);
				model.get_value(iter, Columns.TOTAL, out v_total);
				model.get_value(iter, Columns.ITEM_ID, out v_item_id);
				model.get_value(iter, Columns.PRODUCT_ID, out v_product_id);
				model.get_value(iter, Columns.STATUS, out v_current_status);
				
				if( (bool)v_selected && (string)v_current_status != "completed" )
				{
					int received_so_far = (int)v_qty_total_received + (int)v_qty_received;
					string status = "";
					string note	= "";
					if( received_so_far > 0 && received_so_far < (int)v_qty_ordered )
					{
						status = "partially";
						all_received = false;
						note = SBText.__("Order item #%d partially received, quantity received is %d of %d").printf((int)v_item_id, (int)v_qty_received, (int)v_qty_ordered);
					}
					else if( received_so_far <= 0 )
					{
						status = "non_received";
						all_received = false;
						note = SBText.__("Order item #%d non received, quantity received is 0").printf((int)v_item_id);
					}
					else if( received_so_far == (int)v_qty_ordered)
					{
						status = "completed";
						all_received = false;
						note = SBText.__("Order item #%d received complety, quantity received is %d of %d").printf((int)v_item_id, (int)v_qty_received, (int)v_qty_ordered);
					}
					//##update order item
					var order_item = new HashMap<string, Value?>();
					order_item.set("quantity_received", received_so_far);
					order_item.set("status", status);
					
					var w = new HashMap<string, Value?>();
					w.set("item_id", (int)v_item_id);
					dbh.Update("purchase_order_items", order_item, w);
					
					//##update products quantity
					string query = "UPDATE products SET product_quantity = product_quantity + %d WHERE product_id = %d".
									printf((int)v_qty_received, (int)v_product_id);
					total_items += (int)v_qty_received;
					//##build delivery item
					var delivery_item = new HashMap<string, Value?>();
					delivery_item.set("quantity_ordered", (int)v_qty_ordered);
					delivery_item.set("supply_price", 0);
					delivery_item.set("quantity_delivered", (int)v_qty_received);
					delivery_item.set("sub_total", (int)v_qty_ordered);
					delivery_item.set("total_tax", double.parse((string)v_tax_amount));
					delivery_item.set("discount", double.parse((string)v_discount));
					delivery_item.set("total", double.parse((string)v_total));
					delivery_item.set("creation_date", new DateTime.now_local().format("%Y-%m-%d %H:%M:%S"));
					delivery_items.add(delivery_item);
					SBModules.do_action("purchar_order_item_received", null);
				}
				return false;
			});
			//##insert purchase order delivery
			var delivery = new HashMap<string, Value?>();
			delivery.set("order_id", this.order.Id);
			delivery.set("items", total_items);
			delivery.set("sub_total", double.parse(this.labelSubTotal.label));
			delivery.set("total_tax", double.parse(this.labelTotalTax.label));
			delivery.set("discount", double.parse(this.labelTotalDiscount.label));
			delivery.set("total", double.parse(this.labelTotal.label));
			delivery.set("notes", delivery_notes);
			delivery.set("data", "");
			delivery.set("creation_date", new DateTime.now_local().format("%Y-%m-%d %H:%M:%S"));
			int delivery_id = (int)dbh.Insert("purchase_order_deliveries", delivery);
			//##insert delivery items
			foreach(var item in delivery_items)
			{
				item.set("delivery_id", delivery_id);
				dbh.Insert("purchase_order_delivery_items", item);
			}
			
			
			string message = SBText.__("The order has been received and the products quantity has been updated.");
			string order_status = "completed";
			if( !all_received )
			{
				order_status = "partially";
				message = SBText.__("The order has been received partially, so just some products has been updated.");
			}
			//##update purchase order data
			var order_data = new HashMap<string, Value?>();
			order_data.set("status", order_status);
			var w = new HashMap<string, Value?>();
			w.set("order_id", this.order.Id);
			dbh.Update("purchase_orders", order_data, w);
			
			SBModules.do_action("purchase_order_received", null);
			var msg = new InfoDialog("success")
			{
				Title 	= SBText.__("Purchase order received"),
				Message = message
			};
			msg.run();
			msg.destroy();
			GLib.Signal.emit_by_name(this.buttonCancel, "clicked");
		}
	}
}
