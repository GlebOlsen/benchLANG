import std.algorithm, std.array, std.datetime.stopwatch, std.exception, std.stdio;

enum primesLimit = 8_000_000;
enum fibonacciN = 43;
enum stringIter = 1_200_000;
enum mandelSize = 2048;
enum mandelMaxIter = 256;
enum treeMinDepth = 4;
enum treeMaxDepth = 17;
enum sentenceText = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";
enum knucLength = 6_000_000;
enum knucSeed = 42;
enum knucIm = 139968;
enum knucIa = 3877;
enum knucIc = 29573;
enum knucQuery = "GGTATTTTAATTTATAGT";
immutable knucKs = [1, 2, 3, 4, 6, 12, 18];

void bench(string name, lazy long work) {
    auto sw = StopWatch(AutoStart.yes);
    immutable checksum = work;
    writefln("%s %d %.3f", name, checksum, sw.peek.total!"nsecs" / 1e9);
}

bool isPrime(int n) {
    if (n < 2) return false;
    if (n < 4) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    for (int i = 5; i * i <= n; i += 6)
        if (n % i == 0 || n % (i + 2) == 0) return false;
    return true;
}

long benchPrimes(int limit) {
    long count = 0;
    foreach (i; 2 .. limit)
        if (isPrime(i)) count++;
    return count;
}

long fib(int n) => n < 2 ? n : fib(n - 1) + fib(n - 2);

long benchStrings(string sentence, int iters) {
    auto words = sentence.split(' ');
    auto cur = words.map!(w => w.dup).array;
    long total = 0;
    foreach (it; 0 .. iters) {
        cur[it % cur.length].reverse();
        foreach (wi; cur)
            foreach (wj; words)
                if (wi == wj) total++;
    }
    return total;
}

long benchMandelbrot(int size) {
    long checksum = 0;
    foreach (py; 0 .. size) {
        double cy = cast(double) py / size * 3.0 - 1.5;
        foreach (px; 0 .. size) {
            double cx = cast(double) px / size * 3.0 - 2.0;
            double zx = 0.0, zy = 0.0;
            int iter = 0;
            while (iter < mandelMaxIter && zx * zx + zy * zy <= 4.0) {
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

struct Node {
    Node* left, right;
    long item;
}

Node* makeTree(long item, int depth) =>
    depth == 0 ? new Node(null, null, item)
               : new Node(makeTree(2 * item - 1, depth - 1), makeTree(2 * item, depth - 1), item);

long checkTree(const Node* n) =>
    n.left is null ? n.item : n.item + checkTree(n.left) - checkTree(n.right);

long benchBinaryTrees(int maxDepth) {
    long checksum = checkTree(makeTree(0, maxDepth + 1));
    auto longLived = makeTree(0, maxDepth);
    for (int d = treeMinDepth; d <= maxDepth; d += 2)
        foreach (i; 0 .. 1 << (maxDepth - d + treeMinDepth))
            checksum += checkTree(makeTree(i + 1, d));
    return checksum + checkTree(longLived);
}

long benchKnucleotide(int length) {
    auto buf = new char[length];
    int seed = knucSeed;
    foreach (ref c; buf) {
        seed = (seed * knucIa + knucIc) % knucIm;
        c = seed < 42404 ? 'A' : seed < 70116 ? 'C' : seed < 97766 ? 'G' : 'T';
    }
    string seq = buf.assumeUnique;
    long checksum = 0;
    foreach (k; knucKs) {
        int[string] counts;
        foreach (i; 0 .. length - k + 1)
            counts[seq[i .. i + k]]++;
        checksum += counts.length;
        if (k <= 2) {
            auto entries = counts.byPair.array;
            entries.sort!((a, b) => a.value != b.value ? a.value > b.value : a.key < b.key);
            foreach (r, e; entries)
                checksum += (r + 1) * e.value;
        } else if (auto p = knucQuery[0 .. k] in counts) {
            checksum += *p;
        }
    }
    return checksum;
}

void main() {
    bench("primes", benchPrimes(primesLimit));
    bench("fib", fib(fibonacciN));
    bench("strings", benchStrings(sentenceText, stringIter));
    bench("mandelbrot", benchMandelbrot(mandelSize));
    bench("binarytrees", benchBinaryTrees(treeMaxDepth));
    bench("knucleotide", benchKnucleotide(knucLength));
}
