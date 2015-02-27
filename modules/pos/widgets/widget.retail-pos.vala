using GLib;
using Gee;
using Gtk;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetRetailPos : Box
	{
		protected	Builder			ui;
		protected	Box				boxRetailPos;
		protected	Image			imageCustomer;
		protected	TreeView		treeviewOrderItems;
		protected	Button			buttonComments;
		protected	Button			buttonHold;
		protected	Button			buttonLookup;
		protected	Button			buttonCustomer;
		protected	Button			buttonCalculator;
		protected	Button			buttonCount;
		protected	Button			buttonReqValidation;
		protected	Button			buttonDrawer;
		protected	Button			buttonConvertToCurrency;
		protected	Button			buttonTender;
		
		protected	InfoDialog		CommentsDialog;
		protected	TextView		textviewComments;
		enum Columns
		{
			COUNT,
			PRODUCT_CODE,
			PRODUCT_NAME,
			QUANTITY,
			UOM,
			PRICE,
			TAX,
			TOTAL,
			PRODUCT_ID,
			N_COLS
		}
		public WidgetRetailPos()
		{
			this.ui			= (SBModules.GetModule("Pos") as SBGtkModule).GetGladeUi("retail-pos.glade");
			this.boxRetailPos		= (Box)this.ui.get_object("boxRetailPos");
			this.imageCustomer		= (Image)this.ui.get_object("imageCustomer");
			this.treeviewOrderItems = (TreeView)this.ui.get_object("treeviewOrderItems");
			this.buttonComments		= (Button)this.ui.get_object("buttonComments");
			this.buttonHold			= (Button)this.ui.get_object("buttonHold");
			this.buttonLookup		= (Button)this.ui.get_object("buttonLookup");
			this.buttonCustomer		= (Button)this.ui.get_object("buttonCustomer");
			this.buttonCalculator	= (Button)this.ui.get_object("buttonCalculator");
			this.buttonCount		= (Button)this.ui.get_object("buttonCount");
			this.buttonReqValidation	= (Button)this.ui.get_object("buttonReqValidation");
			this.buttonDrawer			= (Button)this.ui.get_object("buttonDrawer");
			this.buttonConvertToCurrency= (Button)this.ui.get_object("buttonConvertToCurrency");
			this.buttonTender			= (Button)this.ui.get_object("buttonTender");
			
			
			this.textviewComments		= new TextView();
			this.boxRetailPos.reparent(this);
			this.Build();
			this.SetEvents();
		}
		protected void Build()
		{
			this.imageCustomer.pixbuf = (SBModules.GetModule("Pos") as SBGtkModule).GetPixbuf("customer-48x48.png");
			this.treeviewOrderItems.model = new ListStore(Columns.N_COLS,
				typeof(int), //count
				typeof(string), //product code
				typeof(string), //product name
				typeof(int), //quantity
				typeof(string), //UOM
				typeof(string), //price
				typeof(string), //tax
				typeof(string), //total
				typeof(int) //product id
			);
			string[,] cols= 
			{
				{"#", "text", "60", "right", "", ""},
				{SBText.__("Code"), "text", "120", "left", "", ""},
				{SBText.__("Product"), "text", "200", "left", "", ""},
				{SBText.__("Quantity"), "text", "80", "center", "editable", ""},
				{SBText.__("U.O.M."), "text", "120", "left", "", ""},
				{SBText.__("Price"), "text", "120", "right", "", ""},
				{SBText.__("Tax"), "text", "120", "right", "", ""},
				{SBText.__("Total"), "text", "120", "right", "", ""},
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewOrderItems);
			this.treeviewOrderItems.rules_hint = true;
			//build comments dialog
			this.CommentsDialog = new InfoDialog("info")
			{
				Title = SBText.__("Comments"),
				Message = SBText.__("Sale Comments:")
			};
			this.CommentsDialog.get_style_context().add_class("dialog-retail-comments");
			this.CommentsDialog.set_size_request(350, 200);
			var scroll = new ScrolledWindow(null, null){expand = true};
			scroll.add_with_viewport(this.textviewComments);
			scroll.show_all();
			
			this.CommentsDialog.get_content_area().add(scroll);
		}
		protected void SetEvents()
		{
			this.buttonComments.clicked.connect(this.OnButtonCommentsClicked);
			this.buttonLookup.clicked.connect(this.OnButtonLookupClicked);
			this.buttonCalculator.clicked.connect(this.OnButtonCalculatorClicked);
			this.realize.connect( () => 
			{
				this.SetShortcutsEvents();
			});
		}
		protected void OnButtonCommentsClicked()
		{
			this.CommentsDialog.run();
			this.CommentsDialog.hide();
		}
		protected void OnButtonLookupClicked()
		{
			
		}
		protected void OnButtonCalculatorClicked()
		{
			string command = "";
			
			if( SBOS.GetOS().IsLinux() )
			{
				//string? prg = Environment.find_program_in_path("evince");
				if( Environment.find_program_in_path("mate-calc") != null )
				{
					command = "mate-calc";
				}
				else if( Environment.find_program_in_path("gnome-calculator") != null )
				{
					command = "gnome-calculator";
				}
			}
			else if( SBOS.GetOS().IsWindows() )
			{
				command = SBFileHelper.SanitizePath("calc.exe");
			}	
			
			if( command == "" )
			{
				var err = new InfoDialog("error")
				{
					Title = SBText.__("Calculator error"),
					Message = SBText.__("The application can found a valid calculator in your system.")
				};
				err.run();
				err.destroy();
				return;
			}
			//Posix.pid_t pid = Posix.fork();
			//Posix.system(command);
			//exit(1);
			try
			{
				GLib.Process.spawn_command_line_async(command);
			}
			catch(GLib.SpawnError e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
		}
		protected void SetShortcutsEvents()
		{
			Gdk.Window gdk_win = this.get_parent_window();
			void* main_win;
			gdk_win.get_user_data(out main_win);
			//(this.get_toplevel() as Window).key_press_event.connect( (e) => 
			(main_win as Window).key_press_event.connect( (e) => 
			{
				Gdk.ModifierType mod;
				uint f1_code, f2, f3, f4, f5, f6, f7, f8, f9, f10;
				
				Gtk.accelerator_parse("F1", out f1_code, out mod);
				Gtk.accelerator_parse("F3", out f2, out mod);
				Gtk.accelerator_parse("F3", out f3, out mod);
				Gtk.accelerator_parse("F4", out f4, out mod);
				Gtk.accelerator_parse("F5", out f5, out mod);
				Gtk.accelerator_parse("F6", out f6, out mod);
				Gtk.accelerator_parse("F7", out f7, out mod);
				Gtk.accelerator_parse("F8", out f8, out mod);
				Gtk.accelerator_parse("F9", out f9, out mod);
				Gtk.accelerator_parse("F10", out f10, out mod);
				
				var args = (Gdk.EventKey)e;
				if( args.keyval == f1_code )
				{
					GLib.Signal.emit_by_name(this.buttonComments, "clicked");
					return true;
				}
				if( args.keyval == f3 )
				{
					GLib.Signal.emit_by_name(this.buttonLookup, "clicked");
					return true;
				}
				if( args.keyval == f5 )
				{
					GLib.Signal.emit_by_name(this.buttonCalculator, "clicked");
					return true;
				}
				//##return false to mark the event as no consumed
				return false;
			});
		}
	}
}
