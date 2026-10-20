program bench
    use iso_fortran_env, only: int64, real64
    implicit none

    integer, parameter :: PRIMES_LIMIT = 8000000
    integer, parameter :: FIBONACCI_N = 43
    integer, parameter :: STRING_ITER = 1200000
    integer, parameter :: MANDEL_SIZE = 2048
    integer, parameter :: MANDEL_MAX_ITER = 256
    integer, parameter :: TREE_MIN_DEPTH = 4
    integer, parameter :: TREE_MAX_DEPTH = 17
    integer, parameter :: MAX_WORDS = 32
    integer, parameter :: MAX_WORD_LEN = 32
    character(len=*), parameter :: SENTENCE_TEXT = &
        "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"
    integer, parameter :: KNUC_LENGTH = 6000000
    integer, parameter :: KNUC_SEED = 42
    integer, parameter :: KNUC_IM = 139968
    integer, parameter :: KNUC_IA = 3877
    integer, parameter :: KNUC_IC = 29573
    character(len=*), parameter :: KNUC_QUERY = "GGTATTTTAATTTATAGT"

    type :: Node
        type(Node), pointer :: left => null()
        type(Node), pointer :: right => null()
        integer(int64) :: item = 0_int64
    end type Node

    type :: KTable
        integer, allocatable :: keys(:)
        integer, allocatable :: counts(:)
        integer :: cap = 0
        integer :: used = 0
        integer :: k = 0
    end type KTable

    integer(int64) :: t, r

    t = tick(); r = bench_primes(PRIMES_LIMIT);          call report("primes", r, secs(t))
    t = tick(); r = fib(FIBONACCI_N);                     call report("fib", r, secs(t))
    t = tick(); r = bench_strings(SENTENCE_TEXT, STRING_ITER); call report("strings", r, secs(t))
    t = tick(); r = bench_mandelbrot(MANDEL_SIZE);        call report("mandelbrot", r, secs(t))
    t = tick(); r = bench_binary_trees(TREE_MAX_DEPTH);   call report("binarytrees", r, secs(t))
    t = tick(); r = bench_knucleotide(KNUC_LENGTH);       call report("knucleotide", r, secs(t))

