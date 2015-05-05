using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Database;
using SinticBolivia.Gtk;

namespace EPos
{
	public class WidgetTransactionTypes : Box
	{
		protected	Builder		ui;
		protected	Box			boxTransactionTypes;
		protected	Image		image1;
		protected	Label		labelTitle;
		protected	Button		buttonNew;
		protected	Button		buttonEdit;
		protected	Button		buttonDelete;
		protected	TreeView	treeview1;
		//dialog objects
		protected	Dialog		dlg;
		protected	Entry		entryKey;
		protected	Entry		entryName;
		protected	ComboBox	comboboxType;
		protected	Button		buttonCancel;
		protected	Button		buttonSave;
		protected	int			ttId = -1;
		
		public WidgetTransactionTypes()
		{
			this.ui 			= (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("transaction-types.glade");
			this.boxTransactionTypes	= (Box)this.ui.get_object("boxTransactionTypes");
			this.image1			= (Image)this.ui.get_object("image1");
			this.labelTitle		= (Label)this.ui.get_object("labelTitle");
			this.buttonNew		= (Button)this.ui.get_object("buttonNew");
			this.buttonEdit		= (Button)this.ui.get_object("buttonEdit");
			this.buttonDelete	= (Button)this.ui.get_object("buttonDelete");
			this.treeview1		= (TreeView)this.ui.get_object("treeview1");
			this.Build();
			this.Refresh();
			this.SetEvents();
			
			this.boxTransactionTypes.reparent(this);
		}
		protected void Build()
		{
			this.image1.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("icon_transaction_type-64x64.png");
			this.treeview1.model = new ListStore(5, 
				typeof(int),
				typeof(string),
				typeof(string),
				typeof(string),
				typeof(int)
			);
			string[,] cols = 
			{
				{SBText.__("#"), "text", "60", "center", "", ""},
				{SBText.__("Key"), "text", "80", "center", "", ""},
				{SBText.__("Name"), "text", "200", "left", "", ""},
				{SBText.__("Type"), "text", "60", "center", "", ""},
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeview1);
			this.BuildDialog();
		}
		protected void BuildDialog()
		{
			this.dlg = new Dialog();
			this.dlg.get_style_context().add_class("widget-container");
			this.dlg.modal = true;
			this.dlg.title = "";
			this.dlg.decorated = false;
			this.dlg.get_content_area().get_style_context().add_class("box-widget");
			
			var title = new Label(SBText.__("Transaction Type"));
			title.get_style_context().add_class("title");
			this.dlg.get_content_area().add(title);
			
			this.entryKey = new Entry();
			this.entryKey.show();
			this.entryName = new Entry();
			this.entryName.show();
			this.comboboxType = new ComboBox();
			this.comboboxType.show();
			this.comboboxType.model = new ListStore(2, typeof(string), typeof(string));
			var cell = new CellRendererText();
			this.comboboxType.pack_start(cell, true);
			this.comboboxType.set_attributes(cell, "text", 0);
			this.comboboxType.id_column = 1;
			TreeIter iter;
			(this.comboboxType.model as ListStore).append(out iter);
			(this.comboboxType.model as ListStore).set(iter, 0, SBText.__("-- type --"), 1, "-1");
			(this.comboboxType.model as ListStore).append(out iter);
			(this.comboboxType.model as ListStore).set(iter, 0, SBText.__("Input"), 1, "IN");
			(this.comboboxType.model as ListStore).append(out iter);
			(this.comboboxType.model as ListStore).set(iter, 0, SBText.__("Output"), 1, "OUT");
			this.dlg.get_content_area().add(new Label(SBText.__("Key:")){xalign=0});
			this.dlg.get_content_area().add(this.entryKey);
			this.dlg.get_content_area().add(new Label(SBText.__("Name:")){xalign=0});
			this.dlg.get_content_area().add(this.entryName);
			this.dlg.get_content_area().add(new Label(SBText.__("Type:")){xalign=0});
			this.dlg.get_content_area().add(this.comboboxType);
			
			this.buttonCancel = (Button)this.dlg.add_button(SBText.__("Cancel"), ResponseType.CANCEL);
			this.buttonSave = (Button)this.dlg.add_button(SBText.__("Save"), ResponseType.OK);
			this.buttonCancel.get_style_context().add_class("button-red");
			this.buttonSave.get_style_context().add_class("button-green");
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
			this.buttonSave.clicked.connect(this.OnButtonSaveClicked);
		}
		protected void SetEvents()
		{
			this.buttonNew.clicked.connect(this.OnButtonNewClicked);
			this.buttonEdit.clicked.connect(this.OnButtonEditClicked);
			this.buttonDelete.clicked.connect(this.OnButtonDeleteClicked);
		}
		protected void Refresh()
		{
			(this.treeview1.model as ListStore).clear();
			
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM transaction_types ORDER BY transaction_name ASC";
			var rows = dbh.GetResults(query);
			TreeIter iter;
			int i = 1;
			foreach(SBDBRow row in rows)
			{
				(this.treeview1.model as ListStore).append(out iter);
				(this.treeview1.model as ListStore).set(iter, 
					0, i,
					1, row.Get("transaction_key"),
					2, row.Get("transaction_name"),
					3, row.Get("in_out").up(),
					4, row.GetInt("transaction_type_id")
				);
				i++;
			}
			
		}
		protected void OnButtonNewClicked()
		{
			this.comboboxType.active_id = "-1";
			this.dlg.show_all();
			this.entryKey.grab_focus();
			
		}
		protected void OnButtonEditClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeview1.get_selection().get_selected(out model, out iter) )
				return;
			Value v_id;
			model.get_value(iter, 4, out v_id);
			this.ttId = (int)v_id;	
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM transaction_types where transaction_type_id = %d".printf(this.ttId);
			var row = dbh.GetRow(query);
			if(row == null)
				return;
			this.entryName.text = row.Get("transaction_name");
			this.entryKey.text = row.Get("transaction_key");
			this.comboboxType.active_id = row.Get("in_out").up();
			this.dlg.show_all();
			this.entryKey.grab_focus();
			
		}
		protected void OnButtonDeleteClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeview1.get_selection().get_selected(out model, out iter) )
				return;
			Value v_id;
			model.get_value(iter, 4, out v_id);
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "DELETE FROM transaction_types where transaction_type_id = %d".printf((int)v_id);
			dbh.Execute(query);
			this.Refresh();
		}
		protected void OnButtonCancelClicked()
		{
			this.entryKey.text = "";
			this.entryName.text = "";
			this.comboboxType.active_id = "-1";
			this.dlg.hide();
		}
		protected void OnButtonSaveClicked()
		{
			string key = this.entryKey.text.strip();
			string name = this.entryName.text.strip();
			if( key.length <= 0 )
			{
				this.entryKey.grab_focus();
				return;
			}
			if( name.length <= 0 )
			{
				this.entryName.grab_focus();
				return;
			}
			if( this.comboboxType.active_id == null || this.comboboxType.active_id == "-1" )
			{
				this.comboboxType.grab_focus();
				return;
			}
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string cdate = new DateTime.now_local().format("%Y-%m-%d %H:%M:%S");
			var data = new HashMap<string, Value?>();
			data.set("transaction_key", key.up());
			data.set("transaction_name", name);
			data.set("in_out", this.comboboxType.active_id);
			data.set("last_modification_date", cdate);
			if( this.ttId > 0 )
			{
				var w = new HashMap<string, Value?>();
				w.set("transaction_type_id", this.ttId);
				dbh.Update("transaction_types", data, w);
			}
			else
			{
				data.set("creation_date", cdate);
				dbh.Insert("transaction_types", data);
			}
			GLib.Signal.emit_by_name(this.buttonCancel, "clicked");
			this.Refresh();
		}
	}
}
