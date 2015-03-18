using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetModules : Box
	{
		protected 	Box	headerBox;
		protected 	Image	headerImage;
		protected 	Label	headerLabel;
		protected 	Box	buttonsBox;
		protected	Button	buttonEnable;
		protected	Button	buttonDisable;
		protected	ScrolledWindow scrolled;
		protected 	TreeView	treeview;
		protected	Box	footerButtonsBox;
		protected	Button buttonClose;
		
		public WidgetModules()
		{
			this.orientation = Orientation.VERTICAL;
			this.spacing	= 5;
			
			this.headerBox = new Box(Orientation.HORIZONTAL, 5);
			this.headerImage	= new Image();
			this.headerImage.show();
			this.headerLabel	= new Label(SBText.__("Modules Management"));
			this.headerLabel.show();
			this.headerBox.add(this.headerImage);
			this.headerBox.add(this.headerLabel);
			this.headerBox.show();
			
			this.buttonsBox = new Box(Orientation.HORIZONTAL, 5);
			this.buttonEnable = new Button.with_label(SBText.__("Enable"));
			this.buttonEnable.show();
			this.buttonDisable = new Button.with_label(SBText.__("Disable"));
			this.buttonDisable.show();
			this.buttonsBox.add(this.buttonEnable);
			this.buttonsBox.add(this.buttonDisable);
			this.buttonsBox.show();
			
			this.scrolled = new ScrolledWindow(null, null){expand = true};
			this.scrolled.show();
			this.treeview = new TreeView();
			this.treeview.show();
			this.scrolled.add_with_viewport(this.treeview);
			
			this.footerButtonsBox = new Box(Orientation.HORIZONTAL, 5);
			this.buttonClose = new Button.with_label(SBText.__("Close"));
			this.buttonClose.show();
			this.footerButtonsBox.add(this.buttonClose);
			this.footerButtonsBox.show();
			
			this.add(this.headerBox);
			this.add(this.buttonsBox);
			this.add(this.scrolled);
			this.add(this.footerButtonsBox);
			
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			this.treeview.rules_hint = true;
			this.treeview.model = new ListStore(8, typeof(int), 
													typeof(string), //key
													typeof(string), //name
													typeof(string), //description
													typeof(string), //version
													typeof(string), //status text
													typeof(string), //status key,
													typeof(string) //library name
													
													
			);
			var cell = new CellRendererText();
			this.treeview.insert_column_with_attributes(-1, SBText.__("No."), cell, "text", 0);
			cell = new CellRendererText();
			this.treeview.insert_column_with_attributes(-1, SBText.__("Key"), cell, "text", 1);
			cell = new CellRendererText();
			this.treeview.insert_column_with_attributes(-1, SBText.__("Name"), cell, "text", 2);
			cell = new CellRendererText();
			this.treeview.insert_column_with_attributes(-1, SBText.__("Description"), cell, "text", 3);
			cell = new CellRendererText();
			this.treeview.insert_column_with_attributes(-1, SBText.__("Version"), cell, "text", 4);
			cell = new CellRendererText();
			this.treeview.insert_column_with_attributes(-1, SBText.__("Status"), cell, "text", 5);
			
			this.RetrieveModules();
		}
		protected void SetEvents()
		{
			this.treeview.cursor_changed.connect(this.OnTreeViewCursorChanged);
			this.buttonEnable.clicked.connect(this.OnButtonEnableClicked);
			this.buttonDisable.clicked.connect(this.OnButtonDisableClicked);
		}
		protected void RetrieveModules()
		{
			(this.treeview.model as ListStore).clear();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			SBModules.LoadModules("./modules");
			
			string query = "";
			/*
			dbh.Execute("DELETE FROM modules");
			dbh.Execute("DELETE FROM sqlite_sequence WHERE name = 'modules'");
			*/
			string modules_dir = "./modules";
			var modules = (HashMap<string,ISBModule>)SBModules.GetModules();
			
			int i = 1;
			foreach(string key in modules.keys)
			{
				ISBModule mod = (ISBModule)modules.get(key);
				if( mod.Id == "mod_modules" ) continue;
				
				string status = "disabled";
				string status_text = SBText.__("Disabled");
				
				query = "SELECT module_id, status FROM modules WHERE module_key = '%s' LIMIT 1".printf(mod.Id);
				var row = dbh.GetRow(query);
				if( row == null )
				{
					
				}
				else
				{
					status = "enabled";
				}
				if( status == "disabled" )
					status_text = SBText.__("Disabled");
				else if( status == "enabled" )
				{
					status_text = SBText.__("Enabled");
				}
				
				TreeIter iter;
				(this.treeview.model as ListStore).append(out iter);
				(this.treeview.model as ListStore).set(iter, 
												0, i, 
												1, mod.Id, 
												2, mod.Name, 
												3, mod.Description, 
												4, mod.Version.to_string(),
												5, status_text,
												6, status,
												7, mod.LibraryName
				);
				i++;
			}
		}
		protected void OnTreeViewCursorChanged()
		{
			TreeModel model;
			TreeIter iter;
			if( !this.treeview.get_selection().get_selected(out model, out iter) )
				return;
			Value status_value;
			
			model.get_value(iter, 6, out status_value);
			
			if( (string)status_value == "disabled" )
			{
				this.buttonDisable.sensitive = false;
				this.buttonEnable.sensitive = true;
			}
			else
			{
				this.buttonDisable.sensitive = true;
				this.buttonEnable.sensitive = false;
			}
		}
		protected void OnButtonEnableClicked()
		{
			TreeModel model;
			TreeIter iter;
			if( !this.treeview.get_selection().get_selected(out model, out iter) )
				return;
			Value lib_name_value;
			
			model.get_value(iter, 7, out lib_name_value);
			ISBModule mod = (SBModules.GetModule((string)lib_name_value) as ISBModule);
			string key = mod.Id;
			
			mod.Init();
			mod.Enabled();
			
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM modules WHERE module_key = '%s'".printf(key);
			var row = dbh.GetRow(query);
			if( row == null )
			{
				var nmod = new HashMap<string, Value?>();
				nmod.set("name", mod.Name);
				nmod.set("description", "");
				nmod.set("module_key", mod.Id);
				nmod.set("library_name", mod.LibraryName);
				nmod.set("file", "");
				nmod.set("status", "enabled");
				dbh.Insert("modules", nmod);
			}
			else
			{
				var nmod = new HashMap<string, Value?>();
				nmod.set("status", "enabled");
				var w = new HashMap<string, Value?>();
				w.set("module_key", mod.Id);
				dbh.Update("modules", nmod, w);
			}
			
			var msg = new MessageDialog(null, DialogFlags.MODAL, MessageType.INFO, ButtonsType.CLOSE, 
										SBText.__("The module has been enabled."));
			msg.title = SBText.__("Module");
			msg.run();
			msg.destroy();
			this.RetrieveModules();
		}
		protected void OnButtonDisableClicked()
		{
			TreeModel model;
			TreeIter iter;
			if( !this.treeview.get_selection().get_selected(out model, out iter) )
				return;
			Value lib_name_value;
			
			model.get_value(iter, 7, out lib_name_value);
			ISBModule mod = (SBModules.GetModule((string)lib_name_value) as ISBModule);
			mod.Disabled();
			string query = "DELETE FROM modules WHERE module_key = '%s'".printf(mod.Id);
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Execute(query);
			
			var msg = new MessageDialog(null, DialogFlags.MODAL, MessageType.INFO, ButtonsType.CLOSE, 
										SBText.__("The module has been disabled."));
			msg.title = SBText.__("Module");
			msg.run();
			msg.destroy();
			this.RetrieveModules();
		}
	}
}
