const std = @import("std");

const PRIMES_LIMIT: u32 = 20_000_000;
const FIBONACCI_N: i32 = 45;
const MATRIX_SIZE: usize = 2000;
const MATRIX_RAND_MAX: u32 = 100;
const SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";
const STRING_OPS: usize = 200_000_000;
const STRING_REDUCTION_FACTOR: usize = 100;
const SORT_SIZE: usize = 10_000_000;
const RAND_SEED: u64 = 42;

// Static arrays for better performance (like C)
var matrix_a: [MATRIX_SIZE * MATRIX_SIZE]f64 = undefined;
var matrix_b: [MATRIX_SIZE * MATRIX_SIZE]f64 = undefined;
var matrix_c: [MATRIX_SIZE * MATRIX_SIZE]f64 = undefined;
var sort_array: [SORT_SIZE]i32 = undefined;

pub fn main() !void {
    const stdout = std.debug.print;
    stdout("=== COMPREHENSIVE PROGRAMMING LANGUAGE BENCHMARK ===\n\n", .{});

    const total_start = std.time.milliTimestamp();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Initialize standard library RNG with seed (Zig 0.16 API)
    var prng = std.Random.Xoshiro256.init(RAND_SEED);
    const rand = prng.random();

    try benchmarkPrimes();
    try benchmarkFibonacci();
    try benchmarkMatrixMultiplication(rand);
    try benchmarkSorting(rand);
    try benchmarkStringOperations(allocator);

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

fn benchmarkMatrixMultiplication(rand: std.Random) !void {
    const stdout = std.debug.print;
    stdout("Running Matrix Multiplication Benchmark ({}x{})...\n", .{ MATRIX_SIZE, MATRIX_SIZE });
    const start = std.time.milliTimestamp();

    const n = MATRIX_SIZE;
    const elems = n * n;

    // Use static global arrays (no allocation overhead)
    for (0..elems) |i| {
        matrix_a[i] = @as(f64, @floatFromInt(rand.intRangeAtMost(u32, 0, MATRIX_RAND_MAX - 1)));
        matrix_b[i] = @as(f64, @floatFromInt(rand.intRangeAtMost(u32, 0, MATRIX_RAND_MAX - 1)));
        matrix_c[i] = 0;
    }

    // Optimized matrix multiplication with pre-calculated indices
    for (0..n) |i| {
        const in = i * n;
        for (0..n) |k| {
            const aik = matrix_a[in + k];
            const kn = k * n;
            for (0..n) |j| {
                matrix_c[in + j] += aik * matrix_b[kn + j];
            }
        }
    }

    const end = std.time.milliTimestamp();
    stdout("Matrix multiplication completed in {d:.3} seconds\n\n", .{@as(f64, @floatFromInt(end - start)) / 1000.0});
}

fn benchmarkSorting(rand: std.Random) !void {
    const stdout = std.debug.print;
    stdout("Running Sorting Benchmark ({} elements)...\n", .{SORT_SIZE});
    const start = std.time.milliTimestamp();

    // Use static global array (no allocation overhead)
    for (0..SORT_SIZE) |i| {
        sort_array[i] = @intCast(rand.int(u31));
    }

    std.mem.sort(i32, &sort_array, {}, comptime std.sort.asc(i32));

    const end = std.time.milliTimestamp();
    stdout("Sorting completed in {d:.3} seconds\n\n", .{@as(f64, @floatFromInt(end - start)) / 1000.0});
}

fn benchmarkStringOperations(allocator: std.mem.Allocator) !void {
    const stdout = std.debug.print;
    stdout("Running String Operations Benchmark ({} operations)...\n", .{STRING_OPS});
    const start = std.time.milliTimestamp();

    const sentence = SENTENCE;
    const append_count: usize = STRING_OPS / STRING_REDUCTION_FACTOR;
    const max_size = append_count * sentence.len + 1;
    var result = try allocator.alloc(u8, max_size);
    defer allocator.free(result);

    var write_pos: usize = 0;
    for (0..append_count) |_| {
        @memcpy(result[write_pos .. write_pos + sentence.len], sentence);
        write_pos += sentence.len;
    }
    result[write_pos] = 0;
    const haystack = result[0..write_pos];

    const sentence_copy = try allocator.dupe(u8, sentence);
    defer allocator.free(sentence_copy);

    var total_found: usize = 0;
    var word_it = std.mem.tokenizeScalar(u8, sentence_copy, ' ');
    while (word_it.next()) |word| {
        if (word.len == 0 or word.len > haystack.len) continue;
        var found_count: usize = 0;

        // Use std.mem.indexOf for faster string searching (similar to strstr)
        var search_start: usize = 0;
        while (search_start < haystack.len) {
            if (std.mem.indexOf(u8, haystack[search_start..], word)) |pos| {
                found_count += 1;
                search_start += pos + 1;
            } else {
                break;
            }
        }
        total_found += found_count;
    }

    const end = std.time.milliTimestamp();
    stdout("String operations completed in {d:.3} seconds (found {} word instances)\n\n", .{ @as(f64, @floatFromInt(end - start)) / 1000.0, total_found });
}