contains

    function tick() result(c)
        integer(int64) :: c
        call system_clock(c)
    end function tick

    function secs(t0) result(s)
        integer(int64), intent(in) :: t0
        integer(int64) :: t1, rate
        real(real64) :: s
        call system_clock(t1, rate)
        s = real(t1 - t0, real64) / real(rate, real64)
    end function secs

    subroutine report(name, checksum, s)
        character(len=*), intent(in) :: name
        integer(int64), intent(in) :: checksum
        real(real64), intent(in) :: s
        character(len=16) :: buf
        write (buf, '(F16.3)') s
        print '(A,1X,I0,1X,A)', name, checksum, trim(adjustl(buf))
    end subroutine report

    pure logical function is_prime(n)
        integer, intent(in) :: n
        integer :: i
        is_prime = .false.
        if (n < 2) return
        is_prime = .true.
        if (n < 4) return
        is_prime = .false.
        if (mod(n, 2) == 0 .or. mod(n, 3) == 0) return
        i = 5
        do while (i * i <= n)
            if (mod(n, i) == 0 .or. mod(n, i + 2) == 0) return
            i = i + 6
        end do
        is_prime = .true.
    end function is_prime

    function bench_primes(limit) result(count)
        integer, intent(in) :: limit
        integer(int64) :: count
        integer :: i
        count = 0
        do i = 2, limit - 1
            if (is_prime(i)) count = count + 1
        end do
    end function bench_primes

    recursive function fib(n) result(r)
        integer, value :: n
        integer(int64) :: r
        r = (n < 2 ? int(n, int64) : fib(n - 1) + fib(n - 2))
    end function fib

    function bench_strings(sentence, iters) result(total)
        character(len=*), intent(in) :: sentence
        integer, intent(in) :: iters
        integer(int64) :: total
        character(len=MAX_WORD_LEN) :: words(MAX_WORDS), cur(MAX_WORDS)
        character :: c
        integer :: wlen(MAX_WORDS)
        integer :: wcount, i, j, k, it, pos, first, w, n

        wcount = 0
        pos = 0
        do while (pos <= len(sentence) .and. wcount < MAX_WORDS)
            first = pos + 1
            call split(sentence, ' ', pos)
            wcount = wcount + 1
            words(wcount) = sentence(first:pos - 1)
            wlen(wcount) = pos - first
        end do

        cur(1:wcount) = words(1:wcount)
        total = 0
        do it = 0, iters - 1
            w = mod(it, wcount) + 1
            n = wlen(w)
            do k = 1, n / 2
                c = cur(w)(k:k)
                cur(w)(k:k) = cur(w)(n - k + 1:n - k + 1)
                cur(w)(n - k + 1:n - k + 1) = c
            end do
            do i = 1, wcount
                do j = 1, wcount
                    if (wlen(i) == wlen(j)) then
                        if (cur(i)(1:wlen(i)) == words(j)(1:wlen(j))) total = total + 1
                    end if
                end do
            end do
        end do
    end function bench_strings

    function bench_mandelbrot(size) result(checksum)
        integer, intent(in) :: size
        integer(int64) :: checksum
        real(real64) :: cx, cy, zx, zy, nx
        integer :: px, py, iter
        checksum = 0
        do py = 0, size - 1
            cy = real(py, real64) / real(size, real64) * 3.0_real64 - 1.5_real64
            do px = 0, size - 1
                cx = real(px, real64) / real(size, real64) * 3.0_real64 - 2.0_real64
                zx = 0.0_real64
                zy = 0.0_real64
                iter = 0
                do while (iter < MANDEL_MAX_ITER .and. zx * zx + zy * zy <= 4.0_real64)
                    nx = zx * zx - zy * zy + cx
                    zy = 2.0_real64 * zx * zy + cy
                    zx = nx
                    iter = iter + 1
                end do
                checksum = checksum + iter
            end do
        end do
    end function bench_mandelbrot

    recursive function make_tree(item, depth) result(n)
        integer(int64), intent(in) :: item
        integer, intent(in) :: depth
        type(Node), pointer :: n
        allocate (n)
        n%item = item
        if (depth == 0) return
        n%left => make_tree(2_int64 * item - 1_int64, depth - 1)
        n%right => make_tree(2_int64 * item, depth - 1)
    end function make_tree

    recursive function check_tree(n) result(r)
        type(Node), pointer, intent(in) :: n
        integer(int64) :: r
        r = (.not. associated(n%left) ? n%item : n%item + check_tree(n%left) - check_tree(n%right))
    end function check_tree

    recursive subroutine free_tree(n)
        type(Node), pointer, intent(inout) :: n
        if (associated(n%left)) then
            call free_tree(n%left)
            call free_tree(n%right)
        end if
        deallocate (n)
    end subroutine free_tree

    function bench_binary_trees(max_depth) result(checksum)
        integer, intent(in) :: max_depth
        integer(int64) :: checksum
        type(Node), pointer :: stretch, long_lived, tree
        integer :: d, i, iters
        checksum = 0
        stretch => make_tree(0_int64, max_depth + 1)
        checksum = checksum + check_tree(stretch)
        call free_tree(stretch)
        long_lived => make_tree(0_int64, max_depth)
        do d = TREE_MIN_DEPTH, max_depth, 2
            iters = ishft(1, max_depth - d + TREE_MIN_DEPTH)
            do i = 0, iters - 1
                tree => make_tree(int(i + 1, int64), d)
                checksum = checksum + check_tree(tree)
                call free_tree(tree)
            end do
        end do
        checksum = checksum + check_tree(long_lived)
        call free_tree(long_lived)
    end function bench_binary_trees

    pure function fnv1a(key) result(h)
        character(len=*), intent(in) :: key
        integer(int64) :: h
        integer :: i
        h = 2166136261_int64
        do i = 1, len(key)
            h = ieor(h, int(ichar(key(i:i)), int64))
            h = iand(h * 16777619_int64, 4294967295_int64)
        end do
    end function fnv1a

    pure function ktable_probe(keys, cap, seq, key) result(j)
        integer, intent(in) :: keys(0:)
        integer, intent(in) :: cap
        character(len=*), intent(in) :: seq, key
        integer :: j
        j = int(iand(fnv1a(key), int(cap - 1, int64)))
        do while (keys(j) /= 0)
            if (seq(keys(j):keys(j) + len(key) - 1) == key) exit
            j = iand(j + 1, cap - 1)
        end do
    end function ktable_probe

    subroutine ktable_grow(t, seq)
        type(KTable), intent(inout) :: t
        character(len=*), intent(in) :: seq
        integer, allocatable :: keys(:), counts(:)
        integer :: cap, i, j
        cap = t%cap * 2
        allocate (keys(0:cap - 1), counts(0:cap - 1), source=0)
        do i = 0, t%cap - 1
            if (t%keys(i) /= 0) then
                j = ktable_probe(keys, cap, seq, seq(t%keys(i):t%keys(i) + t%k - 1))
                keys(j) = t%keys(i)
                counts(j) = t%counts(i)
            end if
        end do
        call move_alloc(keys, t%keys)
        call move_alloc(counts, t%counts)
        t%cap = cap
    end subroutine ktable_grow

    subroutine ktable_add(t, seq, p)
        type(KTable), intent(inout) :: t
        character(len=*), intent(in) :: seq
        integer, intent(in) :: p
        integer :: j
        j = ktable_probe(t%keys, t%cap, seq, seq(p:p + t%k - 1))
        if (t%keys(j) == 0) then
            if ((t%used + 1) * 2 > t%cap) then
                call ktable_grow(t, seq)
                j = ktable_probe(t%keys, t%cap, seq, seq(p:p + t%k - 1))
            end if
            t%keys(j) = p
            t%used = t%used + 1
        end if
        t%counts(j) = t%counts(j) + 1
    end subroutine ktable_add

    pure logical function kmer_before(seq, k, ka, ca, kb, cb)
        character(len=*), intent(in) :: seq
        integer, intent(in) :: k, ka, ca, kb, cb
        kmer_before = (ca /= cb ? ca > cb : llt(seq(ka:ka + k - 1), seq(kb:kb + k - 1)))
    end function kmer_before

    subroutine sort_kmers(keys, counts, seq, k)
        integer, intent(inout) :: keys(:), counts(:)
        character(len=*), intent(in) :: seq
        integer, intent(in) :: k
        integer :: i, j, key, c
        do i = 2, size(keys)
            key = keys(i)
            c = counts(i)
            j = i - 1
            do while (j >= 1)
                if (.not. kmer_before(seq, k, key, c, keys(j), counts(j))) exit
                keys(j + 1) = keys(j)
                counts(j + 1) = counts(j)
                j = j - 1
            end do
            keys(j + 1) = key
            counts(j + 1) = c
        end do
    end subroutine sort_kmers

    function bench_knucleotide(length) result(checksum)
        integer, intent(in) :: length
        integer(int64) :: checksum
        integer, parameter :: ks(7) = [1, 2, 3, 4, 6, 12, 18]
        character(len=:), allocatable :: seq
        type(KTable) :: t
        integer, allocatable :: ekeys(:), ecounts(:)
        integer :: seed, i, j, k, ki, r
        allocate (character(len=length) :: seq)
        seed = KNUC_SEED
        do i = 1, length
            seed = mod(seed * KNUC_IA + KNUC_IC, KNUC_IM)
            seq(i:i) = (seed < 42404 ? 'A' : seed < 70116 ? 'C' : seed < 97766 ? 'G' : 'T')
        end do
        checksum = 0
        do ki = 1, size(ks)
            k = ks(ki)
            t%cap = 16
            t%used = 0
            t%k = k
            allocate (t%keys(0:t%cap - 1), t%counts(0:t%cap - 1), source=0)
            do i = 1, length - k + 1
                call ktable_add(t, seq, i)
            end do
            checksum = checksum + t%used
            if (k <= 2) then
                ekeys = pack(t%keys, t%keys /= 0)
                ecounts = pack(t%counts, t%keys /= 0)
                call sort_kmers(ekeys, ecounts, seq, k)
                do r = 1, size(ekeys)
                    checksum = checksum + int(r, int64) * ecounts(r)
                end do
            else
                j = ktable_probe(t%keys, t%cap, seq, KNUC_QUERY(1:k))
                if (t%keys(j) /= 0) checksum = checksum + t%counts(j)
            end if
            deallocate (t%keys, t%counts)
        end do
    end function bench_knucleotide

end program bench
