import time

PRIMES_LIMIT = 20_000_000
FIBONACCI_N = 45
STRING_ITER = 5_000_000
MANDEL_SIZE = 4096
MANDEL_MAX_ITER = 256
TREE_MIN_DEPTH = 4
TREE_MAX_DEPTH = 18
SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"


def report(name, checksum, secs):
    print(f"{name} {checksum} {secs:.3f}")


def is_prime(n):
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def bench_primes(limit):
    count = 0
    for i in range(2, limit):
        if is_prime(i):
            count += 1
    return count


def fib(n):
    return n if n < 2 else fib(n - 1) + fib(n - 2)


def bench_strings(sentence, iters):
    words = sentence.split(' ')
    total = 0
    for _ in range(iters):
        for wi in words:
            for wj in words:
                if wi == wj:
                    total += 1
    return total


def bench_mandelbrot(size):
    checksum = 0
    for py in range(size):
        cy = py / size * 3.0 - 1.5
        for px in range(size):
            cx = px / size * 3.0 - 2.0
            zx = 0.0
            zy = 0.0
            it = 0
            while it < MANDEL_MAX_ITER and zx * zx + zy * zy <= 4.0:
                nx = zx * zx - zy * zy + cx
                zy = 2.0 * zx * zy + cy
                zx = nx
                it += 1
            checksum += it
    return checksum


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


def bench_binary_trees(max_depth):
    checksum = 0
    stretch = make_tree(0, max_depth + 1)
    checksum += check_tree(stretch)
    del stretch
    long_lived = make_tree(0, max_depth)
    for d in range(TREE_MIN_DEPTH, max_depth + 1, 2):
        iters = 1 << (max_depth - d + TREE_MIN_DEPTH)
        for i in range(iters):
            checksum += check_tree(make_tree(i + 1, d))
    checksum += check_tree(long_lived)
    return checksum


def main():
    now = time.perf_counter
    t = now(); r = bench_primes(PRIMES_LIMIT);          report("primes", r, now() - t)
    t = now(); r = fib(FIBONACCI_N);                     report("fib", r, now() - t)
    t = now(); r = bench_strings(SENTENCE, STRING_ITER); report("strings", r, now() - t)
    t = now(); r = bench_mandelbrot(MANDEL_SIZE);        report("mandelbrot", r, now() - t)
    t = now(); r = bench_binary_trees(TREE_MAX_DEPTH);   report("binarytrees", r, now() - t)


if __name__ == "__main__":
    main()
