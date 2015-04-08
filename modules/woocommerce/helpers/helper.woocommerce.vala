using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace EPos.Woocommerce
{
	public class WCHelper : Object
	{
		public static ArrayList<SBStore> GetStores()
		{
			var stores = new ArrayList<SBStore>();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("stores").Where("store_type = 'woocommerce'");
			foreach(var row in dbh.GetResults(null))
			{
				var store = new SBStore.with_db_data(row);
				stores.add(store);
			}
			
			return stores;
		}
		public static SBStore GetStore(int id)
		{
			var store = new SBStore();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("stores").Where("store_id = %d".printf(id)).And("store_type = 'woocommerce'");
			var row = dbh.GetRow(null);
			if( row == null )
				return store;
				
			store.SetDbData(row);
			
			return store;
			
		}
		public static ArrayList<HashMap> GetProducts(int store_id)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT p.*, a.file AS thumbnail "+
							"FROM products p " +
								"LEFT JOIN attachments a ON p.product_id = a.object_id " +
							"WHERE 1 = 1 ";
							
			if( store_id > 0 )
			{
				query += "AND store_id = %d ";
			}
							
			query += "AND LOWER(a.object_type) = 'product' " +
					"AND (a.type = 'image_thumbnail' OR a.type = 'image') "+
					"GROUP BY p.product_id "+
					"ORDER BY p.product_id DESC";
			var prods = new ArrayList<HashMap<string, Value?>>();
			var records = dbh.GetResults(query);
			if( records.size <= 0 )
				return prods;
			/*	
			foreach(var row in records)
			{
				var prod = new HashMap<string, Value?>();
				prods.add(prod);
			}
			*/
			return prods;
		}
		public static ArrayList<SBDbObject> GetStoreCustomers(int store_id, SBDatabase? _dbh = null)
		{
			var customers = new ArrayList<SBDbObject>();
			var dbh = (_dbh != null) ? _dbh : (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("customers").Where("store_id = %d".printf(store_id));
			foreach(var row in dbh.GetResults(null))
			{
				var obj = new SBDbObject();
				obj.SetDbRow(row);
				customers.add(obj);
			}
			return customers;
		}
		public static ArrayList<ESale> GetOrders(int store_id, string status = "", SBDatabase? _dbh = null)
		{
			var orders = new ArrayList<ESale>();
			var dbh = (_dbh != null) ? _dbh : (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("sales").Where("store_id = %d".printf(store_id));
			if( status != "" )
			{
				dbh.And("status = %s".printf(status));
			}
			foreach(var row in dbh.GetResults(null))
			{
				var sale = new ESale.with_db_data(row);
				sale.GetDbItems();
				sale.GetDbMeta();
				orders.add(sale);
			}
			
			return orders;
		}
		public static ArrayList<ESale> GetOrdersPendingToSync(int store_id, SBDatabase? _dbh = null)
		{
			var orders = new ArrayList<ESale>();
			var dbh = (_dbh != null) ? _dbh : (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("s.*").From("sales s, sale_meta sm").
				Where("s.sale_id = sm.sale_id").
				And("s.store_id = %d".printf(store_id)).
				And("s.status = 'completed'").
				And("sm.meta_key = 'wc_sync_status'").
				And("sm.meta_value = 'pending'");
				
			foreach(var row in dbh.GetResults(null))
			{
				var sale = new ESale.with_db_data(row);
				sale.GetDbItems();
				sale.GetDbMeta();
				orders.add(sale);
			}
			
			return orders;
		}
		public static string BuildCustomerJson(SBCustomer customer)
		{
			string first_name = customer.Get("first_name").strip();
			string last_name = customer.Get("last_name").strip();
			string email 			= customer.Get("email").strip();
			string billing_email 	= (customer.Meta["billing_email"] != null) ? 
										(string)customer.Meta["billing_email"] : email;
			if( email.length <= 0 && billing_email.strip().length > 0 )
			{
				email = billing_email;
			}
			if( email.length <= 0 )
			{
				email = "%s.%s@epos.net".printf(last_name.down(), first_name.down());
			}
			
			var gen 		= new Json.Generator();
			var root_node 	= new Json.Node(Json.NodeType.OBJECT);
			var root_obj	= new Json.Object();
			var jcustomer	= new Json.Object();
			
			root_obj.set_object_member("customer", jcustomer);
			root_node.set_object(root_obj);
			gen.set_root(root_node);
			
			var billing_address = new Json.Object();
			var shipping_address = new Json.Object();
			jcustomer.set_object_member("billing_address", billing_address);
			jcustomer.set_object_member("shipping_address", shipping_address);
			
			jcustomer.set_string_member("email", email);
			jcustomer.set_string_member("first_name", first_name);
			jcustomer.set_string_member("last_name", last_name);
			jcustomer.set_string_member("username", email);
			//##build billing address
			billing_address.set_string_member("first_name", (customer.Meta["billing_first_name"] != null) ? customer.Meta["billing_first_name"] : first_name);
			billing_address.set_string_member("last_name", (customer.Meta["billing_last_name"] != null) ? customer.Meta["billing_last_name"] : last_name);
			billing_address.set_string_member("company", (customer.Meta["billing_company"] != null) ? customer.Meta["billing_company"] : customer.Get("company"));
			billing_address.set_string_member("address_1", (customer.Meta["billing_address_1"] != null) ? customer.Meta["billing_address_2"] : "");
			billing_address.set_string_member("address_2", (customer.Meta["billing_address_2"] != null) ? customer.Meta["billing_address_2"] : "");
			billing_address.set_string_member("city", (customer.Meta["billing_city"] != null) ? customer.Meta["billing_city"] : "");
			billing_address.set_string_member("state", (customer.Meta["billing_state"] != null) ? customer.Meta["billing_state"] : "");
			billing_address.set_string_member("postcode", (customer.Meta["billing_postcode"] != null) ? customer.Meta["billing_postcode"] : "");
			billing_address.set_string_member("country", (customer.Meta["billing_cuntry"] != null) ? customer.Meta["billing_country"] : "");
			billing_address.set_string_member("email", (customer.Meta["billing_email"] != null) ? customer.Meta["billing_email"] : "");
			billing_address.set_string_member("phone", (customer.Meta["billing_phone"] != null) ? customer.Meta["billing_phone"] : "");
			//##build shipping address
			shipping_address.set_string_member("first_name", (customer.Meta["shipping_first_name"] != null) ? customer.Meta["shipping_first_name"] : "");
			shipping_address.set_string_member("last_name", (customer.Meta["shipping_last_name"] != null) ? customer.Meta["shipping_last_name"] : "");
			shipping_address.set_string_member("company", (customer.Meta["shipping_company"] != null) ? customer.Meta["shipping_company"] : "");
			shipping_address.set_string_member("address_1", (customer.Get("shipping_address_1") != null ) ? customer.Get("shipping_address_1") : "");
			shipping_address.set_string_member("address_2", (customer.Get("shipping_address_2") != null ) ? customer.Get("shipping_address_2") : "");
			shipping_address.set_string_member("city", (customer.Meta["shipping_city"] != null) ? customer.Meta["shipping_city"] : customer.Get("city"));
			shipping_address.set_string_member("state", (customer.Meta["shipping_state"] != null) ? customer.Meta["shipping_state"] : "");
			shipping_address.set_string_member("postcode", (customer.Meta["shipping_postcode"] != null) ? customer.Meta["shipping_postcode"] : "");
			shipping_address.set_string_member("country", (customer.Meta["shipping_country"] != null) ? customer.Meta["shipping_country"] : "");
			
			size_t length;
			return gen.to_data(out length);
		}
	}
}
