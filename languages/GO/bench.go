package main

import (
	"cmp"
	"fmt"
	"slices"
	"strings"
	"time"
)

const (
	primesLimit   = 8_000_000
	fibonacciN    = 43
	stringIter    = 1_200_000
	mandelSize    = 2048
	mandelMaxIter = 256
	treeMinDepth  = 4
	treeMaxDepth  = 17
	sentenceText  = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"
	knucLength    = 6_000_000
	knucSeed      = 42
	knucIM        = 139968
	knucIA        = 3877
	knucIC        = 29573
	knucQuery     = "GGTATTTTAATTTATAGT"
)

func bench(name string, work func() int64) {
	start := time.Now()
	checksum := work()
	fmt.Printf("%s %d %.3f\n", name, checksum, time.Since(start).Seconds())
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
	cur := slices.Clone(words)
	var total int64
	for it := range iters {
		i := it % len(words)
		b := []byte(cur[i])
		slices.Reverse(b)
		cur[i] = string(b)
		for _, wi := range cur {
			for _, wj := range words {
				if wi == wj {
					total++
				}
			}
		}
	}
	return total
}

func benchMandelbrot(size int) int64 {
	var checksum int64
	for py := range size {
		cy := float64(py)/float64(size)*3.0 - 1.5
		for px := range size {
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
	checksum := checkTree(makeTree(0, maxDepth+1))
	longLived := makeTree(0, maxDepth)
	for d := treeMinDepth; d <= maxDepth; d += 2 {
		for i := range 1 << (maxDepth - d + treeMinDepth) {
			checksum += checkTree(makeTree(int64(i+1), d))
		}
	}
	return checksum + checkTree(longLived)
}

type kmerCount struct {
	key   string
	count int
}

func benchKnucleotide(length int) int64 {
	buf := make([]byte, length)
	seed := int32(knucSeed)
	for i := range buf {
		seed = (seed*knucIA + knucIC) % knucIM
		switch {
		case seed < 42404:
			buf[i] = 'A'
		case seed < 70116:
			buf[i] = 'C'
		case seed < 97766:
			buf[i] = 'G'
		default:
			buf[i] = 'T'
		}
	}
	seq := string(buf)
	var checksum int64
	for _, k := range []int{1, 2, 3, 4, 6, 12, 18} {
		counts := make(map[string]int)
		for i := range length - k + 1 {
			counts[seq[i:i+k]]++
		}
		checksum += int64(len(counts))
		if k <= 2 {
			var entries []kmerCount
			for key, count := range counts {
				entries = append(entries, kmerCount{key, count})
			}
			slices.SortFunc(entries, func(a, b kmerCount) int {
				return cmp.Or(cmp.Compare(b.count, a.count), cmp.Compare(a.key, b.key))
			})
			for r, e := range entries {
				checksum += int64(r+1) * int64(e.count)
			}
		} else {
			checksum += int64(counts[knucQuery[:k]])
		}
	}
	return checksum
}

func main() {
	bench("primes", func() int64 { return benchPrimes(primesLimit) })
	bench("fib", func() int64 { return fib(fibonacciN) })
	bench("strings", func() int64 { return benchStrings(sentenceText, stringIter) })
	bench("mandelbrot", func() int64 { return benchMandelbrot(mandelSize) })
	bench("binarytrees", func() int64 { return benchBinaryTrees(treeMaxDepth) })
	bench("knucleotide", func() int64 { return benchKnucleotide(knucLength) })
}
