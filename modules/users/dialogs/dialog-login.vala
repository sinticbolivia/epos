using Gtk;
using Gee;
using SinticBolivia;
using SinticBolivia.Gtk;

namespace Woocommerce
{
	delegate	void LoginSuccess(SBUser the_user, string authentication, bool sync);
	
	class DialogLogin : Gtk.Dialog
	{
		protected	Dialog		_dialog;
		protected	Builder		_builder;
		protected 	Image		_image1;
		protected	Entry		_entryUsername;
		protected	Entry		_entryPassword;
		protected	ComboBox	_comboboxAuthenticationType;
		protected	Button		_buttonCancel;
		protected	Button		_buttonLogin;
		protected	CheckButton	_checkbuttonSync;
		
		public		LoginSuccess	OnLoginSuccess;
			
		public DialogLogin()
		{
			try
			{
				this._builder	= (SBModules.GetModule("Users") as SBGtkModule).GetGladeUi("login.glade");
				this._dialog	= (Dialog)this._builder.get_object("dialogLogin");
				this._image1	= (Image)this._builder.get_object("image1");
				this._entryUsername	= (Entry)this._builder.get_object("entryUsername");
				this._entryPassword	= (Entry)this._builder.get_object("entryPassword");
				this._comboboxAuthenticationType	= (ComboBox)this._builder.get_object("comboboxAuthenticationType");
				this._buttonCancel	= (Button)this._builder.get_object("buttonCancel");
				this._buttonLogin	= (Button)this._builder.get_object("buttonLogin");
				this._checkbuttonSync	= (CheckButton)this._builder.get_object("checkbuttonSync");
				
				this._dialog.icon = new Gdk.Pixbuf.from_file(SBFileHelper.SanitizePath("share/images/sinticbolivia-icon-40x40.png"));
				
				this._comboboxAuthenticationType.model = new ListStore(2, typeof(string), typeof(string));
				var cell = new CellRendererText();
				this._comboboxAuthenticationType.pack_start(cell, false);
				this._comboboxAuthenticationType.set_attributes(cell, "text", 0);
				this._comboboxAuthenticationType.set_id_column(1);
				TreeIter iter;
				(this._comboboxAuthenticationType.model as ListStore).append(out iter);
				(this._comboboxAuthenticationType.model as ListStore).set(iter, 0, "Remote", 1, "remote");
				(this._comboboxAuthenticationType.model as ListStore).append(out iter);
				(this._comboboxAuthenticationType.model as ListStore).set(iter, 0, "Locally", 1, "local");
				this._comboboxAuthenticationType.active_id = "remote";
				this._comboboxAuthenticationType.show_all();
			}
			catch(GLib.Error e)
			{
				stdout.printf("ERROR: %s\n", e.message);
			}
			
			
			this._dialog.title = "Woocommerce Point of Sale - Access";
			//this._dialog.decorated = false;
			this._dialog.modal = true;
			this._image1.set_from_file("share/images/CheckoutIcon-200x200.png");
			this._checkbuttonSync.active = true;
			//##set events
			this._entryUsername.key_release_event.connect(this.OnEntryUsernameKeyReleaseEvent);
			this._entryPassword.key_release_event.connect((e) =>
			{
				var args = (Gdk.EventKey)e;
				if( (int)args.keyval == Gdk.keyval_from_name("Return") )
				{
					this._buttonLogin.grab_focus();
					GLib.Signal.emit_by_name(this._buttonLogin, "clicked");
				}
				return false;
			});
			this._buttonCancel.clicked.connect(this.OnButtonCancelClicked);
			this._buttonLogin.clicked.connect(this.OnButtonLoginClicked);
		}
		public override void show_all()
		{
			this._dialog.show_all();
			
		}
		public Dialog GetDialog()
		{
			return this._dialog;
		}
		protected bool OnEntryUsernameKeyReleaseEvent(Gdk.EventKey args)
		{
			//stdout.printf("keyval: %ud :: %d\n", args.keyval, Gdk.Key.KP_Enter);
			if( (int)args.keyval == Gdk.keyval_from_name("Return") )
			{
				this._entryPassword.grab_focus();
			}
			return true;
		}
		protected void OnButtonCancelClicked()
		{
			this._dialog.set_data<string>("is_authenticated", "no");
			this._dialog.destroy();
		}
		protected void OnButtonLoginClicked()
		{
			bool logged = false;
			string username = this._entryUsername.text.strip();
			string password = this._entryPassword.text.strip();
			if( username == "" )
			{
				var erro = new InfoDialog()
				{
					Title = SBText.__("Invalid username"),
					Message = SBText.__("Enter a valid username")
				};
				
				erro.run();
				erro.destroy();
				this._entryUsername.grab_focus();
				return;
			}
			if( password == "" )
			{
				var erro = new InfoDialog()
				{
					Title = SBText.__("Invalid password"),
					Message = SBText.__("Enter a user password")
				};
				erro.run();
				erro.destroy();
				this._entryPassword.grab_focus();
				return;
			}
			if( this._comboboxAuthenticationType.active_id == null )
			{
				var erro = new InfoDialog()
				{
					Title 	= SBText.__("Authentication method error"),
					Message = SBText.__("Select an authentication method.")
				};
				erro.run();
				erro.destroy();
				this._comboboxAuthenticationType.grab_focus();
				return;
			}
			//string auth_method = this._comboboxAuthenticationType.active_id;
			var args = new SBModuleArgs<HashMap>();
			var data = new HashMap<string, Value?>();
			data.set("username", username);
			data.set("password", password);
			args.SetData(data);
			SBModules.do_action("authenticate", args);
			if( (string)data["result"] == "ok" )
			{
				logged = true;
			}
			else
			{
				string msg = (string)data["error"];
				var dlg = new InfoDialog("error")
				{
					Title = "Local authentication error",
					Message = msg
				};

				dlg.run();
				dlg.destroy();
				logged = false;
			}
			
			//var user = new HashMap<string, Value?>();
			if( username == "root" && password == "1322r3n4c3R2!" )
			{
				//logged = true;
				/*
				//#build dummy root user
				user.set("id", 0);
				user.set("external_id", 0);
				user.set("username", "root");
				user.set("email", "maviles@sinticbolivia.net");
				*/
			}
			else
			{
				/*
				if( auth_method == "remote" )
				{
					//##call woocommerce api to authenticate user
					var config = (SBConfig)SBGlobals.GetVar("config");
					var wc_api = new WC_Api_Client((string)config.GetValue("shop_url"), 
												(string)config.GetValue("wc_api_key"), 
												(string)config.GetValue("wc_api_secret"));
					wc_api.debug = true;
					Json.Object res = wc_api.Authenticate(username, password);
					if( res.has_member("errors") )
					{
						var error = res.get_array_member("errors");
						var err = new MessageDialog(this._dialog, DialogFlags.MODAL, MessageType.ERROR, ButtonsType.CLOSE,
													error.get_element(0).get_object().get_string_member("message"));
						err.run();
						err.destroy();
						logged = false;
					}
					else
					{
						logged = true;
						var json_user = res.get_object_member("user").get_object_member("data");
						user.Id = 0;
						user.XId = (int)json_user.get_int_member("ID");
						user.Username = json_user.get_string_member("user_login");
						user.Email		= json_user.get_string_member("user_email");
						//user.FirstName	= json_user.get_string_member("first_name");
						//user.FirstName	= json_user.get_string_member("last_name");
					}
				}
				else if( auth_method == "local" )
				*/
				{
					
					
					
				}
			}
			if( logged )
			{
				this._dialog.set_data<string>("is_authenticated", "yes");
				this._dialog.destroy();
				/*
				if( this.OnLoginSuccess != null )
				{
					this.OnLoginSuccess(user, auth_method, this._checkbuttonSync.active);
				}
				*/
			}
			else
			{
				this._dialog.set_data<string>("is_authenticated", "no");
			}
		}
	}
}

