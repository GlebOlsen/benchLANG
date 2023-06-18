import time
start = time.time()
def fib(n): 
	if n <= 1:
		return n
	return fib(n-1) + fib(n-2)
fib(45)
end = time.time()
print((end-start) * 10**3, 'ms')
