using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Database;

namespace Woocommerce
{
	public class WidgetPendingToSyncOrders : Box
	{
		protected	Label			labelTitle;
		protected	ScrolledWindow	scrolled;
		protected	Box				boxInner;
		protected	Grid			grid;
		protected	Label			labelPendingOrdersText;
		protected	Label			labelPendingOrdersNum;
		protected	Box				boxButtons;
		protected	Button			buttonView;
		protected	Button			buttonSync;
		
		public WidgetPendingToSyncOrders(string title)
		{
			this.orientation 	= Orientation.VERTICAL;
			this.spacing		= 0;
			this.border_width 	= 5;
			
			this.labelTitle = new Label(title){xalign = 0};
			this.labelTitle.show();
			this.labelTitle.get_style_context().add_class("dashboard-widget-title");
			
			this.scrolled	= new ScrolledWindow(null, null){expand = true};
			this.scrolled.show();
			this.scrolled.get_style_context().add_class("dashboard-widget-body");
			
			this.boxInner	= new Box(Orientation.VERTICAL, 5);
			this.boxInner.show();
			this.boxInner.get_style_context().add_class("box-inner");
			
			this.grid		= new Grid(){row_spacing = 5, column_spacing = 5};
			this.grid.show();
			this.labelPendingOrdersText = new Label(SBText.__("Total Pending Orders:"));
			this.labelPendingOrdersText.show();
			
			this.labelPendingOrdersNum = new Label("0");
			this.labelPendingOrdersNum.show();
			this.labelPendingOrdersNum.get_style_context().add_class("label-number");
			
			this.boxButtons		= new Box(Orientation.HORIZONTAL, 5);
			this.boxButtons.show();
			this.buttonView		= new Button.with_label("View Orders");
			this.buttonView.show();
			this.buttonSync		= new Button.with_label("Synchonize Orders");
			this.buttonSync.show();
			
			this.grid.attach(this.labelPendingOrdersText, 0, 0, 1, 1);
			this.grid.attach(this.labelPendingOrdersNum, 1, 0, 1, 1);
			
			this.boxButtons.add(this.buttonView);
			this.boxButtons.add(this.buttonSync);
			
			this.add(this.labelTitle);
			this.add(this.scrolled);
			this.scrolled.add_with_viewport(this.boxInner);
			//this.scrolled.add_with_viewport(this.grid);
			this.boxInner.add(this.grid);
			this.boxInner.add(this.boxButtons);
			this.boxInner.set_child_packing(this.boxButtons, false, false, 5, PackType.END);
			this.GetData();
		}
		public void GetData()
		{
			int pending_orders = 0;
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT COUNT(transaction_id) AS count FROM transactions WHERE status = 'pending_sync'";
			var row = dbh.GetRow(query);
			if( row != null )
			{
				pending_orders = row.GetInt("count");
			}
			this.labelPendingOrdersNum.label = pending_orders.to_string();
		}
	}
}
