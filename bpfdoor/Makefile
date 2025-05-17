BPFTOOL ?= bpftool

all:
	clang -O2 -g -target bpf -c trace_connect.c -o trace_connect.o

clean:
	rm -f *.o