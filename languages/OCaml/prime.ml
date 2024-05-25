let is_prime n =
  let rec check_from i =
    i * i > n || (n mod i <> 0 && check_from (i + 1))
  in
  n > 1 && check_from 2

let () =
  let start_time = Unix.gettimeofday () in
  for i = 2 to 10000000 do
    if is_prime i then
      Printf.printf "%d\n" i
  done;
  let end_time = Unix.gettimeofday () in
  Printf.printf "Execution time: %f seconds\n" (end_time -. start_time)
