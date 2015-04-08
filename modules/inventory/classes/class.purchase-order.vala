using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace EPos
{
	public class PurchaseOrder : Order
	{
		public PurchaseOrder()
		{
			base();
		}
		public PurchaseOrder.from_id(int order_id)
		{
			//this();
			base.from_id(order_id);
		}
	}
}
