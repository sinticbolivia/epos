using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace Woocommerce
{
	public class ECStore : Object
	{
		protected	SBDBRow		dbData	;
		public int		Id;
		public string 	Name;
		public string 	Description;
		public string 	Key;
		public string 	Url;
		public string 	Version;
		public string 	Type;
		public int		TaxId;
		public double	TaxRate;
		public	string	TaxName;
		public	int		sales_tt_id;
		public	int		purchase_tt_id;
		public	int		refund_tt_id;
		
		public ECStore()
		{
		}
		public ECStore.from_id(int store_id)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT s.*,t.name,t.rate "+
							"FROM stores s "+
								"LEFT JOIN tax_rates t ON s.tax_id = t.tax_id "+
							"WHERE store_id = %d LIMIT 1";
							
			query  = query.printf(store_id);
			
			var row = dbh.GetRow(query);
			if( row != null )
			{
				this.Id 			= row.GetInt("store_id");
				this.Name			= row.Get("store_name");
				this.Description 	= row.Get("store_description");
				this.Key			= row.Get("store_key");
				this.Url			= "";
				this.Version		= "";
				this.Type			= row.Get("store_type");
				this.TaxId			= row.GetInt("tax_id");
				this.TaxRate		= row.GetDouble("rate");
				this.TaxName		= row.Get("name");
				this.sales_tt_id	= row.GetInt("sales_transaction_type_id");
				this.purchase_tt_id	= row.GetInt("purchase_transaction_type_id");
				this.refund_tt_id	= row.GetInt("refund_transaction_type_id");
			}
		}
		public string GetMeta(string meta_key)
		{
			return ECStore.SGetMeta(this.Id, meta_key);
		}
		public static string SGetMeta(int store_id, string meta_key)
		{
			return SBMeta.GetMeta("store_meta", meta_key, "store_id", store_id);
		}
	}
}
