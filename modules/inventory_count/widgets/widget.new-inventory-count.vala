using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetNewInventoryCount : Box
	{
		protected 	Builder			ui;
		protected	Box				box1;
		protected	Image			image1;
		protected	ComboBox		comboboxStore;
		protected	Entry			entryDescription;
		protected	Entry			entrySearchProduct;
		protected	ComboBox		comboboxSearchBy;
		protected	Button			buttonAdd;
		protected	TreeView		treeviewProducts;
		protected	Button 			buttonCancel;
		protected	Button			buttonSave;
		
		protected	enum			Columns
		{
			COUNT,
			ID,
			CODE,
			PRODUCT,
			REMOVE,
			N_COLS
		}
		public WidgetNewInventoryCount()
		{
			this.expand 	= true;
			this.ui			= (SBModules.GetModule("InventoryCount") as SBGtkModule).GetGladeUi("new-inventory-count.glade");
			this.box1		= (Box)this.ui.get_object("box1");
			this.image1		= (Image)this.ui.get_object("image1");
			this.comboboxStore	= (ComboBox)this.ui.get_object("comboboxStore");
			this.entryDescription	= (Entry)this.ui.get_object("entryDescription");
			this.entrySearchProduct	= (Entry)this.ui.get_object("entrySearchProduct");
			this.comboboxSearchBy	= (ComboBox)this.ui.get_object("comboboxSearchBy");
			this.buttonAdd			= (Button)this.ui.get_object("buttonAdd");
			this.treeviewProducts	= (TreeView)this.ui.get_object("treeviewProducts");
			this.buttonCancel		= (Button)this.ui.get_object("buttonCancel");
			this.buttonSave			= (Button)this.ui.get_object("buttonSave");
			this.box1.reparent(this);
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			this.box1.expand = true;
			this.image1.pixbuf	= (SBModules.GetModule("InventoryCount") as SBGtkModule).GetPixbuf("inventory-count-icon-64x64.png");
			var cell = new CellRendererText();
			this.comboboxStore.model = new ListStore(2, typeof(string), typeof(string));
			this.comboboxStore.pack_start(cell, true);
			this.comboboxStore.set_attributes(cell, "text", 0);
			this.comboboxStore.id_column = 1;
			TreeIter iter;
			(this.comboboxStore.model as ListStore).append(out iter);
			(this.comboboxStore.model as ListStore).set(iter,
				0, SBText.__("-- store --"),
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
			//##build treeview
			this.treeviewProducts.model = new ListStore(Columns.N_COLS,
				typeof(int),
				typeof(int),
				typeof(string),
				typeof(string),
				typeof(Gdk.Pixbuf)
			);
			string[,] cols = 
			{
				{SBText.__("#"), "text", "50", "center", "", ""},
				{SBText.__("ID"), "text", "50", "center", "", ""},
				{SBText.__("Code"), "text", "150", "left", "", ""},
				{SBText.__("Product"), "text", "350", "left", "", ""},
				{SBText.__(""), "pixbuf", "40", "center", "", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewProducts);
			this.treeviewProducts.rules_hint = true;
			this.treeviewProducts.get_column(Columns.REMOVE).set_data<string>("action", "remove");
		}
		protected void SetEvents()
		{
			this.entrySearchProduct.icon_release.connect(this.OnEntrySearchProductIconRelease);
			this.treeviewProducts.button_release_event.connect(this.OnTreeViewProductsButtonReleaseEvent);
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
			this.buttonSave.clicked.connect(this.OnButtonSaveClicked);
		}
		protected void OnEntrySearchProductIconRelease(EntryIconPosition icon, Gdk.Event e)
		{
			if( icon == EntryIconPosition.PRIMARY )
			{
				if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1")
				{
					this.comboboxStore.grab_focus();
					return;
				}
				
				var w = new WidgetProductsSearch();
				w.show();
				w.Refresh(int.parse(this.comboboxStore.active_id));
				var dlg = new Dialog(){width_request = 800, height_request = 500, modal = true};
				dlg.get_content_area().add(w);
				w.ButtonCancel.clicked.connect(() => 
				{
					dlg.destroy();
				});
				w.OnSelected.connect( (products) => 
				{
					var remove_img = (SBModules.GetModule("InventoryCount") as SBGtkModule).GetPixbuf("remove-20x20.png");
					TreeIter iter;
					int i = 1;
					foreach(var prod in products)
					{
						(this.treeviewProducts.model as ListStore).append(out iter);
						(this.treeviewProducts.model as ListStore).set(iter,
							Columns.COUNT, i,
							Columns.ID, prod.Id,
							Columns.CODE, prod.Code,
							Columns.PRODUCT, prod.Name,
							Columns.REMOVE, remove_img
						);
						i++;
					}
					dlg.destroy();
				});
				dlg.show();
			}
		}
		protected bool OnTreeViewProductsButtonReleaseEvent(Gdk.EventButton args)
		{
			TreePath path;
			TreeViewColumn column;
			int cell_x, cell_y;
			
			if( !this.treeviewProducts.get_path_at_pos((int)args.x, (int)args.y, out path, out column, out cell_x, out cell_y) )
				return true;
			
			string action = (string)column.get_data<string>("action");
			if( action == "remove" )
			{
				TreeModel model;
				TreeIter iter;
				if( this.treeviewProducts.get_selection().get_selected(out model, out iter) )
				{
					(this.treeviewProducts.model as ListStore).remove(iter);
				}
			}
			return true;
		}
		protected void OnButtonCancelClicked()
		{
			this.destroy();
			var nb = (SBNotebook)SBGlobals.GetVar("notebook");
			nb.RemovePage("new-inventory-count");
		}
		protected void OnButtonSaveClicked()
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1" )
			{
				var err = new InfoDialog("error")
				{
					Title = SBText.__("Error"),
					Message = SBText.__("You need to select a store.")
				};
				err.run();
				err.destroy();
				return;
			}
			string desc = this.entryDescription.text.strip();
			if( desc.length <= 0 )
			{
				var err = new InfoDialog("error")
				{
					Title = SBText.__("Error"),
					Message = SBText.__("You need to enter a description.")
				};
				err.run();
				err.destroy();
				return;
			}
			TreeIter iter;
			if( !this.treeviewProducts.model.get_iter_first(out iter) ) 
			{
				var err = new InfoDialog("error")
				{
					Title = SBText.__("Error"),
					Message = SBText.__("You need to add atleast one product.")
				};
				err.run();
				err.destroy();
				return;
			}
			int store_id 	= int.parse(this.comboboxStore.active_id);
			var dbh 		= (SBDatabase)SBGlobals.GetVar("dbh");
			var user 		= (SBUser)SBGlobals.GetVar("user");
			
			var count = new HashMap<string, Value?>();
			count.set("store_id", store_id);
			count.set("user_id", user.Id);
			count.set("description", desc);
			count.set("status", "pending");
			count.set("creation_date", new DateTime.now_local().format("%Y-%m-%d %H:%M:%S"));
			
			dbh.BeginTransaction();
			int count_id = (int)dbh.Insert("inventory_counts", count);
			int i = 0;
			//##insert the items
			this.treeviewProducts.model.foreach( (model, path, iter) => 
			{
				Value pid;
				model.get_value(iter, Columns.ID, out pid);
				var item = new HashMap<string, Value?>();
				item.set("count_id", count_id);
				item.set("product_id", (int)pid);
				item.set("creation_date", new DateTime.now_local().format("%Y-%m-%d %H:%M:%S"));
				dbh.Insert("inventory_count_products", item);
				i++;
				return false;
			});
			//dbh.Execute("UPDATE inventory_counts SET products = %d WHERE count_id = %d".printf(i, count_id));
			dbh.EndTransaction();
			var msg = new InfoDialog("success")
			{
				Title = SBText.__("Success"),
				Message = SBText.__("Your inventory count has been registered and now is pending.")
			};
			msg.run();
			msg.destroy();
			this.OnButtonCancelClicked();
		}
	}
}
