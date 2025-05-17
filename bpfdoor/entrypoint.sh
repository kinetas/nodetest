#!/bin/bash
set -e

echo "[*] Building BPF..."
make clean && make

echo "[*] Loading BPF (attach only)..."
bpftool prog load trace_connect.o /sys/fs/bpf/trace_connect type tracepoint
bpftool prog attach /sys/fs/bpf/trace_connect tracepoint syscalls:sys_enter_connect

echo "[*] Tailing logs (Press Ctrl+C to exit)"
cat /sys/kernel/debug/tracing/trace_pipe