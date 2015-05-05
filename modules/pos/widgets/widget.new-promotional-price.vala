using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetNewPromotionalPrice : Box
	{
		protected	Builder			ui;
		protected	Box				box1;
		protected	Image			image1;
		protected	Grid			grid1;
		protected	ComboBox		comboboxStore;
		protected	SBDatePicker	datepicker1;
		protected	SBDatePicker	datepicker2;
		protected	Entry			entryDescription;
		protected	Entry			entrySearch;
		protected	Button			buttonAdd;
		protected	TreeView			treeviewItems;
		protected	CellRendererCombo	cellDiscountTypes;
		protected	Button				buttonCancel;
		protected	Button				buttonSave;
		protected	enum				Columns
		{
			COUNT,
			ID,
			CODE,
			PRODUCT,
			DISCOUNT_TYPE,
			AMOUNT,
			REMOVE,
			DISCOUNT_TYPE_CODE,
			N_COLS
		}
		public WidgetNewPromotionalPrice()
		{
			this.ui			= (SBModules.GetModule("Pos") as SBGtkModule).GetGladeUi("new-promotional-price.glade");
			this.box1		= (Box)this.ui.get_object("boxNewPromotionalPrice");
			this.image1		= (Image)this.ui.get_object("image1");
			this.grid1			= (Grid)this.ui.get_object("grid1");
			this.comboboxStore	= (ComboBox)this.ui.get_object("comboboxStore");
			this.datepicker1	= new SBDatePicker()
			{
				Icon = GtkHelper.GetPixbuf("share/images/calendar-icon-16x16.png")
			};
			this.datepicker2	= new SBDatePicker()
			{
				Icon = GtkHelper.GetPixbuf("share/images/calendar-icon-16x16.png")
			};
			this.entryDescription	= (Entry)this.ui.get_object("entryDescription");
			this.entrySearch		= (Entry)this.ui.get_object("entrySearch");
			this.buttonAdd			= (Button)this.ui.get_object("buttonAdd");
			this.treeviewItems		= (TreeView)this.ui.get_object("treeviewItems");
			this.buttonCancel		= (Button)this.ui.get_object("buttonCancel");
			this.buttonSave			= (Button)this.ui.get_object("buttonSave");
			this.box1.reparent(this);
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
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
			this.grid1.attach(this.datepicker1, 1, 1, 1, 1);
			this.grid1.attach(this.datepicker2, 3, 1, 1, 1);
			this.grid1.show_all();
			//##build treeview
			this.treeviewItems.model = new ListStore(Columns.N_COLS,
				typeof(int), //count
				typeof(int), //product id
				typeof(string), //product code
				typeof(string), //product
				typeof(string), //discount type
				typeof(string), //amount
				typeof(Gdk.Pixbuf), //remove
				typeof(string) //discount type code
			);
			string[,] cols = 
			{
				{SBText.__("#"), "text", "50", "center", "", ""},
				{SBText.__("ID"), "text", "50", "center", "", ""},
				{SBText.__("Code"), "text", "120", "left", "", ""},
				{SBText.__("Product"), "text", "250", "left", "", ""},
				{SBText.__("Discount Type"), "combo", "250", "center", "editable", ""},
				{SBText.__("Amount"), "text", "90", "right", "editable", ""},
				{SBText.__("Remove"), "pixbuf", "45", "center", "", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewItems);
			this.treeviewItems.get_column(Columns.REMOVE).set_data<string>("action", "remove");
			this.cellDiscountTypes = (CellRendererCombo)this.treeviewItems.get_column(Columns.DISCOUNT_TYPE).get_cells().nth_data(0);
			this.cellDiscountTypes.model = new ListStore(2, 
				typeof(string), //discount name
				typeof(string) //discount type code
			);
			this.cellDiscountTypes.text_column = 0;
			this.treeviewItems.get_column(Columns.DISCOUNT_TYPE).
									add_attribute(this.cellDiscountTypes, "text", Columns.DISCOUNT_TYPE);
			this.treeviewItems.rules_hint = true;
			//##fill discount types
			//TreeIter iter;
			(this.cellDiscountTypes.model as ListStore).append(out iter);
			(this.cellDiscountTypes.model as ListStore).set(iter, 0, SBText.__("Increase by amount"), 1, "increase_amount");
			(this.cellDiscountTypes.model as ListStore).append(out iter);
			(this.cellDiscountTypes.model as ListStore).set(iter, 0, SBText.__("Discount by amount"), 1, "discount_amount");
			(this.cellDiscountTypes.model as ListStore).append(out iter);
			(this.cellDiscountTypes.model as ListStore).set(iter, 0, SBText.__("Increase by percentage"), "increase_percentage");
			(this.cellDiscountTypes.model as ListStore).append(out iter);
			(this.cellDiscountTypes.model as ListStore).set(iter, 0, SBText.__("Discount by percentage"), 1, "increase_percentage");
		}
		protected void SetEvents()
		{
			this.entrySearch.icon_release.connect(this.OnEntrySearchIconRelease);
			this.buttonAdd.clicked.connect(this.OnButtonAddClicked);
			this.cellDiscountTypes.changed.connect(this.OnDiscountTypeChanged);
			(this.treeviewItems.get_column(Columns.AMOUNT).get_cells().nth_data(0) as CellRendererText).
					edited.connect(this.OnAmountEdited);
			this.treeviewItems.button_release_event.connect(this.OnTreeViewItemsButtonReleaseEvent);
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
			this.buttonSave.clicked.connect(this.OnButtonSaveClicked);
		}
		protected void OnEntrySearchIconRelease(EntryIconPosition icon, Gdk.Event e)
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1" )
			{
				this.comboboxStore.grab_focus();
				return;
			}
			if( icon == EntryIconPosition.PRIMARY )
			{
				var dlg = new WindowLookupProducts()
				{
					StoreId = int.parse(this.comboboxStore.active_id),
					modal = true
				};
				dlg.show();
				dlg.destroy.connect( () => 
				{
					var prod = new SBProduct.from_id(dlg.ProductId);
					this.entrySearch.text = prod.Name;
					this.buttonAdd.set_data<int>("product_id", prod.Id);
				});
			}
			else
			{
				//##show product info
			}
		}
		protected void OnButtonAddClicked()
		{
			int? product_id = this.buttonAdd.get_data<int>("product_id");
			if( product_id == null || product_id <= 0 )
				return;
			
			this.AddProduct(product_id);
			this.entrySearch.text = "";
			this.buttonAdd.set_data<int>("product_id", 0);
		}
		protected void OnDiscountTypeChanged(string path, TreeIter iter_new)
		{
			Value name, code;
			
			this.cellDiscountTypes.model.get_value(iter_new, 0, out name);
			this.cellDiscountTypes.model.get_value(iter_new, 1, out code);
			
			TreeIter iter;
			this.treeviewItems.model.get_iter(out iter, new TreePath.from_string(path));
						
			(this.treeviewItems.model as ListStore).set_value(iter, Columns.DISCOUNT_TYPE, (string)name);
			(this.treeviewItems.model as ListStore).set_value(iter, Columns.DISCOUNT_TYPE_CODE, (string)code);
		}
		protected void OnAmountEdited(string path, string new_text)
		{
			TreeIter iter;
			this.treeviewItems.model.get_iter(out iter, new TreePath.from_string(path));
			double amount = double.parse(new_text);
			(this.treeviewItems.model as ListStore).set_value(iter, Columns.AMOUNT, "%.2f".printf(amount));
		}
		protected bool OnTreeViewItemsButtonReleaseEvent(Gdk.EventButton args)
		{
			TreePath path;
			TreeViewColumn c;
			TreeIter iter;
			TreeModel model;
			int cell_x, cell_y;
			
			if( !this.treeviewItems.get_path_at_pos((int)args.x, (int)args.y, out path, out c, out cell_x, out cell_y) )
				return false;
		
			if( !this.treeviewItems.get_selection().get_selected(out model, out iter) )
				return false;
				
			string action = c.get_data<string>("action");
			if( action == "remove" )
			{
				(this.treeviewItems.model as ListStore).remove(iter);
			}
			return true;
		}
		protected void AddProduct(int product_id)
		{
			var prod = new SBProduct.from_id(product_id);
			bool product_exists = false;
			int i = 0;
			this.treeviewItems.model.foreach( (model, path, iter) => 
			{
				Value id;
				model.get_value(iter, Columns.ID, out id);
				if( (int)id == product_id )
					product_exists = true;
				i++;
				return false;
			});
			if( !product_exists )
			{
				//##insert the product to promotion
				var remove_pix = (SBModules.GetModule("Pos") as SBGtkModule).GetPixbuf("remove-20x20.png");
				TreeIter iter;
				(this.treeviewItems.model as ListStore).append(out iter);
				(this.treeviewItems.model as ListStore).set(iter,
					Columns.COUNT, i + 1,
					Columns.ID, prod.Id,
					Columns.CODE, prod.Code,
					Columns.PRODUCT, prod.Name,
					Columns.DISCOUNT_TYPE, SBText.__("-- discount type --"),
					Columns.AMOUNT, "0.00",
					Columns.REMOVE, remove_pix
				);
			}
			else
			{
				
			}
		}
		protected void OnButtonCancelClicked()
		{
			var nb = (SBNotebook)SBGlobals.GetVar("notebook");
			nb.RemovePage("new-promo-price");
		}
		protected void OnButtonSaveClicked()
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1" )
			{
				var err = new InfoDialog("error")
				{
					Title 	= SBText.__("Error"),
					Message = SBText.__("You need to select a store.")
				};
				err.run();
				err.destroy();
				return;
			}
			if( this.datepicker1.DateString.length <= 0 )
			{
				var err = new InfoDialog("error")
				{
					Title 	= SBText.__("Error"),
					Message = SBText.__("You need to enter the start date.")
				};
				err.run();
				err.destroy();
				return;
			}
			if( this.datepicker2.DateString.length <= 0 )
			{
				var err = new InfoDialog("error")
				{
					Title 	= SBText.__("Error"),
					Message = SBText.__("You need to enter the end date.")
				};
				err.run();
				err.destroy();
				return;
			}
			if( this.entryDescription.text.strip().length <= 0 )
			{
				var err = new InfoDialog("error")
				{
					Title 	= SBText.__("Error"),
					Message = SBText.__("You need to enter a description.")
				};
				err.run();
				err.destroy();
				return;
			}
			TreeIter iter;
			if( !this.treeviewItems.model.get_iter_first(out iter) )
			{
				var err = new InfoDialog("error")
				{
					Title 	= SBText.__("Error"),
					Message = SBText.__("You need to add products to promotion.")
				};
				err.run();
				err.destroy();
				return;
			}
			int store_id = int.parse(this.comboboxStore.active_id);
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var promo = new HashMap<string, Value?>();
			promo.set("store_id", store_id);
			promo.set("description", this.entryDescription.text.strip());
			promo.set("start_date", this.datepicker1.DateString);
			promo.set("end_date", this.datepicker2.DateString);
			promo.set("status", "active");
			promo.set("creation_date", new DateTime.now_local().format("%Y-%m-%d %H:%M:%S"));
			dbh.BeginTransaction();
			int promo_id = (int)dbh.Insert("promotional_prices", promo);
			this.treeviewItems.model.foreach((model, path, iter) =>
			{
				Value product_id, discount_type, amount;
				model.get_value(iter, Columns.ID, out product_id);
				model.get_value(iter, Columns.DISCOUNT_TYPE_CODE, out discount_type);
				model.get_value(iter, Columns.AMOUNT, out amount);
				
				var item = new HashMap<string, Value?>();
				item.set("promo_id", promo_id);
				item.set("product_id", (int)product_id);
				item.set("discount_type", (string)discount_type);
				item.set("discount", double.parse((string)amount));
				item.set("creation_date", new DateTime.now_local().format("%Y-%m-%d %H:%M:%S"));
				dbh.Insert("promotional_price_items", item);
				return false;
			});
			dbh.EndTransaction();
			var msg = new InfoDialog("success")
			{
				Title 	= SBText.__("Success"),
				Message = SBText.__("The promotional price has been created.")
			};
			msg.run();
			msg.destroy();
			this.destroy();
		}
	}
}
