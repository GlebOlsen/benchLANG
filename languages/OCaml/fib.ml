let rec fib n =
  if n <= 1 then n
  else fib (n-1) + fib (n-2)

let () =
  let start_time = Unix.gettimeofday () in
  let _ = fib 45 in
  let end_time = Unix.gettimeofday () in
  Printf.printf "Execution time: %f seconds\n" (end_time -. start_time)
