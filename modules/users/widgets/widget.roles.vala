using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Database;
using SinticBolivia.Gtk;

namespace EPos
{
	class WidgetRoles : Box
	{
		protected	Builder		ui;
		protected	Window		windowRoles;
		protected	Box			boxRoles;
		protected	Image		imageRoles;
		protected	TreeView	treeviewRoles;
		protected	Button		buttonNewRole;
		protected	Button		buttonEditRole;
		protected	Box			box3;
		protected	Entry		entryRoleName;
		protected	Button		buttonCancelRole;
		protected	Button		buttonSaveRole;
		
		protected	Grid		gridPermissions;
		protected	int			_role_id = 0;
		
		private		static		int		instances;
		
		static construct
		{
			WidgetRoles.instances = 0;
		}
		public WidgetRoles()
		{
			Object();
			this.ui				= (SBModules.GetModule("Users") as SBGtkModule).GetGladeUi("roles.glade");
			this.windowRoles	= (Window)this.ui.get_object("windowRoles");
			this.boxRoles		= (Box)this.ui.get_object("boxRoles");
			this.imageRoles		= (Image)this.ui.get_object("imageRoles");
			this.treeviewRoles	= (TreeView)this.ui.get_object("treeviewRoles");
			this.buttonNewRole	= (Button)this.ui.get_object("buttonNewRole");
			this.buttonEditRole	= (Button)this.ui.get_object("buttonEditRole");
			this.entryRoleName	= (Entry)this.ui.get_object("entryRoleName");
			this.buttonCancelRole	= (Button)this.ui.get_object("buttonCancelRole");
			this.buttonSaveRole		= (Button)this.ui.get_object("buttonSaveRole");
			this.box3				= (Box)this.ui.get_object("box3");
			this.gridPermissions	= (Grid)this.ui.get_object("gridPermissions");
		
			this.Build();				
			this.SetEvents();
			this.RefreshRoles();
			this.boxRoles.reparent(this);
		}
		protected void Build()
		{
			try
			{
				this.imageRoles.pixbuf			= (SBModules.GetModule("Users") as SBGtkModule).GetPixbuf("roles-icon-64x64.png");
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
			
			this.treeviewRoles.model = new ListStore(2, typeof(int), typeof(string));
			this.treeviewRoles.insert_column_with_attributes(0, "Id", new CellRendererText(){width = 70}, "text", 0);
			this.treeviewRoles.insert_column_with_attributes(1, "Role name", new CellRendererText(){width = 200}, "text", 1);
			
		}
		protected void SetEvents()
		{
			this.destroy.connect( () => 
			{
				this.boxRoles.reparent(this.windowRoles);
			});
			this.buttonNewRole.clicked.connect(this.OnButtonNewRoleClicked);
			this.buttonEditRole.clicked.connect(this.OnButtonEditRoleClicked);
			this.buttonSaveRole.clicked.connect(this.OnButtonSaveRoleClicked);
		}
		protected void RefreshRoles()
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			(this.treeviewRoles.model as ListStore).clear();
			
			dbh.Select("*").From("user_roles");
			foreach(var row in dbh.GetResults(null))
			{
				TreeIter iter;
				(this.treeviewRoles.model as ListStore).append(out iter);
				(this.treeviewRoles.model as ListStore).set(iter, 
														0, int.parse(row.Get("role_id")),
														1, row.Get("role_name")
				);
			}
			//delete grid childs
			this.gridPermissions.foreach( (child) => 
			{
				child.dispose();
			});
			
			dbh.Select("*").From("permissions");
			
			int gcol = 0, grow = 0;
			foreach(var row in dbh.GetResults(null))
			{
				//var box = new Box(Orientation.HORIZONTAL, 5);
				var check = new CheckButton.with_label(row.Get("label"));
				check.set_data<string>("perm", row.Get("permission"));
				check.set_data<int>("perm_id", int.parse(row.Get("permission_id")));
				check.show();
				//box.add(check);
				//box.show();
				this.gridPermissions.attach(check, gcol, grow, 1, 1);
				gcol++;
				if(gcol == 3)
				{
					gcol = 0;
					grow++;
				}
			}
			
		}
		protected void OnButtonNewRoleClicked()
		{
			this._role_id = 0;
			this.entryRoleName.text = "";
			
			this.gridPermissions.foreach( (child) => 
			{
				(child as CheckButton).active = false;
			});
			this.entryRoleName.grab_focus();
		}
		protected void OnButtonEditRoleClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewRoles.get_selection().get_selected(out model, out iter) )
				return;
			Value v_rid;
			model.get_value(iter, 0, out v_rid);
			
			var role = new SBRole();
			role.GetDbData((int)v_rid);
			this.entryRoleName.text = role.Name;
						
			this.gridPermissions.foreach( (child) => 
			{
				if( role.HasPermission(child.get_data<string>("perm")) )
				{
					(child as CheckButton).active = true;
				}
				else
				{
					(child as CheckButton).active = false;
				}
				//stdout.printf("pem_id: %d\n", child.get_data<int>("permission_id"));
			});
			this._role_id = role.Id;
		}
		protected void OnButtonSaveRoleClicked()
		{
			string role_name = this.entryRoleName.text.strip();
			if( role_name.length <= 0 )
			{
				this.entryRoleName.grab_focus();
				return;
			}
			var dbh		= (SBDatabase)SBGlobals.GetVar("dbh");
			var date = new DateTime.now_local();
			var data = new HashMap<string, Value?>();
			data.set("role_name", role_name);
			data.set("last_modification_date", date.format("%Y-%m-%d %H:%M:%S"));
			dbh.BeginTransaction();
			if( this._role_id > 0 )
			{
				var w = new HashMap<string, Value?>();
				w.set("role_id", this._role_id);
				dbh.Update("user_roles", data, w);
				//##update permissions
				string query = "DELETE FROM role2permission WHERE role_id = %d".printf(this._role_id);
				dbh.Execute(query);
				
				//query = "INSERT INTO role2permission (role_id, permission_id, creation_date) VALUES";
				this.gridPermissions.foreach( (check) => 
				{
					if( (check as CheckButton).active )
					{
						int perm_id = check.get_data<int>("perm_id");
						var row = new HashMap<string, Value?>();
						row.set("role_id", this._role_id);
						row.set("permission_id", perm_id);
						row.set("creation_date", date.format("%Y-%m-%d %H-%M-%S"));
						dbh.Insert("role2permission", row);
					}
				});
				
				var msg = new InfoDialog()
				{
					Title = SBText.__("Role Updated"),
					Message = SBText.__("The role has been updated.")
				};
				
				msg.run();
				msg.dispose();
				
			}
			else
			{
				data.set("creation_date", date.format("%Y-%m-%d %H-%M-%S"));
				int role_id = (int)dbh.Insert("user_roles", data);
				var msg = new MessageDialog(null, DialogFlags.MODAL, MessageType.INFO, ButtonsType.OK, 
											"The role has been created."
				);
				this.gridPermissions.foreach( (check) => 
				{
					if( (check as CheckButton).active )
					{
						int perm_id = check.get_data<int>("perm_id");
						var row = new HashMap<string, Value?>();
						row.set("role_id", role_id);
						row.set("permission_id", perm_id);
						row.set("creation_date", date.format("%Y-%m-%d %H-%M-%S"));
						dbh.Insert("role2permission", row);
					}
				});
				msg.title = "New Role Created";
				msg.run();
				msg.dispose();
			}
			dbh.EndTransaction();
			this.RefreshRoles();
			this._role_id = 0;
		}
	}
}
