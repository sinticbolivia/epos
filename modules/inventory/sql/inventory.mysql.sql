CREATE TABLE IF NOT EXISTS stores ( 
    store_id                     INTEGER         PRIMARY KEY AUTO_INCREMENT NOT NULL,
    store_name                   varchar(128),
    store_address                varchar(256),
    phone							varchar(128),
    fax								varchar(128),
    store_key                    VARCHAR( 150 )  UNIQUE,
    store_description            VARCHAR( 250 ),
    store_type                   VARCHAR( 100 ),
    main_store					tinyint(1),
    tax_id                       INTEGER,
    sales_transaction_type_id    INTEGER,
    purchase_transaction_type_id INTEGER,
    refund_transaction_type_id   INTEGER, 
    last_modification_date       DATETIME,
    creation_date                DATETIME
);
CREATE TABLE IF NOT EXISTS store_meta ( 
    meta_id       INTEGER         PRIMARY KEY AUTO_INCREMENT,
    meta_key      VARCHAR( 128 ),
    meta_value    TEXT,
    store_id      INTEGER         NOT NULL,
    creation_date DATETIME 
);

CREATE TABLE IF NOT EXISTS categories ( 
    category_id   INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name          TEXT,
    description   TEXT,
    parent        INTEGER,
    extern_id     INT,
    store_id      INT, 
    creation_date DATETIME
);
CREATE TABLE IF NOT EXISTS products ( 
    product_id             INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    extern_id              	INTEGER,
    product_code           VARCHAR( 100 ),
    product_number			VARCHAR(128),
    stocking_code			VARCHAR(128),
    product_name           VARCHAR( 250 ),
    product_description    TEXT,
    product_line_id        INTEGER,
    product_model          VARCHAR( 250 ),
    product_barcode        VARCHAR( 100 ),
    product_cost           DECIMAL( 10, 2 ),
    product_price          DECIMAL( 10, 2 ),
    product_price_2        	DECIMAL( 10, 2 ),
    product_price_3        	DECIMAL( 10, 2 ),
    product_quantity       INTEGER,
    product_unit_measure   INTEGER,
    store_id               	INTEGER,
    user_id                	INTEGER,
    department_id			INTEGER,
    status                 	VARCHAR( 50 ),
    min_stock             	INTEGER,
    product_internal_code  	VARCHAR( 100 ),
    shipping_weight			varchar(100),
    width					decimal(10,2),
    height					decimal(10,2),
	last_modification_date 	DATETIME,
    creation_date          	DATETIME
);
CREATE TABLE IF NOT EXISTS product_meta ( 
    meta_id                INTEGER         PRIMARY KEY AUTO_INCREMENT NOT NULL,
    product_id             INTEGER  NOT NULL,
    meta_key               VARCHAR(128),
    meta_value             TEXT,
    last_modification_date DATETIME,
    creation_date          DATETIME 
);
CREATE TABLE IF NOT EXISTS product_sn(
	sn_id					INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
	product_id				INTEGER NOT NULL,
	sn						varchar(256),
	last_modification_date	datetime,
	creation_date			datetime
);
CREATE TABLE IF NOT EXISTS tags(
	tag_id					integer not null primary key auto_increment,
	tag						varchar(256),
	creation_date			datetime
);
CREATE TABLE IF NOT EXISTS product2tag(
	id						integer not null primary key auto_increment,
	product_id				integer not null,
	tag_id					integer not null,
);
CREATE TABLE IF NOT EXISTS unit_measures(
	measure_id				INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
	name					varchar(128),
	code					varchar(64),
	quantity				integer,
	last_modification_date	datetime,
	creation_date			datetime
);
CREATE TABLE IF NOT EXISTS `product_lines`(
	line_id					INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
	name					VARCHAR(128),
	description				VARCHAR(512),
	store_id				INTEGER,
	last_modification_date	datetime,
	creation_date			datetime
);
CREATE TABLE IF NOT EXISTS departments(
	department_id			INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
	store_id				integer,
	name					varchar(128),
	description				text,
	last_modification_date	datetime,
	creation_date			datetime
);
CREATE TABLE IF NOT EXISTS purchase_orders(
	order_id 				integer not null primary key auto_increment,
	code					varchar(128),
	name					varchar(256),
	store_id 				integer not null,
	supplier_id				integer,
	items					integer,
	subtotal				decimal(10,2),
	total_tax				decimal(10,2),
	discount				decimal(10,2),
	total					decimal(10,2),
	r_subtotal				decimal(10,2),
	r_total_tax				decimal(10,2),
	r_discount				decimal(10,2),
	r_total					decimal(10,2),
	details					text,
	status					varchar(128),
	user_id					integer,
	order_date				datetime,
	delivery_date			datetime,	
	last_modification_date 	datetime,
	creation_date 			datetime
);
CREATE TABLE IF NOT EXISTS purchase_order_items(
	item_id					integer not null primary key auto_increment,
	product_id				integer not null,
	order_id				integer not null,
	name					varchar(250),
	quantity				integer,
	quantity_received		integer default 0,
	supply_price			decimal(10,2),
	subtotal				decimal(10,2),
	tax_rate				decimal(10,2),
	total_tax				decimal(10,2),
	discount				decimal(10,2),
	total					decimal(10,2),
	r_subtotal				decimal(10,2),
	r_total_tax				decimal(10,2),
	r_total					decimal(10,2),
	status					varchar(128),
	last_modification_date 	datetime,
	creation_date 			datetime
);
CREATE TABLE IF NOT EXISTS purchase_order_deliveries(
	delivery_id 			integer not null primary key auto_increment,
	order_id				integer not null,
	items					integer,
	sub_total				decimal(10,2),
	total_tax				decimal(10,2),
	discount				decimal(10,2),
	total					decimal(10,2),
	notes					text,
	data					text,
	creation_date			datetime
);
CREATE TABLE IF NOT EXISTS purchase_order_delivery_items(
	item_id					integer not null primary key auto_increment,
	delivery_id				integer not null,
	quantity_ordered		integer,
	supply_price			decimal(10,2),
	quantity_delivered		integer,
	sub_total				decimal(10,2),
	total_tax				decimal(10,2),
	discount				decimal(10,2),
	total					decimal(10,2),
	creation_date			datetime
);
CREATE TABLE IF NOT EXISTS suppliers ( 
    supplier_id             INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    store_id				integer,
    supplier_name           varchar(128),
    supplier_address        varchar(256),
    supplier_address_2      varchar(256),
    supplier_telephone_1    TEXT,
    supplier_telephone_2    TEXT,
    fax						varchar(64),
    supplier_details        TEXT,
    supplier_city           TEXT,
    supplier_email          TEXT,
    supplier_contact_person varchar(256),
    country					varchar(128),
    bank_name               VARCHAR( 250 ),
    bank_account            VARCHAR( 100 ),
    nit_ruc_nif             VARCHAR( 50 ),
    supplier_key            VARCHAR( 10 ),
    last_modification_date  DATETIME,
    creation_date           DATETIME
);
CREATE TABLE IF NOT EXISTS supplier_categories(
	category_id				integer not null primary key auto_increment,
	name					varchar(256),
	parent					integer default 0,
	last_modification_date	datetime,
	creation_date			datetime
);
CREATE TABLE IF NOT EXISTS transaction_types ( 
    transaction_type_id     INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
    transaction_key         varchar(64),
    transaction_name        varchar(128),
    transaction_description TEXT,
    in_out                  varchar(64),
    store_id                INTEGER NOT NULL DEFAULT 0,
    last_modification_date  datetime,
    creation_date           datetime
);
CREATE TABLE IF NOT EXISTS tax_rates(
	tax_id 					integer not null primary key auto_increment,
	code					varchar(256),
	name					varchar(256),
	rate					decimal(10, 2),
	last_modification_date	datetime,
	creation_date			datetime
);
CREATE TABLE IF NOT EXISTS currencies(
	currency_id				integer not null primary key auto_increment,
	code					varchar(10),
	name					varchar(128),
	rate					decimal(10, 2),
	creation_date			datetime
);
CREATE TABLE IF NOT EXISTS item_types(
	item_type_id			integer not null primary key auto_increment,
	code					varchar(128),
	name					varchar(128),
	creation_date			datetime
);
CREATE TABLE IF NOT EXISTS product2suppliers(
	id						integer not null primary key auto_increment,
	product_id				integer not null,
	supplier_id				integer not null,
	creation_date			datetime
);
CREATE TABLE IF NOT EXISTS product2category ( 
    id            INTEGER  NOT NULL PRIMARY KEY AUTO_INCREMENT,
    product_id    INTEGER  NOT NULL,
    category_id   INTEGER  NOT NULL,
    creation_date DATETIME 
);
CREATE TABLE IF NOT EXISTS assemblies(
	assembly_id				INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
	code					varchar(128),
	name					varchar(128),
	description				varchar(256),
	store_id				integer,
	last_modification_date	datetime,
	creation_date			datetime
);
CREATE TABLE IF NOT EXISTS assemblie2product(
	id						integer not null primary key auto_increment,
	assembly_id				integer not null,
	product_id				integer not null,
	qty_required			integer,
	unit_measure_id			integer not null,
	creation_date			datetime
);
CREATE TABLE IF NOT EXISTS product_adjustments(
	adjustment_id 			integer not null primary key auto_increment,
	code					varchar(128),
	store_id				integer not null
	product_id				integer not null,
	user_id					integer not null,
	note					text,
	old_qty					integer,
	new_qty					integer,
	difference				integer,
	status					varchar(128),
	adjustment_date			datetime,
	creation_date			datetime
);
