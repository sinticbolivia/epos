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
		public static HashMap<string, string>? GetCustomer(int id, SBDatabase? _dbh = null)
		{
			HashMap<string, string>? customer = null;
			
			var cfg = (SBConfig)SBGlobals.GetVar("config");
			string is_terminal = (string)cfg.GetValue("is_terminal", "");
			if( is_terminal == "yes" )
			{
				
			}
			else
			{
				var dbh = (_dbh != null) ? _dbh : (SBDatabase)SBGlobals.GetVar("dbh");
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
		public static ArrayList<SBLCategory> GetCategories(int store_id, uint parent_id = 0, SBDatabase? _dbh = null)
		{
			var records = new ArrayList<SBLCategory>();
			var dbh = (_dbh != null) ? _dbh : (SBDatabase)SBGlobals.GetVar("dbh");
			/*
			int offset = (page == 1) ? 0 : (page - 1);
			string query_count = "SELECT COUNT(product_id) FROM products";
			total_records = dbh.Query(query_count);
			if( total_records <= 0 )
				return records;
			*/
			string query = @"SELECT * "+
							@"FROM categories "+
							@"WHERE store_id = $store_id "+
							@"AND parent = $parent_id " +
							@"ORDER BY creation_date DESC";
			var rows = (ArrayList<SBDBRow>)dbh.GetResults(query);
			foreach(var row in rows)
			{
				var cat = new SBLCategory.with_db_data(row);
				records.add(cat);
			}
			
			return records;
		}
		public static ArrayList<SBProduct> GetStoreProducts(int store_id, SBDatabase? _dbh = null)
		{
			var products = new ArrayList<SBProduct>();
			var dbh = (_dbh != null) ? _dbh : (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("products").Where("store_id = %d".printf(store_id));
			foreach(var row in dbh.GetResults(null))
			{
				var prod = new SBProduct.with_db_data(row);
				prod.Dbh = dbh;
				prod.GetDbMeta();
				products.add(prod);
			}
			
			return products;
		}
		public static ArrayList<SBProduct> GetCategoryProducts(int category_id, SBDatabase? _dbh = null)
		{
			var products = new ArrayList<SBProduct>();
			var dbh = (_dbh != null) ? _dbh : (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("p.*").From("products p, product2category p2c").
				Where("p.product_id = p2c.product_id").
				And("p2c.category_id = %d".printf(category_id));
				
			foreach(var row in dbh.GetResults(null))
			{
				var prod = new SBProduct.with_db_data(row);
				prod.Dbh = dbh;
				prod.GetDbMeta();
				products.add(prod);
			}
			
			return products;
		}
	}
}
