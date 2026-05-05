import time
import sys

PRIMES_LIMIT = 20_000_000
FIBONACCI_N = 45
STRING_ITER = 5_000_000
MANDEL_W = 4096
MANDEL_H = 4096
MANDEL_MAX_ITER = 256
TREE_MIN_DEPTH = 4
TREE_MAX_DEPTH = 18
SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"


def is_prime(n):
    if n <= 1: return False
    if n <= 3: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def bench_primes():
    s = time.perf_counter()
    count = 0
    for i in range(2, PRIMES_LIMIT):
        if is_prime(i): count += 1
    print(f"Found {count} primes in {time.perf_counter()-s:.3f} seconds\n")

sys.setrecursionlimit(200)
def fib(n):
    if n <= 1: return n
    return fib(n-1) + fib(n-2)

def bench_fib_recursive():
    s = time.perf_counter()
    r = fib(FIBONACCI_N)
    print(f"Fibonacci({FIBONACCI_N}) = {r} in {time.perf_counter()-s:.3f} seconds\n")

def bench_strings():
    s = time.perf_counter()
    words = SENTENCE.split(' ')
    wcount = len(words)
    total = 0
    for _ in range(STRING_ITER):
        for i in range(wcount):
            count = 0
            wi = words[i]
            for j in range(wcount):
                if wi == words[j]: count += 1
            total += count
    print(f"Strings: total={total} in {time.perf_counter()-s:.3f} seconds\n")

def bench_mandelbrot():
    s = time.perf_counter()
    checksum = 0
    for py in range(MANDEL_H):
        cy = (py / MANDEL_H) * 3.0 - 1.5
        for px in range(MANDEL_W):
            cx = (px / MANDEL_W) * 3.0 - 2.0
            zx = 0.0
            zy = 0.0
            it = 0
            while it < MANDEL_MAX_ITER and zx * zx + zy * zy <= 4.0:
                nx = zx * zx - zy * zy + cx
                zy = 2.0 * zx * zy + cy
                zx = nx
                it += 1
            checksum += it
    print(f"Mandelbrot: checksum={checksum} in {time.perf_counter()-s:.3f} seconds\n")

class Node:
    __slots__ = ('left', 'right', 'item')
    def __init__(self, left, right, item):
        self.left = left
        self.right = right
        self.item = item

def make_tree(item, depth):
    if depth == 0:
        return Node(None, None, item)
    return Node(make_tree(2 * item - 1, depth - 1), make_tree(2 * item, depth - 1), item)

def check_tree(n):
    if n.left is None:
        return n.item
    return n.item + check_tree(n.left) - check_tree(n.right)

def bench_binary_trees():
    s = time.perf_counter()
    checksum = 0

    stretch = make_tree(0, TREE_MAX_DEPTH + 1)
    checksum += check_tree(stretch)
    stretch = None

    long_lived = make_tree(0, TREE_MAX_DEPTH)

    d = TREE_MIN_DEPTH
    while d <= TREE_MAX_DEPTH:
        iters = 1 << (TREE_MAX_DEPTH - d + TREE_MIN_DEPTH)
        sub = 0
        for i in range(iters):
            t = make_tree(i + 1, d)
            sub += check_tree(t)
        checksum += sub
        d += 2

    checksum += check_tree(long_lived)

    print(f"BinaryTrees: checksum={checksum} in {time.perf_counter()-s:.3f} seconds\n")

def main():
    print("=== PROGRAMMING LANGUAGE BENCHMARK ===\n")
    s = time.perf_counter()
    bench_primes()
    bench_fib_recursive()
    bench_strings()
    bench_mandelbrot()
    bench_binary_trees()
    print("=== BENCHMARK COMPLETE ===")
    print(f"Total execution time: {time.perf_counter()-s:.3f} seconds")

if __name__ == "__main__":
    main()
