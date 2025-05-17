#include "vmlinux.h"
#include <bpf/bpf_helpers.h>

SEC("tracepoint/syscalls/sys_enter_connect")
int trace_connect(struct trace_event_raw_sys_enter* ctx) {
    bpf_printk("🛡️ connect() syscall: pid=%d, fd=%d\n", bpf_get_current_pid_tgid() >> 32, ctx->args[0]);
    return 0;
}

char LICENSE[] SEC("license") = "GPL";