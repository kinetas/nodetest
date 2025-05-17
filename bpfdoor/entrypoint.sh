#!/bin/bash
set -e

echo "[*] Building BPF..."
make clean && make

echo "[*] Loading BPF (attach only)..."
bpftool prog load trace_connect.o - type tracepoint name trace_connect
bpftool prog attach name trace_connect tracepoint syscalls:sys_enter_connect

echo "[*] Tailing logs (Press Ctrl+C to exit)"
cat /sys/kernel/debug/tracing/trace_pipe