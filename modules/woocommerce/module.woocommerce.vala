using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Database;
using SinticBolivia.Gtk;

namespace EPos.Woocommerce
{
	public class SB_ModuleWoocommerce : SBGtkModule, ISBModule
	{
		public string Id{get{return this._moduleId;}}
		public string Name{get{return this._name;}}
		public string Description{get{return this._description;}}
		public string Author{get{return this._author;}}
		public double Version{get{return this._version;}}
		public string LibraryName{get{return "Woocommerce";}}
		public string	Dependencies{get{return "Pos";}}
		construct
		{
			this._moduleId 		= "mod_woocommerce";
			this._name			= "Woocommerce Pos Integration";
			this._description 	= "";
			this._author 		= "Sintic Bolivia";
			this._version 		= 1.0;
			this.resourceFile 	= "./modules/woocommerce.gresource";
			this.resourceNs		= "/net/sinticbolivia/Pos/Woocommerce";
		}
		public void Enabled()
		{
			this.LoadResources();
		}
		public void Disabled()
		{
		}
		public void Load()
		{
				
		}
		public void Unload()
		{
		}
		public void Init()
		{
			this.LoadResources();
			this.AddHooks();
		}
		protected void AddHooks()
		{
			var hook0 = new SBModuleHook(){HookName = "init_menu_management", handler = hook_init_menu_management};
			SBModules.add_action("init_menu_management", ref hook0);
			var hook1 = new SBModuleHook(){HookName = "before_register_sale", handler = hook_before_register_sale};
			SBModules.add_action("before_register_sale", ref hook1);
			var hook2 = new SBModuleHook(){HookName = "modules_loaded", handler = hook_modules_loaded};
			SBModules.add_action("modules_loaded", ref hook2);
			var hook3 = new SBModuleHook(){HookName = "build_create_customer_dlg", handler = hook_build_create_customer_dlg};
			SBModules.add_action("build_create_customer_dlg", ref hook3);
		}
		protected void hook_init_menu_management(SBModuleArgs<Gtk.Menu> args)
		{
			var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
			var menu = (Gtk.Menu)args.GetData();
			var mi_wc = new Gtk.ImageMenuItem.with_label(SBText.__("Woocommerce"));
			mi_wc.image = new Image.from_pixbuf(this.GetPixbuf("WooLogo-25x15.png"));
			mi_wc.show();
			mi_wc.submenu = new Gtk.Menu();
			menu.add(mi_wc);
			
			var mi_stores = new Gtk.MenuItem.with_label(SBText.__("Stores"));
			mi_stores.show();
			mi_stores.activate.connect( () => 
			{
				if( notebook.GetPage("wc-stores") == null )
				{
					var w = new WidgetWoocommerceStores();
					w.show();
					notebook.AddPage("wc-stores", SBText.__("Woocommerce Stores"), w);
				}
				notebook.SetCurrentPageById("wc-stores");
			});
			mi_wc.submenu.add(mi_stores);
			
			var mi_cats = new Gtk.MenuItem.with_label(SBText.__("Categories"));
			mi_cats.show();
			mi_cats.activate.connect( () => 
			{
				if( notebook.GetPage("wc-categories") == null )
				{
					var w = new WidgetWoocommerceCategories();
					w.show();
					notebook.AddPage("wc-categories", SBText.__("Woocommerce Categories"), w);
				}
				notebook.SetCurrentPageById("wc-categories");
			});
			mi_wc.submenu.add(mi_cats);
			
			
			var mi_prods = new Gtk.MenuItem.with_label(SBText.__("Products"));
			mi_prods.show();
			mi_prods.activate.connect( () => 
			{
				if( notebook.GetPage("wc-products") == null )
				{
					var w = new WidgetWoocommerceProducts();
					w.show();
					notebook.AddPage("wc-products", SBText.__("Woocommerce Products"), w);
				}
				notebook.SetCurrentPageById("wc-products");
			});
			mi_wc.submenu.add(mi_prods);
			
			var mi_cust = new Gtk.MenuItem.with_label(SBText.__("Customers"));
			mi_cust.show();
			mi_cust.activate.connect( () => 
			{
				if( notebook.GetPage("wc-customers") == null )
				{
					var w = new WidgetWoocommerceCustomers();
					w.show();
					notebook.AddPage("wc-customers", SBText.__("Woocommerce Customers"), w);
				}
				notebook.SetCurrentPageById("wc-customers");
			});
			mi_wc.submenu.add(mi_cust);
			
			var mi_orders = new Gtk.MenuItem.with_label(SBText.__("Orders"));
			mi_orders.show();
			mi_orders.activate.connect( () => 
			{
				if( notebook.GetPage("wc-orders") == null )
				{
					var w = new WidgetWoocommerceOrders();
					w.show();
					notebook.AddPage("wc-orders", SBText.__("Woocommerce Orders"), w);
				}
				notebook.SetCurrentPageById("wc-orders");
			});
			mi_wc.submenu.add(mi_orders);
		}
		protected void hook_before_register_sale(SBModuleArgs<HashMap> args)
		{
			var data = (HashMap<string, Value?>)args.GetData();
			var store = (SBStore)data["store"];
			if( store.Get("store_type") != "woocommerce" )
				return;
			var meta = (HashMap<string, Value?>)data["sale_meta"];
			meta.set("sale_type", "woocommerce");
			meta.set("wc_sync_status", "pending");
			meta.set("wc_status", "pending");
		}
		protected void hook_modules_loaded(SBModuleArgs<string> args)
		{
			try
			{
				/*Thread<int> thread = */new Thread<int>.try ("Woocommerce Sync Orders thread", () => 
				{
					GLib.Timeout.add_seconds(60, this.SyncOrders);
					return 0;
				});
			}
			catch(GLib.Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
		}
		protected void hook_build_create_customer_dlg(SBModuleArgs<Box> args)
		{
			var customer_box = (Box)args.GetData();
			var widget = new WidgetCustomerData();
			widget.show();
			customer_box.add(widget);
		}
		protected bool SyncOrders()
		{
			var cfg = (SBConfig)SBGlobals.GetVar("config");
			var dbh = SBFactory.GetNewDbHandlerFromConfig(cfg);
			var stores = WCHelper.GetStores();
			string woo_order_status = "processing";
			foreach(var store in stores)
			{
				stdout.printf("Synchronizing \"%s\" store orders\n", store.Name);
				var orders = WCHelper.GetOrdersPendingToSync(store.Id);
			
				string url = SBStore.SGetMeta(store.Id, "woocommerce_url");
				string key = SBStore.SGetMeta(store.Id, "woocommerce_key");
				string secret = SBStore.SGetMeta(store.Id, "woocommerce_secret");
				var api = new WC_Api_Client(url, key, secret);
				api.debug = true;
				
				foreach(var order in orders)
				{
					var gen = new Json.Generator();
					var root = new Json.Node(Json.NodeType.OBJECT);
					var main_obj = new Json.Object();
					root.set_object(main_obj);
					gen.set_root(root);
					
					var woo_order = new Json.Object();
					main_obj.set_object_member("order", woo_order);
					
					var payment_details 	= new Json.Object();
					var billing_address 	= new Json.Object();
					var shipping_address 	= new Json.Object();
					var line_items			= new Json.Array();
					woo_order.set_object_member("payment_details", payment_details);
					woo_order.set_object_member("billing_address", billing_address);
					woo_order.set_object_member("shipping_address", shipping_address);
					woo_order.set_array_member("line_items", line_items);
					//##get local customer
					int customer_id = int.parse(order.Customer["customer_id"]);
					SBCustomer? customer = (customer_id > 0) ? new SBCustomer.from_id(customer_id) : null;
					int woo_customer_id = customer.GetInt("extern_id");
					if( woo_customer_id <= 0 && customer != null )
					{
						//##create the customer into woocommerce
						string customer_json = WCHelper.BuildCustomerJson(customer);
						var args = new HashMap<string,string>();
						args.set("raw_data", customer_json);
						args.set("content_type", "application/json");
						var new_customer = api.CreateCustomer(args);
						if( new_customer["id"] != null )
						{
							woo_customer_id = (int)new_customer["id"];
							//##update customer woo id
							dbh.Execute("UPDATE customers SET extern_id = %d WHERE customer_id = %d".printf(woo_customer_id, customer_id));
						}
						else
						{
							stderr.printf("ERROR CREATING WOOCOMMERCE CUSTOMER.\n");
						}
					}
					//##build payment details
					payment_details.set_string_member("method_id", (order.Meta["payment_method"] != null) ? (string)order.Meta["payment_method"] : "undefined");
					payment_details.set_string_member("method_title", (order.Meta["payment_method"] != null) ? (string)order.Meta["payment_method"] : "undefined");
					payment_details.set_boolean_member("paid", true);
					if( woo_customer_id > 0 )
						woo_order.set_int_member("customer_id", woo_customer_id);
					
					//woo_order.set_string_member("status", woo_order_status);
					woo_order.set_string_member("note", order.Notes);
					if( customer != null )
					{
						//##build billing address
						billing_address.set_string_member("first_name", (customer.Meta["billing_first_name"] != null) ? customer.Meta["billing_first_name"] : "");
						billing_address.set_string_member("last_name", (customer.Meta["billing_last_name"] != null) ? customer.Meta["billing_last_name"] : "");
						billing_address.set_string_member("company", (customer.Meta["billing_company"] != null) ? customer.Meta["billing_company"] : customer.Get("company"));
						billing_address.set_string_member("address_1", (customer.Meta["billing_address_1"] != null) ? customer.Meta["billing_address_1"] : "");
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
						shipping_address.set_string_member("address_1", (customer.Meta["shipping_address_1"] != null ) ? customer.Meta["shipping_address_1"] : "");
						shipping_address.set_string_member("address_2", (customer.Meta["shipping_address_2"] != null ) ? customer.Meta["shipping_address_2"] : "");
						shipping_address.set_string_member("city", (customer.Meta["shipping_city"] != null) ? customer.Meta["shipping_city"] : "");
						shipping_address.set_string_member("state", (customer.Meta["shipping_state"] != null) ? customer.Meta["shipping_state"] : "");
						shipping_address.set_string_member("postcode", (customer.Meta["shipping_postcode"] != null) ? customer.Meta["shipping_postcode"] : "");
						shipping_address.set_string_member("country", (customer.Meta["shipping_country"] != null) ? customer.Meta["shipping_country"] : "");
					}
					
					foreach(var item in order.Items)
					{
						var prod = dbh.GetRow("SELECT extern_id FROM products where product_id = %d".printf(item.ProductId));
						var order_item = new Json.Object();
						order_item.set_int_member("product_id", prod.GetInt("extern_id"));
						order_item.set_int_member("quantity", item.Quantity);
						line_items.add_object_element(order_item);
					}
					//##hook the json order object
					var args0 = new SBModuleArgs<HashMap>();
					var order_data_args = new HashMap<string, Value?>();
					order_data_args.set("order", order);
					order_data_args.set("json_order", woo_order);
					args0.SetData(order_data_args);
					SBModules.do_action("wc_before_send_order", args0);
					
					size_t length;
					var args = new HashMap<string, string>();
					args.set("raw_data", gen.to_data(out length));
					args.set("content_type", "application/json");
					//stdout.printf("JSON:\n%s\n", (string)args["raw_data"]);
					//##send the order to woocommerces
					var new_woo_order = api.PlaceOrder(args);
					if( new_woo_order["id"] != null )
					{
						SBMeta.UpdateMeta("sale_meta", "wc_status", (string)new_woo_order["status"], "sale_id", order.Id);
						SBMeta.UpdateMeta("sale_meta", "wc_sync_status", "completed", "sale_id", order.Id);
						SBMeta.UpdateMeta("sale_meta", "wc_order_id", ((int)new_woo_order["id"]).to_string(), "sale_id", order.Id);
						SBMeta.UpdateMeta("sale_meta", "wc_order_url", (string)new_woo_order["view_order_url"], "sale_id", order.Id);
					}
					else if( new_woo_order.has_key("pending_to_sync") )
					{
						//SBMeta.UpdateMeta("sale_meta", "wc_sync_status", "pending", "sale_id", order.Id);
					}
					else
					{
						SBMeta.UpdateMeta("sale_meta", "wc_sync_status", "failed", "sale_id", order.Id);
					}
				}
				
			}
			dbh.Close();
			return true; //return true to continue calling the timeout
		}
	}
}
public Type sb_get_module_libwoocommerce_type(Module mod)
{
	return typeof(EPos.Woocommerce.SB_ModuleWoocommerce);
}
