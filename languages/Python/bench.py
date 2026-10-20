from time import perf_counter as now

PRIMES_LIMIT = 8_000_000
FIBONACCI_N = 43
STRING_ITER = 1_200_000
MANDEL_SIZE = 2048
MANDEL_MAX_ITER = 256
TREE_MIN_DEPTH = 4
TREE_MAX_DEPTH = 17
SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"
KNUC_LENGTH = 6_000_000
KNUC_SEED = 42
KNUC_IM = 139968
KNUC_IA = 3877
KNUC_IC = 29573
KNUC_QUERY = "GGTATTTTAATTTATAGT"


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
    cur = list(words)
    total = 0
    for it in range(iters):
        i = it % len(words)
        cur[i] = cur[i][::-1]
        for wi in cur:
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
            zx = zy = 0.0
            it = 0
            while it < MANDEL_MAX_ITER and zx * zx + zy * zy <= 4.0:
                nx = zx * zx - zy * zy + cx
                zy = 2.0 * zx * zy + cy
                zx = nx
                it += 1
            checksum += it
    return checksum


class Node:
    __slots__ = ("left", "right", "item")

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
    checksum = check_tree(make_tree(0, max_depth + 1))
    long_lived = make_tree(0, max_depth)
    for d in range(TREE_MIN_DEPTH, max_depth + 1, 2):
        iters = 1 << (max_depth - d + TREE_MIN_DEPTH)
        for i in range(iters):
            checksum += check_tree(make_tree(i + 1, d))
    checksum += check_tree(long_lived)
    return checksum


def bench_knucleotide(length):
    buf = bytearray(length)
    seed = KNUC_SEED
    for i in range(length):
        seed = (seed * KNUC_IA + KNUC_IC) % KNUC_IM
        buf[i] = 65 if seed < 42404 else 67 if seed < 70116 else 71 if seed < 97766 else 84
    seq = buf.decode()
    checksum = 0
    for k in (1, 2, 3, 4, 6, 12, 18):
        counts = {}
        for i in range(length - k + 1):
            key = seq[i:i + k]
            counts[key] = counts.get(key, 0) + 1
        checksum += len(counts)
        if k <= 2:
            entries = sorted(counts.items(), key=lambda e: (-e[1], e[0]))
            checksum += sum(r * c for r, (_, c) in enumerate(entries, 1))
        else:
            checksum += counts.get(KNUC_QUERY[:k], 0)
    return checksum


def main():
    t = now(); r = bench_primes(PRIMES_LIMIT);          report("primes", r, now() - t)
    t = now(); r = fib(FIBONACCI_N);                     report("fib", r, now() - t)
    t = now(); r = bench_strings(SENTENCE, STRING_ITER); report("strings", r, now() - t)
    t = now(); r = bench_mandelbrot(MANDEL_SIZE);        report("mandelbrot", r, now() - t)
    t = now(); r = bench_binary_trees(TREE_MAX_DEPTH);   report("binarytrees", r, now() - t)
    t = now(); r = bench_knucleotide(KNUC_LENGTH);       report("knucleotide", r, now() - t)


if __name__ == "__main__":
    main()
