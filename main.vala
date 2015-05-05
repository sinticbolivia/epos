using GLib;
using Gtk;
using Gee;
using SinticBolivia;
using SinticBolivia.Database;
using SinticBolivia.Gtk;

namespace EPos
{
	/*
	void show_loading(string message)
	{
		var builder = (Builder)SBGlobals.GetVar("main_gui_builder");
		var dlg = (Dialog)builder.get_object("dialogLoading");
		var spinner = (Spinner)builder.get_object("spinner1");
		var lbl = (Label)builder.get_object("label12");
		dlg.name = "dialog-loading";
		lbl.label = message;
		spinner.start();
		dlg.show_all();
	}
	void hide_loading()
	{	       
		var builder = (Builder)SBGlobals.GetVar("main_gui_builder");
		var dlg = (Dialog)builder.get_object("dialogLoading");
		var spinner = (Spinner)builder.get_object("spinner1");
		spinner.stop();
		dlg.hide();
	}
	*/
	public class Wcpos : Object
	{
		protected 	string _UI_FILE = "";
		protected 	Window _mainWindow;
		protected 	MenuBar _menubarMain;
		protected 	Gtk.Menu	_menuManagement;
		protected 	SBNotebook 		notebook;
		protected	EventBox		eventboxQuickIcons;
		protected 	SBDashboard		dashboard;
		protected 	Button buttonHome;
		protected 	Button buttonPointOfSale;
		protected 	Builder _builder;
		//protected 	WidgetPOS _widgetPos = null;
		protected 	ImageMenuItem 	imagemenuitemQuit;
		protected 	ImageMenuItem 	imageMenuItemSettings;
		protected	Gtk.MenuItem	menuItemReports;
		
		protected	CheckMenuItem	menuitemHideQuickIcons;
		protected	ImageMenuItem	imagemenuitemAbout;
		protected 	Box				_boxQuickIcons;
		protected	Box				_boxMainContent;
		public		Label			labelCurrentUser;
		protected	Switch	_switch;
		protected	bool	_dataLoaded = false;
		protected	int		storeId = -1; 
		protected	int 		windowState = -1;
		protected	Button		buttonMinimize;
		protected	Button		buttonMaximize;
		protected	Button		buttonCloseWindow;
		//protected	Grid	_gridWidgets;
		
		//##declare modules hooks signals
		//public		signal 	void 	HookDashboardWidgets(Grid gridWidgets);
		//public		signal 	void 	HookSidebarButtons(Window gridWidgets);
		
		public	Window MainWindow
		{
			get{return this._mainWindow;}
		}
		
