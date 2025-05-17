#!/bin/bash
set -e

echo "[*] Building BPF..."
make clean && make

echo "[*] Loading BPF (no pin)..."
# load only (no pin)
prog_id=$(bpftool prog load trace_connect.o type tracepoint | grep -oP 'prog \K[0-9]+')

# attach using prog ID
bpftool prog attach id "$prog_id" tracepoint syscalls:sys_enter_connect

echo "[*] Tailing logs (Press Ctrl+C to exit)"
cat /sys/kernel/debug/tracing/trace_pipe