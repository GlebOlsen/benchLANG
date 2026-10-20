PRIMES_LIMIT = 8_000_000
FIBONACCI_N = 43
STRING_ITER = 1_200_000
MANDEL_SIZE = 2048
MANDEL_MAX_ITER = 256
TREE_MIN_DEPTH = 4
TREE_MAX_DEPTH = 17
SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"
KNUC_LENGTH = 6_000_000
KNUC_SEED = 42
KNUC_IM = 139_968
KNUC_IA = 3877
KNUC_IC = 29_573
KNUC_KS = [1, 2, 3, 4, 6, 12, 18].freeze
KNUC_QUERY = "GGTATTTTAATTTATAGT"

def now = Process.clock_gettime(Process::CLOCK_MONOTONIC)

def report(name, checksum, secs) = puts format("%s %d %.3f", name, checksum, secs)

def prime?(n)
  return false if n < 2
  return true if n < 4
  return false if n % 2 == 0 || n % 3 == 0

  i = 5
  while i * i <= n
    return false if n % i == 0 || n % (i + 2) == 0

    i += 6
  end
  true
end

def bench_primes(limit)
  count = 0
  (2...limit).each { |i| count += 1 if prime?(i) }
  count
end

def fib(n) = n < 2 ? n : fib(n - 1) + fib(n - 2)

def bench_strings(sentence, iters)
  words = sentence.split(" ")
  cur = words.map(&:dup)
  total = 0
  iters.times do |it|
    cur[it % words.size].reverse!
    cur.each do |wi|
      words.each do |wj|
        total += 1 if wi == wj
      end
    end
  end
  total
end

def bench_mandelbrot(size)
  checksum = 0
  size.times do |py|
    cy = py.to_f / size * 3.0 - 1.5
    size.times do |px|
      cx = px.to_f / size * 3.0 - 2.0
      zx = zy = 0.0
      iter = 0
      while iter < MANDEL_MAX_ITER && zx * zx + zy * zy <= 4.0
        nx = zx * zx - zy * zy + cx
        zy = 2.0 * zx * zy + cy
        zx = nx
        iter += 1
      end
      checksum += iter
    end
  end
  checksum
end

class Node
  attr_reader :left, :right, :item

  def initialize(left, right, item)
    @left = left
    @right = right
    @item = item
  end
end

def make_tree(item, depth)
  return Node.new(nil, nil, item) if depth == 0

  Node.new(make_tree(2 * item - 1, depth - 1), make_tree(2 * item, depth - 1), item)
end

def check_tree(node)
  return node.item if node.left.nil?

  node.item + check_tree(node.left) - check_tree(node.right)
end

def bench_binary_trees(max_depth)
  checksum = check_tree(make_tree(0, max_depth + 1))
  long_lived = make_tree(0, max_depth)
  TREE_MIN_DEPTH.step(max_depth, 2) do |d|
    iters = 1 << (max_depth - d + TREE_MIN_DEPTH)
    iters.times { checksum += check_tree(make_tree(it + 1, d)) }
  end
  checksum + check_tree(long_lived)
end

def bench_knucleotide(length)
  seed = KNUC_SEED
  seq = String.new(capacity: length)
  length.times do
    seed = (seed * KNUC_IA + KNUC_IC) % KNUC_IM
    seq << (seed < 42_404 ? 65 : seed < 70_116 ? 67 : seed < 97_766 ? 71 : 84)
  end
  checksum = 0
  KNUC_KS.each do |k|
    counts = Hash.new(0)
    (length - k + 1).times { counts[seq[it, k]] += 1 }
    checksum += counts.size
    if k <= 2
      counts.sort { |(ka, ca), (kb, cb)| [cb, ka] <=> [ca, kb] }
            .each_with_index { |(_, c), r| checksum += (r + 1) * c }
    else
      checksum += counts[KNUC_QUERY[0, k]]
    end
  end
  checksum
end

t = now; r = bench_primes(PRIMES_LIMIT);          report("primes", r, now - t)
t = now; r = fib(FIBONACCI_N);                     report("fib", r, now - t)
t = now; r = bench_strings(SENTENCE, STRING_ITER); report("strings", r, now - t)
t = now; r = bench_mandelbrot(MANDEL_SIZE);        report("mandelbrot", r, now - t)
t = now; r = bench_binary_trees(TREE_MAX_DEPTH);   report("binarytrees", r, now - t)
t = now; r = bench_knucleotide(KNUC_LENGTH);       report("knucleotide", r, now - t)
