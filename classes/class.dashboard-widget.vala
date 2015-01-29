using GLib;
using Gtk;

namespace Woocommerce
{
	class SBDashboardWidget : EventBox //Widget
	{
		public string 	Title
		{
			get
			{
				return this._labelTitle.label;
			}
			set
			{
				this._labelTitle.label = value;
			}
		}
		public 		Box		Content;
		protected	Label	_labelTitle;
		
		public SBDashboardWidget(string title)
		{
			GLib.Object();
			this.get_style_context().add_class("dashboard-widget");
			var evtbox = new EventBox();
			evtbox.get_style_context().add_class("wrap");
			
			//this.set_has_window(false);
			this._labelTitle = new Label(null);
			this._labelTitle.get_style_context().add_class("title");
			this.Content = new Box(Orientation.VERTICAL, 5);
			this.Content.add(this._labelTitle);
			this.Title = title;
			this.set_size_request(200, 200);						
			
			evtbox.add(this.Content);
			evtbox.show_all();
			this.add(evtbox);
		}
	}
}
