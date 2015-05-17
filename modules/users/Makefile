VLIBS=--pkg gmodule-2.0 \
		--pkg gee-1.0 \
		--pkg gtk+-3.0 \
		--pkg libxml-2.0\
		--pkg sqlite3 \
		--pkg mysql\
		--pkg SinticBolivia \
		--pkg GtkSinticBolivia
VFLAGS=--vapidir=../../../SinticBolivia \
		--vapidir=../../../SinticBolivia/widgets
CFLAGS=-X -I. \
		-X -I../../../SinticBolivia \
		-X -I../../../SinticBolivia/widgets \
		-X -L../../../SinticBolivia/bin
CLIBS=-X -lSinticBolivia
SOURCES=module.users.vala  $(wildcard widgets/*.vala) $(wildcard dialogs/*.vala)  $(wildcard helpers/*.vala)
MODULE_NAME=Users
LIB_NAME=libUsers.so
all:
	valac -o $(LIB_NAME) --library=$(MODULE_NAME) -H $(MODULE_NAME).h $(SOURCES) -X -fPIC -X -shared $(VFLAGS) $(CFLAGS) $(VLIBS) $(CLIBS)
	glib-compile-resources users.gresource.xml
	cp $(LIB_NAME) users.gresource ../../bin/modules
install:
	install $(LIB_NAME) ../../bin/modules/
	install users.gresource ../../bin/modules/
clean: 
	rm $(LIB_NAME)
	rm users.gresource
	rm *.h
	rm *.c
	rm widgets/*.c
	rm classes/*.c
	rm *.vapi
