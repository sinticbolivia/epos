include ../../Makefile.in
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
        
INCLUDE_DIR=-X -I.\
			-X -I../../../SinticBolivia\
			-X -I../../../SinticBolivia/widgets\
			-X -I../pos
			
LIB_DIR=-X -L../../../SinticBolivia/bin\
		-X -L../../../SinticBolivia/widgets\
		-X -L../pos

SRC=$(wildcard *.vala) $(wildcard classes/*.vala) $(wildcard helpers/*.vala) $(wildcard widgets/*.vala) $(wildcard dialogs/*.vala)
MODULE_NAME=Woocommerce
LIB_NAME=libWoocommerce.so
#VARA="-e $(OK_COLOR)pwd$(NO_COLOR)"
all:
	@echo "\n$(BLUE_COLOR)Building Woocommerce Point of Sale Integration Module"
	@echo "==========================================$(NO_COLOR)\n\n"
	valac -o $(LIB_NAME) -D GLIB_2_32 --library=$(MODULE_NAME) -H $(MODULE_NAME).h -X -fPIC -X -shared $(SRC) $(PKG) $(VAPI) $(INCLUDE_DIR) $(LIB_DIR)
	glib-compile-resources woocommerce.gresource.xml
	@echo "\n$(OK_COLOR)Compilation completed!!!\n"
	cp $(LIB_NAME) woocommerce.gresource $(INSTALL_DIR)/modules
install:
	cp $(LIB_NAME) woocommerce.gresource $(INSTALL_DIR)/modules
clean:
	rm $(LIB_NAME) woocommerce.gresource *.h *.vapi
