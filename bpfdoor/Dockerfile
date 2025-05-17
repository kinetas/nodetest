FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    clang llvm libbpf-dev gcc make iproute2 \
    linux-headers-$(uname -r) \
    bpfcc-tools bpftrace \
    git curl vim net-tools

WORKDIR /app

COPY trace_connect.c .
COPY Makefile .
COPY entrypoint.sh .

RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]