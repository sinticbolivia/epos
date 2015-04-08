using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetSupplierCategories : Box
	{
		protected	Builder			ui;
		protected	Box				box1;
		protected	Image			image1;
		protected	Button			buttonNew;
		protected	Button			buttonEdit;
		protected	Button			buttonDelete;
		protected	TreeView		treeviewCategories;
		protected	Window			windowNewCategory;
		protected	Entry			entryCategoryName;
		protected	Button			buttonCancel;
		protected	Button			buttonSave;
		protected	int				categoryId;
		
		protected	enum 		Columns			
		{
			COUNT,
			ID,
			NAME,
			ITEMS,
			N_COLS
		}
		public WidgetSupplierCategories()
		{
			this.ui			= (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("supplier-categories.glade");
			this.box1		= (Box)this.ui.get_object("box1");
			this.image1		= (Image)this.ui.get_object("image1");
			this.buttonNew	= (Button)this.ui.get_object("buttonNew");
			this.buttonEdit	= (Button)this.ui.get_object("buttonEdit");
			this.buttonDelete	= (Button)this.ui.get_object("buttonDelete");
			this.treeviewCategories	= (TreeView)this.ui.get_object("treeviewCategories");
			
			this.box1.reparent(this);
			this.Build();
			this.Refresh();
			this.SetEvents();
		}
		protected void Build()
		{
			this.treeviewCategories.model = new ListStore(Columns.N_COLS,
				typeof(int),
				typeof(int),
				typeof(string),
				typeof(int)
			);
			string[,] cols = 
			{
				{"#", "text", "50", "center", "", ""},
				{SBText.__("ID"), "text", "50", "center", "", ""},
				{SBText.__("Group"), "text", "250", "left", "", ""},
				{SBText.__("Suppliers"), "text", "50", "center", "", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewCategories);
			this.treeviewCategories.rules_hint = true;
			
		}
		protected void SetEvents()
		{
			this.buttonNew.clicked.connect(this.OnButtonNewClicked);
			this.buttonEdit.clicked.connect(this.OnButtonEditClicked);
			this.buttonDelete.clicked.connect(this.OnButtonDeleteClicked);
		}
		protected void BuildWindow()
		{
			this.windowNewCategory = new Window();
			var box = new Box(Orientation.VERTICAL, 5);
			var label = new Label(SBText.__("Category Name:"));
			this.entryCategoryName = new Entry();
			var vbox = new Box(Orientation.HORIZONTAL, 5);
			vbox.add(label);
			vbox.add(this.entryCategoryName);
			
			var button_box 		= new Box(Orientation.HORIZONTAL, 5);
			this.buttonCancel 	= new Button();
			this.buttonSave		= new Button();
			button_box.add(this.buttonCancel);
			button_box.add(this.buttonSave);
			box.add(new Label(SBText.__("Supplier Category")));
			box.add(vbox);
			box.add(button_box);
			box.show_all();
			this.windowNewCategory.add(box);
			//##set buttons events
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
			this.buttonSave.clicked.connect(this.OnButtonSaveClicked);
		}
		protected void OnButtonNewClicked()
		{
			if( this.windowNewCategory == null )
			{
				this.BuildWindow();
			}
			this.categoryId = 0;
			this.windowNewCategory.show();
		}
		protected void OnButtonEditClicked()
		{
			TreeModel model;
			TreeIter iter;
			if( !this.treeviewCategories.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("supplier_categories").Where("category_id = %d".printf(this.categoryId));
			var row = dbh.GetRow(null);
			if( this.windowNewCategory == null )
			{
				this.BuildWindow();
			}
			this.entryCategoryName.text = row.Get("name");
			this.windowNewCategory.show();
		}
		protected void OnButtonDeleteClicked()
		{
		}
		protected void OnButtonCancelClicked()
		{
			this.windowNewCategory.destroy();
		}
		protected void OnButtonSaveClicked()
		{
			string name = this.entryCategoryName.text.strip();
			if( name.length <= 0 )
			{
				this.entryCategoryName.grab_focus();
				return;
			}
			string cdate = new DateTime.now_local().format("%Y-%m-%d %H:%M:%S");
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var data = new HashMap<string, Value?>();
			data.set("name", name);
			data.set("last_modification_date", cdate);
			string msg = SBText.__("The category has been created");
			if( this.categoryId <= 0 )
			{
				data.set("creation_date", cdate);
				this.categoryId = (int)dbh.Insert("supplier_categories", data);
			}
			else
			{
				var where = new HashMap<string, Value?>();
				where.set("category_id", this.categoryId);
				dbh.Update("supplier_categories", data, where);
				msg = SBText.__("The category has been updated.");
			}
			this.categoryId = 0;
			var dmsg = new InfoDialog("success")
			{
				Title = SBText.__("Supplier Category"),
				Message = msg
			};
			dmsg.run();
			dmsg.destroy();
			this.Refresh();
		}
		protected void Refresh()
		{
			(this.treeviewCategories.model as ListStore).clear();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("supplier_categories");
			TreeIter iter;
			int i = 1;
			foreach(var row in dbh.GetResults(null))
			{
				(this.treeviewCategories.model as ListStore).append(out iter);
				(this.treeviewCategories.model as ListStore).set(iter,
					Columns.COUNT, i,
					Columns.ID, row.GetInt("category_id"),
					Columns.NAME, row.Get("name"),
					Columns.ITEMS, 0
				);
				i++;
			}
		}
	}
}
