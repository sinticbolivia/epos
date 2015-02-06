using GLib;
using Gee;
using SinticBolivia;
using HPDF;

namespace Woocommerce
{
	public class PdfCell : Object
	{
		protected 	unowned HPDF.Page	page;
		public 		unowned HPDF.Font	PdfFont;
		protected	string				text;
		protected	HPDF.Image			image;
		
		public	float		Width		= 0;
		public	float		Height		= 0;
		public	string		FontFamily  = "Helvetica";
		public	float		FontSize 	= 12;
		public	int			Span 		= 1;
		public	bool		Border 		= true;
		public	int			TableCols	= 0;
		public	float[]		ColumnsWidth;
		public	string		Align		= "left";
		
		protected ArrayList<string>		lines;
		
		public PdfCell(HPDF.Page page)
		{
			this.SetPage(page);
			this.lines = new ArrayList<string>();
		}
		public void SetPage(HPDF.Page page)
		{
			this.page = page;
		}
		public void SetText(string text)
		{
			//##calculate cell width if span > 1
			if( this.Span > 1 && this.Span <= this.TableCols)
			{
				this.Width = 0;
				for( int i = 0; i < this.Span; i++ )
				{
					this.Width += this.ColumnsWidth[i];
				}
			}
			else
			{
				//this.Width = 0;
			}
			
			
			this.lines 	= PdfCell.BuildCellText(this.page, this.Width, text);
			this.Height	= (this.FontSize * this.lines.size * 1.5f);
			//stdout.printf("(%s), lines: %d, width: %f, height: %f, span: %d,\n", text, this.lines.size, this.Width, this.Height, this.Span);
		}
		public void Draw(float x, float y)
		{
			float cell_padding 	= 3;
			
			this.page.SetFontAndSize(this.PdfFont, this.FontSize);
			float yy = (this.Height <= 20) ? y : y - this.Height + (this.FontSize *1.5f);
			float xx = x;
			
			if( this.Border )
			{
				this.page.SetLineWidth(0.5f);
				//##draw cell border
				this.page.Rectangle(xx, yy, this.Width, this.Height);
				stdout.printf("border (%fx%f)\n", xx, yy);
				this.page.Stroke();
			}
			yy = y;
			//##draw the cell text
			int i = 0;
			foreach(string _text in this.lines)
			{
				
				float text_width = this.page.TextWidth(_text);
				/*
				if( text_width > this.Width )
				{
					text_width = this.Width;
				}
				*/
				float text_x_pos = xx + cell_padding;
				float text_y_pos = yy;
				if( this.lines.size == 1 ) 
				{
					text_y_pos += (this.Height - this.FontSize) / 2;
				}
				else
				{
					text_y_pos += 3f;
				}
				
				if( this.Align == "center")
					text_x_pos += ((this.Width - cell_padding) - text_width) / 2;
				else if( this.Align == "right" )
					text_x_pos += ((this.Width - cell_padding) - text_width) / 2;
				
				stdout.printf("text (%fx%f)\n", text_x_pos, text_y_pos);
				this.page.BeginText();
				this.page.TextOut(text_x_pos, text_y_pos, _text);
				this.page.EndText();
				i++;
				if( i < this.lines.size )
					yy -= this.FontSize;
			}
			
		}
		public static ArrayList<string> BuildCellText(HPDF.Page _page, float cell_width, string text)
		{
			var lines = new ArrayList<string>();
			if( _page.TextWidth(text) <= cell_width )
			{
				lines.add(text);
				return lines;
			}
			string the_str = text.strip().normalize();
			string[] words = the_str.split(" ");
			
			stdout.printf("(%s) length: %d, words: %d\n", the_str, the_str.length, words.length);
			string line = "";
			
			for(int i = 0; i < words.length; i++)
			{
				line += words[i] + " ";
				float w = _page.TextWidth(line);
				if( w >= cell_width )
				{
					stdout.printf("line: %s\n",line);
					lines.add(line.strip());
					line = "";
				}
				else if( i == words.length - 1)
				{
					stdout.printf("line: %s\n",line);
					lines.add(line.strip());
					line = "";
				}
			}
			
			
			return lines;
		}
	}
	public class PdfRow : Object
	{
		protected 	unowned HPDF.Page		page;
		protected	ArrayList<PdfCell> cells;
		
		public	float		Width;
		public	float		Height;
		public	float[]		ColumnsWidth;
		public	int			Size
		{
			get{return this.cells.size;}
		}
			
