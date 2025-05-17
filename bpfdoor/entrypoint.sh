#!/bin/bash

# 마운트 확인
mount -t debugfs none /sys/kernel/debug || true
mount -t bpffs bpffs /sys/fs/bpf || true

echo "[*] Building BPF..."
make clean && make

echo "[*] Loading BPF..."
$BPFTOOL prog load trace_connect.o /sys/fs/bpf/trace_connect type tracepoint
$BPFTOOL prog attach name trace_connect tracepoint syscalls:sys_enter_connect

echo "[*] Tailing logs (Press Ctrl+C to exit)"
cat /sys/kernel/debug/tracing/trace_pipe