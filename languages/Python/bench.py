import time

PRIMES_LIMIT = 20_000_000
FIBONACCI_N = 45

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

def main():
    print("=== PROGRAMMING LANGUAGE BENCHMARK ===\n")
    total = time.time()
    benchmark_primes()
    benchmark_fibonacci()
    print("=== BENCHMARK COMPLETE ===")
    print(f"Total execution time: {time.time()-total:.3f} seconds")

if __name__ == "__main__":
    main()
