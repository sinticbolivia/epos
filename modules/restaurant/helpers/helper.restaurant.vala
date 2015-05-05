using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace Woocommerce
{
	public class RestaurantHelper : Object
	{
		public static Gee.ArrayList<HashMap<string, Value?>> GetEnvironments()
		{
			var records = new ArrayList<HashMap<string, Value?>>();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM rest_environments ORDER BY environment_id ASC";
			if( dbh.Query(query) <= 0 )
				return records;
			foreach(var row in dbh.Rows)
			{
				var data = new HashMap<string, Value?>();
				data.set("environment_id", int.parse(row.Get("environment_id")));
				data.set("name", row.Get("name"));
				data.set("creation_date", row.Get("creation_date"));
				records.add(data);
			}
			
			return records;
		}
		public static ArrayList<HashMap<string, Value?>> GetTables(int env_id = 0)
		{
			var records = new ArrayList<HashMap<string, Value?>>();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "";
			if( env_id > 0 )
				query = "SELECT * FROM rest_tables WHERE environment_id = %d ORDER BY table_id ASC".printf(env_id);
			else
				query = "SELECT * FROM rest_tables ORDER BY name ASC";
			if( dbh.Query(query) <= 0 )
				return records;
			foreach(var row in dbh.Rows)
			{
				var data = new HashMap<string, Value?>();
				data.set("table_id", int.parse(row.Get("table_id")));
				data.set("name", row.Get("name"));
				data.set("creation_date", row.Get("creation_date"));
				records.add(data);
			}
			
			return records;
		}
		public static bool DeleteEnvironment(int env_id)
							requires( env_id > 0 )
		{
			string query = "DELETE FROM rest_environments WHERE environment_id = %d LIMIT 1".printf(env_id);
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.BeginTransaction();
			dbh.Execute(query);
			query = "DELETE FROM rest_tables WHERE environment_id = %d".printf(env_id); 
			dbh.Execute(query);
			dbh.EndTransaction();
			return true;
		}
		public static bool DeleteTable(int table_id)
							requires( table_id > 0 )
		{
			string query = "DELETE FROM rest_tables WHERE table_id = %d LIMIT 1".printf(table_id);
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Execute(query);
			
			return true;
		}
		public static ArrayList<HashMap<string, Value?>> GetOptions()
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM rest_product_ops ORDER BY name ASC";
			var records = (ArrayList<SBDBRow>)dbh.GetResults(query);
			var ops = new ArrayList<HashMap<string, Value?>>();
			if( records.size <= 0 )
				return ops;
				
			foreach(var row in records)
			{
				var op = new HashMap<string, Value?>();
				op.set("option_id", row.GetInt("option_id"));
				op.set("name", row.Get("string"));
				op.set("price", row.GetDouble("price"));
				ops.add(op);
			}
			
			return ops;
		}
	}
}
