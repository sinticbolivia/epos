using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WindowSearchOrders : Window
	{
		protected	Builder				ui;
		protected	Box					box1;
		protected	Image				image1;
		protected	Label				labelTitle;
		protected	Entry				entryKeyword;
		protected	ComboBox			comboboxSearchBy;
		protected	ComboBox			comboboxStatus;
		protected	TreeView			treeviewOrders;
		protected	Button				buttonClose;
		protected	Button				buttonSelect;
		protected	enum				Columns
		{
			COUNT,
			ID,
			CODE,
			CUSTOMER,
			TOTAL,
			DATE,
			SALE_OBJ,
			N_COLS
		}
		public		string				Status
		{
			set{this.comboboxStatus.active_id = value;}
		}
		public		ComboBox			ComboboxStatus
		{
			get{return this.comboboxStatus;}
		}
		protected	ESale				sale;
		
		public WindowSearchOrders()
		{
			this.title			= SBText.__("Search Orders");
			this.window_position = WindowPosition.CENTER_ALWAYS;
			this.set_size_request(500, 350);
			
			this.ui				= (SBModules.GetModule("Pos") as SBGtkModule).GetGladeUi("window.search-orders.glade");
			this.box1			= (Box)this.ui.get_object("box1");
			this.image1			= (Image)this.ui.get_object("image1");
			this.labelTitle		= (Label)this.ui.get_object("labelTitle");
			this.entryKeyword	= (Entry)this.ui.get_object("entryKeyword");
			this.comboboxSearchBy	= (ComboBox)this.ui.get_object("comboboxSearchBy");
			this.comboboxStatus		= (ComboBox)this.ui.get_object("comboboxStatus");
			this.treeviewOrders		= (TreeView)this.ui.get_object("treeviewOrders");
			this.buttonClose		= (Button)this.ui.get_object("buttonClose");
			this.buttonSelect		= (Button)this.ui.get_object("buttonSelect");
			this.box1.reparent(this);
			
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			this.image1.pixbuf = (SBModules.GetModule("Pos") as SBGtkModule).GetPixbuf("product-lookup-48x48.png");
			this.comboboxSearchBy.model = new ListStore(2, typeof(string), typeof(string));
			var cell = new CellRendererText();
			this.comboboxSearchBy.pack_start(cell, true);
			this.comboboxSearchBy.set_attributes(cell, "text", 0);
			this.comboboxSearchBy.id_column = 1;
			TreeIter iter;
			string[,] search_types = 
			{
				{SBText.__("ID"), "id"},
				{SBText.__("Code"), "code"}
			};
			for(int i = 0; i < search_types.length[0]; i++)
			{
				(this.comboboxSearchBy.model as ListStore).append(out iter);
				(this.comboboxSearchBy.model as ListStore).set(iter, 
					0, search_types[i, 0],
					1, search_types[i, 1]
				);
			}
			this.comboboxStatus.model = new ListStore(2, typeof(string), typeof(string));
			cell = new CellRendererText();
			this.comboboxStatus.pack_start(cell, true);
			this.comboboxStatus.set_attributes(cell, "text", 0);
			this.comboboxStatus.id_column = 1;
			
			string[,] statuses = 
			{
				{SBText.__("-- order status --"), "-1"},
				{SBText.__("Completed"), "completed"},
				{SBText.__("Hold"), "hold"},
				{SBText.__("Void"), "void"},
				{SBText.__("Refunded"), "refunded"},
			};
			for(int i = 0; i < statuses.length[0]; i++)
			{
				(this.comboboxStatus.model as ListStore).append(out iter);
				(this.comboboxStatus.model as ListStore).set(iter, 
					0, statuses[i, 0],
					1, statuses[i, 1]
				);
			}
			this.comboboxStatus.active_id = "-1";
			this.treeviewOrders.model = new ListStore(Columns.N_COLS,
				typeof(int),//count
				typeof(int), //id
				typeof(string), //code
				typeof(string), //customer
				typeof(string), //total
				typeof(string), //date
				typeof(ESale)
			);
			string[,] cols = 
			{
				{"#", "text", "50", "center", "", ""},
				{SBText.__("ID"), "text", "50", "center", "", ""},
				{SBText.__("Code"), "text", "90", "left", "", ""},
				{SBText.__("Customer"), "text", "120", "left", "", ""},
				{SBText.__("Total"), "text", "90", "right", "", ""},
				{SBText.__("Date"), "text", "100", "left", "", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewOrders);
		}
		protected void SetEvents()
		{
			this.comboboxStatus.changed.connect(this.OnComboBoxStatusChanged);
			this.buttonClose.clicked.connect(this.OnButtonCloseClicked);
			this.buttonSelect.clicked.connect(this.OnButtonSelectClicked);
		}
		protected void OnComboBoxStatusChanged()
		{
			if(this.comboboxStatus.active_id == null)
				return;
			this.GetOrders(this.comboboxStatus.active_id);
		}
		protected void OnButtonCloseClicked()
		{
			this.destroy();
		}
		protected void OnButtonSelectClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewOrders.get_selection().get_selected(out model, out iter) )
			{
				var err = new InfoDialog("error")
				{
					Title = SBText.__("Order error"),
					Message = SBText.__("You need to select an order.")
				};
				err.run();
				err.destroy();
				return;
			}
			Value sale;
			model.get_value(iter, Columns.SALE_OBJ, out sale);
			this.sale = (ESale)sale;
			this.destroy();
		}
		protected void GetOrders(string status)
		{
			(this.treeviewOrders.model as ListStore).clear();
			var cfg = (SBConfig)SBGlobals.GetVar("config");
			string is_terminal = (string)cfg.GetValue("is_terminal", "");
			var orders = new ArrayList<ESale>();
			if( is_terminal == "yes" )
			{
				
			}
			else
			{
				var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
				dbh.Select("s.*, c.first_name, c.last_name").From("sales s").
					LeftJoin("customers c").On("s.customer_id = c.customer_id").
					Where("s.status = '%s'".printf(status));
				foreach(var o in dbh.GetResults(null))
				{
					var order = new ESale.with_db_data(o);
					order.GetDbItems();
					orders.add(order);
				}
			}
			TreeIter iter;
			int i = 1;
			foreach(var order in orders)
			{
				(this.treeviewOrders.model as ListStore).append(out iter);
				(this.treeviewOrders.model as ListStore).set(iter, 
					Columns.COUNT, i,
					Columns.ID, order.Id,
					Columns.CODE, order.Code,
					Columns.CUSTOMER, "%s %s".printf((string)order.Customer["first_name"], (string)order.Customer["last_name"]),
					Columns.TOTAL, "%.2f".printf(order.Total),
					Columns.DATE, order.CreationDate,
					Columns.SALE_OBJ, order
				);
				i++;
			}
		}
		public ESale GetOrder()
		{
			return this.sale;
		}
	}
}
