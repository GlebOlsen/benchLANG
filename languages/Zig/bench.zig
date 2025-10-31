const std = @import("std");

const PRIMES_LIMIT: u32 = 20_000_000;
const FIBONACCI_N: i32 = 45;

pub fn main() !void {
    const stdout = std.debug.print;
    stdout("=== PROGRAMMING LANGUAGE BENCHMARK ===\n\n", .{});

    const total_start = std.time.milliTimestamp();

    try benchmarkPrimes();
    try benchmarkFibonacci();

    const total_end = std.time.milliTimestamp();

    stdout("=== BENCHMARK COMPLETE ===\n", .{});
    stdout("Total execution time: {d:.3} seconds\n", .{@as(f64, @floatFromInt(total_end - total_start)) / 1000.0});
}

fn isPrime(n: u32) bool {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 == 0 or n % 3 == 0) return false;
    var i: u32 = 5;
    while (i * i <= n) : (i += 6) {
        if (n % i == 0 or n % (i + 2) == 0) return false;
    }
    return true;
}

fn benchmarkPrimes() !void {
    const stdout = std.debug.print;
    stdout("Running Prime Numbers Benchmark (up to {})...\n", .{PRIMES_LIMIT});
    const start = std.time.milliTimestamp();

    var prime_count: u32 = 0;
    var i: u32 = 2;
    while (i < PRIMES_LIMIT) : (i += 1) {
        if (isPrime(i)) {
            prime_count += 1;
        }
    }

    const end = std.time.milliTimestamp();
    stdout("Found {} primes in {d:.3} seconds\n\n", .{ prime_count, @as(f64, @floatFromInt(end - start)) / 1000.0 });
}

fn fib(n: i32) i32 {
    @setRuntimeSafety(false);
    if (n <= 1) return n;
    return fib(n - 1) + fib(n - 2);
}

fn benchmarkFibonacci() !void {
    const stdout = std.debug.print;
    stdout("Running Fibonacci Benchmark (n={}, recursive)...\n", .{FIBONACCI_N});
    const start = std.time.milliTimestamp();

    const result = fib(FIBONACCI_N);

    const end = std.time.milliTimestamp();
    stdout("Fibonacci({}) = {} in {d:.3} seconds\n\n", .{ FIBONACCI_N, result, @as(f64, @floatFromInt(end - start)) / 1000.0 });
}
