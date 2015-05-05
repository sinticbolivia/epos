using GLib;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;

namespace EPos.Woocommerce
{
	public class WindowSyncProductsProgress : Window
	{
		protected	Builder			ui;
		protected	Box				box1;
		public		Label			labelProductName;
		public		Label			labelBytes;
		public		ProgressBar		progressbarDownload;
		public		Label			labelTotalProducts;
		public		Label			labelImportedProducts;
		public		ProgressBar		progressbarGlobal;
		public		Button			buttonCancel;
		
		public WindowSyncProductsProgress()
		{
			this.title = SBText.__("Synchronizing woocommerce products");
			this.ui		= (SBModules.GetModule("Woocommerce") as SBGtkModule).GetGladeUi("widget.sync-products.glade");
			this.box1	= (Box)this.ui.get_object("box1");
			this.labelProductName	= (Label)this.ui.get_object("labelProductName");
			this.labelBytes				= (Label)this.ui.get_object("labelBytes");
			this.progressbarDownload	= (ProgressBar)this.ui.get_object("progressbarDownload");
			this.labelTotalProducts		= (Label)this.ui.get_object("labelTotalProducts");
			this.labelImportedProducts	= (Label)this.ui.get_object("labelImportedProducts");
			this.progressbarGlobal		= (ProgressBar)this.ui.get_object("progressbarGlobal");
			this.buttonCancel			= (Button)this.ui.get_object("buttonCancel");
			this.box1.reparent(this);
			this.Build();
		}
		protected void Build()
		{
			this.labelProductName.label = "";
			this.progressbarDownload.fraction = 0;
			this.progressbarGlobal.fraction = 0;
		}
	}
}
