using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Database;

namespace Woocommerce
{
	public class Sale : Object
	{
		protected SBDBRow dbData;
		
		public Sale()
		{
			base();
			
		}
		/*
		public void Sale.from_id(int sale_id)
		{
			this();
		}
		public void GetDbData(int sale_id)
		{
		}
		*/
	}
}
