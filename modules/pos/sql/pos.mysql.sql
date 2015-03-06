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
