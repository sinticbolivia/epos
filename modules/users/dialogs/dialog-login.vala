using Gtk;
using Gee;
using SinticBolivia;
using SinticBolivia.Gtk;

namespace EPos
{
	class DialogLogin : Gtk.Dialog
	{
		protected	Dialog		_dialog;
		protected	Builder		_builder;
		protected	Box			box1;
		protected 	Image		_image1;
		protected	Entry		_entryUsername;
		protected	Entry		_entryPassword;
		//protected	ComboBox	_comboboxAuthenticationType;
		protected	Button		_buttonCancel;
		protected	Button		_buttonLogin;
		//protected	CheckButton	_checkbuttonSync;
				
		public DialogLogin()
		{
			this.decorated = false;
			this.modal = true;
			try
			{
				this._builder	= (SBModules.GetModule("Users") as SBGtkModule).GetGladeUi("login.glade", "mod_users");
				//this._dialog	= (Dialog)this._builder.get_object("dialogLogin");
				this.box1		= (Box)this._builder.get_object("box1");
				this._image1	= (Image)this._builder.get_object("image1");
				this._entryUsername	= (Entry)this._builder.get_object("entryUsername");
				this._entryPassword	= (Entry)this._builder.get_object("entryPassword");
				//this._comboboxAuthenticationType	= (ComboBox)this._builder.get_object("comboboxAuthenticationType");
				this._buttonCancel	= (Button)this.add_button(SBText.__("Cancel"), ResponseType.CANCEL);
				this._buttonLogin	= (Button)this.add_button(SBText.__("Login"), ResponseType.OK);
				this._buttonCancel.get_style_context().add_class("button-red");
				this._buttonLogin.get_style_context().add_class("button-green");
				//this._checkbuttonSync	= (CheckButton)this._builder.get_object("checkbuttonSync");
							
				/*
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
				*/
			}
			catch(GLib.Error e)
			{
				stdout.printf("ERROR: %s\n", e.message);
			}
			this.box1.reparent(this.get_content_area());
			
			this.title = SBText.__("Woocommerce Point of Sale - Access", "mod_users");
			//this._dialog.decorated = false;
			
			
			//this._checkbuttonSync.active = true;
			this.Build();
			this.SetEvents();
			
		}
		protected void Build()
		{
			this.window_position = WindowPosition.CENTER_ALWAYS;
			this.icon = new Gdk.Pixbuf.from_file(SBFileHelper.SanitizePath("share/images/sinticbolivia-icon-40x40.png"));
			this._image1.set_from_file("share/images/CheckoutIcon-200x200.png");
		}
		protected void SetEvents()
		{
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
			//this._dialog.set_data<string>("is_authenticated", "no");
			this._dialog.destroy();
			this.destroy();
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
					Title = SBText.__("Invalid username", "mod_users"),
					Message = SBText.__("Enter a valid username", "mod_users")
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
					Title = SBText.__("Invalid password", "mod_users"),
					Message = SBText.__("Enter a user password", "mod_users")
				};
				erro.run();
				erro.destroy();
				this._entryPassword.grab_focus();
				return;
			}
			/*
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
			*/
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
				this.set_data<string>("is_authenticated", "yes");
				SBGlobals.SetVar("user", (SBUser)data["user"]);
				this.destroy();
				//this.unref();
			}
			else
			{
				string msg = (string)data["error"];
				var dlg = new InfoDialog("error")
				{
					Title = SBText.__("Local authentication error", "mod_users"),
					Message = msg
				};
				dlg.run();
				dlg.destroy();
				logged = false;
				this.set_data<string>("is_authenticated", "no");
			}
		}
	}
}

