using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos.Woocommerce
{
	public class WidgetOrderFees : Box
	{
		protected	Builder					ui;
		protected	Box						box1;
		protected	Image					image1;
		public		Button					buttonClose;
		protected	TreeView				treeviewFees;
		protected	CellRendererCombo		cellComboRates;
		protected	Button					buttonAdd;
		protected	Button					buttonDelete;
		protected	Label					labelTotal;
		protected	enum			Columns
		{
			COUNT,
			TITLE,
			AMOUNT,
			TAX,
			TOTAL,
			TAX_ID,
			TAX_RATE,
			N_COLS
		}
		//protected	SBDatabase				dbh;
		protected	int						items = 0;
		public		ArrayList<HashMap<string, Value?>>	Taxes
		{
			set
			{
				TreeIter iter;
				(this.cellComboRates.model as ListStore).clear();
				(this.cellComboRates.model as ListStore).append(out iter); 
				(this.cellComboRates.model as ListStore).set(iter, 0, SBText.__("-- tax rate --"), 1, "-1");
				foreach(var rate in value)
				{
					(this.cellComboRates.model as ListStore).append(out iter); 
					(this.cellComboRates.model as ListStore).set(iter, 
						0, "%s (%.2f)".printf((string)rate["name"], (double)rate["rate"]), 
						1, ((int)rate["tax_id"]).to_string(),
						2, "%.2f".printf((double)rate["rate"]),
						3, (string)rate["name"]
					);
				}
			}
		}
		public WidgetOrderFees()
		{
			this.expand = true;
			this.margin = 5;
			this.ui		= (SBModules.GetModule("WoocommerceFees") as SBGtkModule).GetGladeUi("fees.glade");
			this.image1	= (Image)this.ui.get_object("image1");
			this.box1	= (Box)this.ui.get_object("box1");
			this.treeviewFees	= (TreeView)this.ui.get_object("treeviewFees");
			this.buttonAdd		= (Button)this.ui.get_object("buttonAdd");
			this.buttonDelete	= (Button)this.ui.get_object("buttonDelete");
			this.buttonClose	= (Button)this.ui.get_object("buttonClose");
			this.labelTotal		= (Label)this.ui.get_object("labelTotal");
			this.box1.reparent(this);
			this.box1.expand = true;
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			this.set_size_request(660, 400);
			this.image1.pixbuf = (SBModules.GetModule("WoocommerceFees") as SBGtkModule).GetPixbuf("dollar-icon-64x48.png");
			this.treeviewFees.model = new ListStore(Columns.N_COLS,
				typeof(int),
				typeof(string), //title
				typeof(string), //amount
				typeof(string), //tax
				typeof(string), //total
				typeof(int), //tax id
				typeof(string) //tax rate
			);
			string[,] cols = 
			{
				{SBText.__("#"), "text", "40", "center", "", ""},
				{SBText.__("Title"), "text", "200", "left", "editable", ""},
				{SBText.__("Amount"), "text", "80", "right", "editable", ""},
				{SBText.__("Tax %"), "combo", "100", "center", "editable", ""},
				{SBText.__("Total"), "text", "80", "right", "editable", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewFees);
			this.treeviewFees.rules_hint = true;
			
			this.cellComboRates = (CellRendererCombo)this.treeviewFees.get_column(Columns.TAX).get_cells().nth_data(0);
			this.cellComboRates.model = new ListStore(4, 
				typeof(string), //tax name
				typeof(string), //tax id
				typeof(string), //tax rate
				typeof(string) //tax code
			);
			this.cellComboRates.text_column = 0;
			this.treeviewFees.get_column(Columns.TAX).add_attribute(this.cellComboRates, "text", Columns.TAX);
			
		}
		protected void SetEvents()
		{
			var cell_title = (CellRendererText)this.treeviewFees.get_column(Columns.TITLE).get_cells().nth_data(0);
			var cell_amount = (CellRendererText)this.treeviewFees.get_column(Columns.AMOUNT).get_cells().nth_data(0);
			
			cell_title.edited.connect(this.OnTitleEdited);
			cell_amount.edited.connect(this.OnAmountEdited);
			this.cellComboRates.changed.connect(this.OnTaxChanged);
			
			
			this.buttonAdd.clicked.connect(this.OnButtonAddClicked);
			this.buttonDelete.clicked.connect(this.OnButtonDeleteClicked);
			this.buttonClose.clicked.connect(this.OnButtonCloseClicked);
		}
		protected void OnTitleEdited(string path, string new_text)
		{
			TreeIter iter;
			this.treeviewFees.model.get_iter(out iter, new TreePath.from_string(path));
			(this.treeviewFees.model as ListStore).set_value(iter, Columns.TITLE, new_text.strip());
			this.CalculateRowTotal(iter);
			this.CalculateTotals();
			
		}
		protected void OnAmountEdited(string path, string new_text)
		{
			TreeIter iter;
			this.treeviewFees.model.get_iter(out iter, new TreePath.from_string(path));
			double amount = double.parse(new_text);
			(this.treeviewFees.model as ListStore).set_value(iter, Columns.AMOUNT, "%.2f".printf(amount));
			this.CalculateRowTotal(iter);
			this.CalculateTotals();
		}
		protected void OnTaxEdited(string path, string new_text)
		{
			TreeIter iter;
			this.treeviewFees.model.get_iter(out iter, new TreePath.from_string(path));
			double amount = double.parse(new_text);
			(this.treeviewFees.model as ListStore).set_value(iter, Columns.TAX, "%.2f".printf(amount));
			this.CalculateRowTotal(iter);
			this.CalculateTotals();
		}
		protected void OnTaxChanged(string path, TreeIter iter_new)
		{
			TreeIter iter;
			Value v_taxname, v_taxid, v_taxrate;
			
			this.cellComboRates.model.get_value(iter_new, 3, out v_taxname);
			this.cellComboRates.model.get_value(iter_new, 1, out v_taxid);
			this.cellComboRates.model.get_value(iter_new, 2, out v_taxrate);
			
			(this.treeviewFees.model as ListStore).get_iter (out iter, new Gtk.TreePath.from_string (path));
			(this.treeviewFees.model as ListStore).set(iter, 
				Columns.TAX, (string)v_taxname,
				Columns.TAX_ID, int.parse((string)v_taxid),
				Columns.TAX_RATE, (string)v_taxrate
			);
			this.CalculateRowTotal(iter);
			this.CalculateTotals();
		}
		protected void OnButtonAddClicked()
		{
			this.items++;
			
			TreeIter iter;
			(this.treeviewFees.model as ListStore).append(out iter);
			(this.treeviewFees.model as ListStore).set(iter, 
				Columns.COUNT, this.items,
				Columns.TITLE, SBText.__("<Fee name here>"),
				Columns.AMOUNT, "0.00",
				Columns.TAX,	SBText.__("-- select tax rate --")
			);
		}
		protected void OnButtonDeleteClicked()
		{
			TreeModel model;
			TreeIter iter;
			if( !this.treeviewFees.get_selection().get_selected(out model, out iter) )
				return;
			(model as ListStore).remove(iter);
			this.CalculateTotals();
		}
		protected void OnButtonCloseClicked()
		{
			//this.destroy();
		}
		public string[,] GetFees(bool clear = true)
		{
			string[,] items = new string[this.items,6];
			int i = 0;
			this.treeviewFees.model.foreach( (model, path, iter) => 
			{
				Value title, v_amount, total, tax_name, tax_id;
				model.get_value(iter, Columns.TITLE, out title);
				model.get_value(iter, Columns.AMOUNT, out v_amount);
				model.get_value(iter, Columns.TAX, out tax_name);
				model.get_value(iter, Columns.TOTAL, out total);
				model.get_value(iter, Columns.TAX_ID, out tax_id);
				
				double amount		= double.parse((string)v_amount);
				double total_amount = double.parse((string)total);
				
				items[i,0] = ((int)tax_id).to_string();
				items[i,1] = (string)title;
				items[i,2] = "%.2f".printf(amount);
				items[i,3] = ((string)tax_name).replace("wc_", "");
				items[i,4] = "%.2f".printf(total_amount - amount); // tax amount
				items[i,5] = "%.2f".printf(total_amount);
				i++;
				return false;
			});
			if( clear )
			{
				this.items = 0;
				(this.treeviewFees.model as ListStore).clear();
				this.labelTotal.label = "0.00";
			}
			
			return items;
		}
		protected void CalculateRowTotal(TreeIter iter)
		{
			Value v_amount, v_tax;
				
			this.treeviewFees.model.get_value(iter, Columns.AMOUNT, out v_amount);
			this.treeviewFees.model.get_value(iter, Columns.TAX_RATE, out v_tax);
			
			double amount 	= double.parse((string)v_amount);
			double tax		= double.parse((string)v_tax);
			
			double row_total = amount * (1 + (tax/100));
			(this.treeviewFees.model as ListStore).set_value(iter, Columns.TOTAL, "%.2f".printf(row_total));
		}
		protected void CalculateTotals()
		{
			double total = 0;
			this.treeviewFees.model.foreach( (model, path, iter) => 
			{
				Value v_amount, v_tax, v_tax_rate;
				
				model.get_value(iter, Columns.AMOUNT, out v_amount);
				model.get_value(iter, Columns.TAX, out v_tax);
				model.get_value(iter, Columns.TAX_RATE, out v_tax_rate);
				double amount 	= double.parse((string)v_amount);
				double tax		= double.parse((string)v_tax_rate);
				
				double row_total = amount * (1 + (tax/100));
				total += row_total;
				return false;
			});
			this.labelTotal.label = "%.2f".printf(total);
		}
		public double GetTotal()
		{
			double total = 0;
			this.treeviewFees.model.foreach( (model, path, iter) => 
			{
				Value amount;
				
				model.get_value(iter, Columns.TOTAL, out amount);
				total += double.parse((string)amount);
				return false;
			});
			return total;
		}
	}
}
