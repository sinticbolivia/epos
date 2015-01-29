using GLib;

namespace SinticBolivia
{
	public abstract class SBSynchronizer : Object
	{
		public string Type = "database";
		
		public abstract long SyncStore();
		public abstract long SyncCategories(int store_id = -1);
		public abstract long SyncProducts(int store_id = -1);
	}
}
