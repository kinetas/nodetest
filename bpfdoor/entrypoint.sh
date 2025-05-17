#!/bin/bash
set -e

echo "[*] Building BPF..."
make clean && make

echo "[*] Loading & Attaching BPF program without pinning..."
# 이 명령은 pin 없이 메모리 attach + prog id 얻기
bpftool prog loadall trace_connect.o /sys/fs/bpf_tmp type tracepoint || true

prog_id=$(bpftool prog list | grep tracepoint | grep trace_connect | awk '{print $1}' | cut -d':' -f1 | tail -n 1)

echo "[*] Attaching to tracepoint with prog ID: $prog_id"
bpftool prog attach id "$prog_id" tracepoint syscalls:sys_enter_connect

echo "[*] BPF program successfully attached!"
echo "[*] Tailing logs (Press Ctrl+C to exit)"
cat /sys/kernel/debug/tracing/trace_pipe