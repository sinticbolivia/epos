using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Database;
using SinticBolivia.Gtk;

namespace EPos
{
	public class WidgetPaymentMethods : Box
	{
		protected 	Builder			ui;
		protected	Box				boxPaymentMethods;
		protected	Image			image1;
		protected	Button			buttonAdd;
		protected	Button			buttonEdit;
		protected	Button			buttonDelete;
		protected	ScrolledWindow	scrolledwindow1;	
		protected	DbTableTreeView	treeview;
		
		protected	Dialog			dlg;
		protected	Entry			entryName;
		protected	Entry			entryCode;
		protected	Button			buttonCancel;
		protected	Button			buttonSave;
		protected	int				pmId = 0;
		
		public WidgetPaymentMethods()
		{
			this.ui						= (SBModules.GetModule("Pos") as SBGtkModule).GetGladeUi("payment-methods.glade");
			this.boxPaymentMethods		= (Box)this.ui.get_object("boxPaymentMethods");
			this.image1					= (Image)this.ui.get_object("image1");
			this.buttonAdd				= (Button)this.ui.get_object("buttonAdd");
			this.buttonEdit				= (Button)this.ui.get_object("buttonEdit");
			this.buttonDelete			= (Button)this.ui.get_object("buttonDelete");
			this.scrolledwindow1		= (ScrolledWindow)this.ui.get_object("scrolledwindow1");
			this.treeview				= new DbTableTreeView(
				"payment_methods",
				{"method_id => ID", "code => Code", "name => Name"},
				(SBGlobals.GetVar("dbh") as SBDatabase)
			)
			{
				expand = true,
				rules_hint = true
			};
			this.treeview.show();
			this.scrolledwindow1.add(this.treeview);
			this.dlg		= new Dialog();
			this.entryCode				= new Entry();
			this.entryName				= new Entry();
			this.buttonCancel			= (Button)this.dlg.add_button(SBText.__("Cancel"), ResponseType.CANCEL);
			this.buttonSave				= (Button)this.dlg.add_button(SBText.__("Save"), ResponseType.OK);
			this.buttonCancel.get_style_context().add_class("button-red");
			this.buttonSave.get_style_context().add_class("button-green");
			this.boxPaymentMethods.reparent(this);
			this.Build();
			this.Refresh();
			this.SetEvents();
		}
		protected void Build()
		{
			this.dlg.get_content_area().add(new Label(SBText.__("Code")));
			this.dlg.get_content_area().add(this.entryCode);
			this.dlg.get_content_area().add(new Label(SBText.__("Name")));
			this.dlg.get_content_area().add(this.entryName);
			this.dlg.get_content_area().show_all();
			this.entryCode.show();
			this.entryName.show();
		}
		protected void SetEvents()
		{
			this.buttonAdd.clicked.connect(this.OnButtonAddClicked);
			this.buttonEdit.clicked.connect(this.OnButtonEditClicked);
			this.buttonDelete.clicked.connect(this.OnButtonDeleteClicked);
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
			this.buttonSave.clicked.connect(this.OnButtonSaveClicked);
		}
		protected void Refresh()
		{
			this.treeview.Bind();
		}
		protected void OnButtonAddClicked()
		{
			this.entryCode.text = "";
			this.entryName.text = "";
			this.dlg.show();
			this.entryCode.grab_focus();
			this.pmId = 0;
		}
		protected void OnButtonEditClicked()
		{
			TreeModel 	model;
			TreeIter	iter;
			
			if( !this.treeview.get_selection().get_selected(out model, out iter) )
				return;
			Value id;
			model.get_value(iter, 1, out id);
			this.pmId = int.parse((string)id);
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("payment_methods").Where("method_id = %d".printf(this.pmId));
			var row = dbh.GetRow(null);
			if( row == null )
				return;
			this.entryCode.text = row.Get("code");
			this.entryName.text	= row.Get("name");
			this.entryCode.grab_focus();
			this.dlg.show();
		}
		protected void OnButtonDeleteClicked()
		{
			TreeModel 	model;
			TreeIter	iter;
			
			if( !this.treeview.get_selection().get_selected(out model, out iter) )
				return;
			var confirm = new InfoDialog()
			{
				Title = SBText.__("Payment method deletion"),
				Message = SBText.__("Are you sure to delete the payment method")
			};
			var btn = confirm.add_button(SBText.__("Yes"), ResponseType.YES);
			btn.get_style_context().add_class("button-green");
			
			if( confirm.run() == ResponseType.YES )
			{
				Value vid;
				model.get_value(iter, 1, out vid);
				int id = int.parse((string)vid);
				
				var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
				var w = new HashMap<string, Value?>();
				w.set("method_id", id);
				dbh.Delete("payment_methods", w);
			}
			confirm.destroy();
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
			if( code.length <= 0 )
			{
				return;
			}
			if( name.length <= 0 )
				return;
			string msg = "";
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var data = new HashMap<string, Value?>();
			data.set("name", name);
			data.set("code", code);
			
			if( this.pmId <= 0 )
			{
				data.set("creation_date", new DateTime.now_local().format("%Y-%m-%d %H:%M:%s"));
				dbh.Insert("payment_methods", data);
				msg = SBText.__("The payment method has been created.");
			}
			else
			{
				var w = new HashMap<string, Value?>();
				w.set("method_id", this.pmId);
				dbh.Update("payment_methods", data, w);
				msg = SBText.__("The payment method has been updated.");
			}
			var dmsg = new InfoDialog()
			{
				Title = SBText.__("Payment method"),
				Message	= msg
			};
			dmsg.run();
			dmsg.destroy();
			this.pmId = 0;
			this.dlg.hide();
			this.Refresh();
		}
	}
}
