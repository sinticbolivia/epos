using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetWorksheet : Box
	{
		protected	Builder			ui;
		protected	Box				box1;
		protected	Image			image1;
		protected	Label			labelTitle;
		protected	Label			labelStore;
		protected	Label			labelCountDate;
		protected	Label			labelDescription;
		protected	TreeView		treeviewProducts;
		protected	Button 			buttonCancel;
		protected	Button 			buttonSave;
		public		enum			Columns
		{
			COUNT,
			ID,
			CODE,
			NAME,
			UNITS,
			CASES,
			RESULT_ID,
			N_COLS
		}
		protected	int				countId = 0;
		protected	int				workSheet = 0;
		protected	bool			update = false;
		public		bool			ShowButtons
		{
			set
			{
				this.buttonCancel.visible = value;
				this.buttonSave.visible = value;
			}
		}
		public		bool			Editable
		{
			set
			{
				(this.treeviewProducts.get_column(Columns.UNITS).get_cells().nth_data(0) as CellRendererText).editable = value;
				(this.treeviewProducts.get_column(Columns.CASES).get_cells().nth_data(0) as CellRendererText).editable = value;
			}
		}
		public		ListStore		Model
		{
			get{return this.treeviewProducts.model as ListStore;}
		}
		public WidgetWorksheet()
		{
			this.expand = true;
			this.ui		= (SBModules.GetModule("InventoryCount") as SBGtkModule).GetGladeUi("worksheet.glade");
			this.box1	= (Box)this.ui.get_object("box1");
			this.image1	= (Image)this.ui.get_object("image1");
			this.labelTitle			= (Label)this.ui.get_object("labelTitle");
			this.labelStore			= (Label)this.ui.get_object("labelStore");
			this.labelCountDate		= (Label)this.ui.get_object("labelCountDate");
			this.labelDescription	= (Label)this.ui.get_object("labelDescription");
			this.treeviewProducts	= (TreeView)this.ui.get_object("treeviewProducts");
			this.buttonCancel		= (Button)this.ui.get_object("buttonCancel");
			this.buttonSave			= (Button)this.ui.get_object("buttonSave");
			this.box1.expand = true;
			this.box1.reparent(this);
			this.Build();
			this.SetEvents();
			
		}
		protected void Build()
		{
			this.image1.pixbuf = (SBModules.GetModule("InventoryCount") as SBGtkModule).GetPixbuf("worksheet-icon-64x64.png");
			this.treeviewProducts.model = new ListStore(Columns.N_COLS,
				typeof(int),
				typeof(int),
				typeof(string),
				typeof(string), //product name,
				typeof(int), //units
				typeof(int), //cases
				typeof(int) //result id
			);
			string[,] cols = 
			{
				{SBText.__("#"), "text", "50", "center", "", ""},
				{SBText.__("ID"), "text", "80", "center", "", ""},
				{SBText.__("Code"), "text", "150", "left", "", ""},
				{SBText.__("Product"), "text", "400", "left", "", ""},
				{SBText.__("Units"), "text", "60", "center", "editable", ""},
				{SBText.__("Cases"), "text", "60", "center", "editable", ""},
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewProducts);
			this.treeviewProducts.rules_hint = true;
			this.treeviewProducts.enable_grid_lines = TreeViewGridLines.BOTH;
		}
		protected void	SetEvents()
		{
			var cell_units = (CellRendererText)this.treeviewProducts.get_column(Columns.UNITS).get_cells().nth_data(0);
			var cell_cases = (CellRendererText)this.treeviewProducts.get_column(Columns.CASES).get_cells().nth_data(0);
			cell_units.edited.connect(this.OnCellUnitsEdited);
			cell_cases.edited.connect(this.OnCellCasesEdited);
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
			this.buttonSave.clicked.connect(this.OnButtonSaveClicked);
			
		}
		public void FillProducts(int count_id)
		{
			this.countId = count_id;
			
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("inventory_counts").Where("count_id = %d".printf(count_id));
			var count = dbh.GetRow(null);
			var store = new SBStore.from_id(count.GetInt("store_id"));
			this.labelStore.label = store.Name;
			this.labelDescription.label = count.Get("description");
			this.labelCountDate.label = count.Get("creation_date");
					
			dbh.Select("p.*").
				From("inventory_count_products cp, products p").
				Where("count_id = %d".printf(this.countId)).
				And("cp.product_id = p.product_id");
				
			(this.treeviewProducts.model as ListStore).clear();
			TreeIter iter;
			int i = 1;
			foreach(var row in dbh.GetResults(null))
			{
				var prod = new SBProduct.with_db_data(row);
				
				(this.treeviewProducts.model as ListStore).append(out iter);
				(this.treeviewProducts.model as ListStore).set(iter,
					Columns.COUNT, i,
					Columns.ID, prod.Id,
					Columns.CODE, prod.Code,
					Columns.NAME, prod.Name,
					Columns.UNITS, 0,
					Columns.CASES, 0,
					Columns.RESULT_ID, 0
				);
				i++;
			}
		}
		public void SetWorksheet(int count_id, int worksheet)
		{
			this.countId = count_id;
			this.labelTitle.label += " #%d".printf(worksheet);
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("inventory_counts").Where("count_id = %d".printf(count_id));
			var count = dbh.GetRow(null);
			var store = new SBStore.from_id(count.GetInt("store_id"));
			this.labelStore.label = store.Name;
			this.labelDescription.label = count.Get("description");
			this.labelCountDate.label = count.Get("creation_date");
			
			dbh.Select("cr.*,p.*").
				From("inventory_count_products cp, inventory_count_results cr, products p").
				Where("cp.product_id = cr.product_id").
				And("cr.product_id = p.product_id").
				And("cr.count_id = %d".printf(this.countId)).
				And("result_number = %d".printf(worksheet));
			(this.treeviewProducts.model as ListStore).clear();
			TreeIter iter;
			int i = 1;
			foreach(var row in dbh.GetResults(null))
			{
				
				(this.treeviewProducts.model as ListStore).append(out iter);
				(this.treeviewProducts.model as ListStore).set(iter,
					Columns.COUNT, i,
					Columns.ID, row.GetInt("product_id"),
					Columns.CODE, row.Get("product_code"),
					Columns.NAME, row.Get("product_name"),
					Columns.UNITS, row.GetInt("units"),
					Columns.CASES, row.GetInt("package"),
					Columns.RESULT_ID, row.GetInt("result_id")
				);
				i++;
			}
			this.update = true;
		}
		protected void OnCellUnitsEdited(string path, string text)
		{
			TreeIter iter;
			int units = int.parse(text);
			this.treeviewProducts.model.get_iter_from_string(out iter, path);
			(this.treeviewProducts.model as ListStore).set_value(iter, Columns.UNITS, units);
		}
		protected void OnCellCasesEdited(string path, string text)
		{
			TreeIter iter;
			int cases = int.parse(text);
			this.treeviewProducts.model.get_iter_from_string(out iter, path);
			(this.treeviewProducts.model as ListStore).set_value(iter, Columns.CASES, cases);
		}
		protected void OnButtonCancelClicked()
		{
			this.destroy();
			string tab_id = (string)this.get_data<string>("tab_id");
			var nb = (SBNotebook)SBGlobals.GetVar("notebook");
			nb.RemovePage(tab_id);
		}
		protected void OnButtonSaveClicked()
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var user = (SBUser)SBGlobals.GetVar("user");
			int result_number = 0;
			if( !this.update )
			{
				string count = "SELECT MAX(result_number) as next_result FROM inventory_count_results ";
				count += " WHERE count_id = %d".printf(this.countId);
				var row = dbh.GetRow(count);
				result_number = row.GetInt("next_result") + 1;
			}
			
			dbh.BeginTransaction();
			this.treeviewProducts.model.foreach( (model, path, iter) => 
			{
				Value product_id, units, cases, result_id;
				model.get_value(iter, Columns.ID, out product_id);
				model.get_value(iter, Columns.UNITS, out units);
				model.get_value(iter, Columns.CASES, out cases);
				model.get_value(iter, Columns.RESULT_ID, out result_id);
				
				var result_item = new HashMap<string, Value?>();
				
				result_item.set("units", (int)units);
				result_item.set("package", (int)cases);
				if( (int)result_id <= 0 )
				{
					//##insert new result
					result_item.set("result_number", result_number);
					result_item.set("count_id", this.countId);
					result_item.set("user_id", user.Id);
					result_item.set("employee_id", 0);
					result_item.set("product_id", (int)product_id);
					result_item.set("creation_date", new DateTime.now_local().format("%Y-%m-%d %H:%M:%S"));
					dbh.Insert("inventory_count_results", result_item);
				}
				else
				{
					//##update the result
					var where = new HashMap<string, Value?>();
					where.set("result_id", (int)result_id);
					dbh.Update("inventory_count_results", result_item, where);
				}
				
				
				return false;
			});
			dbh.EndTransaction();
			var msg = new InfoDialog()
			{
				Title = SBText.__("Worksheet"),
				Message = SBText.__("The worksheet has been submitted.")
			};
			msg.run();
			msg.destroy();
			this.OnButtonCancelClicked();
		}
	}
}
