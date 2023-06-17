package main
import (
	"fmt" 
	"time"
)
func main() {
	start := time.Now()
	fib(45)
	elapsed := time.Since(start)
	fmt.Println(elapsed)
}
func fib(n int) int {
	if n <= 1 {
		return n
	}
	return fib(n-1) + fib(n-2)
}