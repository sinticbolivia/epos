using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Database;
using SinticBolivia.Gtk;

namespace EPos
{
	public class WidgetTaxes : Box
	{
		protected 	Builder 	ui;
		protected	Box			boxTaxes;
		protected	Button		buttonNew;
		protected	Button		buttonEdit;
		protected	Button		buttonDelete;
		protected	TreeView	treeviewTaxes;
		protected	Dialog		dialogAddSave;
		protected	Label		labelTitle;
		protected	Entry		entryName;
		protected	Entry		entryRate;
		protected	int			rateId = 0;
		
		public WidgetTaxes()
		{
			//this.ui = GtkHelper.GetGladeUI("share/ui/sales-tax.glade");
			this.ui = GtkHelper.GetGladeUIFromResource((GLib.Resource)SBGlobals.GetValue("g_resource"), 
												"/net/sinticbolivia/ec-pos/ui/sales-tax.glade");
			this.boxTaxes		= (Box)this.ui.get_object("boxTaxes");
			this.buttonNew		= (Button)this.ui.get_object("buttonNew");
			this.buttonEdit		= (Button)this.ui.get_object("buttonEdit");
			this.buttonDelete	= (Button)this.ui.get_object("buttonDelete");
			this.treeviewTaxes	= (TreeView)this.ui.get_object("treeviewTaxes");
			
			this.boxTaxes.reparent(this);
			this.Build();
			this.RefreshTaxes();
			this.SetEvents();
		}
		protected void Build()
		{
			this.treeviewTaxes.model = new ListStore(4,
				typeof(int),
				typeof(string),
				typeof(string),
				typeof(int)
			);
			string[,] cols = 
			{
				{SBText.__("#"), "text", "70", "center", ""},
				{SBText.__("Name"), "text", "200", "left", ""},
				{SBText.__("Rate %"), "text", "70", "right", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewTaxes);
			//##build dialog
			this.dialogAddSave = new Dialog(){title = SBText.__("Tax rate")};
			this.dialogAddSave.modal = true;
			
			var box = new Box(Orientation.HORIZONTAL, 5);
			box.show();
			this.labelTitle = new Label(SBText.__("Add new tax rate"));
			this.labelTitle.get_style_context().add_class("widget-title");
			this.labelTitle.show();
			box.add(this.labelTitle);
			
			this.entryName = new Entry();
			this.entryName.show();
			this.entryRate = new Entry();
			this.entryRate.show();
			
			var grid = new Grid();
			grid.show();
			grid.attach(new Label(SBText.__("Tax Name:")), 0, 0, 1, 1);
			grid.attach(this.entryName, 1, 0, 1, 1);
			grid.attach(new Label(SBText.__("Tax rate:")), 0, 1, 1, 1);
			grid.attach(this.entryRate, 1, 1, 1, 1);
			
			this.dialogAddSave.get_content_area().spacing = 5;
			this.dialogAddSave.get_content_area().add(box);
			this.dialogAddSave.get_content_area().add(grid);
			
			var btn_cancel = (Button)this.dialogAddSave.add_button("_Cancel", ResponseType.CANCEL);
			var btn_save = (Button)this.dialogAddSave.add_button("_Save", ResponseType.ACCEPT);
			btn_cancel.get_style_context().add_class("button-red");
			btn_save.get_style_context().add_class("button-green");
			
			btn_cancel.clicked.connect( () => {this.dialogAddSave.hide();this.RefreshTaxes();});
			btn_save.clicked.connect(this.OnButtonSaveClicked);
		}
		protected void SetEvents()
		{
			this.buttonNew.clicked.connect(this.OnButtonNewClicked);
			this.buttonEdit.clicked.connect(this.OnButtonEditClicked);
			this.buttonDelete.clicked.connect(this.OnButtonDeleteClicked);
		}
		protected void RefreshTaxes()
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM tax_rates ORDER BY creation_date DESC";
			var rows = dbh.GetResults(query);
			TreeIter iter;
			(this.treeviewTaxes.model as ListStore).clear();
			int i = 1;
			foreach(SBDBRow row in rows)
			{
				(this.treeviewTaxes.model as ListStore).append(out iter);				
				(this.treeviewTaxes.model as ListStore).set(iter,
					 0, i, 
					 1, row.Get("name"),
					 2, "%.2f".printf(row.GetDouble("rate")),
					 3, row.GetInt("tax_id")
				);
				i++;
			}
		}
		protected void OnButtonNewClicked()
		{
			this.entryName.text = "";
			this.entryRate.text = "";
			this.rateId = 0;
			this.entryName.grab_focus();
			this.dialogAddSave.show_all();
		}
		protected void OnButtonEditClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewTaxes.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			Value v_tax_id;
			model.get_value(iter, 3, out v_tax_id);
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM tax_rates WHERE tax_id = %d".printf((int)v_tax_id);
			var row = dbh.GetRow(query);
			if( row == null )
				return;
			
			this.entryName.text = row.Get("name");
			this.entryRate.text	= "%.2f".printf(row.GetDouble("rate"));
			
			this.rateId = row.GetInt("tax_id");
			this.dialogAddSave.show_all();
		}
		protected void OnButtonDeleteClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewTaxes.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			Value v_tax_id;
			model.get_value(iter, 3, out v_tax_id);
			var confirm = new MessageDialog(null, DialogFlags.MODAL, MessageType.QUESTION, ButtonsType.YES_NO, 
				SBText.__("Are you sure to delete the tax rate?")
			);
			confirm.title = SBText.__("Tax rate deletion");
			if(confirm.run() == ResponseType.YES)
			{
				var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
				string query = "DELETE FROM tax_rates WHERE tax_id = %d".printf((int)v_tax_id);
				dbh.Execute(query);
			}
			confirm.destroy();
			this.RefreshTaxes();
		}
		protected void OnButtonSaveClicked()
		{
			string name = this.entryName.text.strip();
			string rate = this.entryRate.text.strip();
			double rate_val = 0;
			
			if( name.length <= 0 )
			{
				this.entryName.grab_focus();
				return;
			}
			if( rate.length <= 0 )
			{
				this.entryRate.grab_focus();
				return;
			}
			if( !double.try_parse(rate, out rate_val) )
			{
				this.entryRate.grab_focus();
				return;
			}
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string cdate = new DateTime.now_local().format("%Y-%m-%d %H:%M:%S");
			
			var data = new HashMap<string, Value?>();
			data.set("name", name);
			data.set("rate", rate_val);
			data.set("last_modification_date", cdate);
			if( this.rateId <= 0 )
			{
				//##add new tax rate
				data.set("creation_date", cdate);
				dbh.Insert("tax_rates", data);
			}
			else
			{
				//##update tax rate
				var w = new HashMap<string, Value?>();
				w.set("tax_id", this.rateId);
				dbh.Update("tax_rates", data, w);
			}
			this.rateId = 0;
			this.dialogAddSave.hide();
			this.RefreshTaxes();
		}
	}
}