		public PdfRow(HPDF.Page page)
		{
			this.page = page;
			this.cells = new ArrayList<PdfCell>();
			this.Width = 0;
			this.Height = 0;
		}
		public void SetPage(HPDF.Page page)
		{
			this.page = page;
			//##update cell page
			foreach(var cell in this.cells)
			{
				cell.SetPage(this.page);
			}
		}
		public int AddCell(PdfCell cell)
		{
			this.cells.add(cell);
			this.calculateRowSize();
			
			return this.cells.size - 1;
		}
		protected void calculateRowSize()
		{
			foreach(var cell in this.cells)
			{
				if( cell.Height > this.Height )
					this.Height = cell.Height;
				this.Width += cell.Width;
			}
		}
		public void Draw(float x, float y)
		{
			foreach(var cell in this.cells)
			{
				cell.Height = this.Height;
				cell.Draw(x, y);
				x += cell.Width;
			}
		}
	}
	public class Catalog : Object
	{
		public 	string 		Title;
		public 	float		XPos;
		public 	float		YPos;
		public	string		FontType = "Helvetica";
		public	string[]	Headers;
		public	float[]		ColumnsWidth;
		
		public	float		TopMargin;
		public	float		RightMargin;
		public	float		BottomMargin;
		public	float		LeftMargin;
		
		protected	HPDF.Doc	pdf;
		protected 	unowned HPDF.Page	page;
		protected 	unowned HPDF.Font	font;
		protected	float pageWidth;
		protected	float pageHeight;
		protected	float pageAvailableSpace;
		protected	int		currentCell = 0;
		//protected	int		currentRow = 0;
		protected	int		totalCols = 0;
		protected	float	rowHeight = 0;
		protected	ArrayList<PdfRow>	rows;
		protected	PdfRow	currentRow = null;
		
