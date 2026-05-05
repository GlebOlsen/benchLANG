program bench
    use iso_fortran_env, only: int64, real64
    implicit none

    integer, parameter :: PRIMES_LIMIT = 20000000
    integer, parameter :: FIBONACCI_N  = 45
    integer(int64), parameter :: STRING_ITER = 5000000_int64
    integer, parameter :: MANDEL_W = 4096
    integer, parameter :: MANDEL_H = 4096
    integer, parameter :: MANDEL_MAX_ITER = 256
    integer, parameter :: TREE_MIN_DEPTH = 4
    integer, parameter :: TREE_MAX_DEPTH = 18
    character(len=*), parameter :: SENTENCE = &
        "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"

    type :: Node
        type(Node), pointer :: left  => null()
        type(Node), pointer :: right => null()
        integer(int64) :: item = 0_int64
    end type Node

    real(real64) :: total_start

    call cpu_time(total_start)
    print '(A)', "=== PROGRAMMING LANGUAGE BENCHMARK ==="
    print *
    call bench_primes()
    call bench_fib_rec()
    call bench_strings()
    call bench_mandelbrot()
    call bench_binary_trees()
    print '(A)', "=== BENCHMARK COMPLETE ==="
    block
        real(real64) :: te
        call cpu_time(te)
        print '(A,F0.3,A)', "Total execution time: ", te - total_start, " seconds"
    end block

