import std.datetime.stopwatch, std.stdio, std.string;

enum primesLimit = 20_000_000;
enum fibonacciN = 45;
enum stringIter = 5_000_000;
enum mandelSize = 4096;
enum mandelMaxIter = 256;
enum treeMinDepth = 4;
enum treeMaxDepth = 18;
enum sentenceText = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

void report(string name, long checksum, double secs) {
    writefln("%s %d %.3f", name, checksum, secs);
}

double secs(ref StopWatch sw) {
    return sw.peek.total!"nsecs" / 1e9;
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

long fib(int n) { return n < 2 ? n : fib(n - 1) + fib(n - 2); }

long benchStrings(string sentence, int iters) {
    auto words = sentence.split(' ');
    long total = 0;
    foreach (it; 0 .. iters)
        foreach (wi; words)
            foreach (wj; words)
                if (wi == wj) total++;
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

final class Node {
    Node left, right;
    long item;
    this(Node left, Node right, long item) { this.left = left; this.right = right; this.item = item; }
}

Node makeTree(long item, int depth) {
    if (depth == 0) return new Node(null, null, item);
    return new Node(makeTree(2 * item - 1, depth - 1), makeTree(2 * item, depth - 1), item);
}

long checkTree(Node n) {
    if (n.left is null) return n.item;
    return n.item + checkTree(n.left) - checkTree(n.right);
}

long benchBinaryTrees(int maxDepth) {
    long checksum = 0;
    {
        auto stretch = makeTree(0, maxDepth + 1);
        checksum += checkTree(stretch);
    }
    auto longLived = makeTree(0, maxDepth);
    for (int d = treeMinDepth; d <= maxDepth; d += 2) {
        int iters = 1 << (maxDepth - d + treeMinDepth);
        foreach (i; 0 .. iters)
            checksum += checkTree(makeTree(i + 1, d));
    }
    checksum += checkTree(longLived);
    return checksum;
}

void main() {
    auto sw = StopWatch(AutoStart.yes);
    long r;
    r = benchPrimes(primesLimit);          report("primes", r, secs(sw)); sw.reset();
    r = fib(fibonacciN);                   report("fib", r, secs(sw)); sw.reset();
    r = benchStrings(sentenceText, stringIter); report("strings", r, secs(sw)); sw.reset();
    r = benchMandelbrot(mandelSize);       report("mandelbrot", r, secs(sw)); sw.reset();
    r = benchBinaryTrees(treeMaxDepth);    report("binarytrees", r, secs(sw));
}
