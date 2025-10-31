import times, strutils

const
  PRIMES_LIMIT = 20_000_000
  FIBONACCI_N = 45

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

when isMainModule:
  echo "=== PROGRAMMING LANGUAGE BENCHMARK ===\n"
  let total = cpuTime()
  benchmarkPrimes()
  benchmarkFibonacci()
  echo "=== BENCHMARK COMPLETE ==="
  echo "Total execution time: ", formatFloat(cpuTime()-total, ffDecimal, 3), " seconds"