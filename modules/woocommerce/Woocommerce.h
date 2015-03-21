/* Woocommerce.h generated by valac 0.24.0, the Vala compiler, do not modify */


#ifndef __WOOCOMMERCE_H__
#define __WOOCOMMERCE_H__

#include <glib.h>
#include <GtkSinticBolivia.h>
#include <SinticBolivia.h>
#include <gtk/gtk.h>
#include <gee.h>
#include <stdlib.h>
#include <string.h>
#include <gmodule.h>
#include <glib-object.h>
#include <gio/gio.h>
#include <libsoup/soup.h>
#include <json-glib/json-glib.h>
#include <Pos.h>

G_BEGIN_DECLS


#define EPOS_WOOCOMMERCE_TYPE_SB_MODULEWOOCOMMERCE (epos_woocommerce_sb_modulewoocommerce_get_type ())
#define EPOS_WOOCOMMERCE_SB_MODULEWOOCOMMERCE(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), EPOS_WOOCOMMERCE_TYPE_SB_MODULEWOOCOMMERCE, EPosWoocommerceSB_ModuleWoocommerce))
#define EPOS_WOOCOMMERCE_SB_MODULEWOOCOMMERCE_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), EPOS_WOOCOMMERCE_TYPE_SB_MODULEWOOCOMMERCE, EPosWoocommerceSB_ModuleWoocommerceClass))
#define EPOS_WOOCOMMERCE_IS_SB_MODULEWOOCOMMERCE(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), EPOS_WOOCOMMERCE_TYPE_SB_MODULEWOOCOMMERCE))
#define EPOS_WOOCOMMERCE_IS_SB_MODULEWOOCOMMERCE_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), EPOS_WOOCOMMERCE_TYPE_SB_MODULEWOOCOMMERCE))
#define EPOS_WOOCOMMERCE_SB_MODULEWOOCOMMERCE_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), EPOS_WOOCOMMERCE_TYPE_SB_MODULEWOOCOMMERCE, EPosWoocommerceSB_ModuleWoocommerceClass))

typedef struct _EPosWoocommerceSB_ModuleWoocommerce EPosWoocommerceSB_ModuleWoocommerce;
typedef struct _EPosWoocommerceSB_ModuleWoocommerceClass EPosWoocommerceSB_ModuleWoocommerceClass;
typedef struct _EPosWoocommerceSB_ModuleWoocommercePrivate EPosWoocommerceSB_ModuleWoocommercePrivate;

#define EPOS_WOOCOMMERCE_TYPE_SBWC_SYNC (epos_woocommerce_sbwc_sync_get_type ())
#define EPOS_WOOCOMMERCE_SBWC_SYNC(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), EPOS_WOOCOMMERCE_TYPE_SBWC_SYNC, EPosWoocommerceSBWCSync))
#define EPOS_WOOCOMMERCE_SBWC_SYNC_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), EPOS_WOOCOMMERCE_TYPE_SBWC_SYNC, EPosWoocommerceSBWCSyncClass))
#define EPOS_WOOCOMMERCE_IS_SBWC_SYNC(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), EPOS_WOOCOMMERCE_TYPE_SBWC_SYNC))
#define EPOS_WOOCOMMERCE_IS_SBWC_SYNC_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), EPOS_WOOCOMMERCE_TYPE_SBWC_SYNC))
#define EPOS_WOOCOMMERCE_SBWC_SYNC_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), EPOS_WOOCOMMERCE_TYPE_SBWC_SYNC, EPosWoocommerceSBWCSyncClass))

typedef struct _EPosWoocommerceSBWCSync EPosWoocommerceSBWCSync;
typedef struct _EPosWoocommerceSBWCSyncClass EPosWoocommerceSBWCSyncClass;
typedef struct _EPosWoocommerceSBWCSyncPrivate EPosWoocommerceSBWCSyncPrivate;

