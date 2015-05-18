#!/bin/bash

export LD_LIBRARY_PATH=`pwd`

if [ "$1" == "debug" ]; then
	echo -e "Debug enabled\n"
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/gtk-3.0/modules
	export GTK_MODULES=gtkparasite
fi
./ec-pos

