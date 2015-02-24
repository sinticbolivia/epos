using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace Woocommerce
{
	public class Customer : Object
	{
		protected SBDBRow dbRow;
		
		public		int Id
		{
			get{return this.dbRow.GetInt("customer_id");}
		}
		public		string Code
		{
			get{return this.dbRow.Get("code");}
		}
		public		string Firstname
		{
			get{return this.dbRow.Get("first_name");}
		}
		public		string Lastname
		{
			get{return this.dbRow.Get("last_name");}
		}
		public		string Company
		{
			get{return this.dbRow.Get("company");}
		}
		public		string DateofBirth
		{
			get{return this.dbRow.Get("date_of_birth");}
		}
		public		string Gender
		{
			get{return this.dbRow.Get("gender");}
		}
		public		string Phone
		{
			get{return this.dbRow.Get("phone");}
		}
		public		string Mobile
		{
			get{return this.dbRow.Get("mobile");}
		}
		public		string Email
		{
			get{return this.dbRow.Get("email");}
		}
		public		string Website
		{
			get{return this.dbRow.Get("website");}
		}
		public		string Address1
		{
			get{return this.dbRow.Get("address_1");}
		}
		public		string Address2
		{
			get{return this.dbRow.Get("address_2");}
		}
		public		string Zipcode
		{
			get{return this.dbRow.Get("zip_code");}
		}
		public		string City
		{
			get{return this.dbRow.Get("city");}
		}
		public		string Country
		{
			get{return this.dbRow.Get("country");}
		}
		public		string CountryCode
		{
			get{return this.dbRow.Get("country_code");}
		}
		public Customer()
		{
			this.dbRow = new SBDBRow();
			
		}
		public Customer.from_id(int customer_id)
		{
			this();
			this.GetDbData(customer_id);
		}
		public void GetDbData(int customer_id)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			
			string query = "SELECT * FROM customers WHERE customer_id = %d".printf(customer_id);
			
			var row = dbh.GetRow(query);
			if( row == null )
				return;
			this.dbRow = row;
		}
		public void SetDbData(SBDBRow row)
		{
			this.dbRow = row;
		}
	}
}
