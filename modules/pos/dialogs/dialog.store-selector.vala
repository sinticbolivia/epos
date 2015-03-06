using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class DialogStoreSelector : Dialog
	{
		protected	Box					content;
		protected	Label				labelTitle;
		
		protected	ScrolledWindow		scroll;
		protected	TreeView			treeviewStores;
		protected	Button				buttonClose;
		protected	Button				buttonSelect;
		
		public DialogStoreSelector()
		{
			this.set_size_request(350, 300);
			this.content	= this.get_content_area();
			this.labelTitle		= new Label(SBText.__("Select Store"));
			this.labelTitle.get_style_context().add_class("widget-title");
			this.labelTitle.show();
			
			this.scroll = new ScrolledWindow(null, null){expand = true};
			this.scroll.show();
			this.treeviewStores	= new TreeView.with_model(new ListStore(3, typeof(int), typeof(string), typeof(string)))
			{
				rules_hint = true
			};
			this.treeviewStores.show();
			this.scroll.add_with_viewport(treeviewStores);
			this.content.add(this.labelTitle);
			this.content.add(this.scroll);
			this.buttonClose = (Button)this.add_button(SBText.__("Cancel"), ResponseType.CANCEL);
			this.buttonSelect = (Button)this.add_button(SBText.__("Select"), ResponseType.OK);
			this.buttonClose.get_style_context().add_class("button-cancel");
			this.buttonSelect.get_style_context().add_class("button-accept");
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			string[,] cols = 
			{
				{SBText.__("Id"), "text", "80", "center", "", ""},
				{SBText.__("Name"), "text", "150", "left", "", ""},
				{SBText.__("Type"), "text", "80", "center", "", ""}
				
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewStores);
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var stores = (ArrayList<SBDBRow>)dbh.GetResults("select * from stores order by store_name ASC");
			
			foreach(SBDBRow row in stores)
			{
				TreeIter iter;
				(this.treeviewStores.model as ListStore).append(out iter);
				(this.treeviewStores.model as ListStore).set(iter, 0, int.parse(row.Get("store_id")), 
										1, row.Get("store_name"),
										2, row.Get("store_type")
				);
			}
		}
		protected void SetEvents()
		{
			this.treeviewStores.row_activated.connect(this.OnTreeViewRowActivated);
			this.buttonClose.clicked.connect(this.OnButtonCloseClicked);
			this.buttonSelect.clicked.connect(this.OnButtonSelectClicked);
		}
		protected void OnTreeViewRowActivated()
		{
			//GLib.Signal.emit_by_name(this, "response");
			GLib.Signal.emit_by_name(this.buttonSelect, "clicked");
		}
		protected void OnButtonCloseClicked()
		{
			this.treeviewStores.get_selection().unselect_all();
			this.destroy();
		}
		protected void OnButtonSelectClicked()
		{
			TreeModel model;
			TreeIter _iter;
			if( !this.treeviewStores.get_selection().get_selected(out model, out _iter) )
			{
				return;
			}
			//GLib.Signal.emit_by_name(this.buttonClose, "clicked");
			this.destroy();
		}
		public SBStore? GetStore()
		{
			TreeModel model;
			TreeIter _iter;
			if( !this.treeviewStores.get_selection().get_selected(out model, out _iter) )
			{
				return null;
			}
			Value v_store_id;
			model.get_value(_iter, 0, out v_store_id);
			var store = new SBStore.from_id((int)v_store_id);
			/*
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var row = dbh.GetRow("select * from stores where store_id = %d".printf((int)v_store_id));
			if( row == null )
				return null;
			var store = new HashMap<string, Value?>();
			store.set("store_id", row.GetInt("store_id"));
			store.set("store_name", row.Get("store_name"));
			store.set("tax_id", row.GetInt("tax_id"));
			store.set("sales_transaction_type_id", row.GetInt("sales_transaction_type_id"));
			*/
			return store;
		}
	}
}
