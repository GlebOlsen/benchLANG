function isPrime(n) {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 === 0 || n % 3 === 0) return false;
    let i = 5;
    while (i * i <= n) {
        if (n % i === 0 || n % (i + 2) === 0) return false;
        i += 6;
    }
    return true;
}

const startTime = Date.now();
for (let i = 2; i < 10000000; i++) {
    if (isPrime(i)) {
        console.log(i);
    }
}
const endTime = Date.now();
console.log((endTime - startTime) / 1000, "seconds to execute");
