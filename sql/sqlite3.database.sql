CREATE TABLE attachments ( 
    attachment_id          INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
    object_type            varchar(128),
    object_id              integer,
    title                  varchar(128),
    description            text,
    type                   TEXT,
    mime                   TEXT,
    file                   TEXT,
    last_modification_date TEXT,
    creation_date          TEXT,
    size                   TEXT,
    parent                 INTEGER DEFAULT ( 0 ) 
);
CREATE TABLE IF NOT EXISTS turns(
	turn_id 			integer not null primary key autoincrement,
	store_id			integer not null,
	user_id 			integer not null,
	initial_amount		decimal(10, 2),
	final_amount		decimal(10, 2),
	open_date 			datetime,
	close_date 			datetime,
	status				varchar(128),
	terminal_id			integer,
	creation_date 		datetime
);
CREATE TABLE IF NOT EXISTS tax_rates(
	tax_id 					integer not null primary key autoincrement,
	name					varchar(256),
	rate					decimal(10, 2),
	last_modification_date	datetime,
	creation_date			datetime
);
