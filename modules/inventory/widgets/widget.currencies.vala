using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetCurrencies : Box
	{
		protected	Builder			ui;
		protected	Box				boxCurrencies;
		protected	Image			image1;
		protected	Button			buttonAdd;
		protected	Button			buttonEdit;
		protected	Button			buttonDelete;
		protected	ScrolledWindow	scrolledwindow1;
		protected	DbTableTreeView	treeview;
		protected	Dialog			dlg;
		protected	Entry			entryCode;
		protected	Entry			entryName;
		protected	Entry			entryRate;
		protected	Button			buttonSave;
		protected	Button			buttonCancel;
		protected	int				currencyId = 0;
		
		public WidgetCurrencies()
		{
			this.ui				= (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("currencies.glade");
			this.boxCurrencies	= (Box)this.ui.get_object("boxCurrencies");
			this.image1			= (Image)this.ui.get_object("image1");
			this.buttonAdd		= (Button)this.ui.get_object("buttonAdd");
			this.buttonEdit		= (Button)this.ui.get_object("buttonEdit");
			this.buttonDelete	= (Button)this.ui.get_object("buttonDelete");
			this.scrolledwindow1	= (ScrolledWindow)this.ui.get_object("scrolledwindow1");
			this.treeview			= new DbTableTreeView("currencies",
				{"currency_id => ID", "code => Code", "name => Name", "rate => Rate %"},
				(SBGlobals.GetVar("dbh") as SBDatabase)
			)
			{
				rules_hint = true,
				expand = true
			};
			this.treeview.show();
			this.scrolledwindow1.add(this.treeview);
			this.dlg				= new Dialog();
			this.entryCode			= new Entry();
			this.entryName			= new Entry();
			this.entryRate			= new Entry();
			
			this.Build();
			this.boxCurrencies.reparent(this);
			this.Refresh();
			this.SetEvents();
		}
		protected void Build()
		{
			this.image1.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("currencies02-64x64.png");
			this.dlg.title = SBText.__("Currency");
			this.dlg.get_content_area().margin = 10;
			this.dlg.get_content_area().add(new Label(SBText.__("Code:")));
			this.dlg.get_content_area().add(this.entryCode);
			this.dlg.get_content_area().add(new Label(SBText.__("Name:")));
			this.dlg.get_content_area().add(this.entryName);
			this.dlg.get_content_area().add(new Label(SBText.__("Rate %:")));
			this.dlg.get_content_area().add(this.entryRate);
			this.dlg.get_content_area().show_all();
			this.buttonCancel = (Button)this.dlg.add_button(SBText.__("Cancel"), ResponseType.CANCEL);
			this.buttonSave		= (Button)this.dlg.add_button(SBText.__("Save"), ResponseType.OK);
			this.buttonCancel.get_style_context().add_class("button-red");
			this.buttonSave.get_style_context().add_class("button-green");
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
			this.entryRate.text = "1.00";
			this.dlg.show();
			this.entryCode.grab_focus();
		}
		protected void OnButtonEditClicked()
		{
			TreeModel	model;
			TreeIter iter;
			if( !this.treeview.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			Value id;
			model.get_value(iter, 1, out id);
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("currencies").Where("currency_id = %s".printf((string)id));
			var row = dbh.GetRow(null);
			if( row == null )
				return;
			this.entryCode.text = row.Get("code");
			this.entryName.text	= row.Get("name");
			this.entryRate.text	= row.Get("rate");
			this.currencyId = row.GetInt("currency_id");
			this.dlg.show();
			this.entryCode.grab_focus();
		}
		protected void OnButtonDeleteClicked()
		{
			TreeModel	model;
			TreeIter iter;
			if( !this.treeview.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			var confirm = new InfoDialog()
			{
				Title = SBText.__("Confirm deletion"),
				Message = SBText.__("Are you sure to delete the currency?")
			};
			var btn = confirm.add_button(SBText.__("Yes"), ResponseType.YES);
			btn.get_style_context().add_class("button-green");
			if( confirm.run() == ResponseType.YES )
			{
				Value id;
				model.get_value(iter, 1, out id);
				var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
				var w = new HashMap<string, Value?>();
				w.set("currency_id", int.parse((string)id));
				dbh.Delete("currencies", w);
			}
			confirm.destroy();
			this.Refresh();
			
		}
		protected void OnButtonSaveClicked()
		{
			string code = this.entryCode.text.strip();
			string name	= this.entryName.text.strip();
			string	rate	= this.entryRate.text.strip();
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
			data.set("rate", double.parse(rate));
			
			//##create new currency
			if( this.currencyId <= 0 )
			{
				data.set("creation_date", new DateTime.now_local().format("%Y-%m-%d %H:%M:%S"));
				dbh.Insert("currencies", data);
			}
			//##update currency
			else
			{
				var _w = new HashMap<string, Value?>();
				_w.set("currency_id", this.currencyId);
				dbh.Update("currencies", data, _w);
			}
			this.currencyId = 0;
			this.dlg.hide();
			this.Refresh();
		}
		protected void OnButtonCancelClicked()
		{
			this.dlg.hide();
		}
	}
}
