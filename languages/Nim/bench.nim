import std/[monotimes, strutils]

const
  PrimesLimit = 20_000_000'i32
  FibonacciN = 45
  StringIter = 5_000_000
  MandelSize = 4096
  MandelMaxIter = 256
  TreeMinDepth = 4
  TreeMaxDepth = 18
  Sentence = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"

proc now(): float = getMonoTime().ticks.float / 1e9

proc report(name: string, checksum: int64, secs: float) =
  echo name, " ", checksum, " ", formatFloat(secs, ffDecimal, 3)

proc isPrime(n: int32): bool =
  if n < 2: return false
  if n < 4: return true
  if n mod 2 == 0 or n mod 3 == 0: return false
  var i = 5'i32
  while i * i <= n:
    if n mod i == 0 or n mod (i + 2) == 0: return false
    i += 6
  true

proc benchPrimes(limit: int32): int64 =
  for i in 2'i32 ..< limit:
    if isPrime(i): inc result

proc fib(n: int): int64 =
  if n < 2: int64(n) else: fib(n - 1) + fib(n - 2)

proc benchStrings(sentence: string, iters: int): int64 =
  let words = sentence.split(' ')
  for it in 0 ..< iters:
    for wi in words:
      for wj in words:
        if wi == wj: inc result

proc benchMandelbrot(size: int): int64 =
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

proc makeTree(item: int64, depth: int): Node =
  if depth == 0:
    return Node(item: item)
  Node(left: makeTree(2 * item - 1, depth - 1),
       right: makeTree(2 * item, depth - 1),
       item: item)

proc checkTree(n: Node): int64 =
  if n.left == nil: return n.item
  n.item + checkTree(n.left) - checkTree(n.right)

proc benchBinaryTrees(maxDepth: int): int64 =
  block:
    let stretch = makeTree(0, maxDepth + 1)
    result += checkTree(stretch)
  let longLived = makeTree(0, maxDepth)
  var d = TreeMinDepth
  while d <= maxDepth:
    let iters = 1 shl (maxDepth - d + TreeMinDepth)
    for i in 0 ..< iters:
      result += checkTree(makeTree(int64(i + 1), d))
    d += 2
  result += checkTree(longLived)

when isMainModule:
  var t: float
  var r: int64
  t = now(); r = benchPrimes(PrimesLimit);          report("primes", r, now() - t)
  t = now(); r = fib(FibonacciN);                    report("fib", r, now() - t)
  t = now(); r = benchStrings(Sentence, StringIter); report("strings", r, now() - t)
  t = now(); r = benchMandelbrot(MandelSize);        report("mandelbrot", r, now() - t)
  t = now(); r = benchBinaryTrees(TreeMaxDepth);     report("binarytrees", r, now() - t)