#define EPOS_WOOCOMMERCE_TYPE_WC_API_CLIENT (epos_woocommerce_wc_api_client_get_type ())
#define EPOS_WOOCOMMERCE_WC_API_CLIENT(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), EPOS_WOOCOMMERCE_TYPE_WC_API_CLIENT, EPosWoocommerceWC_Api_Client))
#define EPOS_WOOCOMMERCE_WC_API_CLIENT_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), EPOS_WOOCOMMERCE_TYPE_WC_API_CLIENT, EPosWoocommerceWC_Api_ClientClass))
#define EPOS_WOOCOMMERCE_IS_WC_API_CLIENT(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), EPOS_WOOCOMMERCE_TYPE_WC_API_CLIENT))
#define EPOS_WOOCOMMERCE_IS_WC_API_CLIENT_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), EPOS_WOOCOMMERCE_TYPE_WC_API_CLIENT))
#define EPOS_WOOCOMMERCE_WC_API_CLIENT_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), EPOS_WOOCOMMERCE_TYPE_WC_API_CLIENT, EPosWoocommerceWC_Api_ClientClass))

typedef struct _EPosWoocommerceWC_Api_Client EPosWoocommerceWC_Api_Client;
typedef struct _EPosWoocommerceWC_Api_ClientClass EPosWoocommerceWC_Api_ClientClass;
typedef struct _EPosWoocommerceWC_Api_ClientPrivate EPosWoocommerceWC_Api_ClientPrivate;

#define EPOS_WOOCOMMERCE_TYPE_WC_HELPER (epos_woocommerce_wc_helper_get_type ())
#define EPOS_WOOCOMMERCE_WC_HELPER(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), EPOS_WOOCOMMERCE_TYPE_WC_HELPER, EPosWoocommerceWCHelper))
#define EPOS_WOOCOMMERCE_WC_HELPER_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), EPOS_WOOCOMMERCE_TYPE_WC_HELPER, EPosWoocommerceWCHelperClass))
#define EPOS_WOOCOMMERCE_IS_WC_HELPER(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), EPOS_WOOCOMMERCE_TYPE_WC_HELPER))
#define EPOS_WOOCOMMERCE_IS_WC_HELPER_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), EPOS_WOOCOMMERCE_TYPE_WC_HELPER))
#define EPOS_WOOCOMMERCE_WC_HELPER_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), EPOS_WOOCOMMERCE_TYPE_WC_HELPER, EPosWoocommerceWCHelperClass))

typedef struct _EPosWoocommerceWCHelper EPosWoocommerceWCHelper;
typedef struct _EPosWoocommerceWCHelperClass EPosWoocommerceWCHelperClass;
typedef struct _EPosWoocommerceWCHelperPrivate EPosWoocommerceWCHelperPrivate;

#define EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_CATEGORIES (epos_woocommerce_widget_woocommerce_categories_get_type ())
#define EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CATEGORIES(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_CATEGORIES, EPosWoocommerceWidgetWoocommerceCategories))
#define EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CATEGORIES_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_CATEGORIES, EPosWoocommerceWidgetWoocommerceCategoriesClass))
#define EPOS_WOOCOMMERCE_IS_WIDGET_WOOCOMMERCE_CATEGORIES(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_CATEGORIES))
#define EPOS_WOOCOMMERCE_IS_WIDGET_WOOCOMMERCE_CATEGORIES_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_CATEGORIES))
#define EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CATEGORIES_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_CATEGORIES, EPosWoocommerceWidgetWoocommerceCategoriesClass))

typedef struct _EPosWoocommerceWidgetWoocommerceCategories EPosWoocommerceWidgetWoocommerceCategories;
typedef struct _EPosWoocommerceWidgetWoocommerceCategoriesClass EPosWoocommerceWidgetWoocommerceCategoriesClass;
typedef struct _EPosWoocommerceWidgetWoocommerceCategoriesPrivate EPosWoocommerceWidgetWoocommerceCategoriesPrivate;

#define EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CATEGORIES_TYPE_COLUMNS (epos_woocommerce_widget_woocommerce_categories_columns_get_type ())

