open Printf

let primes_limit = 20_000_000
let fibonacci_n = 45

let is_prime n =
  if n <= 1 then false
  else if n <= 3 then true
  else if n mod 2 = 0 || n mod 3 = 0 then false
  else
    let rec loop i =
      if i * i > n then true
      else if n mod i = 0 || n mod (i + 2) = 0 then false
      else loop (i + 6)
    in loop 5

let benchmark_primes () =
  printf "Running Prime Numbers Benchmark (up to %d)...\n" primes_limit;
  let start = Unix.gettimeofday () in
  let count = ref 0 in
  for i = 2 to primes_limit - 1 do
    if is_prime i then incr count
  done;
  printf "Found %d primes in %.3f seconds\n\n" !count (Unix.gettimeofday () -. start)

let rec fib n = if n <= 1 then n else fib (n-1) + fib (n-2)

let benchmark_fibonacci () =
  printf "Running Fibonacci Benchmark (n=%d, recursive)...\n" fibonacci_n;
  let start = Unix.gettimeofday () in
  let r = fib fibonacci_n in
  printf "Fibonacci(%d) = %d in %.3f seconds\n\n" fibonacci_n r (Unix.gettimeofday () -. start)

let () =
  printf "=== PROGRAMMING LANGUAGE BENCHMARK ===\n\n";
  let total = Unix.gettimeofday () in
  benchmark_primes();
  benchmark_fibonacci();
  printf "=== BENCHMARK COMPLETE ===\n";
  printf "Total execution time: %.3f seconds\n" (Unix.gettimeofday () -. total)