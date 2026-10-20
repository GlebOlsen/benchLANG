const std = @import("std");

const PRIMES_LIMIT: u32 = 8_000_000;
const FIBONACCI_N: u32 = 43;
const STRING_ITER: usize = 1_200_000;
const MANDEL_SIZE: usize = 2048;
const MANDEL_MAX_ITER: i32 = 256;
const TREE_MIN_DEPTH: i32 = 4;
const TREE_MAX_DEPTH: i32 = 17;
const MAX_WORDS = 32;
const SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";
const KNUC_LENGTH: usize = 6_000_000;
const KNUC_SEED: u32 = 42;
const KNUC_IM: u32 = 139968;
const KNUC_IA: u32 = 3877;
const KNUC_IC: u32 = 29573;
const KNUC_QUERY = "GGTATTTTAATTTATAGT";

fn now(io: std.Io) f64 {
    const ts = std.Io.Clock.now(.awake, io);
    return @as(f64, @floatFromInt(ts.nanoseconds)) / 1e9;
}

fn run(io: std.Io, out: *std.Io.Writer, name: []const u8, bench: anytype, args: anytype) !void {
    const t = now(io);
    const r: anyerror!i64 = @call(.auto, bench, args);
    const secs = now(io) - t;
    try out.print("{s} {d} {d:.3}\n", .{ name, try r, secs });
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

fn benchStrings(sentence: []const u8, iters: usize) i64 {
    var cbuf: [SENTENCE.len]u8 = undefined;
    @memcpy(&cbuf, sentence);
    var words: [MAX_WORDS][]const u8 = undefined;
    var cur: [MAX_WORDS][]u8 = undefined;
    var wcount: usize = 0;
    var tok = std.mem.tokenizeScalar(u8, sentence, ' ');
    while (tok.next()) |w| {
        if (wcount == MAX_WORDS) break;
        words[wcount] = w;
        cur[wcount] = cbuf[tok.index - w.len .. tok.index];
        wcount += 1;
    }
    var total: i64 = 0;
    for (0..iters) |it| {
        std.mem.reverse(u8, cur[it % wcount]);
        for (cur[0..wcount]) |wi| {
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

const KmerCount = struct {
    key: []const u8,
    count: i32,
};

fn kmerLessThan(_: void, a: KmerCount, b: KmerCount) bool {
    if (a.count != b.count) return a.count > b.count;
    return std.mem.lessThan(u8, a.key, b.key);
}

fn benchKnucleotide(allocator: std.mem.Allocator, length: usize) !i64 {
    const seq = try allocator.alloc(u8, length);
    defer allocator.free(seq);
    var seed: u32 = KNUC_SEED;
    for (seq) |*c| {
        seed = (seed * KNUC_IA + KNUC_IC) % KNUC_IM;
        c.* = if (seed < 42404) 'A' else if (seed < 70116) 'C' else if (seed < 97766) 'G' else 'T';
    }
    var checksum: i64 = 0;
    for ([_]usize{ 1, 2, 3, 4, 6, 12, 18 }) |k| {
        var counts: std.StringHashMapUnmanaged(i32) = .empty;
        defer counts.deinit(allocator);
        for (0..length - k + 1) |i| {
            const entry = try counts.getOrPutValue(allocator, seq[i .. i + k], 0);
            entry.value_ptr.* += 1;
        }
        checksum += counts.count();
        if (k <= 2) {
            var entries: std.ArrayList(KmerCount) = .empty;
            defer entries.deinit(allocator);
            var it = counts.iterator();
            while (it.next()) |e| try entries.append(allocator, .{ .key = e.key_ptr.*, .count = e.value_ptr.* });
            std.mem.sort(KmerCount, entries.items, {}, kmerLessThan);
            for (entries.items, 1..) |e, r| checksum += @as(i64, @intCast(r)) * e.count;
        } else if (counts.get(KNUC_QUERY[0..k])) |c| {
            checksum += c;
        }
    }
    return checksum;
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = std.heap.c_allocator;

    var buf: [256]u8 = undefined;
    var w = std.Io.File.stdout().writer(io, &buf);
    const out = &w.interface;

    try run(io, out, "primes", benchPrimes, .{PRIMES_LIMIT});
    try run(io, out, "fib", fib, .{FIBONACCI_N});
    try run(io, out, "strings", benchStrings, .{ SENTENCE, STRING_ITER });
    try run(io, out, "mandelbrot", benchMandelbrot, .{MANDEL_SIZE});
    try run(io, out, "binarytrees", benchBinaryTrees, .{ allocator, TREE_MAX_DEPTH });
    try run(io, out, "knucleotide", benchKnucleotide, .{ allocator, KNUC_LENGTH });
}
