using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetPromotionalPrices : Box
	{
		protected	Builder			ui;
		protected	Box				box1;
		protected	Image			image1;
		protected	Button			buttonNew;
		protected	Button			buttonEdit;
		protected	Button			buttonDelete;
		protected	ComboBox		comboboxStore;
		protected	TreeView		treeviewItems;
		protected	enum			Columns
		{
			COUNT,
			ID,
			DESCRIPTION,
			DATE_FROM,
			DATE_TO,
			STATUS,
			N_COLS
		}
		public WidgetPromotionalPrices()
		{
			this.expand = true;
			this.ui				= (SBModules.GetModule("Pos") as SBGtkModule).GetGladeUi("promotional-prices.glade");
			this.box1			= (Box)this.ui.get_object("boxPromotionalPrices");
			this.image1			= (Image)this.ui.get_object("image1");
			this.buttonNew		= (Button)this.ui.get_object("buttonNew");
			this.buttonEdit		= (Button)this.ui.get_object("buttonEdit");
			this.buttonDelete	= (Button)this.ui.get_object("buttonDelete");
			this.comboboxStore	= (ComboBox)this.ui.get_object("comboboxStore");
			this.treeviewItems	= (TreeView)this.ui.get_object("treeviewItems");
			this.box1.reparent(this);
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			this.box1.expand = true;
			this.image1.pixbuf = (SBModules.GetModule("Pos") as SBGtkModule).GetPixbuf("tickets-icon01-48x48.png");
			this.comboboxStore.model = new ListStore(2, typeof(string), typeof(string));
			var cell = new CellRendererText();
			this.comboboxStore.pack_start(cell, true);
			this.comboboxStore.set_attributes(cell, "text", 0);
			this.comboboxStore.id_column = 1;
			TreeIter iter;
			(this.comboboxStore.model as ListStore).append(out iter);
			(this.comboboxStore.model as ListStore).set(iter,
				0, SBText.__("-- store --"),
				1, "-1"
			);
			foreach(var store in EPosHelper.GetStores())
			{
				(this.comboboxStore.model as ListStore).append(out iter);
				(this.comboboxStore.model as ListStore).set(iter,
					0, store.Name,
					1, store.Id.to_string()
				);
			}
			this.comboboxStore.active_id = "-1";
			
			this.treeviewItems.model = new ListStore(Columns.N_COLS,
				typeof(int),
				typeof(int),
				typeof(string),
				typeof(string),
				typeof(string),
				typeof(string)
			);
			string[,] cols = 
			{
				{"#", "text", "50", "center", "", ""},
				{SBText.__("ID"), "text", "50", "center", "", ""},
				{SBText.__("Description"), "text", "250", "left", "", ""},
				{SBText.__("Start Date"), "text", "90", "left", "", ""},
				{SBText.__("End Date"), "text", "90", "left", "", ""},
				{SBText.__("Status"), "markup", "80", "center", "", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewItems);
			this.treeviewItems.rules_hint = true;
			this.treeviewItems.search_column = Columns.ID;
		}
		protected void SetEvents()
		{
			this.comboboxStore.changed.connect(this.OnComboBoxStoreChanged);
			this.buttonNew.clicked.connect(this.OnButtonNewClicked);
			this.buttonEdit.clicked.connect(this.OnButtonEditClicked);
			this.buttonDelete.clicked.connect(this.OnButtonDeleteClicked);
		}
		protected void OnComboBoxStoreChanged()
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1" )
			{
				(this.treeviewItems.model as ListStore).clear();
				return;
			}
			int store_id = int.parse(this.comboboxStore.active_id);
			this.Refresh(store_id);
		}
		protected void OnButtonNewClicked()
		{
			var nb = (SBNotebook)SBGlobals.GetVar("notebook");
			if( nb.GetPage("new-promo-price") == null )
			{
				var widget = new WidgetNewPromotionalPrice();
				widget.show();
				widget.destroy.connect( () => 
				{
					int store_id = int.parse(this.comboboxStore.active_id);
					this.Refresh(store_id);
				});
				nb.AddPage("new-promo-price", SBText.__("New Promotional Price"), widget);
			}
			nb.SetCurrentPageById("new-promo-price");
		}
		protected void OnButtonEditClicked()
		{
		}
		protected void OnButtonDeleteClicked()
		{
		}
		protected void Refresh(int store_id)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("promotional_prices").Where("store_id = %d".printf(store_id));
			(this.treeviewItems.model as ListStore).clear();
			TreeIter iter;
			int i = 1;
			foreach(var row in dbh.GetResults(null))
			{
				(this.treeviewItems.model as ListStore).append(out iter);
				(this.treeviewItems.model as ListStore).set(iter,
					Columns.COUNT, i,
					Columns.ID, row.GetInt("promo_id"),
					Columns.DESCRIPTION, row.Get("description"),
					Columns.DATE_FROM, row.Get("start_date"),
					Columns.DATE_TO, row.Get("end_date"),
					Columns.STATUS, row.Get("status")
				);
				i++;
			}
		}
	}
}
