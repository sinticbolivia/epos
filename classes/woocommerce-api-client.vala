using GLib;
using Gee;
using Soup;
using SinticBolivia;

namespace Woocommerce
{
	public class WC_Api_Client : Object
	{
		protected string _consumerKey;
		protected string _consumerSecret;
		protected string _apiEndPoint = "/wc-api/v1/";
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
		public ArrayList<HashMap>? GetCategories(out string error)
		{
			string res = this._makeApiCall("categories", null);
			if( this.debug ) stderr.printf (res);
			Json.Object obj = new Json.Object();
			var parser = new Json.Parser ();
			var cats = new ArrayList<HashMap<string, Value?>>();
			try
			{
				parser.load_from_data(res, -1);
				//if( parser.get_root().get_object().has_member("errors") )
				//stdout.printf("node name => %s\n", parser.get_root().type_name());
				if( parser.get_root().type_name() == "JsonObject" )
				{
					string err = parser.get_root().get_object().get_array_member("errors").get_element(0).get_object().get_string_member("message");
					error = SBText.__("ERROR TRYING TO SYNC CATEGORIES: %s\n", err);
					return null;
				}
				else
				{
					foreach(var node in parser.get_root().get_array().get_elements())
					{
						string cat_id_str	= node.get_object().get_string_member("term_id");
						string parent_str	= node.get_object().get_string_member("parent");
						int count			= (int)node.get_object().get_int_member("count");
						
						int cat_id = int.parse(cat_id_str);
						int parent = int.parse(parent_str);
						
						stdout.printf("id => %d\n", cat_id);
						var cat = new HashMap<string, Value?>();
						
						cat.set("term_id",  cat_id);
						cat.set("name", node.get_object().get_string_member("name"));
						cat.set("slug", node.get_object().get_string_member("slug"));
						cat.set("description", node.get_object().get_string_member("description"));
						cat.set("parent", parent);
						cat.set("count", count);
						
						var childs = new ArrayList<HashMap<string, Value?>>();
						
						foreach(var cnode in node.get_object().get_array_member("childs").get_elements())
						{
							var child = new HashMap<string, Value?>();
							string ccat_id	= cnode.get_object().get_string_member("term_id");
							string cparent	= cnode.get_object().get_string_member("parent");
							int ccount		= (int)cnode.get_object().get_int_member("count");
							
							child.set("term_id", int.parse(ccat_id));
							child.set("name", cnode.get_object().get_string_member("name"));
							child.set("slug", cnode.get_object().get_string_member("slug"));
							child.set("description", cnode.get_object().get_string_member("description"));
							child.set("parent", int.parse(cparent));
							child.set("count", ccount);
							childs.add(child);
						}
						
						cat.set("childs", childs);
						cats.add(cat);
					}
					//obj.set_array_member("categories", );
				}
				
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
				return null;
			}
			
			return cats;
		}
		public Json.Object GetProducts(int limit = 50, int page = 1)
		{
			var args = new HashMap<string,string>();
			args.set("filter[limit]", limit.to_string());
			//args.set("filter[page]", page.to_string());
			args.set("page", page.to_string());
						
			string res = this._makeApiCall("products", args);
			if( this.debug ) stderr.printf (res);
			Json.Object products = new Json.Object();
			try
			{
				Json.Parser parser = new Json.Parser();
				parser.load_from_data(res, -1);
				
				if( parser.get_root().get_object().has_member("errors") )
				{
					products = parser.get_root().get_object();
				}
				else
				{
					products.set_array_member("products", parser.get_root().get_object().get_array_member("products"));
					products.set_int_member("total_pages", int.parse(this._responseHeaders.get_one("X-WC-TotalPages")));
					products.set_int_member("total_products", int.parse(this._responseHeaders.get_one("X-WC-Total")));
				}
				
				//stdout.printf("Content-type: %s\n", this._responseHeaders.get_one("Content-type"));
				//stdout.printf("pages: %s\n", this._responseHeaders.get_list("X-WC-TotalPages"));
				//stdout.printf("products: %s\n", this._responseHeaders.get("X-WC-Total"));
				
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
		public Json.Object PlaceOrder(HashMap<string,string>? args = null)
		{
			//stdout.printf("Placing order\n");
			string res = this._makeApiCall("order/new", args, "POST", true);
			if( this.debug ) stderr.printf (res);
			var parser = new Json.Parser ();
			try
			{
				parser.load_from_data(res, -1);
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
				return new Json.Object();
			}
			return parser.get_root().get_object();
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
		protected string _makeApiCall(string endpoint, owned HashMap<string,string>? args = null, string method = "GET", 
										bool send_raw = false)
		{
			var time = new DateTime.now_local();
			HashMap<string, string> get_params = new HashMap<string,string>();
			//build query string
			//StringBuilder str_build = new StringBuilder("");
			/*
			str_build.append_printf("oauth_consumer_key=%s", this._consumerKey);
			str_build.append_printf("&oauth_nonce=%"+int64.FORMAT, (ulong) Random.next_int());
			str_build.append_printf("&oauth_signature_method=HMAC-SHA1");
			str_build.append_printf("&oauth_timestamp=%"+int64.FORMAT, time.to_unix());
			str_build.append_printf("&oauth_signature=%s", this._getSignature(endpoint, str_build.str, method));
			*/
			
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
					message.request_headers.append("Content-type", "text/plain");
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

            //GLib.List<unowned string> keys = query.get_keys();
            //keys.sort((CompareFunc)strcmp);

            //foreach (unowned string key in keys) 
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
