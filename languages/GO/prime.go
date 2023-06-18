package main
import (
	"fmt"
	"time"
)
func isPrime(n int) bool {
	if n < 2 {
		return false
	}
	if n == 2 {
		return true
	}
	if n%2 == 0 {
		return false
	}
	for i := 3; i*i <= n; i += 2 {
		if n%i == 0 {
			return false
		}
	}
	return true
}
func main() {
	start := time.Now()
	n := 10000000
	for i := 2; i <= n; i++ {
		if isPrime(i) {
			fmt.Println(i)
		}
	}
	elapsed := time.Since(start)
	fmt.Println(elapsed)
}
