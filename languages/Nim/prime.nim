import times

proc isPrime(n: int): bool =
    if n <= 1:
        return false
    if n <= 3:
        return true
    if n mod 2 == 0 or n mod 3 == 0:
        return false
    var i = 5
    while i * i <= n:
        if n mod i == 0 or n mod (i + 2) == 0:
            return false
        i += 6
    return true

let startTime = cpuTime()
for i in 2 ..< 10000000:
    if isPrime(i):
        echo i
let endTime = cpuTime()
echo (endTime - startTime), " seconds to execute"
