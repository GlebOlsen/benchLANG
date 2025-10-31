import time, random

PRIMES_LIMIT = 20_000_000
FIBONACCI_N = 45
MATRIX_SIZE = 2000
MATRIX_RAND_MAX = 100
SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"
STRING_OPS = 200_000_000
STRING_REDUCTION_FACTOR = 100
SORT_SIZE = 10_000_000
RAND_SEED = 42

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

def benchmark_matrix_multiplication():
    print(f"Running Matrix Multiplication Benchmark ({MATRIX_SIZE}x{MATRIX_SIZE})...")
    start = time.time()
    random.seed(RAND_SEED)
    n = MATRIX_SIZE
    size = n * n
    # Flat lists for speed / lower overhead
    a = [random.randrange(MATRIX_RAND_MAX) for _ in range(size)]
    b = [random.randrange(MATRIX_RAND_MAX) for _ in range(size)]
    c = [0.0] * size
    for i in range(n):
        in_idx = i * n
        for k in range(n):
            aik = a[in_idx + k]
            kn_idx = k * n
            row_offset = in_idx
            b_offset = kn_idx
            for j in range(n):
                c[row_offset + j] += aik * b[b_offset + j]
    print(f"Matrix multiplication completed in {time.time()-start:.3f} seconds\n")

def benchmark_sorting():
    print(f"Running Sorting Benchmark ({SORT_SIZE} elements)...")
    start = time.time()
    random.seed(RAND_SEED)
    arr = [random.randrange(1<<31) for _ in range(SORT_SIZE)]
    arr.sort()
    print(f"Sorting completed in {time.time()-start:.3f} seconds\n")

def benchmark_string_operations():
    print(f"Running String Operations Benchmark ({STRING_OPS} operations)...")
    start = time.time()
    repeats = STRING_OPS // STRING_REDUCTION_FACTOR
    # Build via list join to avoid quadratic concatenation
    pieces = [SENTENCE] * repeats
    hay = ''.join(pieces)
    words = SENTENCE.split(' ')
    total = 0
    for w in words:
        wl = len(w)
        if wl == 0 or wl > len(hay):
            continue
        # Manual scan (O(n*m)) to mimic C's strstr counting logic
        found = 0
        for i in range(0, len(hay) - wl + 1):
            if hay[i:i+wl] == w:
                found += 1
        total += found
    print(f"String operations completed in {time.time()-start:.3f} seconds (found {total} word instances)\n")

def main():
    print("=== COMPREHENSIVE PROGRAMMING LANGUAGE BENCHMARK ===\n")
    total = time.time()
    benchmark_primes()
    benchmark_fibonacci()
    benchmark_matrix_multiplication()
    benchmark_sorting()
    benchmark_string_operations()
    print("=== BENCHMARK COMPLETE ===")
    print(f"Total execution time: {time.time()-total:.3f} seconds")

if __name__ == "__main__":
    main()
