using System;
using System.Diagnostics;
using System.Globalization;

class Bench {
    const int PRIMES_LIMIT = 20_000_000;
    const int FIBONACCI_N = 45;
    const int STRING_ITER = 5_000_000;
    const int MANDEL_SIZE = 4096;
    const int MANDEL_MAX_ITER = 256;
    const int TREE_MIN_DEPTH = 4;
    const int TREE_MAX_DEPTH = 18;
    const string SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

    static void Report(string name, long checksum, double secs) =>
        Console.WriteLine($"{name} {checksum} {secs.ToString("F3", CultureInfo.InvariantCulture)}");

    static bool IsPrime(int n) {
        if (n < 2) return false;
        if (n < 4) return true;
        if (n % 2 == 0 || n % 3 == 0) return false;
        for (int i = 5; i * i <= n; i += 6)
            if (n % i == 0 || n % (i + 2) == 0) return false;
        return true;
    }

    static long BenchPrimes(int limit) {
        long count = 0;
        for (int i = 2; i < limit; i++)
            if (IsPrime(i)) count++;
        return count;
    }

    static long Fib(int n) => n < 2 ? n : Fib(n - 1) + Fib(n - 2);

    static long BenchStrings(string sentence, int iters) {
        string[] words = sentence.Split(' ');
        long total = 0;
        for (int it = 0; it < iters; it++)
            foreach (string wi in words)
                foreach (string wj in words)
                    if (wi == wj) total++;
        return total;
    }

    static long BenchMandelbrot(int size) {
        long checksum = 0;
        for (int py = 0; py < size; py++) {
            double cy = (double)py / size * 3.0 - 1.5;
            for (int px = 0; px < size; px++) {
                double cx = (double)px / size * 3.0 - 2.0;
                double zx = 0.0, zy = 0.0;
                int iter = 0;
                while (iter < MANDEL_MAX_ITER && zx * zx + zy * zy <= 4.0) {
                    double nx = zx * zx - zy * zy + cx;
                    zy = 2.0 * zx * zy + cy;
                    zx = nx;
                    iter++;
                }
                checksum += iter;
            }
        }
        return checksum;
    }

    sealed class Node {
        public readonly Node? Left, Right;
        public readonly long Item;
        public Node(Node? left, Node? right, long item) { Left = left; Right = right; Item = item; }
    }

    static Node MakeTree(long item, int depth) {
        if (depth == 0) return new Node(null, null, item);
        return new Node(MakeTree(2 * item - 1, depth - 1), MakeTree(2 * item, depth - 1), item);
    }

    static long CheckTree(Node n) {
        if (n.Left == null) return n.Item;
        return n.Item + CheckTree(n.Left) - CheckTree(n.Right!);
    }

    static long BenchBinaryTrees(int maxDepth) {
        long checksum = 0;
        {
            Node stretch = MakeTree(0, maxDepth + 1);
            checksum += CheckTree(stretch);
        }
        Node longLived = MakeTree(0, maxDepth);
        for (int d = TREE_MIN_DEPTH; d <= maxDepth; d += 2) {
            int iters = 1 << (maxDepth - d + TREE_MIN_DEPTH);
            for (int i = 0; i < iters; i++)
                checksum += CheckTree(MakeTree(i + 1, d));
        }
        checksum += CheckTree(longLived);
        return checksum;
    }

    static void Main() {
        var sw = Stopwatch.StartNew();
        long r;
        r = BenchPrimes(PRIMES_LIMIT);          Report("primes", r, sw.Elapsed.TotalSeconds); sw.Restart();
        r = Fib(FIBONACCI_N);                   Report("fib", r, sw.Elapsed.TotalSeconds); sw.Restart();
        r = BenchStrings(SENTENCE, STRING_ITER); Report("strings", r, sw.Elapsed.TotalSeconds); sw.Restart();
        r = BenchMandelbrot(MANDEL_SIZE);        Report("mandelbrot", r, sw.Elapsed.TotalSeconds); sw.Restart();
        r = BenchBinaryTrees(TREE_MAX_DEPTH);    Report("binarytrees", r, sw.Elapsed.TotalSeconds);
    }
}
