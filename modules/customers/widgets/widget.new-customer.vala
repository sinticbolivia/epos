using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetNewCustomer : Box
	{
		protected	Builder		ui;
		protected	Box			boxNewCustomer;
		protected	Image		image1;
		protected	Label		labelTitle;
		protected	Label		label2;
		protected	Box				boxWidgets;
		protected	Button			buttonCustomerImage;
		protected	Image			imageCustomer;
		protected	Entry			entryFirstname;
		protected	Entry			entryLastname;
		protected	Entry			entryCompany;
		protected	Entry			entryCode;
		protected	Entry			entryDateOfBirth;
		protected	RadioButton		radiobuttonFemale;
		protected	RadioButton		radiobuttonMale;
		protected	Entry			entryPhone;
		protected	Entry			entryMobile;
		protected	Entry			entryFax;
		protected	Entry			entryEmail;
		protected	Entry			entryWebsite;
		protected	Entry			entryAddress;
		protected	Entry			entryCity;
		protected	Entry			entryZipcode;
		protected	Entry			entryState;
		protected	ComboBox		comboboxCountry;
		protected	Grid			gridGroups;
		protected	ComboBox		comboboxGroup;
		protected	Button			buttonCancel;
		protected	Button			buttonSave;
		
		protected	int				customerId = 0;
		
		public WidgetNewCustomer()
		{
			this.ui = (Builder)(SBModules.GetModule("Customers") as SBGtkModule).GetGladeUi("new-customer.glade");
			this.boxNewCustomer		= (Box)this.ui.get_object("boxNewCustomer");
			this.image1				= (Image)this.ui.get_object("image1");
			this.labelTitle			= (Label)this.ui.get_object("labelTitle");
			this.label2				= (Label)this.ui.get_object("label2");
			//this.label2.realize
			this.label2.selectable = true;
			this.boxWidgets				= (Box)this.ui.get_object("boxWidgets");
			//this.label2.get_window().cursor = new Gdk.Cursor(Gdk.CursorType.HAND1);
			this.buttonCustomerImage	= (Button)this.ui.get_object("buttonCustomerImage");
			this.imageCustomer			= (Image)this.ui.get_object("imageCustomer");
			this.entryFirstname			= (Entry)this.ui.get_object("entryFirstname");
			this.entryLastname			= (Entry)this.ui.get_object("entryLastname");
			this.entryCompany			= (Entry)this.ui.get_object("entryCompany");
			this.entryCode				= (Entry)this.ui.get_object("entryCode");
			this.entryDateOfBirth		= (Entry)this.ui.get_object("entryDateOfBirth");
			this.radiobuttonFemale		= (RadioButton)this.ui.get_object("radiobuttonFemale");
			this.radiobuttonMale		= (RadioButton)this.ui.get_object("radiobuttonMale");
			this.entryPhone				= (Entry)this.ui.get_object("entryPhone");
			this.entryMobile			= (Entry)this.ui.get_object("entryMobile");
			this.entryFax				= (Entry)this.ui.get_object("entryFax");
			this.entryEmail				= (Entry)this.ui.get_object("entryEmail");
			this.entryWebsite			= (Entry)this.ui.get_object("entryWebsite");
			this.entryAddress			= (Entry)this.ui.get_object("entryAddress");
			this.entryCity				= (Entry)this.ui.get_object("entryCity");
			this.entryZipcode			= (Entry)this.ui.get_object("entryZipcode");
			this.entryState				= (Entry)this.ui.get_object("entryState");
			this.comboboxCountry		= (ComboBox)this.ui.get_object("comboboxCountry");
			this.comboboxGroup			= (ComboBox)this.ui.get_object("comboboxGroup");
			this.gridGroups				= (Grid)this.ui.get_object("gridGroups");
			this.buttonCancel			= (Button)this.ui.get_object("buttonCancel");
			this.buttonSave				= (Button)this.ui.get_object("buttonSave");
			this.boxNewCustomer.reparent(this);
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			this.image1.pixbuf = (SBModules.GetModule("Customers") as SBGtkModule).GetPixbuf("customer-icon-64x64.png");
			this.imageCustomer.pixbuf = (SBModules.GetModule("Customers") as SBGtkModule).GetPixbuf("nobody.png");
			this.comboboxGroup.model = new ListStore(2, typeof(string), typeof(string));
			var cell = new CellRendererText();
			this.comboboxGroup.pack_start(cell, true);
			this.comboboxGroup.set_attributes(cell, "text", 0);
			this.comboboxGroup.id_column = 1;
			TreeIter iter;
			(this.comboboxGroup.model as ListStore).append(out iter);
			(this.comboboxGroup.model as ListStore).set(iter, 
				0, SBText.__("-- customer group --"),
				1, "-1"
			);
			this.comboboxGroup.active_id = "-1";
			
			var args = new SBModuleArgs<HashMap>();
			var data = new HashMap<string, Value?>();
			data.set("box_widgets", this.boxWidgets);
			data.set("grid_groups", this.gridGroups);
			args.SetData(data);
			SBModules.do_action("build_customer_form", args);
		}
		protected void SetEvents()
		{
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
			this.buttonSave.clicked.connect(this.OnButtonSaveClicked);
		}
		protected void OnButtonCancelClicked()
		{
			string tab_id = this.customerId > 0 ? "edit-customer" : "new-customer";
			(SBGlobals.GetVar("notebook") as SBNotebook).RemovePage(tab_id);
		}
		protected void OnButtonSaveClicked()
		{
			string fname = this.entryFirstname.text.strip();
			string lname = this.entryLastname.text.strip();
			string company = this.entryCompany.text.strip();
			string code		= this.entryCode.text.strip();
			string phone	= this.entryPhone.text.strip();
			string mobile	= this.entryMobile.text.strip();
			string email	= this.entryEmail.text.strip();
			string website	= this.entryWebsite.text.strip();
			
			if( fname.length <= 0 )
			{
				this.entryFirstname.grab_focus();
				return;
			}
			if( lname.length <= 0 )
			{
				this.entryLastname.grab_focus();
				return;
			}
			string cdate = new DateTime.now_local().format("%Y-%m-%d %H:%M:%S");
			var data = new HashMap<string, Value?>();
			data.set("first_name", fname);
			data.set("last_name", lname);
			data.set("company", company);
			data.set("code", code);
			data.set("phone", phone);
			data.set("mobile", mobile);
			data.set("email", email);
			data.set("website", website);
			data.set("address_1", this.entryAddress.text.strip());
			data.set("city", this.entryCity.text.strip());
			data.set("zip_code", this.entryZipcode.text.strip());
			data.set("last_modification_date", cdate);
			var meta = new HashMap<string, string>();
			var args0 = new SBModuleArgs<HashMap>();
			var data0 = new HashMap<string, Value?>();
			data0.set("data", data);
			data0.set("meta", meta);
			args0.SetData(data0);
			SBModules.do_action("before_save_customer", args0);
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.BeginTransaction();
			string title = SBText.__("New customer created");
			string msg = SBText.__("A new customer has been added.");
			if( this.customerId <= 0 )
			{
				//##create a new customer
				data.set("creation_date", cdate);
				this.customerId = (int)dbh.Insert("customers", data);
			}
			else
			{
				var w = new HashMap<string, Value?>();
				w.set("customer_id", this.customerId);
				dbh.Update("customers", data, w);
				title = SBText.__("Customer update");
				msg = SBText.__("The customer has been updated.");
			}
			//##add/update meta
			foreach(var entry in meta.entries)
			{
				SBMeta.UpdateMeta("customer_meta", entry.key, entry.value, "customer_id", this.customerId);
			}
			var args1 = new SBModuleArgs<HashMap>();
			var data1 = new HashMap<string, Value?>();
			data1.set("data", data);
			data1.set("meta", meta);
			data1.set("customer_id", this.customerId);
			args1.SetData(data1);
			SBModules.do_action("after_save_customer", args1);
			
			dbh.EndTransaction();
			var dmsg = new MessageDialog(null, DialogFlags.MODAL, MessageType.INFO, ButtonsType.CLOSE, msg);
			dmsg.title = title;
			dmsg.run();
			dmsg.destroy();
			GLib.Signal.emit_by_name(this.buttonCancel, "clicked");
		}
		public void SetCustomer(Customer c)
		{
			this.customerId = c.Id;
			
			this.entryFirstname.text 	= c.Firstname;
			this.entryLastname.text 	= c.Lastname;
			this.entryCompany.text		= c.Company;
			this.entryCode.text			= c.Code;
			this.entryDateOfBirth.text 	= c.DateofBirth;
			this.entryPhone.text		= c.Phone;
			this.entryMobile.text		= c.Mobile;
			this.entryFax.text			= "";
			this.entryWebsite.text		= c.Website;
			this.entryEmail.text		= c.Email;
			this.entryAddress.text		= c.Address1;
			this.entryCity.text			= c.City;
			this.entryZipcode.text		= c.Zipcode;
			this.entryState.text		= "";
			
			this.labelTitle.label		= SBText.__("Edit Customer");
			this.entryFirstname.grab_focus();
			var args = new SBModuleArgs<HashMap<string, Value?>>();
			var data = new HashMap<string, Value?>();
			data.set("customer_id", c.Id);
			args.SetData(data);
			SBModules.do_action("load_customer_data", args);
		}
	}
}

