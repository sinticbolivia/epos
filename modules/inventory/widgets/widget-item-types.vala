using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetItemTypes : Box
	{
		protected	Builder			ui;
		protected	Box				boxItemTypes;
		protected	Image			image1;
		protected	Button			buttonAdd;
		protected	Button			buttonEdit;
		protected	Button			buttonDelete;
		protected	ScrolledWindow	scrolledwindow1;
		protected	DbTableTreeView		treeview;
		protected	Dialog				dlg;
		protected	Entry				entryCode;
		protected	Entry				entryName;
		protected	Button				buttonCancel;
		protected	Button				buttonSave;
		protected	int					itemTypeId = 0;
		
		public WidgetItemTypes()
		{
			this.ui				= (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("item-types.glade");
			this.boxItemTypes	= (Box)this.ui.get_object("boxItemTypes");
			this.image1			= (Image)this.ui.get_object("image1");
			this.buttonAdd		= (Button)this.ui.get_object("buttonAdd");
			this.buttonEdit		= (Button)this.ui.get_object("buttonEdit");
			this.buttonDelete	= (Button)this.ui.get_object("buttonDelete");
			this.scrolledwindow1	= (ScrolledWindow)this.ui.get_object("scrolledwindow1");
			this.boxItemTypes.reparent(this);
			this.dlg 			= new Dialog();
			this.entryCode		= new Entry();
			this.entryName		= new Entry();
			this.buttonCancel	= (Button)this.dlg.add_button(SBText.__("Cancel"), ResponseType.CANCEL);
			this.buttonSave		= (Button)this.dlg.add_button(SBText.__("Save"), ResponseType.OK);
			this.buttonCancel.get_style_context().add_class("button-red");
			this.buttonSave.get_style_context().add_class("button-green");
			this.Build();
			this.Refresh();
			this.SetEvents();
		}
		protected void Build()
		{
			this.treeview = new DbTableTreeView("item_types", 
				{"item_type_id => ID", "code => Code", "name => Type", "creation_date => Created At"},
				(SBGlobals.GetVar("dbh") as SBDatabase)
			)
			{
				expand = true,
				rules_hint = true
			};
			this.treeview.show();
			this.scrolledwindow1.add(this.treeview);
			var box = new Box(Orientation.VERTICAL, 5);
			box.add(new Label(SBText.__("Code:")));
			box.add(this.entryCode);
			box.add(new Label(SBText.__("Name:")));
			box.add(this.entryName);
			box.show_all();
			this.dlg.get_content_area().add(box);
		}
		protected void SetEvents()
		{
			this.buttonAdd.clicked.connect(this.OnButtonAddClicked);
			this.buttonEdit.clicked.connect(this.OnButtonEditClicked);
			this.buttonDelete.clicked.connect(this.OnButtonDeleteClicked);
			this.buttonSave.clicked.connect(this.OnButtonSaveClicked);
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
		}
		protected void Refresh()
		{
			this.treeview.Bind();
		}
		protected void OnButtonAddClicked()
		{
			this.itemTypeId = 0;
			this.entryCode.text = "";
			this.entryName.text = "";
			this.entryCode.grab_focus();
			this.dlg.show();
		}
		protected void OnButtonEditClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeview.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			Value id;
			model.get_value(iter, 1, out id);
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("item_types").Where("item_type_id = %s".printf((string)id));
			var row = dbh.GetRow(null);
			if( row == null )
				return;
			this.itemTypeId = row.GetInt("item_type_id");
			this.entryCode.text = row.Get("code");
			this.entryName.text = row.Get("name");
			this.dlg.show();
			this.entryCode.grab_focus();
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
				Title = SBText.__("Confirm deletion"),
				Message = SBText.__("Are you sure to delete the item type?")
			};
			var btn = confirm.add_button(SBText.__("Yes"), ResponseType.OK);
			btn.get_style_context().add_class("button-green");
			if( confirm.run() == ResponseType.OK )
			{
				Value id;
				model.get_value(iter, 1, out id);
				var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
				var _w = new HashMap<string, Value?>();
				_w.set("item_type_id", int.parse((string)id));
				dbh.Delete("item_types", _w);
				this.Refresh();
			}
			confirm.destroy();
		}
		protected void OnButtonCancelClicked()
		{
			this.itemTypeId = 0;
			this.dlg.hide();
		}
		protected void OnButtonSaveClicked()
		{
			string code = this.entryCode.text.strip();
			string name = this.entryName.text.strip();
			
			if( code.length <= 0 )
			{
				this.entryCode.grab_focus();
				return;
			}
			if( name.length <= 0 )
			{
				this.entryName.grab_focus();
				return;
			}
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var data = new HashMap<string, Value?>();
			data.set("code", code);
			data.set("name", name);
			
			if( this.itemTypeId <= 0 )
			{
				data.set("creation_date", new DateTime.now_local().format("%Y-%m-%d %H:%M:%S"));
				dbh.Insert("item_types", data);
			}
			else
			{
				var _w = new HashMap<string, Value?>();
				_w.set("item_type_id", this.itemTypeId);
				dbh.Update("item_types", data, _w);
			}
			this.itemTypeId = 0;
			this.dlg.hide();
			this.Refresh();
		}
	}
}
