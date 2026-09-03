package main

import (
	"fmt"
	"strings"
	"time"
)

const (
	primesLimit   = 20_000_000
	fibonacciN    = 45
	stringIter    = 5_000_000
	mandelSize    = 4096
	mandelMaxIter = 256
	treeMinDepth  = 4
	treeMaxDepth  = 18
	sentenceText  = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"
)

func report(name string, checksum int64, secs float64) {
	fmt.Printf("%s %d %.3f\n", name, checksum, secs)
}

func isPrime(n int32) bool {
	if n < 2 {
		return false
	}
	if n < 4 {
		return true
	}
	if n%2 == 0 || n%3 == 0 {
		return false
	}
	for i := int32(5); i*i <= n; i += 6 {
		if n%i == 0 || n%(i+2) == 0 {
			return false
		}
	}
	return true
}

func benchPrimes(limit int32) int64 {
	var count int64
	for i := int32(2); i < limit; i++ {
		if isPrime(i) {
			count++
		}
	}
	return count
}

func fib(n int) int64 {
	if n < 2 {
		return int64(n)
	}
	return fib(n-1) + fib(n-2)
}

func benchStrings(sentence string, iters int) int64 {
	words := strings.Split(sentence, " ")
	var total int64
	for it := 0; it < iters; it++ {
		for _, wi := range words {
			for _, wj := range words {
				if wi == wj {
					total++
				}
			}
		}
	}
	return total
}

// Explicit float64() conversions force IEEE rounding of each product so the
// compiler cannot fuse them into FMA (Go spec permits fusion otherwise).
func benchMandelbrot(size int) int64 {
	var checksum int64
	for py := 0; py < size; py++ {
		cy := float64(py)/float64(size)*3.0 - 1.5
		for px := 0; px < size; px++ {
			cx := float64(px)/float64(size)*3.0 - 2.0
			zx, zy := 0.0, 0.0
			iter := 0
			for iter < mandelMaxIter && float64(zx*zx)+float64(zy*zy) <= 4.0 {
				nx := float64(zx*zx) - float64(zy*zy) + cx
				zy = float64(2.0*zx*zy) + cy
				zx = nx
				iter++
			}
			checksum += int64(iter)
		}
	}
	return checksum
}

type node struct {
	left, right *node
	item        int64
}

func makeTree(item int64, depth int) *node {
	if depth == 0 {
		return &node{nil, nil, item}
	}
	return &node{makeTree(2*item-1, depth-1), makeTree(2*item, depth-1), item}
}

func checkTree(n *node) int64 {
	if n.left == nil {
		return n.item
	}
	return n.item + checkTree(n.left) - checkTree(n.right)
}

func benchBinaryTrees(maxDepth int) int64 {
	var checksum int64
	stretch := makeTree(0, maxDepth+1)
	checksum += checkTree(stretch)
	longLived := makeTree(0, maxDepth)
	for d := treeMinDepth; d <= maxDepth; d += 2 {
		iters := 1 << (maxDepth - d + treeMinDepth)
		for i := 0; i < iters; i++ {
			checksum += checkTree(makeTree(int64(i+1), d))
		}
	}
	checksum += checkTree(longLived)
	return checksum
}

func main() {
	var t time.Time
	var r int64
	t = time.Now()
	r = benchPrimes(primesLimit)
	report("primes", r, time.Since(t).Seconds())
	t = time.Now()
	r = fib(fibonacciN)
	report("fib", r, time.Since(t).Seconds())
	t = time.Now()
	r = benchStrings(sentenceText, stringIter)
	report("strings", r, time.Since(t).Seconds())
	t = time.Now()
	r = benchMandelbrot(mandelSize)
	report("mandelbrot", r, time.Since(t).Seconds())
	t = time.Now()
	r = benchBinaryTrees(treeMaxDepth)
	report("binarytrees", r, time.Since(t).Seconds())
}
