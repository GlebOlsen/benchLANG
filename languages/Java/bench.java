import java.util.Locale;

public class bench {
    static final int PRIMES_LIMIT = 20_000_000;
    static final int FIBONACCI_N = 45;
    static final int STRING_ITER = 5_000_000;
    static final int MANDEL_SIZE = 4096;
    static final int MANDEL_MAX_ITER = 256;
    static final int TREE_MIN_DEPTH = 4;
    static final int TREE_MAX_DEPTH = 18;
    static final String SENTENCE =
        "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

    static void report(String name, long checksum, double secs) {
        System.out.printf(Locale.ROOT, "%s %d %.3f%n", name, checksum, secs);
    }

    static boolean isPrime(int n) {
        if (n < 2) return false;
        if (n < 4) return true;
        if (n % 2 == 0 || n % 3 == 0) return false;
        for (int i = 5; i * i <= n; i += 6)
            if (n % i == 0 || n % (i + 2) == 0) return false;
        return true;
    }

    static long benchPrimes(int limit) {
        long count = 0;
        for (int i = 2; i < limit; i++)
            if (isPrime(i)) count++;
        return count;
    }

    static long fib(int n) { return n < 2 ? n : fib(n - 1) + fib(n - 2); }

    static long benchStrings(String sentence, int iters) {
        String[] words = sentence.split(" ");
        long total = 0;
        for (int it = 0; it < iters; it++)
            for (String wi : words)
                for (String wj : words)
                    if (wi.equals(wj)) total++;
        return total;
    }

    static long benchMandelbrot(int size) {
        long checksum = 0;
        for (int py = 0; py < size; py++) {
            double cy = (double) py / size * 3.0 - 1.5;
            for (int px = 0; px < size; px++) {
                double cx = (double) px / size * 3.0 - 2.0;
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

    static final class Node {
        final Node left, right;
        final long item;
        Node(Node left, Node right, long item) { this.left = left; this.right = right; this.item = item; }
    }

    static Node makeTree(long item, int depth) {
        if (depth == 0) return new Node(null, null, item);
        return new Node(makeTree(2 * item - 1, depth - 1), makeTree(2 * item, depth - 1), item);
    }

    static long checkTree(Node n) {
        if (n.left == null) return n.item;
        return n.item + checkTree(n.left) - checkTree(n.right);
    }

    static long benchBinaryTrees(int maxDepth) {
        long checksum = 0;
        {
            Node stretch = makeTree(0, maxDepth + 1);
            checksum += checkTree(stretch);
        }
        Node longLived = makeTree(0, maxDepth);
        for (int d = TREE_MIN_DEPTH; d <= maxDepth; d += 2) {
            int iters = 1 << (maxDepth - d + TREE_MIN_DEPTH);
            for (int i = 0; i < iters; i++)
                checksum += checkTree(makeTree(i + 1, d));
        }
        checksum += checkTree(longLived);
        return checksum;
    }

    public static void main(String[] args) {
        long t, r;
        t = System.nanoTime(); r = benchPrimes(PRIMES_LIMIT);          report("primes", r, (System.nanoTime() - t) / 1e9);
        t = System.nanoTime(); r = fib(FIBONACCI_N);                   report("fib", r, (System.nanoTime() - t) / 1e9);
        t = System.nanoTime(); r = benchStrings(SENTENCE, STRING_ITER); report("strings", r, (System.nanoTime() - t) / 1e9);
        t = System.nanoTime(); r = benchMandelbrot(MANDEL_SIZE);        report("mandelbrot", r, (System.nanoTime() - t) / 1e9);
        t = System.nanoTime(); r = benchBinaryTrees(TREE_MAX_DEPTH);    report("binarytrees", r, (System.nanoTime() - t) / 1e9);
    }
}
