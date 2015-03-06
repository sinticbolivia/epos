using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace EPos
{
	public class EPosHelper
	{
		public static ArrayList<SBStore> GetStores()
		{
			var records = new ArrayList<SBStore>();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("stores").OrderBy("store_name", "ASC");
										
			foreach(var row in dbh.GetResults(null))
			{
				var store = new SBStore();
				store.SetDbData(row);
				records.add(store);
			}
			
			return records;
		}
		public static HashMap<string, Value?>? GetTaxRate(int id)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("tax_rates").Where("tax_id = %d".printf(id));
			var row = dbh.GetRow(null);
			if( row == null )
				return null;
			var tax = new HashMap<string, Value?>();
			tax.set("tax_id", row.GetInt("tax_id"));
			tax.set("name", row.Get("name"));
			tax.set("rate", row.GetDouble("rate"));
			//tax.set("creation_date");
			
			return tax;
		}
		public static HashMap<string, Value?>? GetCustomer(int id)
		{
			HashMap<string, Value?>? customer = null;
			
			var cfg = (SBConfig)SBGlobals.GetVar("config");
			string is_terminal = (string)cfg.GetValue("is_terminal", "");
			if( is_terminal == "yes" )
			{
				
			}
			else
			{
				var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
				dbh.Select("*").From("customers").Where("customer_id = %d".printf(id));
				var row = dbh.GetRow(null);
				if( row == null )
					return null;
				customer = row.ToHashMap();
			}
		
			return customer;
		}
		public static HashMap<string, Value?>? GetUOM(int id)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("unit_measures").Where("measure_id = %d".printf(id));
			var row = dbh.GetRow(null);
			if( row == null )
				return null;
			
			return row.ToHashMap();
		}
		public static int FindProductBy(string by, string val)
		{
			var cfg = (SBConfig)SBGlobals.GetVar("config");
			int product_id = 0;
			string is_terminal = (string)cfg.GetValue("is_terminal", "");
			if( is_terminal == "yes" )
			{
				var req = new HashMap<string, Value?>();
				req.set("search_by", by);
				req.set("value", val);
				//TODO: send request to server
			}
			else
			{
				if( by == "id" )
				{
				}
				else if( by == "code" )
				{
				}
				else if( by == "barcode" )
				{
					var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
					dbh.Select("product_id").From("products").Where("product_barcode = '%s'".printf(val));
					var row = dbh.GetRow(null);
					if( row != null )
					{
						product_id = row.GetInt("product_id");
					}
				}
			}
			
			return product_id;
		}
	}
}
