public class bench {
    private static final int PRIMES_LIMIT = 20_000_000;
    private static final int FIBONACCI_N = 45;
    private static final int STRING_ITER = 5_000_000;
    private static final int MANDEL_W = 4096;
    private static final int MANDEL_H = 4096;
    private static final int MANDEL_MAX_ITER = 256;
    private static final int TREE_MIN_DEPTH = 4;
    private static final int TREE_MAX_DEPTH = 18;
    private static final String SENTENCE =
        "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

    static boolean isPrime(int n) {
        if (n <= 1) return false;
        if (n <= 3) return true;
        if (n % 2 == 0 || n % 3 == 0) return false;
        for (int i = 5; i * i <= n; i += 6)
            if (n % i == 0 || n % (i + 2) == 0) return false;
        return true;
    }

    static void benchPrimes() {
        long s = System.nanoTime();
        int c = 0;
        for (int i = 2; i < PRIMES_LIMIT; i++) if (isPrime(i)) c++;
        System.out.printf("Found %d primes in %.3f seconds%n%n", c, (System.nanoTime() - s) / 1e9);
    }

    static long fib(int n) { return n <= 1 ? n : fib(n - 1) + fib(n - 2); }
    static void benchFibRec() {
        long s = System.nanoTime();
        long r = fib(FIBONACCI_N);
        System.out.printf("Fibonacci(%d) = %d in %.3f seconds%n%n", FIBONACCI_N, r, (System.nanoTime() - s) / 1e9);
    }

    static void benchStrings() {
        long s = System.nanoTime();
        String[] words = SENTENCE.split(" ");
        int wcount = words.length;
        long total = 0;
        for (int iter = 0; iter < STRING_ITER; iter++) {
            for (int i = 0; i < wcount; i++) {
                long count = 0;
                for (int j = 0; j < wcount; j++) {
                    if (words[i].equals(words[j])) count++;
                }
                total += count;
            }
        }
        System.out.printf("Strings: total=%d in %.3f seconds%n%n", total, (System.nanoTime() - s) / 1e9);
    }

    static void benchMandelbrot() {
        long s = System.nanoTime();
        long checksum = 0;
        for (int py = 0; py < MANDEL_H; py++) {
            double cy = ((double) py / (double) MANDEL_H) * 3.0 - 1.5;
            for (int px = 0; px < MANDEL_W; px++) {
                double cx = ((double) px / (double) MANDEL_W) * 3.0 - 2.0;
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
        System.out.printf("Mandelbrot: checksum=%d in %.3f seconds%n%n", checksum, (System.nanoTime() - s) / 1e9);
    }

    static class Node {
        Node left, right;
        long item;
        Node(Node l, Node r, long item) { this.left = l; this.right = r; this.item = item; }
    }

    static Node makeTree(long item, int depth) {
        if (depth == 0) return new Node(null, null, item);
        return new Node(makeTree(2 * item - 1, depth - 1), makeTree(2 * item, depth - 1), item);
    }

    static long checkTree(Node n) {
        if (n.left == null) return n.item;
        return n.item + checkTree(n.left) - checkTree(n.right);
    }

    static void benchBinaryTrees() {
        long s = System.nanoTime();
        long checksum = 0;

        {
            Node stretch = makeTree(0, TREE_MAX_DEPTH + 1);
            checksum += checkTree(stretch);
        }

        Node longLived = makeTree(0, TREE_MAX_DEPTH);

        for (int d = TREE_MIN_DEPTH; d <= TREE_MAX_DEPTH; d += 2) {
            int iters = 1 << (TREE_MAX_DEPTH - d + TREE_MIN_DEPTH);
            long sum = 0;
            for (int i = 0; i < iters; i++) {
                Node t = makeTree((long)(i + 1), d);
                sum += checkTree(t);
            }
            checksum += sum;
        }

        checksum += checkTree(longLived);

        System.out.printf("BinaryTrees: checksum=%d in %.3f seconds%n%n", checksum, (System.nanoTime() - s) / 1e9);
    }

    public static void main(String[] args) {
        System.out.println("=== PROGRAMMING LANGUAGE BENCHMARK ===\n");
        long s = System.nanoTime();
        benchPrimes();
        benchFibRec();
        benchStrings();
        benchMandelbrot();
        benchBinaryTrees();
        System.out.println("=== BENCHMARK COMPLETE ===");
        System.out.printf("Total execution time: %.3f seconds%n", (System.nanoTime() - s) / 1e9);
    }
}
