static final int PRIMES_LIMIT = 8_000_000;
static final int FIBONACCI_N = 43;
static final int STRING_ITER = 1_200_000;
static final int MANDEL_SIZE = 2048;
static final int MANDEL_MAX_ITER = 256;
static final int TREE_MIN_DEPTH = 4;
static final int TREE_MAX_DEPTH = 17;
static final String SENTENCE =
    "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";
static final int KNUC_LENGTH = 6_000_000;
static final int KNUC_SEED = 42;
static final int KNUC_IM = 139968;
static final int KNUC_IA = 3877;
static final int KNUC_IC = 29573;
static final String KNUC_QUERY = "GGTATTTTAATTTATAGT";

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
    var words = sentence.split(" ");
    var cur = words.clone();
    long total = 0;
    for (int it = 0; it < iters; it++) {
        int i = it % words.length;
        cur[i] = new StringBuilder(cur[i]).reverse().toString();
        for (var wi : cur)
            for (var wj : words)
                if (wi.equals(wj)) total++;
    }
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

record Node(Node left, Node right, long item) {}

static Node makeTree(long item, int depth) {
    if (depth == 0) return new Node(null, null, item);
    return new Node(makeTree(2 * item - 1, depth - 1), makeTree(2 * item, depth - 1), item);
}

static long checkTree(Node n) {
    if (n.left() == null) return n.item();
    return n.item() + checkTree(n.left()) - checkTree(n.right());
}

static long benchBinaryTrees(int maxDepth) {
    long checksum = checkTree(makeTree(0, maxDepth + 1));
    var longLived = makeTree(0, maxDepth);
    for (int d = TREE_MIN_DEPTH; d <= maxDepth; d += 2) {
        int iters = 1 << (maxDepth - d + TREE_MIN_DEPTH);
        for (int i = 0; i < iters; i++)
            checksum += checkTree(makeTree(i + 1, d));
    }
    return checksum + checkTree(longLived);
}

static long benchKnucleotide(int length) {
    int[] ks = {1, 2, 3, 4, 6, 12, 18};
    var buf = new char[length];
    int seed = KNUC_SEED;
    for (int i = 0; i < length; i++) {
        seed = (seed * KNUC_IA + KNUC_IC) % KNUC_IM;
        buf[i] = seed < 42404 ? 'A' : seed < 70116 ? 'C' : seed < 97766 ? 'G' : 'T';
    }
    var seq = new String(buf);
    long checksum = 0;
    for (int k : ks) {
        var counts = new HashMap<String, Integer>();
        for (int i = 0; i + k <= length; i++)
            counts.merge(seq.substring(i, i + k), 1, Integer::sum);
        checksum += counts.size();
        if (k <= 2) {
            var entries = new ArrayList<>(counts.entrySet());
            entries.sort((a, b) -> {
                int c = Integer.compare(b.getValue(), a.getValue());
                return c != 0 ? c : a.getKey().compareTo(b.getKey());
            });
            for (int r = 0; r < entries.size(); r++)
                checksum += (long) (r + 1) * entries.get(r).getValue();
        } else {
            checksum += counts.getOrDefault(KNUC_QUERY.substring(0, k), 0);
        }
    }
    return checksum;
}

void main() {
    long t, r;
    t = System.nanoTime(); r = benchPrimes(PRIMES_LIMIT);           report("primes", r, (System.nanoTime() - t) / 1e9);
    t = System.nanoTime(); r = fib(FIBONACCI_N);                    report("fib", r, (System.nanoTime() - t) / 1e9);
    t = System.nanoTime(); r = benchStrings(SENTENCE, STRING_ITER); report("strings", r, (System.nanoTime() - t) / 1e9);
    t = System.nanoTime(); r = benchMandelbrot(MANDEL_SIZE);        report("mandelbrot", r, (System.nanoTime() - t) / 1e9);
    t = System.nanoTime(); r = benchBinaryTrees(TREE_MAX_DEPTH);    report("binarytrees", r, (System.nanoTime() - t) / 1e9);
    t = System.nanoTime(); r = benchKnucleotide(KNUC_LENGTH);       report("knucleotide", r, (System.nanoTime() - t) / 1e9);
}
