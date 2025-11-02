package main

import (
	"fmt"
	"strings"
	"time"
)

const (
	PRIMES_LIMIT = 20000000
	FIBONACCI_N  = 45
	SENTENCE     = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"
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

func benchmarkStrings() {
	fmt.Println("Running String Benchmark...")
	start := time.Now()
	words := strings.Fields(SENTENCE)
	wordsCount := len(words)
	var matchCount int64 = 0
	var reverseCount int64 = 0
	
	for i := 0; i < PRIMES_LIMIT; i++ {
		currentWord := words[i%wordsCount]
		
		// Compare current word against all other words
		for _, otherWord := range words {
			if currentWord == otherWord {
				matchCount++
			}
		}
		
		// Extract and reverse each word from sentence
		currentChars := make([]rune, 0, 20)
		for _, c := range SENTENCE {
			if c == ' ' {
				if len(currentChars) > 0 {
					// Reverse the word
					for j := 0; j < len(currentChars); j++ {
						_ = currentChars[len(currentChars)-1-j]
					}
					reverseCount += int64(len(currentChars))
					currentChars = currentChars[:0]
				}
			} else {
				currentChars = append(currentChars, c)
			}
		}
		// Handle last word
		if len(currentChars) > 0 {
			for j := 0; j < len(currentChars); j++ {
				_ = currentChars[len(currentChars)-1-j]
			}
			reverseCount += int64(len(currentChars))
		}
	}
	
	fmt.Printf("Matches: %d, reverse char count: %d in %.3f seconds\n\n", matchCount, reverseCount, time.Since(start).Seconds())
}

func main() {
	fmt.Println("=== PROGRAMMING LANGUAGE BENCHMARK ===\n")
	total := time.Now()
	benchmarkPrimes()
	benchmarkFibonacci()
	benchmarkStrings()
	fmt.Println("=== BENCHMARK COMPLETE ===")
	fmt.Printf("Total execution time: %.3f seconds\n", time.Since(total).Seconds())
}
