using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;

namespace EPos.Woocommerce
{
	public class WidgetWoocommerceCategories : Box
	{
		protected	Builder			ui;
		protected	Box				box1;
		protected	Image			image1;
		protected	ComboBox		comboboxStore;
		protected	Button			buttonSync;
		protected	Entry			entryName;
		protected	Entry			entrySlug;
		protected	TextView		textviewDescription;
		protected	ComboBox		comboboxParent;
		protected	TreeView		treeviewCategories;
		protected	enum			Columns
		{
			COUNT,
			ID,
			WOO_ID,
			NAME,
			DESCRIPTION,
			SLUG,
			PRODUCTS_COUNT,
			N_COLS
		}
		protected	int				storeId = 0;
		
		public WidgetWoocommerceCategories()
		{
			this.ui = (SBModules.GetModule("Woocommerce") as SBGtkModule).GetGladeUi("categories.glade");
			this.box1 = (Box)this.ui.get_object("box1");
			this.image1		= (Image)this.ui.get_object("image1");
			this.comboboxStore	= (ComboBox)this.ui.get_object("comboboxStore");
			this.buttonSync		= (Button)this.ui.get_object("buttonSync");
			this.entryName		= (Entry)this.ui.get_object("entryName");
			this.entrySlug		= (Entry)this.ui.get_object("entrySlug");
			this.textviewDescription	= (TextView)this.ui.get_object("textviewDescription");
			this.comboboxParent			= (ComboBox)this.ui.get_object("comboboxParent");
			this.treeviewCategories		= (TreeView)this.ui.get_object("treeviewCategories");
			
			this.box1.reparent(this);
			this.Build();
			//this.RefreshCategories();
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
			
			this.treeviewCategories.model = new TreeStore(Columns.N_COLS,
				typeof(int), //count
				typeof(int), //ID
				typeof(int), //Woo id
				typeof(string), //name
				typeof(string), //description
				typeof(string), //slug
				typeof(int) //product count
			);
			string[,] cols = 
			{
				{"#", "text", "40", "center", "", ""},
				{SBText.__("ID"), "text", "40", "center", "", ""},
				{SBText.__("Woo ID"), "text", "40", "center", "", ""},
				{SBText.__("Name"), "text", "180", "left", "", ""},
				{SBText.__("Description"), "text", "280", "left", "", ""},
				{SBText.__("Slug"), "text", "120", "left", "", ""},
				{SBText.__("Products"), "text", "40", "center", "", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewCategories);
			this.treeviewCategories.rules_hint = true;
			
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
		}
		protected void OnComboBoxStoreChanged()
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1" )
			{
				(this.treeviewCategories.model as ListStore).clear();
				return;
			}
			this.RefreshCategories(int.parse(this.comboboxStore.active_id));
		}
		protected void OnButtonSyncClicked()
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1" )
			{
				return;
			}
			this.storeId = int.parse(this.comboboxStore.active_id);
			try
			{
				Thread<int> thread = new Thread<int>.try ("Woocommerce Sync Categories thread", this.SyncCategories);
			}
			catch(GLib.Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
		}
		protected void RefreshCategories(int store_id)
		{
			(this.treeviewCategories.model as TreeStore).clear();
			TreeIter iter;
			int i  = 1;
			foreach(var cat in EPosHelper.GetCategories(store_id))
			{
				(this.treeviewCategories.model as TreeStore).append(out iter, null);
				(this.treeviewCategories.model as TreeStore).set(iter,
					Columns.COUNT, i,
					Columns.ID, cat.Id,
					Columns.WOO_ID, cat.GetInt("extern_id"),
					Columns.NAME, cat.Name,
					Columns.DESCRIPTION, cat.Description,
					Columns.SLUG, "",
					Columns.PRODUCTS_COUNT, 0
				);
				i++;
				TreeIter child_iter;
				foreach(var child in cat.Childs)
				{
					(this.treeviewCategories.model as TreeStore).append(out child_iter, iter);
					(this.treeviewCategories.model as TreeStore).set(child_iter,
						Columns.COUNT, i,
						Columns.ID, child.Id,
						Columns.WOO_ID, child.GetInt("extern_id"),
						Columns.NAME, child.Name,
						Columns.DESCRIPTION, child.Description,
						Columns.SLUG, "",
						Columns.PRODUCTS_COUNT, 0
					);
					i++;
				}
				
			}
		}
		protected int SyncCategories()
		{
			string url = SBStore.SGetMeta(this.storeId, "woocommerce_url");
			string key = SBStore.SGetMeta(this.storeId, "woocommerce_key");
			string secret = SBStore.SGetMeta(this.storeId, "woocommerce_secret");
			var sync = new SBWCSync(url, key, secret);
			sync.SyncCategories(this.storeId);
			GLib.Idle.add( () => 
			{
				this.RefreshCategories(this.storeId);
				return false; //return false, to remove from the list of events
			});
			return 0;
		}
	}
}
