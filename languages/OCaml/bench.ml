open Printf

let primes_limit = 20_000_000
let fibonacci_n = 45
let sentence = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"

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

let benchmark_strings () =
  printf "Running String Benchmark...\n";
  let start = Unix.gettimeofday () in
  let words = String.split_on_char ' ' sentence in
  let words_array = Array.of_list words in
  let words_count = Array.length words_array in
  let match_count = ref 0 in
  let reverse_count = ref 0 in
  
  for i = 0 to primes_limit - 1 do
    let current_word = words_array.(i mod words_count) in
    
    (* Compare current word against all other words *)
    Array.iter (fun other_word ->
      if current_word = other_word then
        incr match_count
    ) words_array;
    
    (* Extract and reverse each word from sentence *)
    let current_chars = ref [] in
    String.iter (fun c ->
      if c = ' ' then begin
        if List.length !current_chars > 0 then begin
          (* Reverse the word *)
          for j = 0 to List.length !current_chars - 1 do
            let _ = List.nth !current_chars (List.length !current_chars - 1 - j) in ()
          done;
          reverse_count := !reverse_count + List.length !current_chars;
          current_chars := []
        end
      end else
        current_chars := !current_chars @ [c]
    ) sentence;
    (* Handle last word *)
    if List.length !current_chars > 0 then begin
      for j = 0 to List.length !current_chars - 1 do
        let _ = List.nth !current_chars (List.length !current_chars - 1 - j) in ()
      done;
      reverse_count := !reverse_count + List.length !current_chars
    end
  done;
  
  printf "Matches: %d, reverse char count: %d in %.3f seconds\n\n" !match_count !reverse_count (Unix.gettimeofday () -. start)

let () =
  printf "=== PROGRAMMING LANGUAGE BENCHMARK ===\n\n";
  let total = Unix.gettimeofday () in
  benchmark_primes();
  benchmark_fibonacci();
  benchmark_strings();
  printf "=== BENCHMARK COMPLETE ===\n";
  printf "Total execution time: %.3f seconds\n" (Unix.gettimeofday () -. total)