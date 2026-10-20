import 'dart:typed_data';

const primesLimit = 8_000_000;
const fibonacciN = 43;
const stringIter = 1_200_000;
const mandelSize = 2048;
const mandelMaxIter = 256;
const treeMinDepth = 4;
const treeMaxDepth = 17;
const sentenceText =
    'The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again';
const knucLength = 6_000_000;
const knucSeed = 42;
const knucIm = 139968;
const knucIa = 3877;
const knucIc = 29573;
const knucQuery = 'GGTATTTTAATTTATAGT';

void report(String name, int checksum, double secs) =>
    print('$name $checksum ${secs.toStringAsFixed(3)}');

bool isPrime(int n) {
  if (n < 2) return false;
  if (n < 4) return true;
  if (n % 2 == 0 || n % 3 == 0) return false;
  for (var i = 5; i * i <= n; i += 6) {
    if (n % i == 0 || n % (i + 2) == 0) return false;
  }
  return true;
}

int benchPrimes(int limit) {
  var count = 0;
  for (var i = 2; i < limit; i++) {
    if (isPrime(i)) count++;
  }
  return count;
}

int fib(int n) => n < 2 ? n : fib(n - 1) + fib(n - 2);

int benchStrings(String sentence, int iters) {
  final words = sentence.split(' ');
  final cur = [...words];
  var total = 0;
  for (var it = 0; it < iters; it++) {
    final i = it % words.length;
    cur[i] = String.fromCharCodes(cur[i].codeUnits.reversed);
    for (final wi in cur) {
      for (final wj in words) {
        if (wi == wj) total++;
      }
    }
  }
  return total;
}

int benchMandelbrot(int size) {
  var checksum = 0;
  for (var py = 0; py < size; py++) {
    final cy = py / size * 3.0 - 1.5;
    for (var px = 0; px < size; px++) {
      final cx = px / size * 3.0 - 2.0;
      var zx = 0.0, zy = 0.0;
      var iter = 0;
      while (iter < mandelMaxIter && zx * zx + zy * zy <= 4.0) {
        final nx = zx * zx - zy * zy + cx;
        zy = 2.0 * zx * zy + cy;
        zx = nx;
        iter++;
      }
      checksum += iter;
    }
  }
  return checksum;
}

final class Node(final Node? left, final Node? right, final int item);

Node makeTree(int item, int depth) {
  if (depth == 0) return Node(null, null, item);
  return Node(makeTree(2 * item - 1, depth - 1), makeTree(2 * item, depth - 1), item);
}

int checkTree(Node n) {
  final left = n.left;
  if (left == null) return n.item;
  return n.item + checkTree(left) - checkTree(n.right!);
}

int benchBinaryTrees(int maxDepth) {
  var checksum = checkTree(makeTree(0, maxDepth + 1));
  final longLived = makeTree(0, maxDepth);
  for (var d = treeMinDepth; d <= maxDepth; d += 2) {
    final iters = 1 << (maxDepth - d + treeMinDepth);
    for (var i = 0; i < iters; i++) {
      checksum += checkTree(makeTree(i + 1, d));
    }
  }
  return checksum + checkTree(longLived);
}

int benchKnucleotide(int length) {
  const ks = [1, 2, 3, 4, 6, 12, 18];
  final buf = Uint8List(length);
  var seed = knucSeed;
  for (var i = 0; i < length; i++) {
    seed = (seed * knucIa + knucIc) % knucIm;
    buf[i] = seed < 42404 ? 65 : seed < 70116 ? 67 : seed < 97766 ? 71 : 84;
  }
  final seq = String.fromCharCodes(buf);
  var checksum = 0;
  for (final k in ks) {
    final counts = <String, int>{};
    for (var i = 0; i + k <= length; i++) {
      final key = seq.substring(i, i + k);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    checksum += counts.length;
    if (k <= 2) {
      final entries = counts.entries.toList()
        ..sort((a, b) => a.value != b.value ? b.value.compareTo(a.value) : a.key.compareTo(b.key));
      for (var r = 0; r < entries.length; r++) {
        checksum += (r + 1) * entries[r].value;
      }
    } else {
      checksum += counts[knucQuery.substring(0, k)] ?? 0;
    }
  }
  return checksum;
}

void main() {
  final sw = Stopwatch()..start();
  int r;
  r = benchPrimes(primesLimit);               report('primes', r, sw.elapsedMicroseconds / 1e6); sw.reset();
  r = fib(fibonacciN);                        report('fib', r, sw.elapsedMicroseconds / 1e6); sw.reset();
  r = benchStrings(sentenceText, stringIter); report('strings', r, sw.elapsedMicroseconds / 1e6); sw.reset();
  r = benchMandelbrot(mandelSize);            report('mandelbrot', r, sw.elapsedMicroseconds / 1e6); sw.reset();
  r = benchBinaryTrees(treeMaxDepth);         report('binarytrees', r, sw.elapsedMicroseconds / 1e6); sw.reset();
  r = benchKnucleotide(knucLength);           report('knucleotide', r, sw.elapsedMicroseconds / 1e6);
}
