using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace Woocommerce
{
	public class ECHelper : Object
	{
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
		public static bool RegisterWoocommerceOrder(SBTransaction order, out int wc_order_id, out string error)
		{
			size_t length = 0;
			string json = "";
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var store = new SBStore.from_id(order.StoreId);
			if( store.Id <= 0 )
			{
				error = "ERROR: Woocommerce store with id = %d does not exists into database\n".printf(order.StoreId);
				return false;
			}
			
			var gen = new Json.Generator();
			var root = new Json.Node(Json.NodeType.OBJECT);
			Json.Object wc_order = new Json.Object();
			var products = new Json.Array();
			foreach(var item in order.Items )
			{
				//get product external id
				string query = "SELECT extern_id FROM products WHERE product_id = %d".printf(item.ProductId);
				var row = dbh.GetRow(query);
				if( row == null ) continue;
					
				int xid = row.GetInt("extern_id");
				Json.Object product = new Json.Object();
				product.set_int_member("id", xid);
				product.set_int_member("quantity", item.Quantity);
				products.add_object_element(product);
			}
			wc_order.set_array_member("products", products);
			wc_order.set_int_member("user_id", order.UserId);
			wc_order.set_int_member("customer_id", order.CustomerId);
			wc_order.set_string_member("payment_method", order.GetMeta("payment_method"));
			wc_order.set_string_member("notes", order.Notes);
			wc_order.set_int_member("terminal_id", 1);
			wc_order.set_string_member("address", store.Address);
			wc_order.set_string_member("city", "point of sale city goes here");
			var now = new DateTime.now_local ();
			wc_order.set_string_member("date", now.format("%x %X"));
	  
			root.set_object(wc_order);
			gen.set_root(root);
			
			json = gen.to_data(out length);
			
			//get woocommerce api handler
			var wc_api = new WC_Api_Client(store.GetMeta("wc_url"), 
											store.GetMeta("wc_api_key"),
											store.GetMeta("wc_api_secret")
			);
			HashMap<string,string> args = new HashMap<string,string>();
			args.set("raw_data", json);
			
			wc_api.debug = true;
			stderr.printf("Generated json: %s\n", json);
			var res = wc_api.PlaceOrder(args);
			/*
			if( res is Json.Object )
			{
				error = SBText.__("Invalid api response, make sure your internet connection is up.");
				return false;
			}
			*/
			bool result = false;
			
			if( res.has_member("order") )
			{
				
				int64 new_id = res.get_object_member("order").get_int_member("id");
				stdout.printf("new_id => %d\n", (int)new_id);
				wc_order_id = (int)new_id;
				result = true;
			}
			else if( res.has_member("error") ) 
			{
				error = SBText.__("An error ocurred while trying to place the order.\nCode: %s\nERROR: %s").
							printf(res.get_array_member("errors").get_element(0).get_object().get_string_member("code"),
									res.get_array_member("errors").get_element(0).get_object().get_string_member("message")
							);
				error += res.get_string_member("error");
				result = false;
			}
			else
			{
				error = SBText.__("An unknow error has ocurred, please contact with support.");
				result = false;
			}
			
			return result;
		}
	}
}