contains

    logical function is_prime(n)
        integer, intent(in) :: n
        integer :: i
        if (n <= 1) then; is_prime = .false.; return; end if
        if (n <= 3) then; is_prime = .true.;  return; end if
        if (mod(n, 2) == 0 .or. mod(n, 3) == 0) then; is_prime = .false.; return; end if
        i = 5
        do while (int(i, int64)*i <= n)
            if (mod(n, i) == 0 .or. mod(n, i+2) == 0) then; is_prime = .false.; return; end if
            i = i + 6
        end do
        is_prime = .true.
    end function is_prime

    subroutine bench_primes()
        real(real64) :: s, e
        integer :: c, i
        call cpu_time(s)
        c = 0
        do i = 2, PRIMES_LIMIT - 1
            if (is_prime(i)) c = c + 1
        end do
        call cpu_time(e)
        print '(A,I0,A,F0.3,A)', "Found ", c, " primes in ", e - s, " seconds"
        print *
    end subroutine bench_primes

    recursive function fib(n) result(r)
        integer, value :: n
        integer(int64) :: r
        if (n <= 1) then; r = int(n, int64); return; end if
        r = fib(n-1) + fib(n-2)
    end function fib

    subroutine bench_fib_rec()
        real(real64) :: s, e
        integer(int64) :: r
        call cpu_time(s)
        r = fib(FIBONACCI_N)
        call cpu_time(e)
        print '(A,I0,A,I0,A,F0.3,A)', "Fibonacci(", FIBONACCI_N, ") = ", r, " in ", e - s, " seconds"
        print *
    end subroutine bench_fib_rec

    subroutine bench_strings()
        real(real64) :: s, e
        integer :: i, j, k, idx, wcount, sentence_len
        integer, parameter :: MAX_WORDS = 32
        character(len=32) :: words(MAX_WORDS)
        integer :: word_lens(MAX_WORDS)
        integer(int64) :: total, count_eq
        integer(int64) :: iter

        call cpu_time(s)

        wcount = 0
        sentence_len = len(SENTENCE)
        i = 1
        do while (i <= sentence_len)
            do while (i <= sentence_len .and. SENTENCE(i:i) == ' ')
                i = i + 1
            end do
            if (i > sentence_len) exit
            wcount = wcount + 1
            words(wcount) = ''
            j = 0
            do while (i <= sentence_len .and. SENTENCE(i:i) /= ' ')
                j = j + 1
                words(wcount)(j:j) = SENTENCE(i:i)
                i = i + 1
            end do
            word_lens(wcount) = j
        end do

        total = 0
        do iter = 1, STRING_ITER
            do idx = 1, wcount
                count_eq = 0
                do k = 1, wcount
                    if (word_lens(idx) == word_lens(k) .and. &
                        words(idx)(1:word_lens(idx)) == words(k)(1:word_lens(k))) then
                        count_eq = count_eq + 1
                    end if
                end do
                total = total + count_eq
            end do
        end do

        call cpu_time(e)
        print '(A,I0,A,F0.3,A)', "Strings: total=", total, " in ", e - s, " seconds"
        print *
    end subroutine bench_strings

    subroutine bench_mandelbrot()
        real(real64) :: s, e
        real(real64) :: cx, cy, zx, zy, nx
        integer :: px, py, iter
        integer(int64) :: checksum
        call cpu_time(s)
        checksum = 0_int64
        do py = 0, MANDEL_H - 1
            cy = (real(py, real64) / real(MANDEL_H, real64)) * 3.0_real64 - 1.5_real64
            do px = 0, MANDEL_W - 1
                cx = (real(px, real64) / real(MANDEL_W, real64)) * 3.0_real64 - 2.0_real64
                zx = 0.0_real64
                zy = 0.0_real64
                iter = 0
                do while (iter < MANDEL_MAX_ITER .and. zx*zx + zy*zy <= 4.0_real64)
                    nx = zx*zx - zy*zy + cx
                    zy = 2.0_real64 * zx * zy + cy
                    zx = nx
                    iter = iter + 1
                end do
                checksum = checksum + int(iter, int64)
            end do
        end do
        call cpu_time(e)
        print '(A,I0,A,F0.3,A)', "Mandelbrot: checksum=", checksum, " in ", e - s, " seconds"
        print *
    end subroutine bench_mandelbrot

    recursive function make_tree(item, depth) result(n)
        integer(int64), intent(in) :: item
        integer, intent(in) :: depth
        type(Node), pointer :: n
        allocate(n)
        n%item = item
        if (depth == 0) then
            n%left => null()
            n%right => null()
            return
        end if
        n%left => make_tree(2_int64 * item - 1_int64, depth - 1)
        n%right => make_tree(2_int64 * item, depth - 1)
    end function make_tree

    recursive function check_tree(n) result(r)
        type(Node), pointer, intent(in) :: n
        integer(int64) :: r
        if (.not. associated(n%left)) then
            r = n%item
            return
        end if
        r = n%item + check_tree(n%left) - check_tree(n%right)
    end function check_tree

    recursive subroutine free_tree(n)
        type(Node), pointer, intent(inout) :: n
        if (associated(n%left)) then
            call free_tree(n%left)
            call free_tree(n%right)
        end if
        deallocate(n)
        n => null()
    end subroutine free_tree

    subroutine bench_binary_trees()
        real(real64) :: s, e
        integer(int64) :: checksum, sum_v
        integer :: d, i, iters
        type(Node), pointer :: stretch, long_lived, t

        call cpu_time(s)
        checksum = 0_int64

        stretch => make_tree(0_int64, TREE_MAX_DEPTH + 1)
        checksum = checksum + check_tree(stretch)
        call free_tree(stretch)

        long_lived => make_tree(0_int64, TREE_MAX_DEPTH)

        d = TREE_MIN_DEPTH
        do while (d <= TREE_MAX_DEPTH)
            iters = ishft(1, TREE_MAX_DEPTH - d + TREE_MIN_DEPTH)
            sum_v = 0_int64
            do i = 0, iters - 1
                t => make_tree(int(i + 1, int64), d)
                sum_v = sum_v + check_tree(t)
                call free_tree(t)
            end do
            checksum = checksum + sum_v
            d = d + 2
        end do

        checksum = checksum + check_tree(long_lived)
        call free_tree(long_lived)

        call cpu_time(e)
        print '(A,I0,A,F0.3,A)', "BinaryTrees: checksum=", checksum, " in ", e - s, " seconds"
        print *
    end subroutine bench_binary_trees

end program bench
