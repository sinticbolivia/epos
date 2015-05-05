using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace EPos
{
	public class ESupplier : Object
	{
		protected SBDBRow		dbData;
		
		public int Id
		{
			get{return this.dbData.GetInt("supplier_id");}
		}
		public int StoreId
		{
			get{return this.dbData.GetInt("store_id");}
		}
		public string Name
		{
			get{return this.dbData.Get("supplier_name");}
		}
		public string Address
		{
			get{return this.dbData.Get("supplier_address");}
		}
		public string Telephone1
		{
			get{return this.dbData.Get("supplier_telephone_1");}
		}
		public string Telephone2
		{
			get{return this.dbData.Get("supplier_telephone_2");}
		}
		public string Fax
		{
			get{return this.dbData.Get("fax");}
		}
		public string City
		{
			get{return this.dbData.Get("supplier_city");}
		}
		public string Email
		{
			get{return this.dbData.Get("supplier_email");}
		}
		public string ContactPerson
		{
			get{return this.dbData.Get("supplier_contact_person");}
		}
		public string Key
		{
			get{return this.dbData.Get("supplier_key");}
		}
		public ESupplier()
		{
			this.dbData = new SBDBRow();
		}
		public ESupplier.with_db_data(SBDBRow db_data)
		{
			this.dbData = db_data;
		}
		public ESupplier.from_id(int supplier_id)
		{
			this();
			this.GetDbData(supplier_id);
		}
		public void GetDbData(int supplier_id)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("suppliers").Where("supplier_id = %d".printf(supplier_id));
			var row = dbh.GetRow(null);
			if( row == null )
				return;
			this.dbData = row;
		}
	}
}
