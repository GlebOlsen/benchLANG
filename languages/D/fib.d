import std.stdio;
import std.datetime;

int fib(int n) {
    if (n <= 1) return n;
    return fib(n - 1) + fib(n - 2);
}

void main() {
    auto startTime = Clock.currTime;
    fib(45);
    auto endTime = Clock.currTime;
    auto duration = endTime - startTime;
    writeln(duration.total!"seconds", " seconds to execute");
}
