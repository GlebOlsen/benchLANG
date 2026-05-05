<?php
const PRIMES_LIMIT = 20000000;
const FIBONACCI_N = 45;
const STRING_ITER = 5000000;
const MANDEL_W = 4096;
const MANDEL_H = 4096;
const MANDEL_MAX_ITER = 256;
const TREE_MIN_DEPTH = 4;
const TREE_MAX_DEPTH = 18;
const SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

function is_prime($n) {
    if ($n <= 1) return false;
    if ($n <= 3) return true;
    if ($n % 2 == 0 || $n % 3 == 0) return false;
    for ($i = 5; $i * $i <= $n; $i += 6)
        if ($n % $i == 0 || $n % ($i + 2) == 0) return false;
    return true;
}
function bench_primes() {
    $s = microtime(true);
    $c = 0;
    for ($i = 2; $i < PRIMES_LIMIT; $i++) if (is_prime($i)) $c++;
    printf("Found %d primes in %.3f seconds\n\n", $c, microtime(true) - $s);
}

function fib($n) { return $n <= 1 ? $n : fib($n - 1) + fib($n - 2); }
function bench_fib_rec() {
    $s = microtime(true);
    $r = fib(FIBONACCI_N);
    printf("Fibonacci(%d) = %d in %.3f seconds\n\n", FIBONACCI_N, $r, microtime(true) - $s);
}

function bench_strings() {
    $s = microtime(true);
    $words = explode(' ', SENTENCE);
    $wcount = count($words);
    $total = 0;
    for ($iter = 0; $iter < STRING_ITER; $iter++) {
        for ($i = 0; $i < $wcount; $i++) {
            $count = 0;
            $wi = $words[$i];
            for ($j = 0; $j < $wcount; $j++) {
                if ($wi === $words[$j]) $count++;
            }
            $total += $count;
        }
    }
    printf("Strings: total=%d in %.3f seconds\n\n", $total, microtime(true) - $s);
}

function bench_mandelbrot() {
    $s = microtime(true);
    $checksum = 0;
    for ($py = 0; $py < MANDEL_H; $py++) {
        $cy = ($py / MANDEL_H) * 3.0 - 1.5;
        for ($px = 0; $px < MANDEL_W; $px++) {
            $cx = ($px / MANDEL_W) * 3.0 - 2.0;
            $zx = 0.0; $zy = 0.0;
            $iter = 0;
            while ($iter < MANDEL_MAX_ITER && $zx * $zx + $zy * $zy <= 4.0) {
                $nx = $zx * $zx - $zy * $zy + $cx;
                $zy = 2.0 * $zx * $zy + $cy;
                $zx = $nx;
                $iter++;
            }
            $checksum += $iter;
        }
    }
    printf("Mandelbrot: checksum=%d in %.3f seconds\n\n", $checksum, microtime(true) - $s);
}

class TreeNode {
    public $left;
    public $right;
    public $item;
}
function make_tree($item, $depth) {
    $n = new TreeNode();
    $n->item = $item;
    if ($depth == 0) {
        $n->left = null;
        $n->right = null;
        return $n;
    }
    $n->left = make_tree(2 * $item - 1, $depth - 1);
    $n->right = make_tree(2 * $item, $depth - 1);
    return $n;
}
function check_tree($n) {
    if ($n->left === null) return $n->item;
    return $n->item + check_tree($n->left) - check_tree($n->right);
}
function bench_binary_trees() {
    $s = microtime(true);
    $checksum = 0;

    $stretch = make_tree(0, TREE_MAX_DEPTH + 1);
    $checksum += check_tree($stretch);
    unset($stretch);

    $long_lived = make_tree(0, TREE_MAX_DEPTH);

    for ($d = TREE_MIN_DEPTH; $d <= TREE_MAX_DEPTH; $d += 2) {
        $iters = 1 << (TREE_MAX_DEPTH - $d + TREE_MIN_DEPTH);
        $sum = 0;
        for ($i = 0; $i < $iters; $i++) {
            $t = make_tree($i + 1, $d);
            $sum += check_tree($t);
        }
        $checksum += $sum;
    }

    $checksum += check_tree($long_lived);

    printf("BinaryTrees: checksum=%d in %.3f seconds\n\n", $checksum, microtime(true) - $s);
}

echo "=== PROGRAMMING LANGUAGE BENCHMARK ===\n\n";
$total = microtime(true);
bench_primes();
bench_fib_rec();
bench_strings();
bench_mandelbrot();
bench_binary_trees();
echo "=== BENCHMARK COMPLETE ===\n";
printf("Total execution time: %.3f seconds\n", microtime(true) - $total);
