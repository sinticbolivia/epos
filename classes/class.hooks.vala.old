using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Database;

namespace Woocommerce
{
	public class ECHooks : Object
	{
		public static void AddInventoryHooks()
		{
			var hook0 = new SBModuleHook(){HookName = "", handler = ECHooks.hook_box_store};
			var hook1 = new SBModuleHook(){HookName = "", handler = ECHooks.hook_edit_store};
			var hook2 = new SBModuleHook(){HookName = "", handler = ECHooks.hook_save_store};
			
			SBModules.add_action("box_store", ref hook0);
			SBModules.add_action("edit_store", ref hook1);
			SBModules.add_action("save_store", ref hook2);
		}
		protected static void hook_box_store(SBModuleArgs<HashMap> args)
		{
			var data = (HashMap<string, Value?>)args.GetData();
			var box	= (Box)data["box_store"];
			int store_id = (int)data["store_id"];
			//##build woocommerce fields
			var wc_box = new WCWidget();
			wc_box.show();
			wc_box.LoadData(store_id);
			box.add(wc_box);
		}
		protected static void hook_edit_store(SBModuleArgs<HashMap> args)
		{
			var data 		= (HashMap<string, Value?>)args.GetData();
			int store_id 	= (int)data["store_id"];
			Box	box			= (Box)data["box_store"];
			WCWidget wc_box = null;
						
			box.get_children().foreach((child) =>
			{
				if( child.name == "wc_box" )
				{
					wc_box		= (WCWidget)child;
					wc_box.LoadData(store_id);			
				}
			});
		}
		protected static void hook_save_store(SBModuleArgs<HashMap> args)
		{
			var data 		= (HashMap<string, Value?>)args.GetData();
			int store_id 	= (int)data["store_id"];
			Box	box			= (Box)data["box_store"];
			
			if( store_id > 0 )
			{
				
			}
			WCWidget wc_box = null;
			//ComboBox store_types = null;
			
			box.get_children().foreach((child) =>
			{
				//stdout.printf("name => %s\n", child.name);
				if( child.name == "wc_box" )
				{
					wc_box		= (WCWidget)child;
					wc_box.SaveData(store_id);			
				}
			});
			
		}
	}
	public class WCWidget : Box
	{
		protected	ComboBox store_types;
		protected 	Label	label;
		protected 	Label	label_api_key;
		protected 	Label	label_api_secret;
		protected 	Entry	url;
		protected	Entry	text_api_key;
		protected	Entry	text_api_secret;
		protected	Button	buttonSyncWoocommerce;
		protected	int		storeId = 0;
		protected	bool	Synchronizing{get;set;}
		protected	SBWCSync	sync_obj;
		
