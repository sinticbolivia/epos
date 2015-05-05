using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Database;
using SinticBolivia.Gtk;
using Woocommerce.Invoice;

namespace EPos
{
	public class WidgetTransactions : Box
	{
		protected	enum		Columns
		{
			CHECKBOX,
			ID,
			STORE,
			TYPE,
			TOTAL,
			NUM_ITEMS,
			STATUS,
			USER_ID,
			DATETIME,
			G_TYPE,
			N_COLS
		}
		protected	Builder 	ui;
		protected	Window		windowTransactions;
		protected	Box			boxTransactions;
		protected	Image		image1;
		protected	Box			boxButtons;
		protected 	Button		buttonView;
		protected	Button		buttonEdit;
		protected	Button		buttonRevert;
		protected	Button		buttonDelete;
		protected	Box			boxFilters;
		protected	ComboBox	comboboxStore;
		protected	ComboBox	comboboxTransactionType;
		protected	TreeView	treeviewTransactions;
		protected	SBStore		store;
		
		public WidgetTransactions()
		{
			//this.ui = SB_ModuleInventory.GetGladeUi("transactions.glade");
			this.ui	= (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("transactions.glade");
			
			//##get widgets
			this.windowTransactions		= (Window)this.ui.get_object("windowTransactions");
			this.boxTransactions		= (Box)this.ui.get_object("boxTransactions");
			this.image1					= (Image)this.ui.get_object("image1");
			this.boxButtons				= (Box)this.ui.get_object("boxButtons");
			this.buttonView				= (Button)this.ui.get_object("buttonView");
			this.buttonEdit				= (Button)this.ui.get_object("buttonEdit");
			this.buttonRevert			= (Button)this.ui.get_object("buttonRevert");
			this.buttonDelete			= (Button)this.ui.get_object("buttonDelete");
			this.boxFilters				= (Box)this.ui.get_object("boxFilters");
			this.comboboxStore			= (ComboBox)this.ui.get_object("comboboxStore");
			this.comboboxTransactionType= (ComboBox)this.ui.get_object("comboboxTransactionType");
			this.treeviewTransactions	= (TreeView)this.ui.get_object("treeviewTransactions");
			
			this.Build();
			this.SetEvents();
			this.boxTransactions.reparent(this);
		}
		protected void Build()
		{
			Gdk.Pixbuf pixbuf0 = null, pixbuf1 = null;
			try
			{
				this.image1.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("transaction-icon-64x64.png");
				
				pixbuf0 = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("blue_led-icon-10x10.png");//new Gdk.Pixbuf.from_stream(istream);
				pixbuf1 = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("green_led-icon-10x10.png");//new Gdk.Pixbuf.from_stream(istream);
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			TreeIter iter;
			
			this.comboboxStore.model = new ListStore(2, typeof(string), typeof(string));
			this.comboboxStore.id_column = 1;
			var cell = new CellRendererText();
			this.comboboxStore.pack_start(cell, false);
			this.comboboxStore.set_attributes(cell, "text", 0);
			(this.comboboxStore.model as ListStore).append(out iter);
			(this.comboboxStore.model as ListStore).set(iter, 0, SBText.__("-- store --"), 1, "-1");
			this.comboboxStore.active_id = "-1";
			//##fill stores
			foreach(var store in InventoryHelper.GetStores())
			{
				(this.comboboxStore.model as ListStore).append(out iter);
				(this.comboboxStore.model as ListStore).set(iter, 0, store.Name, 1, store.Id.to_string());
			}
			//##build transactions types
			this.comboboxTransactionType.model = new ListStore(3, typeof(Gdk.Pixbuf), typeof(string), typeof(string));
			this.comboboxTransactionType.id_column = 2;
			var cell_pix = new CellRendererPixbuf();
			cell = new CellRendererText();
			this.comboboxTransactionType.pack_start(cell_pix, false);
			this.comboboxTransactionType.set_attributes(cell_pix, "pixbuf", 0);
			this.comboboxTransactionType.pack_start(cell, false);
			this.comboboxTransactionType.set_attributes(cell, "text", 1);
			(this.comboboxTransactionType.model as ListStore).append(out iter);
			(this.comboboxTransactionType.model as ListStore).set(iter, 0, null, 1, SBText.__("-- type --"), 2, "-1");
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM transaction_types ORDER BY transaction_name ASC";
			foreach(var row in dbh.GetResults(query))
			{
				(this.comboboxTransactionType.model as ListStore).append(out iter);
				(this.comboboxTransactionType.model as ListStore).set(iter, 
						0, (row.Get("in_out").up() == "IN") ? pixbuf0 : pixbuf1, 
						1, row.Get("transaction_name"), 
						2, row.Get("transaction_type_id"));
			}
														
			this.comboboxTransactionType.active_id = "-1";
			
			//##build options menu
			var ops = new MenuToolButton(null, null);
			ops.get_style_context().add_class("button-ops");
			ops.menu = new Gtk.Menu();
			ops.show_all();
			ops.menu.get_style_context().add_class("white-menu");
			
			var args = new SBModuleArgs<MenuToolButton>();
			args.SetData(ops);
			
			SBModules.do_action("transactions_ops", args);
			this.boxButtons.pack_end(ops, false);
			
			//##build treeview
			this.treeviewTransactions.model = new ListStore(Columns.N_COLS,
						typeof(bool),
						typeof(int),
						typeof(string), //store
						typeof(string), //transaction type
						typeof(string), //total,
						typeof(int), //num items
						typeof(string), //status
						typeof(string), //user,
						typeof(string), //datetime
						typeof(GLib.Type)
			);
			string[,] cols = 
			{
				{SBText.__("Select"), "text", "70", "center", "", ""},
				{SBText.__("ID"), "text", "70", "center", "", ""},
				{SBText.__("Store"), "text", "120", "left", "", ""},
				{SBText.__("Type"), "text", "100", "center", "", ""},
				{SBText.__("Total"), "text", "100", "right", "", ""},
				{SBText.__("Items"), "text", "70", "center", "", ""},
				{SBText.__("Status"), "text", "70", "center", "", ""},
				{SBText.__("User"), "text", "100", "left", "", ""},
				{SBText.__("Date"), "text", "100", "left", "", ""},
			};

			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewTransactions);
			this.treeviewTransactions.rules_hint = true;
		}
		protected void SetEvents()
		{
			this.comboboxStore.changed.connect(this.OnComboBoxStoreChanged);
			this.comboboxTransactionType.changed.connect(this.OnComboBoxTransactionTypeChanged);
			this.buttonView.clicked.connect(this.OnButtonViewClicked);
		}
		protected void OnComboBoxStoreChanged()
		{
			if( this.comboboxStore.active_id == null )
				return;
			if( this.comboboxStore.active_id == "-1" )
				return;
			int store_id = int.parse(this.comboboxStore.active_id);
			this.store = new SBStore.from_id(store_id);
			/*	
			int total_rows = 0;
			
			int type_id = this.comboboxTransactionType.active_id != "-1" ? int.parse(this.comboboxTransactionType.active_id) : 0;
			var transactions = InventoryHelper.GetTransactions(store_id, type_id, 1, 100, out total_rows);
			this.FillTransactions(transactions);
			*/
		}
		protected void OnComboBoxTransactionTypeChanged()
		{
			if( this.comboboxStore.active_id == null )
				return;
			if( this.comboboxStore.active_id == "-1" )
				return;
			int total_rows = 0;
			int store_id = int.parse(this.comboboxStore.active_id);
			
			if( this.comboboxTransactionType.active_id == null )
				return;
			if( this.comboboxTransactionType.active_id == "-1" )
			{
				//var transactions = InventoryHelper.GetTransactions(store_id, 0, 1, 100, out total_rows);
				//this.FillTransactions(transactions);
				return;
			}
			
			int type_id = int.parse(this.comboboxTransactionType.active_id);
			(this.treeviewTransactions.model as ListStore).clear();
			if( this.store.PurchaseTransactionTypeId == type_id )
			{
				TreeIter iter;
								
				foreach(var t in InventoryHelper.GetPurchaseOrders(store_id, 1, 100, out total_rows))
				{
					SinticBolivia.SBDateTime dd = new SinticBolivia.SBDateTime.from_string(t.CreationDate);
					//var store = new SBStore.from_id(t.StoreId);
					
					(this.treeviewTransactions.model as ListStore).append(out iter);
					(this.treeviewTransactions.model as ListStore).set(iter,
						Columns.CHECKBOX, false,
						Columns.ID, t.Id,
						Columns.STORE, this.store.Name,
						Columns.TYPE, SBText.__("Purchase order"),
						Columns.TOTAL, "%.2f".printf(t.Total),
						Columns.NUM_ITEMS, t.Items.size,
						Columns.STATUS, t.Status,
						Columns.USER_ID, t.User.Username,
						Columns.DATETIME, dd.format("%Y-%m-%d %H:%M:%S"),
						Columns.G_TYPE, typeof(PurchaseOrder)
					);
				}
			}
			else if( this.store.SalesTransactionTypeId == type_id )
			{
				var transactions = InventoryHelper.GetTransactions(store_id, type_id, 1, 100, out total_rows);
				this.FillTransactions(transactions);
			}
			else if( this.store.RefundTransactionTypeId == type_id )
			{
			}
			
		}
		protected void FillTransactions(ArrayList<SBTransaction> records)
		{
			TreeIter iter;
			
			foreach(var t in records)
			{
				SinticBolivia.SBDateTime dd = new SinticBolivia.SBDateTime.from_string(t.CreationDate);
				//var store = new SBStore.from_id(t.StoreId);
				
				(this.treeviewTransactions.model as ListStore).append(out iter);
				(this.treeviewTransactions.model as ListStore).set(iter,
					Columns.CHECKBOX, false,
					Columns.ID, t.Id,
					Columns.STORE, this.store.Name,
					Columns.TYPE, SBText.__("Sale"),
					Columns.TOTAL, "%.2f".printf(t.Total),
					Columns.NUM_ITEMS, t.Items.size,
					Columns.STATUS, t.Status,
					Columns.USER_ID, t.User.Username,
					Columns.DATETIME, dd.format("%Y-%m-%d %H:%M:%S"),
					Columns.G_TYPE, typeof(SBTransaction)
				);
			}
		}
		protected void OnButtonViewClicked()
		{
			int width = 400;// * Pango.SCALE;
			int height = 400;// * Pango.SCALE;
			
			
			var layout = new Layout(null, null){expand = true};
			//layout.set_size((uint)width, (uint)height);
			layout.show();
			var scroll = new ScrolledWindow(null, null){expand = true};
			scroll.show();
			scroll.add(layout);
			var _dlg = new Dialog();
			_dlg.get_content_area().add(scroll);
			_dlg.show();
			_dlg.set_size_request(400, 400);
			
			TicketInvoice ticket = new TicketInvoice();
			ticket.SetWidth(width);
			ticket.SetHeight(height);
			ticket.AddLine(this.store.Name, "center");
			ticket.AddLine("Invoice", "center");
			ticket.AddLine("Subtotal: 0.00", "center");
			ticket.AddLine("Discount: 0.00", "right");
			ticket.AddLine("Total: 0.00", "right");
			
			layout.draw.connect( (ctx) => 
			{
				stdout.printf("-- draw --\n");
				var bin_window = layout.get_bin_window();
				if( cairo_should_draw_window(ctx, bin_window) )
				{
					stdout.printf("-- drawing --\n");
					ctx.save();
					cairo_transform_to_window(ctx, layout, bin_window);
					
					ticket.SetContext(ctx);
					ticket.buildPageFrame();
					ticket.Draw();
					
					ctx.restore();
					
				}
				
				return true;
			});
			layout.queue_draw();
			
			return;
			TreeModel model;
			TreeIter iter;
			if( !this.treeviewTransactions.get_selection().get_selected(out model, out iter) )
			{
				var msg = new InfoDialog("error")
				{
					Title 	= SBText.__("Selection error"),
					Message = SBText.__("You need to select a transaction.")
				};
				msg.run();
				msg.destroy();
				return;
			}
			Value v_id, v_type;
			
			model.get_value(iter, Columns.ID, out v_id);
			model.get_value(iter, Columns.G_TYPE, out v_type);
			
			string g_type = "transaction";
			var w = new WidgetViewTransaction();
			w.show();
			var dlg = new InfoDialog("info");
			dlg.modal = true;
			
			if( typeof(PurchaseOrder) == (GLib.Type)v_type )
			{
				w.SetTransaction(new PurchaseOrder.from_id((int)v_id));
				dlg.Title = SBText.__("View Purchase Order");
			}
			else
			{
				var t = new SBTransaction();
				t.GetDbData((int)v_id);
				w.SetTransaction(t);
				dlg.Title = SBText.__("View Sale");
			}
			
			dlg.get_content_area().add(w);
			dlg.show();
		}
	}
}
