CREATE TABLE IF NOT EXISTS payment_methods(
	method_id			integer not null auto_increment primary key,
	name				varchar(256),
	code				varchar(120),
	creation_date		datetime
);
CREATE TABLE IF NOT EXISTS payment_terms(
	term_id				interger not null auto_increment primary key,
	name				varchar(128),
	max_days			decimal(10, 2),
	creation_date		datetime
);
