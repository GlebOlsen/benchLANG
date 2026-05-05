const std = @import("std");
const c = @cImport({
    @cInclude("time.h");
});

const PRIMES_LIMIT: u32 = 20_000_000;
const FIBONACCI_N: u32 = 45;
const STRING_ITER: u32 = 5_000_000;
const MANDEL_W: usize = 4096;
const MANDEL_H: usize = 4096;
const MANDEL_MAX_ITER: i32 = 256;
const TREE_MIN_DEPTH: i32 = 4;
const TREE_MAX_DEPTH: i32 = 18;
const SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

fn nowSec() f64 {
    var ts: c.timespec = undefined;
    _ = c.clock_gettime(c.CLOCK_MONOTONIC, &ts);
    return @as(f64, @floatFromInt(ts.tv_sec)) + @as(f64, @floatFromInt(ts.tv_nsec)) / 1e9;
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

fn benchPrimes() void {
    const out = std.debug.print;
    const start = nowSec();
    var c_count: u32 = 0;
    var i: u32 = 2;
    while (i < PRIMES_LIMIT) : (i += 1) if (isPrime(i)) { c_count += 1; };
    out("Found {} primes in {d:.3} seconds\n\n", .{ c_count, nowSec() - start });
}

fn fib(n: u32) u64 { return if (n <= 1) @as(u64, n) else fib(n - 1) + fib(n - 2); }
fn benchFibRec() void {
    const out = std.debug.print;
    const start = nowSec();
    const r = fib(FIBONACCI_N);
    out("Fibonacci({}) = {} in {d:.3} seconds\n\n", .{ FIBONACCI_N, r, nowSec() - start });
}

fn benchStrings() void {
    const out = std.debug.print;
    const start = nowSec();

    var words: [32][]const u8 = undefined;
    var wcount: usize = 0;
    var iter = std.mem.tokenizeScalar(u8, SENTENCE, ' ');
    while (iter.next()) |w| {
        words[wcount] = w;
        wcount += 1;
    }

    var total: u64 = 0;
    var k: u32 = 0;
    while (k < STRING_ITER) : (k += 1) {
        var i: usize = 0;
        while (i < wcount) : (i += 1) {
            var count: u64 = 0;
            var j: usize = 0;
            while (j < wcount) : (j += 1) {
                if (std.mem.eql(u8, words[i], words[j])) count += 1;
            }
            total += count;
        }
    }
    out("Strings: total={} in {d:.3} seconds\n\n", .{ total, nowSec() - start });
}

fn benchMandelbrot() void {
    const out = std.debug.print;
    const start = nowSec();
    var checksum: i64 = 0;
    var py: usize = 0;
    while (py < MANDEL_H) : (py += 1) {
        const cy: f64 = (@as(f64, @floatFromInt(py)) / @as(f64, @floatFromInt(MANDEL_H))) * 3.0 - 1.5;
        var px: usize = 0;
        while (px < MANDEL_W) : (px += 1) {
            const cx: f64 = (@as(f64, @floatFromInt(px)) / @as(f64, @floatFromInt(MANDEL_W))) * 3.0 - 2.0;
            var zx: f64 = 0.0;
            var zy: f64 = 0.0;
            var iter: i32 = 0;
            while (iter < MANDEL_MAX_ITER and zx * zx + zy * zy <= 4.0) : (iter += 1) {
                const nx = zx * zx - zy * zy + cx;
                zy = 2.0 * zx * zy + cy;
                zx = nx;
            }
            checksum += @as(i64, iter);
        }
    }
    out("Mandelbrot: checksum={} in {d:.3} seconds\n\n", .{ checksum, nowSec() - start });
}

const TreeNode = struct {
    left: ?*TreeNode,
    right: ?*TreeNode,
    item: i64,
};

fn makeTree(allocator: std.mem.Allocator, item: i64, depth: i32) !*TreeNode {
    const n = try allocator.create(TreeNode);
    if (depth == 0) {
        n.* = .{ .left = null, .right = null, .item = item };
        return n;
    }
    n.* = .{
        .left = try makeTree(allocator, 2 * item - 1, depth - 1),
        .right = try makeTree(allocator, 2 * item, depth - 1),
        .item = item,
    };
    return n;
}

fn checkTree(n: *TreeNode) i64 {
    if (n.left == null) return n.item;
    return n.item + checkTree(n.left.?) - checkTree(n.right.?);
}

fn freeTree(allocator: std.mem.Allocator, n: *TreeNode) void {
    if (n.left) |l| {
        freeTree(allocator, l);
        freeTree(allocator, n.right.?);
    }
    allocator.destroy(n);
}

fn benchBinaryTrees() !void {
    const out = std.debug.print;
    const start = nowSec();
    const allocator = std.heap.c_allocator;
    var checksum: i64 = 0;

    {
        const stretch = try makeTree(allocator, 0, TREE_MAX_DEPTH + 1);
        checksum += checkTree(stretch);
        freeTree(allocator, stretch);
    }

    const long_lived = try makeTree(allocator, 0, TREE_MAX_DEPTH);

    var d: i32 = TREE_MIN_DEPTH;
    while (d <= TREE_MAX_DEPTH) : (d += 2) {
        const iters: i32 = @as(i32, 1) << @intCast(TREE_MAX_DEPTH - d + TREE_MIN_DEPTH);
        var sum: i64 = 0;
        var i: i32 = 0;
        while (i < iters) : (i += 1) {
            const t = try makeTree(allocator, @as(i64, i + 1), d);
            sum += checkTree(t);
            freeTree(allocator, t);
        }
        checksum += sum;
    }

    checksum += checkTree(long_lived);
    freeTree(allocator, long_lived);

    out("BinaryTrees: checksum={} in {d:.3} seconds\n\n", .{ checksum, nowSec() - start });
}

pub fn main() !void {
    const out = std.debug.print;
    out("=== PROGRAMMING LANGUAGE BENCHMARK ===\n\n", .{});

    const start = nowSec();
    benchPrimes();
    benchFibRec();
    benchStrings();
    benchMandelbrot();
    try benchBinaryTrees();
    out("=== BENCHMARK COMPLETE ===\n", .{});
    out("Total execution time: {d:.3} seconds\n", .{nowSec() - start});
}
