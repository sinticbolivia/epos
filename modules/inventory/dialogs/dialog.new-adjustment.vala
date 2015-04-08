using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class DialogNewAdjustment : Dialog
	{
		protected	Image					image1;
		protected	Label					labelTitle;
		protected	Grid					grid1;
		protected	ComboBox				comboboxStore;
		protected	Label					labelDate;
		protected	SBDatePicker			datepicker;
		protected	Entry					entrySearch;
		protected	Entry					entryQty;
		protected	TextView				textviewNotes;
		//protected	WidgetProductsSearch	productSearch;
		
		protected	Button					buttonCancel;
		protected	Button					buttonSave;
		protected	int						storeId = 0;
		protected	int						productId = 0;
		
		public DialogNewAdjustment()
		{
			this.title 			= SBText.__("Inventory Adjustment");
			this.labelTitle		= new Label(SBText.__("Inventory Adjustment"));
			this.image1			= new Image.from_pixbuf((SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("adjustment-icon-64x55.png"));
			this.comboboxStore	= new ComboBox();
			this.labelDate		= new Label(SBText.__("Date:"));
			this.datepicker		= new SBDatePicker();
			this.entrySearch	= new Entry();
			this.entryQty		= new Entry();
			this.grid1			= new Grid(){row_spacing = 5, column_spacing = 5};
			this.textviewNotes	= new TextView(){height_request = 70};
			this.buttonCancel	= (Button)this.add_button(SBText.__("Cancel"), ResponseType.CANCEL);
			this.buttonSave		= (Button)this.add_button(SBText.__("Save"), ResponseType.OK);
			
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			this.get_content_area().spacing = 5;
			
			this.labelTitle.get_style_context().add_class("widget-title");
			this.entrySearch.placeholder_text = SBText.__("Product");
			this.textviewNotes.get_style_context().add_class("yellow-background");
			this.buttonCancel.get_style_context().add_class("button-red");
			this.buttonSave.get_style_context().add_class("button-green");
			
			this.comboboxStore.model = new ListStore(2, typeof(string), typeof(string));
			var cell = new CellRendererText();
			this.comboboxStore.pack_start(cell, true);
			this.comboboxStore.set_attributes(cell, "text", 0);
			this.comboboxStore.id_column = 1;
			
			TreeIter iter;
			(this.comboboxStore.model as ListStore).append(out iter);
			(this.comboboxStore.model as ListStore).set(iter,
				0, SBText.__("-- store-- "),
				1, "-1"
			);
			foreach(var store in InventoryHelper.GetStores())
			{
				(this.comboboxStore.model as ListStore).append(out iter);
				(this.comboboxStore.model as ListStore).set(iter,
					0, store.Name,
					1, store.Id.to_string()
				);
			}
			this.comboboxStore.active_id = "-1";
			this.datepicker.DateString = new DateTime.now_local().format("%Y-%m-%d");
			this.datepicker.Icon = GtkHelper.GetPixbuf("share/images/calendar-icon-16x16.png");
			//##build entry completion
			this.entrySearch.completion = new EntryCompletion();
			this.entrySearch.completion.model = new ListStore(2, typeof(string), typeof(int));
			this.entrySearch.completion.text_column = 0;
			
			var box0 = new Box(Orientation.HORIZONTAL, 5);
			box0.add(this.image1);
			box0.add(this.labelTitle);
			box0.show_all();
			this.get_content_area().add(box0);
			this.grid1.attach(new Label(SBText.__("Store:")), 0, 0, 1, 1);
			this.grid1.attach(this.comboboxStore, 1, 0, 1, 1);
			this.grid1.attach(this.labelDate, 2, 0, 1, 1);
			this.grid1.attach(this.datepicker, 3, 0, 1, 1);
			
			this.grid1.attach(this.entrySearch, 0, 1, 3, 1);
			this.grid1.attach(new Label("Quantity:"), 0, 2, 1, 1);
			this.grid1.attach(this.entryQty, 1, 2, 1, 1);
			
			var scroll = new ScrolledWindow(null, null){expand = true, shadow_type = ShadowType.ETCHED_IN};
			this.textviewNotes.wrap_mode = WrapMode.WORD;
			scroll.add(this.textviewNotes);
			scroll.show_all();
			this.grid1.attach(scroll, 0, 3, 4, 1);
			
			this.grid1.show_all();
			this.get_content_area().add(this.grid1);
		}
		protected void SetEvents()
		{
			this.entrySearch.key_release_event.connect(this.OnEntrySearchKeReleaseEvent);
			this.entrySearch.completion.set_match_func( (completion, key, iter) => 
			{
				return true;
			});
			this.entrySearch.completion.match_selected.connect(this.OnEntrySearchMatchSelected);
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
			this.buttonSave.clicked.connect(this.OnButtonSaveClicked);
		}
		protected bool OnEntrySearchKeReleaseEvent(Gdk.EventKey e)
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1" )
				return true;
				
			if( e.keyval == 65361 || e.keyval == 65362 || e.keyval == 65363 || e.keyval == 65364 )
				return true;
				
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string keyword = this.entrySearch.text.strip();
			if( keyword.length <= 0 )
				return true;
			int store_id = int.parse(this.comboboxStore.active_id);
			string q = "SELECT * FROM products WHERE store_id = %d AND product_name LIKE '%s'".printf(store_id, "%"+keyword+"%");
			stdout.printf("%s\n", q);
			TreeIter iter;
			(this.entrySearch.completion.model as ListStore).clear();
			foreach(var row in dbh.GetResults(q))
			{
				(this.entrySearch.completion.model as ListStore).append(out iter);
				(this.entrySearch.completion.model as ListStore).set(iter, 
					0, row.Get("product_name"),
					1, row.GetInt("product_id")
				);
			}
			return true;
		}
		protected bool OnEntrySearchMatchSelected(TreeModel model, TreeIter iter)
		{
			Value name, id;
			
			model.get_value(iter, 0, out name);
			model.get_value(iter, 1, out id);
			this.entrySearch.text 	= (string)name;
			this.productId			= (int)id;
			return true;
		}
		protected void OnButtonCancelClicked()
		{
			this.destroy();
		}
		protected void OnButtonSaveClicked()
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1" )
			{
				return;
			}
			int store_id = int.parse(this.comboboxStore.active_id);
			if( this.productId <= 0 )
			{
				this.entrySearch.grab_focus();
				return;
			}
			var store = new SBStore.from_id(store_id);
			if( this.entryQty.text.strip().length <= 0 )
			{
				this.entryQty.grab_focus();
				return;
			}
			int qty = int.parse(this.entryQty.text.strip());
			/*
			if( qty <= 0 )
			{
				this.entrySearch.grab_focus();
				return;
			}
			*/
			var prod = new SBProduct.from_id(this.productId);
			int old_qty = prod.Quantity;
			int new_qty = old_qty + qty;
			int difference = new_qty - old_qty;
			
			var user = (SBUser)SBGlobals.GetVar("user");
			string cdate = new DateTime.now_local().format("%y-%m-%d %H:%M:%S");
			var data = new HashMap<string, Value?>();
			data.set("store_id", store_id);
			data.set("product_id", this.productId);
			data.set("user_id", user.Id);
			data.set("note", this.textviewNotes.buffer.text.strip());
			data.set("old_qty", old_qty);
			data.set("new_qty", new_qty);
			data.set("difference", difference);
			data.set("status", "completed");
			data.set("adjustment_date", this.datepicker.DateString + " 00:00:00");
			data.set("creation_date", cdate);
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.BeginTransaction();
			long id = dbh.Insert("product_adjustments", data);
			int doc_id = int.parse(store.GetMeta("adjustment_doc"));
			var document = new SBTransactionType.from_id(doc_id);
			string code = "%s-%s".printf(document.Key, Utils.FillCeros((int)id));
			dbh.Execute("UPDATE product_adjustments SET code = '%s' WHERE adjustment_id = %ld".printf(code, id));
			//##update product quantity
			dbh.Execute("UPDATE products SET product_quantity = %d WHERE product_id = %d".printf(new_qty, prod.Id));
			dbh.EndTransaction();
			var msg = new InfoDialog("sucess")
			{
				Title = SBText.__("Iventory Adjustment"),
				Message = SBText.__("The adjustment has been registerd and applied.")
			};
			msg.run();
			msg.destroy();
			this.destroy();
		}
	}
}
