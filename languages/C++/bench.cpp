#include <chrono>
#include <cstdio>
#include <string_view>
#include <vector>

namespace {

constexpr int PRIMES_LIMIT    = 20000000;
constexpr int FIBONACCI_N     = 45;
constexpr int STRING_ITER     = 5000000;
constexpr int MANDEL_SIZE     = 4096;
constexpr int MANDEL_MAX_ITER = 256;
constexpr int TREE_MIN_DEPTH  = 4;
constexpr int TREE_MAX_DEPTH  = 18;
constexpr std::string_view SENTENCE =
    "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

double now() {
    return std::chrono::duration<double>(std::chrono::steady_clock::now().time_since_epoch()).count();
}

void report(const char* name, long long checksum, double secs) {
    std::printf("%s %lld %.3f\n", name, checksum, secs);
}

bool is_prime(int n) {
    if (n < 2) return false;
    if (n < 4) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    for (int i = 5; i * i <= n; i += 6)
        if (n % i == 0 || n % (i + 2) == 0) return false;
    return true;
}

long long bench_primes(int limit) {
    long long count = 0;
    for (int i = 2; i < limit; i++)
        if (is_prime(i)) count++;
    return count;
}

long long fib(int n) { return n < 2 ? n : fib(n - 1) + fib(n - 2); }

long long bench_strings(std::string_view sentence, int iters) {
    std::vector<std::string_view> words;
    for (size_t start = 0; start < sentence.size();) {
        size_t sp = sentence.find(' ', start);
        if (sp == std::string_view::npos) sp = sentence.size();
        words.push_back(sentence.substr(start, sp - start));
        start = sp + 1;
    }
    long long total = 0;
    for (int it = 0; it < iters; it++)
        for (std::string_view wi : words)
            for (std::string_view wj : words)
                if (wi == wj) total++;
    return total;
}

long long bench_mandelbrot(int size) {
    long long checksum = 0;
    for (int py = 0; py < size; py++) {
        double cy = static_cast<double>(py) / size * 3.0 - 1.5;
        for (int px = 0; px < size; px++) {
            double cx = static_cast<double>(px) / size * 3.0 - 2.0;
            double zx = 0.0, zy = 0.0;
            int iter = 0;
            while (iter < MANDEL_MAX_ITER && zx * zx + zy * zy <= 4.0) {
                double nx = zx * zx - zy * zy + cx;
                zy = 2.0 * zx * zy + cy;
                zx = nx;
                iter++;
            }
            checksum += iter;
        }
    }
    return checksum;
}

struct Node {
    Node* left;
    Node* right;
    long long item;
};

Node* make_tree(long long item, int depth) {
    Node* n = new Node;
    n->item = item;
    if (depth == 0) { n->left = n->right = nullptr; return n; }
    n->left = make_tree(2 * item - 1, depth - 1);
    n->right = make_tree(2 * item, depth - 1);
    return n;
}

long long check_tree(const Node* n) {
    if (!n->left) return n->item;
    return n->item + check_tree(n->left) - check_tree(n->right);
}

void free_tree(Node* n) {
    if (n->left) { free_tree(n->left); free_tree(n->right); }
    delete n;
}

long long bench_binary_trees(int max_depth) {
    long long checksum = 0;
    Node* stretch = make_tree(0, max_depth + 1);
    checksum += check_tree(stretch);
    free_tree(stretch);
    Node* long_lived = make_tree(0, max_depth);
    for (int d = TREE_MIN_DEPTH; d <= max_depth; d += 2) {
        int iters = 1 << (max_depth - d + TREE_MIN_DEPTH);
        for (int i = 0; i < iters; i++) {
            Node* t = make_tree(i + 1, d);
            checksum += check_tree(t);
            free_tree(t);
        }
    }
    checksum += check_tree(long_lived);
    free_tree(long_lived);
    return checksum;
}

}

int main() {
    double t;
    long long r;
    t = now(); r = bench_primes(PRIMES_LIMIT);          report("primes", r, now() - t);
    t = now(); r = fib(FIBONACCI_N);                     report("fib", r, now() - t);
    t = now(); r = bench_strings(SENTENCE, STRING_ITER); report("strings", r, now() - t);
    t = now(); r = bench_mandelbrot(MANDEL_SIZE);        report("mandelbrot", r, now() - t);
    t = now(); r = bench_binary_trees(TREE_MAX_DEPTH);   report("binarytrees", r, now() - t);
    return 0;
}
