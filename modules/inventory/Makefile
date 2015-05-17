VLIBS=--pkg gmodule-2.0\
        --pkg gee-1.0\
        --pkg gtk+-3.0\
        --pkg sqlite3\
        --pkg mysql\
        --pkg SinticBolivia\
        --pkg GtkSinticBolivia\
		--pkg libharu\
		--pkg posix\
		--pkg libxml-2.0\
		--pkg xlsxwriter
		
VFLAGS=--vapidir=../../../SinticBolivia \
        --vapidir=../../../SinticBolivia/widgets\
        --vapidir=../../../libs/libxlsxwriter/include\
		--vapidir=../../../libs/libharu\
		--vapidir=../../../libs/libxlsxwriter/include/
		
CFLAGS=-X -I.\
        -X -I../../../SinticBolivia\
        -X -I../../../SinticBolivia/widgets\
        -X -I../../../libs/libxlsxwriter/include\
        -X -L../../../libs/libxlsxwriter/lib\
        -X -I../../../libs/libharu/libharu-RELEASE_2_2_0/include\
        -X -L../../../libs/libharu/libharu-RELEASE_2_2_0/src/.libs\
		-X -L../../../SinticBolivia/bin
		
		
CLIBS=-X -lSinticBolivia \
		-X -lhpdf \
		-X -lxlsxwriter
	
SOURCES=$(wildcard *.vala) $(wildcard classes/*.vala) $(wildcard widgets/*.vala) $(wildcard dialogs/*.vala) $(wildcard helpers/*.vala)
		
MODULE_NAME=Inventory
LIB_NAME=libInventory.so
all:
	valac -o $(LIB_NAME) --library=$(MODULE_NAME) -H $(MODULE_NAME).h $(SOURCES) -X -fPIC -X -shared $(VFLAGS) $(CFLAGS) $(VLIBS) $(CLIBS)
	glib-compile-resources inventory.gresource.xml
	cp $(LIB_NAME) inventory.gresource ../../bin/modules
install:
	install $(LIB_NAME) ../../bin/modules/
	install inventory.gresource ../../bin/modules/
clean: 
	rm $(LIB_NAME)
	rm inventory.gresource
	rm *.h
	rm *.vapi
