#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define PRIMES_LIMIT     20000000
#define FIBONACCI_N      45
#define STRING_ITER      5000000
#define MANDEL_SIZE      4096
#define MANDEL_MAX_ITER  256
#define TREE_MIN_DEPTH   4
#define TREE_MAX_DEPTH   18
#define MAX_WORDS        32
#define SENTENCE         "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"

static double now(void) {
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return t.tv_sec + t.tv_nsec / 1e9;
}

static void report(const char *name, long long checksum, double secs) {
    printf("%s %lld %.3f\n", name, checksum, secs);
}

static int is_prime(int n) {
    if (n < 2) return 0;
    if (n < 4) return 1;
    if (n % 2 == 0 || n % 3 == 0) return 0;
    for (int i = 5; i * i <= n; i += 6)
        if (n % i == 0 || n % (i + 2) == 0) return 0;
    return 1;
}

static long long bench_primes(int limit) {
    long long count = 0;
    for (int i = 2; i < limit; i++)
        if (is_prime(i)) count++;
    return count;
}

static long long fib(int n) { return n < 2 ? n : fib(n - 1) + fib(n - 2); }

static long long bench_strings(const char *sentence, int iters) {
    char *buf = strdup(sentence);
    const char *words[MAX_WORDS];
    size_t wlen[MAX_WORDS];
    int wcount = 0;
    for (char *tok = strtok(buf, " "); tok && wcount < MAX_WORDS; tok = strtok(NULL, " ")) {
        words[wcount] = tok;
        wlen[wcount] = strlen(tok);
        wcount++;
    }
    long long total = 0;
    for (int it = 0; it < iters; it++)
        for (int i = 0; i < wcount; i++)
            for (int j = 0; j < wcount; j++)
                if (wlen[i] == wlen[j] && memcmp(words[i], words[j], wlen[i]) == 0) total++;
    free(buf);
    return total;
}

static long long bench_mandelbrot(int size) {
    long long checksum = 0;
    for (int py = 0; py < size; py++) {
        double cy = (double)py / size * 3.0 - 1.5;
        for (int px = 0; px < size; px++) {
            double cx = (double)px / size * 3.0 - 2.0;
            double zx = 0.0, zy = 0.0;
            int iter = 0;
            while (iter < MANDEL_MAX_ITER && zx * zx + zy * zy <= 4.0) {
                double nx = zx * zx - zy * zy + cx;
                zy = 2.0 * zx * zy + cy;
                zx = nx;
                iter++;
            }
            checksum += iter;
        }
    }
    return checksum;
}

typedef struct Node { struct Node *left, *right; long long item; } Node;

static Node *make_tree(long long item, int depth) {
    Node *n = malloc(sizeof(Node));
    n->item = item;
    if (depth == 0) { n->left = n->right = NULL; return n; }
    n->left = make_tree(2 * item - 1, depth - 1);
    n->right = make_tree(2 * item, depth - 1);
    return n;
}

static long long check_tree(const Node *n) {
    if (!n->left) return n->item;
    return n->item + check_tree(n->left) - check_tree(n->right);
}

static void free_tree(Node *n) {
    if (n->left) { free_tree(n->left); free_tree(n->right); }
    free(n);
}

static long long bench_binary_trees(int max_depth) {
    long long checksum = 0;
    Node *stretch = make_tree(0, max_depth + 1);
    checksum += check_tree(stretch);
    free_tree(stretch);
    Node *long_lived = make_tree(0, max_depth);
    for (int d = TREE_MIN_DEPTH; d <= max_depth; d += 2) {
        int iters = 1 << (max_depth - d + TREE_MIN_DEPTH);
        for (int i = 0; i < iters; i++) {
            Node *t = make_tree(i + 1, d);
            checksum += check_tree(t);
            free_tree(t);
        }
    }
    checksum += check_tree(long_lived);
    free_tree(long_lived);
    return checksum;
}

int main(void) {
    double t;
    long long r;
    t = now(); r = bench_primes(PRIMES_LIMIT);          report("primes", r, now() - t);
    t = now(); r = fib(FIBONACCI_N);                     report("fib", r, now() - t);
    t = now(); r = bench_strings(SENTENCE, STRING_ITER); report("strings", r, now() - t);
    t = now(); r = bench_mandelbrot(MANDEL_SIZE);        report("mandelbrot", r, now() - t);
    t = now(); r = bench_binary_trees(TREE_MAX_DEPTH);   report("binarytrees", r, now() - t);
    return 0;
}
