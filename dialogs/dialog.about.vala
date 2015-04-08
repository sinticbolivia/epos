using GLib;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;

namespace EPos
{
	public class EPosAboutDialog : AboutDialog
	{
		public EPosAboutDialog()
		{
			this.authors = {"J. Marcelo Aviles Paco"};
			this.program_name = "Ecommerce Point of Sale";
			this.copyright = "Copyright @ 2004 - 2015 Sintic Bolivia";
			this.version = "1.5";
			this.license = "";
			this.website = "http://sinticbolivia.net";
			this.website_label = "Sintic Bolivia Web Site";
		}
	}
}
