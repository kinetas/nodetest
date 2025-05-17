#!/bin/bash
set -e

echo "[*] Building BPF..."
make clean && make

echo "[*] Loading BPF program without pinning..."
# Load the program and capture its ID
bpftool prog load trace_connect.o /dev/null type tracepoint
prog_id=$(bpftool prog list | grep trace_connect | awk '{print $1}' | cut -d':' -f1 | tail -n 1)

echo "[*] Attaching to tracepoint with prog ID: $prog_id"
bpftool prog attach id "$prog_id" tracepoint syscalls:sys_enter_connect

echo "[*] BPF program successfully attached!"
echo "[*] Tailing logs (Press Ctrl+C to exit)"
cat /sys/kernel/debug/tracing/trace_pipe