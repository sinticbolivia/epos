using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Database;
using SinticBolivia.Gtk;

namespace EPos
{
	class WidgetEditUser : Box
	{
		protected	Builder		ui;
		protected	Window		windowNewUser;
		protected	Box			boxNewUser;
		protected	Image		imageNewUser;
		protected	Button		buttonUserImage;
		protected	Image		imageUser;
		protected	Grid		grid2;
		protected	Entry		entryFirstName;
		protected	Entry		entryLastName;
		protected	Entry		entryEmail;
		protected	Entry		entryUsername;
		protected	Entry		entryPassword;
		protected	ComboBox	comboboxRoles;
		protected	Button		buttonCancelNewUser;
		protected	Button		buttonSaveNewUser;
		
		protected	SBUser		theUser	= null;
		
		private		static	int instances = 0;
		
		static construct
		{
			instances = 0;
		}
		public WidgetEditUser()
		{
			Object();
			this.ui					= (SBModules.GetModule("Users") as SBGtkModule).GetGladeUi("edit-user.glade", "mod_users");
			this.ui.translation_domain = "mod_users";
			this.windowNewUser		= (Window)this.ui.get_object("windowNewUser");
			this.boxNewUser			= (Box)this.ui.get_object("boxNewUser");
			this.imageNewUser		= (Image)this.ui.get_object("imageNewUser");
			this.imageUser			= (Image)this.ui.get_object("imageUser");
			this.buttonUserImage	= (Button)this.ui.get_object("buttonUserImage");
			this.grid2				= (Grid)this.ui.get_object("grid2");
			this.entryFirstName		= (Entry)this.ui.get_object("entryFirstName");
			this.entryLastName		= (Entry)this.ui.get_object("entryLastName");
			this.entryEmail			= (Entry)this.ui.get_object("entryEmail");
			this.entryUsername		= (Entry)this.ui.get_object("entryUsername");
			this.entryPassword		= (Entry)this.ui.get_object("entryPassword");
			this.comboboxRoles			= (ComboBox)this.ui.get_object("comboboxRoles");
			this.buttonCancelNewUser 	= (Button)this.ui.get_object("buttonCancelNewUser");
			this.buttonSaveNewUser		= (Button)this.ui.get_object("buttonSaveNewUser");
					
			this.Build();
			this.SetEvents();
			this.RefreshRoles();
			//##reset the form values
			this.entryFirstName.text = "";
			this.entryLastName.text = "";
			this.entryEmail.text = "";
			this.entryUsername.text = "";
			this.entryPassword.text = "";
			this.comboboxRoles.active_id = "-1";
			
			this.boxNewUser.reparent(this);
			//stdout.printf("admin string md5: %s\n",  Checksum.compute_for_string(ChecksumType.MD5, "admin"));
		}
		protected void Build()
		{
			try
			{
				this.imageNewUser.pixbuf = (SBModules.GetModule("Users") as SBGtkModule).GetPixbuf("user-icon-64x64.png");
				this.imageUser.pixbuf	= (SBModules.GetModule("Users") as SBGtkModule).GetPixbuf("nobody.png");
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			this.comboboxRoles.model = new ListStore(2, typeof(string), typeof(string));
			var cell = new CellRendererText();
			this.comboboxRoles.pack_start(cell, false);
			this.comboboxRoles.set_attributes(cell, "text", 0);
			this.comboboxRoles.id_column = 1;
			this.comboboxRoles.show_all();
			
			var args = new SBModuleArgs<Grid>();
			args.SetData(this.grid2);
			SBModules.do_action("user_fields", args);
		}
		protected void SetEvents()
		{
			this.destroy.connect( () => 
			{
				this.boxNewUser.reparent(this.windowNewUser);
			});
			this.buttonUserImage.clicked.connect(this.OnButtonUserImageClicked);
			this.buttonSaveNewUser.clicked.connect(this.OnButtonSaveNewUserClicked);
		}
		protected void RefreshRoles()
		{
			TreeIter iter;
			(this.comboboxRoles.model as ListStore).append(out iter);
			(this.comboboxRoles.model as ListStore).set(iter, 0, SBText.__("-- roles --"), 1, "-1");
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("user_roles");
			var rows = dbh.GetResults(null);
			foreach(var row in rows)
			{
				(this.comboboxRoles.model as ListStore).append(out iter);
				(this.comboboxRoles.model as ListStore).set(iter, 0, row.Get("role_name"), 1, row.Get("role_id"));
			}
			this.comboboxRoles.active_id = "-1";
		}
		public void SetUser(SBUser user)
		{
			this.theUser = user;
			//##set form data
			this.entryFirstName.text 	= this.theUser.Firstname;
			this.entryLastName.text		= this.theUser.Lastname;
			this.entryEmail.text		= this.theUser.Email;
			this.entryUsername.text		= this.theUser.Username;
			this.entryPassword.text		= this.theUser.Password;
			this.comboboxRoles.active_id = this.theUser.RoleId.to_string();
			
			var args = new SBModuleArgs<HashMap<string, Value?>>();
			var data = new HashMap<string, Value?>();
			data.set("grid_fields", this.grid2);
			data.set("user_id", this.theUser.Id);
			args.SetData(data);
			SBModules.do_action("set_user_data", args);
		}
		protected void OnButtonUserImageClicked()
		{
		}
		protected void OnButtonSaveNewUserClicked()
		{
			string first_name = this.entryFirstName.text.strip();
			string last_name	= this.entryLastName.text.strip();
			string username		= this.entryUsername.text.strip();
			string password		= this.entryPassword.text.strip();
			string email		= this.entryEmail.text.strip();
			int	role_id			= (this.comboboxRoles.active_id == null) ? -1 : int.parse(this.comboboxRoles.active_id);
			
			if( first_name.length <= 0 )
			{
				this.entryFirstName.grab_focus();
				return;
			}
			if( last_name.length <= 0 )
			{
				this.entryLastName.grab_focus();
				return;
			}
			if( username.length <= 0 )
			{
				this.entryUsername.grab_focus();
				return;
			}
			if( password.length <= 0 )
			{
				this.entryPassword.grab_focus();
				return;
			}
			if( role_id == -1 )
			{
				this.comboboxRoles.grab_focus();
				return;
			}
			//##update user data
			var data = new HashMap<string, Value?>();
			data.set("first_name", first_name);
			data.set("last_name", last_name);
			data.set("role_id", role_id);
			data.set("email", email);
			
			if( password != this.theUser.Password )
			{
				data.set("pwd", Checksum.compute_for_string(ChecksumType.MD5, password));
			}
			var w = new HashMap<string, Value?>();
			w.set("user_id", this.theUser.Id);
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Update("users", data, w);
			
			var args_data = new HashMap<string, Value?>();
			args_data.set("grid_fields", this.grid2);
			args_data.set("user_id", this.theUser.Id);
			var args = new SBModuleArgs<HashMap<string, Value?>>();
			args.SetData(args_data);
			SBModules.do_action("user_saved", args);
			
			var msg = new InfoDialog()
			{
				Message = SBText.__("The user has been updated.", "mod_users"),
				Title = SBText.__("User updated", "mod_users")
			};
			msg.run();
			msg.dispose();
		}
	}
}
