CREATE TABLE IF NOT EXISTS rest_environments(
	environment_id 			integer not null primary key autoincrement,
	name					varchar(200),
	last_modification_date	datetime,
	creation_date			datetime
);
CREATE TABLE IF NOT EXISTS rest_tables(
	table_id				integer not null primary key autoincrement,
	name					varchar(200),
	environment_id			integer not null,
	last_modification_date	datetime,
	creation_date			datetime
);
CREATE TABLE IF NOT EXISTS rest_product_ops(
	option_id				integer not null primary key autoincrement,
	name					varchar(200),
	price					decimal(10, 2),
	last_modification_date	datetime,
	creation_date			datetime
);
CREATE TABLE IF NOT EXISTS rest_product2op(
	id						integer not null primary key autoincrement,
	product_id				integer not null,
	option_id				integer not null,
	creation_date			dateime
);
