using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetAdjustments : Box
	{
		protected	Builder			ui;
		protected	Box				box1;
		protected	Image			image1;
		protected	Button			buttonNew;
		protected	Button			buttonCancel;
		protected	ComboBox		comboboxStore;
		protected	TreeView		treeviewItems;
		protected	enum			Columns
		{
			COUNT,
			SELECT,
			CODE,
			STATUS,
			STORE,
			NOTE,
			PRODUCT,
			OLD_QTY,
			NEW_QTY,
			ID,
			N_COLS
		}
		public class WidgetAdjustments()
		{
			this.expand = true;
			this.ui			= (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("widget.adjustments.glade");
			this.box1		= (Box)this.ui.get_object("box1");
			this.image1		= (Image)this.ui.get_object("image1");
			this.buttonNew	= (Button)this.ui.get_object("buttonNew");
			this.buttonCancel	= (Button)this.ui.get_object("buttonCancel");
			this.comboboxStore	= (ComboBox)this.ui.get_object("comboboxStore");
			this.treeviewItems	= (TreeView)this.ui.get_object("treeviewItems");
			this.box1.expand = true;
			this.box1.reparent(this);
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			this.image1.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("adjustment-icon-64x55.png");
			this.comboboxStore.model = new ListStore(2, typeof(string), typeof(string));
			var cell = new CellRendererText();
			this.comboboxStore.pack_start(cell, true);
			this.comboboxStore.set_attributes(cell, "text", 0);
			this.comboboxStore.id_column = 1;
			TreeIter iter;
			(this.comboboxStore.model as ListStore).append(out iter);
			(this.comboboxStore.model as ListStore).set(iter, 0, SBText.__("-- store --"), 1, "-1");
			foreach(var store in InventoryHelper.GetStores())
			{
				(this.comboboxStore.model as ListStore).append(out iter);
				(this.comboboxStore.model as ListStore).set(iter, 
					0, store.Name, 
					1, store.Id.to_string()
				);
			}
			this.comboboxStore.active_id = "-1";
			this.treeviewItems.model = new ListStore(Columns.N_COLS,
				typeof(int), //count
				typeof(bool), //select
				typeof(string),//code
				typeof(string), //status
				typeof(string), //store
				typeof(string), //note
				typeof(string), //product
				typeof(int), //old qty
				typeof(int), //new qty
				typeof(int) //id
			);
			string[,] cols = 
			{
				{"#", "text", "40", "center", "", ""},
				{SBText.__(""), "toggle", "40", "center", "", ""},
				{SBText.__("Code"), "text", "90", "left", "", ""},
				{SBText.__("Status"), "markup", "70", "center", "", ""},
				{SBText.__("Store"), "text", "140", "left", "", ""},
				{SBText.__("Note"), "text", "240", "left", "", ""},
				{SBText.__("Product"), "text", "150", "left", "", ""},
				{SBText.__("Old Qty"), "text", "40", "center", "", ""},
				{SBText.__("New Qty"), "text", "40", "center", "", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewItems);
			this.treeviewItems.rules_hint = true;
			
 		}
		protected void SetEvents()
		{
			this.comboboxStore.changed.connect(this.OnComboBoxStoreChanged);
			this.buttonNew.clicked.connect(this.OnButtonNewClicked);
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
		}
		protected void OnComboBoxStoreChanged()
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1" )
			{
				return;
			}
			int store_id = int.parse(this.comboboxStore.active_id);
			this.Refresh(store_id);
		}
		protected void OnButtonNewClicked()
		{
			var w = new DialogNewAdjustment();
			w.modal = true;
			w.show();
			w.destroy.connect( () => 
			{
				int store_id = int.parse(this.comboboxStore.active_id);
				this.Refresh(store_id);
			});
		}
		protected void OnButtonCancelClicked()
		{
			
		}
		protected void Refresh(int store_id)
		{
			(this.treeviewItems.model as ListStore).clear();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("product_adjustments").Where("store_id = %d".printf(store_id)).
				OrderBy("creation_date", "DESC");
			TreeIter iter;
			int i = 1;
			foreach(var row in dbh.GetResults(null))
			{
				var store = new SBStore.from_id(row.GetInt("store_id"));
				var prod = new SBProduct.from_id(row.GetInt("product_id"));
				(this.treeviewItems.model as ListStore).append(out iter);
				(this.treeviewItems.model as ListStore).set(iter,
					Columns.COUNT, i,
					Columns.SELECT, false,
					Columns.CODE, row.Get("code"),
					Columns.STATUS, row.Get("status"),
					Columns.STORE, store.Name,
					Columns.NOTE, row.Get("note"),
					Columns.PRODUCT, prod.Name,
					Columns.OLD_QTY, row.GetInt("old_qty"),
					Columns.NEW_QTY, row.GetInt("new_qty"),
					Columns.ID, row.GetInt("adjustment_id")					
				);
				i++;
			}
		}
	}
}
