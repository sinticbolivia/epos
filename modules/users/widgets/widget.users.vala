using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	class WidgetUsers : Box
	{
		protected	Builder		ui;
		protected	Window		windowUsers;
		protected 	Box			boxUsers;
		protected	Image		imageUsers;
		protected	Button		buttonNewUser;
		protected	Button		buttonEditUser;
		protected	Button		buttonDeleteUser;
		protected	TreeView	treeviewUsers;
		protected	Label		labelTotalProducts;
		
		protected	static		int instances = 0;
		
		static construct
		{
			WidgetUsers.instances = 0;
		}
		public WidgetUsers()
		{
			//Object();
			this.ui					= (SBModules.GetModule("Users") as SBGtkModule).GetGladeUi("users.glade", "mod_users");
			this.windowUsers		= (Window)this.ui.get_object("windowUsers");
			this.boxUsers			= (Box)this.ui.get_object("boxUsers");
			this.imageUsers			= (Image)this.ui.get_object("imageUsers");
			this.buttonNewUser		= (Button)this.ui.get_object("buttonNewUser");
			this.buttonEditUser		= (Button)this.ui.get_object("buttonEditUser");
			this.buttonDeleteUser	= (Button)this.ui.get_object("buttonDeleteUser");
			this.treeviewUsers		= (TreeView)this.ui.get_object("treeviewUsers");
			this.labelTotalProducts	= (Label)this.ui.get_object("labelTotalProducts");
			
			this.Build();
		
			this.SetEvents();
			this.labelTotalProducts.label = "0";
			this.RefreshUsers();
			this.boxUsers.reparent(this);
		}
		protected void Build()
		{
			try
			{
				this.imageUsers.pixbuf = (SBModules.GetModule("Users") as SBGtkModule).GetPixbuf("system-users-64x64.png");
			}
			catch(GLib.Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			this.treeviewUsers.model = new ListStore(6, 
										typeof(int), 
										typeof(Gdk.Pixbuf), 
										typeof(string), 
										typeof(string),
										typeof(string),
										typeof(string)
			);
			this.treeviewUsers.insert_column_with_attributes(0, 
									SBText.__("Id", "mod_users"), 
									new CellRendererText(){width = 70}, 
									"text", 0);
			this.treeviewUsers.insert_column_with_attributes(1, 
									SBText.__("Image", "mod_users"), 
									new CellRendererPixbuf(){width = 80}, 
									"pixbuf", 1);
			this.treeviewUsers.insert_column_with_attributes(2, 
									SBText.__("Username", "mod_users"), 
									new CellRendererText(){width = 100}, 
									"text", 2);
			this.treeviewUsers.insert_column_with_attributes(3, 
									SBText.__("Email", "mod_users"), 
									new CellRendererText(){width = 150}, 
									"text", 3);
			this.treeviewUsers.get_column(3).resizable = true;
			this.treeviewUsers.insert_column_with_attributes(4, 
									SBText.__("Name", "mod_users"), 
									new CellRendererText(){width = 150}, 
									"text", 4);
			this.treeviewUsers.insert_column_with_attributes(5, 
								SBText.__("Role", "mod_users"), 
								new CellRendererText(){width = 120}, 
								"text", 5);
									
		}
		protected void SetEvents()
		{
			var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
			
			
			this.buttonNewUser.clicked.connect( () => 
			{
				var widget = new WidgetNewUser();
				if( notebook.GetPage("new-user") == null )
				{
					notebook.AddPage("new-user", SBText.__("New User", "mod_users"), widget);
				}
				notebook.SetCurrentPageById("new-user");
			});
			this.buttonEditUser.clicked.connect(this.OnButtonEditUserClicked);
		}
		protected void RefreshUsers()
		{
			(this.treeviewUsers.model as ListStore).clear();
			
			string query = "SELECT * FROM users ORDER BY username ASC";
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var rows = dbh.GetResults(query);
			if( rows.size <= 0 )
			{
				return;
			}
			this.labelTotalProducts.label = "%d".printf(rows.size);
			TreeIter iter;
			Gdk.Pixbuf user_pixbuf =  null;
			try
			{
				
				user_pixbuf = (SBModules.GetModule("Users") as SBGtkModule).GetPixbuf("nobody.png", 80, 80);
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			
			foreach(var row in rows)
			{
				(this.treeviewUsers.model as ListStore).append(out iter);
				(this.treeviewUsers.model as ListStore).set(iter, 
												0, int.parse(row.Get("user_id")),
												1, user_pixbuf,
												2, row.Get("username"),
												3, row.Get("email"),
												4, "%s %s".printf(row.Get("first_name"), row.Get("last_name"))
				);
			}
			
		}
		protected void OnButtonEditUserClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( this.treeviewUsers.get_selection().get_selected(out model, out iter) )
			{
						
				var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
				if( notebook.GetPage("edit-user") == null )
				{
					Value v_user_id;
					model.get_value(iter, 0, out v_user_id);
					
					var user = new SBUser();
					user.GetDbData((int)v_user_id);
					var w = new WidgetEditUser();
					w.SetUser(user);
					notebook.AddPage("edit-user", SBText.__("Edit User (%s)", "mod_users").printf(user.Username), w);
				}
				notebook.SetCurrentPageById("edit-user");
			}
			
		}
	}
}
