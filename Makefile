SB_LIBS=../SinticBolivia
VFLAGS=--vapidir=$(SB_LIBS) \
		--vapidir=$(SB_LIBS)/widgets \
		-X -I. \
		-X -I./$(SB_LIBS) \
		-X -I./$(SB_LIBS)/widgets \
		-X -L./$(SB_LIBS)/bin \
		-X -L./$(SB_LIBS)/widgets
		
VLIBS=--pkg gtk+-3.0 \
		--pkg glib-2.0 \
		--pkg gmodule-2.0 \
		--pkg gio-2.0 \
		--pkg gee-1.0 \
		--pkg libsoup-2.4 \
		--pkg json-glib-1.0 \
		--pkg libxml-2.0 \
		--pkg sqlite3 \
		--pkg mysql\
		--pkg SinticBolivia \
		--pkg GtkSinticBolivia \
		-X -lSinticBolivia \
		-X -lGtkSinticBolivia\
		-X -lmysqlclient\
		-X -lm
VC=valac
SOURCES=main.vala $(wildcard classes/*.vala) $(wildcard dialogs/*.vala) $(wildcard widgets/*.vala) \
		$(wildcard helpers/*.vala)
		
OBJECTS=$(SOURCES:.vala=.o)
DEST_EXEC=woocommerce_pos
LIBRARY_NAME=SinticBolivia
#include Database/Makefile

all: $(DEST_EXEC) resource setup

#$(DEST_EXEC): $(OBJECTS)
$(DEST_EXEC): $(SOURCES)
	$(VC) -D __linux__ -D GLIB_2_32 --thread -X -s -o bin/$@ $(VFLAGS) $(VLIBS) $(SOURCES)
	@#$(VC) classes/interface.module.vala -C -H includes/pos_module.h --vapi=includes/pos_module.vapi --library=PosModule
	@#$(VC) classes/class.modules.vala -C -H includes/modules.h --vapi=includes/modules.vapi --library=PosModules --pkg gee-1.0 --pkg gmodule-2.0 includes/pos_module.vapi
	@#strip bin/$@
setup:
	valac -D __linux__ -D GLIB_2_32 -o bin/$@ $(VFLAGS) $(VLIBS) setup.vala
resource:
	glib-compile-resources ec-pos.gresource.xml
	mv ec-pos.gresource share/resources
	
#$(OBJECTS): $(SOURCES)
#	$(VC) -c $(VFLAGS) $(VLIBS) $^ -o $@
	
#	$(VC) $(VFLAGS) -c $(SOURCES)
##modules section
#$(MODULES): 
#	cd $<; make $<	
#.vala.o:
#	$(VC) $(VFLAGS) $< -o $@
#test: test.vala
#	$(VC) -X -I. -X -L./bin $(VLIBS) -X -l$(LIBRARY_NAME) $(LIBRARY_NAME).vapi  test.vala -o bin/test 
clean:
	rm -fv bin/$(DEST_EXEC)
	rm *.o