#define EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_CUSTOMERS (epos_woocommerce_widget_woocommerce_customers_get_type ())
#define EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CUSTOMERS(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_CUSTOMERS, EPosWoocommerceWidgetWoocommerceCustomers))
#define EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CUSTOMERS_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_CUSTOMERS, EPosWoocommerceWidgetWoocommerceCustomersClass))
#define EPOS_WOOCOMMERCE_IS_WIDGET_WOOCOMMERCE_CUSTOMERS(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_CUSTOMERS))
#define EPOS_WOOCOMMERCE_IS_WIDGET_WOOCOMMERCE_CUSTOMERS_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_CUSTOMERS))
#define EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CUSTOMERS_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_CUSTOMERS, EPosWoocommerceWidgetWoocommerceCustomersClass))

typedef struct _EPosWoocommerceWidgetWoocommerceCustomers EPosWoocommerceWidgetWoocommerceCustomers;
typedef struct _EPosWoocommerceWidgetWoocommerceCustomersClass EPosWoocommerceWidgetWoocommerceCustomersClass;
typedef struct _EPosWoocommerceWidgetWoocommerceCustomersPrivate EPosWoocommerceWidgetWoocommerceCustomersPrivate;

#define EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CUSTOMERS_TYPE_COLUMNS (epos_woocommerce_widget_woocommerce_customers_columns_get_type ())

#define EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_PRODUCTS (epos_woocommerce_widget_woocommerce_products_get_type ())
#define EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_PRODUCTS(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_PRODUCTS, EPosWoocommerceWidgetWoocommerceProducts))
#define EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_PRODUCTS_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_PRODUCTS, EPosWoocommerceWidgetWoocommerceProductsClass))
#define EPOS_WOOCOMMERCE_IS_WIDGET_WOOCOMMERCE_PRODUCTS(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_PRODUCTS))
#define EPOS_WOOCOMMERCE_IS_WIDGET_WOOCOMMERCE_PRODUCTS_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_PRODUCTS))
#define EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_PRODUCTS_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_PRODUCTS, EPosWoocommerceWidgetWoocommerceProductsClass))

typedef struct _EPosWoocommerceWidgetWoocommerceProducts EPosWoocommerceWidgetWoocommerceProducts;
typedef struct _EPosWoocommerceWidgetWoocommerceProductsClass EPosWoocommerceWidgetWoocommerceProductsClass;
typedef struct _EPosWoocommerceWidgetWoocommerceProductsPrivate EPosWoocommerceWidgetWoocommerceProductsPrivate;

#define EPOS_WOOCOMMERCE_TYPE_WINDOW_SYNC_PRODUCTS_PROGRESS (epos_woocommerce_window_sync_products_progress_get_type ())
#define EPOS_WOOCOMMERCE_WINDOW_SYNC_PRODUCTS_PROGRESS(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), EPOS_WOOCOMMERCE_TYPE_WINDOW_SYNC_PRODUCTS_PROGRESS, EPosWoocommerceWindowSyncProductsProgress))
#define EPOS_WOOCOMMERCE_WINDOW_SYNC_PRODUCTS_PROGRESS_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), EPOS_WOOCOMMERCE_TYPE_WINDOW_SYNC_PRODUCTS_PROGRESS, EPosWoocommerceWindowSyncProductsProgressClass))
#define EPOS_WOOCOMMERCE_IS_WINDOW_SYNC_PRODUCTS_PROGRESS(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), EPOS_WOOCOMMERCE_TYPE_WINDOW_SYNC_PRODUCTS_PROGRESS))
#define EPOS_WOOCOMMERCE_IS_WINDOW_SYNC_PRODUCTS_PROGRESS_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), EPOS_WOOCOMMERCE_TYPE_WINDOW_SYNC_PRODUCTS_PROGRESS))
#define EPOS_WOOCOMMERCE_WINDOW_SYNC_PRODUCTS_PROGRESS_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), EPOS_WOOCOMMERCE_TYPE_WINDOW_SYNC_PRODUCTS_PROGRESS, EPosWoocommerceWindowSyncProductsProgressClass))

typedef struct _EPosWoocommerceWindowSyncProductsProgress EPosWoocommerceWindowSyncProductsProgress;
typedef struct _EPosWoocommerceWindowSyncProductsProgressClass EPosWoocommerceWindowSyncProductsProgressClass;

#define EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_PRODUCTS_TYPE_COLUMNS (epos_woocommerce_widget_woocommerce_products_columns_get_type ())

