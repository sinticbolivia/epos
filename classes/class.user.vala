using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace Woocommerce
{
	public class WCUser : SBUser
	{
		public	int XId;
		
		public WCUser()
		{
		}
		public WCUser.from_row(SBDBRow row)
		{
			this.Id			= row.GetInt("user_id");
			this.XId		= row.GetInt("extern_id");
			this.Firstname	= row.Get("first_name");
			this.Lastname	= row.Get("last_name");
			this.Email		= row.Get("email");
			this.Username	= row.Get("username");
		}
	}
}
