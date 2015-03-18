using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace EPos
{
	public class SBUsersHelper
	{
		public static GLib.List<SBRole> GetRoles()
		{
			var records = new GLib.List<SBRole>();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM user_roles ORDER BY role_name ASC";
			if( dbh.Query( query ) <= 0 )
				return records;
			foreach(var row in dbh.Rows)
			{
				var role = new SBRole();
				role.SetDbData(row);
				records.append(role);
			}
			
			return records;
		}
	}
}
