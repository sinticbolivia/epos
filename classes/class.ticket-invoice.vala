using GLib;
using Gee;
using Gtk;

namespace Woocommerce
{
	public class TicketInvoice : Object
	{
		protected	Cairo.Context ctx;
		protected	int		width;
		protected	int		innerWidth;
		//public	int		Height;
		protected	string	body;
		protected	double	fontSize = 5;
		
		public TicketInvoice()
		{
			
		}
		public TicketInvoice.with_context(Cairo.Context ctx)
		{
			this.ctx = ctx;
		}
		public Cairo.Context GetContext()
		{
			return this.ctx;
		}
		public void SetWidth(int width)
		{
			this.width = width;
			this.innerWidth = this.width - 10;
		}
		public void AddLine(string text, string align = "left")
		{
			if( align == "left" )
				this.body += this.TextLeft(text) + "\n";
			if( align == "right" )
				this.body += this.TextRight(text) + "\n";
			if( align == "center" )
				this.body += this.TextCenter(text) + "\n";
		}
		public void Draw()
		{
			Pango.Layout layout;
            Pango.FontDescription desc;
            int text_width, text_height;
            int line;
            
            layout = Pango.cairo_create_layout(this.ctx);//Pango.CairoHelper.CreateLayout(cc);
            layout.set_width((int)(Pango.SCALE * this.width));//(int)(Pango.Scale.PangoScale * page_width/*200*/);
            layout.set_wrap(Pango.WrapMode.WORD_CHAR);
            //desc = Pango.FontDescription.FromString("monospace");
            desc = Pango.FontDescription.from_string("mono");
            desc.set_size((int)(this.fontSize * Pango.SCALE));
            layout.set_font_description(desc);
            
            this.ctx.move_to(5, 5);
            string[] lines = this.body.split("\n");
            
            for (int i = 0; i < lines.length; i++)
            {
                layout.set_text(lines[i], lines[i].length);
                Pango.cairo_show_layout(this.ctx, layout);
                this.ctx.rel_move_to(0, this.fontSize + 7);
                //line++;
                //Console.WriteLine("printing line: {0}", i);
            }
            layout.dispose();
            
		}
		protected string TextLeft(string _str)
        {
			int max_length = this.innerWidth;
			string str = _str;
			
            if (str.length > max_length)
            {
                str = str.substring(0, max_length);
            }
            string fill = "";
            for(int i = 0; i < (max_length - str.length); i++)
            {
                fill += " ";
            }

            return str + fill;
        }
        public string TextCenter(string par1)
        {
			int max_length = this.innerWidth;
            string ticket = "";
            string parte1 = "";
            int max = par1.length;
            if (max > max_length)                                 // **********
            {
                int cort = max - max_length;
                //parte1 = par1.Remove(max_length, cort);          // si es mayor que 40 caracteres, lo corta
                parte1 = par1.substring(0, max_length);
            }
            else { parte1 = par1; }                      // **********

            max = (int)(max_length - parte1.length) / 2;         // saca la cantidad de espacios libres y divide entre dos
            for (int i = 0; i < max; i++)                // **********
            {
                ticket += " ";                           // Agrega espacios antes del texto a centrar
            }                                            // **********
            ticket += parte1;
            return ticket;
        }
        public string TextRight(string par1)
        {
			int max_length = this.innerWidth;
            string ticket = "";
            string parte1 = "";
            int max = par1.length;
            if (max > max_length)                                 // **********
            {
                int cort = max - max_length;
                //parte1 = par1.Remove(max_length, cort);           // si es mayor que 40 caracteres, lo corta
                parte1 = par1.substring(0, max_length);
            }
            else { parte1 = par1; }                      // **********
            max = max_length - par1.length;                     // obtiene la cantidad de espacios para llegar a 40
            for (int i = 0; i < max; i++)
            {
                ticket += " ";                          // agrega espacios para alinear a la derecha
            }
            ticket += parte1;                    //Agrega el texto
            return ticket;
        }
        public float Pixel2Mm(float _pix)
        {
            float pixel = 0.264583333f;
            float mm = 1f;

            return _pix / pixel;
        }
        public float Mm2Pixel(float _mm)
        {
            float pixel = 0.264583333f;
            float mm = 1f;
            
            return _mm * pixel;
        }
	}
}
