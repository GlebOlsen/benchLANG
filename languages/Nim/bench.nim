import times, strutils, math, random, algorithm

const
  PRIMES_LIMIT = 20_000_000
  FIBONACCI_N = 45
  MATRIX_SIZE = 2000
  MATRIX_RAND_MAX = 100
  SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"
  STRING_OPS = 200_000_000
  STRING_REDUCTION_FACTOR = 100
  SORT_SIZE = 10_000_000
  RAND_SEED = 42

proc isPrime(n: int): bool =
  if n <= 1: return false
  if n <= 3: return true
  if n mod 2 == 0 or n mod 3 == 0: return false
  var i = 5
  while i*i <= n:
    if n mod i == 0 or n mod (i+2) == 0: return false
    i += 6
  true

proc benchmarkPrimes() =
  echo "Running Prime Numbers Benchmark (up to ", PRIMES_LIMIT, ")..."
  let start = cpuTime()
  var count = 0
  for i in 2 ..< PRIMES_LIMIT:
    if isPrime(i): inc count
  echo "Found ", count, " primes in ", formatFloat(cpuTime()-start, ffDecimal, 3), " seconds\n"

proc fib(n: int): int =
  if n <= 1: n else: fib(n-1)+fib(n-2)

proc benchmarkFibonacci() =
  echo "Running Fibonacci Benchmark (n=", FIBONACCI_N, ", recursive)..."
  let start = cpuTime()
  let r = fib(FIBONACCI_N)
  echo "Fibonacci(", FIBONACCI_N, ") = ", r, " in ", formatFloat(cpuTime()-start, ffDecimal, 3), " seconds\n"

var matrixA = newSeq[float64](MATRIX_SIZE*MATRIX_SIZE)
var matrixB = newSeq[float64](MATRIX_SIZE*MATRIX_SIZE)
var matrixC = newSeq[float64](MATRIX_SIZE*MATRIX_SIZE)

proc benchmarkMatrixMultiplication() =
  echo "Running Matrix Multiplication Benchmark (", MATRIX_SIZE, "x", MATRIX_SIZE, ")..."
  let start = cpuTime()
  randomize(RAND_SEED)
  let n = MATRIX_SIZE
  for i in 0 ..< n*n:
    matrixA[i] = rand(MATRIX_RAND_MAX-1).float64
    matrixB[i] = rand(MATRIX_RAND_MAX-1).float64
    matrixC[i] = 0
  for i in 0 ..< n:
    let inIdx = i * n
    for k in 0 ..< n:
      let aik = matrixA[inIdx + k]
      let knIdx = k * n
      for j in 0 ..< n:
        matrixC[inIdx + j] += aik * matrixB[knIdx + j]
  echo "Matrix multiplication completed in ", formatFloat(cpuTime()-start, ffDecimal, 3), " seconds\n"

var sortArray = newSeq[int](SORT_SIZE)

proc benchmarkSorting() =
  echo "Running Sorting Benchmark (", SORT_SIZE, " elements)..."
  let start = cpuTime()
  randomize(RAND_SEED)
  for i in 0 ..< SORT_SIZE: sortArray[i] = rand(high(int))
  sort(sortArray)
  echo "Sorting completed in ", formatFloat(cpuTime()-start, ffDecimal, 3), " seconds\n"

proc benchmarkStringOperations() =
  echo "Running String Operations Benchmark (", STRING_OPS, " operations)..."
  let start = cpuTime()
  let repeats = STRING_OPS div STRING_REDUCTION_FACTOR
  var sb = newStringOfCap(SENTENCE.len * repeats)
  for _ in 0 ..< repeats: sb.add SENTENCE
  let hay = sb
  let words = SENTENCE.split(' ')
  var total = 0
  for w in words:
    if w.len == 0 or w.len > hay.len: continue
    var found = 0
    for i in 0 .. hay.len - w.len:
        if hay[i ..< i + w.len] == w: inc found
    total += found
  echo "String operations completed in ", formatFloat(cpuTime()-start, ffDecimal, 3), " seconds (found ", total, " word instances)\n"

when isMainModule:
  echo "=== COMPREHENSIVE PROGRAMMING LANGUAGE BENCHMARK ===\n"
  let total = cpuTime()
  benchmarkPrimes()
  benchmarkFibonacci()
  benchmarkMatrixMultiplication()
  benchmarkSorting()
  benchmarkStringOperations()
  echo "=== BENCHMARK COMPLETE ==="
  echo "Total execution time: ", formatFloat(cpuTime()-total, ffDecimal, 3), " seconds"