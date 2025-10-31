#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define PRIMES_LIMIT 20000000
#define FIBONACCI_N 45

double get_time_diff(clock_t start, clock_t end);
int is_prime(int n);
void benchmark_primes();
int fib(int n);
void benchmark_fibonacci();

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

int main() {
    printf("=== PROGRAMMING LANGUAGE BENCHMARK ===\n\n");

    clock_t total_start = clock();

    benchmark_primes();
    benchmark_fibonacci();

    clock_t total_end = clock();

    printf("=== BENCHMARK COMPLETE ===\n");
    printf("Total execution time: %.3f seconds\n", get_time_diff(total_start, total_end));

    return 0;
}
