BPF_CFLAGS = -O2 -g -Wall -target bpf -D__TARGET_ARCH_x86

all:
	clang $(BPF_CFLAGS) -I. -c trace_connect.c -o trace_connect.o

clean:
	rm -f *.o