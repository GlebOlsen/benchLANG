let primes_limit = 20_000_000
let fibonacci_n = 45
let string_iter = 5_000_000
let mandel_size = 4096
let mandel_max_iter = 256
let tree_min_depth = 4
let tree_max_depth = 18
let sentence_text = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"

external now : unit -> float = "bench_now"
let report name checksum secs = Printf.printf "%s %d %.3f\n" name checksum secs

let is_prime n =
  if n < 2 then false
  else if n < 4 then true
  else if n mod 2 = 0 || n mod 3 = 0 then false
  else begin
    let i = ref 5 and p = ref true in
    while !p && !i * !i <= n do
      if n mod !i = 0 || n mod (!i + 2) = 0 then p := false else i := !i + 6
    done;
    !p
  end

let bench_primes limit =
  let count = ref 0 in
  for i = 2 to limit - 1 do if is_prime i then incr count done;
  !count

let rec fib n = if n < 2 then n else fib (n - 1) + fib (n - 2)

let bench_strings sentence iters =
  let words = Array.of_list (String.split_on_char ' ' sentence) in
  let wcount = Array.length words in
  let total = ref 0 in
  for _ = 1 to iters do
    for i = 0 to wcount - 1 do
      let wi = words.(i) in
      for j = 0 to wcount - 1 do
        if wi = words.(j) then incr total
      done
    done
  done;
  !total

let bench_mandelbrot size =
  let checksum = ref 0 in
  for py = 0 to size - 1 do
    let cy = float_of_int py /. float_of_int size *. 3.0 -. 1.5 in
    for px = 0 to size - 1 do
      let cx = float_of_int px /. float_of_int size *. 3.0 -. 2.0 in
      let zx = ref 0.0 and zy = ref 0.0 and iter = ref 0 in
      while !iter < mandel_max_iter && !zx *. !zx +. !zy *. !zy <= 4.0 do
        let nx = !zx *. !zx -. !zy *. !zy +. cx in
        zy := 2.0 *. !zx *. !zy +. cy;
        zx := nx;
        incr iter
      done;
      checksum := !checksum + !iter
    done
  done;
  !checksum

type tree = Empty | Node of tree * tree * int

let rec make_tree item depth =
  if depth = 0 then Node (Empty, Empty, item)
  else Node (make_tree (2 * item - 1) (depth - 1), make_tree (2 * item) (depth - 1), item)

let rec check_tree = function
  | Node (Empty, _, item) -> item
  | Node (l, r, item) -> item + check_tree l - check_tree r
  | Empty -> 0

let bench_binary_trees max_depth =
  let checksum = ref 0 in
  checksum := !checksum + check_tree (make_tree 0 (max_depth + 1));
  let long_lived = make_tree 0 max_depth in
  let d = ref tree_min_depth in
  while !d <= max_depth do
    let iters = 1 lsl (max_depth - !d + tree_min_depth) in
    for i = 0 to iters - 1 do
      checksum := !checksum + check_tree (make_tree (i + 1) !d)
    done;
    d := !d + 2
  done;
  !checksum + check_tree long_lived

let () =
  let timed name f =
    let t = now () in
    let r = f () in
    report name r (now () -. t)
  in
  timed "primes" (fun () -> bench_primes primes_limit);
  timed "fib" (fun () -> fib fibonacci_n);
  timed "strings" (fun () -> bench_strings sentence_text string_iter);
  timed "mandelbrot" (fun () -> bench_mandelbrot mandel_size);
  timed "binarytrees" (fun () -> bench_binary_trees tree_max_depth)
