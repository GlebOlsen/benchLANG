open Printf

let primes_limit = 20_000_000
let fibonacci_n = 45
let matrix_size = 2000
let matrix_rand_max = 100
let sentence = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"
let string_ops = 200_000_000
let string_reduction_factor = 100
let sort_size = 10_000_000
let rand_seed = 42

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

let benchmark_matrix_multiplication () =
  printf "Running Matrix Multiplication Benchmark (%dx%d)...\n" matrix_size matrix_size;
  let start = Unix.gettimeofday () in
  Random.init rand_seed;
  let n = matrix_size in
  let a = Array.make (n*n) 0. in
  let b = Array.make (n*n) 0. in
  let c = Array.make (n*n) 0. in
  for i = 0 to n*n - 1 do
    a.(i) <- float (Random.int matrix_rand_max);
    b.(i) <- float (Random.int matrix_rand_max);
  done;
  for i = 0 to n - 1 do
    let in_idx = i * n in
    for k = 0 to n - 1 do
      let aik = a.(in_idx + k) in
      let kn_idx = k * n in
      for j = 0 to n - 1 do
        c.(in_idx + j) <- c.(in_idx + j) +. aik *. b.(kn_idx + j)
      done
    done
  done;
  printf "Matrix multiplication completed in %.3f seconds\n\n" (Unix.gettimeofday () -. start)

let benchmark_sorting () =
  printf "Running Sorting Benchmark (%d elements)...\n" sort_size;
  let start = Unix.gettimeofday () in
  Random.init rand_seed;
  let arr = Array.init sort_size (fun _ -> Random.bits ()) in
  Array.sort compare arr;
  printf "Sorting completed in %.3f seconds\n\n" (Unix.gettimeofday () -. start)

let benchmark_string_operations () =
  printf "Running String Operations Benchmark (%d operations)...\n" string_ops;
  let start = Unix.gettimeofday () in
  let repeats = string_ops / string_reduction_factor in
  let buf = Buffer.create (String.length sentence * repeats) in
  for _ = 1 to repeats do Buffer.add_string buf sentence done;
  let hay = Buffer.contents buf in
  let words = String.split_on_char ' ' sentence in
  let total = ref 0 in
  List.iter (fun w ->
    let wl = String.length w in
    if wl > 0 && wl <= String.length hay then (
      let found = ref 0 in
      for i = 0 to String.length hay - wl do
        if String.sub hay i wl = w then incr found
      done;
      total := !total + !found
    )
  ) words;
  printf "String operations completed in %.3f seconds (found %d word instances)\n\n"
    (Unix.gettimeofday () -. start) !total

let () =
  printf "=== COMPREHENSIVE PROGRAMMING LANGUAGE BENCHMARK ===\n\n";
  let total = Unix.gettimeofday () in
  benchmark_primes();
  benchmark_fibonacci();
  benchmark_matrix_multiplication();
  benchmark_sorting();
  benchmark_string_operations();
  printf "=== BENCHMARK COMPLETE ===\n";
  printf "Total execution time: %.3f seconds\n" (Unix.gettimeofday () -. total)