program bench
    use iso_fortran_env, only: int64, real64
    implicit none

    integer, parameter :: PRIMES_LIMIT = 20000000
    integer, parameter :: FIBONACCI_N = 45
    integer, parameter :: STRING_ITER = 5000000
    integer, parameter :: MANDEL_SIZE = 4096
    integer, parameter :: MANDEL_MAX_ITER = 256
    integer, parameter :: TREE_MIN_DEPTH = 4
    integer, parameter :: TREE_MAX_DEPTH = 18
    integer, parameter :: MAX_WORDS = 32
    integer, parameter :: MAX_WORD_LEN = 32
    character(len=*), parameter :: SENTENCE_TEXT = &
        "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"

    type :: Node
        type(Node), pointer :: left => null()
        type(Node), pointer :: right => null()
        integer(int64) :: item = 0_int64
    end type Node

    integer(int64) :: t, r

    t = tick(); r = bench_primes(PRIMES_LIMIT);          call report("primes", r, secs(t))
    t = tick(); r = fib(FIBONACCI_N);                     call report("fib", r, secs(t))
    t = tick(); r = bench_strings(SENTENCE_TEXT, STRING_ITER); call report("strings", r, secs(t))
    t = tick(); r = bench_mandelbrot(MANDEL_SIZE);        call report("mandelbrot", r, secs(t))
    t = tick(); r = bench_binary_trees(TREE_MAX_DEPTH);   call report("binarytrees", r, secs(t))

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

    ! n by value, same calling convention as every other language here.
    recursive function fib(n) result(r)
        integer, value :: n
        integer(int64) :: r
        if (n < 2) then
            r = n
        else
            r = fib(n - 1) + fib(n - 2)
        end if
    end function fib

    function bench_strings(sentence, iters) result(total)
        character(len=*), intent(in) :: sentence
        integer, intent(in) :: iters
        integer(int64) :: total
        character(len=MAX_WORD_LEN) :: words(MAX_WORDS)
        integer :: wlen(MAX_WORDS)
        integer :: wcount, i, j, k, it, pos

        wcount = 0
        pos = 1
        do while (pos <= len(sentence) .and. wcount < MAX_WORDS)
            do while (pos <= len(sentence))
                if (sentence(pos:pos) /= ' ') exit
                pos = pos + 1
            end do
            if (pos > len(sentence)) exit
            wcount = wcount + 1
            k = 0
            do while (pos <= len(sentence))
                if (sentence(pos:pos) == ' ') exit
                k = k + 1
                words(wcount)(k:k) = sentence(pos:pos)
                pos = pos + 1
            end do
            wlen(wcount) = k
        end do

        total = 0
        do it = 1, iters
            do i = 1, wcount
                do j = 1, wcount
                    if (wlen(i) == wlen(j)) then
                        if (words(i)(1:wlen(i)) == words(j)(1:wlen(j))) total = total + 1
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
        if (.not. associated(n%left)) then
            r = n%item
        else
            r = n%item + check_tree(n%left) - check_tree(n%right)
        end if
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

end program bench
