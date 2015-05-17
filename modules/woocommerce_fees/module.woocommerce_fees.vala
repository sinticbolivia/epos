using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Database;
using SinticBolivia.Gtk;

namespace EPos.Woocommerce
{
	public class SB_ModuleWoocommerceFees : SBGtkModule, ISBModule
	{
		public string Id{get{return this._moduleId;}}
		public string Name{get{return this._name;}}
		public string Description{get{return this._description;}}
		public string Author{get{return this._author;}}
		public double Version{get{return this._version;}}
		public string LibraryName{get{return "WoocommerceFees";}}
		public string	Dependencies{get{return "Pos";}}
		protected	Window				windowFees;
		protected	WidgetOrderFees		widgetFees;
		protected	Label				labelTotalFee;
		protected	Label				labelOrderTotal;
		protected	SBDatabase			dbh;
		
		construct
		{
			this._moduleId 		= "mod_woocommerce_fees";
			this._name			= "Woocommerce Custom Fees";
			this._description 	= "Add custom fees to your woocommerce order.";
			this._author 		= "Sintic Bolivia";
			this._version 		= 1.0;
			this.resourceFile 	= "./modules/woocommerce_fees.gresource";
			this.resourceNs		= "/net/sinticbolivia/Pos/Woocommerce/Fees";
		}
		public void Enabled()
		{
			this.LoadResources();
		}
		public void Disabled()
		{
		}
		public void Load()
		{
				
		}
		public void Unload()
		{
		}
		public void Init()
		{
			this.LoadResources();
			this.AddHooks();
		}
		protected void AddHooks()
		{
			var hook0 = new SBModuleHook(){HookName = "before_register_sale", handler = hook_before_register_sale};
			SBModules.add_action("before_register_sale", ref hook0);
			var hook1 = new SBModuleHook(){HookName = "pos_buttons", handler = hook_pos_buttons};
			SBModules.add_action("pos_buttons", ref hook1);
			var hook2 = new SBModuleHook(){HookName = "pos_totals_grid", handler = hook_pos_totals_grid};
			SBModules.add_action("pos_totals_grid", ref hook2);
			var hook3 = new SBModuleHook(){HookName = "pos_calculate_totals", handler = hook_pos_calculate_totals};
			SBModules.add_action("pos_calculate_totals", ref hook3);
			
			var hook4 = new SBModuleHook(){HookName = "wc_before_send_order", handler = hook_wc_before_send_order};
			SBModules.add_action("wc_before_send_order", ref hook4);
			
		}
		protected void hook_before_register_sale(SBModuleArgs<HashMap> args)
		{
			var data = (HashMap<string, Value?>)args.GetData();
			var store = (SBStore)data["store"];
			if( store.Get("store_type") != "woocommerce" )
				return;
				
			
			var meta = (HashMap<string, Value?>)data["sale_meta"];
			meta.set("wc_total_fee", this.labelTotalFee.label);
			string[,] fees = this.widgetFees.GetFees();
			string fees_str = "";
			for(int i = 0; i < fees.length[0]; i++)
			{
				fees_str += "%s,%s,%s,%s,%s,%s|".printf(fees[i,0], fees[i,1], fees[i,2], fees[i,3], fees[i,4], fees[i,5]);
			}
			meta.set("wc_fees", fees_str.substring(0, fees_str.length - 1));
			this.labelTotalFee.label = "0.00";
			
		}
		protected void hook_pos_buttons(SBModuleArgs<HashMap> args)
		{
			var data 	= (HashMap<string, Value?>)args.GetData();
			var buttons = (ArrayList<Button>)data["buttons"];
			this.dbh	= (SBDatabase)data["dbh"];
			var button_add_fee = new Button.with_label(SBText.__("Add Fee\n(F10)"));
			button_add_fee.clicked.connect( this.OnButtonAddFeeClicked );
			buttons.add(button_add_fee);
		}
		protected void OnButtonAddFeeClicked()
		{
			if( this.windowFees == null )
			{
				this.widgetFees = new WidgetOrderFees();
				this.widgetFees.show();
				this.widgetFees.buttonClose.clicked.connect( () => 
				{
					double order_total 	= double.parse(this.labelOrderTotal.get_data<string>("total_before_hook"));
					double fee_total 	= this.widgetFees.GetTotal();
					this.labelTotalFee.label = "%.2f".printf(fee_total);
					this.labelOrderTotal.label = "%.2f".printf(fee_total + order_total);
					this.windowFees.hide();
				});
				this.windowFees = new Window()
				{
					title = SBText.__("Order Fees"),
					modal = true
				};
				this.windowFees.add( this.widgetFees );
			}
			this.widgetFees.Taxes = EPosHelper.GetTaxes();
			this.windowFees.show();
		}
		protected void hook_pos_totals_grid(SBModuleArgs<Grid> args)
		{
			var label = new Label(SBText.__("Total Fee:")){xalign = 1};
			label.show();
			this.labelTotalFee = new Label("0.00"){xalign = 1};
			this.labelTotalFee.show();
			
			var grid = (Grid)args.GetData();
			grid.insert_row(2);
			grid.attach(label, 0, 2, 1, 1);
			grid.attach(this.labelTotalFee, 1, 2, 1, 1);
			
			grid.get_children().foreach( (w) => 
			{
				//stdout.printf("Widget: %s, type: %s\n", w.name, w.get_type().name());
				if( w.name == "label-total" )
				{
					this.labelOrderTotal = (Label)w;
					//grid.attach_next_to(label, w, PositionType.BOTTOM, 1, 1);
					//grid.attach_next_to(this.labelTotalFee, label, PositionType.RIGHT, 1, 1);
				}
			});
			
		}
		protected void hook_pos_calculate_totals(SBModuleArgs<HashMap<string, double?>> args)
		{
			if( this.widgetFees == null )
				return;
			var data = (HashMap<string, double?>)args.GetData();
			if( data.has_key("added_total") )
			{
				data["added_total"] = ((double)data["added_total"]) + this.widgetFees.GetTotal();
			}
			else
			{
				data.set("added_total", this.widgetFees.GetTotal());
			}
			
		}
		protected void hook_wc_before_send_order(SBModuleArgs<Json.Object> args)
		{
			var data  = (HashMap<string, Value?>)args.GetData();
			var order = (ESale)data["order"];
			var json_order = (Json.Object)data["json_order"];
			if( order.Meta["wc_fees"] != null )
			{
				var fee_lines = new Json.Array();
				json_order.set_array_member("fee_lines", fee_lines);
				
				string[] fees = ((string)order.Meta["wc_fees"]).split("|");
				foreach(string fee in fees)
				{
					string[] parts = fee.strip().split(",");
					if( parts.length < 5 ) continue;
					
					string title 	= parts[1];
					double amount	= double.parse(parts[2]);
					double total 	= double.parse(parts[5]);
					
					var json_fee 	= new Json.Object();
					var tax_data	= new Json.Array();
					json_fee.set_string_member("title", title);
					json_fee.set_double_member("total", amount);
					json_fee.set_array_member("tax_data", tax_data);
					
					if( parts[3] != "" && parts[3] != "-1" )
					{
						json_fee.set_boolean_member("taxable", true);
						json_fee.set_string_member("tax_class", parts[3]);
						json_fee.set_double_member("total_tax", double.parse(parts[4]));
						tax_data.add_double_element(total - amount);
					}
					
					fee_lines.add_object_element(json_fee);
				} 
			}
		}
	}
}
public Type sb_get_module_libwoocommercefees_type(Module mod)
{
	return typeof(EPos.Woocommerce.SB_ModuleWoocommerceFees);
}
