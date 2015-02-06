using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace Woocommerce
{
	public class WidgetProductDepartments : Box
	{
		protected	Builder			ui;
		protected	Box				boxDepartments;
		protected	Image			image1;
		protected	Button			buttonNew;
		protected	Button			buttonEdit;
		protected	Button			buttonDelete;
		protected	ScrolledWindow	scrolledwindow1;
		protected	DbTableTreeView	treeview;
		
		protected	Dialog			dlg;
		protected	Entry			entryName;
		protected	Entry			entryDescription;
		protected	Button			buttonCancel;
		protected	Button			buttonSave;
		protected	int				depId = 0;
			
		public WidgetProductDepartments()
		{
			this.ui				= (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("departments.glade");
			this.boxDepartments	= (Box)this.ui.get_object("boxDepartments");
			this.image1			= (Image)this.ui.get_object("image1");
			this.buttonNew		= (Button)this.ui.get_object("buttonNew");
			this.buttonEdit		= (Button)this.ui.get_object("buttonEdit");
			this.buttonDelete	= (Button)this.ui.get_object("buttonDelete");
			this.scrolledwindow1	= (ScrolledWindow)this.ui.get_object("scrolledwindow1");
			this.Build();
			this.boxDepartments.reparent(this);
			this.SetEvents();
			this.Refresh();
		}
		protected void Build()
		{
			this.treeview = new DbTableTreeView("departments", 
				{"department_id => ID", "name => Department", "description => Description", "creation_date => Created at"}, 
				(SBGlobals.GetVar("dbh") as SBDatabase)
			)
			{
				expand = true,
				rules_hint = true
			};
			
			this.treeview.show();
			this.scrolledwindow1.add(this.treeview);
			this.dlg = new Dialog();
			this.dlg.modal = true;
			var box = new Box(Orientation.VERTICAL, 5);
			this.entryName = new Entry();	
			this.entryDescription = new Entry();
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
		}
		protected void Refresh()
		{
			this.treeview.Bind();
		}
		protected void SetEvents()
		{
			this.buttonNew.clicked.connect(this.OnButtonNewClicked);
			this.buttonEdit.clicked.connect(this.OnButtonEditClicked);
			this.buttonDelete.clicked.connect(this.OnButtonDeleteClicked);
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
			this.buttonSave.clicked.connect(this.OnButtonSaveClicked);
		}
		protected void OnButtonNewClicked()
		{
			this.depId = 0;
			this.entryName.text = "";
			this.entryDescription.text = "";
			this.dlg.show();
		}
		protected void OnButtonEditClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeview.get_selection().get_selected(out model, out iter) )
				return;
				
			Value v_id;
			model.get_value(iter, 1, out v_id);
			this.depId = int.parse((string)v_id);
			
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("departments").Where("department_id = %d".printf(this.depId));
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
			
			if( !this.treeview.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			var confirm = new InfoDialog()
			{
				Title 	= SBText.__("Confirm deletion"),
				Message	= SBText.__("Are you sure to delete the product department?")
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
			w.set("department_id", int.parse((string)v_id));
			dbh.Delete("departments", w);
			var msg = new InfoDialog()
			{
				Title	= SBText.__("Product Department Deleted"),
				Message	= SBText.__("The product department has been deleted.")
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
			if( this.depId <= 0 )
			{
				data.set("creation_date", cdate);
				dbh.Insert("departments", data);
				msg = SBText.__("The product department has been added.");
			}
			else
			{
				msg = SBText.__("The product department has been updated.");
				var w = new HashMap<string, Value?>();
				w.set("department_id", this.depId);
				dbh.Update("departments", data, w);
			}
			var dmsg = new InfoDialog(){
				Title = SBText.__("Product Department"),
				Message = msg
			};
			dmsg.run();
			dmsg.destroy();
			this.dlg.hide();
			this.depId = 0;
			this.Refresh();
		}
	}
}