		public WCWidget()
		{
			this.orientation = Orientation.VERTICAL;
			this.spacing = 5;
			this.name = "wc_box";
			
			this.store_types = new ComboBox(){name = "store_types"};
			this.store_types.show();
			this.label = new Label(SBText.__("Store Type:")){xalign = 0};
			this.label_api_key = new Label(SBText.__("Api Key:")){xalign = 0};
			this.label_api_secret = new Label(SBText.__("Api Secret:")){xalign = 0};
			this.url				= new Entry(){placeholder_text = SBText.__("Woocommerce Url")};
			this.text_api_key		= new Entry(){name = "entry_api_key"};
			this.text_api_secret	= new Entry(){name = "entry_api_secret"};
			this.buttonSyncWoocommerce = new Button.with_label(SBText.__("Sync Data"));
			
			this.label.show();
			/*
			this.label_api_key.show();
			this.label_api_secret.show();
			this.text_api_key.show();
			this.text_api_secret.show();
			this.buttonSyncWoocommerce.show();
			*/
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			this.store_types.model = new ListStore(2, typeof(string), typeof(string));
			var cell = new CellRendererText();
			this.store_types.pack_start(cell, false);
			this.store_types.set_attributes(cell, "text", 0);
			this.store_types.id_column = 1;
			TreeIter iter;
			(this.store_types.model as ListStore).append(out iter);
			(this.store_types.model as ListStore).set(iter, 0, SBText.__("-- store type --"), 1, "-1");
			(this.store_types.model as ListStore).append(out iter);
			(this.store_types.model as ListStore).set(iter, 0, SBText.__("Local Store"), 1, "local");
			(this.store_types.model as ListStore).append(out iter);
			(this.store_types.model as ListStore).set(iter, 0, "Woocommerce", 1, "woocommerce");
			(this.store_types.model as ListStore).append(out iter);
			(this.store_types.model as ListStore).set(iter, 0, "Mono Business", 1, "mb");
			(this.store_types.model as ListStore).append(out iter);
			(this.store_types.model as ListStore).set(iter, 0, "Shopify", 1, "shopify");
			this.store_types.active_id = "-1";
			
						
			this.add(label);
			this.add(this.store_types);
			this.add(this.url);
			this.add(label_api_key);
			this.add(this.text_api_key);
			this.add(label_api_secret);
			this.add(this.text_api_secret);
			this.add(this.buttonSyncWoocommerce);
		}
		protected void SetEvents()
		{
			this.notify["Synchronizing"].connect( () => 
			{
				//stdout.printf("sync: %s\n", this.Synchronizing ? "true" : "false");
				if( this.Synchronizing == false)
				{
					//var msg = new MessageDialog((Window)this.get_toplevel(), 
					var msg = new MessageDialog((Window)this.get_ancestor(typeof(Window)), 
												DialogFlags.MODAL, 
												MessageType.INFO, 
												ButtonsType.OK, 
												SBText.__("Synchronization finished.")
					);
					msg.title = SBText.__("Woocommerce Synchronization");
					msg.run();
					msg.destroy();
				}
			});
			this.store_types.changed.connect( () => 
			{
				
				if( this.store_types.active_id == null || this.store_types.active_id != "woocommerce" )
				{
					this.url.hide();
					this.label_api_key.hide();
					this.label_api_secret.hide();
					this.text_api_key.hide();
					this.text_api_secret.hide();
					this.buttonSyncWoocommerce.hide();
					return;
				}
				this.url.show();
				this.label_api_key.show();
				this.label_api_secret.show();
				this.text_api_key.show();
				this.text_api_secret.show();
				this.buttonSyncWoocommerce.show();
			});
			this.buttonSyncWoocommerce.clicked.connect(this.OnButtonSyncWoocommerceClicked);
		}
		protected void OnButtonSyncWoocommerceClicked()
		{
			if( this.storeId <= 0 )
			{
				var msg = new MessageDialog(null, DialogFlags.MODAL, MessageType.INFO, ButtonsType.CLOSE, 
							SBText.__("You need to save the store first.")
				);
				msg.run();
				msg.destroy();
				return;
			}
			
			string url = this.url.text.strip();
			string api_key = this.text_api_key.text.strip();
			string api_secret = this.text_api_secret.text.strip();
			
			this.sync_obj = new SBWCSync(url, api_key, api_secret);
			//sync.SyncCategories(store_id);
			//sync.SyncProducts(store_id);
			new Thread<void*>("thread1", this.StartSync);
			this.Synchronizing = true;
		}
		protected void* StartSync()
		{
			this.sync_obj.SyncCategories(this.storeId);
			this.sync_obj.SyncProducts(this.storeId);
			GLib.Idle.add( () => 
			{
				this.Synchronizing = false;
				return false;
			}, Priority.HIGH_IDLE);
			
			
			return null;
		}
		public void LoadData(int store_id)
		{
			this.storeId = store_id;
			
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = @"SELECT * FROM stores WHERE store_id = $store_id LIMIT 1";
			var store = dbh.GetRow(query);
			if( store == null )
			{
				this.url.text = "";
				this.text_api_key.text = "";
				this.text_api_secret.text = "";
				return;
			}
			this.store_types.active_id = store.Get("store_type");
			var row0 = SBMeta.GetMetaRow("store_meta", "wc_api_key", "store_id", store_id);
			var row1 = SBMeta.GetMetaRow("store_meta", "wc_api_secret", "store_id", store_id);
			var row2 = SBMeta.GetMetaRow("store_meta", "wc_url", "store_id", store_id);
			this.url.text = row2.Get("meta_value");
			this.text_api_key.text = row0.Get("meta_value");
			this.text_api_secret.text = row1.Get("meta_value");
		}
		public void SaveData(int store_id)
		{
			if( this.store_types.active_id == "woocommerce" )
			{
				string query = "UPDATE stores SET store_type = 'woocommerce' WHERE store_id = %d".
								printf(store_id);
				((SBDatabase)SBGlobals.GetVar("dbh")).Execute(query);
				
				string wc_url		= this.url.text.strip();
				string api_key 		= this.text_api_key.text.strip();
				string api_secret 	= this.text_api_secret.text.strip();
				
				SBMeta.UpdateMeta("store_meta", "wc_url", wc_url, "store_id", store_id);
				SBMeta.UpdateMeta("store_meta", "wc_api_key", api_key, "store_id", store_id);
				SBMeta.UpdateMeta("store_meta", "wc_api_secret", api_secret, "store_id", store_id);
			}
		}
		public static void AddReports()
		{
		}
	}
}
