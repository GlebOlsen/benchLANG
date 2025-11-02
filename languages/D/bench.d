import std.stdio, std.datetime.stopwatch, std.format, std.string, std.array;

enum PRIMES_LIMIT = 20_000_000;
enum FIBONACCI_N = 45;
enum SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

// Helper to format a Duration in fractional seconds with 3 decimals
string fmtSeconds(Duration d) {
    double secs = cast(double)d.total!"nsecs" / 1_000_000_000.0;
    return format("%.3f", secs);
}

bool isPrime(int n) {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    int i = 5;
    while (cast(long)i * i <= n) {
        if (n % i == 0 || n % (i + 2) == 0) return false;
        i += 6;
    }
    return true;
}

void benchmarkPrimes() {
    writeln("Running Prime Numbers Benchmark (up to ", PRIMES_LIMIT, ")...");
    StopWatch sw; sw.start();
    int count;
    foreach (i; 2 .. PRIMES_LIMIT) if (isPrime(i)) ++count;
    sw.stop();
    writeln("Found ", count, " primes in ", fmtSeconds(sw.peek()), " seconds\n");
}

int fib(int n) { return n <= 1 ? n : fib(n-1) + fib(n-2); }

void benchmarkFibonacci() {
    writeln("Running Fibonacci Benchmark (n=", FIBONACCI_N, ", recursive)...");
    StopWatch sw; sw.start();
    auto r = fib(FIBONACCI_N);
    sw.stop();
    writeln("Fibonacci(", FIBONACCI_N, ") = ", r, " in ", fmtSeconds(sw.peek()), " seconds\n");
}

void benchmarkStrings() {
    writeln("Running String Benchmark...");
    StopWatch sw; sw.start();
    auto words = SENTENCE.split();
    int wordsCount = cast(int)words.length;
    long matchCount = 0;
    long reverseCount = 0;
    
    foreach (i; 0 .. PRIMES_LIMIT) {
        auto currentWord = words[i % wordsCount];
        
        // Compare current word against all other words
        foreach (otherWord; words) {
            if (currentWord == otherWord) {
                matchCount++;
            }
        }
        
        // Extract and reverse each word from sentence
        char[100] currentChars;
        int charIdx = 0;
        foreach (c; SENTENCE) {
            if (c == ' ') {
                if (charIdx > 0) {
                    // Reverse the word
                    foreach (j; 0 .. charIdx) {
                        auto temp = currentChars[charIdx - 1 - j];
                    }
                    reverseCount += charIdx;
                    charIdx = 0;
                }
            } else {
                currentChars[charIdx++] = c;
            }
        }
        // Handle last word
        if (charIdx > 0) {
            foreach (j; 0 .. charIdx) {
                auto temp = currentChars[charIdx - 1 - j];
            }
            reverseCount += charIdx;
        }
    }
    
    sw.stop();
    writeln("Matches: ", matchCount, ", reverse char count: ", reverseCount, " in ", fmtSeconds(sw.peek()), " seconds\n");
}

void main() {
    writeln("=== PROGRAMMING LANGUAGE BENCHMARK (D) ===\n");
    StopWatch total; total.start();
    benchmarkPrimes();
    benchmarkFibonacci();
    benchmarkStrings();
    total.stop();
    writeln("=== BENCHMARK COMPLETE ===");
    writeln("Total execution time: ", fmtSeconds(total.peek()), " seconds");
}