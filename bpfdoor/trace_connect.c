#include <linux/ptrace.h>
#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>

SEC("tracepoint/syscalls/sys_enter_connect")
int trace_connect(struct trace_event_raw_sys_enter* ctx) {
    bpf_printk("🛡️ Connect syscall detected!\n");
    return 0;
}

char LICENSE[] SEC("license") = "GPL";