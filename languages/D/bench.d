import std.stdio, std.datetime.stopwatch, std.format, std.string;

enum PRIMES_LIMIT    = 20_000_000;
enum FIBONACCI_N     = 45;
enum STRING_ITER     = 5_000_000;
enum MANDEL_W        = 4096;
enum MANDEL_H        = 4096;
enum MANDEL_MAX_ITER = 256;
enum TREE_MIN_DEPTH  = 4;
enum TREE_MAX_DEPTH  = 18;
enum SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

bool isPrime(int n) {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    for (int i = 5; i * i <= n; i += 6)
        if (n % i == 0 || n % (i + 2) == 0) return false;
    return true;
}
void benchPrimes() {
    auto sw = StopWatch(AutoStart.yes);
    int c = 0;
    foreach (i; 2 .. PRIMES_LIMIT) if (isPrime(i)) c++;
    writefln("Found %d primes in %.3f seconds\n", c, sw.peek.total!"hnsecs" / 1e7);
}

long fib(int n) { return n <= 1 ? n : fib(n - 1) + fib(n - 2); }
void benchFibRec() {
    auto sw = StopWatch(AutoStart.yes);
    auto r = fib(FIBONACCI_N);
    writefln("Fibonacci(%d) = %d in %.3f seconds\n", FIBONACCI_N, r, sw.peek.total!"hnsecs" / 1e7);
}

void benchStrings() {
    auto sw = StopWatch(AutoStart.yes);
    auto words = SENTENCE.split(' ');
    int wcount = cast(int)words.length;
    ulong total = 0;
    foreach (iter; 0 .. STRING_ITER) {
        for (int i = 0; i < wcount; i++) {
            ulong count = 0;
            for (int j = 0; j < wcount; j++) {
                if (words[i] == words[j]) count++;
            }
            total += count;
        }
    }
    writefln("Strings: total=%d in %.3f seconds\n", total, sw.peek.total!"hnsecs" / 1e7);
}

void benchMandelbrot() {
    auto sw = StopWatch(AutoStart.yes);
    long checksum = 0;
    foreach (py; 0 .. MANDEL_H) {
        double cy = (cast(double)py / cast(double)MANDEL_H) * 3.0 - 1.5;
        foreach (px; 0 .. MANDEL_W) {
            double cx = (cast(double)px / cast(double)MANDEL_W) * 3.0 - 2.0;
            double zx = 0.0, zy = 0.0;
            int iter = 0;
            while (iter < MANDEL_MAX_ITER && zx * zx + zy * zy <= 4.0) {
                double nx = zx * zx - zy * zy + cx;
                zy = 2.0 * zx * zy + cy;
                zx = nx;
                iter++;
            }
            checksum += cast(long)iter;
        }
    }
    writefln("Mandelbrot: checksum=%d in %.3f seconds\n", checksum, sw.peek.total!"hnsecs" / 1e7);
}

final class TreeNode {
    TreeNode left;
    TreeNode right;
    long item;
}

TreeNode makeTree(long item, int depth) {
    auto n = new TreeNode();
    n.item = item;
    if (depth == 0) {
        n.left = null;
        n.right = null;
        return n;
    }
    n.left = makeTree(2 * item - 1, depth - 1);
    n.right = makeTree(2 * item, depth - 1);
    return n;
}

long checkTree(TreeNode n) {
    if (n.left is null) return n.item;
    return n.item + checkTree(n.left) - checkTree(n.right);
}

void benchBinaryTrees() {
    auto sw = StopWatch(AutoStart.yes);
    long checksum = 0;

    {
        auto stretch = makeTree(0, TREE_MAX_DEPTH + 1);
        checksum += checkTree(stretch);
    }

    auto longLived = makeTree(0, TREE_MAX_DEPTH);

    for (int d = TREE_MIN_DEPTH; d <= TREE_MAX_DEPTH; d += 2) {
        int iters = 1 << (TREE_MAX_DEPTH - d + TREE_MIN_DEPTH);
        long sum = 0;
        for (int i = 0; i < iters; i++) {
            auto t = makeTree(cast(long)(i + 1), d);
            sum += checkTree(t);
        }
        checksum += sum;
    }

    checksum += checkTree(longLived);

    writefln("BinaryTrees: checksum=%d in %.3f seconds\n", checksum, sw.peek.total!"hnsecs" / 1e7);
}

void main() {
    writeln("=== PROGRAMMING LANGUAGE BENCHMARK ===\n");
    auto sw = StopWatch(AutoStart.yes);
    benchPrimes();
    benchFibRec();
    benchStrings();
    benchMandelbrot();
    benchBinaryTrees();
    writeln("=== BENCHMARK COMPLETE ===");
    writefln("Total execution time: %.3f seconds", sw.peek.total!"hnsecs" / 1e7);
}
