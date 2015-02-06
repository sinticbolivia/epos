using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace Woocommerce
{
	public class WidgetSuppliers : Gtk.Box
	{
		protected	Builder		ui;
		protected	Box			boxSuppliers;
		protected	Image		image1;
		protected	Label		labelTitle;
		protected	Button		buttonNew;
		protected 	Button		buttonEdit;
		protected	Button		buttonDelete;
		protected	ComboBox	comboboxStore;
		protected	TreeView	treeviewSuppliers;
		
		protected enum Columns
		{
			COUNT,
			SUPPLIER_NAME,
			COMPANY,
			CITY,
			MARKUP,
			SUPPLIER_ID,
			N_COLS
		}
		public WidgetSuppliers()
		{
			//this.ui = SB_ModuleInventory.GetGladeUi("suppliers.glade");
			this.ui = (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("suppliers.glade");
			this.boxSuppliers		= (Box)this.ui.get_object("boxSuppliers");
			this.image1				= (Image)this.ui.get_object("image1");
			this.labelTitle			= (Label)this.ui.get_object("labelTitle");
			this.buttonNew			= (Button)this.ui.get_object("buttonNew");
			this.buttonEdit			= (Button)this.ui.get_object("buttonEdit");
			this.buttonDelete		= (Button)this.ui.get_object("buttonDelete");
			//this.comboboxCountry	= (ComboBox)this.ui.get_object("comboboxCountry");
			this.treeviewSuppliers	= (TreeView)this.ui.get_object("treeviewSuppliers");
			
			this.Build();
			this.FillForm();
			this.SetEvents();
			this.boxSuppliers.reparent(this);
		}
		protected void Build()
		{
			this.image1.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("supplier-icon-48x48.png");//SB_ModuleInventory.GetPixbuf("supplier-icon-48x48.png");
			this.treeviewSuppliers.model = new ListStore(Columns.N_COLS,
				typeof(int),
				typeof(string),
				typeof(string),
				typeof(string),
				typeof(string),
				typeof(int) //supplier id
			);
			string[,] cols = 
			{
				{"#", "text", "70", "center", ""},
				{SBText.__("Name"), "text", "220", "left", ""},
				{SBText.__("Company"), "text", "150", "left", ""},
				{SBText.__("City"), "text", "100", "left", ""},
				{SBText.__("Markup"), "text", "60", "right", ""},
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewSuppliers);
			this.treeviewSuppliers.rules_hint = true;
			
			/*
			var cell0 = new CellRendererText();
			this.comboboxCountry.pack_start(cell0, true);
			TreeIter iter;
			this.comboboxCountry.model = new ListStore(2, typeof(string), typeof(string));
			(this.comboboxCountry.model as ListStore).append(out iter);
			(this.comboboxCountry.model as ListStore).set(iter, 0, SBText.__("-- country --"), 1, "-1");
			this.comboboxCountry.id_column = 1;
			*/
		}
		protected void FillForm()
		{
			//this.comboboxCountry.active_id = "-1";
			this.FillSuppliers();
		}
		protected void SetEvents()
		{
			this.buttonNew.clicked.connect(this.OnButtonNewClicked);
			this.buttonEdit.clicked.connect(this.OnButtonEditClicked);
		}
		protected void OnButtonNewClicked()
		{	
			var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
			if( notebook.GetPage("new-supplier") == null )
			{
				var w = new WidgetNewSupplier();
				w.show();
				notebook.AddPage("new-supplier", "Add Supplier", w);
			}
			notebook.SetCurrentPageById("new-supplier");
		}
		protected void OnButtonEditClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewSuppliers.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			Value v_sid;
			model.get_value(iter, Columns.SUPPLIER_ID, out v_sid);
			
			var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
			if( notebook.GetPage("edit-supplier") == null )
			{
				var w = new WidgetNewSupplier();
				w.SetSupplier((int)v_sid);
				w.show();
				
				notebook.AddPage("edit-supplier", "Edit Supplier", w);
			}
			notebook.SetCurrentPageById("edit-supplier");
		}
		protected void FillSuppliers()
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "select * FROM suppliers ORDER BY supplier_name ASC";
			var rows = (ArrayList<SBDBRow>)dbh.GetResults(query);
			(this.treeviewSuppliers.model as ListStore).clear();
			TreeIter iter;
			int i = 1;
			foreach(var row in rows)
			{
				(this.treeviewSuppliers.model as ListStore).append(out iter);
				(this.treeviewSuppliers.model as ListStore).set(iter,
					Columns.COUNT, i,
					Columns.SUPPLIER_NAME, row.Get("supplier_name"),
					Columns.COMPANY, "",
					Columns.CITY, row.Get("supplier_city"),
					Columns.MARKUP, "0%",
					Columns.SUPPLIER_ID, row.GetInt("supplier_id")
				);
				i++;
			}
		}
	}
}
