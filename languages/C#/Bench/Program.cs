using System.Diagnostics;
using System.Globalization;
using System.Runtime.InteropServices;

const int PRIMES_LIMIT = 8_000_000;
const int FIBONACCI_N = 43;
const int STRING_ITER = 1_200_000;
const int MANDEL_SIZE = 2048;
const int MANDEL_MAX_ITER = 256;
const int TREE_MIN_DEPTH = 4;
const int TREE_MAX_DEPTH = 17;
const string SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";
const int KNUC_LENGTH = 6_000_000;
const int KNUC_SEED = 42;
const int KNUC_IM = 139968;
const int KNUC_IA = 3877;
const int KNUC_IC = 29573;
const string KNUC_QUERY = "GGTATTTTAATTTATAGT";

var sw = Stopwatch.StartNew();
long r;
r = BenchPrimes(PRIMES_LIMIT);           Report("primes", r, sw.Elapsed.TotalSeconds); sw.Restart();
r = Fib(FIBONACCI_N);                    Report("fib", r, sw.Elapsed.TotalSeconds); sw.Restart();
r = BenchStrings(SENTENCE, STRING_ITER); Report("strings", r, sw.Elapsed.TotalSeconds); sw.Restart();
r = BenchMandelbrot(MANDEL_SIZE);        Report("mandelbrot", r, sw.Elapsed.TotalSeconds); sw.Restart();
r = BenchBinaryTrees(TREE_MAX_DEPTH);    Report("binarytrees", r, sw.Elapsed.TotalSeconds); sw.Restart();
r = BenchKnucleotide(KNUC_LENGTH);       Report("knucleotide", r, sw.Elapsed.TotalSeconds);

static void Report(string name, long checksum, double secs) =>
    Console.WriteLine(string.Create(CultureInfo.InvariantCulture, $"{name} {checksum} {secs:F3}"));

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
    var words = sentence.Split(' ');
    string[] cur = [.. words];
    long total = 0;
    for (int it = 0; it < iters; it++) {
        int i = it % words.Length;
        var chars = cur[i].ToCharArray();
        Array.Reverse(chars);
        cur[i] = new string(chars);
        foreach (var wi in cur)
            foreach (var wj in words)
                if (wi == wj) total++;
    }
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

static Node MakeTree(long item, int depth) {
    if (depth == 0) return new Node(null, null, item);
    return new Node(MakeTree(2 * item - 1, depth - 1), MakeTree(2 * item, depth - 1), item);
}

static long CheckTree(Node n) {
    if (n.Left is null) return n.Item;
    return n.Item + CheckTree(n.Left) - CheckTree(n.Right!);
}

static long BenchBinaryTrees(int maxDepth) {
    long checksum = CheckTree(MakeTree(0, maxDepth + 1));
    var longLived = MakeTree(0, maxDepth);
    for (int d = TREE_MIN_DEPTH; d <= maxDepth; d += 2) {
        int iters = 1 << (maxDepth - d + TREE_MIN_DEPTH);
        for (int i = 0; i < iters; i++)
            checksum += CheckTree(MakeTree(i + 1, d));
    }
    return checksum + CheckTree(longLived);
}

static long BenchKnucleotide(int length) {
    int[] ks = [1, 2, 3, 4, 6, 12, 18];
    var buf = new char[length];
    int seed = KNUC_SEED;
    for (int i = 0; i < length; i++) {
        seed = (seed * KNUC_IA + KNUC_IC) % KNUC_IM;
        buf[i] = seed < 42404 ? 'A' : seed < 70116 ? 'C' : seed < 97766 ? 'G' : 'T';
    }
    var seq = new string(buf);
    long checksum = 0;
    foreach (var k in ks) {
        var counts = new Dictionary<string, int>();
        for (int i = 0; i + k <= length; i++)
            CollectionsMarshal.GetValueRefOrAddDefault(counts, seq.Substring(i, k), out _)++;
        checksum += counts.Count;
        if (k <= 2) {
            List<KeyValuePair<string, int>> entries = [.. counts];
            entries.Sort((a, b) => a.Value != b.Value ? b.Value.CompareTo(a.Value) : string.CompareOrdinal(a.Key, b.Key));
            for (int r = 0; r < entries.Count; r++)
                checksum += (long)(r + 1) * entries[r].Value;
        } else {
            checksum += counts.GetValueOrDefault(KNUC_QUERY[..k]);
        }
    }
    return checksum;
}

sealed record Node(Node? Left, Node? Right, long Item);
