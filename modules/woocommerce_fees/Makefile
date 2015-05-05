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
        --pkg posix
        
VAPI=--vapidir=../../../SinticBolivia \
        --vapidir=../../../SinticBolivia/widgets
INCLUDE_DIR=-X -I.\
			-X -I../../../SinticBolivia\
			-X -I../../../SinticBolivia/widgets
LIB_DIR=-X -L../../../SinticBolivia/bin\
		-X -L../../../SinticBolivia/widgets

SRC=$(wildcard *.vala) $(wildcard helpers/*.vala) $(wildcard classes/*.vala) $(wildcard widgets/*.vala) $(wildcard dialogs/*.vala)
MODULE_NAME=Pos
LIB_NAME=libPos.so
#VARA="-e $(OK_COLOR)pwd$(NO_COLOR)"
all:
	@echo "\n$(BLUE_COLOR)Building Point of Sale Module"
	@echo "==========================================$(NO_COLOR)\n\n"
	valac -o $(LIB_NAME) --library=$(MODULE_NAME) -H $(MODULE_NAME).h -X -fPIC -X -shared $(SRC) $(PKG) $(VAPI) $(INCLUDE_DIR) $(LIB_DIR)
	glib-compile-resources pos.gresource.xml
	@echo "\n$(OK_COLOR)Compilation completed!!!\n"
install:
	cp $(LIB_NAME) pos.gresource ../../bin/modules
clean:
	rm $(LIB_NAME) pos.gresource *.h *.vapi
