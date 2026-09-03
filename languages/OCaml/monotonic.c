#include <time.h>
#include <caml/mlvalues.h>
#include <caml/alloc.h>

value bench_now(value unit) {
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return caml_copy_double(t.tv_sec + t.tv_nsec / 1e9);
}
