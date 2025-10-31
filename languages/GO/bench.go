package main

import (
	"fmt"
	"math/rand"
	"sort"
	"strings"
	"time"
)

// Standardized constants (match C benchmark)
const (
	PRIMES_LIMIT            = 20000000
	FIBONACCI_N             = 45
	MATRIX_SIZE             = 2000
	MATRIX_RAND_MAX         = 100
	SENTENCE                = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"
	STRING_OPS              = 200000000
	STRING_REDUCTION_FACTOR = 100
	SORT_SIZE               = 10000000
	RAND_SEED               = 42
)

// Prime check (unchanged logic)
func isPrime(n int) bool {
	if n <= 1 { return false }
	if n <= 3 { return true }
	if n%2 == 0 || n%3 == 0 { return false }
	for i := 5; i*i <= n; i += 6 {
		if n%i == 0 || n%(i+2) == 0 { return false }
	}
	return true
}

func benchmarkPrimes() {
	fmt.Printf("Running Prime Numbers Benchmark (up to %d)...\n", PRIMES_LIMIT)
	start := time.Now()
	count := 0
	for i := 2; i < PRIMES_LIMIT; i++ { if isPrime(i) { count++ } }
	fmt.Printf("Found %d primes in %.3f seconds\n\n", count, time.Since(start).Seconds())
}

func fib(n int) int { if n <= 1 { return n }; return fib(n-1)+fib(n-2) }

func benchmarkFibonacci() {
	fmt.Printf("Running Fibonacci Benchmark (n=%d, recursive)...\n", FIBONACCI_N)
	start := time.Now(); r := fib(FIBONACCI_N)
	fmt.Printf("Fibonacci(%d) = %d in %.3f seconds\n\n", FIBONACCI_N, r, time.Since(start).Seconds())
}

// Flat matrices to reduce overhead vs [][]
var matrixA = make([]float64, MATRIX_SIZE*MATRIX_SIZE)
var matrixB = make([]float64, MATRIX_SIZE*MATRIX_SIZE)
var matrixC = make([]float64, MATRIX_SIZE*MATRIX_SIZE)

func benchmarkMatrixMultiplication() {
	fmt.Printf("Running Matrix Multiplication Benchmark (%dx%d)...\n", MATRIX_SIZE, MATRIX_SIZE)
	start := time.Now()
	rand.Seed(RAND_SEED)
	n := MATRIX_SIZE; size := n * n
	for i := 0; i < size; i++ { matrixA[i] = float64(rand.Intn(MATRIX_RAND_MAX)); matrixB[i] = float64(rand.Intn(MATRIX_RAND_MAX)); matrixC[i] = 0 }
	for i := 0; i < n; i++ {
		in := i * n
		for k := 0; k < n; k++ { aik := matrixA[in+k]; kn := k * n; for j := 0; j < n; j++ { matrixC[in+j] += aik * matrixB[kn+j] } }
	}
	fmt.Printf("Matrix multiplication completed in %.3f seconds\n\n", time.Since(start).Seconds())
}

var sortArray = make([]int, SORT_SIZE)

func benchmarkSorting() {
	fmt.Printf("Running Sorting Benchmark (%d elements)...\n", SORT_SIZE)
	start := time.Now(); rand.Seed(RAND_SEED)
	for i := 0; i < SORT_SIZE; i++ { sortArray[i] = rand.Int() }
	sort.Ints(sortArray)
	fmt.Printf("Sorting completed in %.3f seconds\n\n", time.Since(start).Seconds())
}

// We'll add the actual sorting using a separate patch to include the missing import.

func benchmarkStringOperations() {
	fmt.Printf("Running String Operations Benchmark (%d operations)...\n", STRING_OPS)
	start := time.Now()
	repeats := STRING_OPS / STRING_REDUCTION_FACTOR
	// Pre-size builder capacity estimate
	var b strings.Builder
	b.Grow(len(SENTENCE) * repeats)
	for i := 0; i < repeats; i++ { b.WriteString(SENTENCE) }
	hay := b.String()
	words := strings.Split(SENTENCE, " ")
	total := 0
	for _, w := range words { wl := len(w); if wl == 0 || wl > len(hay) { continue }; found := 0; for i := 0; i+wl <= len(hay); i++ { if hay[i:i+wl] == w { found++ } }; total += found }
	fmt.Printf("String operations completed in %.3f seconds (found %d word instances)\n\n", time.Since(start).Seconds(), total)
}

func main() {
	fmt.Println("=== COMPREHENSIVE PROGRAMMING LANGUAGE BENCHMARK ===\n")
	total := time.Now()
	benchmarkPrimes()
	benchmarkFibonacci()
	benchmarkMatrixMultiplication()
	benchmarkSorting()
	benchmarkStringOperations()
	fmt.Println("=== BENCHMARK COMPLETE ===")
	fmt.Printf("Total execution time: %.3f seconds\n", time.Since(total).Seconds())
}
