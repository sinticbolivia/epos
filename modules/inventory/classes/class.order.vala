using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace Woocommerce
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
		public		int NumItems
		{
			get{return this.dbData.GetInt("items");}
		}
		public		double SubTotal
		{
			get{return this.dbData.GetDouble("sub_total");}
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
			this.dbData = dbh.GetRow(query);
			
		}
		public void SetDbData(SBDBRow row)
		{
			this.dbData = row;
		}
		public void GetDbItems(int order_id)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM purchase_order_items WHERE order_id = %d".printf(order_id);
			this.items = (ArrayList<SBDBRow>)dbh.GetResults(query);
		}
	}
}
