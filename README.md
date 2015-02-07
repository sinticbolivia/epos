# EPos
Ecommerce Point of Sale - The crossplatform Point of Sale and Inventory system.

Dependencies:
=============

Gtk3 >= 3.4

GLib >= 2.34

Gee 0.8

Lib Soup 2.4

Lib Json 1.0

GModule 2.0

Lib Xml

Sqlite3

MySql Client

Sintic Bolivia Framework >= 1.0

Sintic Bolivia Gtk Widgetd >= 1.0


Linux Build
============



Windows Build
=============

In order to build for windows, you need to setup a MinGW environment with all dependencies installed and compiled.

After that, you can just run the Makefile.win file with the next command.

make -f Makefile.win

To compile all modules run the next command.

make -f Makefile.win modules


make -f Makefile.win install

This last command, will install the system including mysql server engine into c:\EPOS directory.

In order to initialize the mysql server, you just need to execute the next command.

c:\EPOS\mysql\mysql_start.bat

To stop the server.

c:\EPOS\mysql\mysql_stop.bat


Now you need to setup the system.

cd \EPOS
setup.exe
woocommerce_pos.exe


Contacts
========

Website: http://sinticbolivia.net
Email: info@sinticbolivia.net


