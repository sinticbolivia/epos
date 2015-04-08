using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetCustomerPriceGroups : Object
	{
		public		Label			label1;
		public		ComboBox		comboboxPriceGroups;
		
		public WidgetCustomerPriceGroups()
		{
			//this.spacing = 5;
			//this.orientation = Orientation.HORIZONTAL;
			//this.expand = true;
			this.label1					= new Label(SBText.__("Price Group:"));
			this.comboboxPriceGroups	= new ComboBox();
			this.Build();
		}
		~WidgetCustomerPriceGroups()
		{
			SBModules.remove_action("before_save_customer", this.BeforeSave);
		}
		protected void Build()
		{
			//this.add(this.label1);
			//this.add(this.comboboxPriceGroups);
			//this.show_all();
			this.label1.show();
			this.comboboxPriceGroups.show();
			
			this.comboboxPriceGroups.model = new ListStore(2, typeof(string), typeof(string));
			var cell = new CellRendererText();
			this.comboboxPriceGroups.pack_start(cell, true);
			this.comboboxPriceGroups.set_attributes(cell, "text", 0);
			this.comboboxPriceGroups.id_column = 1;
			TreeIter iter;
			(this.comboboxPriceGroups.model as ListStore).append(out iter);
			(this.comboboxPriceGroups.model as ListStore).set(iter,
				0, SBText.__("-- price group --"),
				1, "-1"
			);
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("price_levels");
			foreach(var row in dbh.GetResults(null))
			{
				(this.comboboxPriceGroups.model as ListStore).append(out iter);
				(this.comboboxPriceGroups.model as ListStore).set(iter,
					0, row.Get("name"),
					1, row.Get("level_id")
				);
			}
			this.comboboxPriceGroups.active_id = "-1";
			
			//##add hooks
			var hook0 = new SBModuleHook(){HookName = "load_customer_data", handler = this.LoadData};
			SBModules.add_action("load_customer_data", ref hook0);
			var hook1 = new SBModuleHook(){HookName = "before_save_customer", handler = this.BeforeSave};
			SBModules.add_action("before_save_customer", ref hook1);
		}
		protected void LoadData(SBModuleArgs<HashMap> args)
		{
			var data = (HashMap<string, Value?>)args.GetData();
			int customer_id = (int)data["customer_id"];
			this.comboboxPriceGroups.active_id = SBMeta.GetMeta("customer_meta", "price_group_id", "customer_id", customer_id);
		}
		protected void BeforeSave(SBModuleArgs<HashMap> args)
		{
			var data = (HashMap<string, Value?>)args.GetData();
			var meta = (HashMap<string,string>)data["meta"];
			meta.set("price_group_id", this.comboboxPriceGroups.active_id);			
		}
	}
}
