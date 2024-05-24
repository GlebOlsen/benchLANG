const std = @import("std");

fn fib(n: i32) i32 {
    if (n <= 1) return n;
    return fib(n - 1) + fib(n - 2);
}

pub fn main() void {
    const stdout = std.io.getStdOut().writer();
    const start_time = std.time.milliTimestamp();
    _ = fib(45); // Discard the result of fib(45)
    const end_time = std.time.milliTimestamp();
    const elapsed = end_time - start_time;
    stdout.print("{} milliseconds to execute\n", .{elapsed}) catch {};
}
