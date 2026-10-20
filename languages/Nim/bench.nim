import std/[algorithm, monotimes, strutils, tables]

const
  PrimesLimit = 8_000_000'i32
  FibonacciN = 43
  StringIter = 1_200_000
  MandelSize = 2048
  MandelMaxIter = 256
  TreeMinDepth = 4
  TreeMaxDepth = 17
  Sentence = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"
  KnucLength = 6_000_000
  KnucSeed = 42'i32
  KnucIM = 139968'i32
  KnucIA = 3877'i32
  KnucIC = 29573'i32
  KnucKs = [1, 2, 3, 4, 6, 12, 18]
  KnucQuery = "GGTATTTTAATTTATAGT"

template bench(name: string, work: int64) =
  let start = getMonoTime().ticks
  let checksum = work
  let secs = float(getMonoTime().ticks - start) / 1e9
  echo name, " ", checksum, " ", formatFloat(secs, ffDecimal, 3)

func isPrime(n: int32): bool =
  if n < 2: return false
  if n < 4: return true
  if n mod 2 == 0 or n mod 3 == 0: return false
  var i = 5'i32
  while i * i <= n:
    if n mod i == 0 or n mod (i + 2) == 0: return false
    i += 6
  true

func benchPrimes(limit: int32): int64 =
  for i in 2'i32 ..< limit:
    if isPrime(i): inc result

func fib(n: int): int64 =
  if n < 2: int64(n) else: fib(n - 1) + fib(n - 2)

func benchStrings(sentence: string, iters: int): int64 =
  let words = sentence.split(' ')
  var cur = words
  for it in 0 ..< iters:
    cur[it mod cur.len].reverse()
    for wi in cur:
      for wj in words:
        if wi == wj: inc result

func benchMandelbrot(size: int): int64 =
  for py in 0 ..< size:
    let cy = float64(py) / float64(size) * 3.0 - 1.5
    for px in 0 ..< size:
      let cx = float64(px) / float64(size) * 3.0 - 2.0
      var zx = 0.0
      var zy = 0.0
      var iter = 0
      while iter < MandelMaxIter and zx * zx + zy * zy <= 4.0:
        let nx = zx * zx - zy * zy + cx
        zy = 2.0 * zx * zy + cy
        zx = nx
        inc iter
      result += int64(iter)

type Node = ref object
  left, right: Node
  item: int64

func makeTree(item: int64, depth: int): Node =
  if depth == 0: Node(item: item)
  else: Node(left: makeTree(2 * item - 1, depth - 1), right: makeTree(2 * item, depth - 1), item: item)

func checkTree(n: Node): int64 =
  if n.left == nil: n.item else: n.item + checkTree(n.left) - checkTree(n.right)

func benchBinaryTrees(maxDepth: int): int64 =
  result = checkTree(makeTree(0, maxDepth + 1))
  let longLived = makeTree(0, maxDepth)
  for d in countup(TreeMinDepth, maxDepth, 2):
    for i in 0 ..< 1 shl (maxDepth - d + TreeMinDepth):
      result += checkTree(makeTree(int64(i + 1), d))
  result += checkTree(longLived)

func benchKnucleotide(length: int): int64 =
  var sequence = newString(length)
  var seed = KnucSeed
  for i in 0 ..< length:
    seed = (seed * KnucIA + KnucIC) mod KnucIM
    sequence[i] = if seed < 42404: 'A' elif seed < 70116: 'C' elif seed < 97766: 'G' else: 'T'
  for k in KnucKs:
    var counts: Table[string, int]
    for i in 0 .. length - k:
      inc counts.mgetOrPut(sequence[i ..< i + k])
    result += counts.len
    if k <= 2:
      var entries: seq[(string, int)]
      for entry in counts.pairs:
        entries.add entry
      entries.sort(proc (a, b: (string, int)): int =
        if a[1] != b[1]: cmp(b[1], a[1]) else: cmp(a[0], b[0]))
      for r, e in entries:
        result += int64(r + 1) * e[1]
    else:
      result += counts.getOrDefault(KnucQuery[0 ..< k])

bench("primes", benchPrimes(PrimesLimit))
bench("fib", fib(FibonacciN))
bench("strings", benchStrings(Sentence, StringIter))
bench("mandelbrot", benchMandelbrot(MandelSize))
bench("binarytrees", benchBinaryTrees(TreeMaxDepth))
bench("knucleotide", benchKnucleotide(KnucLength))
