package main

import (
	"fmt"
	"strings"
	"time"
)

const (
	PRIMES_LIMIT    = 20_000_000
	FIBONACCI_N     = 45
	STRING_ITER     = 5_000_000
	MANDEL_W        = 4096
	MANDEL_H        = 4096
	MANDEL_MAX_ITER = 256
	TREE_MIN_DEPTH  = 4
	TREE_MAX_DEPTH  = 18
	SENTENCE        = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"
)

func isPrime(n int) bool {
	if n <= 1 {
		return false
	}
	if n <= 3 {
		return true
	}
	if n%2 == 0 || n%3 == 0 {
		return false
	}
	for i := 5; i*i <= n; i += 6 {
		if n%i == 0 || n%(i+2) == 0 {
			return false
		}
	}
	return true
}

func benchPrimes() {
	s := time.Now()
	c := 0
	for i := 2; i < PRIMES_LIMIT; i++ {
		if isPrime(i) {
			c++
		}
	}
	fmt.Printf("Found %d primes in %.3f seconds\n\n", c, time.Since(s).Seconds())
}

func fib(n int) int64 {
	if n <= 1 {
		return int64(n)
	}
	return fib(n-1) + fib(n-2)
}
func benchFibRec() {
	s := time.Now()
	r := fib(FIBONACCI_N)
	fmt.Printf("Fibonacci(%d) = %d in %.3f seconds\n\n", FIBONACCI_N, r, time.Since(s).Seconds())
}

func benchStrings() {
	s := time.Now()
	words := strings.Split(SENTENCE, " ")
	wcount := len(words)
	var total uint64
	for iter := 0; iter < STRING_ITER; iter++ {
		for i := 0; i < wcount; i++ {
			var count uint64
			for j := 0; j < wcount; j++ {
				if words[i] == words[j] {
					count++
				}
			}
			total += count
		}
	}
	fmt.Printf("Strings: total=%d in %.3f seconds\n\n", total, time.Since(s).Seconds())
}

func benchMandelbrot() {
	s := time.Now()
	var checksum int64
	for py := 0; py < MANDEL_H; py++ {
		cy := (float64(py)/float64(MANDEL_H))*3.0 - 1.5
		for px := 0; px < MANDEL_W; px++ {
			cx := (float64(px)/float64(MANDEL_W))*3.0 - 2.0
			zx, zy := 0.0, 0.0
			iter := 0
			for iter < MANDEL_MAX_ITER && zx*zx+zy*zy <= 4.0 {
				nx := zx*zx - zy*zy + cx
				zy = 2.0*zx*zy + cy
				zx = nx
				iter++
			}
			checksum += int64(iter)
		}
	}
	fmt.Printf("Mandelbrot: checksum=%d in %.3f seconds\n\n", checksum, time.Since(s).Seconds())
}

type Node struct {
	left, right *Node
	item        int64
}

func makeTree(item int64, depth int) *Node {
	if depth == 0 {
		return &Node{nil, nil, item}
	}
	return &Node{makeTree(2*item-1, depth-1), makeTree(2*item, depth-1), item}
}

func checkTree(n *Node) int64 {
	if n.left == nil {
		return n.item
	}
	return n.item + checkTree(n.left) - checkTree(n.right)
}

func benchBinaryTrees() {
	s := time.Now()
	var checksum int64

	{
		stretch := makeTree(0, TREE_MAX_DEPTH+1)
		checksum += checkTree(stretch)
	}

	longLived := makeTree(0, TREE_MAX_DEPTH)

	for d := TREE_MIN_DEPTH; d <= TREE_MAX_DEPTH; d += 2 {
		iters := 1 << (TREE_MAX_DEPTH - d + TREE_MIN_DEPTH)
		var sum int64
		for i := 0; i < iters; i++ {
			t := makeTree(int64(i+1), d)
			sum += checkTree(t)
		}
		checksum += sum
	}

	checksum += checkTree(longLived)

	fmt.Printf("BinaryTrees: checksum=%d in %.3f seconds\n\n", checksum, time.Since(s).Seconds())
}

func main() {
	fmt.Printf("=== PROGRAMMING LANGUAGE BENCHMARK ===\n\n")
	s := time.Now()
	benchPrimes()
	benchFibRec()
	benchStrings()
	benchMandelbrot()
	benchBinaryTrees()
	fmt.Println("=== BENCHMARK COMPLETE ===")
	fmt.Printf("Total execution time: %.3f seconds\n", time.Since(s).Seconds())
}
