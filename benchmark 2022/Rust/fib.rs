use std::time::Instant;
fn fib(n: i32) -> i32 {
    if n <= 1 {
        return n;
    }
    fib(n - 1) + fib(n - 2)
}
fn main() {
    let start_time = Instant::now();
    let n = 45;
    fib(n);
    let elapsed_time = start_time.elapsed();
    let time_taken = elapsed_time.as_secs_f64();
    println!("{} seconds to execute", time_taken);
}
