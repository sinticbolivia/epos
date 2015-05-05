using GLib;
using Gee;
using Gtk;
using SinticBolivia;

namespace Woocommerce
{
	public class WidgetRestautantOptions : Box
	{
		protected	Builder		ui;
		
		protected	Window		windowOptions;
		protected	Box			boxOptions;
		protected	TreeView	treeviewOptions;
		
		
		public WidgetRestautantOptions()
		{
			this.ui 				= SB_ModuleRestaurant.GetGladeUi("options.glade");
			
			this.windowOptions		= (Window)this.ui.get_object("windowOptions");
			this.boxOptions			= (Box)this.ui.get_object("boxOptions");
			this.treeviewOptions	= (TreeView)this.ui.get_object("treeviewOptions");
			
			this.Build();
			this.SetEvents();
			this.boxOptions.reparent(this);
		}
		protected void Build()
		{
			this.treeviewOptions.model = new ListStore(3, typeof(int), typeof(string), typeof(string));
			this.treeviewOptions.insert_column_with_attributes(0, SBText.__("ID"), 
							new CellRendererText(){xalign = 0.5f, width = 80},
							"text", 0
			);
			this.treeviewOptions.insert_column_with_attributes(1, SBText.__("Option"), 
							new CellRendererText(){ width = 170},
							"text", 1
			);
			this.treeviewOptions.insert_column_with_attributes(2, SBText.__("Price"), 
							new CellRendererText(){xalign = 1f, width = 90},
							"text", 2
			);
		}
		public void SetEvents()
		{
			this.destroy.connect( () => 
			{
				this.boxOptions.reparent(this.windowOptions);
			});
		}
	}
}
