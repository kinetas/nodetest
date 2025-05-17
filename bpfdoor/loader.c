// loader.c
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
    int err;

    signal(SIGINT, handle_signal);
    signal(SIGTERM, handle_signal);

    // BPF object load
    obj = bpf_object__open_file("trace_connect.o", NULL);
    if (libbpf_get_error(obj)) {
        fprintf(stderr, "Failed to open BPF object\n");
        return 1;
    }

    err = bpf_object__load(obj);
    if (err) {
        fprintf(stderr, "Failed to load BPF object\n");
        return 1;
    }

    // Auto-attach all programs (tracepoint 등)
    err = bpf_object__attach(obj);
    if (err) {
        fprintf(stderr, "Failed to attach BPF programs\n");
        return 1;
    }

    printf("✅ BPF program loaded and attached! Press Ctrl+C to stop.\n");

    while (!exiting) {
        sleep(1);
    }

    bpf_object__close(obj);
    return 0;
}
