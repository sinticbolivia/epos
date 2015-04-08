using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos.Woocommerce
{
	public class WidgetWoocommerceStores : Box
	{
		protected	Builder			ui;
		protected	Box				box1;
		protected	Image			image1;
		protected	Button			buttonNew;
		protected	Button			buttonEdit;
		protected	Button			buttonDelete;
		protected	TreeView		treeviewStores;
		protected	Entry			entryName;
		protected	Entry			entryUrl;
		protected	Entry			entryKey;
		protected	Entry			entrySecret;
		protected	Button			buttonCancel;
		protected	Button			buttonSave;
		
		protected	int				storeId = 0;
		
		public WidgetWoocommerceStores()
		{
			this.ui			= (SBModules.GetModule("Woocommerce") as SBGtkModule).GetGladeUi("stores.glade");
			this.box1		= (Box)this.ui.get_object("box1");
			this.image1		= (Image)this.ui.get_object("image1");
			this.buttonNew		= (Button)this.ui.get_object("buttonNew");
			this.buttonEdit		= (Button)this.ui.get_object("buttonEdit");
			this.buttonDelete	= (Button)this.ui.get_object("buttonDelete");
			this.treeviewStores	= (TreeView)this.ui.get_object("treeviewStores");
			this.entryName		= (Entry)this.ui.get_object("entryName");
			this.entryUrl		= (Entry)this.ui.get_object("entryUrl");
			this.entryKey		= (Entry)this.ui.get_object("entryKey");
			this.entrySecret	= (Entry)this.ui.get_object("entrySecret");
			this.buttonCancel 	= (Button)this.ui.get_object("buttonCancel");
			this.buttonSave		= (Button)this.ui.get_object("buttonSave");
			
			this.box1.reparent(this);
			this.Build();
			this.RefreshStores();
			this.SetEvents();
		}
		protected void Build()
		{
			this.image1.pixbuf	= (SBModules.GetModule("Woocommerce") as SBGtkModule).GetPixbuf("woocommerce_logo-64x64.png");
			this.treeviewStores.model = new ListStore(4,
				typeof(int),
				typeof(int),
				typeof(string),
				typeof(string)
			);
			string[,] cols = 
			{
				{"#", "text", "40", "center", "", ""},
				{"ID", "text", "40", "center", "", ""},
				{SBText.__("Name"), "text", "240", "left", "", ""},
				{SBText.__("Url"), "text", "240", "left", "", ""},
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewStores);
			this.treeviewStores.rules_hint = true;
			
		}
		protected void SetEvents()
		{
			this.buttonNew.clicked.connect(this.OnButtonNewClicked);
			this.buttonEdit.clicked.connect(this.OnButtonEditClicked);
			this.buttonSave.clicked.connect(this.OnButtonSaveClicked);
		}
		protected void RefreshStores()
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			(this.treeviewStores.model as ListStore).clear();
			TreeIter iter;
			int i  = 1;
			foreach(var store in WCHelper.GetStores())
			{
				(this.treeviewStores.model as ListStore).append(out iter);
				(this.treeviewStores.model as ListStore).set(iter,
					0, i,
					1, store.Id,
					2, store.Name,
					3, ""
				);
			}
		}
		protected void OnButtonNewClicked()
		{
			this.Reset();
			this.entryName.grab_focus();
		}
		protected void OnButtonEditClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewStores.get_selection().get_selected(out model, out iter) )
			{
				var err = new InfoDialog()
				{
					Title = SBText.__("Edit store error"),
					Message = SBText.__("You need to select a store.")
				};
				err.run();
				err.destroy();
				return;
			}
			this.Reset();
			Value id;
			model.get_value(iter, 1, out id);
			var store = new SBStore.from_id((int)id);
			this.entryName.text = store.Name;
			this.entryUrl.text = store.GetMeta("woocommerce_url");
			this.entryKey.text = store.GetMeta("woocommerce_key");
			this.entrySecret.text = store.GetMeta("woocommerce_secret");
			this.storeId = store.Id;
			
		}
		protected void OnButtonSaveClicked()
		{
			string name 	= this.entryName.text.strip();
			string url 		= this.entryUrl.text.strip();
			string key		= this.entryKey.text.strip();
			string secret 	= this.entrySecret.text.strip();
			if( name.length <= 0 )
			{
				var err = new InfoDialog()
				{
					Title = SBText.__("Woocommerce store error"),
					Message = SBText.__("You need to enter a store name")
				};
				err.run();
				err.destroy();
				return;
			}
			if( url.length <= 0 )
			{
				var err = new InfoDialog()
				{
					Title = SBText.__("Woocommerce store error"),
					Message = SBText.__("You need to enter a store url")
				};
				err.run();
				err.destroy();
				return;
			}
			if( key.length <= 0 )
			{
				var err = new InfoDialog()
				{
					Title = SBText.__("Woocommerce store error"),
					Message = SBText.__("You need to enter your api consumer key")
				};
				err.run();
				err.destroy();
				return;
			}
			if( secret.length <= 0 )
			{
				var err = new InfoDialog()
				{
					Title = SBText.__("Woocommerce store error"),
					Message = SBText.__("You need to enter your api consumer secret")
				};
				err.run();
				err.destroy();
				return;
			}
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string cdate = new DateTime.now_local().format("%Y-%m-%d %H:%M:%S");
			var data 		= new HashMap<string, Value?>();
			data.set("store_name", name);
			data.set("store_type", "woocommerce");
			data.set("last_modification_date", cdate);
			if( this.storeId <= 0 )
			{
				data.set("creation_date", cdate);
				this.storeId = (int)dbh.Insert("stores", data);
			}
			else
			{
				var where = new HashMap<string, Value?>();
				where.set("store_id", this.storeId);
				dbh.Update("stores", data, where);
			}
			SBStore.SUpdateMeta(this.storeId, "woocommerce_url", url);
			SBStore.SUpdateMeta(this.storeId, "woocommerce_key", key);
			SBStore.SUpdateMeta(this.storeId, "woocommerce_secret", secret);
			var msg = new InfoDialog()
			{
				Title = SBText.__("Woocommerce store"),
				Message = SBText.__("The store has been saved")
			};
			msg.run();
			msg.destroy();
			this.RefreshStores();
			this.Reset();
		}
		protected void Reset()
		{
			this.storeId = 0;
			this.entryName.text = "";
			this.entryUrl.text = "";
			this.entryKey.text = "";
			this.entrySecret.text = "";
			
		}
	}
}
