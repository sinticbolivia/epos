CREATE TABLE IF NOT EXISTS payment_methods(
	method_id			integer not null auto_increment primary key,
	name				varchar(256),
	code				varchar(120),
	creation_date		datetime
);
CREATE TABLE IF NOT EXISTS payment_terms(
	term_id				integer not null auto_increment primary key,
	name				varchar(128),
	max_days			decimal(10, 2),
	creation_date		datetime
);
CREATE TABLE IF NOT EXISTS sales(
	sale_id				integer not null auto_increment primary key,
	code				varchar(128),
	store_id			integer not null,
	cashier_id			integer not null,
	customer_id			integer,
	notes				varchar(512),
	sub_total			decimal(10,2),
	tax_rate			decimal(10,2),
	tax_amount			decimal(10,2),
	discount_total		decimal(10,2),
	total				decimal(10,2),
	items_total			integer,
	status				varchar(128),
	last_modification_date	datetime,
	creation_date			datetime
);
CREATE TABLE IF NOT EXISTS sale_items(
	item_id				integer not null auto_increment primary key,
	sale_id				integer not null,
	product_id			integer,
	product_name		varchar(256),
	quantity			integer,
	price				decimal(10,2),
	sub_total			decimal(10,2),
	tax_rate			decimal(10,2),
	tax_amount			decimal(10,2),
	discount			decimal(10,2),
	total				decimal(10,2),
	status				varchar(128),
	last_modification_date	datetime,
	creation_date			datetime
);
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
CREATE TABLE IF NOT EXISTS product2category ( 
    id            INTEGER  NOT NULL PRIMARY KEY AUTO_INCREMENT,
    product_id    INTEGER  NOT NULL,
    category_id   INTEGER  NOT NULL,
    creation_date DATETIME 
);
