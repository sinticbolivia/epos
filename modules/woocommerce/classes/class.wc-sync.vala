using GLib;
using Gee;
using Json;
using SinticBolivia;
using SinticBolivia.Database;

namespace EPos.Woocommerce
{
	public delegate void SyncCallback(int totals, int imported, string item_name, string message);
	public class SBWCSync : GLib.Object
	{
		
		
		protected	WC_Api_Client _api;
		public		SBDatabase		Dbh{get;set;}
		
		public SBWCSync(string wp_url, string api_key, string api_secret)
		{
			this._api = new WC_Api_Client(wp_url, api_key, api_secret);
		}
		public long SyncStore()
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			
			Json.Object data 	= this._api.GetStoreData();
			string store_name 	= data.get_string_member("name").strip();
			string description 	= data.get_string_member("description").strip();
			//string url			= data.get_string_member("URL").strip();
			//string version		= data.get_string_member("wc_version").strip();
			string store_key = "";
			var	regex = /\s+/i;
			try
			{
				store_key	= regex.replace(store_name.down(), store_name.length, 0, "-");
				
			}
			catch(GLib.Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			string query = @"SELECT * FROM stores WHERE store_key = '$store_key' LIMIT 1";
			stdout.printf("CHECKING STORE: %s\n", query);
			var date = new DateTime.now_local();
			string cdate = date.format("%Y-%m-%d %H:%M:%S");
			var store = new HashMap<string, Value?>();
			store.set("store_name", store_name);
			store.set("store_key", store_key);
			store.set("store_address", SBText.__("Online Store, Woocommerce"));
			store.set("store_description", description);
			store.set("store_type", "woocommerce");
			store.set("last_modification_date", cdate);
			
			var records = dbh.GetResults(query);
			long store_id = -1;
			if( records.size > 0 )
			{
				store_id = int.parse((records.get(0) as SBDBRow).Get("store_id"));
				var w = new HashMap<string, Value?>();
				w.set("store_id", store_id);
				dbh.Update("stores", store, w);
			}
			else
			{
				store.set("creation_date", cdate);
				store_id = dbh.Insert("stores", store);
			}			
			return store_id;
		}
		public long SyncCategories(int store_id)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			long records = 0;
			this._api.debug = true;
			string error = "";
			int total_cats = 0;
			int total_pages = 0;
			
			var cats = this._api.GetCategories(100, 1, out total_cats, out total_pages);
			
			dbh.BeginTransaction();
			foreach(var cat in cats)
			{
				int xcat_id = (int)cat["id"];
				string query = "SELECT category_id FROM categories WHERE extern_id = %d AND store_id = %d".printf(xcat_id, store_id);
				var row = dbh.GetRow(query);
				if( row != null )
				{
					SBMeta.UpdateMeta("category_meta", "wc_parent", ((int)cat["parent"]).to_string(), "category_id", row.GetInt("category_id"));
					SBMeta.UpdateMeta("category_meta", "wc_count", ((int)cat["count"]).to_string(), "category_id", row.GetInt("category_id"));
					SBMeta.UpdateMeta("category_meta", "wc_slug", (string)cat["slug"], "category_id", row.GetInt("category_id"));
					continue;
				}
				//##insert category into database
				HashMap<string, Value?> data = new HashMap<string, Value?>();
				data.set("name", (string)cat["name"]);
				data.set("description", (string)cat["description"]);
				data.set("parent", 0);
				data.set("creation_date", new DateTime.now_local().format("%Y-%m-%d %H:%M:%S"));
				data.set("extern_id", xcat_id);
				data.set("store_id", store_id);
				
				long cat_id = dbh.Insert("categories", data);
				SBMeta.UpdateMeta("category_meta", "wc_parent", ((int)cat["parent"]).to_string(), "category_id", (int)cat_id);
				SBMeta.UpdateMeta("category_meta", "wc_count", ((int)cat["count"]).to_string(), "category_id", (int)cat_id);
				SBMeta.UpdateMeta("category_meta", "wc_slug", (string)cat["slug"], "category_id", (int)cat_id);
				/*
				var childs = (ArrayList<HashMap<string, Value?>>)cat["childs"];
				
				foreach(var child in childs)
				{
					query = "SELECT category_id FROM categories WHERE extern_id = %d AND store_id = %d".
								printf((int)child["term_id"], store_id);
					if( dbh.Query(query) > 0 )
						continue;
						
					HashMap<string, Value?> cdata = new HashMap<string, Value?>();
					cdata.set("name", (string)child["name"]);
					cdata.set("description", (string)child["description"]);
					cdata.set("parent", cat_id);
					cdata.set("creation_date", new DateTime.now_local().format("%Y-%m-%d %H:%M:%S"));
					cdata.set("extern_id", (int)child["term_id"]);
					cdata.set("store_id", store_id);
					
					dbh.Insert("categories", cdata);
				}
				*/
			}
			this.FixCategoriesParent(store_id);
			dbh.EndTransaction();
			return records;
		}
		protected void FixCategoriesParent(int store_id)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string q = "SELECT c.*, cm.meta_value FROM categories c, category_meta cm ";
			q += "WHERE c.store_id = %d ".printf(store_id);
			q += "AND c.category_id = cm.category_id ";
			q += "AND cm.meta_key = 'wc_parent'";
			
