import std.stdio;
import std.datetime;

bool isPrime(int n) {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    for (int i = 5; i * i <= n; i += 6) {
        if (n % i == 0 || n % (i + 2) == 0) return false;
    }
    return true;
}

void main() {
    auto startTime = Clock.currTime;
    foreach (i; 2 .. 10_000_000) {
        if (isPrime(i))
            writeln(i);
    }
    auto endTime = Clock.currTime;
    auto duration = endTime - startTime;
    writeln(duration.total!"seconds", " seconds to execute");
}
