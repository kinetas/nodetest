FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    clang llvm gcc make libbpf-dev iproute2 \
    bpfcc-tools bpftrace \
    linux-headers-generic \
    linux-tools-generic \
    linux-tools-$(uname -r)

WORKDIR /app

COPY trace_connect.c .
COPY Makefile .
COPY entrypoint.sh .

RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]