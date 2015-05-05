CREATE TABLE IF NOT EXISTS modules(
	module_id integer not null primary key autoincrement,
	name			varchar(256),
	description		text,
	module_key				varchar(128),
	library_name	varchar(128),
	file			varchat(256),
	status			varchar(128),
	creation_date	datetime
);
