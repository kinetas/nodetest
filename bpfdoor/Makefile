BPF_CFLAGS = -O2 -g -Wall -target bpf -D__TARGET_ARCH_x86

all: trace_connect.o loader

trace_connect.o: trace_connect.c vmlinux.h
	clang $(BPF_CFLAGS) -I. -c trace_connect.c -o trace_connect.o

loader: loader.c
	clang -g -Wall -o loader loader.c -lbpf -lelf -lz

clean:
	rm -f trace_connect.o loader