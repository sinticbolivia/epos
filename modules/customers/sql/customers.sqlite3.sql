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
