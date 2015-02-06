using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace Woocommerce
{
	public class InventoryHelper : Object
	{
		public static ArrayList<SBStore> GetStores()
		{
			var records = new ArrayList<SBStore>();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM stores ORDER BY store_name ASC";
							
			foreach(var row in dbh.GetResults(query))
			{
				var store = new SBStore();
				store.SetDbData(row);
				records.add(store);
			}
			
			return records;
		}
		public static ArrayList<SBLCategory> GetCategories(int store_id, uint parent_id = 0)
		{
			var records = new ArrayList<SBLCategory>();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
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
		public static ArrayList<SBProduct> GetProducts(int page, int rows_per_page, out long total_records)
		{
			var records = new ArrayList<SBProduct>();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			int offset = (page == 1) ? 0 : (page - 1);
			string query_count = "SELECT COUNT(product_id) as total_rows FROM products";
			var _row = dbh.GetRow(query_count);
			if(  _row == null )
				return records;
				
			total_records = _row.GetInt("total_rows");
			
			string query = @"SELECT * FROM products "+
							"ORDER BY creation_date "+
							"DESC LIMIT $offset, $rows_per_page";
							
			var rows = (ArrayList<SBDBRow>)dbh.GetResults(query);
			
			foreach(var row in rows)
			{
				//var product = new SBProduct.with_db_data(row);
				var product = new SBProduct();
				product.SetDbData(row, false, true);
				records.add(product);
			}
			
			return records;
		}
		public static ArrayList<SBProduct> GetStoreProducts(int store_id, int page, int rows_per_page, out long total_records)
		{
			var records = new ArrayList<SBProduct>();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			int offset = (page == 1) ? 0 : (page - 1);
			string query_count = "SELECT COUNT(product_id) as total_rows FROM products WHERE store_id = %d".printf(store_id);
			var _row = dbh.GetRow(query_count);
			if(  _row == null )
				return records;
				
			total_records = _row.GetInt("total_rows");
			
			string query = @"SELECT * FROM products WHERE store_id = $store_id ORDER BY creation_date DESC LIMIT $offset, $rows_per_page";
			var rows = (ArrayList<SBDBRow>)dbh.GetResults(query);
			
			foreach(var row in rows)
			{
				//var product = new SBProduct.with_db_data(row);
				var product = new SBProduct();
				product.SetDbData(row, false, true);
				records.add(product);
			}
			
			return records;
		}
		public static ArrayList<SBProduct> GetCategoryProducts(int cat_id, int page, int rows_per_page, out long total_records)
		{
			var records = new ArrayList<SBProduct>();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			int offset = (page == 1) ? 0 : (page - 1);
			string query_count = "SELECT COUNT(product_id) as total_rows FROM product2category WHERE category_id = %d".printf(cat_id);
			var _row = dbh.GetRow(query_count);
			if(  _row == null )
				return records;
			total_records = _row.GetInt("total_rows");
			
			string query = @"SELECT p.* "+
							@"FROM products p, product2category p2c "+
							@"WHERE p.product_id = p2c.product_id "+
							@"AND p2c.category_id = $cat_id "+
							"ORDER BY creation_date DESC ";
							
			if( rows_per_page > 0 )
				query += @"LIMIT $offset, $rows_per_page";
			
			var rows = (ArrayList<SBDBRow>)dbh.GetResults(query);
			
			foreach(var row in rows)
			{
				//var product = new SBProduct.with_db_data(row);
				var product = new SBProduct();
				product.SetDbData(row, false, true);
				records.add(product);
			}
			
			return records;
		}
		public static bool DeleteStore(int store_id)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.BeginTransaction();
			//##delete product images from filesystem
			string query = "SELECT * "+
							"FROM attachments a, products p "+
							"WHERE p.store_id = %d " +
							"AND a.object_id = p.product_id";
			var records = dbh.GetResults(query.printf(store_id));
			if( records.size > 0 )
			{
				foreach(var row in records)
				{
					string file = row.Get("file");
					string path = "";
					if( row.Get("type") == "image" || row.Get("type") == "image_thumbnail" )
					{
						path = "images/%s".printf(file);
					}
					FileUtils.unlink(path);
				}
			}
			query = "DELETE FROM attachments WHERE object_id IN(SELECT product_id FROM products WHERE store_id = %d)".printf(store_id);
			dbh.Execute(query);
			query = "DELETE FROM product2category WHERE product_id IN(SELECT product_id FROM products WHERE store_id = %d)".printf(store_id);
			dbh.Execute(query);
			query = "DELETE FROM product_meta WHERE product_id IN(SELECT product_id FROM products WHERE store_id = %d)".printf(store_id);
			dbh.Execute(query);
			query = "DELETE FROM categories WHERE store_id = %d".printf(store_id);
			dbh.Execute(query);
			query = "DELETE FROM products WHERE store_id = %d".printf(store_id);
			dbh.Execute(query);
			query = "DELETE FROM store_meta WHERE store_id = %d".printf(store_id);
			dbh.Execute(query);
			query = "DELETE FROM stores WHERE store_id = %d".printf(store_id);
			dbh.Execute(query);
			dbh.EndTransaction();
			
			return true;
		}
		public static ArrayList<SBTransaction> GetTransactions(int store_id, int type_id, int page, int rows_per_page, out int total_rows)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var records = new ArrayList<SBTransaction>();
			int offset = (page == 1) ? 0 : (page - 1);
			string query_count = "SELECT COUNT(transaction_id) as total_rows "+
									"FROM transactions WHERE store_id = %d".printf(store_id);
			
			if(  dbh.Query(query_count) <= 0 )
				return records;
			total_rows = dbh.Rows[0].GetInt("total_rows");
			
			string query = "SELECT t.* "+
							"FROM transactions t "+
							"WHERE store_id = %d ";
			if( type_id > 0 )
			{
				query += "AND transaction_type_id = %d ".printf(type_id);
			}
			query += "ORDER BY creation_date DESC ";
			
			query = query.printf(store_id);
							
			if( rows_per_page > 0 )
				query += @"LIMIT $offset, $rows_per_page";
				
			var rows = (ArrayList<SBDBRow>)dbh.GetResults(query);
			if( rows.size <= 0 )
				return records;
			foreach(var row in rows)
			{
				var t = new SBTransaction.with_db_data(row);
				records.add(t);
			}
			return records;
		}
		public static ArrayList<PurchaseOrder> GetPurchaseOrders(int store_id, int page, int rows_per_page, out int total_rows)
		{
			string query = "SELECT * FROM purchase_orders ORDER BY creation_date DESC";
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var orders = new ArrayList<PurchaseOrder>();
			foreach(var o in dbh.GetResults(query))
			{
				var order = new PurchaseOrder();
				order.SetDbData(o);
				orders.add(order);
			}
			
			return orders;
		}
	}
}
