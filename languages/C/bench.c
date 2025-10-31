#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define PRIMES_LIMIT 20000000

#define FIBONACCI_N 45

#define MATRIX_SIZE 2000
#define MATRIX_RAND_MAX 100

#define SENTENCE "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"
#define STRING_OPS 200000000
#define STRING_REDUCTION_FACTOR 100

#define SORT_SIZE 10000000
#define RAND_SEED 42


double get_time_diff(clock_t start, clock_t end);
int is_prime(int n);
void benchmark_primes();
int fib(int n);
void benchmark_fibonacci();
void benchmark_matrix_multiplication();
void benchmark_string_operations();
void benchmark_sorting();

double get_time_diff(clock_t start, clock_t end) {
    return ((double)(end - start)) / CLOCKS_PER_SEC;
}

int is_prime(int n) {
    if (n <= 1)
        return 0;
    if (n <= 3)
        return 1;
    if (n % 2 == 0 || n % 3 == 0)
        return 0;
    int i = 5;
    while (i * i <= n) {
        if (n % i == 0 || n % (i + 2) == 0)
            return 0;
        i += 6;
    }
    return 1;
}

void benchmark_primes() {
    printf("Running Prime Numbers Benchmark (up to %d)...\n", PRIMES_LIMIT);
    clock_t start = clock();

    int prime_count = 0;
    for (int i = 2; i < PRIMES_LIMIT; i++) {
        if (is_prime(i)) {
            prime_count++;
        }
    }
    clock_t end = clock();

    printf("Found %d primes in %.3f seconds\n\n", prime_count, get_time_diff(start, end));
}

int fib(int n) {
    if (n <= 1) {
        return n;
    }
    return fib(n-1) + fib(n-2);
}

void benchmark_fibonacci() {
    printf("Running Fibonacci Benchmark (n=%d, recursive)...\n", FIBONACCI_N);
    clock_t start = clock();

    int result = fib(FIBONACCI_N);

    clock_t end = clock();
    printf("Fibonacci(%d) = %d in %.3f seconds\n\n", FIBONACCI_N, result, get_time_diff(start, end));
}

static double matrix_a[MATRIX_SIZE * MATRIX_SIZE];
static double matrix_b[MATRIX_SIZE * MATRIX_SIZE];
static double matrix_c[MATRIX_SIZE * MATRIX_SIZE];


void benchmark_matrix_multiplication() {
    printf("Running Matrix Multiplication Benchmark (%dx%d)...\n", MATRIX_SIZE, MATRIX_SIZE);
    clock_t start = clock();

    const size_t n = MATRIX_SIZE;
    const size_t elems = n * n;

    for (size_t i = 0; i < elems; i++) {
        matrix_a[i] = rand() % MATRIX_RAND_MAX;
        matrix_b[i] = rand() % MATRIX_RAND_MAX;
        matrix_c[i] = 0.0;
    }

    for (size_t i = 0; i < n; i++) {
        size_t in = i * n;
        for (size_t k = 0; k < n; k++) {
            double aik = matrix_a[in + k];
            size_t kn = k * n;
            for (size_t j = 0; j < n; j++) {
                matrix_c[in + j] += aik * matrix_b[kn + j];
            }
        }
    }

    clock_t end = clock();
    printf("Matrix multiplication completed in %.3f seconds\n\n", get_time_diff(start, end));
}

static int sort_array[SORT_SIZE];

static int int_cmp(const void *a, const void *b) {
    int ia = *(const int*)a, ib = *(const int*)b;
    return (ia > ib) - (ia < ib);
}

void benchmark_sorting() {
    printf("Running Sorting Benchmark (%d elements)...\n", SORT_SIZE);
    clock_t start = clock();

    for (int i = 0; i < SORT_SIZE; i++) {
        sort_array[i] = rand();
    }

    qsort(sort_array, SORT_SIZE, sizeof *sort_array, int_cmp);

    clock_t end = clock();
    printf("Sorting completed in %.3f seconds\n\n", get_time_diff(start, end));
}

void benchmark_string_operations() {
    printf("Running String Operations Benchmark (%d operations)...\n", STRING_OPS);
    clock_t start = clock();

    const char *sentence = SENTENCE;
    size_t sentence_len = strlen(sentence);
    size_t repeats = STRING_OPS / STRING_REDUCTION_FACTOR;
    size_t total_len = sentence_len * repeats;

    char *buffer = (char*)malloc(total_len + 1);
    if (!buffer) { fprintf(stderr, "Allocation failed\n"); exit(1); }

    char *write = buffer;
    for (size_t i = 0; i < repeats; i++) {
        memcpy(write, sentence, sentence_len);
        write += sentence_len;
    }
    *write = '\0';

    char *sentence_copy = strdup(sentence);
    if (!sentence_copy) { fprintf(stderr, "Allocation failed\n"); exit(1); }

    int total_found = 0;
    char *saveptr = NULL;
    for (char *word = strtok_r(sentence_copy, " ", &saveptr); word; word = strtok_r(NULL, " ", &saveptr)) {
        size_t wlen = strlen(word);
        if (wlen == 0 || wlen > total_len) continue;
        int found_count = 0;
        const char *pos = buffer;
        while ((pos = strstr(pos, word)) != NULL) {
            found_count++;
            pos++;
        }
        total_found += found_count;
    }

    free(sentence_copy);
    free(buffer);

    clock_t end = clock();
    printf("String operations completed in %.3f seconds (found %d word instances)\n\n",
           get_time_diff(start, end), total_found);
}

int main() {
    printf("=== COMPREHENSIVE PROGRAMMING LANGUAGE BENCHMARK ===\n\n");

    srand(RAND_SEED);

    clock_t total_start = clock();

    benchmark_primes();
    benchmark_fibonacci();
    benchmark_matrix_multiplication();
    benchmark_sorting();
    benchmark_string_operations();

    clock_t total_end = clock();

    printf("=== BENCHMARK COMPLETE ===\n");
    printf("Total execution time: %.3f seconds\n", get_time_diff(total_start, total_end));

    return 0;
}