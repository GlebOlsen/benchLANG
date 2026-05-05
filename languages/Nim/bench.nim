import times, strutils

const
  PRIMES_LIMIT    = 20_000_000
  FIBONACCI_N     = 45
  STRING_ITER     = 5_000_000
  MANDEL_W        = 4096
  MANDEL_H        = 4096
  MANDEL_MAX_ITER = 256
  TREE_MIN_DEPTH  = 4
  TREE_MAX_DEPTH  = 18
  SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"

proc fmtSec(s: float): string = formatFloat(s, ffDecimal, 3)

proc isPrime(n: int): bool =
  if n <= 1: return false
  if n <= 3: return true
  if n mod 2 == 0 or n mod 3 == 0: return false
  var i = 5
  while i*i <= n:
    if n mod i == 0 or n mod (i+2) == 0: return false
    i += 6
  true

proc benchPrimes() =
  let s = cpuTime()
  var c = 0
  for i in 2 ..< PRIMES_LIMIT:
    if isPrime(i): inc c
  echo "Found ", c, " primes in ", fmtSec(cpuTime()-s), " seconds\n"

proc fib(n: int): int64 =
  if n <= 1: int64(n) else: fib(n-1) + fib(n-2)

proc benchFibRec() =
  let s = cpuTime()
  let r = fib(FIBONACCI_N)
  echo "Fibonacci(", FIBONACCI_N, ") = ", r, " in ", fmtSec(cpuTime()-s), " seconds\n"

proc benchStrings() =
  let s = cpuTime()
  let words = SENTENCE.split(' ')
  let wcount = words.len
  var total: uint64 = 0
  for iter in 0 ..< STRING_ITER:
    for i in 0 ..< wcount:
      var count: uint64 = 0
      for j in 0 ..< wcount:
        if words[i] == words[j]: inc count
      total += count
  echo "Strings: total=", total, " in ", fmtSec(cpuTime()-s), " seconds\n"

proc benchMandelbrot() =
  let s = cpuTime()
  var checksum: int64 = 0
  for py in 0 ..< MANDEL_H:
    let cy = (float64(py) / float64(MANDEL_H)) * 3.0 - 1.5
    for px in 0 ..< MANDEL_W:
      let cx = (float64(px) / float64(MANDEL_W)) * 3.0 - 2.0
      var zx = 0.0
      var zy = 0.0
      var iter = 0
      while iter < MANDEL_MAX_ITER and zx * zx + zy * zy <= 4.0:
        let nx = zx * zx - zy * zy + cx
        zy = 2.0 * zx * zy + cy
        zx = nx
        inc iter
      checksum += int64(iter)
  echo "Mandelbrot: checksum=", checksum, " in ", fmtSec(cpuTime()-s), " seconds\n"

type Node = ref object
  left, right: Node
  item: int64

proc makeTree(item: int64, depth: int): Node =
  if depth == 0:
    return Node(left: nil, right: nil, item: item)
  Node(left: makeTree(2*item - 1, depth - 1),
       right: makeTree(2*item, depth - 1),
       item: item)

proc itemCheck(n: Node): int64 =
  if n.left == nil: return n.item
  n.item + itemCheck(n.left) - itemCheck(n.right)

proc benchBinaryTrees() =
  let s = cpuTime()
  var checksum: int64 = 0

  block:
    let stretch = makeTree(0, TREE_MAX_DEPTH + 1)
    checksum += itemCheck(stretch)

  let longLived = makeTree(0, TREE_MAX_DEPTH)

  var d = TREE_MIN_DEPTH
  while d <= TREE_MAX_DEPTH:
    let iters = 1 shl (TREE_MAX_DEPTH - d + TREE_MIN_DEPTH)
    var sum: int64 = 0
    for i in 0 ..< iters:
      sum += itemCheck(makeTree(int64(i + 1), d))
    checksum += sum
    d += 2

  checksum += itemCheck(longLived)

  echo "BinaryTrees: checksum=", checksum, " in ", fmtSec(cpuTime()-s), " seconds\n"

when isMainModule:
  echo "=== PROGRAMMING LANGUAGE BENCHMARK ===\n"
  let total = cpuTime()
  benchPrimes()
  benchFibRec()
  benchStrings()
  benchMandelbrot()
  benchBinaryTrees()
  echo "=== BENCHMARK COMPLETE ==="
  echo "Total execution time: ", fmtSec(cpuTime()-total), " seconds"
