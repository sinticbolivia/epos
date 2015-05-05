using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos.Woocommerce
{
	public class WidgetCustomerData : Box
	{
		protected	Builder			ui;
		protected	Box				boxCustomerData;
		protected	Entry			entryBillingFirstName;
		protected	Entry			entryBillingLastName;
		protected	Entry			entryBillingCompany;
		protected	Entry			entryBillingAddress1;
		protected	Entry			entryBillingAddress2;
		protected	Entry			entryBillingCity;
		protected	Entry			entryBillingState;
		protected	Entry			entryBillingPostcode;
		protected	Entry			entryBillingCountry;
		protected	Entry			entryBillingEmail;
		protected	Entry			entryBillingPhone;
		
		protected	Entry			entryShippingFirstName;
		protected	Entry			entryShippingLastName;
		protected	Entry			entryShippingCompany;
		protected	Entry			entryShippingAddress1;
		protected	Entry			entryShippingAddress2;
		protected	Entry			entryShippingCity;
		protected	Entry			entryShippingState;
		protected	Entry			entryShippingPostcode;
		protected	Entry			entryShippingCountry;
		
		protected	CheckButton		checkbutton1;
		
		
		public WidgetCustomerData()
		{
			this.expand = true;
			this.ui	= (SBModules.GetModule("Woocommerce") as SBGtkModule).GetGladeUi("widget.customer-data.glade");
			this.boxCustomerData		= (Box)this.ui.get_object("boxCustomerData");
			this.entryBillingFirstName	= (Entry)this.ui.get_object("entryBillingFirstName");
			this.entryBillingLastName	= (Entry)this.ui.get_object("entryBillingLastName");
			this.entryBillingCompany	= (Entry)this.ui.get_object("entryBillingCompany");
			this.entryBillingAddress1	= (Entry)this.ui.get_object("entryBillingAddress1");
			this.entryBillingAddress2	= (Entry)this.ui.get_object("entryBillingAddress2");
			this.entryBillingCity		= (Entry)this.ui.get_object("entryBillingCity");
			this.entryBillingState		= (Entry)this.ui.get_object("entryBillingState");
			this.entryBillingPostcode	= (Entry)this.ui.get_object("entryBillingPostcode");
			this.entryBillingCountry	= (Entry)this.ui.get_object("entryBillingCountry");
			this.entryBillingEmail		= (Entry)this.ui.get_object("entryBillingEmail");
			this.entryBillingPhone		= (Entry)this.ui.get_object("entryBillingPhone");
			this.checkbutton1			= (CheckButton)this.ui.get_object("checkbutton1");
			this.entryShippingFirstName	= (Entry)this.ui.get_object("entryShippingFirstName");
			this.entryShippingLastName	= (Entry)this.ui.get_object("entryShippingLastName");
			this.entryShippingCompany	= (Entry)this.ui.get_object("entryShippingCompany");
			this.entryShippingAddress1	= (Entry)this.ui.get_object("entryShippingAddress1");
			this.entryShippingAddress2	= (Entry)this.ui.get_object("entryShippingAddress2");
			this.entryShippingCity		= (Entry)this.ui.get_object("entryShippingCity");
			this.entryShippingState		= (Entry)this.ui.get_object("entryShippingState");
			this.entryShippingPostcode	= (Entry)this.ui.get_object("entryShippingPostcode");
			this.entryShippingCountry	= (Entry)this.ui.get_object("entryShippingCountry");
			this.boxCustomerData.reparent(this);
			this.Build();
			this.SetEvents();
			var hook1 = new SBModuleHook(){HookName = "after_create_customer", handler = this.Save};
			SBModules.add_action("after_create_customer", ref hook1);
			var hook2 = new SBModuleHook(){HookName = "view_customer_details_dlg", handler = this.ViewData};
			SBModules.add_action("view_customer_details_dlg", ref hook2);
		}
		~WidgetCustomerData()
		{
			stdout.printf("Destroying WidgetCustomerData\n");
			SBModules.remove_action("after_create_customer", this.Save);
			SBModules.remove_action("view_customer_details_dlg", this.ViewData);
		}
		protected void Build()
		{
		}
		protected void SetEvents()
		{
			this.checkbutton1.clicked.connect(this.OnCheckButtonSameDataClicked);
		}
		protected void OnCheckButtonSameDataClicked()
		{
			if( this.checkbutton1.active )
			{
				this.entryShippingFirstName.text = this.entryBillingFirstName.text;
				this.entryShippingLastName.text = this.entryBillingLastName.text;
				this.entryShippingCompany.text = this.entryBillingCompany.text;
				this.entryShippingAddress1.text = this.entryBillingAddress1.text;
				this.entryShippingAddress2.text = this.entryBillingAddress2.text;
				this.entryShippingCity.text = this.entryBillingCity.text;
				this.entryShippingState.text = this.entryBillingState.text;
				this.entryShippingPostcode.text = this.entryBillingPostcode.text;
				this.entryShippingCountry.text = this.entryBillingCountry.text;
			}
			else
			{
				this.entryShippingFirstName.text = "";
				this.entryShippingLastName.text = "";
				this.entryShippingCompany.text = "";
				this.entryShippingAddress1.text = "";
				this.entryShippingAddress2.text = "";
				this.entryShippingCity.text = "";
				this.entryShippingState.text = "";
				this.entryShippingPostcode.text = "";
				this.entryShippingCountry.text = "";
			}
		}
		protected void Save(SBModuleArgs<HashMap> args)
		{
			var data = (HashMap<string, Value?>)args.GetData();
			int customer_id = (int)data["customer_id"];
			if( customer_id <= 0 )
				return;
				
			var dbh = (SBDatabase)data["dbh"];
			string billing_firstname = this.entryBillingFirstName.text.strip();
			string billing_lastname = this.entryBillingLastName.text.strip();
			string billing_company	= this.entryBillingCompany.text.strip();
			string billing_address1 = this.entryBillingAddress1.text.strip();
			string billing_address2 = this.entryBillingAddress2.text.strip();
			string billing_city		= this.entryBillingCity.text.strip();
			string billing_state	= this.entryBillingState.text.strip();
			string billing_postcode	= this.entryBillingPostcode.text.strip();
			string billing_country	= this.entryBillingCountry.text.strip().up();
			string billing_email	= this.entryBillingEmail.text.strip();
			string billing_phone	= this.entryBillingPhone.text.strip();
			//##get shipping address
			string shipping_firstname 	= this.entryShippingFirstName.text.strip();
			string shipping_lastname 	= this.entryShippingLastName.text.strip();
			string shipping_company		= this.entryShippingCompany.text.strip();
			string shipping_address1 	= this.entryShippingAddress1.text.strip();
			string shipping_address2 	= this.entryShippingAddress2.text.strip();
			string shipping_city		= this.entryShippingCity.text.strip();
			string shipping_state		= this.entryShippingState.text.strip();
			string shipping_postcode	= this.entryShippingPostcode.text.strip();
			string shipping_country		= this.entryShippingCountry.text.strip().up();
			
			SBMeta.UpdateMeta("customer_meta", "billing_first_name", billing_firstname, "customer_id", customer_id, dbh);
			SBMeta.UpdateMeta("customer_meta", "billing_last_name", billing_lastname, "customer_id", customer_id, dbh);
			SBMeta.UpdateMeta("customer_meta", "billing_city", billing_city, "customer_id", customer_id, dbh);
			SBMeta.UpdateMeta("customer_meta", "billing_company", billing_company, "customer_id", customer_id, dbh);
			SBMeta.UpdateMeta("customer_meta", "billing_address_1", billing_address1, "customer_id", customer_id, dbh);
			SBMeta.UpdateMeta("customer_meta", "billing_address_2", billing_address2, "customer_id", customer_id, dbh);
			SBMeta.UpdateMeta("customer_meta", "billing_city", billing_city, "customer_id", customer_id, dbh);
			SBMeta.UpdateMeta("customer_meta", "billing_state", billing_state, "customer_id", customer_id, dbh);
			SBMeta.UpdateMeta("customer_meta", "billing_postcode", billing_postcode, "customer_id", customer_id, dbh);
			SBMeta.UpdateMeta("customer_meta", "billing_country", billing_country, "customer_id", customer_id, dbh);
			SBMeta.UpdateMeta("customer_meta", "billing_email", billing_email, "customer_id", customer_id, dbh);
			SBMeta.UpdateMeta("customer_meta", "billing_phone", billing_phone, "customer_id", customer_id, dbh);
			//##update sihpping address
			SBMeta.UpdateMeta("customer_meta", "shipping_first_name", shipping_firstname, "customer_id", customer_id, dbh);
			SBMeta.UpdateMeta("customer_meta", "shipping_last_name", shipping_lastname, "customer_id", customer_id, dbh);
			SBMeta.UpdateMeta("customer_meta", "shipping_company", shipping_company, "customer_id", customer_id, dbh);
			SBMeta.UpdateMeta("customer_meta", "shipping_address_1", shipping_address1, "customer_id", customer_id, dbh);
			SBMeta.UpdateMeta("customer_meta", "shipping_address_2", shipping_address2, "customer_id", customer_id, dbh);
			SBMeta.UpdateMeta("customer_meta", "shipping_city", shipping_city, "customer_id", customer_id, dbh);
			SBMeta.UpdateMeta("customer_meta", "shipping_state", shipping_state, "customer_id", customer_id, dbh);
			SBMeta.UpdateMeta("customer_meta", "shipping_postcode", shipping_postcode, "customer_id", customer_id, dbh);
			SBMeta.UpdateMeta("customer_meta", "shipping_country", shipping_country, "customer_id", customer_id, dbh);
		}
		protected void ViewData(SBModuleArgs<SBCustomer> args)
		{
			var customer = (SBCustomer)args.GetData();
			this.entryBillingFirstName.text = (customer.Meta["billing_first_name"] != null) ? customer.Meta["billing_first_name"] : "";;
			this.entryBillingLastName.text = (customer.Meta["billing_last_name"] != null) ? customer.Meta["billing_last_name"] : "";;
			this.entryBillingCompany.text = (customer.Meta["billing_company"] != null) ? customer.Meta["billing_company"] : "";
			this.entryBillingAddress1.text = (customer.Meta["billing_address_1"] != null) ? customer.Meta["billing_address_1"] : "";
			this.entryBillingAddress2.text = (customer.Meta["billing_address_2"] != null) ? customer.Meta["billing_address_2"] : "";
			this.entryBillingCity.text = (customer.Meta["billing_city"] != null) ? customer.Meta["billing_city"] : "";
			this.entryBillingState.text = (customer.Meta["billing_state"] != null) ? customer.Meta["billing_state"] : "";
			this.entryBillingPostcode.text = (customer.Meta["billing_postcode"] != null) ? customer.Meta["billing_postcode"] : "";
			this.entryBillingCountry.text = (customer.Meta["billing_country"] != null) ? customer.Meta["billing_country"] : "";
			this.entryBillingEmail.text = (customer.Meta["billing_email"] != null) ? customer.Meta["billing_email"] : "";
			this.entryBillingPhone.text = (customer.Meta["billing_phone"] != null) ? customer.Meta["billing_phone"] : "";
			//##set shipping address
			this.entryShippingFirstName.text = (customer.Meta["shipping_first_name"] != null) ? customer.Meta["shipping_first_name"] : "";;
			this.entryShippingLastName.text = (customer.Meta["shipping_last_name"] != null) ? customer.Meta["shipping_last_name"] : "";;
			this.entryShippingCompany.text = (customer.Meta["shipping_company"] != null) ? customer.Meta["shipping_company"] : "";
			this.entryShippingAddress1.text = (customer.Meta["shipping_address_1"] != null) ? customer.Meta["shipping_address_1"] : "";
			this.entryShippingAddress2.text = (customer.Meta["shipping_address_2"] != null) ? customer.Meta["shipping_address_2"] : "";
			this.entryShippingCity.text = (customer.Meta["shipping_city"] != null) ? customer.Meta["shipping_city"] : "";
			this.entryShippingState.text = (customer.Meta["shipping_state"] != null) ? customer.Meta["shipping_state"] : "";
			this.entryShippingPostcode.text = (customer.Meta["shipping_postcode"] != null) ? customer.Meta["shipping_postcode"] : "";
			this.entryShippingCountry.text = (customer.Meta["shipping_country"] != null) ? customer.Meta["shipping_country"] : "";
			
		}
	}
}
