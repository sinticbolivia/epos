using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using Woocommerce.Invoice;

namespace EPos
{
	public class WidgetViewTransaction : Box
	{
		protected	Builder		ui;
		protected	Box			boxViewTransaction;
		protected	Image		image1;
		protected	Label		labelTitle;
		protected	TreeView	treeviewItems;
		protected	Label		labelSubtotal;
		protected	Label		labelDiscount;
		protected	Label		labelTotal;
		protected	Button		buttonClose;
		protected	Button		buttonPrint;
		protected	Button		buttonRefund;
		protected	enum		Columns
		{
			COUNT,
			ITEM,
			QTY,
			PRICE,
			TOTAL,
			N_COLS
		}
		protected	Object		transaction = null;
		protected	int			transactionId = 0;
		
		public WidgetViewTransaction()
		{
			this.ui					= (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("view-transaction.glade");
			this.boxViewTransaction	= (Box)this.ui.get_object("boxViewTransaction");
			this.image1				= (Image)this.ui.get_object("image1");
			this.labelTitle			= (Label)this.ui.get_object("labelTitle");
			this.treeviewItems		= (TreeView)this.ui.get_object("treeviewItems");
			this.labelSubtotal		= (Label)this.ui.get_object("labelSubtotal");
			this.labelDiscount		= (Label)this.ui.get_object("labelDiscount");
			this.labelTotal			= (Label)this.ui.get_object("labelTotal");
			this.buttonClose		= (Button)this.ui.get_object("buttonClose");
			this.buttonPrint		= (Button)this.ui.get_object("buttonPrint");
			this.buttonRefund		= (Button)this.ui.get_object("buttonRefund");
			this.Build();
			this.SetEvents();
			this.boxViewTransaction.reparent(this);
		}
		protected void Build()
		{
			string[,] cols = 
			{
				{"#", "text", "70", "center", "", ""},
				{SBText.__("Item"), "text", "200", "left", "", ""},
				{SBText.__("Qty"), "text", "70", "center", "", ""},
				{SBText.__("Price"), "text", "90", "right", "", ""},
				{SBText.__("Total"), "text", "90", "right", "", ""}
			};
			this.treeviewItems.model = new ListStore(Columns.N_COLS,
				typeof(int),
				typeof(string),
				typeof(int),
				typeof(string),
				typeof(string)
			);
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewItems);
		}
		protected void SetEvents()
		{
			this.buttonClose.clicked.connect( () => 
			{
				string tab_id = "view-transaction";//this.transactionId > 0 ? "edit-transaction" : "view-transaction";
				var nb = (SBNotebook)SBGlobals.GetVar("notebook");
				nb.RemovePage(tab_id);
			});
			this.buttonPrint.clicked.connect(this.OnButtonPrintClicked);
		}
		protected void OnButtonPrintClicked()
		{
			int width = 200;// * Pango.SCALE;
			int height = 400;// * Pango.SCALE;
			/*
			Cairo.PdfSurface surface = new Cairo.PdfSurface.for_stream((data) => {return Cairo.Status.SUCCESS;}, 
					width,
					height
			);
			Cairo.Context cr = new Cairo.Context(surface);
			*/
			TicketInvoice ticket = new TicketInvoice();
			ticket.SetWidth(width);
			ticket.AddLine("Invoice", "center");
			ticket.AddLine("Subtotal: 0.00", "center");
			ticket.AddLine("Discount: 0.00", "right");
			ticket.AddLine("Total: 0.00", "right");
			/*
			var layout = new Layout(null, null){expand = true};
			layout.set_size((uint)width, (uint)height);
			layout.show();
			*/
			var area = new DrawingArea();
			area.show();
			area.set_size_request(400, 700);
			var scroll = new ScrolledWindow(null, null);
			scroll.expand = true;
			scroll.add(area);
			scroll.show();
			
			var dlg = new Dialog();
			dlg.get_content_area().add(scroll);
			
			dlg.set_size_request(400, 400);
			area.draw.connect( (ctx) => 
			{
				stdout.printf("-- draw --\n");
				/*
				//var bin_window = layout.get_bin_window();
				//if( cairo_should_draw_window(ctx, bin_window) )
				{
					stdout.printf("-- drawing --\n");
					ctx.set_source_rgb(0.9, 0, 0.1); //#rosso
					ctx.save();
					//cairo_transform_to_window(ctx, layout, bin_window);
					ticket.SetContext(ctx);
					ticket.buildPageFrame();
					ticket.Draw();
					ctx.restore();
					
				}
				*/
				weak Gtk.StyleContext style_context = area.get_style_context ();
				int _height = area.get_allocated_height ();
				int _width = area.get_allocated_width ();
				Gdk.RGBA color = style_context.get_color (0);

				// Draw an arc:
				double xc = _width / 2.0;
				double yc = _height / 2.0;
				double radius = int.min (_width, _height) / 2.0;
				double angle1 = 0;
				double angle2 = 2*Math.PI;

				ctx.arc (xc, yc, radius, angle1, angle2);
				Gdk.cairo_set_source_rgba (ctx, color);
				ctx.fill ();
				return true;
			});
			dlg.show_all();
			//layout.queue_draw();
		}
		public void SetTransaction(Object t)
		{
			this.transaction = t;
			int i = 1;
			TreeIter iter;
			if( t.get_type() == typeof(PurchaseOrder) )
			{
				this.labelTitle.label = SBText.__("View Order");
				var _t = (PurchaseOrder)t;
				this.labelTitle.label = SBText.__("View Sale");
				this.labelSubtotal.label = "%.2f".printf(_t.SubTotal);
				this.labelDiscount.label = "%.2f".printf(_t.Discount);
				this.labelTotal.label	= "%.2f".printf(_t.Total);
				foreach(var item in _t.Items)
				{
					(this.treeviewItems.model as ListStore).append(out iter);
					(this.treeviewItems.model as ListStore).set(iter, 
						Columns.COUNT, i,
						Columns.ITEM, item.Get("name"),
						Columns.QTY, item.GetInt("quantity"),
						Columns.PRICE, "%.2f".printf(item.GetDouble("supply_price")),
						Columns.TOTAL, "%.2f".printf(item.GetDouble("total"))
					);
					i++;
				}
			}
			else if( t.get_type() == typeof(SBTransaction) )
			{
				var _t = (SBTransaction)t;
				this.labelTitle.label = SBText.__("View Sale");
				this.labelSubtotal.label = "%.2f".printf(_t.SubTotal);
				this.labelDiscount.label = "%.2f".printf(_t.Discount);
				this.labelTotal.label	= "%.2f".printf(_t.Total);
				foreach(var item in _t.Items)
				{
					(this.treeviewItems.model as ListStore).append(out iter);
					(this.treeviewItems.model as ListStore).set(iter, 
						Columns.COUNT, i,
						Columns.ITEM, "",
						Columns.QTY, item.Quantity,
						Columns.PRICE, "%.2f".printf(item.Price),
						Columns.TOTAL, "%.2f".printf(item.Total)
					);
				}
				i++;
			}
			
		}
	}
}
