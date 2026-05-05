using System;
using System.Diagnostics;

class Bench {
    const int PRIMES_LIMIT = 20_000_000;
    const int FIBONACCI_N = 45;
    const int STRING_ITER = 5_000_000;
    const int MANDEL_W = 4096;
    const int MANDEL_H = 4096;
    const int MANDEL_MAX_ITER = 256;
    const int TREE_MIN_DEPTH = 4;
    const int TREE_MAX_DEPTH = 18;
    const string SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

    static bool IsPrime(int n) {
        if (n <= 1) return false;
        if (n <= 3) return true;
        if (n % 2 == 0 || n % 3 == 0) return false;
        for (int i = 5; i * i <= n; i += 6)
            if (n % i == 0 || n % (i + 2) == 0) return false;
        return true;
    }

    static void BenchPrimes() {
        var sw = Stopwatch.StartNew();
        int c = 0;
        for (int i = 2; i < PRIMES_LIMIT; i++) if (IsPrime(i)) c++;
        Console.WriteLine($"Found {c} primes in {sw.Elapsed.TotalSeconds:F3} seconds\n");
    }

    static long Fib(int n) => n <= 1 ? n : Fib(n - 1) + Fib(n - 2);
    static void BenchFibRec() {
        var sw = Stopwatch.StartNew();
        long r = Fib(FIBONACCI_N);
        Console.WriteLine($"Fibonacci({FIBONACCI_N}) = {r} in {sw.Elapsed.TotalSeconds:F3} seconds\n");
    }

    static void BenchStrings() {
        var sw = Stopwatch.StartNew();
        string[] words = SENTENCE.Split(' ');
        int wcount = words.Length;
        ulong total = 0;
        for (int iter = 0; iter < STRING_ITER; iter++) {
            for (int i = 0; i < wcount; i++) {
                ulong count = 0;
                for (int j = 0; j < wcount; j++) {
                    if (words[i] == words[j]) count++;
                }
                total += count;
            }
        }
        Console.WriteLine($"Strings: total={total} in {sw.Elapsed.TotalSeconds:F3} seconds\n");
    }

    static void BenchMandelbrot() {
        var sw = Stopwatch.StartNew();
        long checksum = 0;
        for (int py = 0; py < MANDEL_H; py++) {
            double cy = ((double)py / (double)MANDEL_H) * 3.0 - 1.5;
            for (int px = 0; px < MANDEL_W; px++) {
                double cx = ((double)px / (double)MANDEL_W) * 3.0 - 2.0;
                double zx = 0.0, zy = 0.0;
                int iter = 0;
                while (iter < MANDEL_MAX_ITER && zx * zx + zy * zy <= 4.0) {
                    double nx = zx * zx - zy * zy + cx;
                    zy = 2.0 * zx * zy + cy;
                    zx = nx;
                    iter++;
                }
                checksum += (long)iter;
            }
        }
        Console.WriteLine($"Mandelbrot: checksum={checksum} in {sw.Elapsed.TotalSeconds:F3} seconds\n");
    }

    class Node {
        public Node? Left;
        public Node? Right;
        public long Item;
    }

    static Node MakeTree(long item, int depth) {
        if (depth == 0) return new Node { Left = null, Right = null, Item = item };
        return new Node { Left = MakeTree(2 * item - 1, depth - 1), Right = MakeTree(2 * item, depth - 1), Item = item };
    }

    static long CheckTree(Node n) {
        if (n.Left == null) return n.Item;
        return n.Item + CheckTree(n.Left) - CheckTree(n.Right!);
    }

    static void BenchBinaryTrees() {
        var sw = Stopwatch.StartNew();
        long checksum = 0;

        {
            Node stretch = MakeTree(0, TREE_MAX_DEPTH + 1);
            checksum += CheckTree(stretch);
        }

        Node longLived = MakeTree(0, TREE_MAX_DEPTH);

        for (int d = TREE_MIN_DEPTH; d <= TREE_MAX_DEPTH; d += 2) {
            int iters = 1 << (TREE_MAX_DEPTH - d + TREE_MIN_DEPTH);
            long sum = 0;
            for (int i = 0; i < iters; i++) {
                Node t = MakeTree((long)(i + 1), d);
                sum += CheckTree(t);
            }
            checksum += sum;
        }

        checksum += CheckTree(longLived);

        Console.WriteLine($"BinaryTrees: checksum={checksum} in {sw.Elapsed.TotalSeconds:F3} seconds\n");
    }

    static void Main() {
        Console.WriteLine("=== PROGRAMMING LANGUAGE BENCHMARK ===\n");
        var sw = Stopwatch.StartNew();
        BenchPrimes();
        BenchFibRec();
        BenchStrings();
        BenchMandelbrot();
        BenchBinaryTrees();
        Console.WriteLine("=== BENCHMARK COMPLETE ===");
        Console.WriteLine($"Total execution time: {sw.Elapsed.TotalSeconds:F3} seconds");
    }
}