#define EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_STORES (epos_woocommerce_widget_woocommerce_stores_get_type ())
#define EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_STORES(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_STORES, EPosWoocommerceWidgetWoocommerceStores))
#define EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_STORES_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_STORES, EPosWoocommerceWidgetWoocommerceStoresClass))
#define EPOS_WOOCOMMERCE_IS_WIDGET_WOOCOMMERCE_STORES(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_STORES))
#define EPOS_WOOCOMMERCE_IS_WIDGET_WOOCOMMERCE_STORES_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_STORES))
#define EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_STORES_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), EPOS_WOOCOMMERCE_TYPE_WIDGET_WOOCOMMERCE_STORES, EPosWoocommerceWidgetWoocommerceStoresClass))

typedef struct _EPosWoocommerceWidgetWoocommerceStores EPosWoocommerceWidgetWoocommerceStores;
typedef struct _EPosWoocommerceWidgetWoocommerceStoresClass EPosWoocommerceWidgetWoocommerceStoresClass;
typedef struct _EPosWoocommerceWidgetWoocommerceStoresPrivate EPosWoocommerceWidgetWoocommerceStoresPrivate;
typedef struct _EPosWoocommerceWindowSyncProductsProgressPrivate EPosWoocommerceWindowSyncProductsProgressPrivate;

struct _EPosWoocommerceSB_ModuleWoocommerce {
	SinticBoliviaGtkSBGtkModule parent_instance;
	EPosWoocommerceSB_ModuleWoocommercePrivate * priv;
};

struct _EPosWoocommerceSB_ModuleWoocommerceClass {
	SinticBoliviaGtkSBGtkModuleClass parent_class;
};

typedef void (*EPosWoocommerceSyncCallback) (gint totals, gint imported, const gchar* item_name, const gchar* message, void* user_data);
struct _EPosWoocommerceSBWCSync {
	GObject parent_instance;
	EPosWoocommerceSBWCSyncPrivate * priv;
	EPosWoocommerceWC_Api_Client* _api;
};

struct _EPosWoocommerceSBWCSyncClass {
	GObjectClass parent_class;
};

struct _EPosWoocommerceWC_Api_Client {
	GObject parent_instance;
	EPosWoocommerceWC_Api_ClientPrivate * priv;
	gchar* _consumerKey;
	gchar* _consumerSecret;
	gchar* _apiEndPoint;
	gchar* _endPoint;
	gchar* _wordpressUrl;
	gchar* _signatureMethod;
	gchar* _apiUrl;
	SoupMessageHeaders* _responseHeaders;
	gboolean debug;
};

struct _EPosWoocommerceWC_Api_ClientClass {
	GObjectClass parent_class;
};

struct _EPosWoocommerceWCHelper {
	GObject parent_instance;
	EPosWoocommerceWCHelperPrivate * priv;
};

struct _EPosWoocommerceWCHelperClass {
	GObjectClass parent_class;
};

struct _EPosWoocommerceWidgetWoocommerceCategories {
	GtkBox parent_instance;
	EPosWoocommerceWidgetWoocommerceCategoriesPrivate * priv;
	GtkBuilder* ui;
	GtkBox* box1;
	GtkImage* image1;
	GtkComboBox* comboboxStore;
	GtkButton* buttonSync;
	GtkEntry* entryName;
	GtkEntry* entrySlug;
	GtkTextView* textviewDescription;
	GtkComboBox* comboboxParent;
	GtkTreeView* treeviewCategories;
	gint storeId;
};

struct _EPosWoocommerceWidgetWoocommerceCategoriesClass {
	GtkBoxClass parent_class;
};

typedef enum  {
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CATEGORIES_COLUMNS_COUNT,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CATEGORIES_COLUMNS_ID,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CATEGORIES_COLUMNS_WOO_ID,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CATEGORIES_COLUMNS_NAME,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CATEGORIES_COLUMNS_DESCRIPTION,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CATEGORIES_COLUMNS_SLUG,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CATEGORIES_COLUMNS_PRODUCTS_COUNT,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CATEGORIES_COLUMNS_N_COLS
} EPosWoocommerceWidgetWoocommerceCategoriesColumns;

