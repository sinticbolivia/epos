using Gtk;
using Gee;
using SinticBolivia;

namespace EPos
{
	//delegate void CustomerCreatedCallback(WCCustomer customer);
	
	public class DialogCreateCustomer : Gtk.Dialog
	{
		protected Builder 	_builder;
		protected Dialog 	_dialog;
		protected Image		imageTitle;
		protected Label		labelTitle;
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
		//public		CustomerCreatedCallback OnCustomerCreated;
		public 		Dialog	TheDialog
		{
			get{return this._dialog;}
		}
		public DialogCreateCustomer()
		{
			this._builder 		= new Builder();
			try
			{
				this._builder.add_from_file(GLib.Environment.get_current_dir() + "/share/ui/" + "create-customer.glade");
				
				this._dialog		= (Dialog)this._builder.get_object("dialogCreateCustomer");
				this.imageTitle 	= (Image)this._builder.get_object("imageTitle");
				this.entryFirstName	= (Entry)this._builder.get_object("entryFirstName");
				this.entryLastName	= (Entry)this._builder.get_object("entryLastName");
				this.entryAddress	= (Entry)this._builder.get_object("entryAddress");
				this.entryEmail		= (Entry)this._builder.get_object("entryEmail");
				this.entryUsername	= (Entry)this._builder.get_object("entryUsername");
				this.entryPassword	= (Entry)this._builder.get_object("entryPassword");
				this.buttonGeneratePassword	= (Button)this._builder.get_object("buttonGeneratePassword");
				this.buttonCancel	= (Button)this._builder.get_object("buttonCancel");
				this.buttonSave		= (Button)this._builder.get_object("buttonSave");
			}
			catch(GLib.Error e)
			{
				stdout.printf("ERROR: %s\n", e.message);
			}
			this.imageTitle.set_from_file(SBFileHelper.SanitizePath("share/images/customer-icon-64x64.png"));
			//##set connect signals
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
			this._dialog.dispose();
		}
		protected void OnButtonSaveClicked()
		{
			size_t length = 0;
			/*
			var generator = new Json.Generator();
			var root = new Json.Node(Json.NodeType.OBJECT);
			Json.Object customer = new Json.Object();
			root.set_object(customer);
			generator.set_root(root);
			customer.set_string_member("email", this.entryEmail.text.strip());
			customer.set_string_member("username", this.entryUsername.text.strip());
			customer.set_string_member("password", this.entryPassword.text.strip());
			customer.set_string_member("first_name", this.entryFirstName.text.strip());
			customer.set_string_member("last_name", this.entryLastName.text.strip());
			customer.set_string_member("city", this.entryCity.text.strip());
			customer.set_string_member("state", this.entryState.text.strip());
			customer.set_string_member("phone", this.entryPhone.text.strip());
			
			string json = generator.to_data(out length);
			stdout.printf("JSON => %s\n", json);
			HashMap<string,string> data = new HashMap<string,string>();
			data.set("raw_data", json);
			
			var api = (WC_Api_Client)SBGlobals.GetVar("ec_api");
			api.debug = true;
			Json.Object new_customer = api.CreateCustomer(data);
			if( new_customer.has_member("customer") )
			{
				MessageDialog msg = new MessageDialog(null, 
												DialogFlags.MODAL, 
												MessageType.INFO, 
												ButtonsType.OK, 
												"The customer has been created.");
				msg.run();
				msg.dispose();
				if( this.OnCustomerCreated != null )
				{
					var the_customer = new WCCustomer();
					the_customer.Id = 0;
					the_customer.XId = (int)new_customer.get_object_member("customer").get_int_member("ID");
					the_customer.Firstname = "";
					the_customer.Lastname = "";
					the_customer.Email	= new_customer.get_object_member("customer").get_object_member("data").get_string_member("user_email");
					the_customer.Username = new_customer.get_object_member("customer").get_object_member("data").get_string_member("user_login");
					this.OnCustomerCreated(the_customer);
				}
			}
			else
			{
			}
			*/
		}
		protected override void show_all()
		{
			this._dialog.show_all();
		}
	}
}
