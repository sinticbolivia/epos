using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace EPos
{
	public class EAssembly : Object
	{
		protected	SBDBRow		dbData;
		
		public		int		Id
		{
			get{return this.dbData.GetInt("assembly_id");}
		}
		public		string 	Name
		{
			get{return this.dbData.Get("name");}
		}
		public		string 	Description
		{
			get{return this.dbData.Get("description");}
		}
		public		int		StoreId
		{
			get{return this.dbData.GetInt("store_id");}
		}
		protected	ArrayList<EAssemblyComponent>		components;
		public		ArrayList<EAssemblyComponent>		Components
		{
			get{return this.components;}
		}
		public EAssembly()
		{
			this.dbData 	= new SBDBRow();
			this.components = new ArrayList<EAssemblyComponent>();
		}
		public EAssembly.from_id(int id)
		{
			this();
			this.GetDbData(id);
			this.GetDbComponents();
		}
		public void GetDbData(int id)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("assemblies").Where("assembly_id = %d".printf(id));
			var row = dbh.GetRow(null);
			if( row == null )
				return;
			this.dbData = row;
		}
		public void GetDbComponents()
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Select("*").From("assemblie2product").Where("assembly_id = %d".printf(this.Id));
			foreach(var row in dbh.GetResults(null))
			{
				var component = new EAssemblyComponent();
				component.SetDbData(row);
				this.components.add(component);
			}
		}
	}
}
