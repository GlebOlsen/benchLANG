package main
import (
	"fmt" 
	"time"
)
func main() {
	start := time.Now()
	i, j, n := 0, 0, 10000000
	for i = 2; i <= n; i++ { 
		for j = 2; j <= (i/j); j++ {
			if i%j == 0 {
				break
			}
		}
		if j > (i/j) {
			fmt.Println(i)
		}
	}
	elapsed := time.Since(start)
	fmt.Println(elapsed)
}