		public Catalog()
		{
			this.rows = new ArrayList<PdfRow>();
			this.TopMargin 	= this.RightMargin = this.BottomMargin = 40;
			this.LeftMargin = 40;
			this.pdf	= new HPDF.Doc((error_no, detail_no) => 
			{
				stderr.printf("Error %d - detail %d\n", (int)error_no, (int)detail_no);
			});
			this.page	= this.pdf.AddPage();
			this.font = pdf.GetFont(this.FontType);
			this.pageWidth	= this.page.GetWidth();
			this.pageHeight	= this.page.GetHeight();
			this.pageAvailableSpace	= this.pageWidth - this.LeftMargin - this.RightMargin;
			//initialize coordinates
			this.XPos 	= this.LeftMargin;
			this.YPos	= this.pageHeight - this.TopMargin;
		}
		public void SetMargins(float top, float right, float bottom, float left)
		{
			this.TopMargin 		= top;
			this.RightMargin 	= right;
			this.BottomMargin 	= bottom;
			this.LeftMargin 	= left;
			//initialize coordinates
			this.XPos 	= this.LeftMargin;
			this.YPos	= this.pageHeight - this.TopMargin;
		}
		public void WriteText(string text, string align = "left", float font_size = 12, string? color = null)
		{
			this.page.SetFontAndSize(this.font, font_size);
			this.CheckNewPage(font_size);
			
			this.page.BeginText();
			
			if( align == "left" )
				this.page.TextOut(this.LeftMargin, this.YPos, text);
			if( align == "center" )
				this.page.TextOut((this.pageWidth - this.page.TextWidth(text)) / 2, this.YPos, text);
			if( align == "right" )
				this.page.TextOut((this.pageWidth - this.page.TextWidth(text)) / 2, this.YPos, text);
				
			this.page.EndText();
			
			this.YPos -= font_size + 10;
			this.XPos = this.LeftMargin;
		}
		public void SetColumnsWidth(float[] widths)
		{
			this.ColumnsWidth = new float[widths.length];
			for(int i = 0; i < widths.length; i++)
			{
				this.ColumnsWidth[i] = this.pageAvailableSpace * (widths[i] / 100);
			}
			this.totalCols = this.ColumnsWidth.length;
		}
		public void SetTableHeaders(string[] headers)
		{
			if(this.totalCols <= 0 )
			{
				stdout.printf("No columns found\n");
				return;
			}
			//this.Headers = headers;
			foreach(string header in headers)
			{
				this.AddCell(header, "center");
			}
		}
		public void AddCell(string text, string align = "left", float font_size = 12, bool border = true, int span = 1, 
							string? bg = null, string? fg = null)
		{
			if( this.totalCols <= 0 )
			{
				stdout.printf("No columns found.\n");
				return;
			}
			if( this.currentRow == null )	
			{
				this.currentRow = new PdfRow(this.page);
				this.currentCell = 0;
			}
				
			var the_cell 		= new PdfCell(this.page);
			the_cell.FontFamily = "Helvetica";
			the_cell.FontSize	= font_size;
			the_cell.PdfFont	= this.pdf.GetFont(the_cell.FontFamily);
			the_cell.TableCols	= this.ColumnsWidth.length;
			the_cell.ColumnsWidth = this.ColumnsWidth;
			the_cell.Span 		= span;
			the_cell.Border		= border;
			the_cell.Width		= this.ColumnsWidth[this.currentCell];
			the_cell.Align		= align;																																																						
			the_cell.SetText(text);
			
			int cells_left = this.totalCols - this.currentRow.Size;
			
			if( span == this.totalCols )
			{
				if( this.currentRow.Size == 0 )
				{
					this.currentRow.AddCell(the_cell);
					this.rows.add(this.currentRow);
				}
				else
				{
					this.rows.add(this.currentRow);
					this.currentRow = new PdfRow(this.page);
					this.currentRow.AddCell(the_cell);
					this.rows.add(this.currentRow);
					
				}
				this.currentRow = new PdfRow(this.page);
				this.currentCell = 0;
				return;
			}
			//##check space in row
			if( cells_left > 0  )
			{
				this.currentRow.AddCell(the_cell);
				this.currentCell++;
			}
			cells_left = this.totalCols - this.currentRow.Size;
			if( cells_left <= 0 )
			{
				this.rows.add(this.currentRow);
				this.currentRow = new PdfRow(this.page);
				this.currentCell = 0;
			}
		}
		public void Draw()
		{
			float page_height = this.pageHeight - this.TopMargin - this.BottomMargin;
			stdout.printf("page_height: %f\n", page_height);
			stdout.printf("rows: %d, cols: %d\n", this.rows.size, this.totalCols);
			stdout.printf("starting table at (%fx%f)\n\n", this.XPos, this.YPos);
			foreach(var row in this.rows)
			{
				this.CheckNewPage(row.Height);
				row.SetPage(this.page);
				stdout.printf("row height => %f\n", row.Height);
				row.Draw(this.XPos, this.YPos);
				this.XPos 	= this.LeftMargin;
				this.YPos	-= row.Height;
				stdout.printf("new global(%fx%f)\n\n", this.XPos, this.YPos);
			}
			
		}
		protected bool CheckNewPage(float obj_height)
		{
			float page_height = this.pageHeight - this.TopMargin - this.BottomMargin;
			//stdout.printf("total_page_height => %f, page_height => %f, y => %f, obj => %f\n", 
				//			this.pageHeight, page_height, this.YPos, obj_height);
			if( this.YPos < obj_height )
			{
				stdout.printf("adding new page\n");
				this.page 	= this.pdf.AddPage();
				var dst 	= this.page.CreateDestination();
				dst.SetXYZ(0, this.pageHeight, 1);
				this.YPos = this.pageHeight - this.TopMargin;
				this.XPos = this.LeftMargin;
				return true;
			}
			
			return false;
		}
		public string Save(string name = "catalog")
		{
			if( !FileUtils.test("temp", FileTest.IS_DIR) )
			{
				//create temp dir
				DirUtils.create("temp", 0744);
			}
			string filename = "%s-%s.pdf".printf(name, new DateTime.now_local().format("%Y-%m-%d"));
			string pdf_path = SBFileHelper.SanitizePath("temp/%s".printf(filename));
			pdf.SaveToFile(pdf_path);
			
			return pdf_path;
		}
		public void Preview(string name = "catalog")
		{
			string pdf_path = this.Save(name);
			string command = "";
			stdout.printf("OS: %s\n", SBOS.GetOS().OS);
			if( SBOS.GetOS().IsLinux() )
			{
				command = "evince --preview %s".printf(pdf_path);
			}
			else if( SBOS.GetOS().IsWindows() )
			{
				command = SBFileHelper.SanitizePath("bin/SumatraPDF.exe %s".printf(pdf_path));
			}	
			
			Posix.system(command);
		}
		public void Print(string name = "catalog", string printer = "")
		{
			string pdf_path = this.Save(name);
			string cmd = "";
			if( SBOS.GetOS().IsWindows() )
			{
				cmd = SBFileHelper.SanitizePath("bin/SumatraPDF.exe %s -print-to %s -silent -exit-on-print".printf(pdf_path, printer));
			}
			else if( SBOS.GetOS().IsLinux() )
			{
				cmd = "evince --preview %s".printf(pdf_path);
			}
			Posix.system(cmd);
		}
	}
}
