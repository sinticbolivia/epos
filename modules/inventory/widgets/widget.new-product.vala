using GLib;
using Gtk;
using Gee;
using SinticBolivia;
using SinticBolivia.Gtk;
using SinticBolivia.Database;

namespace Woocommerce
{
	public class WidgetNewProduct : Box
	{
		protected	Builder		ui;
		
		protected	Window		windowNewProduct;
		protected	Box			boxNewProduct;
		protected 	Notebook	notebook1;
		protected	ComboBox	comboboxCategories;
		protected	TextView	textviewDescription;
		protected	Entry		entryCode;
		protected	Button		buttonGenerateCode;
		protected	Entry		entryName;
		protected	Entry		entryBarcode;
		protected	ComboBox	comboboxItemType;
		protected	ComboBox	comboboxUnitofMeasure;
		protected	ComboBox	comboboxStatus;
		protected	Entry		entryCost;
		protected	Entry		entryPrice;
		protected	Entry		entryPrice2;
		protected	ComboBox	comboboxStoreBranch;
		protected	Entry		entryQuantity;
		protected	Entry		entryMinQuantity;
		protected	CheckButton	checkbuttonUsesStock;
		protected	Viewport	viewport1;
		protected	Fixed				fixedImages;
		protected	ScrolledWindow		scrolledwindowSn;
		protected	Entry				entrySn;
		protected	TreeView			treeviewSn;
		protected	TreeView			treeviewSuppliers;
		protected	Entry				entrySearchSupplier;
		protected	Button				buttonAddSn;
		protected	Button				buttonRemoveSn;
		protected	Button				buttonAddImage;
		protected	Button				buttonCancel;
		protected	Button				buttonSave;
		
		protected	SBProduct	product = null;
		protected	int			fixedWidth = 0;
		protected	int			fixedX = 0;
		protected	int 		fixedY = 0;
		protected	int			fixedRow = 0;
		protected	int			fixedCol = 0;
		
