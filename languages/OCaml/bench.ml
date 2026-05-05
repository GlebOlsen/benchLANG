open Printf

let primes_limit = 20_000_000
let fibonacci_n = 45
let string_iter = 5_000_000
let mandel_w = 4096
let mandel_h = 4096
let mandel_max_iter = 256
let tree_min_depth = 4
let tree_max_depth = 18
let sentence = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"

let now () = Unix.gettimeofday ()

let is_prime n =
  if n <= 1 then false
  else if n <= 3 then true
  else if n mod 2 = 0 || n mod 3 = 0 then false
  else
    let i = ref 5 in
    let p = ref true in
    while !p && !i * !i <= n do
      if n mod !i = 0 || n mod (!i + 2) = 0 then p := false
      else i := !i + 6
    done;
    !p

let bench_primes () =
  let s = now () in
  let c = ref 0 in
  for i = 2 to primes_limit - 1 do if is_prime i then incr c done;
  printf "Found %d primes in %.3f seconds\n\n" !c (now () -. s)

let rec fib n = if n <= 1 then n else fib (n - 1) + fib (n - 2)
let bench_fib_rec () =
  let s = now () in
  let r = fib fibonacci_n in
  printf "Fibonacci(%d) = %d in %.3f seconds\n\n" fibonacci_n r (now () -. s)

let bench_strings () =
  let s = now () in
  let words = Array.of_list (String.split_on_char ' ' sentence) in
  let wcount = Array.length words in
  let total = ref 0 in
  for _ = 0 to string_iter - 1 do
    for i = 0 to wcount - 1 do
      let count = ref 0 in
      let wi = words.(i) in
      for j = 0 to wcount - 1 do
        if wi = words.(j) then incr count
      done;
      total := !total + !count
    done
  done;
  printf "Strings: total=%d in %.3f seconds\n\n" !total (now () -. s)

let bench_mandelbrot () =
  let s = now () in
  let checksum = ref 0 in
  for py = 0 to mandel_h - 1 do
    let cy = (float_of_int py /. float_of_int mandel_h) *. 3.0 -. 1.5 in
    for px = 0 to mandel_w - 1 do
      let cx = (float_of_int px /. float_of_int mandel_w) *. 3.0 -. 2.0 in
      let zx = ref 0.0 in
      let zy = ref 0.0 in
      let iter = ref 0 in
      while !iter < mandel_max_iter && !zx *. !zx +. !zy *. !zy <= 4.0 do
        let nx = !zx *. !zx -. !zy *. !zy +. cx in
        zy := 2.0 *. !zx *. !zy +. cy;
        zx := nx;
        incr iter
      done;
      checksum := !checksum + !iter
    done
  done;
  printf "Mandelbrot: checksum=%d in %.3f seconds\n\n" !checksum (now () -. s)

type tree = Empty | Node of tree * tree * int

let rec make_tree item depth =
  if depth = 0 then Node (Empty, Empty, item)
  else Node (make_tree (2 * item - 1) (depth - 1), make_tree (2 * item) (depth - 1), item)

let rec check_tree = function
  | Node (Empty, _, item) -> item
  | Node (l, r, item) -> item + check_tree l - check_tree r
  | Empty -> 0

let bench_binary_trees () =
  let s = now () in
  let checksum = ref 0 in
  (let stretch = make_tree 0 (tree_max_depth + 1) in
   checksum := !checksum + check_tree stretch);
  let long_lived = make_tree 0 tree_max_depth in
  let d = ref tree_min_depth in
  while !d <= tree_max_depth do
    let iters = 1 lsl (tree_max_depth - !d + tree_min_depth) in
    let sum = ref 0 in
    for i = 0 to iters - 1 do
      let t = make_tree (i + 1) !d in
      sum := !sum + check_tree t
    done;
    checksum := !checksum + !sum;
    d := !d + 2
  done;
  checksum := !checksum + check_tree long_lived;
  printf "BinaryTrees: checksum=%d in %.3f seconds\n\n" !checksum (now () -. s)

let () =
  printf "=== PROGRAMMING LANGUAGE BENCHMARK ===\n\n";
  let s = now () in
  bench_primes ();
  bench_fib_rec ();
  bench_strings ();
  bench_mandelbrot ();
  bench_binary_trees ();
  printf "=== BENCHMARK COMPLETE ===\n";
  printf "Total execution time: %.3f seconds\n" (now () -. s)
