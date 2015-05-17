NO_COLOR=\033[0m
OK_COLOR=\033[32m
BLUE_COLOR=\033[34m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m

OK_STRING=$(OK_COLOR)[OK]$(NO_COLOR)
ERROR_STRING=$(ERROR_COLOR)[ERRORS]$(NO_COLOR)
WARN_STRING=$(WARN_COLOR)[WARNINGS]$(NO_COLOR)

PKG=--pkg gmodule-2.0\
        --pkg gee-1.0\
        --pkg gio-2.0\
        --pkg gtk+-3.0\
        --pkg sqlite3\
        --pkg mysql\
        --pkg SinticBolivia\
        --pkg GtkSinticBolivia\
        --pkg libxml-2.0\
        --pkg json-glib-1.0\
        --pkg libsoup-2.4 \
        --pkg posix\
        --pkg Pos
        
VAPI=--vapidir=../../../SinticBolivia \
        --vapidir=../../../SinticBolivia/widgets\
        --vapidir=../pos
        
CFLAGS=
		
		
CLIBS=-X -lSinticBolivia \
		-X -lGtkSinticBolivia\
		-X -lPos
				
INCLUDE_DIR=-X -I.\
			-X -I../../../SinticBolivia\
			-X -I../../../SinticBolivia/widgets\
			-X -I../pos
			
LIB_DIR=-X -L../../../SinticBolivia/bin\
		-X -L../../../SinticBolivia/widgets\
		-X -L../pos

SRC=$(wildcard *.vala) $(wildcard classes/*.vala) $(wildcard helpers/*.vala) $(wildcard widgets/*.vala) $(wildcard dialogs/*.vala)
MODULE_NAME=WoocommerceFees
LIB_NAME=libWoocommerceFees.so
#VARA="-e $(OK_COLOR)pwd$(NO_COLOR)"
all:
	@echo "\n$(BLUE_COLOR)Building Woocommerce Fees Module"
	@echo "==========================================$(NO_COLOR)\n\n"
	valac -o $(LIB_NAME) -D GLIB_2_32 --library=$(MODULE_NAME) -H $(MODULE_NAME).h -X -fPIC -X -shared $(SRC) $(PKG) $(VAPI) $(CFLAGS) $(INCLUDE_DIR) $(LIB_DIR) $(CLIBS)
	glib-compile-resources woocommerce_fees.gresource.xml
	@cp $(LIB_NAME) woocommerce_fees.gresource ../../bin/modules
	@echo "\n$(OK_COLOR)Compilation completed!!!\n"
install:
	install $(LIB_NAME) /c/EPOS/modules
	install woocommerce_fees.gresource /c/EPOS/modules
clean:
	rm $(LIB_NAME) woocommerce_fees.gresource *.h *.vapi
