using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetAssemblies : Box
	{
		protected	Builder			ui;
		protected	Box				boxAssemblies;
		protected	Image			image1;
		protected	Button			buttonAdd;
		protected	Button			buttonEdit;
		protected	Button			buttonDelete;
		protected	ComboBox		comboboxStore;
		protected	TreeView		treeviewAssemblies;
		
		public WidgetAssemblies()
		{
			this.ui						= (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("assemblies.glade");
			this.boxAssemblies			= (Box)this.ui.get_object("boxAssemblies");
			this.image1					= (Image)this.ui.get_object("image1");
			this.buttonAdd				= (Button)this.ui.get_object("buttonAdd");
			this.buttonEdit				= (Button)this.ui.get_object("buttonEdit");
			this.buttonDelete			= (Button)this.ui.get_object("buttonDelete");
			this.comboboxStore			= (ComboBox)this.ui.get_object("comboboxStore");
			this.treeviewAssemblies		= (TreeView)this.ui.get_object("treeviewAssemblies");
			this.Build();
			this.Refresh();
			this.SetEvents();
			this.boxAssemblies.reparent(this);
		}
		protected void Build()
		{
			try
			{
				this.image1.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("assembly-64x64.png");
			}
			catch(GLib.Error e)
			{
				stdout.printf("ERROR: %s\n".printf(e.message));
			}
			this.comboboxStore.model = new ListStore(2, typeof(string), typeof(string));
			var cell = new CellRendererText();
			this.comboboxStore.pack_start(cell, false);
			this.comboboxStore.set_attributes(cell, "text", 0);
			this.comboboxStore.id_column = 1;
			TreeIter iter;
			(this.comboboxStore.model as ListStore).append(out iter);
			(this.comboboxStore.model as ListStore).set(iter, 
				0, SBText.__("-- store --"),
				1, "-1"
			);
			
			foreach(var store in Woocommerce.InventoryHelper.GetStores())
			{
				(this.comboboxStore.model as ListStore).append(out iter);
				(this.comboboxStore.model as ListStore).set(iter, 
					0, store.Name,
					1, store.Id.to_string()
				);
			}
			
			this.comboboxStore.active_id = "-1";
			
			this.treeviewAssemblies.model = new ListStore(4, 
				typeof(int), 
				typeof(string), 
				typeof(string), 
				typeof(int)
			);
			string[,] cols = 
			{
				{"#", "text", "90", "center", "", ""},
				{SBText.__("Code"), "text", "150", "left", "", ""},
				{SBText.__("Name"), "text", "250", "left", "", ""},
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewAssemblies);
		}
		protected void SetEvents()
		{
			this.buttonAdd.clicked.connect(this.OnButtonAddClicked);
			this.buttonEdit.clicked.connect(this.OnButtonEditClicked);
			this.buttonDelete.clicked.connect(this.OnButtonDeleteClicked);
		}
		protected void Refresh()
		{
			(this.treeviewAssemblies.model as ListStore).clear();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("assemblies");
			TreeIter iter;
			int i = 1;
			foreach(var row in dbh.GetResults(null))
			{
				(this.treeviewAssemblies.model as ListStore).append(out iter);
				(this.treeviewAssemblies.model as ListStore).set(iter, 
					0, i, 
					1, row.Get("code"),
					2, row.Get("name"),
					3, row.GetInt("assembly_id")
				);
				i++;
			}
		}
		protected void OnButtonAddClicked()
		{
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1")
			{
				var dlg = new InfoDialog("error")
				{
					Title 	= SBText.__("Error"),
					Message = SBText.__("You need to select a store.")
				};
				dlg.run();
				dlg.destroy();
				this.comboboxStore.grab_focus();
				
				return;
			}
			var w = new WindowNewAssembly();
			w.StoreId = int.parse(this.comboboxStore.active_id);
			w.show();
			w.destroy.connect( () => {this.Refresh();});
		}
		protected void OnButtonEditClicked()
		{
			TreeModel model;
			TreeIter iter;
			if( this.comboboxStore.active_id == null || this.comboboxStore.active_id == "-1")
			{
				var dlg = new InfoDialog("error")
				{
					Title 	= SBText.__("Error"),
					Message = SBText.__("You need to select a store.")
				};
				dlg.run();
				dlg.destroy();
				this.comboboxStore.grab_focus();
				
				return;
			}
			if( !this.treeviewAssemblies.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			//##get assembly id
			Value id;
			model.get_value(iter, 3, out id);
			var w = new WindowNewAssembly();
			w.StoreId = int.parse(this.comboboxStore.active_id);
			w.SetAssembly(new EAssembly.from_id((int)id));
			w.show();
			w.destroy.connect( () => {this.Refresh();});
		}
		protected void OnButtonDeleteClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewAssemblies.get_selection().get_selected(out model, out iter) )
			{
				return;
			}
			var confirm = new InfoDialog("info")
			{
				Title = SBText.__("Confirm deletion"),
				Message = SBText.__("Are you sure to delete the assembly?")
			};
			confirm.add_button(SBText.__("Yes"), ResponseType.YES).get_style_context().add_class("button-green");
			if( confirm.run() == ResponseType.YES )
			{
				Value id;
				model.get_value(iter, 3, out id);
				var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
				string query = "DELETE FROM assemblie2product WHERE assembly_id = %d".printf((int)id);
				dbh.Execute(query);
				query = "DELETE FROM assemblies WHERE assembly_id = %d".printf((int)id);
				dbh.Execute(query);
				this.Refresh();
			}
			confirm.destroy();
			
		}
	}
}
