const std = @import("std");

const PRIMES_LIMIT: u32 = 20_000_000;
const FIBONACCI_N: i32 = 45;
const SENTENCE: []const u8 = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

pub fn main() !void {
    const stdout = std.debug.print;
    stdout("=== PROGRAMMING LANGUAGE BENCHMARK ===\n\n", .{});

    const total_start = std.time.milliTimestamp();

    try benchmarkPrimes();
    try benchmarkFibonacci();
    try benchmarkStrings();

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

fn benchmarkStrings() !void {
    const stdout = std.debug.print;
    stdout("Running String Benchmark...\n", .{});
    const start = std.time.milliTimestamp();

    var words: [20][]const u8 = undefined;
    var words_count: usize = 0;
    var iter = std.mem.tokenizeScalar(u8, SENTENCE, ' ');
    while (iter.next()) |word| {
        words[words_count] = word;
        words_count += 1;
    }

    var match_count: u64 = 0;
    var reverse_count: u64 = 0;

    var i: u32 = 0;
    while (i < PRIMES_LIMIT) : (i += 1) {
        const current_word = words[i % words_count];

        // Compare current word against all other words
        for (words[0..words_count]) |other_word| {
            if (std.mem.eql(u8, current_word, other_word)) {
                match_count += 1;
            }
        }

        // Extract and reverse each word from sentence
        var current_chars: [100]u8 = undefined;
        var char_idx: usize = 0;
        for (SENTENCE) |c| {
            if (c == ' ') {
                if (char_idx > 0) {
                    // Reverse the word
                    var rev_idx: usize = 0;
                    while (rev_idx < char_idx) : (rev_idx += 1) {
                        _ = current_chars[char_idx - 1 - rev_idx];
                    }
                    reverse_count += char_idx;
                    char_idx = 0;
                }
            } else {
                current_chars[char_idx] = c;
                char_idx += 1;
            }
        }
        // Handle last word
        if (char_idx > 0) {
            var rev_idx: usize = 0;
            while (rev_idx < char_idx) : (rev_idx += 1) {
                _ = current_chars[char_idx - 1 - rev_idx];
            }
            reverse_count += char_idx;
        }
    }

    const end = std.time.milliTimestamp();
    stdout("Matches: {}, reverse char count: {} in {d:.3} seconds\n\n", .{ match_count, reverse_count, @as(f64, @floatFromInt(end - start)) / 1000.0 });
}
