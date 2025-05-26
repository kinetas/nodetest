#include "vmlinux.h"
#include <bpf/bpf_helpers.h>

char msg[] = "🛡️ execve() called!";

SEC("tracepoint/syscalls/sys_enter_execve")
int trace_execve(struct trace_event_raw_sys_enter* ctx) {
    bpf_trace_printk(msg, sizeof(msg));
    return 0;
}

char LICENSE[] SEC("license") = "GPL";