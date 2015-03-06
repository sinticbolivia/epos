using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace EPos
{
	public class ESale : SBDbObject
	{
		public		int						Id
		{
			get{return this.dbData.GetInt("sale_id");}
			set{this.dbData.Set("sale_id", value.to_string());}
		}
		public		string					Code
		{
			get{return this.dbData.Get("code");}
			set{this.dbData.Set("code", value);}
		}
		public		int						StoreId
		{
			get{return this.dbData.GetInt("store_id");}
			set{this.dbData.Set("store_id", value.to_string());}
		}
		public		int						CashierId
		{
			get{return this.dbData.GetInt("cashier_id");}
			set{this.dbData.Set("cashier_id", value.to_string());}
		}
		public		int						CustomerId
		{
			get{return this.dbData.GetInt("customer_id");}
			set{this.dbData.Set("customer_id", value.to_string());}
		}
		public		string					Notes
		{
			get{return this.dbData.Get("notes");}
			set{this.dbData.Set("notes", value);}
		}
		public		double					SubTotal
		{
			get{return this.dbData.GetDouble("sub_total");}
			set{this.dbData.Set("sub_total", value.to_string());}
		}
		public		double					TaxRate
		{
			get{return this.dbData.GetDouble("tax_rate");}
			set{this.dbData.Set("tax_rate", value.to_string());}
		}
		public		double					TaxAmount
		{
			get{return this.dbData.GetDouble("tax_amount");}
			set{this.dbData.Set("tax_amount", value.to_string());}
		}
		public		double					Discount
		{
			get{return this.dbData.GetDouble("discount_total");}
			set{this.dbData.Set("discount_total", value.to_string());}
		}
		public		double					Total
		{
			get{return this.dbData.GetDouble("total");}
			set{this.dbData.Set("total", value.to_string());}
		}
		public		string					Status
		{
			get{return this.dbData.Get("status");}
			set{this.dbData.Set("status", value);}
		}
		public		string					CreationDate
		{
			get{return this.dbData.Get("creation_date");}
			set{this.dbData.Set("creation_date", value);}
		}
		public		ArrayList<ESaleItem>	Items;
		public		HashMap<string, Value?>? Customer = null;
		
		public ESale()
		{
			this.dbData = new SBDBRow();
			this.Items = new ArrayList<ESaleItem>();
		}
		public ESale.from_id(int id)
		{
			this();
		}
		public ESale.with_db_data(SBDBRow row)
		{
			this();
			this.dbData = row;
			if( this.CustomerId > 0 )
			{
				this.Customer = EPosHelper.GetCustomer(this.CustomerId);
			}
		}
		public void GetDbData(int id)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("sales").Where("sale_id = %d".printf(this.Id));
			var row = dbh.GetRow(null);
			if( row == null )
				return;
			this.dbData = row;
			if( this.CustomerId > 0 )
			{
				this.Customer = EPosHelper.GetCustomer(this.CustomerId);
			}
		}
		public void GetDbItems()
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("sale_items").Where("sale_id = %d".printf(this.Id));
			foreach(var item in dbh.GetResults(null))
			{
				var _item = new ESaleItem.with_db_data(item);
				this.Items.add(_item);
			}
		}
		public void SetDbItems(ArrayList<SBDBRow> items)
		{
			foreach(var item in items)
			{
				var _item = new ESaleItem.with_db_data(item);
				this.Items.add(_item);
			}
		}
		
	}
}
