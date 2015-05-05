using Gtk;
using Gee;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	//delegate void CustomerCreatedCallback(WCCustomer customer);
	
	public class DialogCreateCustomer : Gtk.Dialog
	{
		protected Builder 		_builder;
		//protected Dialog 	_dialog;
		protected	Box			box1;
		protected 	Image		imageTitle;
		protected 	Label		labelTitle;
		protected	Box			boxCustomerForm;
		public		Entry	entryFirstName;
		public		Entry	entryLastName;
		public		Entry	entryAddress;
		public		Entry	entryCity;
		public		Entry	entryState;
		public 		Entry	entryEmail;
		public 		Entry	entryPhone;
		public		Entry	entryUsername;
		public		Entry	entryPassword;
		public		Button	buttonGeneratePassword;
		public		Button	buttonCancel;
		public		Button	buttonSave;
		public		int						StoreId = 0;
		protected	int						customerId = 0;
		public		SBDatabase				Dbh;
		public		HashMap<string, Value?>	CustomerData;
		public DialogCreateCustomer()
		{
			this.set_size_request(800, 600);
			this.title = SBText.__("Create customer");
			try
			{
				this._builder		= (SBModules.GetModule("Pos") as SBGtkModule).GetGladeUi("create-customer.glade");
				this.box1			= (Box)this._builder.get_object("box1");
				this.imageTitle 	= (Image)this._builder.get_object("imageTitle");
				this.labelTitle		= (Label)this._builder.get_object("labelTitle");
				this.boxCustomerForm	= (Box)this._builder.get_object("boxCustomerForm");
				this.entryFirstName	= (Entry)this._builder.get_object("entryFirstName");
				this.entryLastName	= (Entry)this._builder.get_object("entryLastName");
				this.entryAddress	= (Entry)this._builder.get_object("entryAddress");
				this.entryCity		= (Entry)this._builder.get_object("entryCity");
				this.entryState		= (Entry)this._builder.get_object("entryState");
				this.entryEmail		= (Entry)this._builder.get_object("entryEmail");
				this.entryPhone		= (Entry)this._builder.get_object("entryPhone");
				//this.entryUsername	= (Entry)this._builder.get_object("entryUsername");
				//this.entryPassword	= (Entry)this._builder.get_object("entryPassword");
				//this.buttonGeneratePassword	= (Button)this._builder.get_object("buttonGeneratePassword");
				this.buttonCancel	= (Button)this.add_button(SBText.__("Cancel"), ResponseType.CANCEL);
				this.buttonSave		= (Button)this.add_button(SBText.__("Save"), ResponseType.OK);
			}
			catch(GLib.Error e)
			{
				stdout.printf("ERROR: %s\n", e.message);
			}
			this.box1.reparent(this.get_content_area());
			this.Build();
			this.SetEvents();
			
			
		}
		protected void Build()
		{
			this.imageTitle.set_from_file(SBFileHelper.SanitizePath("share/images/customer-icon-64x64.png"));
			this.buttonCancel.get_style_context().add_class("button-red");
			this.buttonSave.get_style_context().add_class("button-green");
			var args = new SBModuleArgs<Box>();
			args.SetData(this.boxCustomerForm);
			SBModules.do_action("build_create_customer_dlg", args);
		}
		protected void SetEvents()
		{
			//##connect signals
			this.buttonGeneratePassword.clicked.connect(this.OnButtonGeneratePassword);
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
			this.buttonSave.clicked.connect(this.OnButtonSaveClicked);
		}
		protected void OnButtonGeneratePassword()
		{
			string lower_letters = "abcdefghijklmnopqrstuvwxyz";
			string upper_letters = lower_letters.up();
			string alpha_numeric = "1234567890[]{}-_~+#$%&/()=?¿¡!*@";
			string dictionary = lower_letters + upper_letters + alpha_numeric;
			string password = "";
			var rand = new Rand();
			for(int i = 0; i < 8; i++)
			{
				password += dictionary[rand.int_range(0, dictionary.length - 1)].to_string();
			}
			
			this.entryPassword.text = password;
		}
		protected void OnButtonCancelClicked(Button sender)
		{
			this.destroy();
		}
		protected void OnButtonSaveClicked()
		{
			string first_name = this.entryFirstName.text.strip();
			string last_name	= this.entryLastName.text.strip();
			string address		= this.entryAddress.text.strip();
			string city 		= this.entryCity.text.strip();
			string state 		= this.entryState.text.strip();
			string email		= this.entryEmail.text.strip();
			string phone		= this.entryPhone.text.strip();
			
			if( first_name.length <= 0 )
			{
				var err = new InfoDialog("error")
				{
					Title = SBText.__("Customer data error"),
					Message = SBText.__("You need to enter the customer firstname")
				};
				err.run();
				err.destroy();
				this.entryFirstName.grab_focus();
				return;
			}
			if( last_name.length <= 0 )
			{
				var err = new InfoDialog("error")
				{
					Title = SBText.__("Customer data error"),
					Message = SBText.__("You need to enter the customer lastname")
				};
				err.run();
				err.destroy();
				this.entryLastName.grab_focus();
				return;
			}
			var validation = new HashMap<string, Value?>();
			validation.set("ok", true);
			var valid_args = new SBModuleArgs<HashMap>();
			valid_args.SetData(validation);
			SBModules.do_action("create_customer_validation", valid_args);
			
			if( (bool)validation["ok"] == false )
			{
				var err = new InfoDialog("error")
				{
					Title = SBText.__("Customer error"),
					Message	= (string)validation["error"]
				};
				err.run();
				err.destroy();
				return;
			}
			string cdate = new DateTime.now_local().format("%Y-%m-%d %H:%M:%S");
			this.CustomerData = new HashMap<string, Value?>();
			this.CustomerData.set("store_id", this.StoreId);
			this.CustomerData.set("first_name", first_name);
			this.CustomerData.set("last_name", last_name);
			this.CustomerData.set("address_1", address);
			this.CustomerData.set("city", city);
			this.CustomerData.set("phone", phone);
			this.CustomerData.set("email", email);
			this.CustomerData.set("last_modification_date", cdate);
			
			var b_args = new SBModuleArgs<HashMap>();
			b_args.SetData(this.CustomerData);
			SBModules.do_action("before_create_customer", b_args);
			this.Dbh.BeginTransaction();
			string msg_str = "";
			if( this.customerId <= 0 )
			{
				msg_str = SBText.__("The customer has been created");
				this.CustomerData.set("creation_date", cdate);
				this.customerId = (int)this.Dbh.Insert("customers", this.CustomerData);
			}
			else
			{
				msg_str = SBText.__("The customer has been updated");
				var where = new HashMap<string, Value?>();
				where.set("customer_id", this.customerId);
				this.Dbh.Update("customers", this.CustomerData, where);
			}
			this.Dbh.EndTransaction();
			this.CustomerData.set("customer_id", this.customerId);
			
			var a_args = new SBModuleArgs<HashMap>();
			var data = new HashMap<string, Value?>();
			data.set("customer", this.CustomerData);
			data.set("customer_id", this.customerId);
			data.set("dbh", this.Dbh);
			a_args.SetData(data);
			SBModules.do_action("after_create_customer", a_args);
			var msg = new InfoDialog("success")
			{
				Title = SBText.__("Customer"),
				Message = msg_str
			};
			msg.run();
			msg.destroy();
			this.destroy();
		}
		public void ViewCustomer(SBCustomer customer, bool allow_update = false)
		{
			this.title = SBText.__("Customer Details");
			this.customerId = 0;
			this.labelTitle.label		= SBText.__("Customer Details");
			this.entryFirstName.text = customer.Get("first_name");
			this.entryLastName.text = customer.Get("last_name");
			this.entryAddress.text	= customer.Get("address_1");
			this.entryCity.text		= customer.Get("city");
			this.entryState.text	= customer.Get("city");
			this.entryEmail.text	= customer.Get("email");
			this.entryPhone.text	= customer.Get("phone");
			this.buttonSave.visible = false;
			this.buttonCancel.label = SBText.__("Close");
			var args = new SBModuleArgs<SBCustomer>();
			args.SetData(customer);
			SBModules.do_action("view_customer_details_dlg", args);
			if( allow_update )
			{
				this.customerId = customer.Id;
				this.buttonSave.visible = true;
			}
		}
	}
}
