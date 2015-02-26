using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetRetailPos : Box
	{
		protected	Builder			ui;
		protected	Box				boxRetailPos;
		protected	Image			imageCustomer;
		protected	TreeView		treeviewOrderItems;
		enum Columns
		{
			COUNT,
			PRODUCT_CODE,
			PRODUCT_NAME,
			QUANTITY,
			UOM,
			PRICE,
			TAX,
			TOTAL,
			PRODUCT_ID,
			N_COLS
		}
		public WidgetRetailPos()
		{
			this.ui			= (SBModules.GetModule("Pos") as SBGtkModule).GetGladeUi("retail-pos.glade");
			this.boxRetailPos		= (Box)this.ui.get_object("boxRetailPos");
			this.imageCustomer		= (Image)this.ui.get_object("imageCustomer");
			this.treeviewOrderItems = (TreeView)this.ui.get_object("treeviewOrderItems");
			this.boxRetailPos.reparent(this);
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			this.imageCustomer.pixbuf = (SBModules.GetModule("Pos") as SBGtkModule).GetPixbuf("customer-48x48.png");
			this.treeviewOrderItems.model = new ListStore(Columns.N_COLS,
				typeof(int), //count
				typeof(string), //product code
				typeof(string), //product name
				typeof(int), //quantity
				typeof(string), //UOM
				typeof(string), //price
				typeof(string), //tax
				typeof(string), //total
				typeof(int) //product id
			);
			string[,] cols= 
			{
				{"#", "text", "60", "right", "", ""},
				{SBText.__("Code"), "text", "120", "left", "", ""},
				{SBText.__("Product"), "text", "200", "left", "", ""},
				{SBText.__("Quantity"), "text", "80", "center", "editable", ""},
				{SBText.__("U.O.M."), "text", "120", "left", "", ""},
				{SBText.__("Price"), "text", "120", "right", "", ""},
				{SBText.__("Tax"), "text", "120", "right", "", ""},
				{SBText.__("Total"), "text", "120", "right", "", ""},
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewOrderItems);
			this.treeviewOrderItems.rules_hint = true;
		}
		protected void SetEvents()
		{
		}
	}
}