		public Wcpos()
		{
			if( !FileUtils.test("images", FileTest.IS_DIR) )
			{
				//create images dir
				DirUtils.create("images", 0777);
			}
			stdout.printf("OS => %s\n", SBOS.GetOS().OS);
			
			//this._UI_FILE = GLib.Environment.get_current_dir() + "/share/ui/" + "ui-v1.0.glade";
			try 
			{
				//this._builder = new Builder ();
				//this._builder.add_from_file (this._UI_FILE);
				//this._builder.connect_signals (null);
				//SBGlobals.SetVar("main_gui_builder", (Object)this._builder);
				this._builder				= GtkHelper.GetGladeUIFromResource((GLib.Resource)SBGlobals.GetValue("g_resource"), 
												"/net/sinticbolivia/ec-pos/ui/ui-v1.0.glade");
				this._mainWindow 			= (Window)this._builder.get_object ("windowMain");
				this._menubarMain			= (MenuBar)this._builder.get_object("menubarMain");
				this._mainWindow.name 		= "windowMain";
				this._menuManagement		= (Gtk.Menu)this._builder.get_object("menuManagement");
				this._boxMainContent		= (Box)this._builder.get_object("boxMainContent");
				this.eventboxQuickIcons		= (EventBox)this._builder.get_object("eventboxQuickIcons");
				this._switch				= (Switch)this._builder.get_object("switch1");
				this.labelCurrentUser		= (Label)this._builder.get_object("labelCurrentUser");
				this.buttonMinimize			= (Button)this._builder.get_object("buttonMinimize");
				this.buttonMaximize			= (Button)this._builder.get_object("buttonMaximize");
				this.buttonCloseWindow		= (Button)this._builder.get_object("buttonCloseWindow");
				
				//this._gridWidgets			= (Grid)this._builder.get_object("gridWidgets");
				//var hot_keys = AccelGroup();
				//hot_keys.connect(12);
				//set application icon
				this._mainWindow.icon = new Gdk.Pixbuf.from_file(SBFileHelper.SanitizePath("share/images/sinticbolivia-icon-40x40.png"));
				this.imagemenuitemQuit = this._builder.get_object("imagemenuitemQuit") as ImageMenuItem;
				this.menuitemHideQuickIcons = (CheckMenuItem)this._builder.get_object("menuitemHideQuickIcons");
				this.imagemenuitemAbout		= (ImageMenuItem)this._builder.get_object("imagemenuitemAbout");
				var eventboxQuickIcons 	= (EventBox)this._builder.get_object("eventboxQuickIcons");
				eventboxQuickIcons.name = "eventboxQuickIcons";
				this._boxQuickIcons		= (Box)this._builder.get_object("boxQuickIcons");
				this._boxQuickIcons.name 	= "boxQuickIcons";
				this._mainWindow.title = "Sintic Bolivia - Ecommerce Point of Sale";
				this._mainWindow.set_default_size(450, 400);
				this._mainWindow.window_position = WindowPosition.CENTER;
				
				this.imageMenuItemSettings = (ImageMenuItem)this._builder.get_object("imagemenuitemSettings");
				this.notebook = new SBNotebook(){margin_top = 5};
				
				this._boxMainContent.add(this.notebook);
				this._boxMainContent.show_all();
								
				this.buttonHome = (Button)this._builder.get_object("buttonHome");
				this.buttonHome.name = "button_home";
				this.buttonHome.label = null;
				this.buttonHome.tooltip_text = SBText.__("Home", "ec_pos");
				this.buttonHome.image = new Image.from_file(GLib.Environment.get_current_dir() + "/share/images/120.png");
				this.buttonHome.image_position = PositionType.TOP;
				this.buttonHome.set_size_request(48, 48);
				//this.buttonPointOfSale = (Button)this._builder.get_object("buttonPointOfSale");
				//this.buttonPointOfSale.label = null;
				//this.buttonPointOfSale.tooltip_text = SBText.__("Point of Sale");
				//this.buttonPointOfSale.image = new Image.from_file(GLib.Environment.get_current_dir() + "/share/images/sale-icon.png");
				//this.buttonPointOfSale.image_position = PositionType.TOP;
				this.SetStyles();
			} 
			catch (Error e) 
			{
				stderr.printf ("Could not load UI: %s\n", e.message);
			} 
			//##set global variables
			SBGlobals.SetVar("notebook", this.notebook);
			this.Build();
			this.SetEvents();
			this.notebook.show_all();
		}
		protected void SetStyles()
		{
			try
			{
				//##set css file
				var css = new CssProvider();
				css.load_from_path (GLib.Environment.get_current_dir() + "/share/css/style.css");
				//Gdk.Display display = this._mainWindow.get_display ();
				Gdk.Screen screen = this._mainWindow.get_screen ();
				StyleContext.add_provider_for_screen(screen, css, 600);
			}
			catch(GLib.Error e)
			{
				stderr.printf("ERROR: Error loading styles\n%s\n", e.message);
			}
		}
		protected void Build()
		{
			this.BuildMenubar();
			this.menuitemHideQuickIcons.active = true;
		}
		protected void SetEvents()
		{
			//##set events
			this._mainWindow.destroy.connect(this.on_destroy);
			this._mainWindow.key_press_event.connect((e) => 
			{
				var args = (Gdk.EventKey)e;
				stdout.printf("Key code: %u\n", args.keyval);
				if( (int)args.keyval ==  65513) //left alt
				{
					/*
					if( this._menubarMain.visible )
					{
						this._menubarMain.visible = false;
					}
					else
					{
						this._menubarMain.visible = true;
						this._menubarMain.show_all();
					}
					*/
				}
				return false;
			});

			this.imagemenuitemQuit.activate.connect(this.on_menuitem_quite_activated);
			this.imageMenuItemSettings.activate.connect(() => 
			{
				var dlg = new DialogConfig();
				dlg.LoadData();
				dlg.GetDialog().show_all();
			});
			this.menuitemHideQuickIcons.activate.connect( () => 
			{
				if(this.menuitemHideQuickIcons.active)
				{
					this.eventboxQuickIcons.visible = true;
				}
				else
				{
					this.eventboxQuickIcons.visible = false;
				}
			});
			this.imagemenuitemAbout.activate.connect(this.OnMenuItemAboutActivate);
			this.buttonHome.clicked.connect(this.OnButtonHomeClicked);
			//this.buttonPointOfSale.clicked.connect(this.OnButtonPointOfSaleClicked);
			this._switch.notify["active"].connect(this.OnSwitchActive);
			this._mainWindow.window_state_event.connect( (event) => 
			{
				this.windowState = event.new_window_state;
				stdout.printf("new window state: %d\n", this.windowState);
				return true;
			});
			this.buttonMinimize.clicked.connect( () => 
			{
				//this._mainWindow.unmaximize();
				this._mainWindow.iconify();
			});
			this.buttonMaximize.clicked.connect( () => 
			{
				//Value maximized = Value(typeof(bool));
				//this._mainWindow.get_property("is_maximized", ref maximized);
				//stdout.printf("maximize clicked (%d)\n", this.windowState);
				if( this.windowState == 388/*128*/  )
					this._mainWindow.unmaximize();
				else
					this._mainWindow.maximize();
			}); 
			this.buttonCloseWindow.clicked.connect( () => 
			{
				this.Quit();
			});
		}
		protected void OnSwitchActive()
		{
			if( this._switch.active )
			{
				stdout.printf("on\n");
			}
			else
			{
				stdout.printf("off\n");
			}
		}
		//[CCode (cname = "G_MODULE_EXPORT on_menuitem_quite_activated", instance_pos = -1)]
		public void on_menuitem_quite_activated()
		{
			this.Quit();
		}
		//[CCode (instance_pos = -1)]
		public void on_destroy(Widget window)
		{
			this.Quit();
		}
		protected void OnMenuItemAboutActivate()
		{
			
		}
		protected void OnButtonHomeClicked()
		{
			
			if( this.notebook.GetPage("dashboard") == null)
			{
				this.dashboard	= new SBDashboard();
				this.dashboard.show();
				this.dashboard.Width = 700;
				
		
				/*****************************/
				var pts = new WidgetPendingToSyncOrders(SBText.__("Woocommerce\nPending to Sync Orders"));
				pts.show();
				this.dashboard.Add(pts);
				/*****************************/
				this.notebook.AddPage("dashboard", SBText.__("Dashboard"), this.dashboard);
			}
			this.notebook.SetCurrentPageById("dashboard");
		}
		/*
		public void OnButtonPointOfSaleClicked(Button button)
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var dlg = new Dialog();
			dlg.title = SBText.__("Store Selection");
			//dlg.parent = this._mainWindow;
			dlg.modal = true;
			dlg.set_size_request(350, 300);
			var box	= (Box)dlg.get_content_area();
			var action_area = (Box)dlg.get_action_area();
			var scroll = new ScrolledWindow(null, null){expand = true};
			scroll.show();
			var treeview	= new TreeView.with_model(new ListStore(3, typeof(int), typeof(string), typeof(string)))
			{
				rules_hint = true
			};
			string[,] cols = 
			{
				{SBText.__("Id"), "text", "80", "center", "", ""},
				{SBText.__("Name"), "text", "150", "left", "", ""},
				{SBText.__("Type"), "text", "80", "center", "", ""}
				
			};
			GtkHelper.BuildTreeViewColumns(cols, ref treeview);
			treeview.show();
			scroll.add_with_viewport(treeview);
			var label = new Label(SBText.__("Select Store"));
			label.show();
			box.add(label);
			box.add(scroll);
			var stores = (ArrayList<SBDBRow>)dbh.GetResults("select * from stores order by store_name ASC");
			
			foreach(SBDBRow row in stores)
			{
				TreeIter iter;
				(treeview.model as ListStore).append(out iter);
				(treeview.model as ListStore).set(iter, 0, int.parse(row.Get("store_id")), 
										1, row.Get("store_name"),
										2, row.Get("store_type")
				);
			}
			var btn_cancel = new Button.with_label(SBText.__("Cancel"));
			var btn_accept = new Button.with_label(SBText.__("Accept"));
			btn_cancel.show();
			btn_accept.show();
			btn_cancel.get_style_context().add_class("button-cancel");
			btn_accept.get_style_context().add_class("button-accept");
			action_area.add(btn_accept);
			action_area.add(btn_cancel);
			btn_cancel.clicked.connect( () => 
			{
				dlg.dispose();
			});
			btn_accept.clicked.connect( () => 
			{
				TreeModel model;
				TreeIter _iter;
				if( treeview.get_selection().get_selected(out model, out _iter) )
				{
					Value v_store_id;
					model.get_value(_iter, 0, out v_store_id);
					var store = new ECStore.from_id((int)v_store_id);
					if( this.notebook.GetPage("pos") == null)
					{
						this._widgetPos = new WidgetPOS(store);
						this._widgetPos.show();
						this.notebook.AddPage("pos", SBText.__("Point of Sale"), this._widgetPos);
					}
					this.notebook.SetCurrentPageById("pos");
				}
				dlg.dispose();
			});
			treeview.row_activated.connect( () => 
			{
				TreeModel model;
				TreeIter _iter;
				treeview.get_selection().get_selected(out model, out _iter);
				Value v_store_id;
				model.get_value(_iter, 0, out v_store_id);
				var store = new ECStore.from_id((int)v_store_id);
				if( this.notebook.GetPage("pos") == null)
				{
					this._widgetPos = new WidgetPOS(store);
					//this._widgetPos.LoadData();
					this._widgetPos.show();
					this.notebook.AddPage("pos", SBText.__("Point of Sale"), this._widgetPos);
				}
				this.notebook.SetCurrentPageById("pos");
				dlg.dispose();
			});
			dlg.show();
		}
		*/
		public void Hide()
		{
			this._mainWindow.hide();
		}
		protected void BuildMenubar()
		{
			//##add taxes menu
			var item_taxes = new Gtk.MenuItem.with_label(SBText.__("Taxes"));
			item_taxes.show();
			item_taxes.activate.connect( () => 
			{
				{
					var w = new WidgetTaxes();
					w.show();
					this.notebook.AddPage("taxes", SBText.__("Sales Tax"), w);
				}
				this.notebook.SetCurrentPageById("taxes");
			});
			this._menuManagement.add(item_taxes);
			//## add reports menu
			this.menuItemReports = new Gtk.MenuItem.with_label(SBText.__("Reports"));
			this.menuItemReports.show();
			this.menuItemReports.submenu = new Gtk.Menu();
			
			var menu_item_daily_report = new Gtk.MenuItem.with_label(SBText.__("Daily Report"));
			menu_item_daily_report.show();
			this.menuItemReports.submenu.add(menu_item_daily_report);
			menu_item_daily_report.activate.connect( () => 
			{
				if( this.notebook.GetPage("daily-report") == null )
				{
					var w = new WidgetDailyReport();
					w.show();
					this.notebook.AddPage("daily-report", SBText.__("Daily Reports"), w);
				}
				this.notebook.SetCurrentPageById("daily-report");
			});
			
			
			this._menuManagement.add(this.menuItemReports);
		}
		protected void ShowAll()
		{
			//##call hooks for reports menu
			var args3 = new SBModuleArgs<Gtk.MenuItem>();
			args3.SetData(this.menuItemReports);
			SBModules.do_action("reports_menu", args3);
			
			/*
			this.HookDashboardWidgets.connect( (_grid) => 
			{
				var widget1 = new SBDashboardWidget("Local Products");
				widget1.get_style_context().add_class("dashboard-widget");
				var widget2 = new SBDashboardWidget("Remote Products");
				_grid.attach(widget1, 0, 0, 1, 1);
				_grid.attach(widget2, 1, 0, 1, 1);
				_grid.show_all();
			});
			this.HookDashboardWidgets(this._gridWidgets);
			*/
			var margs = new SBModuleArgs<HashMap>();
			var data = new HashMap<string, Widget>();
			data.set("quickicons", this._boxQuickIcons);
			//data.set("notebook", this.notebook);
			margs.SetData(data);
			SBModules.do_action("init_sidebar", margs);
			
			var args1 = new SBModuleArgs<MenuBar>();
			args1.SetData(this._menubarMain);
			SBModules.do_action("init_menubar", args1);
			
			var args2 = new SBModuleArgs<Gtk.Menu>();
			//var data2	= new HashMap<string, Widget>();
			args2.SetData(this._menuManagement);
			SBModules.do_action("init_menu_management", args2);
			
			//##set current username
			var user = (SBUser)SBGlobals.GetVar("user");
			this.labelCurrentUser.label = user.Username;
			//##show the dashboard
			GLib.Signal.emit_by_name(this.buttonHome, "clicked");
			
			this._mainWindow.maximize();
			
			//show window
			this._mainWindow.show();
		}
		/*
		public int SyncData()
		{
			var cfg = (SBConfig)SBGlobals.GetVar("config");
			var sync = new SBWCSync((string)cfg.GetValue("shop_url"), 
									(string)cfg.GetValue("wc_api_key"),
									(string)cfg.GetValue("wc_api_secret"));
			int store_id = (int)sync.SyncStore();
			if( store_id > 0 )
			{
				sync.SyncCategories(store_id);
				sync.SyncProducts(store_id);
				this.storeId = store_id;
			}
			
			this._dataLoaded = true;
			
			return 0;
		}
		
		public int CheckLoadedData()
		{
			while(!this._dataLoaded){}
			hide_loading();
			var app = (Wcpos)SBGlobals.GetVar("app");
			//get store data
			var store = new ECStore.from_id(this.storeId);
			SBGlobals.SetVar("store", store);
			//set window title
			app.MainWindow.title = "%s - Point of Sale".printf(store.Name);
			return 0;
		}
		*/
		protected void Quit()
		{
			var msg = new InfoDialog("error")
			{
				Title	= SBText.__("Logout"),
				Message	= SBText.__("Are you sure want to quit?")
			};
			var btn = (Button)msg.add_button(SBText.__("Quit"), ResponseType.YES);
			btn.get_style_context().add_class("button-green");
			msg.modal = false;
			
			if( msg.run() == ResponseType.YES )
			{
				msg.destroy();
				SBModules.do_action("on_quit", new SBModuleArgs<string>());
				Gtk.main_quit();
			}
			msg.destroy();
			//this._mainWindow.show();
		}
		/******************************/
		/***** static method sections */
		/******************************/
		public static void LoadModules()
		{
			SBModules.LoadModules("./modules");
			
			string[] init_modules = {"Modules", "Users"};
			foreach(string mod in init_modules)
			{
				//SBModules.GetModule(mod).Enabled();
				SBModules.GetModule(mod).Init();
			}
			
			SBModules.do_action("modules_loaded", new SBModuleArgs<string>());
			//##add ec pos hooks
			//ECHooks.AddInventoryHooks();
		}
		public static void Start()
		{
			GLib.Environment.set_variable("LC_NUMERIC", "en_GB.UTF-8", true);
			//##initialize config file
			var cfg = new SBConfig("config.xml", "point_of_sale");
			SBGlobals.SetVar("config", cfg);
			//##set language
			SBText.LoadLanguage((string)cfg.GetValue("language", "en_US"), "ec_pos", "./share/locale/");
			string db_engine = (string)cfg.GetValue("database_engine", "sqlite3");
			string db_server = (string)cfg.GetValue("db_server", "");
			if( db_engine.length <= 0 )
			{
				stderr.printf("There is no database engine selected, please run setup to configure your engine.\n");
				Gtk.main_quit();
				return;
			}
			if( db_server.length <= 0 )
			{
				stderr.printf("There is no database server, please run setup to configure your connection.\n");
				Gtk.main_quit();
				return;
			}
			SBDatabase dbh = null;
			//##initialize datase
			if( db_engine == "sqlite3")
			{
				dbh = new SBSQLite( SinticBolivia.SBFileHelper.SanitizePath("db/%s".printf(db_server)) );
			}
			else if( db_engine == "mysql")
			{
				string dbname 	= (string)cfg.GetValue("db_name", "");
				string user 	= (string)cfg.GetValue("db_user", "");
				string pass 	= (string)cfg.GetValue("db_pass");
				int port		= int.parse((string)cfg.GetValue("db_port", "3306"));
				dbh = new SBMySQL(db_server, dbname, user, pass, port);
			}
			else
			{
				stderr.printf("ERROR: The database engine '%s' is not supported.\n", db_engine);
				Gtk.main_quit();
			}
			dbh.Open();
			SBGlobals.SetVar("dbh", dbh);
			//##set error loggin handler
			GLib.Log.set_default_handler( (domain, log_levels, message) => 
			{
				string log_file = "";
				stdout.printf("%s\n", message);
				if( log_levels == LogLevelFlags.LEVEL_ERROR )
				{
					log_file = "error.log";
				}
				if( log_file.length <= 0 )
				{
					return;
				}
				File fh = File.new_for_path(log_file);
				
				try
				{
					FileOutputStream stream = null;
					if( !FileUtils.test(log_file, FileTest.IS_REGULAR) )
					{
						stream = fh.create(FileCreateFlags.NONE);
						
					}
					else
					{
						stream = fh.append_to(FileCreateFlags.NONE);
					}
					stream.write(("ERROR: %s\n".printf(message)).data);
					//stream = null;
				}
				catch(GLib.Error e)
				{
					stdout.printf("ERROR: %s\n", e.message);
				}
				
			});
			//##creare application main window
			var app = new Wcpos();
			//app.Hide();
			SBGlobals.SetVar("app", app);
			
			//##load modules
			Wcpos.LoadModules();
			
			var args = new SBModuleArgs<HashMap>();
			var data = new HashMap<string, Value?>();
			data.set("dialog", null);
			args.SetData(data);
			
			//##get login dialog
			SBModules.do_action("login_dialog", args);
			if(data["dialog"] != null )
			{
				(data["dialog"] as Dialog).modal = true;
				(data["dialog"] as Dialog).show();
				(data["dialog"] as Dialog).destroy.connect( () => 
				{
					string res = (data["dialog"] as Dialog).get_data<string>("is_authenticated");
					if( res == "yes" )
					{
						data["dialog"] = null;
						app.ShowAll();
					}
					else
					{
						SBModules.do_action("on_quit", new SBModuleArgs<string>());
						Gtk.main_quit();
					}
				});
			}
			else
			{
				app.ShowAll();
			}
		}
		public static int main(string[] args)
		{
			//stdout.printf("Working directory: %s\n", Environment.get_current_dir());
						
			string cfg_file = "config.xml";
			/*
			if( args.length > 1 )
			{
				for(int i = 1; i < args.length; i++)
				{
					if( args[i] == "--config" && args[i + 1] != null )
					{
						cfg_file = args[i + 1].strip();
					}
				}
			}
			*/
			Gtk.init(ref args);
			
			//bool show_setup = FileUtils.test("setup.xml", FileTest.EXISTS);
			if (Thread.supported () == false) 
			{
				stderr.printf ("Threads are not supported!\n");
			}
			//##load global resources
			var gres = GtkHelper.LoadResource("share/resources/ec-pos.gresource");
			SBGlobals.SetValue("g_resource", gres);
			//check if config file exists
			if( !FileUtils.test(cfg_file, FileTest.EXISTS) )
			{
				var dlg = new DialogConfig();
				dlg.GetDialog().modal = true;
				dlg.GetDialog().show();
				dlg.GetDialog().destroy.connect(() => 
				{
					Wcpos.Start();
				});
				
			}
			else
			{
				Wcpos.Start();
			}
			
			Gtk.main();
			return 0;
		}
	} 
}
