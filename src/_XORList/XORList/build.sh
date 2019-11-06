#!/usr/bin/env bash

print_done(){
    tput setaf 2;
    echo " DONE";
    tput sgr0;
}


CFLAGS=$(python-config --cflags);
LDFLAGS=$(python-config --ldflags);
echo -n "Transpiling to linked_list.c";
cython linked_list.pyx -3; # --> outputs linked_list.c
print_done;
echo -n "Compiling linked_list.c to object code";
gcc -c linked_list.c ${CFLAGS}; # outputs linked_list.o
print_done;
echo -n "Creating shared object";
gcc linked_list.o -o linked_list.so -shared ${LDFLAGS} -fPIC; # --> outputs fib.so
print_done;
