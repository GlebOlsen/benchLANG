<?php
declare(strict_types=1);

const PRIMES_LIMIT = 8000000;
const FIBONACCI_N = 43;
const STRING_ITER = 1200000;
const MANDEL_SIZE = 2048;
const MANDEL_MAX_ITER = 256;
const TREE_MIN_DEPTH = 4;
const TREE_MAX_DEPTH = 17;
const SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";
const KNUC_LENGTH = 6000000;
const KNUC_SEED = 42;
const KNUC_IM = 139968;
const KNUC_IA = 3877;
const KNUC_IC = 29573;
const KNUC_QUERY = "GGTATTTTAATTTATAGT";

function report(string $name, int $checksum, float $secs): void {
    printf("%s %d %.3f\n", $name, $checksum, $secs);
}

function is_prime(int $n): bool {
    if ($n < 2) return false;
    if ($n < 4) return true;
    if ($n % 2 === 0 || $n % 3 === 0) return false;
    for ($i = 5; $i * $i <= $n; $i += 6)
        if ($n % $i === 0 || $n % ($i + 2) === 0) return false;
    return true;
}

function bench_primes(int $limit): int {
    $count = 0;
    for ($i = 2; $i < $limit; $i++)
        if (is_prime($i)) $count++;
    return $count;
}

function fib(int $n): int { return $n < 2 ? $n : fib($n - 1) + fib($n - 2); }

function bench_strings(string $sentence, int $iters): int {
    $words = explode(' ', $sentence);
    $cur = $words;
    $total = 0;
    for ($it = 0; $it < $iters; $it++) {
        $i = $it % count($words);
        $cur[$i] = strrev($cur[$i]);
        foreach ($cur as $wi)
            foreach ($words as $wj)
                if ($wi === $wj) $total++;
    }
    return $total;
}

function bench_mandelbrot(int $size): int {
    $checksum = 0;
    for ($py = 0; $py < $size; $py++) {
        $cy = $py / $size * 3.0 - 1.5;
        for ($px = 0; $px < $size; $px++) {
            $cx = $px / $size * 3.0 - 2.0;
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
    return $checksum;
}

final class Node {
    public function __construct(public ?Node $left, public ?Node $right, public int $item) {}
}

function make_tree(int $item, int $depth): Node {
    if ($depth === 0) return new Node(null, null, $item);
    return new Node(make_tree(2 * $item - 1, $depth - 1), make_tree(2 * $item, $depth - 1), $item);
}

function check_tree(Node $n): int {
    return $n->left === null ? $n->item : $n->item + check_tree($n->left) - check_tree($n->right);
}

function bench_binary_trees(int $max_depth): int {
    $checksum = 0;
    $stretch = make_tree(0, $max_depth + 1);
    $checksum += check_tree($stretch);
    unset($stretch);
    $long_lived = make_tree(0, $max_depth);
    for ($d = TREE_MIN_DEPTH; $d <= $max_depth; $d += 2) {
        $iters = 1 << ($max_depth - $d + TREE_MIN_DEPTH);
        for ($i = 0; $i < $iters; $i++)
            $checksum += check_tree(make_tree($i + 1, $d));
    }
    $checksum += check_tree($long_lived);
    return $checksum;
}

function bench_knucleotide(int $length): int {
    $seq = str_repeat(' ', $length);
    $seed = KNUC_SEED;
    for ($i = 0; $i < $length; $i++) {
        $seed = ($seed * KNUC_IA + KNUC_IC) % KNUC_IM;
        $seq[$i] = $seed < 42404 ? 'A' : ($seed < 70116 ? 'C' : ($seed < 97766 ? 'G' : 'T'));
    }
    $checksum = 0;
    foreach ([1, 2, 3, 4, 6, 12, 18] as $k) {
        $counts = [];
        for ($i = 0; $i + $k <= $length; $i++) {
            $key = substr($seq, $i, $k);
            $counts[$key] = ($counts[$key] ?? 0) + 1;
        }
        $checksum += count($counts);
        if ($k <= 2) {
            $entries = [];
            foreach ($counts as $key => $c) $entries[] = [$key, $c];
            usort($entries, fn($a, $b) => $b[1] <=> $a[1] ?: strcmp($a[0], $b[0]));
            foreach ($entries as $r => $e) $checksum += ($r + 1) * $e[1];
        } else {
            $checksum += $counts[substr(KNUC_QUERY, 0, $k)] ?? 0;
        }
    }
    return $checksum;
}

$t = hrtime(true); $r = bench_primes(PRIMES_LIMIT);           report("primes", $r, (hrtime(true) - $t) / 1e9);
$t = hrtime(true); $r = fib(FIBONACCI_N);                     report("fib", $r, (hrtime(true) - $t) / 1e9);
$t = hrtime(true); $r = bench_strings(SENTENCE, STRING_ITER); report("strings", $r, (hrtime(true) - $t) / 1e9);
$t = hrtime(true); $r = bench_mandelbrot(MANDEL_SIZE);         report("mandelbrot", $r, (hrtime(true) - $t) / 1e9);
$t = hrtime(true); $r = bench_binary_trees(TREE_MAX_DEPTH);    report("binarytrees", $r, (hrtime(true) - $t) / 1e9);
$t = hrtime(true); $r = bench_knucleotide(KNUC_LENGTH);        report("knucleotide", $r, (hrtime(true) - $t) / 1e9);
