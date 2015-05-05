VLIBS=--pkg gmodule-2.0 --pkg gee-1.0 --pkg gtk+-3.0 --pkg sqlite3 --pkg SinticBolivia --pkg GtkSinticBolivia
VFLAGS=--vapidir=../../../SinticBolivia --vapidir=../../../SinticBolivia/widgets
CFLAGS=-X -I. -X -I../../../SinticBolivia -X -I../../../SinticBolivia/widgets -X -L../../../SinticBolivia/bin
CLIBS=-X -lSinticBolivia
SOURCES=module.restaurant.vala widgets/widget.environments.vala helpers/helper.restaurant.vala widgets/widget.options.vala
MODULE_NAME=Restaurant
LIB_NAME=libRestaurant.so
all:
	valac -o $(LIB_NAME) --library=$(MODULE_NAME) -H $(MODULE_NAME).h $(SOURCES) -X -fPIC -X -shared $(VFLAGS) $(CFLAGS) $(VLIBS) $(CLIBS)
	glib-compile-resources $(shell echo $(MODULE_NAME) | tr A-Z a-z).gresource.xml
install:
	install $(LIB_NAME) ../../bin/modules/
	install $(shell echo $(MODULE_NAME) | tr A-Z a-z).gresource ../../bin/modules/
clean: 
	rm $(LIB_NAME)
	rm users.gresource
	rm *.h
	#rm *.c
	#rm widgets/*.c
	#rm classes/*.c
	rm *.vapi
