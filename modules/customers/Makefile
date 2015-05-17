VLIBS=--pkg gmodule-2.0 \
		--pkg gee-1.0 \
		--pkg libxml-2.0\
		--pkg gtk+-3.0 \
		--pkg sqlite3 \
		--pkg mysql\
		--pkg SinticBolivia \
		--pkg GtkSinticBolivia \
		--pkg posix
		
VFLAGS=--vapidir=../../../SinticBolivia \
		--vapidir=../../../SinticBolivia/widgets
		
CFLAGS=-X -I. \
		-X -I../../../SinticBolivia \
		-X -I../../../SinticBolivia/widgets \
		-X -L../../../SinticBolivia/bin \
		-X -L../../../SinticBolivia/widgets
		
CLIBS=-X -lSinticBolivia \
		-X -lGtkSinticBolivia
SOURCES=$(wildcard *.vala) $(wildcard widgets/*.vala) $(wildcard classes/*.vala)
			
MODULE_NAME=Customers
LIB_NAME=libCustomers.so
all:
	valac -o $(LIB_NAME) --library=$(MODULE_NAME) -H $(MODULE_NAME).h $(SOURCES) -X -fPIC -X -shared $(VFLAGS) $(CFLAGS) $(VLIBS) $(CLIBS)
	glib-compile-resources customers.gresource.xml
	cp $(LIB_NAME) customers.gresource ../../bin/modules
install:
	install $(LIB_NAME) ../../bin/modules/
	install customers.gresource ../../bin/modules/
clean: 
	rm $(LIB_NAME)
	rm customers.gresource
	rm *.h
	rm *.vapi
