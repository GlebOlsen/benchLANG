use std::time::Instant;
fn is_prime(n: u32) -> bool {
    if n <= 1 {
        return false;
    }
    if n <= 3 {
        return true;
    }
    if n % 2 == 0 || n % 3 == 0 {
        return false;
    }
    let mut i = 5;
    while i * i <= n {
        if n % i == 0 || n % (i + 2) == 0 {
            return false;
        }
        i += 6;
    }
    true
}
fn main() {
    let start_time = Instant::now();
    for i in 2..10_000_000 {
        if is_prime(i) {
            println!("{}", i);
        }
    }
    let elapsed_time = start_time.elapsed();
    let time_taken = elapsed_time.as_secs_f64();
    println!("{} seconds to execute", time_taken);
}
