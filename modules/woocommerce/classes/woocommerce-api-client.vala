using GLib;
using Gee;
using Soup;
using SinticBolivia;

namespace EPos.Woocommerce
{
	public class WC_Api_Client : Object
	{
		protected string _consumerKey;
		protected string _consumerSecret;
		//protected string _apiEndPoint = "/wc-api/v1/";
		protected string _apiEndPoint = "/wc-api/v2/";
		protected string _endPoint;
		protected string _wordpressUrl;
		protected string _signatureMethod = "SHA1";
		protected string _apiUrl;
		protected MessageHeaders	_responseHeaders;
		
		public bool debug = false;
		
		public WC_Api_Client(string wordpress_url, string api_key, string api_secret)
		{
			this._wordpressUrl = wordpress_url;
			this._consumerKey = api_key;
			this._consumerSecret = api_secret;
			this._apiUrl = "%s%s".printf(this._wordpressUrl, this._apiEndPoint);
		}
		public Json.Object GetStoreData()
		{
			Json.Object obj = new Json.Object();
			try
			{
				string res = this._makeApiCall("", null);
				var parser = new Json.Parser ();
				parser.load_from_data(res, -1);
				obj = parser.get_root().get_object().get_object_member("store");
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			return obj;
		}
		public ArrayList<HashMap<string, Value?>> GetCategories(int limit = 100, int page = 1, out int total_cats, out int total_pages)
		{
			var args = new HashMap<string,string>();
			args.set("filter[limit]", limit.to_string());
			args.set("page", page.to_string());
			
			string res = this._makeApiCall("products/categories", args);
			if( this.debug ) stderr.printf (res);
			Json.Object obj = new Json.Object();
			var parser = new Json.Parser ();
			var cats = new ArrayList<HashMap<string, Value?>>();
			try
			{
				total_cats = int.parse(this._responseHeaders.get_one("X-WC-Totals"));
				parser.load_from_data(res, -1);
				var main_obj = parser.get_root().get_object();
				if( !main_obj.has_member("product_categories") )
				{
					return cats;
				}
				foreach(var node in main_obj.get_array_member("product_categories").get_elements())
				{
					int cat_id	= (int)node.get_object().get_int_member("id");
					int parent	= (int)node.get_object().get_int_member("parent");
					int count	= (int)node.get_object().get_int_member("count");
					
					stdout.printf("id => %d\n", cat_id);
					var cat = new HashMap<string, Value?>();
					
					cat.set("id",  cat_id);
					cat.set("name", node.get_object().get_string_member("name"));
					cat.set("slug", node.get_object().get_string_member("slug"));
					cat.set("description", node.get_object().get_string_member("description"));
					cat.set("parent", parent);
					cat.set("count", count);
					cats.add(cat);
				}
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
				return null;
			}
			
			return cats;
		}
		public ArrayList<HashMap<string, Value?>> GetProducts(int limit, int page, out int total_products, out int total_pages)
		{
			var args = new HashMap<string,string>();
			args.set("filter[limit]", limit.to_string());
			args.set("page", page.to_string());
			var products = new ArrayList<HashMap<string, Value?>>();
			string res = this._makeApiCall("products", args);
			if( this.debug ) stderr.printf (res);
			
			try
			{
				total_products = int.parse(this._responseHeaders.get_one("X-WC-Total"));
				total_pages = int.parse(this._responseHeaders.get_one("X-WC-TotalPages"));
				
				Json.Parser parser = new Json.Parser();
				parser.load_from_data(res, -1);
				var main_obj = parser.get_root().get_object();
				if( !main_obj.has_member("products") )
				{
					return products;
				}
				foreach(var node in main_obj.get_array_member("products").get_elements())
				{
					double sale_price = 0;
					string? str_sale_price = node.get_object().get_string_member("sale_price");
					string? featured_src = node.get_object().get_string_member("featured_src");
					if( str_sale_price != null )
					{
						sale_price = double.parse(str_sale_price);
					}
					var prod = new HashMap<string, Value?>();
					prod.set("title", node.get_object().get_string_member("title"));
					prod.set("id", (int)node.get_object().get_int_member("id"));
					prod.set("type", node.get_object().get_string_member("type"));
					prod.set("status", node.get_object().get_string_member("status"));
					prod.set("permalink", node.get_object().get_string_member("permalink"));
					prod.set("sku", node.get_object().get_string_member("sku"));
					prod.set("price", double.parse(node.get_object().get_string_member("price")));
					prod.set("regular_price", double.parse(node.get_object().get_string_member("regular_price")));
					prod.set("sale_price", sale_price);
					prod.set("stock_quantity", (int)node.get_object().get_int_member("stock_quantity"));
					prod.set("description", node.get_object().get_string_member("description"));
					prod.set("featured_src", featured_src != null ? featured_src : "");
					string cats = "";
					foreach(var cat_node in node.get_object().get_array_member("categories").get_elements())
					{
						cats += "%s,".printf(cat_node.get_string());
					}
					prod.set("categories", cats != "" ? cats.substring(0, cats.length - 1): "");
					products.add(prod);
				}
				//stdout.printf("Content-type: %s\n", this._responseHeaders.get_one("Content-type"));
				stdout.printf("products pages: %s\n", this._responseHeaders.get_one("X-WC-TotalPages"));
				stdout.printf("total products: %s\n", this._responseHeaders.get_one("X-WC-Total"));
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			return products;
		}
		public Json.Array SearchCustomerByName(string name)
		{
			var args = new HashMap<string,string>();
			args.set("filter[q]", name);
			//args.set("filter[search_columns]", "first_name");
			
			string res = this._makeApiCall("customers", args);
			if( this.debug ) stderr.printf (res);
			Json.Array customers = new Json.Array();
			try
			{
				Json.Parser parser = new Json.Parser();
				parser.load_from_data(res, -1);
				customers = parser.get_root().get_object().get_array_member("customers");
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			return customers;
		}
		public HashMap<string, Value?> PlaceOrder(HashMap<string,string>? args = null)
		{
			var woo_order = new HashMap<string, Value?>();
			string res = this._makeApiCall("orders", args, "POST", true);
			if( this.debug ) stderr.printf (res);
			var parser = new Json.Parser ();
			try
			{
				parser.load_from_data(res, -1);
				var main_obj = parser.get_root().get_object();
				if( !main_obj.has_member("order") )
					return woo_order;
				var json_order = main_obj.get_object_member("order");
				woo_order.set("id", (int)json_order.get_int_member("id"));
				woo_order.set("status", json_order.get_string_member("status"));
				woo_order.set("view_order_url", json_order.get_string_member("view_order_url"));
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
				
			}
			return woo_order;
		}
		public Json.Object Authenticate(string username, string pass)
		{
			var args = new HashMap<string,string>();
			args.set("username", username);
			args.set("password", pass);
			
			string res = this._makeApiCall("user/login", args, "POST");
			if( this.debug ) stderr.printf (res);
			Json.Object user = new Json.Object();
			try
			{
				Json.Parser parser = new Json.Parser();
				parser.load_from_data(res, -1);
				if( parser.get_root().get_object().has_member("error") )
				{
				}
				user = parser.get_root().get_object();
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
				var errors = new Json.Array();
				user.set_array_member("errors", errors);
			}
			return user;
		}
		public Json.Object CreateCustomer(HashMap<string,string> data)
		{
			Json.Object obj = new Json.Object();
			
			try
			{
				string res = this._makeApiCall("customers/new", data, "POST", true);
				Json.Parser parser = new Json.Parser();
				parser.load_from_data(res, -1);
				obj = parser.get_root().get_object();
				if( this.debug )
				{
					stdout.printf("RESPONSE: \n%s\n", res);
				}
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			
			return obj;
		}
		public ArrayList<HashMap<string, Value?>> GetCustomers(int limit, 
																	int page, 
																	out int total_customers, 
																	out int total_pages)
		{
			var args = new HashMap<string,string>();
			args.set("filter[limit]", limit.to_string());
			args.set("page", page.to_string());
			var customers 	= new ArrayList<HashMap<string, Value?>>();
			string res 		= this._makeApiCall("customers", args);
			total_customers = int.parse(this._responseHeaders.get_one("X-WC-Total"));
			total_pages = int.parse(this._responseHeaders.get_one("X-WC-TotalPages"));
				
			if( this.debug ) stderr.printf (res);
			try
			{
				var parser = new Json.Parser();
				parser.load_from_data(res, -1);
				var main_obj = parser.get_root().get_object();
				if( !main_obj.has_member("customers") )
				{
					stderr.printf("the json has no member customers\n");
					return customers;
				}
				foreach(var node in main_obj.get_array_member("customers").get_elements())
				{
					var c = new HashMap<string, Value?>();
					c.set("id", (int)node.get_object().get_int_member("id"));
					c.set("email", node.get_object().get_string_member("email"));
					c.set("first_name", node.get_object().get_string_member("first_name"));
					c.set("last_name", node.get_object().get_string_member("last_name"));
					c.set("username", node.get_object().get_string_member("username"));
					c.set("orders_count", (int)node.get_object().get_int_member("orders_count"));
					c.set("avatar_url", node.get_object().get_string_member("avatar_url"));
					c.set("billing_first_name", node.get_object().get_object_member("billing_address").get_string_member("first_name"));
					c.set("billing_last_name", node.get_object().get_object_member("billing_address").get_string_member("last_name"));
					c.set("billing_company", node.get_object().get_object_member("billing_address").get_string_member("company"));
					c.set("billing_address_1", node.get_object().get_object_member("billing_address").get_string_member("address_1"));
					c.set("billing_address_2", node.get_object().get_object_member("billing_address").get_string_member("address_2"));
					c.set("billing_city", node.get_object().get_object_member("billing_address").get_string_member("city"));
					c.set("billing_state", node.get_object().get_object_member("billing_address").get_string_member("state"));
					c.set("billing_postcode", node.get_object().get_object_member("billing_address").get_string_member("postcode"));
					c.set("billing_country", node.get_object().get_object_member("billing_address").get_string_member("country"));
					c.set("billing_email", node.get_object().get_object_member("billing_address").get_string_member("email"));
					c.set("billing_phone", node.get_object().get_object_member("billing_address").get_string_member("phone"));
					//##shipping details
					c.set("shipping_first_name", node.get_object().get_object_member("shipping_address").get_string_member("first_name"));
					c.set("shipping_last_name", node.get_object().get_object_member("shipping_address").get_string_member("last_name"));
					c.set("shipping_company", node.get_object().get_object_member("shipping_address").get_string_member("company"));
					c.set("shipping_address_1", node.get_object().get_object_member("shipping_address").get_string_member("address_1"));
					c.set("shipping_address_2", node.get_object().get_object_member("shipping_address").get_string_member("address_2"));
					c.set("shipping_city", node.get_object().get_object_member("shipping_address").get_string_member("city"));
					c.set("shipping_state", node.get_object().get_object_member("shipping_address").get_string_member("state"));
					c.set("shipping_postcode", node.get_object().get_object_member("shipping_address").get_string_member("postcode"));
					c.set("shipping_country", node.get_object().get_object_member("shipping_address").get_string_member("country"));
					customers.add(c);
				}
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			return customers;
		}
		protected string _makeApiCall(string endpoint, owned HashMap<string,string>? args = null, string method = "GET", 
										bool send_raw = false)
		{
			var time = new DateTime.now_local();
			HashMap<string, string> get_params = new HashMap<string,string>();
						
			string query_string = "";
			string post_vars = "";
			if( args == null )
			{
				args = new HashMap<string,string>();
			}
			get_params.set("oauth_consumer_key", this._consumerKey);
			get_params.set("oauth_nonce", Random.next_int().to_string());
			get_params.set("oauth_signature_method", "HMAC-SHA1");
			get_params.set("oauth_timestamp", time.to_unix().to_string());
			
			if( method == "GET" && args != null )
			{
				foreach(var entry in args.entries)
				{
					get_params.set(entry.key, entry.value);
				}
				
			}
			else if( method == "POST" )
			{
				if( send_raw )
				{
					post_vars += args.get("raw_data");
				}
				else
				{
					foreach(var entry in args.entries)
					{
						post_vars += "%s=%s&".printf(entry.key, entry.value);
					}
					
					post_vars = post_vars.substring(0, post_vars.length - 1);
				}
			}
			get_params.set("oauth_signature", this.get_signature_base_string(endpoint, get_params, method));
			query_string = this.get_query_string(get_params);
			string url = "%s%s?%s".printf(this._apiUrl, endpoint, query_string);
			
    		Soup.SessionSync session = new Soup.SessionSync();
			Soup.Message message = new Soup.Message (method, url);
    		if( method == "POST" )
    		{
				if( !send_raw )
				{
					message.request_headers.append("Content-type", "application/x-www-form-urlencoded");
				}
				else
				{
					message.request_headers.append("Allow", "GET,POST");
					message.request_headers.append("Content-type", (send_raw) ? (string)args["content_type"] : "text/plain");
				}					
				message.request_body.append(MemoryUse.COPY, post_vars.data);				
			}
			if( this.debug ) 
			{
				//stdout.printf("HEADER => %s\n", message.request_headers.get_list());
				stderr.printf("url => %s\n", url);
				if( method == "POST" )
				{
					stdout.printf("%sPOST => %s\n", (send_raw) ? "RAW " : "", (string)post_vars.data);
				}
			}
    		int status = (int)session.send_message(message);
    		if( status != 200 )
    		{
    			
    		}
    		stdout.printf("Status: %d\n", status);
    		this._responseHeaders = message.response_headers;
    		string response = (string)message.response_body.flatten().data;
    		
			return response;
		}
		/**
		* Build signature
		*
		*/
		protected string _getSignature(string endpoint, string query_string, string method)
		{
			string base_request_uri 		= URI.encode(this._apiUrl + endpoint, null);
			string encoded_query_string 	= URI.encode(query_string, "&=");
			string string_to_sign 			= "%s&%s&%s".printf(method, base_request_uri, encoded_query_string);
			if( this.debug ) 
			{
				stderr.printf("\nbase_request_uri => %s\n", base_request_uri);
				stderr.printf("encoded_query_string => %s\n", encoded_query_string);
				stderr.printf("string_to_sign => %s\n", string_to_sign);
			}
			
			
			uchar[] hmac = HMAC.hmac_sha1((uchar[])this._consumerSecret.to_utf8(), (uchar[])string_to_sign.to_utf8());
			
			string signature = URI.encode(Base64.encode(hmac), "+");
			if( this.debug ) stderr.printf("signature => %s\n", signature);
			return signature;
		}
		private string get_signature_base_string(string endpoint, HashMap<string,string> parameters, string method) 
		{
			string url = this._apiUrl + endpoint;
            var buffer = new StringBuilder();

            GLib.List<string> keys = new GLib.List<string>();
            foreach(var entry in parameters.entries)
			{
				 keys.append(entry.key);
			}
		
            keys.sort((CompareFunc)strcmp);

            foreach (string key in keys) 
            {
                string key_encoded = URI.encode(key, "&=()").replace("%", "%25");
				string val_encoded = URI.encode(parameters[key], "&=()").replace("%", "%25");
                buffer.append(key_encoded + "%3D" + val_encoded + "%26");
            }
			
			string encoded_query_string = buffer.str;
			encoded_query_string = encoded_query_string.substring(0, encoded_query_string.length - 3);
			
            //string string_to_sign = "%s&%s&%s".printf(method, URI.encode(url, null), URI.encode(encoded_query_string, "&="));
            string string_to_sign = "%s&%s&%s".printf(method, URI.encode(url, null), encoded_query_string);
            
			uchar[] hmac = HMAC.hmac_sha1((uchar[])this._consumerSecret.to_utf8(), (uchar[])string_to_sign.to_utf8());
			
			string signature = URI.encode(Base64.encode(hmac), "=/").replace("%3D", "=");
			signature = signature.replace("%2F", "/").replace("+", "%2B");
			if( this.debug )
			{
				stderr.printf("base_request_uri => %s\n", url);
				stderr.printf("encoded_query_string => %s\n", encoded_query_string);
				stderr.printf("string_to_sign => %s\n", string_to_sign);
				stderr.printf("signature => %s\n", signature);
			}
			return signature;
            
        }
        //private string get_query_string(HashTable<string,string> query) 
        private string get_query_string(HashMap<string,string> query) 
		{
            var buffer = new StringBuilder();
           
            foreach (var entry in query.entries) 
            {
                //unowned string? val = query.lookup(key);
                string key_encoded = entry.key;//URI.encode(entry.key, "&=()");
				string val_encoded = entry.value;//URI.encode(entry.value, "&=()");
				
                if (buffer.len != 0) {
                    buffer.append("&");
                }
				/*
                if (val == null) {
                    buffer.append(key_encoded + "=");
                } else {
                    string val_encoded = URI.encode(val, "&=()");
                    buffer.append(key_encoded + "=" + val_encoded);
                }
                */
                buffer.append(key_encoded + "=" + val_encoded);
            }

            //buffer.prepend("?");

            return buffer.str;
        }
		/**
		* Build signature
		*
		*/
		/*
		protected string _getSignatureFromMap(string endpoint, HashMap<string, string> args, string method)
		{
			string base_request_uri 		= URI.encode(this._apiUrl + endpoint, null);
			string query_string = "";
			string encoded_query_string 	= URI.encode(query_string, "&=");
			string string_to_sign 			= "%s&%s&%s".printf(method, base_request_uri, encoded_query_string);
			if( this.debug ) 
			{
				stderr.printf("\nbase_request_uri => %s\n", base_request_uri);
				stderr.printf("encoded_query_string => %s\n", encoded_query_string);
				stderr.printf("string_to_sign => %s\n", string_to_sign);
			}
			
			
			uchar[] hmac = HMAC.hmac_sha1((uchar[])this._consumerSecret.to_utf8(), (uchar[])string_to_sign.to_utf8());
			
			string signature = URI.encode(Base64.encode(hmac), "+");
			if( this.debug ) stderr.printf("signature => %s\n", signature);
			return signature;
		}
		*/
	}
}
