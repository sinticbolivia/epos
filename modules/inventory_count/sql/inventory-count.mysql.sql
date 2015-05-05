create table if not exists inventory_counts(
	count_id			integer not null primary key auto_increment,
	store_id			integer not null,
	user_id				integer not null,
	description			varchar(512),
	status				varchar(64),
	creation_date		datetime
);
create table if not exists inventory_count_products(
	id					integer not null primary key auto_increment,
	count_id			integer not null,
	product_id			integer not null,
	creation_date		datetime
);
create table if not exists inventory_count_results(
	result_id 			integer not null primary key auto_increment,
	result_number		integer not null,
	count_id			integer not null,
	user_id				integer not null,
	employee_id			integer,
	product_id			integer not null,
	units				integer not null default 0,
	package				integer not null default 0,
	creation_date		datetime
);
create table if not exists inventory_count_difference(
	difference_id		integer not null primary key auto_increment,
	result_number		integer not null,
	product_id			integer not null,
	units				integer,
	package				integer,
	creation_date		datetime
);
