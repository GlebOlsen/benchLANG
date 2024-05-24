function fib(n) {
    if (n <= 1) return n;
    return fib(n - 1) + fib(n - 2);
}

const startTime = Date.now();
fib(45);
const endTime = Date.now();
console.log((endTime - startTime) / 1000, " seconds to execute");
