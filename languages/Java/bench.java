import java.util.*;

public class bench {
    // Constants
    private static final int PRIMES_LIMIT = 20000000;
    private static final int FIBONACCI_N = 45;
    private static final int MATRIX_SIZE = 2000;
    private static final int MATRIX_RAND_MAX = 100;
    private static final String SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";
    private static final int STRING_OPS = 200000000;
    private static final int STRING_REDUCTION_FACTOR = 100;
    private static final int SORT_SIZE = 10000000;
    private static final int RAND_SEED = 42;

    public static void main(String[] args) {
        System.out.println("=== COMPREHENSIVE PROGRAMMING LANGUAGE BENCHMARK ===\n");
        
        long totalStart = System.currentTimeMillis();
        
        benchmarkPrimes();
        benchmarkFibonacci();
        benchmarkMatrixMultiplication();
        benchmarkSorting();
        benchmarkStringOperations();
        
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

    // 3. Matrix multiplication
    private static void benchmarkMatrixMultiplication() {
        System.out.printf("Running Matrix Multiplication Benchmark (%dx%d)...%n", MATRIX_SIZE, MATRIX_SIZE);
        long start = System.currentTimeMillis();
        
        Random rand = new Random(RAND_SEED);
        int n = MATRIX_SIZE;
        int elems = n * n;
        double[] a = new double[elems];
        double[] b = new double[elems];
        double[] c = new double[elems];
        
        // Initialize matrices
        for (int i = 0; i < elems; i++) {
            a[i] = rand.nextInt(MATRIX_RAND_MAX);
            b[i] = rand.nextInt(MATRIX_RAND_MAX);
            c[i] = 0;
        }
        
        // Matrix multiplication (ijk order for cache efficiency)
        for (int i = 0; i < n; i++) {
            for (int k = 0; k < n; k++) {
                double aik = a[i * n + k];
                for (int j = 0; j < n; j++) {
                    c[i * n + j] += aik * b[k * n + j];
                }
            }
        }
        
        long end = System.currentTimeMillis();
        System.out.printf("Matrix multiplication completed in %.3f seconds%n%n", (end - start) / 1000.0);
    }

    // 4. Sorting
    private static void benchmarkSorting() {
        System.out.printf("Running Sorting Benchmark (%d elements)...%n", SORT_SIZE);
        long start = System.currentTimeMillis();
        
        Random rand = new Random(RAND_SEED);
        int[] arr = new int[SORT_SIZE];
        
        for (int i = 0; i < SORT_SIZE; i++) {
            arr[i] = rand.nextInt();
        }
        
        Arrays.sort(arr);
        
        long end = System.currentTimeMillis();
        System.out.printf("Sorting completed in %.3f seconds%n%n", (end - start) / 1000.0);
    }

    // 5. String operations
    private static void benchmarkStringOperations() {
        System.out.printf("Running String Operations Benchmark (%d operations)...%n", STRING_OPS);
        long start = System.currentTimeMillis();
        
        String sentence = SENTENCE;
        StringBuilder result = new StringBuilder();
        
        for (int i = 0; i < STRING_OPS / STRING_REDUCTION_FACTOR; i++) {
            result.append(sentence);
        }
        
        // Dynamic word extraction and searching (matching C's O(n*m) behavior)
        String resultString = result.toString();
        String[] words = sentence.split(" ");
        
        int totalFound = 0;
        for (String word : words) {
            int foundCount = 0;
            // Manual string search to match C's strstr behavior
            for (int i = 0; i <= resultString.length() - word.length(); i++) {
                if (resultString.substring(i, i + word.length()).equals(word)) {
                    foundCount++;
                }
            }
            totalFound += foundCount;
        }
        
        long end = System.currentTimeMillis();
        System.out.printf("String operations completed in %.3f seconds (found %d word instances)%n%n",
                (end - start) / 1000.0, totalFound);
    }
}