			foreach(var row in dbh.GetResults(q))
			{
				if( row.GetInt("meta_value") <= 0 )
				{
					continue;
				}
				string sub_query = "SELECT sc.category_id FROM categories sc WHERE sc.store_id = %d ".printf(store_id);
				sub_query += "AND extern_id = %d".printf(row.GetInt("meta_value"));
				string update = "UPDATE categories SET parent = (%s) WHERE category_id = %d ".printf(sub_query, row.GetInt("category_id"));
				stdout.printf("QUERY: %s\n", update);
				dbh.Execute(update);
			}
		}
		public long SyncProducts(int store_id, SyncCallback? cb = null, FileProgressCallback? progress_callback = null)
		{
			this._api.debug = true;
			int total_prods = 0;
			int total_pages = 0;
			int imported	= 0;
			int products_per_page = 100;
			var products = this._api.GetProducts(products_per_page, 1, out total_prods, out total_pages);
			try
			{
				for(int page = 1; page <= total_pages; page++)
				{
					if( page > 1 )
					{
						products = this._api.GetProducts(products_per_page, page, out total_prods, out total_pages);
					}
					stdout.printf ("Synchronizing page: %d\n", page);
					foreach (var prod in products) 
					{
						this.Dbh.BeginTransaction();
						int woo_id 				= (int)prod["id"];
						double price 			= (double)prod["price"];
						double regular_price 	= (double)prod["regular_price"];
						double sale_price 		= (double)prod["sale_price"];
						int	qty					= (int)prod["stock_quantity"];
						string product_type 	= (string)prod["type"];
						string image_url		= (string)prod["featured_src"];
						string query = "SELECT product_id FROM products WHERE extern_id = %d AND store_id = %d LIMIT 1".
											printf(woo_id, store_id);
						var row = this.Dbh.GetRow(query);
						int product_id = 0;
						//##call sync callback
						if( cb != null ) cb(total_prods, imported, (string)prod["title"], "");
						if( row != null )
						{
							//##update product data
							product_id = row.GetInt("product_id");
							//TODO:update product stock
							var udata = new HashMap<string, Value?>();
							udata.set("product_description", this.StripHtmlTags((string)prod["description"]));
							udata.set("product_quantity", qty);
							var uw = new HashMap<string, Value?>();
							uw.set("product_id", product_id);
							this.Dbh.Update("products", udata, uw);
							imported++;
						}
						else
						{
							string cdate = new DateTime.now_local().format("%Y-%m-%d %H:%M:%S");
							HashMap<string, Value?> _row = new HashMap<string, Value?>();
							
							_row.set("extern_id", woo_id); 
							_row.set("product_code", (string)prod["sku"]);
							_row.set("product_name", (string)prod["title"]); 
							_row.set("product_description", (string)prod["description"]);
							_row.set("product_quantity", qty); 
							_row.set("product_price", price);
							_row.set("product_price_2", regular_price);
							_row.set("product_price_3", sale_price);
							_row.set("store_id", store_id);
							_row.set("status", "publish");
							_row.set("last_modification_date", cdate);
							_row.set("creation_date", cdate);
							//##insert record
							product_id = (int)this.Dbh.Insert("products", _row);
							if( product_id <= 0 )
							{
								continue;
							}
							SBMeta.AddMeta("product_meta", "wc_product_type", "product_id", product_id, product_type, this.Dbh);
							SBMeta.AddMeta("product_meta", "wc_image_url", "product_id", product_id, image_url, this.Dbh);
							SBMeta.AddMeta("product_meta", "wc_categories", "product_id", product_id, (string)prod["categories"], this.Dbh);
							
							if( image_url.length > 0 )
							{
								stdout.printf("Downloading product image from : %s\n", image_url);
								string image_name	= File.new_for_uri(image_url).get_basename();
								string image_path = SBFileHelper.SanitizePath("images/store_%d/".printf(store_id));
								if( !FileUtils.test(image_path, FileTest.IS_DIR) )
								{
									DirUtils.create_with_parents(image_path, 0777);
								}
								
								image_name 			= SBFileHelper.GetUniqueFilename(image_path, image_name);
								string[] parts		= SBFileHelper.GetParts(image_name);
								string ext			= parts[1];
								string thumbnail	= "%s-80x80.%s".printf(parts[0], parts[1]);
								//##download image
								/*
								uint8[] buffer;
								SBWeb.RequestData(image_url, out buffer);
								//##write image
								FileUtils.set_data(image_path + image_name, buffer);
								*/
								SBWeb.Download(image_url, image_path + image_name, progress_callback);
								try
								{
									var pixbuf = new Gdk.Pixbuf.from_file(image_path + image_name);
									var scaled_pixbuf = pixbuf.scale_simple(80, 80, Gdk.InterpType.BILINEAR);
									//##write thumbnail
									scaled_pixbuf.save(image_path + thumbnail, (ext == "jpg") ? "jpeg" : ext, null, "quality", "100");
									//var prod_pixbuf = new Gdk.Pixbuf.from_inline(buffer);
									//var prod_pixbuf = new Gdk.Pixbuf.from_file_at_scale("test.png", 80, 80, true);
									string query_images = @"INSERT INTO attachments(object_type,object_id,type,mime,file) VALUES"+
														@"('Product',$product_id,'image', '$ext', '$image_name'),"+
														@"('Product',$product_id,'image_thumbnail', '$ext', '$thumbnail')";
									this.Dbh.Execute(query_images);
								}
								catch(GLib.Error e)
								{
									stderr.printf("ERROR: %s\n", e.message);
								}
								
							}
							imported++;
						}
						this.FixProductCategories(store_id, product_id);
						//##call sync callback
						if( cb != null ) cb(total_prods, imported, "", "");
						this.Dbh.EndTransaction();	
					}//end foreach
				}
				
				stdout.printf("Sync finished.\n");			
			}
			catch(Error e)
			{
				stderr.printf ("Error: %s\n", e.message);
			}
			
			return 0;
		}
		protected void FixProductCategories(int store_id, int product_id)
		{
			stdout.printf("FIXING PRODUCTS CATEGORIES\n================================\n");
			string q_delete = "DELETE FROM product2category WHERE product_id = %d".printf(product_id);
			this.Dbh.Execute(q_delete);
			string? str_cats = SBProduct.GetMeta(product_id, "wc_categories", this.Dbh);
			if( str_cats == null )
				return;
			string[] cats = str_cats.split(",");
			string cdate = new DateTime.now_local().format("%Y-%m-%d %H:%M:%S");
			string insert_query = "INSERT INTO product2category(product_id,category_id,creation_date) VALUES";
			bool do_insert = false;
			foreach(string cat_name in cats)
			{
				this.Dbh.Select("category_id,extern_id").From("categories").
					Where("name = '%s'".printf(cat_name.strip())).
					And("store_id = %d".printf(store_id));
				var row = this.Dbh.GetRow(null);
				if( row == null )
					continue;
				do_insert = true;
				insert_query += "(%d,%d,'%s'),".printf(product_id, row.GetInt("category_id"),cdate);
			}
			if( do_insert )
			{
				this.Dbh.Execute(insert_query.substring(0, insert_query.length - 1));
			}
		}
		public void SyncCustomers(int store_id)
		{
			this._api.debug = true;
			int total_customers = 0;
			int total_pages = 0;
			var customers = this._api.GetCustomers(100, 1, out total_customers, out total_pages);
			try
			{
				this.Dbh.BeginTransaction();
				
				for(int page = 1; page <= total_pages; page++)
				{
					if( page > 1 )
					{
						customers = this._api.GetCustomers(100, page, out total_customers, out total_pages);
					}
					foreach (var cust in customers) 
					{
						string cdate = new DateTime.now_local().format("%Y-%m-%d %H:%M:%S");
						int customer_id = 0;
						int woo_id 		= (int)cust["id"];
						var crow = new HashMap<string, Value?>();
						
						crow.set("first_name", (string)cust["first_name"]);
						crow.set("last_name", (string)cust["last_name"]);
						crow.set("company", (string)cust["billing_company"]);
						crow.set("phone", (string)cust["billing_phone"]);
						crow.set("email", (string)cust["email"]);
						crow.set("address_1", (string)cust["billing_address_1"]);
						crow.set("address_2", (string)cust["billing_address_2"]);
						crow.set("zip_code", (string)cust["billing_postcode"]);
						crow.set("city", (string)cust["billing_city"]);
						crow.set("country_code", (string)cust["billing_country"]);
						crow.set("address_1", (string)cust["billing_address_1"]);
						crow.set("last_modification_date", cdate);
						
						this.Dbh.Select("customer_id").From("customers").Where("store_id = %d".printf(store_id)).
							And("extern_id = %d".printf(woo_id));
						var row = this.Dbh.GetRow(null);
						if( row == null )
						{
							//##insert new customer
							crow.set("extern_id", woo_id);
							crow.set("store_id", store_id);
							crow.set("creation_date", cdate);
							customer_id = (int)this.Dbh.Insert("customers", crow);
							//##add meta
							//SBMeta.AddMeta("customer_meta", "", "customer_id", customer_id, "", this.Dbh);
							string query = "INSERT INTO customer_meta(customer_id, meta_key,meta_value,creation_date) VALUES";
							query += "(%d,'billing_city', '%s', '%s'),".printf(customer_id, this.Dbh.EscapeString((string)cust["billing_city"]), cdate);
							query += "(%d,'billing_state', '%s', '%s'),".printf(customer_id, this.Dbh.EscapeString((string)cust["billing_state"]), cdate);
							query += "(%d,'billing_email', '%s', '%s'),".printf(customer_id, this.Dbh.EscapeString((string)cust["billing_email"]), cdate);
							query += "(%d,'billing_phone', '%s', '%s'),".printf(customer_id, this.Dbh.EscapeString((string)cust["billing_phone"]), cdate);
							//##insert shipping data
							query += "(%d,'shipping_first_name', '%s', '%s'),".printf(customer_id, this.Dbh.EscapeString((string)cust["shipping_first_name"]), cdate);
							query += "(%d,'shipping_last_name', '%s', '%s'),".printf(customer_id, this.Dbh.EscapeString((string)cust["shipping_last_name"]), cdate);
							query += "(%d,'shipping_company', '%s', '%s'),".printf(customer_id, this.Dbh.EscapeString((string)cust["shipping_company"]), cdate);
							query += "(%d,'shipping_address_1', '%s', '%s'),".printf(customer_id, this.Dbh.EscapeString((string)cust["shipping_address_1"]), cdate);
							query += "(%d,'shipping_address_2', '%s', '%s'),".printf(customer_id, this.Dbh.EscapeString((string)cust["shipping_address_2"]), cdate);
							query += "(%d,'shipping_city', '%s', '%s'),".printf(customer_id, this.Dbh.EscapeString((string)cust["shipping_city"]), cdate);
							query += "(%d,'shipping_state', '%s', '%s'),".printf(customer_id, this.Dbh.EscapeString((string)cust["shipping_state"]), cdate);
							query += "(%d,'shipping_postcode', '%s', '%s'),".printf(customer_id, this.Dbh.EscapeString((string)cust["shipping_postcode"]), cdate);
							query += "(%d,'shipping_country', '%s', '%s')".printf(customer_id, this.Dbh.EscapeString((string)cust["shipping_country"]), cdate);
							this.Dbh.Execute(query);
						}
						else
						{
							customer_id = row.GetInt("customer_id");
							//##update customer
							var where = new HashMap<string, Value?>();
							where.set("customer_id", customer_id);
							this.Dbh.Update("customers", crow, where);
						}
					}
				}
				this.Dbh.EndTransaction();
			}
			catch(Error e)
			{
				stderr.printf ("Error: %s\n", e.message);
			}
		}
		protected string StripHtmlTags(string html)
		{
			string striped = "";
			try
			{
				var regex = new Regex("<.*?>");
			
				striped = regex.replace(html.strip(), html.strip().length, 0, "");
				//stdout.printf("%s\n%s\n", html, striped);
			}
			catch(RegexError e)
			{
				stderr.printf("RRROR: %s\n", e.message);
				striped = html.strip();
			}
			return striped;
		}
	}
}
