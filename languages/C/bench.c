#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

#define PRIMES_LIMIT 20000000
#define FIBONACCI_N 45
#define SENTENCE "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"

double get_time_diff(clock_t start, clock_t end);
int is_prime(int n);
void benchmark_primes();
int fib(int n);
void benchmark_fibonacci();
void benchmark_strings();

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

void benchmark_strings() {
    printf("Running String Benchmark...\n");
    clock_t start = clock();
    
    // Split sentence into words
    char sentence_copy[256];
    strcpy(sentence_copy, SENTENCE);
    char *words[50];
    int words_count = 0;
    
    char *token = strtok(sentence_copy, " ");
    while (token != NULL) {
        words[words_count++] = token;
        token = strtok(NULL, " ");
    }
    
    long long match_count = 0;
    long long reverse_count = 0;
    
    for (int i = 0; i < PRIMES_LIMIT; i++) {
        char *current_word = words[i % words_count];
        
        // Compare current word against all other words
        for (int j = 0; j < words_count; j++) {
            if (strcmp(current_word, words[j]) == 0) {
                match_count++;
            }
        }
        
        // Extract and reverse each word from sentence
        char current_chars[100];
        int char_idx = 0;
        for (int k = 0; SENTENCE[k] != '\0'; k++) {
            if (SENTENCE[k] == ' ') {
                if (char_idx > 0) {
                    // Reverse the word
                    for (int rev = 0; rev < char_idx; rev++) {
                        char temp = current_chars[char_idx - 1 - rev];
                        (void)temp; // Use temp to prevent optimization
                    }
                    reverse_count += char_idx;
                    char_idx = 0;
                }
            } else {
                current_chars[char_idx++] = SENTENCE[k];
            }
        }
        // Handle last word
        if (char_idx > 0) {
            for (int rev = 0; rev < char_idx; rev++) {
                char temp = current_chars[char_idx - 1 - rev];
                (void)temp;
            }
            reverse_count += char_idx;
        }
    }
    
    clock_t end = clock();
    printf("Matches: %lld, reverse char count: %lld in %.3f seconds\n\n", match_count, reverse_count, get_time_diff(start, end));
}

int main() {
    printf("=== PROGRAMMING LANGUAGE BENCHMARK ===\n\n");

    clock_t total_start = clock();

    benchmark_primes();
    benchmark_fibonacci();
    benchmark_strings();

    clock_t total_end = clock();

    printf("=== BENCHMARK COMPLETE ===\n");
    printf("Total execution time: %.3f seconds\n", get_time_diff(total_start, total_end));

    return 0;
}
