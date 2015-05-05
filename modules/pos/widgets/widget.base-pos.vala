using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public abstract class BasePos : Box
	{
		public		SBDatabase		Dbh{get;set;}
		public		string			TabId;
		protected 	SBStore			store;		
		protected	int				storeId = -1;
		protected	double			taxRate;
		protected	Label			labelStoreName;
		protected	Label			labelCashierUsername;
		protected	Label			labelTaxRate;
		
		public void ShowStoreSelector()
		{
			var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
			var user = (SBUser)SBGlobals.GetVar("user");
			var w = new DialogStoreSelector();
			w.modal = true;
			w.show();
			w.destroy.connect( () => 
			{
				this.store = w.GetStore();
				if( this.store != null )
				{
					this.storeId = this.store.Id;
					int tax_id 		= int.parse(this.store.Get("tax_id"));
					var tax_rate 	= EPosHelper.GetTaxRate(tax_id);
					this.taxRate 	= (double)tax_rate["rate"];
					this.labelStoreName.label = this.store.Name;
					this.labelCashierUsername.label = user.Username;
					this.labelTaxRate.label = "%.2f%s".printf(this.taxRate, "%");
					this.LoadData();
				}
				else
				{
					notebook.RemovePage(this.TabId);
				}
			});
		}
		public abstract void LoadData();
	}
}