struct _EPosWoocommerceWidgetWoocommerceCustomers {
	GtkBox parent_instance;
	EPosWoocommerceWidgetWoocommerceCustomersPrivate * priv;
	GtkBuilder* ui;
	GtkBox* box1;
	GtkImage* image1;
	GtkComboBox* comboboxStore;
	GtkButton* buttonDetails;
	GtkButton* buttonSync;
	GtkTreeView* treeviewCustomers;
	gint storeId;
};

struct _EPosWoocommerceWidgetWoocommerceCustomersClass {
	GtkBoxClass parent_class;
};

typedef enum  {
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CUSTOMERS_COLUMNS_SELECT,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CUSTOMERS_COLUMNS_COUNT,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CUSTOMERS_COLUMNS_IMAGE,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CUSTOMERS_COLUMNS_ID,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CUSTOMERS_COLUMNS_WOO_ID,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CUSTOMERS_COLUMNS_FIRST_NAME,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CUSTOMERS_COLUMNS_LAST_NAME,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CUSTOMERS_COLUMNS_EMAIL,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_CUSTOMERS_COLUMNS_N_COLS
} EPosWoocommerceWidgetWoocommerceCustomersColumns;

struct _EPosWoocommerceWidgetWoocommerceProducts {
	GtkBox parent_instance;
	EPosWoocommerceWidgetWoocommerceProductsPrivate * priv;
	GtkBuilder* ui;
	GtkBox* box1;
	GtkImage* image1;
	GtkComboBox* comboboxStore;
	GtkComboBox* comboboxCategories;
	GtkButton* buttonDetails;
	GtkButton* buttonSync;
	GtkEntry* entrySearch;
	GtkComboBox* comboboxSearchBy;
	GtkTreeView* treeviewProducts;
	gint storeId;
	gboolean lockCategoriesEvent;
	EPosWoocommerceWindowSyncProductsProgress* windowProgress;
};

struct _EPosWoocommerceWidgetWoocommerceProductsClass {
	GtkBoxClass parent_class;
};

typedef enum  {
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_PRODUCTS_COLUMNS_SELECT,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_PRODUCTS_COLUMNS_COUNT,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_PRODUCTS_COLUMNS_IMAGE,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_PRODUCTS_COLUMNS_ID,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_PRODUCTS_COLUMNS_WOO_ID,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_PRODUCTS_COLUMNS_TITLE,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_PRODUCTS_COLUMNS_SKU,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_PRODUCTS_COLUMNS_QUANTITY,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_PRODUCTS_COLUMNS_PRICE,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_PRODUCTS_COLUMNS_CATEGORIES,
	EPOS_WOOCOMMERCE_WIDGET_WOOCOMMERCE_PRODUCTS_COLUMNS_N_COLS
} EPosWoocommerceWidgetWoocommerceProductsColumns;

struct _EPosWoocommerceWidgetWoocommerceStores {
	GtkBox parent_instance;
	EPosWoocommerceWidgetWoocommerceStoresPrivate * priv;
	GtkBuilder* ui;
	GtkBox* box1;
	GtkImage* image1;
	GtkButton* buttonNew;
	GtkButton* buttonEdit;
	GtkButton* buttonDelete;
	GtkTreeView* treeviewStores;
	GtkEntry* entryName;
	GtkEntry* entryUrl;
	GtkEntry* entryKey;
	GtkEntry* entrySecret;
	GtkButton* buttonCancel;
	GtkButton* buttonSave;
	gint storeId;
};

struct _EPosWoocommerceWidgetWoocommerceStoresClass {
	GtkBoxClass parent_class;
};

struct _EPosWoocommerceWindowSyncProductsProgress {
	GtkWindow parent_instance;
	EPosWoocommerceWindowSyncProductsProgressPrivate * priv;
	GtkBuilder* ui;
	GtkBox* box1;
	GtkLabel* labelProductName;
	GtkLabel* labelBytes;
	GtkProgressBar* progressbarDownload;
	GtkLabel* labelTotalProducts;
	GtkLabel* labelImportedProducts;
	GtkProgressBar* progressbarGlobal;
	GtkButton* buttonCancel;
};

struct _EPosWoocommerceWindowSyncProductsProgressClass {
	GtkWindowClass parent_class;
};


