using Gtk;
using SinticBolivia;
using SinticBolivia.Database;
using Gee;
using SinticBolivia.Gtk;

namespace Woocommerce
{
	public class DialogConfig : Gtk.Dialog
	{
		protected 	string 		_UI_FILE;
		protected	Builder 	_builder;
		protected	SBConfig	_config;
		protected	HashMap<string, Widget> _ecommerceWidgets;
		
		public		Box			boxEcommerceSettings;
		public		ComboBox	comboboxLanguage;
		//#company tab
		public		Entry		entryCompany;
		public		Entry		entryAddress;
		public		Entry		entryCity;
		public		Entry		entryPhone1;
		public		Entry		entryPhone2;
		public		Entry		entryFax;
		public		Entry		entryEmail;
		public		Entry		entryReg;
		public		Entry		entryNIT;
		public		Button		buttonLogo;
		public		Image		imageLogo;
		
		public		ComboBox	comboboxPrinter;
		public		ComboBox	comboboxPageSizes;
			
		public 		Dialog 		dialogConfig;
		public		Button		buttonTestPrinter;
		public		Button		buttonCancel;
		public		Button		buttonSave;
		public		CheckButton	checkbuttonShowPreview;
		public		CheckButton	checkbuttonShowPrintDialog;
		public		Image		imageSettings;
		public		string		cfgFile = "config.xml";
		public		string		logoFilename = "";
		
