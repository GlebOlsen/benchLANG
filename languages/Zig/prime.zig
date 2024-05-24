const std = @import("std");

fn isPrime(n: i32) bool {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (@rem(n, 2) == 0 or @rem(n, 3) == 0) return false;
    var i: i32 = 5;
    while (i * i <= n) : (i += 6) {
        if (@rem(n, i) == 0 or @rem(n, i + 2) == 0) return false;
    }
    return true;
}

pub fn main() void {
    const stdout = std.io.getStdOut().writer();
    const start_time = std.time.milliTimestamp();
    var i: i32 = 2;
    while (i < 10000000) : (i += 1) {
        if (isPrime(i)) {
            stdout.print("{}\n", .{i}) catch {};
        }
    }
    const end_time = std.time.milliTimestamp();
    const elapsed = end_time - start_time;
    stdout.print("{} milliseconds to execute\n", .{elapsed}) catch {};
}
