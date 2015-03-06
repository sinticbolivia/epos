using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace EPos
{
	public class ESaleItem : SBDbObject
	{
		public		int			Id
		{
			get{return this.dbData.GetInt("item_id");}
			set{this.dbData.Set("item_id", value.to_string());}
		}
		public		int			SaleId
		{
			get{return this.dbData.GetInt("sale_id");}
			set{this.dbData.Set("sale_id", value.to_string());}
		}
		public		int			ProductId
		{
			get{return this.dbData.GetInt("product_id");}
			set{this.dbData.Set("product_id", value.to_string());}
		}
		public		string		ProductName
		{
			get{return this.dbData.Get("product_name");}
			set{this.dbData.Set("product_name", value);}
		}
		public		int			Quantity
		{
			get{return this.dbData.GetInt("quantity");}
			set{this.dbData.Set("quantity", value.to_string());}
		}
		public		double		Price
		{
			get{return this.dbData.GetDouble("price");}
			set{this.dbData.Set("price", value.to_string());}
		}
		public		double		SubTotal
		{
			get{return this.dbData.GetDouble("sub_total");}
			set{this.dbData.Set("sub_total", value.to_string());}
		}
		public		double		TaxRate
		{
			get{return this.dbData.GetDouble("tax_rate");}
			set{this.dbData.Set("tax_rate", value.to_string());}
		}
		public		double		TaxAmount
		{
			get{return this.dbData.GetDouble("tax_amount");}
			set{this.dbData.Set("tax_amount", value.to_string());}
		}
		public		double		Discount
		{
			get{return this.dbData.GetDouble("discount");}
			set{this.dbData.Set("discount", value.to_string());}
		}
		public		double		Total
		{
			get{return this.dbData.GetDouble("total");}
			set{this.dbData.Set("total", value.to_string());}
		}
		public		string		Status
		{
			get{return this.dbData.Get("status");}
			set{this.dbData.Set("status", value);}
		}
		public		string		CreationDate
		{
			get{return this.dbData.Get("creation_date");}
			set{this.dbData.Set("creation_date", value);}
		}
		public ESaleItem()
		{
			this.dbData = new SBDBRow();
		}
		public ESaleItem.from_id(int id)
		{
			this();
		}
		public ESaleItem.with_db_data(SBDBRow row)
		{
			this();
			this.dbData = row;
		}
	}
}
