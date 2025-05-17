#include <stdio.h>
#include <stdlib.h>
#include <bpf/libbpf.h>
#include <unistd.h>
#include <signal.h>

static bool exiting = false;

void handle_signal(int sig) {
    exiting = true;
}

int main() {
    struct bpf_object *obj;
    struct bpf_program *prog;
    struct bpf_link *link = NULL;
    int err;

    signal(SIGINT, handle_signal);
    signal(SIGTERM, handle_signal);

    obj = bpf_object__open_file("trace_connect.o", NULL);
    if (libbpf_get_error(obj)) {
        fprintf(stderr, "❌ Failed to open BPF object\n");
        return 1;
    }

    err = bpf_object__load(obj);
    if (err) {
        fprintf(stderr, "❌ Failed to load BPF object\n");
        return 1;
    }

    prog = bpf_object__find_program_by_name(obj, "trace_connect");
    if (!prog) {
        fprintf(stderr, "❌ Failed to find BPF program\n");
        return 1;
    }

    link = bpf_program__attach_tracepoint(prog, "syscalls", "sys_enter_connect");
    if (libbpf_get_error(link)) {
        fprintf(stderr, "❌ Failed to attach tracepoint\n");
        return 1;
    }

    printf("✅ BPF program loaded and attached! Press Ctrl+C to stop.\n");

    while (!exiting) {
        sleep(1);
    }

    bpf_link__destroy(link);
    bpf_object__close(obj);
    return 0;
}