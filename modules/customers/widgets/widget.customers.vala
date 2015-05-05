using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetCustomers : Box
	{
		protected	Builder ui;
		protected	Box		boxCustomers;
		protected	Image	image1;
		protected	Label	labelTitle;
		protected	TreeView	treeviewCustomers;
		protected	Button		buttonNew;
		protected	Button		buttonEdit;
		protected	Button		buttonDelete;
		protected	enum 		Columns
		{
			COUNT,
			IMAGE,
			CODE,
			NAME,
			COMPANY,
			TELEPHONE,
			CITY,
			EMAIL,
			CUSTOMER_ID,
			N_COLS
		}
		public WidgetCustomers()
		{
			this.ui = (Builder)(SBModules.GetModule("Customers") as SBGtkModule).GetGladeUi("customers.glade");
			this.boxCustomers		= (Box)this.ui.get_object("boxCustomers");
			this.image1				= (Image)this.ui.get_object("image1");
			this.buttonNew			= (Button)this.ui.get_object("buttonNew");
			this.buttonEdit			= (Button)this.ui.get_object("buttonEdit");
			this.buttonDelete		= (Button)this.ui.get_object("buttonDelete");
			this.treeviewCustomers	= (TreeView)this.ui.get_object("treeviewCustomers");
			
			this.boxCustomers.reparent(this);
			this.Build();
			this.RefreshCustomers();
			this.SetEvents();
		}
		protected void Build()
		{
			this.image1.pixbuf = (SBModules.GetModule("Customers") as SBGtkModule).GetPixbuf("customer-icon-64x64.png");
			this.treeviewCustomers.model = new ListStore(Columns.N_COLS,
				typeof(int), //count
				typeof(Gdk.Pixbuf),
				typeof(string), //code
				typeof(string), //name
				typeof(string), //company,
				typeof(string), //telephone
				typeof(string), //city
				typeof(string), //email
				typeof(int) //customer_id
			);
			string[,] cols = 
			{
				{SBText.__("#"), "text", "70", "center", ""},
				{SBText.__("Image"), "pixbuf", "80", "center", ""},
				{SBText.__("Code"), "text", "150", "left", ""},
				{SBText.__("Contact Name"), "text", "250", "left", ""},
				{SBText.__("Company"), "text", "150", "left", ""},
				{SBText.__("Telephone"), "text", "100", "right", ""},
				{SBText.__("City"), "text", "70", "center", ""},
				{SBText.__("Email"), "text", "90", "left", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewCustomers);
			this.treeviewCustomers.rules_hint = true;
			
		}
		protected void SetEvents()
		{	
			this.buttonNew.clicked.connect(this.OnButtonNewClicked);
			this.buttonEdit.clicked.connect(this.OnButtonEditClicked);
			this.buttonDelete.clicked.connect(this.OnButtonDeleteClicked);
		}
		protected void RefreshCustomers()
		{
			(this.treeviewCustomers.model as ListStore).clear();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM customers ORDER BY first_name ASC";
			var rows = dbh.GetResults(query);
			TreeIter iter;
			var img_nobody = (SBModules.GetModule("Customers") as SBGtkModule).GetPixbuf("nobody-80x80.png");
			int i = 1;
			foreach(SBDBRow row in rows)
			{
				(this.treeviewCustomers.model as ListStore).append(out iter);
				(this.treeviewCustomers.model as ListStore).set(iter,
					Columns.COUNT, i,
					Columns.IMAGE, img_nobody,
					Columns.CODE, row.Get("code"),
					Columns.NAME, row.Get("first_name") + " " + row.Get("last_name"),
					Columns.COMPANY, row.Get("company"),
					Columns.TELEPHONE, row.Get("phone"),
					Columns.CITY, row.Get("city"),
					Columns.EMAIL, row.Get("email"),
					Columns.CUSTOMER_ID, row.GetInt("customer_id")
				);
				i++;
			}
		}
		protected void OnButtonNewClicked()
		{
			var nb = (SBNotebook)SBGlobals.GetVar("notebook");
			if( nb.GetPage("new-customer") == null )
			{
				var w = new WidgetNewCustomer();
				w.show();
				w.destroy.connect( () => {this.RefreshCustomers();});
				nb.AddPage("new-customer", SBText.__("New Customer"), w);
			}
			nb.SetCurrentPageById("new-customer");
		}
		protected void OnButtonEditClicked()
		{
			TreeModel model;
			TreeIter iter;
			if( !this.treeviewCustomers.get_selection().get_selected(out model, out iter) )
				return;
			Value v_cid;
			model.get_value(iter, Columns.CUSTOMER_ID, out v_cid);
			var nb = (SBNotebook)SBGlobals.GetVar("notebook");
			if( nb.GetPage("edit-customer") == null )
			{
				var w = new WidgetNewCustomer();
				w.SetCustomer(new Customer.from_id((int)v_cid));
				w.show();
				w.destroy.connect( () => {this.RefreshCustomers();});
				nb.AddPage("edit-customer", SBText.__("Edit Customer"), w);
			}
			nb.SetCurrentPageById("edit-customer");
		}
		protected void OnButtonDeleteClicked()
		{
			TreeModel model;
			TreeIter iter;
			if( !this.treeviewCustomers.get_selection().get_selected(out model, out iter) )
				return;
			Value v_cid;
			model.get_value(iter, Columns.CUSTOMER_ID, out v_cid);
			var dlg = new MessageDialog(null, DialogFlags.MODAL, MessageType.QUESTION,
				ButtonsType.YES_NO, SBText.__("Are you sure to delete the customer?") 
			);
			if( dlg.run() == ResponseType.YES )
			{
				var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
				string query = "DELETE FROM customers WHERE customer_id = %d".printf((int)v_cid);
				dbh.Execute(query);
				this.RefreshCustomers();
			}
			dlg.destroy();
		}
	}
}
