using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace Woocommerce
{
	public class WidgetProductLines : Box
	{
		protected	Builder 		ui;
		protected	Box				box1;
		protected	Image			image1;
		protected	Button			buttonNew;
		protected	Button			buttonEdit;
		protected	Button			buttonDelete;
		protected	ScrolledWindow	scrolledwindow1;
		protected	DbTableTreeView	tv;
		protected	Dialog			dlg;
		protected	Entry			entryName;
		protected	Entry			entryDescription;
		protected	Button			buttonCancel;
		protected	Button			buttonSave;
		protected	int				lineId = 0;
		
		public WidgetProductLines()
		{
			this.ui					= (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("product-lines.glade");
			this.box1				= (Box)this.ui.get_object("box1");
			this.scrolledwindow1	= (ScrolledWindow)this.ui.get_object("scrolledwindow1");
			this.buttonNew			= (Button)this.ui.get_object("buttonNew");
			this.buttonEdit			= (Button)this.ui.get_object("buttonEdit");
			this.buttonDelete		= (Button)this.ui.get_object("buttonDelete");
			this.box1.reparent(this);
			this.Build();
			this.Refresh();
			this.SetEvents();
		}
		protected void Build()
		{
			this.tv = new DbTableTreeView("lines",
				{"line_id => ID", "name => Line", "description => Description", "creation_date => Created at"},
				(SBGlobals.GetVar("dbh") as SBDatabase)
			);
			this.tv.expand 		= true;
			this.tv.rules_hint 	= true;
			this.tv.show();
			
			this.scrolledwindow1.add(this.tv);
			
			//##build add/edit dialog
			this.entryName	= new Entry();
			//this.entryName.show();
			this.entryDescription	= new Entry();
			//this.entryDescription.show();
			this.dlg = new Dialog();
			this.dlg.modal = true;
			var box = new Box(Orientation.VERTICAL, 5);
		
			box.add(new Label(SBText.__("Name:")));
			box.add(this.entryName);
			box.add(new Label(SBText.__("Description:")));
			box.add(this.entryDescription);
			box.show_all();
			this.buttonCancel 	= (Button)this.dlg.add_button(SBText.__("Cancel"), ResponseType.CANCEL);
			this.buttonSave 	= (Button)this.dlg.add_button(SBText.__("Save"), ResponseType.OK);
			this.buttonCancel.get_style_context().add_class("button-red");
			this.buttonSave.get_style_context().add_class("button-green");
			this.dlg.get_content_area().add(box);
			//this.dlg.hide();
		}
		protected void SetEvents()
		{
			this.buttonNew.clicked.connect(this.OnButtonNewClicked);
			this.buttonEdit.clicked.connect(this.OnButtonEditClicked);
			this.buttonDelete.clicked.connect(this.OnButtonDeleteClicked);
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
			this.buttonSave.clicked.connect(this.OnButtonSaveClicked);
		}
		protected void Refresh()
		{
			this.tv.Bind();
		}
		protected void OnButtonNewClicked()
		{
			this.lineId = 0;
			this.entryName.text = "";
			this.entryDescription.text = "";
			this.dlg.show();
		}
		protected void OnButtonEditClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.tv.get_selection().get_selected(out model, out iter) )
				return;
			Value v_id;
			model.get_value(iter, 1, out v_id);
			this.lineId = int.parse((string)v_id);
			
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("lines").Where("line_id = %d".printf(this.lineId));
			var row = dbh.GetRow(null);
			if( row == null )
				return;
			
			this.entryName.text = row.Get("name");
			this.entryDescription.text = row.Get("description");
			this.dlg.show();
		}
		protected void OnButtonDeleteClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.tv.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			var confirm = new InfoDialog()
			{
				Title 	= SBText.__("Confirm deletion"),
				Message	= SBText.__("Are you sure to delete the product line?")
			};
			var btn = confirm.add_button(SBText.__("Yes"), ResponseType.OK);
			btn.get_style_context().add_class("button-green");
			
			if( confirm.run() != ResponseType.OK )
			{
				confirm.destroy();
				return;
			}
			confirm.destroy();
			
			Value v_id;
			
			model.get_value(iter, 1, out v_id);
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var w = new HashMap<string, Value?>();
			w.set("line_id", int.parse((string)v_id));
			dbh.Delete("lines", w);
			var msg = new InfoDialog()
			{
				Title	= SBText.__("Product Line Deleted"),
				Message	= SBText.__("The product line has been deleted.")
			};
			msg.run();
			msg.destroy();
			this.Refresh();
		}
		protected void OnButtonCancelClicked()
		{
			this.dlg.hide();
		}
		protected void OnButtonSaveClicked()
		{
			string name = this.entryName.text.strip();
			string desc = this.entryDescription.text.strip();
			if( name.length <= 0 )
			{
				this.entryName.grab_focus();
				return;
			}
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string cdate = new DateTime.now_local().format("%Y-%m-%d %H:%I:%S");
			string msg = "";
			var data = new HashMap<string, Value?>();
			data.set("name", name);
			data.set("description", desc);
			data.set("store_id", 0);
			data.set("last_modification_date", cdate);
			if( this.lineId <= 0 )
			{
				data.set("creation_date", cdate);
				dbh.Insert("lines", data);
				msg = SBText.__("The product line has been added.");
			}
			else
			{
				msg = SBText.__("The product line has been updated.");
				var w = new HashMap<string, Value?>();
				w.set("line_id", this.lineId);
				dbh.Update("lines", data, w);
			}
			var dmsg = new InfoDialog(){
				Title = SBText.__("Product Line"),
				Message = msg
			};
			dmsg.run();
			dmsg.destroy();
			this.dlg.hide();
			this.lineId = 0;
			this.Refresh();
		}
	}
}
