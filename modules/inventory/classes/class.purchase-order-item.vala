using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace EPos
{
	public class EPurchaseOrderItem : Object
	{
		protected	SBDBRow		dbData;
		
		public		int			Id
		{
			get{return this.dbData.GetInt("item_id");}
		}
		public		int			ProductId
		{
			get{return this.dbData.GetInt("product_id");}
		}
		public		int			OrderId
		{
			get{return this.dbData.GetInt("order_id");}
		}
		public		string		Name
		{
			get{return this.dbData.Get("name");}
		}
		public		int			QtyOrdered
		{
			get{return this.dbData.GetInt("quantity");}
		}
		public		int			QtyReceived
		{
			get{return this.dbData.GetInt("quantity_received");}
		}
		public		double		SupplyPrice
		{
			get{return this.dbData.GetDouble("supply_price");}
		}
		public		double		SubTotal
		{
			get{return this.dbData.GetDouble("subtotal");}
		}
		public		double		TotalTax
		{
			get{return this.dbData.GetDouble("total_tax");}
		}
		public		double		Discount
		{
			get{return this.dbData.GetDouble("discount");}
		}
		public		double		Total
		{
			get{return this.dbData.GetDouble("total");}
		}
		public		string		Status
		{
			get{return this.dbData.Get("status");}
		}
		public EPurchaseOrderItem()
		{
			this.dbData = new SBDBRow();
		}
		public EPurchaseOrderItem.from_id(int id)
		{
			this();
			this.GetDbData(id);
		}
		public EPurchaseOrderItem.with_db_data(SBDBRow data)
		{
			this();
			this.dbData = data;
		}
		public void GetDbData(int id)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("purchase_order_items").Where("item_id = %d".printf(id));
			var row = dbh.GetRow(null);
			if( row == null )
				return;
			this.dbData = row;
		}
	}
}
