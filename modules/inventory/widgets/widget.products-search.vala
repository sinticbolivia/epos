using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetProductsSearch : Box
	{
		protected	Builder			ui;
		protected	Box				box1;
		protected	Entry			entrySearch;
		protected	ComboBox		comboboxSearchBy;
		protected	TreeView		treeviewProducts;
		
		public		ListStore		Model
		{
			get{return (ListStore)this.treeviewProducts.model;}
		}
		public		enum 			Columns	
		{
			COUNT,
			ID,
			NAME,
			QUANTITY,
			PRICE,
			N_COLS
		}
		protected	int				storeId = 0;
		public WidgetProductsSearch()
		{
			this.ui		= (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("widget.product-search.glade");
			this.box1	= (Box)this.ui.get_object("box1");
			this.entrySearch		= (Entry)this.ui.get_object("entrySearch");
			this.comboboxSearchBy	= (ComboBox)this.ui.get_object("comboboxSearchBy");
			this.treeviewProducts	= (TreeView)this.ui.get_object("treeviewProducts");
			this.box1.reparent(this);
		}
		protected void Build()
		{
			this.treeviewProducts.model = new ListStore(Columns.N_COLS,
				typeof(int),
				typeof(string),
				typeof(int),
				typeof(string)
			);
			string[,] cols = 
			{
				{"#", "text", "50", "center", "", ""},
				{SBText.__("Product"), "text", "250", "left", "", ""},
				{SBText.__("Qty"), "text", "70", "center", "", ""},
				{SBText.__("Price"), "text", "90", "right", "", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewProducts);
			this.treeviewProducts.rules_hint = true;
		}
		protected void SetEvents()
		{
			this.entrySearch.key_release_event.connect(this.OnEntrySearchKeReleaseEvent);
		}
		public void Refresh(int store_id, ArrayList<SBProduct>? items = null)
		{
			this.storeId = store_id;
			long total_prods = 0;
			(this.treeviewProducts.model as ListStore).clear();
			int i = 1;
			TreeIter iter;
			foreach(var prod in (items != null) ? items : InventoryHelper.GetStoreProducts(store_id, 1, 100, out total_prods))
			{
				this.Model.append(out iter);
				this.Model.set(iter,
					Columns.COUNT, i,
					Columns.ID, prod.Id,
					Columns.NAME, prod.Name,
					Columns.QUANTITY, prod.Quantity,
					Columns.PRICE, "%.2f".printf(prod.Price)
				);
				i++;
			}
			
		}
		protected TreeIter? GetSelected()
		{
			TreeModel model;
			TreeIter iter;
			if( !this.treeviewProducts.get_selection().get_selected(out model, out iter) )
			{
				return null;
			}
			
			return iter;
		}
		protected bool OnEntrySearchKeReleaseEvent(Gdk.EventKey e)
		{
			if( e.keyval != 65293 )
				return true;
			string keyword = this.entrySearch.text.strip();
			if( keyword.length <= 0 )
				return true;
				
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM products WHERE store_id = %d ".printf(this.storeId);
			string search_by = "name";
			if( keyword.index_of(":") != -1 )
			{
				string[] parts = keyword.split(":");
				search_by = parts[0].strip().down();
				keyword		= parts[1].strip();
			}
			else
			{
				//##user combobox as search by
				if( this.comboboxSearchBy.active_id != null && this.comboboxSearchBy.active_id != "-1" )
				{
					search_by = this.comboboxSearchBy.active_id.down();
				}
			}
			if( search_by == "name" )
			{
				query += "AND product_name LIKE '%s'".printf("%" + keyword + "%");
			}
			else if( search_by == "id" )
			{
				query += "AND product_id = %s".printf(keyword);
			}
			else if( search_by == "tag" )
			{
				
			}
			else if( search_by == "code" )
			{
				query += "AND product_code LIKE '%s'".printf("%" + keyword + "%");
			}
			else if( search_by == "barcode" )
			{
				query += "AND product_barcode LIKE '%s'".printf("%" + keyword + "%");
			}
			var prods = new ArrayList<SBProduct>();
			foreach(var row in dbh.GetResults(query))
			{
				var p = new SBProduct.with_db_data(row);
				prods.add(p);
			}
			this.Refresh(this.storeId, prods);
			return true;
		}
	}
}
