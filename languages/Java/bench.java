public class bench {
    // Constants
    private static final int PRIMES_LIMIT = 20000000;
    private static final int FIBONACCI_N = 45;

    public static void main(String[] args) {
        System.out.println("=== PROGRAMMING LANGUAGE BENCHMARK ===\n");
        
        long totalStart = System.currentTimeMillis();
        
        benchmarkPrimes();
        benchmarkFibonacci();
        
        long totalEnd = System.currentTimeMillis();
        
        System.out.println("=== BENCHMARK COMPLETE ===");
        System.out.printf("Total execution time: %.3f seconds%n", (totalEnd - totalStart) / 1000.0);
    }

    // Optimized prime checking function
    private static boolean isPrime(int n) {
        if (n <= 1)
            return false;
        if (n <= 3)
            return true;
        if (n % 2 == 0 || n % 3 == 0)
            return false;
        int i = 5;
        while (i * i <= n) {
            if (n % i == 0 || n % (i + 2) == 0)
                return false;
            i += 6;
        }
        return true;
    }

    // 1. Prime number calculation using optimized algorithm
    private static void benchmarkPrimes() {
        System.out.printf("Running Prime Numbers Benchmark (up to %d)...%n", PRIMES_LIMIT);
        long start = System.currentTimeMillis();
        
        int primeCount = 0;
        for (int i = 2; i < PRIMES_LIMIT; i++) {
            if (isPrime(i)) {
                primeCount++;
            }
        }
        
        long end = System.currentTimeMillis();
        System.out.printf("Found %d primes in %.3f seconds%n%n", primeCount, (end - start) / 1000.0);
    }

    // 2. Fibonacci calculation (recursive)
    private static int fib(int n) {
        if (n <= 1) {
            return n;
        }
        return fib(n - 1) + fib(n - 2);
    }

    private static void benchmarkFibonacci() {
        System.out.printf("Running Fibonacci Benchmark (n=%d, recursive)...%n", FIBONACCI_N);
        long start = System.currentTimeMillis();
        
        int result = fib(FIBONACCI_N);
        
        long end = System.currentTimeMillis();
        System.out.printf("Fibonacci(%d) = %d in %.3f seconds%n%n", FIBONACCI_N, result, (end - start) / 1000.0);
    }
}