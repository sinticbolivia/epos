using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Database;
using SinticBolivia.Gtk;

namespace EPos
{
	public class WindowCustomerLookup : Window
	{
		protected	Builder		ui;
		protected	Box			boxCustomerLookup;
		protected	Image		image1;
		protected	Entry		entryKeyword;
		protected	ComboBox	comboboxSearchBy;
		protected	TreeView	treeviewCustomers;
		protected	Button		buttonCreateCustomer;
		protected	Button		buttonClose;
		protected	Button		buttonSelect;
		
		public		int			CustomerId = 0;
		
		public WindowCustomerLookup()
		{
			this.window_position = WindowPosition.CENTER_ALWAYS;
			this.title			= SBText.__("Customer Lookup");
			this.set_size_request(500, 350);
			this.ui				= (SBModules.GetModule("Pos") as SBGtkModule).GetGladeUi("window.customer-lookup.glade");
			this.boxCustomerLookup = (Box)this.ui.get_object("boxCustomerLookup");
			this.image1					= (Image)this.ui.get_object("image1");
			this.entryKeyword			= (Entry)this.ui.get_object("entryKeyword");
			this.comboboxSearchBy		= (ComboBox)this.ui.get_object("comboboxSearchBy");
			this.treeviewCustomers		= (TreeView)this.ui.get_object("treeviewCustomers");
			this.buttonCreateCustomer	= (Button)this.ui.get_object("buttonCreateCustomer");
			this.buttonClose			= (Button)this.ui.get_object("buttonClose");
			this.buttonSelect			= (Button)this.ui.get_object("buttonSelect");
			
			this.Build();
			this.boxCustomerLookup.reparent(this);
			this.FillCustomers();
			this.SetEvents();
		}
		protected void Build()
		{
			this.image1.pixbuf		= (SBModules.GetModule("Pos") as SBGtkModule).GetPixbuf("product-lookup-48x48.png");
			this.comboboxSearchBy.model = new ListStore(2, typeof(string), typeof(string));
			var cell = new CellRendererText();
			this.comboboxSearchBy.pack_start(cell, true);
			this.comboboxSearchBy.set_attributes(cell, "text", 0);
			this.comboboxSearchBy.id_column = 1;
			string[,] searchs = 
			{
				{SBText.__("ID"), "id"}, 
				{SBText.__("Code"), "code"}, 
				{SBText.__("Name"), "name"}
			};
			TreeIter iter;
			for(int i = 0; i < searchs.length[0]; i++)
			{
				(this.comboboxSearchBy.model as ListStore).append(out iter);
				(this.comboboxSearchBy.model as ListStore).set(iter,
					0, searchs[i, 0],
					1, searchs[i, 1]
				);
			}
			this.comboboxSearchBy.active_id = "name";
			//##build treeview
			this.treeviewCustomers.model = new ListStore(4,
				typeof(int),//count
				typeof(int), //id
				typeof(string), //code
				typeof(string) //name
			);
			string[,] cols = 
			{
				{"#", "text", "60", "center", "", ""},
				{SBText.__("ID"), "text", "60", "center", "", ""},
				{SBText.__("Code"), "text", "100", "left", "", ""},
				{SBText.__("Name"), "text", "220", "left", "", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewCustomers);
			this.treeviewCustomers.rules_hint = true;
		}
		protected void SetEvents()
		{
			this.entryKeyword.key_release_event.connect(this.OnEntryKeywordKeyReleaseEvent);
			this.treeviewCustomers.row_activated.connect(this.OnTreeViewCustomersRowActivated);
			this.buttonClose.clicked.connect(this.OnButtonCloseClicked);
			this.buttonSelect.clicked.connect(this.OnButtonSelectClicked);
		}
		protected void FillCustomers()
		{
			(this.treeviewCustomers.model as ListStore).clear();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("customers");
			TreeIter iter;
			int i = 1;
			foreach(var row in dbh.GetResults(null))
			{
				(this.treeviewCustomers.model as ListStore).append(out iter);
				(this.treeviewCustomers.model as ListStore).set(iter,
					0, i,
					1, row.GetInt("customer_id"),
					2, row.Get("code"),
					3, "%s %s".printf(row.Get("first_name"), row.Get("last_name"))
				);
				i++;
			}
		}
		protected bool OnEntryKeywordKeyReleaseEvent(Gdk.EventKey event)
		{
			if( event.keyval == 65364 || event.keyval == 65362)
			{
				return true;
			}
			string keyword = this.entryKeyword.text.strip();
			if( keyword.length <= 0 )
			{
				this.FillCustomers();
				return true;
			}
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string search_by = this.comboboxSearchBy.active_id;
			string query = "SELECT customer_id, code, first_name, last_name "+
							"FROM customers ";
			if( search_by == "id" )
			{
				query += "customer_id = %d".printf(int.parse(keyword));
			}
			else if( search_by == "code" )
			{
				query += "WHERE code LIKE '%s'";
			}
			else if( search_by == "name" )
			{
				query += "WHERE CONCAT(first_name, last_name) LIKE '%s'";
			}
									
			var rows = dbh.GetResults(query.printf("%"+keyword+"%"));
			TreeIter iter;
			int i = 1;
			(this.treeviewCustomers.model as ListStore).clear();
			foreach(var row in rows)
			{
				(this.treeviewCustomers.model as ListStore).append(out iter);
				(this.treeviewCustomers.model as ListStore).set(iter,
					0, i,
					1, row.GetInt("customer_id"),
					2, row.Get("code"),
					3, "%s %s".printf(row.Get("first_name"), row.Get("last_name"))
				);
				i++;
			}
			return true;
		}
		protected void OnTreeViewCustomersRowActivated(TreePath path, TreeViewColumn column)
		{
			GLib.Signal.emit_by_name(this.buttonSelect, "clicked");
		}
		protected void OnButtonCloseClicked()
		{
			this.destroy();
		}
		protected void OnButtonSelectClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewCustomers.get_selection().get_selected(out model, out iter) )
			{
				var err = new InfoDialog("error")
				{
					Title = SBText.__("Customer error"),
					Message = SBText.__("You need to select a customer")
				};
				err.run();
				err.destroy();
				return;
			}
			Value v_id;
			model.get_value(iter, 1, out v_id);
			this.CustomerId = (int)v_id;
			this.destroy();
		}
	}
}
