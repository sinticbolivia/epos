CREATE TABLE IF NOT EXISTS payment_methods(
	method_id			integer not null primary key autoincrement,
	name				varchar(256),
	code				varchar(120),
	creation_date		datetime
);
CREATE TABLE IF NOT EXISTS payment_terms(
	term_id				integer not null primary key autoincrement,
	name				varchar(128),
	max_days			decimal(10, 2),
	creation_date		datetime
);
CREATE TABLE IF NOT EXISTS sales(
	sale_id				integer not null primary key autoincrement,
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
	item_id				integer not null primary key autoincrement,
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
CREATE TABLE IF NOT EXISTS customers(
	customer_id		integer not null primary key autoincrement,
	extern_id		integer default 0,
	code			varchar(512),
	store_id		integer,
	first_name		varchar(128),
	last_name		varchar(128),
	company			varchar(128),
	date_of_birth	date,
	gender			varchar(64),
	phone			varchar(64),
	mobile			varchar(64),
	fax				varchar(64),
	email			varchar(128),
	website			varchar(128),
	address_1				varchar(256),
	address_2				varchar(256),
	zip_code				varchar(32),
	city					varchar(128),
	country					varchar(128),		
	country_code			varchar(10),
	last_modification_date 	datetime,
	creation_date			datetime
);
CREATE TABLE IF NOT EXISTS customer_meta(
	meta_id			integer not null primary key autoincrement,
	customer_id		integer	not null,
	meta_key		varchar(256),
	meta_value		text,
	creation_date	datetime
);
