PKG=--pkg gmodule-2.0 \
		--pkg gee-1.0 \
		--pkg libxml-2.0\
		--pkg gtk+-3.0 \
		--pkg sqlite3 \
		--pkg mysql\
		--pkg SinticBolivia \
		--pkg GtkSinticBolivia \
		--pkg posix

SRV_PKG=--pkg gmodule-2.0 \
		--pkg gio-2.0\
		--pkg gee-1.0 \
		--pkg libxml-2.0\
		--pkg sqlite3 \
		--pkg mysql\
		--pkg SinticBolivia \
		--pkg posix
		
VAPI=--vapidir=../../../SinticBolivia \
		--vapidir=../../../SinticBolivia/widgets
		
CFLAGS=-X -I. \
		-X -I../../../SinticBolivia \
		-X -I../../../SinticBolivia/widgets \
		-X -L../../../SinticBolivia/bin
		
CLIBS=-X -lSinticBolivia \
		-X -lGtkSinticBolivia
		
SRV_LIBS=-X -lSinticBolivia
			
MOD_SOURCES=$(wildcard *.vala)
SERVER_SOURCES=$(wildcard classes/*.vala)		
MODULE_NAME=Chimuela
LIB_NAME=libChimuela.so

all: server
	valac -o $(LIB_NAME) $(MOD_SOURCES) --library=$(MODULE_NAME) -H $(MODULE_NAME).h  -X -fPIC -X -shared $(CFLAGS) $(VAPI) $(PKG) $(CLIBS)
	#glib-compile-resources customers.gresource.xml
	cp $(LIB_NAME) ../../bin/modules
server:
	valac -o chimuela $(SERVER_SOURCES) $(CFLAGS) $(VAPI) $(SRV_PKG) $(SRV_LIBS)
	cp chimuela ../../bin
install:
	install $(LIB_NAME) /c/EPOS/modules/
	install customers.gresource /c/EPOS/modules/
clean: 
	rm $(LIB_NAME) chimuela *.h *.vapi
