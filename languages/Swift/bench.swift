let primesLimit: Int32 = 8_000_000
let fibonacciN = 43
let stringIter = 1_200_000
let mandelSize = 2048
let mandelMaxIter = 256
let treeMinDepth = 4
let treeMaxDepth = 17
let sentence = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"
let knucLength = 6_000_000
let knucSeed: Int32 = 42
let knucIM: Int32 = 139_968
let knucIA: Int32 = 3877
let knucIC: Int32 = 29573
let knucQuery = "GGTATTTTAATTTATAGT"

func bench(_ name: String, _ work: () -> Int64) {
    let start = SuspendingClock.now
    let checksum = work()
    let millis = Int(((SuspendingClock.now - start) / .milliseconds(1)).rounded())
    let frac = String(millis % 1000)
    print("\(name) \(checksum) \(millis / 1000).\(String(repeating: "0", count: 3 - frac.count))\(frac)")
}

func isPrime(_ n: Int32) -> Bool {
    if n < 2 { return false }
    if n < 4 { return true }
    if n % 2 == 0 || n % 3 == 0 { return false }
    var i: Int32 = 5
    while i * i <= n {
        if n % i == 0 || n % (i + 2) == 0 { return false }
        i += 6
    }
    return true
}

func benchPrimes(_ limit: Int32) -> Int64 {
    var count: Int64 = 0
    for i in 2..<limit where isPrime(i) {
        count += 1
    }
    return count
}

func fib(_ n: Int) -> Int64 {
    n < 2 ? Int64(n) : fib(n - 1) + fib(n - 2)
}

func benchStrings(_ sentence: String, _ iters: Int) -> Int64 {
    let words = sentence.split(separator: " ").map(String.init)
    var cur = words
    var total: Int64 = 0
    for it in 0..<iters {
        let i = it % words.count
        cur[i] = String(cur[i].reversed())
        for wi in cur {
            for wj in words where wi == wj {
                total += 1
            }
        }
    }
    return total
}

func benchMandelbrot(_ size: Int) -> Int64 {
    var checksum: Int64 = 0
    for py in 0..<size {
        let cy = Double(py) / Double(size) * 3.0 - 1.5
        for px in 0..<size {
            let cx = Double(px) / Double(size) * 3.0 - 2.0
            var zx = 0.0
            var zy = 0.0
            var iter = 0
            while iter < mandelMaxIter && zx * zx + zy * zy <= 4.0 {
                let nx = zx * zx - zy * zy + cx
                zy = 2.0 * zx * zy + cy
                zx = nx
                iter += 1
            }
            checksum += Int64(iter)
        }
    }
    return checksum
}

final class Node {
    let left: Node?
    let right: Node?
    let item: Int64

    init(_ item: Int64, _ left: Node? = nil, _ right: Node? = nil) {
        self.left = left
        self.right = right
        self.item = item
    }
}

func makeTree(_ item: Int64, _ depth: Int) -> Node {
    depth == 0 ? Node(item) : Node(item, makeTree(2 * item - 1, depth - 1), makeTree(2 * item, depth - 1))
}

func checkTree(_ n: Node) -> Int64 {
    guard let left = n.left, let right = n.right else { return n.item }
    return n.item + checkTree(left) - checkTree(right)
}

func benchBinaryTrees(_ maxDepth: Int) -> Int64 {
    var checksum = checkTree(makeTree(0, maxDepth + 1))
    let longLived = makeTree(0, maxDepth)
    for d in stride(from: treeMinDepth, through: maxDepth, by: 2) {
        for i in 0..<1 << (maxDepth - d + treeMinDepth) {
            checksum += checkTree(makeTree(Int64(i + 1), d))
        }
    }
    return checksum + checkTree(longLived)
}

func benchKnucleotide(_ length: Int) -> Int64 {
    var seq = [UInt8](repeating: 0, count: length)
    var seed = knucSeed
    for i in 0..<length {
        seed = (seed * knucIA + knucIC) % knucIM
        seq[i] = switch seed {
        case ..<42404: UInt8(ascii: "A")
        case ..<70116: UInt8(ascii: "C")
        case ..<97766: UInt8(ascii: "G")
        default: UInt8(ascii: "T")
        }
    }
    let query = Array(knucQuery.utf8)
    var checksum: Int64 = 0
    for k in [1, 2, 3, 4, 6, 12, 18] {
        var counts: [ArraySlice<UInt8>: Int] = [:]
        for i in 0...length - k {
            counts[seq[i..<i + k], default: 0] += 1
        }
        checksum += Int64(counts.count)
        if k <= 2 {
            var entries = Array(counts)
            entries.sort { a, b in
                a.value != b.value ? a.value > b.value : a.key.lexicographicallyPrecedes(b.key)
            }
            for (r, e) in entries.enumerated() {
                checksum += Int64(r + 1) * Int64(e.value)
            }
        } else {
            checksum += Int64(counts[query[..<k]] ?? 0)
        }
    }
    return checksum
}

bench("primes") { benchPrimes(primesLimit) }
bench("fib") { fib(fibonacciN) }
bench("strings") { benchStrings(sentence, stringIter) }
bench("mandelbrot") { benchMandelbrot(mandelSize) }
bench("binarytrees") { benchBinaryTrees(treeMaxDepth) }
bench("knucleotide") { benchKnucleotide(knucLength) }
