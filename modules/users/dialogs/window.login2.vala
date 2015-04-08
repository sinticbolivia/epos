using Gee;
using GLib;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;

namespace EPos
{
	public class WindowLogin : Window
	{
		protected	Builder		ui;
		protected	Fixed	fixed1;
		protected	Box			box1;
		protected	EventBox	eventbox1;
		protected	Box			boxFooter;
		protected	Entry		entryUsername;
		protected	Entry		entryPassword;
		protected	Button		buttonSignIn;
		protected	Button		buttonCancel;
		protected	int			currentImg = 0;
		protected	uint		timeoutId;
		public WindowLogin()
		{
			this.name = "window-login";
			this.ui				= (SBModules.GetModule("Users") as SBGtkModule).GetGladeUi("login2.glade");
			
			this.fixed1			= (Fixed)this.ui.get_object("fixed1");
			this.eventbox1		= (EventBox)this.ui.get_object("eventbox1");
			this.box1			= (Box)this.ui.get_object("box1");
			this.boxFooter		= (Box)this.ui.get_object("boxFooter");
			this.entryUsername	= (Entry)this.ui.get_object("entryUsername");
			this.entryPassword	= (Entry)this.ui.get_object("entryPassword");
			this.buttonSignIn	= (Button)this.ui.get_object("buttonSignIn");
			this.buttonCancel	= (Button)this.ui.get_object("buttonCancel");
			this.fixed1.reparent(this);
			
			this.maximize();
			this.Build();
			this.SetEvents();
		}
		public void Build()
		{
			this.title = SBText.__("Ecommerce Point of Sale - Access");
			this.decorated = false;
			this.boxFooter.visible = false;
		}
		protected void SetEvents()
		{
			this.show.connect(() => {this.modal = false;});
			this.size_allocate.connect( (alloc) => 
			{
				int w 			= this.get_allocated_width();
				int h			= this.get_allocated_height();
				int box_width 	= this.eventbox1.get_allocated_width();				
				this.fixed1.move(this.eventbox1, (w/2) - (box_width/2), 100);
				//this.fixed1.move(this.boxFooter, 0, h);
				//this.boxFooter.set_size_request(w, 50);
				//stdout.printf("window width: %d\n", w);
			});
			this.entryUsername.key_release_event.connect( (args) => 
			{
				if( (int)args.keyval == Gdk.keyval_from_name("Return") )
				{
					this.entryPassword.grab_focus();
				}
				return true;
			});
			this.entryPassword.key_release_event.connect((e) =>
			{
				var args = (Gdk.EventKey)e;
				if( (int)args.keyval == Gdk.keyval_from_name("Return") )
				{
					this.buttonSignIn.grab_focus();
					GLib.Signal.emit_by_name(this.buttonSignIn, "clicked");
				}
				return false;
			});
			this.buttonSignIn.clicked.connect(this.OnButtonLoginClicked);
			this.buttonCancel.clicked.connect(()=>{this.destroy();});
			this.get_style_context().add_class("woman0");
			this.timeoutId = GLib.Timeout.add(5000, () =>
			{
				string _class = "woman%d".printf(this.currentImg);
				stdout.printf("removing class: %s\n", _class);
				this.get_style_context().remove_class(_class);
				
				this.currentImg++;
				if( this.currentImg == 3 )
					this.currentImg = 0;
				_class = "woman%d".printf(this.currentImg);	
				//stdout.printf("adding class: %s\n", _class);
				this.get_style_context().add_class(_class);
				
				return true;
			});
		}
		protected void OnButtonLoginClicked()
		{
			bool logged = false;
			string username = this.entryUsername.text.strip();
			string password = this.entryPassword.text.strip();
			if( username.length <= 0 )
			{
				var erro = new InfoDialog()
				{
					Title = SBText.__("Invalid username"),
					Message = SBText.__("Enter a valid username")
				};
				
				erro.run();
				erro.destroy();
				this.entryUsername.grab_focus();
				return;
			}
			if( password.length <= 0 )
			{
				var erro = new InfoDialog()
				{
					Title = SBText.__("Invalid password"),
					Message = SBText.__("Enter a user password")
				};
				erro.run();
				erro.destroy();
				this.entryPassword.grab_focus();
				return;
			}
			
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
				//stdout.printf("USERNAME: %s\n", (data["user"] as SBUser).Username);
				SBGlobals.SetVar("user", (Object)data["user"]);
				GLib.Source.remove(this.timeoutId);
				this.destroy();
				//this.unref();
			}
			else
			{
				string msg = (string)data["error"];
				var dlg = new InfoDialog("error")
				{
					Title = SBText.__("Local authentication error"),
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
