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
		/*
		public		int						UserId
		{
			get{return this.dbData.GetInt("user_id");}
			set{this.dbData.set("user_id", value.to_string());}
		}
		*/
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
		public		HashMap<string, string>? Customer = null;
		public		HashMap<string, Value?>		Meta;
		public ESale()
		{
			this.dbData = new SBDBRow();
			this.Items = new ArrayList<ESaleItem>();
			this.Meta	= new HashMap<string, Value?>();
		}
		public ESale.from_id(int id)
		{
			this();
			this.GetDbData(id);
		}
		public ESale.with_db_data(SBDBRow row)
		{
			this();
			this.dbData = row;
			if( this.CustomerId > 0 )
			{
				this.Customer = EPosHelper.GetCustomer(this.CustomerId, this.Dbh);
			}
		}
		public void GetDbData(int id)
		{
			this.Dbh.Select("*").From("sales").Where("sale_id = %d".printf(this.Id));
			var row = this.Dbh.GetRow(null);
			if( row == null )
				return;
			this.dbData = row;
			if( this.CustomerId > 0 )
			{
				this.Customer = EPosHelper.GetCustomer(this.CustomerId, this.Dbh);
			}
			this.GetDbItems();
			this.GetDbMeta();
		}
		public void GetDbItems()
		{
			if( this.Items.size > 0 )
				return;
				
			this.Dbh.Select("*").From("sale_items").Where("sale_id = %d".printf(this.Id));
			foreach(var item in this.Dbh.GetResults(null))
			{
				var _item = new ESaleItem.with_db_data(item);
				this.Items.add(_item);
			}
		}
		public void GetDbMeta()
		{
			this.Dbh.Select("*").From("sale_meta").Where("sale_id = %d".printf(this.Id));
			foreach(var row in this.Dbh.GetResults(null))
			{
				this.Meta.set(row.Get("meta_key"), row.Get("meta_value"));
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
		public void SetItem(ESaleItem item)
		{
			this.Items.add(item);
		}
		public int Register()
		{
			string cdate = new DateTime.now_local().format("%Y-%m-%d %H:%M:%S");
			var row = new HashMap<string, Value?>();
			row.set("code", "");
			row.set("store_id", this.StoreId);
			row.set("cashier_id", this.CashierId);
			row.set("customer_id", this.CustomerId);
			row.set("notes", this.Notes);
			row.set("sub_total", this.SubTotal);
			row.set("tax_rate", this.TaxRate);
			row.set("tax_amount", this.TaxAmount);
			row.set("discount_total", this.Discount);
			row.set("total", this.Total);
			row.set("items_total", 0);
			row.set("status", this.Status);
			row.set("last_modification_date", cdate);
			row.set("creation_date", cdate);
			int sale_id = (int)this.Dbh.Insert("sales", row);
			int total_items = 0;
			foreach(var item in this.Items)
			{
				item.Dbh = this.Dbh;
				item.SaleId = sale_id;
				total_items += item.Quantity;
				item.Register();
			}
			string update = "UPDATE sales SET items_total = %d WHERE sale_id = %d".printf(total_items, sale_id);
			this.Dbh.Execute(update);
			this.UpdateStock();
			return sale_id;
		}
		protected void UpdateStock()
		{
			foreach(var item in this.Items)
			{
				string update = "UPDATE products SET product_quantity = product_quantity - %d ".printf(item.Quantity);
				update += "WHERE product_id = %d".printf(item.ProductId);
				this.Dbh.Execute(update);
			}
		}
	}
}
