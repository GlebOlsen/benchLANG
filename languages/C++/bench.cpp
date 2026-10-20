#include <algorithm>
#include <chrono>
#include <cstdio>
#include <ranges>
#include <string>
#include <string_view>
#include <unordered_map>
#include <utility>
#include <vector>

namespace {

constexpr int PRIMES_LIMIT    = 8000000;
constexpr int FIBONACCI_N     = 43;
constexpr int STRING_ITER     = 1200000;
constexpr int MANDEL_SIZE     = 2048;
constexpr int MANDEL_MAX_ITER = 256;
constexpr int TREE_MIN_DEPTH  = 4;
constexpr int TREE_MAX_DEPTH  = 17;
constexpr std::string_view SENTENCE =
    "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";
constexpr int KNUC_LENGTH     = 6000000;
constexpr int KNUC_SEED       = 42;
constexpr int KNUC_IM         = 139968;
constexpr int KNUC_IA         = 3877;
constexpr int KNUC_IC         = 29573;
constexpr std::string_view KNUC_QUERY = "GGTATTTTAATTTATAGT";

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
    auto words = sentence | std::views::split(' ')
               | std::views::transform([](auto w) { return std::string_view(w); })
               | std::ranges::to<std::vector>();
    auto cur = words | std::ranges::to<std::vector<std::string>>();
    long long total = 0;
    for (int it = 0; it < iters; it++) {
        std::string& w = cur[it % cur.size()];
        std::ranges::reverse(w);
        for (std::string_view wi : cur)
            for (std::string_view wj : words)
                if (wi == wj) total++;
    }
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

long long bench_knucleotide(int length) {
    std::string seq(length, '\0');
    int seed = KNUC_SEED;
    for (int i = 0; i < length; i++) {
        seed = (seed * KNUC_IA + KNUC_IC) % KNUC_IM;
        seq[i] = seed < 42404 ? 'A' : seed < 70116 ? 'C' : seed < 97766 ? 'G' : 'T';
    }
    std::string_view sv = seq;
    long long checksum = 0;
    for (int k : {1, 2, 3, 4, 6, 12, 18}) {
        std::unordered_map<std::string_view, int> counts;
        for (int i = 0; i + k <= length; i++) counts[sv.substr(i, k)]++;
        checksum += counts.size();
        if (k <= 2) {
            std::vector<std::pair<std::string_view, int>> entries(counts.begin(), counts.end());
            std::ranges::sort(entries, [](const auto& a, const auto& b) {
                return a.second != b.second ? a.second > b.second : a.first < b.first;
            });
            for (auto [r, e] : std::views::enumerate(entries)) checksum += (r + 1) * e.second;
        } else if (auto it = counts.find(KNUC_QUERY.substr(0, k)); it != counts.end()) {
            checksum += it->second;
        }
    }
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
    t = now(); r = bench_knucleotide(KNUC_LENGTH);       report("knucleotide", r, now() - t);
    return 0;
}
