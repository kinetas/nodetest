#!/bin/bash
set -e

echo "[*] Building BPF..."
make clean && make

echo "[*] Loading BPF (no pin)..."
bpftool prog load trace_connect.o - type tracepoint
bpftool prog attach tracepoint syscalls:sys_enter_connect id $(bpftool prog list | grep tracepoint | awk '{print $1}' | cut -d: -f1 | tail -n 1)

echo "[*] Tailing logs (Press Ctrl+C to exit)"
cat /sys/kernel/debug/tracing/trace_pipe