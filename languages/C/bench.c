#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

constexpr int PRIMES_LIMIT    = 8000000;
constexpr int FIBONACCI_N     = 43;
constexpr int STRING_ITER     = 1200000;
constexpr int MANDEL_SIZE     = 2048;
constexpr int MANDEL_MAX_ITER = 256;
constexpr int TREE_MIN_DEPTH  = 4;
constexpr int TREE_MAX_DEPTH  = 17;
constexpr int MAX_WORDS       = 32;
constexpr char SENTENCE[] =
    "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";
constexpr int KNUC_LENGTH     = 6000000;
constexpr int KNUC_SEED       = 42;
constexpr int KNUC_IM         = 139968;
constexpr int KNUC_IA         = 3877;
constexpr int KNUC_IC         = 29573;
constexpr char KNUC_QUERY[] = "GGTATTTTAATTTATAGT";

static double now() {
    struct timespec t;
    timespec_get(&t, TIME_MONOTONIC);
    return t.tv_sec + t.tv_nsec / 1e9;
}

static void report(const char *name, long long checksum, double secs) {
    printf("%s %lld %.3f\n", name, checksum, secs);
}

static bool is_prime(int n) {
    if (n < 2) return false;
    if (n < 4) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    for (int i = 5; i * i <= n; i += 6)
        if (n % i == 0 || n % (i + 2) == 0) return false;
    return true;
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
    char *cbuf = strdup(sentence);
    const char *words[MAX_WORDS];
    char *cur[MAX_WORDS];
    size_t wlen[MAX_WORDS];
    int wcount = 0;
    for (char *tok = strtok(buf, " "); tok && wcount < MAX_WORDS; tok = strtok(nullptr, " ")) {
        words[wcount] = tok;
        cur[wcount] = cbuf + (tok - buf);
        wlen[wcount] = strlen(tok);
        wcount++;
    }
    long long total = 0;
    for (int it = 0; it < iters; it++) {
        int k = it % wcount;
        for (char *p = cur[k], *q = cur[k] + wlen[k] - 1; p < q; p++, q--) {
            char c = *p;
            *p = *q;
            *q = c;
        }
        for (int i = 0; i < wcount; i++)
            for (int j = 0; j < wcount; j++)
                if (wlen[i] == wlen[j] && memcmp(cur[i], words[j], wlen[i]) == 0) total++;
    }
    free(cbuf);
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
    if (depth == 0) { n->left = n->right = nullptr; return n; }
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

typedef struct { const char *key; int count; } KEntry;
typedef struct { KEntry *slots; size_t cap, used; int k; } KTable;

static uint32_t fnv1a(const char *s, int k) {
    uint32_t h = 2166136261u;
    for (int i = 0; i < k; i++) { h ^= (unsigned char)s[i]; h *= 16777619u; }
    return h;
}

static size_t ktable_probe(const KEntry *slots, size_t cap, const char *key, int k) {
    size_t j = fnv1a(key, k) & (cap - 1);
    while (slots[j].key && memcmp(slots[j].key, key, k) != 0) j = (j + 1) & (cap - 1);
    return j;
}

static void ktable_grow(KTable *t) {
    size_t cap = t->cap * 2;
    KEntry *slots = calloc(cap, sizeof(KEntry));
    for (size_t i = 0; i < t->cap; i++)
        if (t->slots[i].key) slots[ktable_probe(slots, cap, t->slots[i].key, t->k)] = t->slots[i];
    free(t->slots);
    t->slots = slots;
    t->cap = cap;
}

static KEntry *ktable_get(KTable *t, const char *key) {
    size_t j = ktable_probe(t->slots, t->cap, key, t->k);
    if (t->slots[j].key) return &t->slots[j];
    if ((t->used + 1) * 2 > t->cap) {
        ktable_grow(t);
        j = ktable_probe(t->slots, t->cap, key, t->k);
    }
    t->slots[j].key = key;
    t->used++;
    return &t->slots[j];
}

static int kmer_k;

static int kentry_cmp(const void *a, const void *b) {
    const KEntry *x = a, *y = b;
    if (x->count != y->count) return x->count < y->count ? 1 : -1;
    return memcmp(x->key, y->key, kmer_k);
}

static long long bench_knucleotide(int length) {
    static const int ks[] = {1, 2, 3, 4, 6, 12, 18};
    char *seq = malloc(length);
    int seed = KNUC_SEED;
    for (int i = 0; i < length; i++) {
        seed = (seed * KNUC_IA + KNUC_IC) % KNUC_IM;
        seq[i] = seed < 42404 ? 'A' : seed < 70116 ? 'C' : seed < 97766 ? 'G' : 'T';
    }
    long long checksum = 0;
    for (size_t ki = 0; ki < sizeof ks / sizeof ks[0]; ki++) {
        int k = ks[ki];
        KTable t = { calloc(16, sizeof(KEntry)), 16, 0, k };
        for (int i = 0; i + k <= length; i++) ktable_get(&t, seq + i)->count++;
        checksum += t.used;
        if (k <= 2) {
            KEntry *e = malloc(t.used * sizeof(KEntry));
            size_t n = 0;
            for (size_t i = 0; i < t.cap; i++) if (t.slots[i].key) e[n++] = t.slots[i];
            kmer_k = k;
            qsort(e, n, sizeof(KEntry), kentry_cmp);
            for (size_t r = 0; r < n; r++) checksum += (long long)(r + 1) * e[r].count;
            free(e);
        } else {
            KEntry *q = &t.slots[ktable_probe(t.slots, t.cap, KNUC_QUERY, k)];
            if (q->key) checksum += q->count;
        }
        free(t.slots);
    }
    free(seq);
    return checksum;
}

int main() {
    double t;
    long long r;
    t = now(); r = bench_primes(PRIMES_LIMIT);          report("primes", r, now() - t);
    t = now(); r = fib(FIBONACCI_N);                     report("fib", r, now() - t);
    t = now(); r = bench_strings(SENTENCE, STRING_ITER); report("strings", r, now() - t);
    t = now(); r = bench_mandelbrot(MANDEL_SIZE);        report("mandelbrot", r, now() - t);
    t = now(); r = bench_binary_trees(TREE_MAX_DEPTH);   report("binarytrees", r, now() - t);
    t = now(); r = bench_knucleotide(KNUC_LENGTH);       report("knucleotide", r, now() - t);
    return 0;
}
