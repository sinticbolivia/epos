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
				typeof(string)	//tax rate
			);
			string[,] cols = 
			{
				{"", "toggle", "50", "center", "", ""},
				{"", "markup", "50", "center", "", ""},
				{"#", "text", "50", "center", "", ""},
				{SBText.__("Product"), "text", "200", "left", "", ""},
				{SBText.__("Qty Ordered"), "text", "50", "center", "", ""},
				{SBText.__("Qty Received"), "text", "50", "center", "editable", ""},
				{SBText.__("Unit"), "text", "100", "left", "", ""},
				{SBText.__("Cost"), "text", "80", "right", "", ""},
				{SBText.__("Discount %"), "text", "80", "right", "editable", ""},
				{SBText.__("Sub Total"), "text", "100", "right", "", ""},
				{SBText.__("Discount Amount"), "text", "100", "right", "", ""},
				{SBText.__("Tax"), "text", "100", "right", "", ""},
				{SBText.__("Total"), "text", "120", "right", "", ""}
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
				(this.treeviewOrderItems.model as ListStore).append(out iter);
				(this.treeviewOrderItems.model as ListStore).set(iter,
					Columns.SELECTED, true,
					Columns.STATUS_COLOR, status_color,
					Columns.COUNT, i,
					Columns.PRODUCT_NAME, prod.Name,
					Columns.QTY_ORDERED, item.GetInt("quantity"),
					Columns.QTY_RECEIVED, item.GetInt("quantity"),
					Columns.UNIT, "",
					Columns.COST, "%.2f".printf(item.GetDouble("supply_price")),
					Columns.DISCOUNT, "0.00",
					Columns.SUB_TOTAL, "%.2f".printf(item.GetDouble("subtotal")),
					Columns.DISCOUNT_AMOUNT, "0.00",
					Columns.TAX, "%.2f".printf(item.GetDouble("total_tax")),
					Columns.TOTAL, "%.2f".printf(item.GetDouble("total")),
					Columns.ITEM_ID, item.GetInt("item_id"),
					Columns.PRODUCT_ID, item.GetInt("product_id"),
					Columns.TAX_RATE, "%.2f".printf(item.GetDouble("tax_rate"))
				);
				i++;
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
				
			TreeIter iter;
			this.treeviewOrderItems.model.get_iter(out iter, new TreePath.from_string(path));
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
			this.treeviewOrderItems.model.foreach( (model, tree, iter) => 
			{
				Value v_selected, v_qty_ordered, v_qty_received, v_item_id, v_product_id;
				model.get_value(iter, Columns.SELECTED, out v_selected);
				model.get_value(iter, Columns.QTY_ORDERED, out v_qty_ordered);
				model.get_value(iter, Columns.QTY_RECEIVED, out v_qty_received);
				model.get_value(iter, Columns.ITEM_ID, out v_item_id);
				model.get_value(iter, Columns.PRODUCT_ID, out v_product_id);
				if( (bool)v_selected )
				{
					string status = "completed";
					if( (int)v_qty_received > 0 && (int)v_qty_received < (int)v_qty_ordered )
					{
						status = "partially";
						all_received = false;
					}
					else if( (int)v_qty_received <= 0 )
					{
						status = "non_received";
						all_received = false;
					}
					
					var item = new HashMap<string, Value?>();
					item.set("quantity_received", (int)v_qty_received);
					item.set("status", status);
					var w = new HashMap<string, Value?>();
					w.set("item_id", (int)v_item_id);
					//dbh.Update("purchar_order_items", item, w);
					//##update products quantity
					string query = "UPDATE products SET product_quantity = product_quantity + %d WHERE product_id = %d".
									printf((int)v_qty_received, (int)v_product_id);
					SBModules.do_action("purchar_order_item_received", null);
				}
				return false;
			});
			string message = SBText.__("The order has been received and the products quantity has been updated.");
			string order_status = "completed";
			if( !all_received )
			{
				order_status = "partially";
				message = SBText.__("The order has been received partially, so just some products has been updated.");
			}
			var order_data = new HashMap<string, Value?>();
			order_data.set("status", order_status);
			var w = new HashMap<string, Value?>();
			w.set("order_id", this.order.Id);
			//dbh.Update("purchase_orders", order_data, w);
			SBModules.do_action("purchar_order_received", null);
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
