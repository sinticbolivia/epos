using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace EPos
{
	public class HelperInventoryCount : GLib.Object
	{
		public static ArrayList<SBDBRow> GetWorksheet(int count_id, int result_number, SBDatabase? _dbh = null)
		{
			var dbh = (_dbh != null) ? _dbh : (SBDatabase)SBGlobals.GetVar("dbh");
			
			dbh.Select("cr.*,p.*").
				From("inventory_count_products cp, inventory_count_results cr, products p").
				Where("cp.product_id = cr.product_id").
				And("cr.product_id = p.product_id").
				And("cr.count_id = %d".printf(count_id)).
				And("result_number = %d".printf(result_number));
				
			return dbh.GetResults(null);
		}
		public static ArrayList<SBProduct> GetCountProducts(int count_id, SBDatabase? _dbh = null)
		{
			var dbh = (_dbh != null) ? _dbh : (SBDatabase)SBGlobals.GetVar("dbh");
			
			dbh.Select("p.*").
				From("inventory_count_products cp, products p").
				Where("count_id = %d".printf(count_id)).
				And("cp.product_id = p.product_id");
			var products = new ArrayList<SBProduct>();
			foreach(var row in dbh.GetResults(null))
			{
				var prod = new SBProduct.with_db_data(row);
				products.add(prod);
			}
			
			return products;
		}
		/*
		public static ArrayList<HashMap<string, Value?>> CompareWorksheets(int count_id, int result_1, int result_2, SBDatabase? _dbh = null)
		{
			var dbh = (_dbh != null) ? _dbh : (SBDatabase)SBGlobals.GetVar("dbh");
			
			dbh.Select("cr.*,p.*").
				From("inventory_count_products cp, inventory_count_results cr, products p").
				Where("cp.product_id = cr.product_id").
				And("cr.product_id = p.product_id").
				And("cr.count_id = %d".printf(count_id)).
				And("result_number = %d".printf(result_1));
			var results_1 = dbh.GetResults(null);
			dbh.Select("cr.*,p.*").
				From("inventory_count_products cp, inventory_count_results cr, products p").
				Where("cp.product_id = cr.product_id").
				And("cr.product_id = p.product_id").
				And("cr.count_id = %d".printf(count_id)).
				And("result_number = %d".printf(result_2));
			var results_2 = dbh.GetResults(null);
			
			var products = HelperInventoryCount.GetCountProducts(count_id);
			var results = new ArrayList<HashMap<string, Value?>>();
			foreach(var prod in products)
			{
				
			}
		}
		*/
	}
}