		public DialogConfig()
		{
			this._ecommerceWidgets = new HashMap<string, Widget>();
			this._UI_FILE = GLib.Environment.get_current_dir() + "/share/ui/" + "config-ui.glade";
			this._builder = new Builder();
			try
			{
				this._builder.add_from_file(this._UI_FILE);
				//get widgets
				this.dialogConfig 			= (Gtk.Dialog)this._builder.get_object("dialogConfig");
				this.imageSettings 			= (Image)this._builder.get_object("imageSettings");
				this.boxEcommerceSettings 	= (Box)this._builder.get_object("boxEcommerceSettings");
				//##get company widgets
				this.entryCompany			= (Entry)this._builder.get_object("entryCompany");
				this.entryAddress			= (Entry)this._builder.get_object("entryAddress");
				this.entryCity				= (Entry)this._builder.get_object("entryCity");
				this.entryPhone1			= (Entry)this._builder.get_object("entryPhone1");
				this.entryPhone2			= (Entry)this._builder.get_object("entryPhone2");
				this.entryFax				= (Entry)this._builder.get_object("entryFax");
				this.entryEmail				= (Entry)this._builder.get_object("entryEmail");
				this.entryReg				= (Entry)this._builder.get_object("entryReg");
				this.entryNIT				= (Entry)this._builder.get_object("entryNIT");
				this.buttonLogo				= (Button)this._builder.get_object("buttonLogo");
				this.imageLogo				= (Image)this._builder.get_object("imageLogo");
				
				this.comboboxPrinter		= (ComboBox)this._builder.get_object("comboboxPrinter");
				this.comboboxPageSizes		= (ComboBox)this._builder.get_object("comboboxPageSizes");
				
				this.buttonTestPrinter		= (Button)this._builder.get_object("buttonTestPrinter");
				this.buttonCancel 			= (Button)this._builder.get_object("buttonCancel");
				this.buttonSave				= (Button)this._builder.get_object("buttonSave");
				this.checkbuttonShowPreview	= (CheckButton)this._builder.get_object("checkbuttonShowPreview");
				this.checkbuttonShowPrintDialog	= (CheckButton)this._builder.get_object("checkbuttonShowPrintDialog");
				
				this.imageSettings.set_from_icon_name("preferences-desktop", IconSize.DIALOG);
				TreeIter iter;
				/*
				this.comboboxShopType.model = new ListStore(2, typeof(string), typeof(string));
				var cell = new CellRendererText();
				this.comboboxShopType.pack_start(cell, false);
				this.comboboxShopType.set_attributes(cell, "text", 0);
				
				(this.comboboxShopType.model as ListStore).append(out iter);
				(this.comboboxShopType.model as ListStore).set(iter, 0, "Woocommerce", 1, "woocommerce");
				(this.comboboxShopType.model as ListStore).append(out iter);
				(this.comboboxShopType.model as ListStore).set(iter, 0, "Open Cart", 1, "open-cart");
				(this.comboboxShopType.model as ListStore).append(out iter);
				(this.comboboxShopType.model as ListStore).set(iter, 0, "OsCommerce", 1, "oscommerce");
				(this.comboboxShopType.model as ListStore).append(out iter);
				(this.comboboxShopType.model as ListStore).set(iter, 0, "WP-ecoomerce (get shopped)", 1, "wp-ecoomerce");
				*/
				this.dialogConfig.title = SBText.__("Settings");
				//setup combobox printer
				var cell = new CellRendererText();
				this.comboboxPageSizes.pack_start(cell, false);
				this.comboboxPageSizes.set_attributes(cell, "text", 0);
				
				this.comboboxPageSizes.model = new ListStore(2, typeof(string), typeof(string));
				(this.comboboxPageSizes.model as ListStore).append(out iter);
				(this.comboboxPageSizes.model as ListStore).set(iter, 0, "Letter", 1, "na_letter_8.5x11in");
				//A4 => iso_a4_210x297mm 
				(this.comboboxPageSizes.model as ListStore).append(out iter);
				(this.comboboxPageSizes.model as ListStore).set(iter, 0, "Legal", 1, "na_legal_8.5x14in");
				(this.comboboxPageSizes.model as ListStore).append(out iter);
				(this.comboboxPageSizes.model as ListStore).set(iter, 0, "Ticket", 1, "ticket");
				//this.comboboxPageSizes.set_column_id(1);
				this.comboboxPageSizes.id_column = 1;
				this.Build();
				this.SetEvents();
				
			}
			catch(Error e)
			{
				stderr.printf("ERROR: %s\n", e.message);
			}
		}
		protected void Build()
		{
			this.imageLogo.pixbuf = GtkHelper.GetPixbuf("share/images/logo.png", 120, 120);
			
		}
		protected void SetEvents()
		{
			//##connect signals
			this.buttonLogo.clicked.connect(this.OnButtonLogoClicked);
			this.buttonTestPrinter.clicked.connect(this.OnButtonTestPrinterClicked);
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
			this.buttonSave.clicked.connect(this.OnButtonSaveClicked);
		}
		public void LoadData()
		{
			string company_data = SBParameter.Get("company");
			stdout.printf("company json:%s\n", company_data);
			var company = SinticBolivia.Utils.JsonDecode(company_data);
			this.entryCompany.text = (string)company["company"];
			this.entryAddress.text = (string)company["address"];
			this.entryCity.text		= (string)company["city"];
			this.entryPhone1.text	= (string)company["phone_1"];
			this.entryPhone2.text	= (string)company["phone_2"];
			this.entryFax.text		= (string)company["fax"];
			this.entryEmail.text	= (string)company["email"];
			this.entryReg.text	= (string)company["reg"];
			this.entryNIT.text	= (string)company["nit"];
			string logo = (company["logo"] != null) ? "images/%s".printf((string)company["logo"]) : "";
			if( logo.length > 0 && FileUtils.test(logo, FileTest.EXISTS) )
			{
				this.imageLogo.pixbuf = new Gdk.Pixbuf.from_file(logo);
			}
			
			TreeIter iter;
			//set default data from config file
			this._config = new SBConfig(this.cfgFile, "point_of_sale");
			(this.comboboxPrinter.get_child() as Entry).text = (string)this._config.GetValue("printer");
			string page_size = (string)this._config.GetValue("page_size");
			/*
			this.comboboxPrinter.model.foreach((_model, _path, _iter) => 
			{
				stdout.printf("row path: %s\n", _path.to_string());
				Value _val;
				_model.get_value(_iter, 1, out _val);
				if( page_size ==)
				return false;
			});
			*/
			this.comboboxPageSizes.active_id = page_size;
			this.entryAddress.text 	= (string)this._config.GetValue("address");
			this.entryCity.text		= (string)this._config.GetValue("city");
			this.checkbuttonShowPreview.active = ((string)this._config.GetValue("print_preview") == "yes");
			this.checkbuttonShowPrintDialog.active = ((string)this._config.GetValue("show_print_dialog") == "yes");
		}
		public Dialog GetDialog()
		{
			return this.dialogConfig;
		}
		protected void OnButtonLogoClicked()
		{
			var dlg = new FileChooserDialog(SBText.__("Select your company logo"), null, 
							FileChooserAction.OPEN,
							SBText.__("_Cancel"),
							ResponseType.CANCEL,
							SBText.__("_Open"),
							ResponseType.ACCEPT
			);
			var filter = new FileFilter();
			filter.add_mime_type("image/jpeg");
			filter.add_mime_type("image/png");
			filter.add_mime_type("image/gif");
			//filter.add_mime_type("image/bmp");
			dlg.set_filter(filter);
			
			if( dlg.run() == ResponseType.ACCEPT )
			{
				string file = dlg.get_filename();
				this.imageLogo.pixbuf = new Gdk.Pixbuf.from_file(file);
				this.imageLogo.pixbuf = this.imageLogo.pixbuf.scale_simple(150, 150, Gdk.InterpType.BILINEAR);
				this.logoFilename = file;
			}
			dlg.destroy();
		}
		protected void OnButtonResetDataClicked()
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			dbh.Execute("DELETE FROM products");
			dbh.Execute("DELETE FROM product2category");
			dbh.Execute("DELETE FROM categories");
			dbh.Execute("DELETE FROM attachments");
			dbh.Execute("DELETE FROM sqlite_sequence WHERE name = 'products' AND name = 'product2category' AND name = 'categories' AND name = 'attachments'");
			dbh.Execute("VACUUM");
			var msg = new MessageDialog(this.dialogConfig, DialogFlags.MODAL, MessageType.INFO, ButtonsType.OK, 
													"The local data has been deleted.");
			msg.title = "Reset Data";
			msg.run();
			msg.dispose();
		}
		protected void OnButtonCancelClicked(Button sender)
		{
			//this.dialogConfig.destroy();
			this.dialogConfig.dispose();
		}
		protected void OnComboBoxShopTypeChanged()
		{
			/*
			TreeIter iter;
			Value shop_type;
			this.comboboxShopType.get_active_iter(out iter);
			this.comboboxShopType.model.get_value(iter, 1, out shop_type);
						
			foreach(Widget w in this.boxEcommerceSettings.get_children())
			{
				if( w.name == "ecommerce_box" )
				{
					w.destroy();
				}
			}
			
			if( (string)shop_type == "woocommerce" )
			{
				var box = new Box(Orientation.VERTICAL, 5);
				box.name = "ecommerce_box";
				var username_box = new Box(Orientation.HORIZONTAL, 5);
				var api_key = new Label("Api Key:"){xalign = 0};
				var entry_api_key = new Entry();
				entry_api_key.set_name("entryWcApiKey");
				username_box.pack_start(api_key);
				username_box.pack_start(entry_api_key);
				
				var label = new Label("Api Secret:"){xalign = 0};
				var entry = new Entry();
				entry.set_name("entryWcApiSecret");
				var api_secret_key_box = new Box(Orientation.HORIZONTAL, 5);
				api_secret_key_box.pack_start(label);
				api_secret_key_box.pack_start(entry);
				
				((HashMap<string, Widget>)this._ecommerceWidgets).set("wc_entry_api_key", entry_api_key);
				((HashMap<string, Widget>)this._ecommerceWidgets).set("wc_entry_api_secret", entry);
				
				entry_api_key.text = (this._config != null) ? (string)this._config.GetValue("wc_api_key") : "";
				entry.text = (this._config != null) ? (string)this._config.GetValue("wc_api_secret") : "";
				box.pack_start(username_box);
				box.pack_start(api_secret_key_box);
				this.boxEcommerceSettings.pack_start(box);
			}
			this.boxEcommerceSettings.show_all();
			*/
		}
		protected void OnButtonTestPrinterClicked()
		{
			double font_size = 12;
			string printer_name = (this.comboboxPrinter.get_child() as Entry).text.strip();
			if( printer_name.length <= 0 )
			{
				var error = new MessageDialog(this.dialogConfig, DialogFlags.MODAL,
												MessageType.ERROR, 
												ButtonsType.CLOSE, 
												"You need to select a printer");
				error.run();
				error.dispose();
				return;
			}
			var operation = new PrintOperation();
			var settings = new PrintSettings();
			var page_setup = new PageSetup();
			PaperSize paper_size;
			//set printer
			settings.set_printer(printer_name);
			if( this.comboboxPageSizes.active_id == "ticket") 
			{
				double paper_width = 2.25;
				double paper_height = 14;
				paper_size = new PaperSize.custom("custom_ticket_2.25x14in", "Ticket", paper_width, paper_height, Unit.INCH);
				font_size = 5;
			}
			else
			{
				paper_size = new PaperSize(this.comboboxPageSizes.active_id);
			}
			//TODO:set paper margins
			
			page_setup.set_paper_size(paper_size);
			operation.print_settings = settings;
			operation.default_page_setup = page_setup;
			int _PANGO_SCALE = 1024;
			int lines_per_page = 0;
			int num_lines = 0;
			int num_pages = 0;
			string contents = """
			Ecommerce Point of Sale - Test page
			-----------------------------------
			
			
			------------------------------------
			Date: xxxxxxxxx
			Hour: 00:00
			------------------------------------
			
			
			Your printer is correctly configured!!!
			
			
			-------------------------------------
			@Copyright - Sintic Bolivia 2007-2014
			""";
			//##set print operation events
			operation.begin_print.connect( (context) => 
			{
				double height = context.get_height();
				
				lines_per_page = (int)GLib.Math.floor(height / font_size);
				string[] lines = contents.split("\n");
				num_lines = lines.length;
				num_pages = (num_lines - 1) / lines_per_page + 1;
				//set total pages to print operation
				operation.n_pages = num_pages;
				stdout.printf("Total page: %d\nTotal lines: %d\nLines per page:%d\n", num_pages, num_lines, lines_per_page);
				
			});
			operation.preview.connect( (preview, context, parent) => 
			{
				stdout.printf("preview\n");
				var prv = new SBPrintPreview(operation, preview, context);
				var dlg = new Dialog(){title = "Test print preview"};
				dlg.get_content_area().add(prv);
				dlg.show_all();
				return true;
			});
			operation.draw_page.connect( (context, page_nr) => 
			{
				
				int text_width, text_height;
				double top = 20;
				Cairo.Context cr = context.get_cairo_context();
				double width = context.get_width();
				Pango.Layout layout = context.create_pango_layout();
				Pango.FontDescription desc = Pango.FontDescription.from_string("Arial %lf".printf(font_size));
				
				string invoice_title = "Woocommerce Point of Sale";
				layout.set_font_description(desc);
				layout.set_text(invoice_title, invoice_title.length);
				layout.get_pixel_size(out text_width, out text_height);
				
				if( text_width > width )
				{
					layout.set_width((int)width);
					layout.set_ellipsize(Pango.EllipsizeMode.START);
					layout.get_pixel_size(out text_width, out text_height);
				}
				cr.move_to( (width - text_width) / 2, top);
				Pango.cairo_show_layout(cr, layout);
				
			});
			operation.end_print.connect( (context) => 
			{
				
			});
			try
			{
				if( this.checkbuttonShowPrintDialog.active )
				{
					operation.run(PrintOperationAction.PRINT_DIALOG, this.dialogConfig);
				}
				else if( this.checkbuttonShowPreview.active )
				{
					operation.run(PrintOperationAction.PREVIEW, this.dialogConfig);
				}
			}
			catch(GLib.Error e)
			{
				stderr.printf("ERROR PRINTING: %s\n", e.message);
			}
			
		}
		protected void OnButtonSaveClicked(Button sender)
		{
			/*
			TreeIter iter;
			Value shop_type;
			if( !this.comboboxShopType.get_active_iter(out iter) )
			{
				var msg = new InfoDialog()
				{
					Title = SBText.__("Error"),
					Message = SBText.__("Invalid shop type")
				};
				msg.run();
				msg.destroy();
				return;
			}
			this.comboboxShopType.model.get_value(iter, 1, out shop_type);
			*/
			if( this._config == null )
			{
				this._config = new SBConfig(this.cfgFile, "point_of_sale");
			}
			var company = new HashMap<string, Value?>();
			company.set("company", this.entryCompany.text.strip());
			company.set("address", this.entryAddress.text.strip());
			company.set("city", this.entryCity.text.strip());
			company.set("phone_1", this.entryPhone1.text.strip());
			company.set("phone_2", this.entryPhone2.text.strip());
			company.set("fax", this.entryFax.text.strip());
			company.set("email", this.entryEmail.text.strip());
			company.set("reg", this.entryReg.text.strip());
			company.set("nit", this.entryNIT.text.strip());
			
			if( this.logoFilename.length > 0 && FileUtils.test(this.logoFilename, FileTest.EXISTS) )
			{
				string[] parts = SBFileHelper.GetParts(this.logoFilename);
				string f = "company_logo.%s".printf(parts[1]);
				string type = (parts[1] == "jpg") ? "jpeg" : parts[1];
				this.imageLogo.pixbuf.scale_simple(150, 150, Gdk.InterpType.BILINEAR).save("images/%s".printf(f), type);
				company.set("logo", f);
			}
			
			SBParameter.Update("company", SinticBolivia.Utils.JsonEncode(company));
			
			//stderr.printf("%s => %s\n", "textchild", (string)cfg.GetValue("textchild"));			
			//this._config.SetValue("address", this.entryAddress.text);
			//this._config.SetValue("city", this.entryCity.text);
			//this._config.SetValue("shop_type", (string)shop_type);
			//this._config.SetValue("shop_url", this.entryShopUrl.text.strip());
			/*
			if( (string)shop_type == "woocommerce" )
			{
				Entry entry = (Entry)((HashMap<string,Widget>)this._ecommerceWidgets)["wc_entry_api_key"];
				this._config.SetValue("wc_api_key", entry.text.strip());
				entry = (Entry)((HashMap<string,Widget>)this._ecommerceWidgets)["wc_entry_api_secret"];
				this._config.SetValue("wc_api_secret", entry.text.strip());
			}
			*/
			//##set printing settings
			this._config.SetValue("printer", (this.comboboxPrinter.get_child() as Entry).text.strip());
			this._config.SetValue("page_size", this.comboboxPageSizes.active_id);
			this._config.SetValue("print_preview", this.checkbuttonShowPreview.active ? "yes" : "no");
			this._config.SetValue("show_print_dialog", this.checkbuttonShowPrintDialog.active ? "yes" : "no");
			this._config.Save();
			//update global config
			SBGlobals.SetVar("config", (Object)new SBConfig("config.xml", "point_of_sale"));
			var msg = new InfoDialog()
			{
				Title = SBText.__("Settings saved"),
				Message = SBText.__("The settings has been saved.")
			};
			msg.run();
			msg.destroy();
			
		}
	}
}
