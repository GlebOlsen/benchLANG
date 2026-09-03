const std = @import("std");

const PRIMES_LIMIT: u32 = 20_000_000;
const FIBONACCI_N: u32 = 45;
const STRING_ITER: u32 = 5_000_000;
const MANDEL_SIZE: usize = 4096;
const MANDEL_MAX_ITER: i32 = 256;
const TREE_MIN_DEPTH: i32 = 4;
const TREE_MAX_DEPTH: i32 = 18;
const MAX_WORDS = 32;
const SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

fn now(io: std.Io) f64 {
    const ts = std.Io.Clock.now(.awake, io);
    return @as(f64, @floatFromInt(ts.nanoseconds)) / 1e9;
}

fn report(out: *std.Io.Writer, name: []const u8, checksum: i64, secs: f64) !void {
    try out.print("{s} {d} {d:.3}\n", .{ name, checksum, secs });
    try out.flush();
}

fn isPrime(n: u32) bool {
    if (n < 2) return false;
    if (n < 4) return true;
    if (n % 2 == 0 or n % 3 == 0) return false;
    var i: u32 = 5;
    while (i * i <= n) : (i += 6) {
        if (n % i == 0 or n % (i + 2) == 0) return false;
    }
    return true;
}

fn benchPrimes(limit: u32) i64 {
    var count: i64 = 0;
    var i: u32 = 2;
    while (i < limit) : (i += 1) {
        if (isPrime(i)) count += 1;
    }
    return count;
}

fn fib(n: u32) i64 {
    return if (n < 2) @as(i64, n) else fib(n - 1) + fib(n - 2);
}

fn benchStrings(sentence: []const u8, iters: u32) i64 {
    var words: [MAX_WORDS][]const u8 = undefined;
    var wcount: usize = 0;
    var tok = std.mem.tokenizeScalar(u8, sentence, ' ');
    while (tok.next()) |w| {
        if (wcount == MAX_WORDS) break;
        words[wcount] = w;
        wcount += 1;
    }
    var total: i64 = 0;
    var it: u32 = 0;
    while (it < iters) : (it += 1) {
        for (words[0..wcount]) |wi| {
            for (words[0..wcount]) |wj| {
                if (std.mem.eql(u8, wi, wj)) total += 1;
            }
        }
    }
    return total;
}

fn benchMandelbrot(size: usize) i64 {
    var checksum: i64 = 0;
    const fsize: f64 = @floatFromInt(size);
    for (0..size) |py| {
        const cy = @as(f64, @floatFromInt(py)) / fsize * 3.0 - 1.5;
        for (0..size) |px| {
            const cx = @as(f64, @floatFromInt(px)) / fsize * 3.0 - 2.0;
            var zx: f64 = 0.0;
            var zy: f64 = 0.0;
            var iter: i32 = 0;
            while (iter < MANDEL_MAX_ITER and zx * zx + zy * zy <= 4.0) : (iter += 1) {
                const nx = zx * zx - zy * zy + cx;
                zy = 2.0 * zx * zy + cy;
                zx = nx;
            }
            checksum += iter;
        }
    }
    return checksum;
}

const Node = struct {
    left: ?*Node,
    right: ?*Node,
    item: i64,
};

fn makeTree(allocator: std.mem.Allocator, item: i64, depth: i32) !*Node {
    const n = try allocator.create(Node);
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

fn checkTree(n: *const Node) i64 {
    const left = n.left orelse return n.item;
    return n.item + checkTree(left) - checkTree(n.right.?);
}

fn freeTree(allocator: std.mem.Allocator, n: *Node) void {
    if (n.left) |l| {
        freeTree(allocator, l);
        freeTree(allocator, n.right.?);
    }
    allocator.destroy(n);
}

fn benchBinaryTrees(allocator: std.mem.Allocator, max_depth: i32) !i64 {
    var checksum: i64 = 0;
    const stretch = try makeTree(allocator, 0, max_depth + 1);
    checksum += checkTree(stretch);
    freeTree(allocator, stretch);
    const long_lived = try makeTree(allocator, 0, max_depth);
    var d: i32 = TREE_MIN_DEPTH;
    while (d <= max_depth) : (d += 2) {
        const iters = @as(i32, 1) << @intCast(max_depth - d + TREE_MIN_DEPTH);
        var i: i32 = 0;
        while (i < iters) : (i += 1) {
            const t = try makeTree(allocator, i + 1, d);
            checksum += checkTree(t);
            freeTree(allocator, t);
        }
    }
    checksum += checkTree(long_lived);
    freeTree(allocator, long_lived);
    return checksum;
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = std.heap.c_allocator;

    var buf: [256]u8 = undefined;
    var w = std.Io.File.stdout().writer(io, &buf);
    const out = &w.interface;

    var t: f64 = undefined;
    var r: i64 = undefined;
    t = now(io);
    r = benchPrimes(PRIMES_LIMIT);
    try report(out, "primes", r, now(io) - t);
    t = now(io);
    r = fib(FIBONACCI_N);
    try report(out, "fib", r, now(io) - t);
    t = now(io);
    r = benchStrings(SENTENCE, STRING_ITER);
    try report(out, "strings", r, now(io) - t);
    t = now(io);
    r = benchMandelbrot(MANDEL_SIZE);
    try report(out, "mandelbrot", r, now(io) - t);
    t = now(io);
    r = try benchBinaryTrees(allocator, TREE_MAX_DEPTH);
    try report(out, "binarytrees", r, now(io) - t);
}
