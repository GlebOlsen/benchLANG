import times, strutils

const
  PRIMES_LIMIT = 20_000_000
  FIBONACCI_N = 45
  SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"

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

proc benchmarkStrings() =
  echo "Running String Benchmark..."
  let start = cpuTime()
  let words = SENTENCE.split(' ')
  let wordsCount = words.len
  var matchCount: int64 = 0
  var reverseCount: int64 = 0
  
  for i in 0 ..< PRIMES_LIMIT:
    let currentWord = words[i mod wordsCount]
    
    # Compare current word against all other words
    for otherWord in words:
      if currentWord == otherWord:
        inc matchCount
    
    # Extract and reverse each word from sentence
    var currentChars: seq[char] = @[]
    for c in SENTENCE:
      if c == ' ':
        if currentChars.len > 0:
          # Reverse the word
          for j in 0 ..< currentChars.len:
            let temp = currentChars[currentChars.len - 1 - j]
          reverseCount += currentChars.len
          currentChars.setLen(0)
      else:
        currentChars.add(c)
    # Handle last word
    if currentChars.len > 0:
      for j in 0 ..< currentChars.len:
        let temp = currentChars[currentChars.len - 1 - j]
      reverseCount += currentChars.len
  
  echo "Matches: ", matchCount, ", reverse char count: ", reverseCount, " in ", formatFloat(cpuTime()-start, ffDecimal, 3), " seconds\n"

when isMainModule:
  echo "=== PROGRAMMING LANGUAGE BENCHMARK ===\n"
  let total = cpuTime()
  benchmarkPrimes()
  benchmarkFibonacci()
  benchmarkStrings()
  echo "=== BENCHMARK COMPLETE ==="
  echo "Total execution time: ", formatFloat(cpuTime()-total, ffDecimal, 3), " seconds"