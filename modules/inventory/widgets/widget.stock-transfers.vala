using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetStockTransfers : Box
	{
		protected		Builder		ui;
		protected		Box			boxStockTransfer;
		protected		Image		image1;
		protected		Button		buttonRequest;
		protected		Button		buttonReceive;
		protected		TreeView	treeviewTransfers;
		
		public WidgetStockTransfers()
		{
			this.ui					= (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("stock-transfer.glade");
			this.boxStockTransfer	= (Box)this.ui.get_object("boxStockTransfer");
			this.image1				= (Image)this.ui.get_object("image1");
			this.buttonRequest		= (Button)this.ui.get_object("buttonRequest");
			this.buttonReceive		= (Button)this.ui.get_object("buttonReceive");
			this.treeviewTransfers	= (TreeView)this.ui.get_object("treeviewTransfers");
			
			this.boxStockTransfer.reparent(this);
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			this.image1.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("stock-transfer-icon-64x64.png");
		}
		protected void SetEvents()
		{
			this.buttonRequest.clicked.connect(this.OnButtonRequestClicked);
			this.buttonReceive.clicked.connect(this.OnButtonReceiveClicked);
		}
		protected void OnButtonRequestClicked()
		{
		}
		protected void OnButtonReceiveClicked()
		{
		}
	}
}
