using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;
//using SinticBolivia.Utils;

namespace EPos
{
	public class WidgetUnitOfMeasurement : Box
	{
		protected	Builder 		ui;
		protected	Box				boxUm;
		protected	Image			image1;
		protected	Button			buttonNew;
		protected	Button			buttonEdit;
		protected	Button			buttonDelete;
		protected	TreeView		treeview1;
		//##add/edit measurement dialog
		protected	Dialog			dlg;
		protected	Entry			entryCode;
		protected	Entry			entryName;
		protected	Entry			entryQty;
		protected	Button			buttonSave;
		protected	Button			buttonCancel;
		protected	int				theId = 0;
		
		public WidgetUnitOfMeasurement()
		{
			this.ui				= (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("unit-measurement.glade");
			this.boxUm			= (Box)this.ui.get_object("boxUm");
			this.image1			= (Image)this.ui.get_object("image1");
			this.buttonNew		= (Button)this.ui.get_object("buttonNew");
			this.buttonEdit		= (Button)this.ui.get_object("buttonEdit");
			this.buttonDelete	= (Button)this.ui.get_object("buttonDelete");
			this.treeview1		= (TreeView)this.ui.get_object("treeview1");
			
			this.Build();
			this.Refresh();
			this.SetEvents();
			this.boxUm.reparent(this);
			
		}
		protected void Build()
		{
			this.image1.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("unit-measure-64x64.png");
			this.treeview1.model = new ListStore(5, 
				typeof(int),
				typeof(string),
				typeof(string),
				typeof(int),
				typeof(int)
			);
			string[,] cols = 
			{
				{SBText.__("#"), "text", "80", "center", "", ""},
				{SBText.__("Code"), "text", "80", "left", "", ""},
				{SBText.__("Name"), "text", "250", "left", "", ""},
				{SBText.__("Quantity"), "text", "80", "center", "", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeview1);
			this.treeview1.rules_hint = true;
			//##build add/edit dialog
			this.dlg = new Dialog();
			this.entryCode = new Entry();
			this.entryName	= new Entry();
			this.entryQty	= new Entry();
			//var box = new Box(Orientation.VERTICAL, 5);
			//box.get_style_context("");
			var grid = new Grid(){row_spacing = 5, column_spacing = 5};
			grid.attach(new Label(SBText.__("Code:")), 0, 0, 1, 1);
			grid.attach(this.entryCode, 1, 0, 1, 1);
			grid.attach(new Label(SBText.__("Name:")), 0, 1, 1, 1);
			grid.attach(this.entryName, 1, 1, 1, 1);
			grid.attach(new Label(SBText.__("Quantity:")), 0, 2, 1, 1);
			grid.attach(this.entryQty, 1, 2, 1, 1);
			grid.show_all();
			
			dlg.get_content_area().add(grid);
			this.buttonCancel 	= (Button)dlg.add_button(SBText.__("Cancel"), ResponseType.CLOSE);
			this.buttonSave		= (Button)dlg.add_button(SBText.__("Save"), ResponseType.OK);
		}
		protected void SetEvents()
		{
			this.buttonNew.clicked.connect(this.OnButtonNewClicked);
			this.buttonEdit.clicked.connect(this.OnButtonEditClicked);
			this.buttonDelete.clicked.connect(this.OnButtonDeleteClicked);
			this.buttonSave.clicked.connect(this.OnButtonSaveClicked);
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
		}
		protected void Refresh()
		{
			(this.treeview1.model as ListStore).clear();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("unit_measures").OrderBy("name");
			
			TreeIter iter;
			int i = 1;
			foreach(var row in dbh.GetResults(null))
			{
				(this.treeview1.model as ListStore).append(out iter);
				(this.treeview1.model as ListStore).set(iter, 
					0, i,
					1, row.Get("code"),
					2, row.Get("name"),
					3, row.GetInt("quantity"),
					4, row.GetInt("measure_id")
				);
				i++;
			}
		}
		protected void OnButtonNewClicked()
		{
			this.theId = 0;
			this.dlg.modal = true;
			this.dlg.show();
			this.entryCode.text = "";
			this.entryName.text = "";
			this.entryQty.text	= "";
			this.entryCode.grab_focus();
		}
		protected void OnButtonEditClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeview1.get_selection().get_selected(out model, out iter) )
				return;
				
			Value v_id;
			model.get_value(iter, 4, out v_id);
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("unit_measures").Where("measure_id = %d".printf((int)v_id));
			var row = dbh.GetRow(null); 
			if( row == null )
			 return;
			 
			this.theId = row.GetInt("measure_id");
						
			this.entryCode.text = row.Get("code");
			this.entryName.text = row.Get("name");
			this.entryQty.text	= row.Get("quantity");
			
			this.entryCode.grab_focus();
			this.dlg.modal = true;
			this.dlg.show();
		}
		protected void OnButtonDeleteClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeview1.get_selection().get_selected(out model, out iter) )
				return;
			
			var msg = new InfoDialog()
			{
				Title 	= SBText.__("Delete"),
				Message = SBText.__("Are you sure to delete the unit of measure?")
			};
			var btn = (Button)msg.add_button(SBText.__("Confirm"), ResponseType.OK);
			btn.get_style_context().add_class("button-green");
			if( msg.run() == ResponseType.OK )
			{
				Value v_id;
				model.get_value(iter, 4, out v_id);
				var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
				var w = new HashMap<string, Value?>();
				w.set("measure_id", (int)v_id);
				dbh.Delete("unit_measures", w);
			}
			msg.destroy();
			this.Refresh();
			
		}
		protected void OnButtonCancelClicked()
		{
			this.dlg.hide();
		}
		protected void OnButtonSaveClicked()
		{
			string code = this.entryCode.text.strip();
			string name = this.entryName.text.strip();
			string qty = this.entryQty.text.strip();
			string cdate = new DateTime.now_local().format("%Y-%m-%d %H:%M:%S");
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var data = new HashMap<string, Value?>();
			data.set("name", name);
			data.set("code", code);
			data.set("quantity", int.parse(qty));
			data.set("last_modification_date", cdate);
			string msg = "";
			if( this.theId <= 0 )
			{
				data.set("creation_date", cdate);
				
				long id = dbh.Insert("unit_measures", data);
				msg = SBText.__("New unit of measurement has been added.");
			}
			else
			{
				var w = new HashMap<string, Value?>();
				w.set("measure_id", this.theId);
				dbh.Update("unit_measures", data, w);
				msg = SBText.__("The unit of measurement has been updated.");
			}
			var dmsg = new InfoDialog()
			{
				Title = SBText.__("Unit of measurement"),
				Message = msg
			};
			dmsg.run();
			dmsg.destroy();
			this.theId = 0;
			this.dlg.hide();
			this.Refresh();
		}
	}
}
