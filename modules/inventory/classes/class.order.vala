using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace EPos
{
	public class Order : Object
	{
		protected SBDBRow dbData;
		protected ArrayList<SBDBRow> items;
		
		public		int Id
		{
			get{return this.dbData.GetInt("order_id");}
		}
		public		string Code
		{
			get{return this.dbData.Get("code");}
		}
		public		int StoreId
		{
			get{return this.dbData.GetInt("store_id");}
		}
		public		int SupplierId
		{
			get{return this.dbData.GetInt("supplier_id");}
		}
		public		int NumItems
		{
			get{return this.dbData.GetInt("items");}
		}
		public		double SubTotal
		{
			get{return this.dbData.GetDouble("subtotal");}
		}
		public		double TaxTotal
		{
			get{return this.dbData.GetDouble("total_tax");}
		}
		public		double Discount
		{
			get{return this.dbData.GetDouble("discount");}
		}
		public		double Total
		{
			get{return this.dbData.GetDouble("total");}
		}
		public		string Details
		{
			get{return this.dbData.Get("details");}
		}
		public		string Status
		{
			get{return this.dbData.Get("status");}
		}
		public		int UserId
		{
			get{return this.dbData.GetInt("user_id");}
		}
		public		SBUser	User;
		public 		string OrderDate
		{
			get{return this.dbData.Get("order_date");}
		}
		public 		string DeliveryDate
		{
			get{return this.dbData.Get("delivery_date");}
		}
		public		string LastModificationDate
		{
			get{return this.dbData.Get("last_modification_date");}
		}
		public		string CreationDate
		{
			get{return this.dbData.Get("creation_date");}
		}
		public		ArrayList<SBDBRow> Items
		{
			get{return this.items;}
		}
		public Order()
		{
			this.dbData = new SBDBRow();
			this.items = new ArrayList<SBDBRow>();
			this.User = new SBUser();
		}
		public Order.from_id(int order_id)
		{
			this();
			this.GetDbData(order_id);
			this.GetDbItems(order_id);
		}
		public void GetDbData(int order_id)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM purchase_orders WHERE order_id = %d".printf(order_id);
			var row = dbh.GetRow(query);
			if( row == null )
				return;
				
			this.dbData = row;
			
		}
		public void SetDbData(SBDBRow row)
		{
			this.dbData = row;
		}
		public void GetDbItems(int order_id)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("purchase_order_items").Where("order_id = %d".printf(order_id));
			
			this.items = dbh.GetResults(null);
		}
	}
}
