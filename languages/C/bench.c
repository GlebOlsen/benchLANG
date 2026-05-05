#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define PRIMES_LIMIT     20000000
#define FIBONACCI_N      45
#define STRING_ITER      5000000
#define MANDEL_W         4096
#define MANDEL_H         4096
#define MANDEL_MAX_ITER  256
#define TREE_MIN_DEPTH   4
#define TREE_MAX_DEPTH   18
#define SENTENCE         "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"

static struct timespec now(void) { struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t); return t; }
static double tdiff(struct timespec a, struct timespec b) {
    return (b.tv_sec - a.tv_sec) + (b.tv_nsec - a.tv_nsec) / 1e9;
}

static int is_prime(int n) {
    if (n <= 1) return 0;
    if (n <= 3) return 1;
    if (n % 2 == 0 || n % 3 == 0) return 0;
    for (int i = 5; i * i <= n; i += 6)
        if (n % i == 0 || n % (i + 2) == 0) return 0;
    return 1;
}
static void bench_primes(void) {
    struct timespec s = now();
    int count = 0;
    for (int i = 2; i < PRIMES_LIMIT; i++) if (is_prime(i)) count++;
    printf("Found %d primes in %.3f seconds\n\n", count, tdiff(s, now()));
}

static long long fib(int n) { return n <= 1 ? n : fib(n - 1) + fib(n - 2); }
static void bench_fib_recursive(void) {
    struct timespec s = now();
    long long r = fib(FIBONACCI_N);
    printf("Fibonacci(%d) = %lld in %.3f seconds\n\n", FIBONACCI_N, r, tdiff(s, now()));
}

static void bench_strings(void) {
    struct timespec s = now();
    char buf[256];
    strcpy(buf, SENTENCE);
    char *words[32];
    size_t wlen[32];
    int wcount = 0;
    char *tok = strtok(buf, " ");
    while (tok != NULL) {
        words[wcount] = tok;
        wlen[wcount] = strlen(tok);
        wcount++;
        tok = strtok(NULL, " ");
    }
    unsigned long long total = 0;
    for (int iter = 0; iter < STRING_ITER; iter++) {
        for (int i = 0; i < wcount; i++) {
            unsigned long long count = 0;
            size_t li = wlen[i];
            const char *wi = words[i];
            for (int j = 0; j < wcount; j++) {
                if (li == wlen[j] && memcmp(wi, words[j], li) == 0) count++;
            }
            total += count;
        }
    }
    printf("Strings: total=%llu in %.3f seconds\n\n", total, tdiff(s, now()));
}

static void bench_mandelbrot(void) {
    struct timespec s = now();
    long long checksum = 0;
    for (int py = 0; py < MANDEL_H; py++) {
        double cy = ((double)py / (double)MANDEL_H) * 3.0 - 1.5;
        for (int px = 0; px < MANDEL_W; px++) {
            double cx = ((double)px / (double)MANDEL_W) * 3.0 - 2.0;
            double zx = 0.0, zy = 0.0;
            int iter = 0;
            while (iter < MANDEL_MAX_ITER && zx * zx + zy * zy <= 4.0) {
                double nx = zx * zx - zy * zy + cx;
                zy = 2.0 * zx * zy + cy;
                zx = nx;
                iter++;
            }
            checksum += (long long)iter;
        }
    }
    printf("Mandelbrot: checksum=%lld in %.3f seconds\n\n", checksum, tdiff(s, now()));
}

typedef struct Node {
    struct Node *left, *right;
    long long item;
} Node;

static Node *make_tree(long long item, int depth) {
    Node *n = malloc(sizeof(Node));
    n->item = item;
    if (depth == 0) {
        n->left = NULL;
        n->right = NULL;
        return n;
    }
    n->left = make_tree(2 * item - 1, depth - 1);
    n->right = make_tree(2 * item, depth - 1);
    return n;
}

static long long item_check(Node *n) {
    if (n->left == NULL) return n->item;
    return n->item + item_check(n->left) - item_check(n->right);
}

static void free_tree(Node *n) {
    if (n->left != NULL) {
        free_tree(n->left);
        free_tree(n->right);
    }
    free(n);
}

static void bench_binary_trees(void) {
    struct timespec s = now();
    long long checksum = 0;

    {
        Node *stretch = make_tree(0, TREE_MAX_DEPTH + 1);
        checksum += item_check(stretch);
        free_tree(stretch);
    }

    Node *long_lived = make_tree(0, TREE_MAX_DEPTH);

    for (int d = TREE_MIN_DEPTH; d <= TREE_MAX_DEPTH; d += 2) {
        int iters = 1 << (TREE_MAX_DEPTH - d + TREE_MIN_DEPTH);
        long long sum = 0;
        for (int i = 0; i < iters; i++) {
            Node *t = make_tree((long long)(i + 1), d);
            sum += item_check(t);
            free_tree(t);
        }
        checksum += sum;
    }

    checksum += item_check(long_lived);
    free_tree(long_lived);

    printf("BinaryTrees: checksum=%lld in %.3f seconds\n\n", checksum, tdiff(s, now()));
}

int main(void) {
    printf("=== PROGRAMMING LANGUAGE BENCHMARK ===\n\n");
    struct timespec s = now();
    bench_primes();
    bench_fib_recursive();
    bench_strings();
    bench_mandelbrot();
    bench_binary_trees();
    printf("=== BENCHMARK COMPLETE ===\n");
    printf("Total execution time: %.3f seconds\n", tdiff(s, now()));
    return 0;
}
