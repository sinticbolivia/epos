using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace EPos
{
	public class Quote : SBDbObject
	{
		public		int		Id
		{
			get{return this.dbData.GetInt("quote_id");}
		}
		public		string	Code
		{
			get{return this.dbData.Get("code");}
		}
		public		int		StoreId
		{
			get{return this.dbData.GetInt("store_id");}
		}
		public		int		UserId
		{
			get{return this.dbData.GetInt("user_id");}
		}
		public		int		CustomerId
		{
			get{return this.dbData.GetInt("customer_id");}
		}
		public		string	Details
		{
			get{return this.dbData.Get("description");}
		}
		public		double	SubTotal
		{
			get{return this.dbData.GetDouble("subtotal");}
		}
		public		double	TaxTotal
		{
			get{return this.dbData.GetDouble("total_tax");}
		}
		public		double	Total
		{
			get{return this.dbData.GetDouble("total");}
		}
		public		string	Status
		{
			get{return this.dbData.Get("status");}
		}
		public		ArrayList<SBDBRow>	Items;
		public Quote()
		{
			this.dbData = new SBDBRow();
			this.Items	= new ArrayList<SBDBRow>();
		}
		public Quote.from_id(int quote_id)
		{
			this();
			this.GetDbData(quote_id);
		}
		public void GetDbData(int quote_id)
		{
			this.Dbh.Select("*").From("quotes").Where("quote_id = %d".printf(quote_id));
			var row = this.Dbh.GetRow(null);
			if( row == null )
				return;
			this.dbData = row;
		}
		public void GetDbItems()
		{
			this.Dbh.Select("*").From("quote_items").Where("quote_id = %d".printf(this.Id));
			this.Items = this.Dbh.GetResults(null);
		}
	}
}
