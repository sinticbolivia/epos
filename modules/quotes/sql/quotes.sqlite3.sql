CREATE TABLE IF NOT EXISTS quotes(
	quote_id				integer not null primary key autoincrement,
	code					varchar(32),
	store_id				integer not null,
	user_id					integer not null,
	customer_id				integer not null,
	description				varchar(512),
	items					integer,
	subtotal				decimal(10,2),
	total_tax				decimal(10,2),
	discount				decimal(10,2),
	total					decimal(10,2),
	status					varchar(128),
	quote_date				datetime,
	expiration_date			datetime,	
	last_modification_date 	datetime,
	creation_date 			datetime
);
CREATE TABLE IF NOT EXISTS quote_items(
	item_id					integer not null primary key AUTOINCREMENT,
	quote_id				integer not null,
	product_id				integer not null,
	product_name			varchar(250),
	quantity				integer,
	price					decimal(10,2),
	subtotal				decimal(10,2),
	tax_rate				decimal(10,2),
	total_tax				decimal(10,2),
	discount				decimal(10,2),
	total					decimal(10,2),
	status					varchar(128),
	last_modification_date 	datetime,
	creation_date 			datetime
);
