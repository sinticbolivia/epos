using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace Woocommerce
{
	public class WidgetNewSupplier : Gtk.Box
	{
		protected	Builder		ui;
		protected	Box			boxSupplier;
		protected	Image		image1;
		protected	Label		labelDetailsTitle;
		protected	Viewport	viewportDetailsBody;
		protected	Entry		entrySupplierName;
		protected	Entry		entryDefaultMarkup;
		protected	TextView	textviewDescription;
		protected	Entry		entryCompany;
		protected	Entry		entryContactFirstName;
		protected 	Entry		entryPhone;
		protected	Entry		entryMobile;
		protected	Entry		entryEmail;
		protected	Entry		entryWebsite;
		protected	Entry		entryStreet;
		protected	Entry		entryCity;
		protected	ComboBox	comboboxCountry;
		protected 	Button		buttonCancel;
		protected	Button		buttonSave;
		
		protected	int			supplierId = 0;
		
		public WidgetNewSupplier()
		{
			//this.ui = SB_ModuleInventory.GetGladeUi("new-supplier.glade");
			this.ui		= (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("new-supplier.glade");
			this.boxSupplier			= (Box)this.ui.get_object("boxSupplier");
			this.image1					= (Image)this.ui.get_object("image1");
			this.labelDetailsTitle		= (Label)this.ui.get_object("labelDetailsTitle");
			this.viewportDetailsBody	= (Viewport)this.ui.get_object("viewportDetailsBody");
			this.entrySupplierName		= (Entry)this.ui.get_object("entrySupplierName");
			this.entryDefaultMarkup		= (Entry)this.ui.get_object("entryDefaultMarkup");
			this.textviewDescription	= (TextView)this.ui.get_object("textviewDescription");
			this.entryCompany			= (Entry)this.ui.get_object("entryCompany");
			this.entryContactFirstName	= (Entry)this.ui.get_object("entryContactFirstName");
			this.entryPhone				= (Entry)this.ui.get_object("entryPhone");
			this.entryMobile			= (Entry)this.ui.get_object("entryMobile");
			this.entryEmail				= (Entry)this.ui.get_object("entryEmail");
			this.entryWebsite			= (Entry)this.ui.get_object("entryWebsite");
			this.entryStreet			= (Entry)this.ui.get_object("entryStreet");
			this.entryCity				= (Entry)this.ui.get_object("entryCity");
			this.comboboxCountry		= (ComboBox)this.ui.get_object("comboboxCountry");
			this.buttonCancel			= (Button)this.ui.get_object("buttonCancel");
			this.buttonSave				= (Button)this.ui.get_object("buttonSave");
			
			this.Build();
			this.FillForm();
			this.SetEvents();
			this.boxSupplier.reparent(this);
			
		}
		protected void Build()
		{
			this.labelDetailsTitle.events = Gdk.EventMask.BUTTON_RELEASE_MASK;
			this.labelDetailsTitle.selectable = true;
			this.image1.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("supplier-icon-48x48.png");//SB_ModuleInventory.GetPixbuf("supplier-icon-48x48.png");
			var cell0 = new CellRendererText();
			this.comboboxCountry.pack_start(cell0, true);
			this.comboboxCountry.add_attribute(cell0, "text", 0);
			TreeIter iter;
			this.comboboxCountry.model = new ListStore(2, typeof(string), typeof(string));
			(this.comboboxCountry.model as ListStore).append(out iter);
			(this.comboboxCountry.model as ListStore).set(iter, 0, SBText.__("-- country --"), 1, "-1");
			this.comboboxCountry.id_column = 1;
			
		}
		protected void FillForm()
		{
			this.comboboxCountry.active_id = "-1";
		}
		protected void SetEvents()
		{
			this.labelDetailsTitle.button_release_event.connect( () => 
			//GLib.Signal.connect(this.labelDetailsTitle, "button-release-event", () =>
			{
				stdout.printf("button-release-event\n");
				this.viewportDetailsBody.visible = !this.viewportDetailsBody.visible;
				return true;
			});
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
			this.buttonSave.clicked.connect(this.OnButtonSaveClicked);
		}
		protected void OnButtonCancelClicked()
		{
			string tab_id = (this.supplierId > 0) ? "edit-supplier" : "new-supplier";
			var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
			notebook.RemovePage(tab_id);
		}
		protected void OnButtonSaveClicked()
		{
			string name = this.entrySupplierName.text.strip();
			double markup = double.parse(this.entryDefaultMarkup.text.strip());
			string desc = this.textviewDescription.buffer.text.strip();
			
			if( name.length <= 0 )
			{
				this.entrySupplierName.grab_focus();
				return;
			}
			string msg_text = "The supplier has been added.";
			string msg_title = SBText.__("New Supplier added");
			string cdate = new DateTime.now_local().format("%Y-%m-%d %H:%M:%S");
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var sup = new HashMap<string, Value?>();
			sup.set("supplier_name", name);
			sup.set("supplier_details", desc);
			sup.set("supplier_contact_person", this.entryContactFirstName.text.strip());
			sup.set("supplier_telephone_1", this.entryPhone.text.strip());
			sup.set("supplier_telephone_2", this.entryMobile.text.strip());
			sup.set("supplier_email", this.entryEmail.text.strip());
			sup.set("supplier_address", this.entryStreet.text.strip());
			sup.set("supplier_city", this.entryCity.text.strip());
			sup.set("last_modification_date", cdate);
			
			if( this.supplierId <= 0 )
			{
				//##add new supplier
				sup.set("creation_date", cdate);
				dbh.Insert("suppliers", sup);
			}
			else
			{
				//##update supplier
				var w = new HashMap<string, Value?>();
				w.set("supplier_id", this.supplierId);
				dbh.Update("suppliers", sup, w);
				msg_text = "The supplier has been updated.";
				msg_title = SBText.__("Supplier updated");
			}
			var msg = new MessageDialog(null, DialogFlags.MODAL, MessageType.INFO, ButtonsType.CLOSE, 
				SBText.__(msg_text)
			){title = msg_title};
			msg.run();
			msg.destroy();
			
			GLib.Signal.emit_by_name(this.buttonCancel, "clicked");
		}
		public void SetSupplier(int supplier_id)
		{
			this.supplierId = supplier_id;
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM suppliers WHERE supplier_id = %d".printf(supplier_id);
			var row = dbh.GetRow(query);
			if( row == null )
				return;
			this.entrySupplierName.text = row.Get("supplier_name");
			this.entryDefaultMarkup.text = "0";
			this.textviewDescription.buffer.text = row.Get("supplier_details");
			this.entryContactFirstName.text = row.Get("supplier_contact_person");
			this.entryPhone.text = row.Get("supplier_telephone_1");
			this.entryMobile.text = row.Get("supplier_telephone_2");
			this.entryEmail.text = row.Get("supplier_email");
			this.entryStreet.text = row.Get("supplier_address");
			this.entryCity.text = row.Get("supplier_city");
			this.entrySupplierName.grab_focus();
		}
	}
}
