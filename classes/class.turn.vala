using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace Woocommerce
{
	public class ECTurn : Object
	{
		protected SBDBRow dbData;
		
		public int	Id
		{
			get{return this.dbData.GetInt("turn_id");}
			set{this.dbData.Set("turn_id", value.to_string());}
		}
		public int	UserId
		{
			get{return this.dbData.GetInt("user_id");}
		}
		public int	TerminalId
		{
			get{return this.dbData.GetInt("terminal_id");}
		}
		public int	StoreId
		{
			get{return this.dbData.GetInt("store_id");}
		}
		public string	OpenDate
		{
			get{return "";}
		}
		public string	CloseDate
		{
			get{return "";}
		}
		public string	Status
		{
			get{return this.dbData.Get("status");}
		}
		
		public ECTurn()
		{
			this.dbData = new SBDBRow();
		}
		public ECTurn.from_id(int turn_id)
						requires(turn_id > 0)
		{
			this();
			this.GetDbData(turn_id);
		}
		public void GetDbData(int turn_id)
		{
			string query = "SELECT * FROM turns WHERE turn_id = %d LIMIT 1".printf(turn_id);
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var records = (ArrayList<SBDBRow>)dbh.GetResults(query);
			if(records.size <= 0)
				return;
			this.dbData = records.get(0);
			
		}
		public void SetDbData(SBDBRow row)
		{
			this.dbData = row;
		}
		public bool Create(int store_id, int user_id, int terminal_id, string notes = "")
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var data = new HashMap<string, Value?>();
			data.set("user_id", user_id);
			data.set("store_id", store_id);
			data.set("terminal_id", terminal_id);
			data.set("initial_amount", 0.00);
			data.set("final_amount", 0.00);
			data.set("status", "created");
			data.set("creation_date", new DateTime.now_local().format("%Y-%-m%-d %H:%M:%s"));
			long turn_id = dbh.Insert("turns", data);
			this.Id = (int)turn_id;
			
			return true;
		}
		public bool Open(double initial_mount)
		{
			//##check if the turn is already created into database
			if( this.Id <= 0 )
				return false;
				
			return true;
		}
		public bool Close(double final_amount)
		{
			if( this.Id <= 0 )
				return false;
				
			return true;
		}
		public static bool IsThereOpenOne(int store_id)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM turns WHERE store_id = %d AND status = 'open'";
			return (dbh.Query(query) > 0);
		}
		public static ECTurn GetOpen(int store_id)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM turns WHERE store_id = %d AND status = 'open'";
			var records = (ArrayList<SBDBRow>)dbh.GetResults(query);
			ECTurn turn = new ECTurn();
			if( records.size > 0 )
			{
				turn.SetDbData(records.get(0));
			}
			
			return turn;
		}
	}
}
