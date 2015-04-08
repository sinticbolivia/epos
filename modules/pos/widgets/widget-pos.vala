using GLib;
using Gtk;
using Gee;
//using Soup;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace EPos
{
	public class WidgetPOS : BasePos
	{
		enum ProductColumns
		{
			IMAGE,
			EXTERNAL_ID,
			NAME,
			QTY,
			PRICE,
			ADD,
			ID,
			N_COLS
		}
		enum OrderColumns
		{
			QTY,
			PRODUCT_NAME,
			PRICE,
			SUB_TOTAL,
			TAX,
			TOTAL,
			ACTION,
			PRODUCT_ID,
			EXTERNAL_ID,
			TAX_RATE,
			NUM_COLS
		}
		protected 	Builder 		_builder;
		public		Window			windowPos;
		public		Box				box1;
		public		Paned			panedPos;
		public 		ComboBox 		comboboxCategories;
		public		Entry			entrySearchProduct;
		public		ScrolledWindow	scrolledwindow1 = null;
		protected	SBFixed			fixedProducts;
		public 		TreeView 		treeviewProducts = null;
		public 		TreeView 		treeviewOrderItems;
		public		Label			labelTotalProducts;
		public 		ToggleButton	togglebuttonListView;
		public 		ToggleButton	togglebuttonGridView;
		protected	ButtonBox		buttonboxPosButtons;
		public 		Button 			buttonRefreshProducts;
		public		Button			buttonCreateCustomer;
		public		Button			buttonCancel;
		public		Button			buttonRegisterSale;
		protected	Grid			gridTotals;
		public		Label			labelSubTotal;
		public		Label			labelTotal;
		protected	Label			labelTax;
		public		Label			labelVAT;
		public		Entry			entryDiscount;
		public 		ComboBox 		comboboxPaymentMethod;
		public 		Entry			entrySearchCustomer;
		protected	Button			buttonGuestCustomer;
		protected	Button			buttonClearCustomer;
		public		TextView		textviewNotes;
		protected	bool			_dataLoaded = false;
		protected	bool			_categoriesLoaded = false;
		protected	bool			_productsLoaded		= false;
		protected	bool			_offline = true;
		protected	string			_currentView = "list";
		protected	bool			lock_grid_view = false;
		protected	bool			lock_list_view = false;
		protected	int				customerId = 0;
		protected	bool			customerCreated = false;
		protected	ArrayList<SBProduct>	productsToFill;
		
		public WidgetPOS()
		{
			this._builder = (SBModules.GetModule("Pos") as SBGtkModule).GetGladeUi("wc-pos.glade");
			this.productsToFill	= new ArrayList<SBProduct>();
		
			/*
			Type type = typeof(WidgetPOS);
			var self = Object.new(type);
			ObjectClass ocl = (ObjectClass)type.class_ref();
			foreach(ParamSpec spec in ocl.list_properties())
			{
				stdout.printf("WidgetPOS.%s\n", spec.get_name());
			}
			*/
			//##get widgets from glade file
			this.windowPos				= (Window)this._builder.get_object("windowPos");
			this.box1					= (Box)this._builder.get_object("box1");
			this.labelStoreName			= (Label)this._builder.get_object("labelStoreName");
			this.panedPos				= (Paned)this._builder.get_object("panedPos");
			this.comboboxCategories 	= (ComboBox)this._builder.get_object("comboboxCategories");
			this.entrySearchProduct		= (Entry)this._builder.get_object("entrySearchProduct");
			this.scrolledwindow1		= (ScrolledWindow)this._builder.get_object("scrolledwindow1");
			this.labelTotalProducts		= (Label)this._builder.get_object("labelTotalProducts");
			this.togglebuttonListView	= (ToggleButton)this._builder.get_object("togglebuttonListView");
			this.togglebuttonGridView	= (ToggleButton)this._builder.get_object("togglebuttonGridView");
			this.buttonboxPosButtons	= (ButtonBox)this._builder.get_object("buttonboxPosButtons");
			this.buttonRefreshProducts 	= (Button)this._builder.get_object("buttonRefreshProducts");
			this.buttonCreateCustomer	= (Button)this._builder.get_object("buttonCreateCustomer");
			this.buttonCancel			= (Button)this._builder.get_object("buttonCancel");
			this.buttonRegisterSale		= (Button)this._builder.get_object("buttonRegisterSale");
			this.gridTotals				= (Grid)this._builder.get_object("gridTotals");
			this.labelSubTotal			= (Label)this._builder.get_object("labelSubTotal");
			this.labelTotal				= (Label)this._builder.get_object("labelTotal");
			this.labelTax				= (Label)this._builder.get_object("labelTax");
			this.labelVAT				= (Label)this._builder.get_object("labelVAT");
			this.entryDiscount			= (Entry)this._builder.get_object("entryDiscount");
			this.entryDiscount.name		= "entry-discount";
			this.treeviewOrderItems 	= (TreeView)this._builder.get_object("treeviewOrderItems");
			this.comboboxPaymentMethod 	= (ComboBox)this._builder.get_object("comboboxPaymentMethod");
			this.entrySearchCustomer	= (Entry)this._builder.get_object("entrySearchCustomer");
			this.buttonGuestCustomer	= (Button)this._builder.get_object("buttonGuestCustomer");
			this.buttonClearCustomer	= (Button)this._builder.get_object("buttonClearCustomer");
			this.textviewNotes			= (TextView)this._builder.get_object("textviewNotes");
			this.Build();
			//this.LoadData();
			this.SetEvents();
			
			this.box1.reparent(this);
		}
		protected void Build()
		{
			this.labelSubTotal.name = "label-subtotal";
			this.labelTax.name		= "label-tax-total";
			this.labelTotal.name	= "label-total";
			
			var args = new SBModuleArgs<HashMap<string, Value?>>();
			var data = new HashMap<string, Value?>();
			data["dbh"]			= this.Dbh;
			data["box_totals"] 	= this.gridTotals;
			data["buttons"] 	= new ArrayList<Button>();
			args.SetData(data);
			SBModules.do_action("pos_buttons", args);
			//##build pos buttons
			foreach(var btn  in (data["buttons"] as ArrayList<Button>))
			{
				btn.show();
				this.buttonboxPosButtons.add(btn);
			}
			
			//##build combobox categories
			this.comboboxCategories.model = new TreeStore(2, typeof(string), typeof(string));
			var cell = new CellRendererText();
			this.comboboxCategories.pack_start(cell, false);
			this.comboboxCategories.set_attributes(cell, "text", 0);
			this.comboboxCategories.set_id_column(1);
			//build combobox payment methods
			cell = new CellRendererText();
			this.comboboxPaymentMethod.pack_start(cell, false);
			this.comboboxPaymentMethod.set_attributes(cell, "text", 0);
			this.comboboxPaymentMethod.set_id_column(1);
			this.comboboxPaymentMethod.model = new ListStore(2, typeof(string), typeof(string));
			TreeIter iter;
			(this.comboboxPaymentMethod.model as ListStore).append(out iter);
			(this.comboboxPaymentMethod.model as ListStore).set(iter, 0, SBText.__("-- payment method --"), 1, "-1");
			(this.comboboxPaymentMethod.model as ListStore).append(out iter);
			(this.comboboxPaymentMethod.model as ListStore).set(iter, 0, "Cash", 1, "cod");
			(this.comboboxPaymentMethod.model as ListStore).append(out iter);
			(this.comboboxPaymentMethod.model as ListStore).set(iter, 0, "Credit Card", 1, "cc");
			this.comboboxPaymentMethod.active_id = "-1";
			this.comboboxPaymentMethod.show_all();
						
			//##build order items treeview
			this.treeviewOrderItems.model = new ListStore(OrderColumns.NUM_COLS, 
															typeof(int), //product quantity
															typeof(string), //product name
															typeof(string), //product price
															typeof(string), //subtotal
															typeof(string), //tax
															typeof(string), //total
															typeof(Gdk.Pixbuf), //remove button
															typeof(int), //product_id
															typeof(int), //external id
															typeof(string) //tax rate
			);
			this.treeviewOrderItems.rules_hint = true;
			string[,] cols = 
			{
				{SBText.__("Qty"), "text", "40", "center", "editable", "resizable"},
				{SBText.__("Product"), "text", "200", "left", "", "resizable"},
				{SBText.__("Price"), "text", "60", "right", "editable", "resizable"},
				{SBText.__("Sub Total"), "text", "65", "right", "", ""},
				{SBText.__("Tax"), "text", "60", "right", "", ""},
				{SBText.__("Total"), "text", "90", "right", "", "resizable"},
				{SBText.__(""), "pixbuf", "40", "center", "", "resizable"}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewOrderItems);
			this.treeviewOrderItems.get_column(OrderColumns.ACTION).max_width = 90;
			this.treeviewOrderItems.get_column(OrderColumns.ACTION).set_data<string>("action", "remove");	
			this.entrySearchCustomer.completion = new EntryCompletion();		
			this.entrySearchCustomer.completion.model = new ListStore(2, typeof(string), typeof(int));
			this.entrySearchCustomer.completion.text_column = 0;
			this.entrySearchCustomer.completion.set_match_func( (completion, key, iter) => 
			{
				return true;
			});
			this.buttonGuestCustomer.visible = false;
			var args1 = new SBModuleArgs<Grid>();
			args1.SetData(this.gridTotals);
			SBModules.do_action("pos_totals_grid", args1);
		}
		protected void SetEvents()
		{
			this.size_allocate.connect( (allocation) => 
			//this.map.connect( () => 
			{
				int w = this.get_allocated_width();
				this.panedPos.position = (int)(w * 0.53);
			});
			//##set events
			this.comboboxCategories.changed.connect(this.OnComboBoxCategoriesChanged);
			this.entrySearchProduct.key_release_event.connect( this.OnEntrySearchProductKeyRelease );
			this.togglebuttonGridView.toggled.connect(this.OnToggleButtonGridViewToggled);
			this.togglebuttonListView.toggled.connect(this.OnToggleButtonListViewToggled);
			//this.togglebuttonGridView.clicked.connect(this.OnToggleButtonGridViewClicked);
			//this.togglebuttonListView.clicked.connect(this.OnToggleButtonListViewClicked);
			this.buttonRefreshProducts.clicked.connect(this.OnButtonRefreshProductsClicked);
			this.buttonCreateCustomer.clicked.connect(this.OnButtonCreateCustomerClicked);
			this.buttonCancel.clicked.connect(this.resetOrder);
			this.buttonRegisterSale.clicked.connect(this.OnButtonRegisterSaleClicked);
			//##add event to remove product from order
			this.treeviewOrderItems.button_release_event.connect(this.OnOrderItemsButtonReleaseEvent);
			(this.treeviewOrderItems.get_column(OrderColumns.QTY).get_cells().nth_data(0) as CellRendererText).edited.connect(this.OnOrderItemQtyEdited);		
			(this.treeviewOrderItems.get_column(OrderColumns.PRICE).get_cells().nth_data(0) as CellRendererText).edited.connect(this.OnOrderItemPriceEdited);
			this.entrySearchCustomer.key_release_event.connect(this.OnSearchCustomerKeyReleaseEvent);
			this.entrySearchCustomer.completion.match_selected.connect(this.OnCustomerSelected);
			this.entrySearchCustomer.icon_release.connect(this.OnEntrySearchCustomerIconRelease);
			this.buttonGuestCustomer.clicked.connect(this.OnButtonGuestCustomerClicked);
			this.buttonClearCustomer.clicked.connect(this.OnButtonClearCustomerClicked);
		}
		protected void _buildProductTreeView()
		{
			this.treeviewProducts = new TreeView();
			//build product list model
			this.treeviewProducts.model = new ListStore(ProductColumns.N_COLS, 
														typeof(Gdk.Pixbuf), //image
														typeof(int), //Xid
														typeof(string), //name
														typeof(int), //qty
														typeof(string), //price
														typeof(Gdk.Pixbuf), //add button
														typeof(int) //id
			);
			string[,] cols = 
			{
				{SBText.__("Image"), "pixbuf", "100", "center", "", ""},
				{SBText.__("ID"), "text", "60", "center", "", ""},
				{SBText.__("Product"), "text", "250", "left", "", "resizable"},
				{SBText.__("Qty"), "text", "60", "center", "", "resizable"},
				{SBText.__("Price"), "text", "70", "right", "", "resizable"},
				{SBText.__("Add"), "pixbuf", "90", "center", "", "resizable"},
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewProducts);
			//build action column
			var col = this.treeviewProducts.get_column(ProductColumns.ADD);
			col.set_data<string>("action", "add");
		
			this.treeviewProducts.button_release_event.connect(this.OnButtonReleaseEvent);
		}
		public override void LoadData()
		{
			this._fillCategories();
			/*
			string query = "SELECT COUNT(*) as total_products FROM products WHERE store_id = %d".
								printf(this.storeId);
			long total_products = this.Dbh.GetRow(query).GetInt("total_products");
			this.productsToFill = EPosHelper.GetStoreProducts(this.storeId, this.Dbh);
			stdout.printf("LoadData(), size: %d\n", this.productsToFill.size);
			this._fillProducts("list");
			this.labelTotalProducts.label = total_products.to_string();
			*/
			this.togglebuttonListView.active = true;
			
		}
		protected void _fillCategories()
		{
			TreeIter iter;
			//clear categories combobox
			(this.comboboxCategories.model as TreeStore).clear();
			(this.comboboxCategories.model as TreeStore).append(out iter, null);
			(this.comboboxCategories.model as TreeStore).set(iter,
				0, SBText.__("-- categories --"),
				1, "-1"
			);		
			this.comboboxCategories.active_id = "-1";
			//Gdk.threads_enter();
			
			var cats = EPosHelper.GetCategories(this.storeId, 0, this.Dbh);
						
			foreach(var cat in cats)
			{
				//##insert categories
				(this.comboboxCategories.model as TreeStore).append(out iter, null);
				(this.comboboxCategories.model as TreeStore).set(iter,
					0, cat.Name,
					1, cat.Id.to_string()
				);				
				TreeIter citer;
				foreach(var child in cat.Childs)
				{
					(this.comboboxCategories.model as TreeStore).append(out citer, iter);
					(this.comboboxCategories.model as TreeStore).set(citer,
						0, child.Name,
						1, child.Id.to_string()
					);				
				}
			}
			//Gdk.threads_leave();
			this._categoriesLoaded = true;
		}
		public void _fillProducts(string view = "list")
		{
			this._currentView = view;
			this.labelTotalProducts.label = "%d".printf(this.productsToFill.size);
			try
			{
				new Thread<int>.try("Fill pos products thread", this.ThreadFillProducts);
			}
			catch(GLib.Error e)
			{
				stderr.printf("THREAD ERROR: %s\n", e.message);
			}
			
		}
		protected int ThreadFillProducts()
		{
			string view = this._currentView;
			stdout.printf("(Thread)total products to fill: %d, View:%s\n", this.productsToFill.size, view);
			
			GLib.Idle.add( () => 
			{
				if( this.scrolledwindow1.get_child() != null )
				{
					this.scrolledwindow1.get_child().destroy();
				}
				if( view == "list" )
				{
					this._buildProductTreeView();
					this.scrolledwindow1.add(this.treeviewProducts);
					this.scrolledwindow1.show_all();
				}
				else if( view == "grid" )
				{
					this.fixedProducts = new SBFixed()
					{
						Width = this.scrolledwindow1.get_allocated_width()
					};
					this.fixedProducts.SetWidgetSize(100, 110);
					this.fixedProducts.show();
					this.scrolledwindow1.add_with_viewport(this.fixedProducts);
					this.scrolledwindow1.show_all();
				}
				return false;
			}); //end idle
			
			string images_path = SBFileHelper.SanitizePath("images/store_%d/".printf(this.storeId));
			var placeholder = (SBModules.GetModule("Pos") as SBGtkModule).GetPixbuf("placeholder-80x80.png");
			foreach(var prod in this.productsToFill)
			{
				string product_image = images_path + prod.GetThumbnail();
				Gdk.Pixbuf? prod_pixbuf = null;
				if( FileUtils.test(product_image, FileTest.IS_REGULAR) )
				{
					prod_pixbuf = new Gdk.Pixbuf.from_file(product_image);
					if( prod_pixbuf.width > 80 )
					{
						prod_pixbuf = prod_pixbuf.scale_simple(80, 80, Gdk.InterpType.BILINEAR);
					}
				}
				
				if( view == "list" )
				{
					string add_icon	= SBFileHelper.SanitizePath("share/images/add-icon.png");		
					var add_pixbuf = new Gdk.Pixbuf.from_file(add_icon);
					GLib.Idle.add( () => 
					{
						TreeIter iter;
						(this.treeviewProducts.model as ListStore).append(out iter);
						(this.treeviewProducts.model as ListStore).set(iter,
													0, prod_pixbuf == null ? placeholder : prod_pixbuf,
													1, prod.Id,
													2, prod.Name, 
													3, prod.Quantity, 
													4, "%.2lf".printf(prod.Price),
													5, add_pixbuf,
													6, prod.Id
						);
						return false;
					});
					//this.treeviewProducts.show_all();
				}
				else if( view == "grid" ) 
				{
					string label = "Price: %.2lf".printf(prod.Price);
					Button btn = new Button.with_label(label);
					btn.show();
					//btn.tooltip_text = product.get_string_member("title");
					btn.has_tooltip = true;
					var tooltip_window = new Window(){skip_taskbar_hint = true};
					tooltip_window.decorated = false;
					var box = new Box(Gtk.Orientation.VERTICAL, 5){margin = 10};
					box.pack_start(new Label("Name: %s".printf(prod.Name) ){xalign = 0});
					box.pack_start(new Label("Price: %.2lf".printf(prod.Price)){xalign = 0});
					box.pack_start(new Label("Stock: %d".printf(prod.Quantity)){xalign = 0});
					box.pack_start(new Label("Woo ID: %d".printf(prod.GetInt("extern_id"))){xalign = 0});
					box.show_all();
					tooltip_window.add(box);
					tooltip_window.name = "gtk-tooltip";
					btn.set_tooltip_window(tooltip_window);
					btn.query_tooltip.connect( (_x, _y, _keyboard_tooltip, _tooltip) => 
					{
						//btn.get_tooltip_window().show_all();
						return true;
					});
					btn.expand = false;
					btn.vexpand = false;
					btn.hexpand = false;
					btn.set_size_request(80,80);
					btn.image = new Image.from_pixbuf(prod_pixbuf != null ? prod_pixbuf : placeholder);
					btn.image_position = PositionType.TOP;
					btn.clicked.connect( () => 
					{
						this._addProductToOrder(prod);
					});
					GLib.Idle.add( () => 
					{
						this.fixedProducts.AddWidget(btn);
						return false;
					});
				}
			}//end foreach
			
			return 0;
		}
		protected uint timeout = 0;
		
		protected bool OnEntrySearchProductKeyRelease()
		{
			string keyword = this.entrySearchProduct.text.strip();
			if( keyword.length <= 0 )
			{
				this.OnComboBoxCategoriesChanged();
				return false;
			}
			GLib.Source.remove(this.timeout);
			
			this.timeout = GLib.Timeout.add(400, () => 
			{
				stdout.printf("searching products\n");
				string query = "SELECT p.*, a.file AS thumbnail "+
								"FROM products p "+
									"LEFT JOIN attachments a ON a.object_id = p.product_id " +
								"WHERE product_name LIKE '%s' "+
								"AND p.product_id = a.object_id "+
								"AND store_id = %d "+
								"AND LOWER(a.object_type) = 'product' " +
								"AND (a.type = 'image_thumbnail' OR a.type = 'image') "+
								"GROUP BY p.product_id ";
				query = query.printf("%"+keyword+"%", this.storeId);
				
				var rows = this.Dbh.GetResults(query);
				this.productsToFill = new ArrayList<SBProduct>();
				foreach(var row in rows)
				{
					var p = new SBProduct.with_db_data(row);
					this.productsToFill.add(p);
				}
				this._fillProducts(this._currentView);
				return false;
			});		
			
			return true;
		}
		/*
		protected int _checkLoadedData()
		{
			while( !this._dataLoaded )
			{
				if( this._categoriesLoaded && this._productsLoaded )
				{
					this._dataLoaded = true;
				}
			}
			
			Gdk.threads_enter();
			hide_loading();
			Gdk.threads_leave();
			return 0;
		}
		*/
		public void OnButtonRefreshProductsClicked(Button button)
		{
			var dlg = new MessageDialog(null, DialogFlags.MODAL, 
											MessageType.ERROR, 
											ButtonsType.CLOSE, 
											"You are using a demo version, please contact with support to get the full featured version.")
						{skip_taskbar_hint = true};
			dlg.run();
			dlg.dispose();
		}
		protected void OnButtonCreateCustomerClicked()
		{
			var w 		= new DialogCreateCustomer();
			w.StoreId 	= this.storeId;
			w.Dbh		= this.Dbh;
			w.modal = true;
			w.show();
			w.destroy.connect( () => 
			{
				if( w.CustomerData != null )
				{
					this.customerId = (int)w.CustomerData["customer_id"];
					this.entrySearchCustomer.text = "%s %s".printf((string)w.CustomerData["first_name"], 
																	(string)w.CustomerData["last_name"]);
					this.customerCreated = true;
				}
			});
		}
		/**
		 * Add Product to order
		 * 
		 */
		protected bool OnButtonReleaseEvent(Gdk.EventButton args)
		{
			TreePath path;
			TreeViewColumn c;
			TreeIter iter;
			TreeModel model;
			int cell_x, cell_y;
			
			if( !this.treeviewProducts.get_path_at_pos((int)args.x, (int)args.y, out path, out c, out cell_x, out cell_y) )
				return false;
		
			if( !this.treeviewProducts.get_selection().get_selected(out model, out iter) )
				return false;
			
			string action = c.get_data<string>("action");
			if( action == "add" )        
            {
				GLib.Value v_pid;
				
				(this.treeviewProducts.model as ListStore).get_value(iter, ProductColumns.ID, out v_pid);
				var product = new SBProduct(){Dbh = this.Dbh};
				product.GetDbData((int)v_pid);
				
				if( product.Id > 0 )
				{
					product.GetDbMeta();
					this._addProductToOrder(product);									
				}
			}
			
			return true;
		}
		protected bool OnOrderItemsButtonReleaseEvent(Gdk.EventButton args)
		{
			TreePath path;
			TreeViewColumn c;
			TreeIter iter;
			TreeModel model;
			int cell_x, cell_y;
			
			if( !this.treeviewOrderItems.get_path_at_pos((int)args.x, (int)args.y, out path, out c, out cell_x, out cell_y) )
				return false;
		
			if( !this.treeviewOrderItems.get_selection().get_selected(out model, out iter) )
				return false;
			
			string action = c.get_data<string>("action");
			
			
            if( action == "remove" )        
            {
				GLib.Value product_id, qty, price;
			
				(this.treeviewOrderItems.model as ListStore).get_value(iter, OrderColumns.QTY, out qty);
				(this.treeviewOrderItems.model as ListStore).get_value(iter, OrderColumns.PRICE, out price);
				(this.treeviewOrderItems.model as ListStore).get_value(iter, OrderColumns.PRODUCT_ID, out product_id);
				
				if( (int)qty > 1 )
				{
					float the_price = (float)double.parse((string)price);
					(this.treeviewOrderItems.model as ListStore).set_value(iter, 0, ((int)qty - 1));
					(this.treeviewOrderItems.model as ListStore).set_value(iter, 3, 
																"%.2f".printf(((int)qty - 1) * the_price)
					);
				}
				else
				{
					(this.treeviewOrderItems.model as ListStore).remove(iter);
				}
				this.CalculateOrderTotal();
			}
			
			return true;
		}
		protected void _calculateOrderItermTotal(TreeIter iter)
		{
			Value v_qty, v_price, v_tax_rate;
			
			(this.treeviewOrderItems.model as ListStore).get_value(iter, OrderColumns.QTY, out v_qty);
			(this.treeviewOrderItems.model as ListStore).get_value(iter, OrderColumns.PRICE, out v_price);
			(this.treeviewOrderItems.model as ListStore).get_value(iter, OrderColumns.TAX_RATE, out v_tax_rate);
			double tax_rate = double.parse((string)v_tax_rate);
			double sub_total = (int)v_qty * double.parse((string)v_price);
			
			double tax_amount = sub_total * tax_rate;
			double total = sub_total + tax_amount;
			(this.treeviewOrderItems.model as ListStore).set_value(iter, OrderColumns.SUB_TOTAL, "%.2f".printf(sub_total));
			(this.treeviewOrderItems.model as ListStore).set_value(iter, OrderColumns.TAX, "%.2f".printf(tax_amount));
			(this.treeviewOrderItems.model as ListStore).set_value(iter, OrderColumns.TOTAL, "%.2f".printf(total));
		}
		protected void _addProductToOrder(SBProduct product)
		{
			TreeIter iter;
			int product_id = product.Id;
			
			int qty = 1;
						
			if( this._productInTreeView(product_id, out iter) )
			{
				Value current_qty;
				(this.treeviewOrderItems.model as ListStore).get_value(iter, OrderColumns.QTY, out current_qty);
				qty = (int)current_qty + 1;
				//update quantity
				(this.treeviewOrderItems.model as ListStore).set_value(iter, OrderColumns.QTY, qty);
				//calculate item total
				this._calculateOrderItermTotal(iter);
			}
			else
			{
				//this.labelVAT.label = "%.2f".printf(this.store.TaxRate);
				try
				{
					int tax_id = product.Meta["tax_rate_id"] != null ? int.parse(product.Meta["tax_rate_id"]) : 0;
					HashMap<string, Value?>? tax = null;
					if(product.Meta["tax_rate_id"] != null)
						tax = EPosHelper.GetTaxRate(tax_id);
						
					double tax_rate = tax != null ? ((double)tax["rate"] / 100) : 0;
					double sub_total = product.Price * qty;
					double tax_amount = sub_total * tax_rate;
					double total = sub_total + tax_amount;
					stdout.printf("Tax id: %d, Tax rate: %.2f\n", tax_id, tax_rate);
					(this.treeviewOrderItems.model as ListStore).append(out iter);
					(this.treeviewOrderItems.model as ListStore).set(iter,
							OrderColumns.QTY, qty,
							OrderColumns.PRODUCT_NAME, product.Name,
							OrderColumns.PRICE, "%.2lf".printf(product.Price),
							OrderColumns.SUB_TOTAL, "%.2lf".printf(sub_total),
							OrderColumns.TAX, "%.2f".printf(tax_amount),
							OrderColumns.TOTAL, "%.2lf".printf(total),
							OrderColumns.ACTION, new Gdk.Pixbuf.from_file(SBFileHelper.SanitizePath("share/images/remove-icon.png")),
							OrderColumns.PRODUCT_ID, product.Id,
							OrderColumns.EXTERNAL_ID, product.GetInt("extern_id"),
							OrderColumns.TAX_RATE, "%.2f".printf(tax_rate)
					);
					
				}
				catch(Error e)
				{
					stderr.printf("ERROR: %s\n", e.message);
				}
			}		
			this.CalculateOrderTotal();
			
		}
		protected bool _productInTreeView(int product_id, out TreeIter out_iter)
		{
			bool exists = false;
			
			TreeIter iter;
			if( !this.treeviewOrderItems.model.get_iter_first(out iter) )
				return false;
			do
			{
				Value pid;
				this.treeviewOrderItems.model.get_value(iter, OrderColumns.PRODUCT_ID, out pid);
				if( product_id == (int)pid )
				{
					out_iter = iter;
					exists = true;
					break;
				}
			}while( this.treeviewOrderItems.model.iter_next(ref iter) );
			
			return exists;
		}
		protected void OnOrderItemQtyEdited(string path, string new_text)
		{
			TreeIter iter;
			int new_qty = int.parse(new_text.strip());
			this.treeviewOrderItems.model.get_iter(out iter, new TreePath.from_string(path));
			(this.treeviewOrderItems.model as ListStore).set_value(iter, OrderColumns.QTY, new_qty);
			this._calculateOrderItermTotal(iter);
			this.CalculateOrderTotal();
		}
		protected void OnOrderItemPriceEdited(string path, string new_text)
		{
			TreeIter iter;
			double new_price = double.parse(new_text.strip());
			this.treeviewOrderItems.model.get_iter(out iter, new TreePath.from_string(path));
			(this.treeviewOrderItems.model as ListStore).set_value(iter, 
								OrderColumns.PRICE, 
								"%.2f".printf(new_price));
			this._calculateOrderItermTotal(iter);
			this.CalculateOrderTotal();
		}
		protected bool OnSearchCustomerKeyReleaseEvent(Gdk.EventKey event)
		{
			if( /*args.keyval == 65293 || args.keyval == 65288 ||*/ event.keyval == 65361 || event.keyval == 65362 || event.keyval == 65363 || event.keyval == 65364 )
			{
				return true;
			}
			(this.entrySearchCustomer.completion.model as ListStore).clear();
			string keyword = this.entrySearchCustomer.text.strip();
			if( keyword.length <= 0)
			{
				
				return true;
			}
			string query = "SELECT * FROM customers WHERE (first_name || last_name) LIKE '%s' ";
			query += "AND store_id = %d";
			query = query.printf("%"+keyword+"%", this.storeId);
			
			var rows = this.Dbh.GetResults(query);
			TreeIter iter;
			foreach(var row in rows)
			{
				(this.entrySearchCustomer.completion.model as ListStore).append(out iter);
				(this.entrySearchCustomer.completion.model as ListStore).set(iter,
					0, "%s %s, %s, %s".printf(row.Get("first_name"), row.Get("last_name"), row.Get("address_1"), row.Get("zip_code")),
					1, row.GetInt("customer_id")
				);
			}
			return true;
		}
		protected bool OnCustomerSelected(TreeModel model, TreeIter iter)
		{
			Value name, cid;
			model.get_value(iter, 0, out name);
			model.get_value(iter, 1, out cid);
			this.entrySearchCustomer.text = (string)name;
			this.customerId = (int)cid;
			this.customerCreated = false;
			return true;
		}
		protected void OnEntrySearchCustomerIconRelease(EntryIconPosition icon, Gdk.Event event)
		{
			
			if( icon == EntryIconPosition.PRIMARY )
			{
			}
			else
			{
				if( this.customerId > 0 )
				{
					var dlg 	= new DialogCreateCustomer();
					dlg.StoreId = this.storeId;
					dlg.Dbh 	= this.Dbh;
					dlg.ViewCustomer(new SBCustomer.from_id(this.customerId), true);
					dlg.modal 	= true;
					dlg.show();
				}
				else
				{
					var info = new InfoDialog("info")
					{
						Title = SBText.__("Customer details"),
						Message = SBText.__("You need to select a customer.")
					};
					info.run();
					info.destroy();
				}
			}
		}
		protected void OnButtonGuestCustomerClicked()
		{
			this.customerId = -1;
			this.entrySearchCustomer.text = SBText.__("Guest");
		}
		protected void OnButtonClearCustomerClicked()
		{
			this.customerId = 0;
			this.entrySearchCustomer.text = "";
		}
		/**
		 * Register new into store
		 */
		protected void OnButtonRegisterSaleClicked(Button sender)
		{
			TreeIter iter;
			
			if( this.comboboxPaymentMethod.active_id == null || this.comboboxPaymentMethod.active_id == "-1" )
			{
				var err = new InfoDialog("error");
				err.Title 	= SBText.__("Sale error");
				err.Message = SBText.__("You need to select a payment method.");
				err.run();
				err.destroy();
				this.comboboxPaymentMethod.grab_focus();
				return;
			}
			if( this.customerId == 0 )
			{
				var err = new InfoDialog("error");
				err.Title = SBText.__("Error");
				err.Message = SBText.__("You need to select a customer.");
				err.run();
				err.destroy();
				this.entrySearchCustomer.grab_focus();
				return;
			}
			if( !this.treeviewOrderItems.model.get_iter_first(out iter) )
			{
				var err = new InfoDialog("error")
				{
					Title 	= SBText.__("Error"),
					Message = SBText.__("You need to add products to order.")
				};
				
				err.run();
				err.destroy();
				return;
			}
			var user = (SBUser)SBGlobals.GetVar("user");
			this.Dbh.BeginTransaction();
			string notes 	= this.textviewNotes.buffer.text.strip();
			var sale 		= new ESale();
			sale.Dbh		= this.Dbh;
			sale.Code 		= "";
			sale.StoreId 	= this.storeId;
			sale.CashierId 	= user.Id;
			sale.CustomerId = this.customerId;
			
			sale.Notes 		= notes;
			sale.SubTotal	= double.parse(this.labelSubTotal.label);
			sale.TaxRate	= 0;
			sale.TaxAmount	= 0;
			sale.Discount	= 0;
			sale.Total		= double.parse(this.labelTotal.label);
			sale.Status		= "completed";
			
			this.treeviewOrderItems.model.foreach( (_model, _path, _iter) => 
			{
				Value v_pid, v_qty, v_price, v_pname;
				_model.get_value(_iter, OrderColumns.QTY, out v_qty);
				_model.get_value(_iter, OrderColumns.PRODUCT_ID, out v_pid);
				_model.get_value(_iter, OrderColumns.PRICE, out v_price);
				_model.get_value(_iter, OrderColumns.PRODUCT_NAME, out v_pname);
				//##add item to order/sale
				var sale_item = new ESaleItem();
				sale_item.ProductId 	= (int)v_pid;
				sale_item.ProductName 	= (string)v_pname;
				sale_item.Quantity		= (int)v_qty;
				sale_item.Price			= double.parse((string)v_price);
				sale_item.SubTotal		= sale_item.Quantity * sale_item.Price;
				sale_item.TaxRate		= 0;
				sale_item.TaxAmount		= 0;
				sale_item.Discount		= 0;
				sale_item.Total			= (sale_item.SubTotal + sale_item.TaxAmount) - sale_item.Discount;
				sale_item.Status		= "completed";
				sale.SetItem(sale_item);
				
				return false;
				
			});
			var meta = new HashMap<string, Value?>();
			meta.set("payment_method", this.comboboxPaymentMethod.active_id);
			meta.set("customer_created", this.customerCreated ? "yes" : "no");
			
			var before_args = new SBModuleArgs<HashMap<string, Value?>>();
			var bdata = new HashMap<string, Value?>();
			bdata.set("store", this.store);
			bdata.set("sale_obj", sale);
			bdata.set("sale_meta", meta);
			before_args.SetData(bdata);
			SBModules.do_action("before_register_sale", before_args);
			int sale_id = sale.Register();
			//##add sale meta
			foreach(var m in meta.keys)
			{
				SBMeta.AddMeta("sale_meta", m, "sale_id", sale_id, (string)meta[m], this.Dbh);
			}
			var after_args = new SBModuleArgs<HashMap<string, Value?>>();
			var data = new HashMap<string, Value?>();
			data.set("sale_id", sale_id);
			data.set("sale_obj", sale);
			after_args.SetData(data);
			SBModules.do_action("after_register_sale", after_args);
			
			//##store order/sale into local database
			this.Dbh.EndTransaction();
			var msg = new InfoDialog("success")
			{
				Title = SBText.__("Point of Sale"),
				Message = SBText.__("The order has been registered.")
			};
			msg.run();
			msg.destroy();
							
			/*	
			//## get print settings
			double font_size = 12;
			string page_size = (string)(SBGlobals.GetVar("config") as SBConfig).GetValue("page_size");
			string show_preview = (string)(SBGlobals.GetVar("config") as SBConfig).GetValue("print_preview");
			string printer		= (string)(SBGlobals.GetVar("config") as SBConfig).GetValue("printer");
			
			var invoice = new SBInvoice(printer, font_size);
			invoice.Number = wc_order_id;
			invoice.Title = SBText.__("Order Invoice");
			invoice.Number = sale.Id;
			
			//##print the invoice
			PaperSize paper_size;
			
			if( page_size == "ticket")
			{
				double paper_width = 2.25;
				double paper_height = 14;
				paper_size = new PaperSize.custom("custom_ticket_2.25x14in", "Ticket", paper_width, paper_height, 
													Unit.INCH);
				font_size = 5;
			}
			else
			{
				paper_size = new PaperSize(page_size);
			}
			
			invoice.CustomerName = SBText.__("Guest");
			invoice.Date = new DateTime.now_local().format("%Y-%m-%d %H:%M:%S");
			invoice.window = (Window)this.scrolledwindow1.get_toplevel();
			invoice.PageSettings.set_paper_size(paper_size);
			invoice.Prepare();
			this.treeviewOrderItems.model.foreach((_model, _path, _iter) => 
			{
				Value the_value;
				var prod = new ECProduct();
				(_model as ListStore).get_value(_iter, 0, out the_value);
				prod.Quantity = (int)the_value;
				(_model as ListStore).get_value(_iter, 1, out the_value);
				prod.Name = (string)the_value;
				(_model as ListStore).get_value(_iter, 2, out the_value);
				prod.Price = (float)double.parse((string)the_value);
				invoice.Items.append(prod);
				return false;
			});
			if( show_preview == "yes" )
				invoice.Preview();
			else
				invoice.Print();
			*/
			this.resetOrder();
		}
		protected float CalculateRowTotal(TreeIter iter)
		{
			Value v_qty, v_price;
			this.treeviewOrderItems.model.get_value(iter, 0, out v_qty);
			this.treeviewOrderItems.model.get_value(iter, 2, out v_price);
			int qty = int.parse((string)v_qty);
			float price = (float)double.parse((string)v_price);
			(this.treeviewOrderItems.model as ListStore).set_value(iter, 3, "%.2f".printf(price));
			return price * qty;
		}
		/**
		 * Calculate order total
		 */
		protected double CalculateOrderTotal()
		{
			TreeIter iter;
			double sub_total 	= 0;
			double tax			= 0;
			if( !this.treeviewOrderItems.model.get_iter_first(out iter) )
			{
				this.labelSubTotal.label 	= "0.00";
				this.labelVAT.label			= "0.00";
				this.labelTotal.label 		= "0.00";
				return 0;
			}
				
			do
			{
				Value v_sub_total, v_tax;
				this.treeviewOrderItems.model.get_value(iter, OrderColumns.SUB_TOTAL, out v_sub_total);
				this.treeviewOrderItems.model.get_value(iter, OrderColumns.TAX, out v_tax);
				sub_total += double.parse((string)v_sub_total);
				tax			+= double.parse((string)v_tax);
				
			}while( this.treeviewOrderItems.model.iter_next(ref iter) );
			
			double discount 	= double.parse(this.entryDiscount.text.strip());
			double order_total 	= (sub_total + tax) - discount;
			
			this.labelTotal.set_data<string>("total_before_hook", "%.2f".printf(order_total));
			var args = new SBModuleArgs<HashMap>();
			var data = new HashMap<string, double?>();
			data.set("subtotal", sub_total);
			data.set("tax", tax);
			data.set("total", order_total);
			args.SetData(data);
			SBModules.do_action("pos_calculate_totals", args);
			
			if( data.has_key("added_subtotal") )
			{
				sub_total += (double)data["added_subtotal"];
			}
			if( data.has_key("added_tax") )
			{
				tax += (double)data["added_tax"];
			}
			if( data.has_key("added_total") )
			{
				order_total += (double)data["added_total"];
			}
			data = null;
			this.labelSubTotal.label 	= "%.2f".printf(sub_total);
			this.labelVAT.label			= "%.2f".printf(tax);
			this.labelTotal.label 		= "%.2f".printf(order_total);
			
			//this.labelTax.label			= "%s (%.2f%)".printf(SBText.__("Tax:"), this.store.TaxRate);
			//this.labelTax.tooltip_text	= "%s (%.2f%)".printf(this.store.TaxName, this.store.TaxRate);
			return (float)order_total;
		}
		protected void SetCustomers(/*WCCustomer[] customers*/)
		{
			
		}
		protected uint 		_timeout = 0;
		protected string 	_keyword;
		
		protected bool _searchTimeout()
		{
			
					
			return false;
		}
		protected void OnComboBoxCategoriesChanged()
		{
			if( this.comboboxCategories.active_id == null )
				return;
			int category_id = int.parse(this.comboboxCategories.active_id);
			//var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			if( category_id == -1 )
			{
				this.productsToFill = EPosHelper.GetStoreProducts(this.storeId, this.Dbh);
				this._fillProducts(this._currentView);
				
				return;
			}
			
			this.productsToFill = EPosHelper.GetCategoryProducts(category_id, this.Dbh);
			this._fillProducts(this._currentView);
		}
		/*
		protected ArrayList<SBDBRow> GetProducts(int store_id, out int total)
		{
			total = 0;
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT COUNT(*) as total_products FROM products WHERE store_id = %d".printf(this.storeId);
			var row = dbh.GetRow(query);
			total = row.GetInt("total_products");
			query = "SELECT p.*,a.file AS thumbnail "+
					"FROM products p " +
						"LEFT JOIN attachments a ON p.product_id = a.object_id " +
					"WHERE 1=1 " +
					"AND p.store_id = %d "+
					"AND LOWER(a.object_type) = 'product' " +
					"AND (a.type = 'image_thumbnail' OR a.type = 'image') "+
					"GROUP BY p.product_id "+
					"ORDER BY p.product_name ASC LIMIT 100";
			return dbh.GetResults(query.printf(store_id));
		}
		*/
		protected void OnToggleButtonListViewToggled()
		{
			if( this.lock_list_view )
				return;
				
			stdout.printf("list state: %s\n", this.togglebuttonGridView.active ? "active" : "non active");
			this.lock_grid_view = true;
			this.lock_list_view = false;
			
			this.togglebuttonGridView.active = false;
			this.togglebuttonGridView.sensitive = true;
			this.togglebuttonListView.sensitive = false;
						
			this.productsToFill = EPosHelper.GetStoreProducts(this.storeId, this.Dbh);
			this._fillProducts("list");
					
			this.lock_grid_view = false;
			
		}
		protected void OnToggleButtonGridViewToggled()
		{
			if( this.lock_grid_view )
				return;
				
			stdout.printf("grid state: %s\n", this.togglebuttonGridView.active ? "active" : "non active");
			this.lock_list_view = true;
			this.lock_grid_view = false;
			
			this.togglebuttonGridView.sensitive = false;
			this.togglebuttonListView.active = false;
			this.togglebuttonListView.sensitive = true;
					
			this.productsToFill = EPosHelper.GetStoreProducts(this.storeId, this.Dbh);
			this._fillProducts("grid");
			this.lock_list_view = false;
		}
		protected void resetOrder()
		{
			(this.treeviewOrderItems.model as ListStore).clear();
			this.comboboxPaymentMethod.active_id = "-1";
			this.entrySearchCustomer.text = "";
			this.textviewNotes.buffer.text = "";
			this.labelSubTotal.label = "0.00";
			this.labelVAT.label = "0.00";
			this.entryDiscount.text = "";
			this.labelTotal.label = "0.00";
			this.customerId = 0;
		}
	}
}
