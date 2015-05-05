using GLib;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;

namespace Woocommerce
{
	public class ECProduct : Object
	{
		public	int 	Id;
		public	int		XId;
		public	string	Name;
		public	double	Price;
		public	string	Description;
		public	int		Quantity;
		public	string	Type;
		public	string	Thumbnail;
		public	string[] Images;
		
		public ECProduct(int? product_id = null)
		{
			if( product_id != null && product_id > 0 )
			{
				this.GetFromDb(product_id);
			}
		}
		public ECProduct.from_row(SBDBRow row)
		{
			this.SetDataFromRow(row);
		}
		public void SetDataFromRow(SBDBRow row)
		{
			this.Id 			= row.GetInt("product_id");
			this.XId			= row.GetInt("extern_id");
			this.Name			= row.Get("product_name");
			this.Price			= row.GetDouble("product_price");
			this.Description	= "";
			this.Quantity		= row.GetInt("product_quantity");
			this.Thumbnail		= row.Get("thumbnail");
		}
		public void GetFromDb(int product_id)
		{
			string query = @"SELECT p.*, a.file AS thumbnail "+
								"FROM products p,attachments a "+
								@"WHERE product_id = $product_id "+
								@"AND p.product_id = a.object_id "+
								@"AND LOWER(a.object_type) = 'product' " +
								@"AND (a.type = 'image_thumbnail' OR a.type = 'image') "+
								"LIMIT 1";
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var results = (ArrayList<SBDBRow>)dbh.GetResults(query);
			if( results.size > 0 )
			{
				this.SetDataFromRow(results.get(0));
			}
		}
	}
}
