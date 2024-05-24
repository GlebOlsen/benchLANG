import times

proc fib(n: int): int =
    if n <= 1:
        return n
    return fib(n - 1) + fib(n - 2)

let startTime = cpuTime()
discard fib(45)
let endTime = cpuTime()
echo (endTime - startTime), " seconds to execute"