		public WidgetNewProduct()
		{
			GLib.Object();
			//##get new product glade file
			this.ui = (SBModules.GetModule("Inventory") as SBGtkModule).GetGladeUi("new-product.glade");
					
			this.windowNewProduct		= (Window)this.ui.get_object("windowNewProduct");
			this.boxNewProduct 			= (Box)this.ui.get_object("boxNewProduct");
			this.entryCode				= (Entry)this.ui.get_object("entryCode");
			this.buttonGenerateCode		= (Button)this.ui.get_object("buttonGenerateCode");
			this.entryName				= (Entry)this.ui.get_object("entryName");
			this.notebook1				= (Notebook)this.ui.get_object("notebook1");
			this.comboboxCategories		= (ComboBox)this.ui.get_object("comboboxCategories");
			this.textviewDescription	= (TextView)this.ui.get_object("textviewDescription");
			this.entryBarcode			= (Entry)this.ui.get_object("entryBarcode");
			this.comboboxItemType		= (ComboBox)this.ui.get_object("comboboxItemType");
			this.comboboxUnitofMeasure	= (ComboBox)this.ui.get_object("comboboxUnitofMeasure");
			this.comboboxStatus			= (ComboBox)this.ui.get_object("comboboxStatus");
			this.entryCost				= (Entry)this.ui.get_object("entryCost");
			this.entryPrice				= (Entry)this.ui.get_object("entryPrice");
			this.entryPrice2			= (Entry)this.ui.get_object("entryPrice2");
			this.comboboxStoreBranch	= (ComboBox)this.ui.get_object("comboboxStoreBranch");
			this.entryQuantity			= (Entry)this.ui.get_object("entryQuantity");
			this.entryMinQuantity		= (Entry)this.ui.get_object("entryMinQuantity");
			this.checkbuttonUsesStock	= (CheckButton)this.ui.get_object("checkbuttonUsesStock");
			this.fixedImages			= (Fixed)this.ui.get_object("fixedImages");
			this.viewport1				= (Viewport)this.ui.get_object("viewport1");
			this.scrolledwindowSn		= (ScrolledWindow)this.ui.get_object("scrolledwindowSn");
			this.treeviewSn				= (TreeView)this.ui.get_object("treeviewSn");
			this.entrySn				= (Entry)this.ui.get_object("entrySn");
			this.treeviewSuppliers		= (TreeView)this.ui.get_object("treeviewSuppliers");
			this.entrySearchSupplier	= (Entry)this.ui.get_object("entrySearchSupplier");
			this.buttonAddSn			= (Button)this.ui.get_object("buttonAddSn");
			this.buttonRemoveSn			= (Button)this.ui.get_object("buttonRemoveSn");
			this.buttonAddImage			= (Button)this.ui.get_object("buttonAddImage");
			this.buttonCancel			= (Button)this.ui.get_object("buttonCancel");
			this.buttonSave				= (Button)this.ui.get_object("buttonSave");
			
			this.boxNewProduct.reparent(this);
			this.Build();
			this.SetEvents();
			this.fixedWidth = this.viewport1.get_allocated_width();
		}
		public WidgetNewProduct.with_product(owned SBProduct prod)
		{
			this();
			this.product = prod;
			
			this.entryCode.text = this.product.Code;
			this.entryName.text = this.product.Name;
			this.textviewDescription.buffer.text = this.product.Description;
			this.entryBarcode.text = this.product.Barcode;
			//this.entrySerialNumber.text = this.product.SerialNumber;
			this.entryCost.text = "%.2lf".printf(this.product.Cost);
			this.entryPrice.text = "%.2lf".printf(this.product.Price);
			this.entryPrice2.text = "%.2lf".printf(this.product.Price2);
			this.entryQuantity.text = this.product.Quantity.to_string();
			this.entryMinQuantity.text = this.product.MinStock.to_string();
			
			this.comboboxStoreBranch.active_id = this.product.StoreId.to_string();
			if( this.product.CategoriesIds.size > 0 )
			{
				stdout.printf("cat_id: %s\n", this.product.CategoriesIds.get(0).to_string());
				this.comboboxCategories.active_id = this.product.CategoriesIds.get(0).to_string();
			}
			//set images
			foreach(var attach in this.product.Attachments)
			{
				this.addImage(SBFileHelper.SanitizePath("images/%s".printf(attach.Get("file"))), 
								attach.GetInt("attachment_id"));
			}
		}
		~WidgetNewProduct()
		{
			stdout.printf("widget.new-product.vala destroyed\n");
			this.fixedImages.get_children().foreach( (child) => 
			{
				(((Button)child).image as Image).pixbuf.dispose();
				(((Button)child).image as Image).dispose();
				child.dispose();
			});
			this.ui.dispose();
		}
		protected void Build()
		{
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			
			TreeIter iter;
			this.comboboxItemType.model = new ListStore(2, typeof(string), typeof(string));
			var cell0 = new CellRendererText();
			this.comboboxItemType.pack_start(cell0, false);
			this.comboboxItemType.set_attributes(cell0, "text", 0); 
			this.comboboxItemType.id_column = 1;
			
			(this.comboboxItemType.model as ListStore).append(out iter);
			(this.comboboxItemType.model as ListStore).set(iter, 
				0, SBText.__("-- item type --"), 
				1, "-1"
			);
			dbh.Select("*").From("item_types");
			foreach(var row in dbh.GetResults(null))
			{
				(this.comboboxItemType.model as ListStore).append(out iter);
				(this.comboboxItemType.model as ListStore).set(iter, 
					0, "%s - %s".printf(row.Get("code"), row.Get("name")), 
					1, row.Get("item_type_id")
				);
			}
			this.comboboxItemType.active_id = "-1";
			//##build U.O.M.
			this.comboboxUnitofMeasure.model = new ListStore(2, typeof(string), typeof(string));
			cell0 = new CellRendererText();
			this.comboboxUnitofMeasure.pack_start(cell0, false);
			this.comboboxUnitofMeasure.set_attributes(cell0, "text", 0);
			this.comboboxUnitofMeasure.id_column = 1;
			(this.comboboxUnitofMeasure.model as ListStore).append(out iter);
			(this.comboboxUnitofMeasure.model as ListStore).set(iter, 
				0, SBText.__("-- unit of measure --"), 
				1, "-1"
			);
			dbh.Select("*").From("unit_measures");
			foreach(var row in dbh.GetResults(null))
			{
				(this.comboboxUnitofMeasure.model as ListStore).append(out iter);
				(this.comboboxUnitofMeasure.model as ListStore).set(iter, 
					0, "%s - %s".printf(row.Get("code"), row.Get("name")), 
					1, row.Get("measure_id")
				);
			}
			this.comboboxUnitofMeasure.active_id = "-1";
			//##build statuses
			this.comboboxStatus.model = new ListStore(2, typeof(string), typeof(string));
			cell0 = new CellRendererText();
			this.comboboxStatus.pack_start(cell0, false);
			this.comboboxStatus.set_attributes(cell0, "text", 0);
			this.comboboxStatus.id_column = 1;
			
			string[,] statuses = 
			{
				{"-1", SBText.__("-- status --")},
				{"active", SBText.__("Active")},
				{"discontinued", SBText.__("Discontinued")}
			};
			
			for(int i = 0; i < statuses.length[0]; i++)
			{
				(this.comboboxStatus.model as ListStore).append(out iter);
				(this.comboboxStatus.model as ListStore).set(iter,
					0, statuses[i,1],
					1, statuses[i,0]
				);
			}
			this.comboboxStatus.active_id = "-1";
			//##build categories
			this.comboboxCategories.model = new ListStore(2, typeof(string), typeof(string));
			cell0 = new CellRendererText();
			this.comboboxCategories.pack_start(cell0, false);
			this.comboboxCategories.set_attributes(cell0, "text", 0);
			this.comboboxCategories.id_column = 1;
			this.comboboxCategories.sensitive = false;
			
			this.comboboxStoreBranch.model = new ListStore(2, typeof(string), typeof(string));
			var cell = new CellRendererText();
			this.comboboxStoreBranch.pack_start(cell, false);
			this.comboboxStoreBranch.set_attributes(cell, "text", 0);
			this.comboboxStoreBranch.set_id_column(1);
			(this.comboboxStoreBranch.model as ListStore).append(out iter);
			(this.comboboxStoreBranch.model as ListStore).set(iter, 0, SBText.__("-- store/branch --"), 1, "-1");
			var stores = (ArrayList<SBStore>)InventoryHelper.GetStores();
			foreach(var store in stores)
			{
				(this.comboboxStoreBranch.model as ListStore).append(out iter);
				(this.comboboxStoreBranch.model as ListStore).set(iter, 0, store.Name, 1, store.Id.to_string());
			}
			this.comboboxStoreBranch.active_id = "-1";
			//##build serial numbers treeview
			this.treeviewSn.model = new ListStore(2, typeof(int), typeof(string));
			string[,] cols = 
			{
				{"#", "text", "100", "center", "", ""},
				{SBText.__("Serial Number"), "text", "250", "left", "", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols, ref this.treeviewSn);
			//##build suppliers treeview
			this.treeviewSuppliers.model = new ListStore(5, 
				typeof(int), 
				typeof(string), 
				typeof(string),
				typeof(string),
				typeof(int)
			);
			string[,] cols1 = 
			{
				{"#", "text", "100", "center", "", ""},
				{SBText.__("Supplier"), "text", "200", "left", "", ""},
				{SBText.__("Email"), "text", "200", "left", "", ""},
				{SBText.__("Phone"), "text", "200", "left", "", ""}
			};
			GtkHelper.BuildTreeViewColumns(cols1, ref this.treeviewSuppliers);
			this.entrySearchSupplier.completion = new EntryCompletion();
			this.entrySearchSupplier.completion.model = new ListStore(2, typeof(string), typeof(int));
			
		}
		protected void SetEvents()
		{
			this.comboboxStoreBranch.changed.connect( () => 
			{
				if( this.comboboxStoreBranch.active_id != null && this.comboboxStoreBranch.active_id != "-1" )
				{
					int store_id = int.parse(this.comboboxStoreBranch.active_id);
					this.FillCategories(store_id);
					this.comboboxCategories.grab_focus();
				}
			});
			this.buttonAddImage.clicked.connect(this.OnButtonAddImageClicked);
			this.buttonAddSn.clicked.connect(this.OnButtonAddSnClicked);
			this.buttonRemoveSn.clicked.connect(this.OnButtonRemoveSnClicked);
			this.buttonCancel.clicked.connect(this.OnButtonCancelClicked);
			this.buttonSave.clicked.connect(this.OnButtonSaveClicked);
			this.entrySearchSupplier.key_release_event.connect(this.OnEntrySearchSupplierKeyReleaseEvent);
		}
		protected void FillCategories(int store_id)
		{
			//##fill categories
			TreeIter iter;
			(this.comboboxCategories.model as ListStore).clear();
			(this.comboboxCategories.model as ListStore).append(out iter);
			(this.comboboxCategories.model as ListStore).set(iter, 0, SBText.__("-- category --"), 1, "-1");
			this.comboboxCategories.active_id = "-1";
			
			var cats = (ArrayList<SBLCategory>)InventoryHelper.GetCategories(store_id);
			foreach(var cat in cats)
			{
				(this.comboboxCategories.model as ListStore).append(out iter);
				(this.comboboxCategories.model as ListStore).set(iter, 0, cat.Name, 1, cat.Id.to_string());
			}
			this.comboboxCategories.sensitive = true;
		}
		protected void OnButtonAddImageClicked()
		{
			var fc = new FileChooserDialog(SBText.__("Select product image"), null, 
											FileChooserAction.OPEN,
											SBText.__("_Cancel"),
											ResponseType.CANCEL,
											SBText.__("_Open"),
											ResponseType.ACCEPT
			);
			fc.select_multiple = true;
			var filter = new FileFilter();
			filter.add_mime_type("image/jpeg");
			filter.add_mime_type("image/png");
			filter.add_mime_type("image/gif");
			//filter.add_mime_type("image/bmp");
			fc.set_filter(filter);
			var img_preview = new Image();
			fc.set_preview_widget(img_preview);
			fc.update_preview.connect( () => 
			{
				string uri = fc.get_preview_uri();
				// We only display local files:
				if( uri != null && uri.has_prefix ("file://") == true) 
				{
					try 
					{
						Gdk.Pixbuf pixbuf = new Gdk.Pixbuf.from_file_at_scale (uri.substring (7), 150, 	150, true);
						img_preview.set_from_pixbuf (pixbuf);
						img_preview.show ();
					} 
					catch (Error e) 
					{
						img_preview.hide ();
					}
				} 
				else 
				{
					img_preview.hide ();
				}
			});
			/*
			int fixed_width = this.viewport1.get_allocated_width();
			int margin = 10;
			int button_width = 150;
			int button_height = 150;
			int total_cols = (int)Math.ceil(fixed_width / 150);
			stdout.printf("available space: %d\ntotal columns: %d\n", fixed_width, total_cols);
			*/
			
			// Process response:
			if( fc.run () == Gtk.ResponseType.ACCEPT) 
			{
				/*
				if( this.fixedX == 0 && this.fixedY == 0 )
				{
					this.fixedX += 5;
					this.fixedY += 5;
				}
				*/
				SList<string> uris = fc.get_uris ();
				//stdout.printf ("Selection:\n");
				foreach (string uri in uris)
				{
					this.addImage(uri);
				}
			}

			// Close the FileChooserDialog:
			fc.close ();
			//
			//stdout.printf("base_line_row: %d\n", this.gridImages.get_baseline_row());
		}
		protected void addImage(string filename, int id = 0)
		{
			stdout.printf("fixed width:%d\n", this.fixedWidth);
			int margin = 10;
			int button_width = 150;
			int button_height = 150;
			int total_cols = (int)Math.ceil(this.fixedWidth / 150);
			
			if( this.fixedX == 0 && this.fixedY == 0 )
			{
				this.fixedX += 5;
				this.fixedY += 5;
			}
			var image = new Image();
			try
			{
				//image.pixbuf = new Gdk.Pixbuf.from_file_at_scale ((filename.index_of("file://") != -1) ? filename.substring (7) : filename, 150, 	150, false);
				image.pixbuf = new Gdk.Pixbuf.from_file( (filename.index_of("file://") != -1) ? filename.substring (7) : filename);
				if(image.pixbuf.width > 150)
				{
					image.pixbuf = image.pixbuf.scale_simple(150, 150, Gdk.InterpType.BILINEAR);
				}
				image.pixbuf.set_data<string>("uri", filename);
				image.pixbuf.set_data<int>("id", id);
			}
			catch(GLib.Error e)
			{
				if( e.code == 4 )
				{
					image.pixbuf = (SBModules.GetModule("Inventory") as SBGtkModule).GetPixbuf("placeholder-80x80.png");
					stderr.printf("ERROR: %s, using placeholder\n", e.message);
				}
				else
				{
					stderr.printf("ERROR: %s, CODE: %d\n", e.message, e.code);
				}
			}
			image.show ();
			var overlay = new Overlay();
			var box = new Box(Orientation.VERTICAL, 0);
			var btn_remove_img = new Button.with_label(SBText.__("X")){valign = Align.CENTER,halign = Align.CENTER};
			overlay.show();
			box.show();
			btn_remove_img.hide();
			
			var button = new Button(){relief = ReliefStyle.NONE, image = image};
			button.set_events(Gdk.EventMask.ALL_EVENTS_MASK);
			button.show();
			button.set_size_request(button_width, button_height);
			//button.enter_notify_event.connect( () => 
			button.clicked.connect( () => 
			{
				btn_remove_img.show();
			});
			//button.leave_notify_event.connect( () => 
			button.focus_out_event.connect( () => 
			{
				btn_remove_img.hide();
				return true;
			});
			box.add(button);
			overlay.add(box);
			overlay.add_overlay(btn_remove_img);
			this.fixedImages.put(overlay, this.fixedX, this.fixedY);
			this.fixedX += button_width + margin;
			this.fixedCol++;
			if( this.fixedCol == total_cols)
			{
				this.fixedCol 	= 0;
				this.fixedX 	= 5;
				this.fixedY 	+= button_height + margin;
			}
		}
		protected void OnButtonCancelClicked()
		{
			var notebook = (SBNotebook)SBGlobals.GetVar("notebook");
			if( this.product == null )
				notebook.RemovePage("new-product");
			else
				notebook.RemovePage("edit-product");
		}
		protected void OnButtonSaveClicked()
		{
			string product_name = this.entryName.text.strip();
			string description	= this.textviewDescription.buffer.text.strip();
			string barcode		= this.entryBarcode.text.strip();
			//string sn			= this.entrySerialNumber.text.strip();
			double cost, price, price2;
			
			int store_id 		= (this.comboboxStoreBranch.active_id == null || this.comboboxStoreBranch.active_id == "-1") ? -1 :  int.parse(this.comboboxStoreBranch.active_id);
			int64 quantity = 0, min_quantity = 0;
			bool uses_stock = this.checkbuttonUsesStock.active;
			long pid = 0;
			string message = "";
			
			if( product_name.length <= 0 )
			{
				this.entryName.grab_focus();
				return;
			}
			if( !double.try_parse(this.entryCost.text.strip(), out cost) )
			{
				this.entryCost.grab_focus();
				return;
			}
			if( !double.try_parse(this.entryPrice.text.strip(), out price) )
			{
				this.entryPrice.grab_focus();
				return;
			}
			
			if( !double.try_parse(this.entryPrice2.text.strip(), out price2) )
			{
				price2 = 0.0;
			}
			//stdout.printf("store_id: %d, %s\n", store_id, this.comboboxStoreBranch.active_id);
			if( store_id == -1 )
			{
				this.comboboxStoreBranch.grab_focus();
				this.notebook1.set_current_page(2);
				return;
			}
			if( !int64.try_parse(this.entryQuantity.text.strip(), out quantity) )
			{
				quantity = 0;
			}
			if( !int64.try_parse(this.entryMinQuantity.text.strip(), out min_quantity) )
			{
				min_quantity = 0;
			}
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			var date = new DateTime.now_local();
			string cdate = date.format("%Y-%m-%d %H:%M:%S");
			var data = new HashMap<string, Value?>();
			data.set("product_name", product_name);
			data.set("product_description", description);
			data.set("product_barcode", barcode);
			//data.set("product_serial_number", sn);
			data.set("product_cost", cost);
			data.set("product_price", price);
			data.set("product_price_2", price2);
			data.set("store_id", store_id);
			data.set("product_quantity", (int)quantity);
			data.set("min_stock", (int)min_quantity);
			data.set("last_modification_date", cdate);
			dbh.BeginTransaction();
			
			var meta = new HashMap<string, Value?>();
			meta.set("uses_stock", this.checkbuttonUsesStock.active ? "yes" : "no");
			//##insert a new product
			if( this.product == null )
			{
				data.set("creation_date", cdate);
				pid = dbh.Insert("products", data);
				message = SBText.__("The product has been created.");				
			}
			//##update product data
			else
			{
				pid = this.product.Id;
				var w = new HashMap<string, Value?>();
				w.set("product_id", pid);
				dbh.Update("products", data, w);
				message = SBText.__("The product has been updated.");
			}
			//set product meta
			foreach(string key in meta.keys)
			{
				SBProduct.UpdateMeta((int)pid, key, meta[key]);
			}
			//##check images
			this.fixedImages.get_children().foreach( (overlay) => 
			{
				var box = (Box)(overlay as Overlay).get_child();
				var btn = (Button)box.get_children().first().data;
				date = new DateTime.now_local();
				cdate = date.format("%Y-%m-%d %H:%M:%S");
				string uri = (btn.image as Image).pixbuf.get_data<string>("uri");
				int attachment_id = (btn.image as Image).pixbuf.get_data<int>("id");
				if( attachment_id == 0 )
				{
					//stdout.printf("uri => %s\n", uri);
					string filename = Path.get_basename(uri);
					string[] parts = SBFileHelper.GetParts(filename);
					string image_file = SBFileHelper.GetUniqueFilename("images", filename);
					stdout.printf("%s\n", image_file);
					//insert product attachment
					var attach = new HashMap<string, Value?>();
					attach.set("object_type", "product");
					attach.set("object_id", pid);
					attach.set("title", image_file);
					attach.set("description", "");
					attach.set("type", "image");
					attach.set("mime", parts[0]);
					attach.set("file", image_file);
					attach.set("last_modification_date", cdate);
					attach.set("creation_date", cdate);
					dbh.Insert("attachments", attach);
					try
					{
						(btn.image as Image).pixbuf.save("images/%s".printf(image_file), (parts[1] == "jpg") ? "jpeg" : parts[1]);
					}				
					catch(GLib.Error e)
					{
						stderr.printf("ERROR SAVING IMAGE, %s\n", e.message);
					}
				}
			});
			//delete categories
			string query = @"DELETE FROM product2category WHERE product_id = $pid";
			dbh.Execute(query);
			if( this.comboboxCategories.active_id != null && this.comboboxCategories.active_id != "-1" )
			{
				int cat_id = int.parse(this.comboboxCategories.active_id);
				var cats = new HashMap<string, Value?>();
				cats.set("product_id", pid);
				cats.set("category_id", cat_id);
				//cat.set("creation_date", );
				dbh.Insert("product2category", cats);
			}
			//##delete all serial numbers
			query = "DELETE FROM product_sn WHERE product_id = %ld".printf(pid);
			this.treeviewSn.model.foreach( (_model, _path, _iter) => 
			{
				Value sn;
				_model.get_value(_iter, 1, out sn);
				
				var dsn = new HashMap<string, Value?>();
				dsn.set("product_id", pid);
				dsn.set("sn", sn);
				dsn.set("last_modification_date", cdate);
				dsn.set("creation_date", cdate);
				dbh.Insert("product_sn", dsn);
				return false;
			});
			dbh.EndTransaction();
			var dlg = new InfoDialog()
			{
				Title	= SBText.__("Product message"),
				Message = message
			};
			dlg.run();
			dlg.destroy();
		}
		protected void OnButtonAddSnClicked()
		{
			int i = 0;
			this.treeviewSn.model.foreach((model, path, iter) => 
			{
				i++;
				return false;
			});
			TreeIter iter;
			(this.treeviewSn.model as ListStore).append(out iter);
			string sn = this.entrySn.text.strip();
			(this.treeviewSn.model as ListStore).set(iter, 0, i + 1, 1, sn);
		}
		protected void OnButtonRemoveSnClicked()
		{
			TreeModel model;
			TreeIter iter;
			
			if( !this.treeviewSn.get_selection().get_selected(out model, out iter) )
				return;
			
			(this.treeviewSn.model as ListStore).remove(iter);
		}
		protected bool OnEntrySearchSupplierKeyReleaseEvent(Gdk.EventKey event)
		{
			(this.entrySearchSupplier.completion.model as ListStore).clear();
			string keyword = this.entrySearchSupplier.text.strip();
			if( keyword.length <= 0 )
			{
				return false;
			}
			var dbh = (SBDatabase)SBGlobals.GetVar("dbh");
			string query = "SELECT * FROM suppliers WHERE supplier_name LIKE = '%s'".printf(keyword);
			foreach(var row in dbh.GetResults(query))
			{
				
			}
			
			return true;
		}
	}
}
