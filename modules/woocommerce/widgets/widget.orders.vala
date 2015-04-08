using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;

namespace EPos.Woocommerce
{
	public class WidgetWoocommerceOrders : Box
	{
		protected	Builder			ui;
		protected	Box				box1;
		protected	Image			image1;
		protected	ComboBox		comboboxStore;
		protected	Button			buttonDetails;
		protected	Button			buttonSync;
		protected	Button			buttonRefresh;
			
		protected	TreeView		treeviewOrders;
		protected	enum			Columns
		{
			SELECT,
			COUNT,
			ID,
			WOO_ID,
			CUSTOMER,
			LOCAL_STATUS,
			WOO_STATUS,
			TOTAL,
			ORDER_DATE,
			N_COLS
		}
		protected	int				storeId = 0;
		
		public WidgetWoocommerceOrders()
		{
			this.expand				= true;
			this.ui					= (SBModules.GetModule("Woocommerce") as SBGtkModule).GetGladeUi("orders.glade");
			this.box1				= (Box)this.ui.get_object("box1");
			this.image1				= (Image)this.ui.get_object("image1");
			this.comboboxStore		= (ComboBox)this.ui.get_object("comboboxStore");
			this.buttonDetails		= (Button)this.ui.get_object("buttonDetails");
			this.buttonSync			= (Button)this.ui.get_object("buttonSync");
			this.buttonRefresh		= (Button)this.ui.get_object("buttonRefresh");
			this.treeviewOrders		= (TreeView)this.ui.get_object("treeviewOrders");
			this.box1.reparent(this);
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			this.image1.pixbuf = (SBModules.GetModule("Woocommerce") as SBGtkModule).GetPixbuf("woocommerce_bundles-64x64.png");
			//##builder combobox stores
			this.comboboxStore.model = new ListStore(2, typeof(string), typeof(string));
			var cell = new CellRendererText();
			this.comboboxStore.pack_start(cell, true);
			this.comboboxStore.set_attributes(cell, "text", 0);
			this.comboboxStore.id_column = 1;
						
			this.treeviewOrders.model = new ListStore(Columns.N_COLS,
				typeof(bool), //select
				typeof(int), //count
				typeof(int), //ID
				typeof(int), //Woo id
				typeof(string), //customer
				typeof(string), //local status
				typeof(string), //woo status
				typeof(string), //total
				typeof(string) //date
			);
			string[,] cols = 
			{
				{SBText.__("Select"), "toggle", "40", "center", "", ""},
				{"#", "text", "40", "center", "", ""},
				{SBText.__("ID"), "text", "50", "center", "", ""},
				{SBText.__("Woo ID"), "text", "50", "center", "", ""},
				{SBText.__("Customer"), "markup", "250", "left", "", ""},
				{SBText.__("Local Status"), "text", "120", "left", "", ""},
				{SBText.__("Woo Status"), "text", "120", "left", "", ""},
				{SBText.__("Total"), "text", "120", "right", "", ""},
				{SBText.__("Date"), "text", "130", "right", "", ""},
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewOrders);
			this.treeviewOrders.rules_hint = true;
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
			this.comboboxStore.changed.connect(this.OnComboBoxStoreChanged);
			this.buttonSync.clicked.connect(this.OnButtonSyncClicked);
			this.buttonRefresh.clicked.connect(this.OnButtonRefreshClicked);
		}
		protected void OnComboBoxStoreChanged()
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1" )
			{
				return;
			}
			this.Refresh(int.parse(this.comboboxStore.active_id));
		}
		protected void OnButtonSyncClicked()
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1" )
			{
				var err = new InfoDialog()
				{
					Title = SBText.__("Products Synchronization error"),
					Message = SBText.__("You need to select a store")
				};
				err.run();
				err.destroy();
				return;
			}
			this.storeId = int.parse(this.comboboxStore.active_id);
			/*
			try
			{
				this.windowProgress = new WindowSyncProductsProgress();
				this.windowProgress.show();
				Thread<int> thread = new Thread<int>.try ("Woocommerce Sync Products thread", this.SyncProducts);
			}
			catch(GLib.Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			*/
		}
		protected void OnButtonRefreshClicked()
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1" )
			{
				var err = new InfoDialog()
				{
					Title = SBText.__("Products Synchronization error"),
					Message = SBText.__("You need to select a store")
				};
				err.run();
				err.destroy();
				return;
			}
			int store_id = int.parse(this.comboboxStore.active_id);
			this.Refresh(store_id);
		}
		protected void Refresh(int store_id)
		{
			(this.treeviewOrders.model as ListStore).clear();
			TreeIter iter;
			int i = 1;
			var orders = WCHelper.GetOrders(store_id);
			foreach(var order in orders)
			{
				(this.treeviewOrders.model as ListStore).append(out iter);
				(this.treeviewOrders.model as ListStore).set(iter,
					Columns.SELECT, false,
					Columns.COUNT, i,
					Columns.ID, order.Id,
					Columns.WOO_ID, (order.Meta["wc_order_id"] != null) ? int.parse((string)order.Meta["wc_order_id"]) : 0,
					Columns.CUSTOMER, "%s %s\n<span fgcolor=\"#0074A2\">%s</span>".printf((string)order.Customer["first_name"], 
														(string)order.Customer["last_name"],
														(order.Customer["email"] != null) ? (string)order.Customer["email"] : ""),
					Columns.LOCAL_STATUS, order.Status,
					Columns.WOO_STATUS, (order.Meta["wc_status"] != null) ? (string)order.Meta["wc_status"] : "---",
					Columns.TOTAL, "%.2f".printf(order.Total),
					Columns.ORDER_DATE, "%s".printf(order.CreationDate)
				);
				i++;
			}
		}
	}
}
