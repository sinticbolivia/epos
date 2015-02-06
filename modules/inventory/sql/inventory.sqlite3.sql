CREATE TABLE IF NOT EXISTS purchase_orders(
	order_id 				integer not null primary key autoincrement,
	code					varchar(128),
	name					varchar(256),
	store_id 				integer not null,
	items					integer,
	discount				decimal(10,2),
	total					decimal(10,2),
	details					text,
	status					varchar(128),
	user_id					integer,
	delivery_date			datetime,	
	last_modification_date 	datetime,
	creation_date 			datetime
);
CREATE TABLE IF NOT EXISTS purchase_order_items(
	item_id					integer not null primary key autoincrement,
	product_id				integer not null,
	order_id				integer not null,
	name					varchar(250),
	quantity				integer,
	supply_price			decimal(10,2),
	discount				decimal(10,2),
	total					decimal(10,2),
	last_modification_date 	datetime,
	creation_date 			datetime
);
CREATE TABLE IF NOT EXISTS suppliers ( 
    supplier_id             INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    supplier_name           TEXT,
    supplier_address        TEXT,
    supplier_telephone_1    TEXT,
    supplier_telephone_2    TEXT,
    supplier_details        TEXT,
    supplier_city           TEXT,
    supplier_email          TEXT,
    supplier_contact_person TEXT,
    bank_name               VARCHAR( 250 ),
    bank_account            VARCHAR( 100 ),
    nit_ruc_nif             VARCHAR( 50 ),
    supplier_key            VARCHAR( 10 ),
    last_modification_date  DATETIME,
    creation_date           DATETIME
);
