using GLib;
using Gee;
using Json;
using Woocommerce;
using SinticBolivia;
using SinticBolivia.Database;

namespace SinticBolivia
{
	public class SBWCSync : SBSynchronizer
	{
		protected	WC_Api_Client _api;
		
		public SBWCSync(string wp_url, string api_key, string api_secret)
		{
			this._api = new WC_Api_Client(wp_url, api_key, api_secret);
		}
		public override long SyncStore()
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
		public override long SyncCategories(int store_id = -1)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			long records = 0;
			this._api.debug = true;
			string error = "";
			var cats = (ArrayList<HashMap<string, Value?>>)this._api.GetCategories(out error);
			if( cats == null )
			{
				stderr.printf("Error trying to sync categories, ERROR: %s\n", error);
				return -1;
			}
			dbh.BeginTransaction();
			foreach(var cat in cats)
			{
				int xcat_id = (int)cat["term_id"];
				string query = "SELECT category_id FROM categories WHERE extern_id = %d AND store_id = %d".printf(xcat_id, store_id);
				stdout.printf("%s\n", query);
				if( dbh.Query(query) > 0 )
				{
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
				
			}
			dbh.EndTransaction();
			return records;
		}
		public override long SyncProducts(int store_id = -1)
		{
			long records = 0;
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			//this._api.debug = true;
			Json.Object products = this._api.GetProducts();
			try
			{
				if( products.has_member("errors") )
				{
					/*
					var error = products.get_array_member("errors").get_element(0).get_object();
					MessageDialog msg = new MessageDialog(null, DialogFlags.MODAL, MessageType.ERROR, ButtonsType.CLOSE, 
													error.get_string_member("message"));
					msg.run();
					msg.destroy();
					return null;
					*/
				}
				int total_pages = (int)products.get_int_member("total_pages");
				records = (long)products.get_int_member("total_products");
				stdout.printf ("\ntotal products %ld:\n", records);
				stdout.printf ("store_id: %d\nTotal pages %d:\n", store_id, total_pages);
				dbh.BeginTransaction();
				
				for(int page = 1; page <= total_pages; page++)
				{
					if( page > 1 )
					{
						products = this._api.GetProducts(50, page);
					}
					stdout.printf ("Synchronizing page: %d\n", page);
					foreach (var geonode in products.get_array_member("products").get_elements ()) 
					{
						Json.Object product	= geonode.get_object ();
						int64 pid = product.get_int_member("id");
						double price = double.parse(product.get_string_member ("price"));
						int	qty	= (int)product.get_int_member("stock_quantity");
						string product_type = product.get_string_member("type");
						string query = "SELECT product_id FROM products WHERE extern_id = %d AND store_id = %d LIMIT 1".
											printf((int)pid, store_id);
						var rows = (ArrayList<SBDBRow>)dbh.GetResults(query);
						long product_id = 0;
						
						if( rows.size > 0 )
						{
							product_id = rows.get(0).GetInt("product_id");
							//TODO:update product stock
							var udata = new HashMap<string, Value?>();
							udata.set("product_description", product.get_string_member("description"));
							udata.set("product_quantity", qty);
							var uw = new HashMap<string, Value?>();
							uw.set("extern_id", (int)pid);
							dbh.Update("products", udata, uw);
						}
						else
						{
							Json.Array images 	= product.get_array_member("images");
							Json.Object image 	= images.get_element(0).get_object();
							string image_url 	= image.get_string_member("src").strip();
							string image_name	= File.new_for_uri(image_url).get_basename();
							
							//stdout.printf("name:%s, extension: %s\n", parts[0], parts[1]);
							uint8[] buffer;
							SBWeb.RequestData(image.get_string_member("src"), out buffer);
							string image_path = SBFileHelper.SanitizePath("images/");
							
							image_name = SBFileHelper.GetUniqueFilename(image_path, image_name);
							string[] parts		= SBFileHelper.GetParts(image_name);
							string ext			= parts[1];
							string thumbnail	= "%s-80x80.%s".printf(parts[0], parts[1]);
							//write image
							FileUtils.set_data(image_path + image_name, buffer);
							var pixbuf = new Gdk.Pixbuf.from_file(image_path + image_name);
							var scaled_pixbuf = pixbuf.scale_simple(80, 80, Gdk.InterpType.BILINEAR);
							//write thumbnail
							scaled_pixbuf.save(image_path + thumbnail, (ext == "jpg") ? "jpeg" : ext, null, "quality", "100");
							
							//var prod_pixbuf = new Gdk.Pixbuf.from_inline(buffer);
							//var prod_pixbuf = new Gdk.Pixbuf.from_file_at_scale("test.png", 80, 80, true);
							
							HashMap<string, Value?> row = new HashMap<string, Value?>();
							
							row.set("extern_id", pid); 
							row.set("product_name", product.get_string_member ("title")); 
							row.set("product_description", product.get_string_member("description"));
							row.set("product_quantity", qty); 
							row.set("product_price", price);
							row.set("store_id", store_id);
							//row.set("image", new Gdk.Pixbuf.from_file("share/images/add-icon.png"));
							//##insert record
							product_id = dbh.Insert("products", row);
							string query_images = "INSERT INTO attachments(object_type,object_id,type,mime,file) VALUES"+
													@"('Product',$product_id,'image', '$ext', '$image_name'),"+
													@"('Product',$product_id,'image_thumbnail', '$ext', '$thumbnail')";
							dbh.Execute(query_images);
							dbh.Execute(@"INSERT INTO product_meta(product_id, meta_key, meta_value) VALUES($product_id,'product_type', '$product_type')");
							//##check for variations
							if( product.has_member("variations") && product.get_array_member("variations").get_length() > 0 )
							{
								foreach(var node in product.get_array_member("variations").get_elements())
								{
									var variation = node.get_object();
								}
							}
						}
						string qc = "DELETE FROM product2category WHERE product_id = %ld".printf(product_id);
						dbh.Execute(qc);
						//##set product categories
						foreach(var cat_node in product.get_array_member("categories_ids").get_elements())
						{
							int xcat_id = (int)cat_node.get_int();
							query = "SELECT category_id FROM categories WHERE extern_id = %d AND store_id = %d".
										printf(xcat_id, store_id);
							long res = dbh.Query(query);
							if( res > 0 )
							{
								int icat_id = dbh.Rows[0].GetInt("category_id");
								query = "INSERT INTO product2category(product_id,category_id) VALUES(%ld,%d)".printf(product_id, icat_id);
								dbh.Execute(query);
							}
						}
					}
				}
				dbh.EndTransaction();	
				stdout.printf("Sync finished.\n");			
			}
			catch(Error e)
			{
				stderr.printf ("Error: %s\n", e.message);
			}
			
			return records;
		}
		public void SyncCustomers()
		{
			
		}
	}
}
