using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace EPos
{
	public class EAssemblyComponent : Object
	{
		protected	SBDBRow			dbData;
		
		public		int				Id
		{
			get{return this.dbData.GetInt("id");}
		}
		public		int				ProductId
		{
			get{return this.dbData.GetInt("product_id");}
		}
		public		int				QtyRequired
		{
			get{return this.dbData.GetInt("qty_required");}
		}
		public		int				UOMId
		{
			get{return this.dbData.GetInt("unit_of_measure_id");}
		}
		
		public		EProduct		Product;
		
		public EAssemblyComponent()
		{
			this.dbData	= new SBDBRow();
			this.Product = new EProduct();
		}
		public EAssemblyComponent.from_id(int id)
		{
			this();
			this.GetDbData(id);
		}
		public EAssemblyComponent.from_assembly_id_and_product_id(int assembly_id, int product_id)
		{
			this();
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("assemblie2product").
				Where("assembly_id = %d".printf(assembly_id)).
				And("product_id = %d".printf(product_id));
			var row = dbh.GetRow(null);
			if( row != null )
			{
				this.dbData = row;
				this.Product = new EProduct.from_id(this.dbData.GetInt("product_id"));
			}
		}
		public void GetDbData(int id)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("assemblie2product").Where("id = %d".printf(id));
			var row = dbh.GetRow(null);
			if( row == null )
				return;
			this.dbData = row;
			this.Product = new EProduct.from_id(this.dbData.GetInt("product_id"));
		}
		public void SetDbData(SBDBRow data)
		{
			this.dbData = data;
			this.Product = new EProduct.from_id(this.dbData.GetInt("product_id"));
		}
		
	}
}
