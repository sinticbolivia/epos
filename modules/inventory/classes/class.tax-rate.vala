using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace EPos
{
	public class ETaxRate : Object
	{
		protected	SBDBRow		dbData;
		
		public		int 	Id
		{
			get{return this.dbData.GetInt("tax_id");}
		}
		public		string	Name
		{
			get{return this.dbData.Get("name");}
		}
		public		double	Rate
		{
			get{return this.dbData.GetDouble("rate");}
		}
		
		public ETaxRate()
		{
			this.dbData = new SBDBRow();
		}
		public ETaxRate.from_id(int id)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			
			dbh.Select("*").From("tax_rates").Where("tax_id = %d".printf(id));
			var row = dbh.GetRow(null);
			if( row != null )
			{
				this.dbData = row;
			}
		}
	}
}
