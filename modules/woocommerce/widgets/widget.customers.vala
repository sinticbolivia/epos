using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos.Woocommerce
{
	public class WidgetWoocommerceCustomers : Box
	{
		protected	Builder			ui;
		protected	Box				box1;
		protected	Image			image1;
		protected	ComboBox		comboboxStore;	
		protected	Button			buttonDetails;
		protected	Button			buttonSync;
		protected	TreeView		treeviewCustomers;
		protected	enum			Columns
		{
			SELECT,
			COUNT,
			IMAGE,
			ID,
			WOO_ID,
			FIRST_NAME,
			LAST_NAME,
			EMAIL,
			N_COLS
		}
		protected	int				storeId = 0;
		
		public WidgetWoocommerceCustomers()
		{
			this.expand = true;
			this.ui					= (SBModules.GetModule("Woocommerce") as SBGtkModule).GetGladeUi("customers.glade");
			this.box1				= (Box)this.ui.get_object("box1");
			this.image1				= (Image)this.ui.get_object("image1");
			this.comboboxStore		= (ComboBox)this.ui.get_object("comboboxStore");
			this.buttonDetails		= (Button)this.ui.get_object("buttonDetails");
			this.buttonSync			= (Button)this.ui.get_object("buttonSync");
			this.treeviewCustomers	= (TreeView)this.ui.get_object("treeviewCustomers");
			this.box1.expand = true;
			this.box1.reparent(this);
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			this.image1.pixbuf = (SBModules.GetModule("Woocommerce") as SBGtkModule).GetPixbuf("woocommerce_logo-64x64.png");
			//##builder combobox stores
			this.comboboxStore.model = new ListStore(2, typeof(string), typeof(string));
			var cell = new CellRendererText();
			this.comboboxStore.pack_start(cell, true);
			this.comboboxStore.set_attributes(cell, "text", 0);
			this.comboboxStore.id_column = 1;
			this.treeviewCustomers.model = new ListStore(Columns.N_COLS,
				typeof(bool), //select
				typeof(int), //count
				typeof(Gdk.Pixbuf),
				typeof(int), //ID
				typeof(int), //Woo id
				typeof(string), //firstname
				typeof(string), //lastname
				typeof(string) //email
			);
			string[,] cols = 
			{
				{SBText.__("Select"), "toggle", "40", "center", "", ""},
				{"#", "text", "40", "center", "", ""},
				{SBText.__("Image"), "pixbuf", "80", "center", "", ""},
				{SBText.__("ID"), "text", "40", "center", "", ""},
				{SBText.__("Woo ID"), "text", "40", "center", "", ""},
				{SBText.__("First Name"), "text", "180", "left", "", ""},
				{SBText.__("Last Name"), "text", "180", "left", "", ""},
				{SBText.__("Email"), "text", "150", "left", "", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewCustomers);
			this.treeviewCustomers.rules_hint = true;
			//##refresh stores
			TreeIter iter;
			(this.comboboxStore.model as ListStore).append(out iter);
			(this.comboboxStore.model as ListStore).set(iter, 
				0, SBText.__("-- store --"),
				1, "-1"
			);
			foreach(var store in WCHelper.GetStores())
			{
				(this.comboboxStore.model as ListStore).append(out iter);
				(this.comboboxStore.model as ListStore).set(iter, 
					0, store.Name,
					1, store.Id.to_string()
				);
			}
			this.comboboxStore.active_id = "-1";
		}
		protected void SetEvents()
		{
			this.comboboxStore.changed.connect(this.OnCamboBoxStoreChanged);
			this.buttonSync.clicked.connect(this.OnButtonSyncClicked);
		}
		protected void OnCamboBoxStoreChanged()
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1" )
			{
				(this.treeviewCustomers.model as ListStore).clear();
				return;
			}
			int store_id = int.parse(this.comboboxStore.active_id);
			this.Refresh(store_id);
		}
		protected void OnButtonSyncClicked()
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1" )
			{
				var err = new InfoDialog("error")
				{
					Title = SBText.__("Synchronization error"),
					Message = SBText.__("You need to select a store")
				};
				err.run();
				err.destroy();
				return;
			}
			this.storeId = int.parse(this.comboboxStore.active_id);
			try
			{
				Thread<int> thread = new Thread<int>.try ("Woocommerce Sync Customers thread", this.SyncCustomers);
			}
			catch(GLib.Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
		}
		protected void Refresh(int store_id)
		{
			(this.treeviewCustomers.model as ListStore).clear();
			TreeIter iter;
			int i = 1;
			var placeholder = (SBModules.GetModule("Woocommerce") as SBGtkModule).GetPixbuf("customer-no-image-80x80.png");
			foreach(var c in WCHelper.GetStoreCustomers(store_id))
			{
				(this.treeviewCustomers.model as ListStore).append(out iter);
				(this.treeviewCustomers.model as ListStore).set(iter,
					Columns.SELECT, false,
					Columns.COUNT, i,
					Columns.IMAGE, placeholder,
					Columns.ID, c.GetInt("customer_id"),
					Columns.WOO_ID, c.GetInt("extern_id"),
					Columns.FIRST_NAME, c.Get("first_name"),
					Columns.LAST_NAME, c.Get("last_name"),
					Columns.EMAIL, c.Get("email")
				);
				i++;
			}
		}
		protected int SyncCustomers()
		{
			var cfg = (SBConfig)SBGlobals.GetVar("config");
			string url = SBStore.SGetMeta(this.storeId, "woocommerce_url");
			string key = SBStore.SGetMeta(this.storeId, "woocommerce_key");
			string secret = SBStore.SGetMeta(this.storeId, "woocommerce_secret");
			var sync = new SBWCSync(url, key, secret);
			sync.Dbh = SBFactory.GetNewDbHandlerFromConfig(cfg);
			sync.SyncCustomers(this.storeId);
			sync.Dbh.Close();
			
			GLib.Idle.add( () => 
			{
				this.Refresh(this.storeId);
				return false;
			});
			return 0;
		}
	}
}
