import time

PRIMES_LIMIT = 20_000_000
FIBONACCI_N = 45
SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"

def is_prime(n: int) -> bool:
    if n <= 1: return False
    if n <= 3: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True

def benchmark_primes():
    print(f"Running Prime Numbers Benchmark (up to {PRIMES_LIMIT})...")
    start = time.time()
    count = sum(1 for i in range(2, PRIMES_LIMIT) if is_prime(i))
    print(f"Found {count} primes in {time.time()-start:.3f} seconds\n")

def fib(n: int) -> int:
    if n <= 1: return n
    return fib(n-1) + fib(n-2)

def benchmark_fibonacci():
    print(f"Running Fibonacci Benchmark (n={FIBONACCI_N}, recursive)...")
    start = time.time()
    result = fib(FIBONACCI_N)
    print(f"Fibonacci({FIBONACCI_N}) = {result} in {time.time()-start:.3f} seconds\n")

def benchmark_strings():
    print(f"Running String Benchmark...")
    start = time.time()
    words = SENTENCE.split()
    words_count = len(words)
    match_count = 0
    reverse_count = 0
    
    for i in range(PRIMES_LIMIT):
        current_word = words[i % words_count]
        
        # Compare current word against all other words
        for other_word in words:
            if current_word == other_word:
                match_count += 1
        
        # Extract and reverse each word from sentence
        current_chars = ""
        for c in SENTENCE:
            if c == ' ':
                if len(current_chars) > 0:
                    reverse_word = current_chars[::-1]
                    reverse_count += len(reverse_word)
                    current_chars = ""
            else:
                current_chars += c
        # Handle last word
        if len(current_chars) > 0:
            reverse_word = current_chars[::-1]
            reverse_count += len(reverse_word)
    
    print(f"Matches: {match_count}, reverse char count: {reverse_count} in {time.time()-start:.3f} seconds\n")

def main():
    print("=== PROGRAMMING LANGUAGE BENCHMARK ===\n")
    total = time.time()
    benchmark_primes()
    benchmark_fibonacci()
    benchmark_strings()
    print("=== BENCHMARK COMPLETE ===")
    print(f"Total execution time: {time.time()-total:.3f} seconds")

if __name__ == "__main__":
    main()
