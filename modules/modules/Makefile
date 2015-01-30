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
		-X -I../../../libs/libmysqlclient-5.6.20\
		-X -I../../../SinticBolivia \
		-X -I../../../SinticBolivia/widgets \
		-X -L../../../SinticBolivia/bin \
		-X -L../../../SinticBolivia/widgets
CLIBS=-X -lSinticBolivia \
		-X -lGtkSinticBolivia
		
SOURCES=module.modules.vala \
		widgets/widget.modules.vala
MODULE_NAME=Modules
LIB_NAME=libModules.so
all:
	valac -o $(LIB_NAME) --library=$(MODULE_NAME) -H $(MODULE_NAME).h $(SOURCES) -X -fPIC -X -shared $(VFLAGS) $(CFLAGS) $(VLIBS) $(CLIBS)
	glib-compile-resources modules.gresource.xml
install:
	install $(LIB_NAME) ../../bin/modules/
	install modules.gresource ../../bin/modules/
clean: 
	rm $(LIB_NAME)
	rm modules.gresource
	rm *.h
	rm *.vapi