GType epos_woocommerce_sb_modulewoocommerce_get_type (void) G_GNUC_CONST;
void epos_woocommerce_sb_modulewoocommerce_AddHooks (EPosWoocommerceSB_ModuleWoocommerce* self);
void epos_woocommerce_sb_modulewoocommerce_hook_init_menu_management (EPosWoocommerceSB_ModuleWoocommerce* self, SinticBoliviaSBModuleArgs* args);
void epos_woocommerce_sb_modulewoocommerce_hook_before_register_sale (EPosWoocommerceSB_ModuleWoocommerce* self, SinticBoliviaSBModuleArgs* args);
void epos_woocommerce_sb_modulewoocommerce_hook_modules_loaded (EPosWoocommerceSB_ModuleWoocommerce* self, SinticBoliviaSBModuleArgs* args);
gboolean epos_woocommerce_sb_modulewoocommerce_SyncOrders (EPosWoocommerceSB_ModuleWoocommerce* self);
EPosWoocommerceSB_ModuleWoocommerce* epos_woocommerce_sb_modulewoocommerce_new (void);
EPosWoocommerceSB_ModuleWoocommerce* epos_woocommerce_sb_modulewoocommerce_construct (GType object_type);
GType sb_get_module_libwoocommerce_type (GModule* mod);
GType epos_woocommerce_sbwc_sync_get_type (void) G_GNUC_CONST;
GType epos_woocommerce_wc_api_client_get_type (void) G_GNUC_CONST;
EPosWoocommerceSBWCSync* epos_woocommerce_sbwc_sync_new (const gchar* wp_url, const gchar* api_key, const gchar* api_secret);
EPosWoocommerceSBWCSync* epos_woocommerce_sbwc_sync_construct (GType object_type, const gchar* wp_url, const gchar* api_key, const gchar* api_secret);
glong epos_woocommerce_sbwc_sync_SyncStore (EPosWoocommerceSBWCSync* self);
glong epos_woocommerce_sbwc_sync_SyncCategories (EPosWoocommerceSBWCSync* self, gint store_id);
void epos_woocommerce_sbwc_sync_FixCategoriesParent (EPosWoocommerceSBWCSync* self, gint store_id);
glong epos_woocommerce_sbwc_sync_SyncProducts (EPosWoocommerceSBWCSync* self, gint store_id, EPosWoocommerceSyncCallback cb, void* cb_target, GFileProgressCallback progress_callback, void* progress_callback_target);
void epos_woocommerce_sbwc_sync_FixProductCategories (EPosWoocommerceSBWCSync* self, gint store_id, gint product_id);
void epos_woocommerce_sbwc_sync_SyncCustomers (EPosWoocommerceSBWCSync* self, gint store_id);
gchar* epos_woocommerce_sbwc_sync_StripHtmlTags (EPosWoocommerceSBWCSync* self, const gchar* html);
SinticBoliviaDatabaseSBDatabase* epos_woocommerce_sbwc_sync_get_Dbh (EPosWoocommerceSBWCSync* self);
void epos_woocommerce_sbwc_sync_set_Dbh (EPosWoocommerceSBWCSync* self, SinticBoliviaDatabaseSBDatabase* value);
EPosWoocommerceWC_Api_Client* epos_woocommerce_wc_api_client_new (const gchar* wordpress_url, const gchar* api_key, const gchar* api_secret);
EPosWoocommerceWC_Api_Client* epos_woocommerce_wc_api_client_construct (GType object_type, const gchar* wordpress_url, const gchar* api_key, const gchar* api_secret);
JsonObject* epos_woocommerce_wc_api_client_GetStoreData (EPosWoocommerceWC_Api_Client* self);
GeeArrayList* epos_woocommerce_wc_api_client_GetCategories (EPosWoocommerceWC_Api_Client* self, gint limit, gint page, gint* total_cats, gint* total_pages);
GeeArrayList* epos_woocommerce_wc_api_client_GetProducts (EPosWoocommerceWC_Api_Client* self, gint limit, gint page, gint* total_products, gint* total_pages);
JsonArray* epos_woocommerce_wc_api_client_SearchCustomerByName (EPosWoocommerceWC_Api_Client* self, const gchar* name);
GeeHashMap* epos_woocommerce_wc_api_client_PlaceOrder (EPosWoocommerceWC_Api_Client* self, GeeHashMap* args);
JsonObject* epos_woocommerce_wc_api_client_Authenticate (EPosWoocommerceWC_Api_Client* self, const gchar* username, const gchar* pass);
JsonObject* epos_woocommerce_wc_api_client_CreateCustomer (EPosWoocommerceWC_Api_Client* self, GeeHashMap* data);
GeeArrayList* epos_woocommerce_wc_api_client_GetCustomers (EPosWoocommerceWC_Api_Client* self, gint limit, gint page, gint* total_customers, gint* total_pages);
gchar* _epos_woocommerce_wc_api_client_makeApiCall (EPosWoocommerceWC_Api_Client* self, const gchar* endpoint, GeeHashMap* args, const gchar* method, gboolean send_raw);
gchar* _epos_woocommerce_wc_api_client_getSignature (EPosWoocommerceWC_Api_Client* self, const gchar* endpoint, const gchar* query_string, const gchar* method);
GType epos_woocommerce_wc_helper_get_type (void) G_GNUC_CONST;
GeeArrayList* epos_woocommerce_wc_helper_GetStores (void);
SinticBoliviaSBStore* epos_woocommerce_wc_helper_GetStore (gint id);
GeeArrayList* epos_woocommerce_wc_helper_GetProducts (gint store_id);
GeeArrayList* epos_woocommerce_wc_helper_GetStoreCustomers (gint store_id, SinticBoliviaDatabaseSBDatabase* _dbh);
GeeArrayList* epos_woocommerce_wc_helper_GetOrders (gint store_id, const gchar* status, SinticBoliviaDatabaseSBDatabase* _dbh);
GeeArrayList* epos_woocommerce_wc_helper_GetOrdersPendingToSync (gint store_id, SinticBoliviaDatabaseSBDatabase* _dbh);
EPosWoocommerceWCHelper* epos_woocommerce_wc_helper_new (void);
EPosWoocommerceWCHelper* epos_woocommerce_wc_helper_construct (GType object_type);
GType epos_woocommerce_widget_woocommerce_categories_get_type (void) G_GNUC_CONST;
GType epos_woocommerce_widget_woocommerce_categories_columns_get_type (void) G_GNUC_CONST;
EPosWoocommerceWidgetWoocommerceCategories* epos_woocommerce_widget_woocommerce_categories_new (void);
EPosWoocommerceWidgetWoocommerceCategories* epos_woocommerce_widget_woocommerce_categories_construct (GType object_type);
void epos_woocommerce_widget_woocommerce_categories_Build (EPosWoocommerceWidgetWoocommerceCategories* self);
void epos_woocommerce_widget_woocommerce_categories_SetEvents (EPosWoocommerceWidgetWoocommerceCategories* self);
void epos_woocommerce_widget_woocommerce_categories_OnComboBoxStoreChanged (EPosWoocommerceWidgetWoocommerceCategories* self);
void epos_woocommerce_widget_woocommerce_categories_OnButtonSyncClicked (EPosWoocommerceWidgetWoocommerceCategories* self);
void epos_woocommerce_widget_woocommerce_categories_RefreshCategories (EPosWoocommerceWidgetWoocommerceCategories* self, gint store_id);
gint epos_woocommerce_widget_woocommerce_categories_SyncCategories (EPosWoocommerceWidgetWoocommerceCategories* self);
GType epos_woocommerce_widget_woocommerce_customers_get_type (void) G_GNUC_CONST;
GType epos_woocommerce_widget_woocommerce_customers_columns_get_type (void) G_GNUC_CONST;
EPosWoocommerceWidgetWoocommerceCustomers* epos_woocommerce_widget_woocommerce_customers_new (void);
EPosWoocommerceWidgetWoocommerceCustomers* epos_woocommerce_widget_woocommerce_customers_construct (GType object_type);
void epos_woocommerce_widget_woocommerce_customers_Build (EPosWoocommerceWidgetWoocommerceCustomers* self);
void epos_woocommerce_widget_woocommerce_customers_SetEvents (EPosWoocommerceWidgetWoocommerceCustomers* self);
void epos_woocommerce_widget_woocommerce_customers_OnCamboBoxStoreChanged (EPosWoocommerceWidgetWoocommerceCustomers* self);
void epos_woocommerce_widget_woocommerce_customers_OnButtonSyncClicked (EPosWoocommerceWidgetWoocommerceCustomers* self);
void epos_woocommerce_widget_woocommerce_customers_Refresh (EPosWoocommerceWidgetWoocommerceCustomers* self, gint store_id);
gint epos_woocommerce_widget_woocommerce_customers_SyncCustomers (EPosWoocommerceWidgetWoocommerceCustomers* self);
GType epos_woocommerce_widget_woocommerce_products_get_type (void) G_GNUC_CONST;
GType epos_woocommerce_window_sync_products_progress_get_type (void) G_GNUC_CONST;
GType epos_woocommerce_widget_woocommerce_products_columns_get_type (void) G_GNUC_CONST;
EPosWoocommerceWidgetWoocommerceProducts* epos_woocommerce_widget_woocommerce_products_new (void);
EPosWoocommerceWidgetWoocommerceProducts* epos_woocommerce_widget_woocommerce_products_construct (GType object_type);
void epos_woocommerce_widget_woocommerce_products_Build (EPosWoocommerceWidgetWoocommerceProducts* self);
void epos_woocommerce_widget_woocommerce_products_SetEvents (EPosWoocommerceWidgetWoocommerceProducts* self);
void epos_woocommerce_widget_woocommerce_products_OnComboBoxStoreChanged (EPosWoocommerceWidgetWoocommerceProducts* self);
void epos_woocommerce_widget_woocommerce_products_OnComboBoxCategoriesChanged (EPosWoocommerceWidgetWoocommerceProducts* self);
void epos_woocommerce_widget_woocommerce_products_SetStoreCategories (EPosWoocommerceWidgetWoocommerceProducts* self, gint store_id);
void epos_woocommerce_widget_woocommerce_products_RefreshProducts (EPosWoocommerceWidgetWoocommerceProducts* self, gint store_id, gint cat_id);
void epos_woocommerce_widget_woocommerce_products_OnButtonSyncClicked (EPosWoocommerceWidgetWoocommerceProducts* self);
gint epos_woocommerce_widget_woocommerce_products_SyncProducts (EPosWoocommerceWidgetWoocommerceProducts* self);
GType epos_woocommerce_widget_woocommerce_stores_get_type (void) G_GNUC_CONST;
EPosWoocommerceWidgetWoocommerceStores* epos_woocommerce_widget_woocommerce_stores_new (void);
EPosWoocommerceWidgetWoocommerceStores* epos_woocommerce_widget_woocommerce_stores_construct (GType object_type);
void epos_woocommerce_widget_woocommerce_stores_Build (EPosWoocommerceWidgetWoocommerceStores* self);
void epos_woocommerce_widget_woocommerce_stores_SetEvents (EPosWoocommerceWidgetWoocommerceStores* self);
void epos_woocommerce_widget_woocommerce_stores_RefreshStores (EPosWoocommerceWidgetWoocommerceStores* self);
void epos_woocommerce_widget_woocommerce_stores_OnButtonNewClicked (EPosWoocommerceWidgetWoocommerceStores* self);
void epos_woocommerce_widget_woocommerce_stores_OnButtonEditClicked (EPosWoocommerceWidgetWoocommerceStores* self);
void epos_woocommerce_widget_woocommerce_stores_OnButtonSaveClicked (EPosWoocommerceWidgetWoocommerceStores* self);
void epos_woocommerce_widget_woocommerce_stores_Reset (EPosWoocommerceWidgetWoocommerceStores* self);
EPosWoocommerceWindowSyncProductsProgress* epos_woocommerce_window_sync_products_progress_new (void);
EPosWoocommerceWindowSyncProductsProgress* epos_woocommerce_window_sync_products_progress_construct (GType object_type);
void epos_woocommerce_window_sync_products_progress_Build (EPosWoocommerceWindowSyncProductsProgress* self);


G_END_DECLS

#endif
