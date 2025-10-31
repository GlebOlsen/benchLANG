program bench
    implicit none
    
    ! Constants
    integer, parameter :: PRIMES_LIMIT = 20000000
    integer, parameter :: FIBONACCI_N = 45
    integer, parameter :: MATRIX_SIZE = 2000
    integer, parameter :: MATRIX_RAND_MAX = 100
    character(len=89), parameter :: SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"
    integer, parameter :: STRING_OPS = 200000000
    integer, parameter :: STRING_REDUCTION_FACTOR = 100
    integer, parameter :: SORT_SIZE = 10000000
    integer, parameter :: RAND_SEED = 42
    
    ! Global arrays for performance
    real(8), allocatable :: matrix_a(:), matrix_b(:), matrix_c(:)
    integer, allocatable :: sort_array(:)
    
    real :: start_time, end_time, total_start, total_end
    
    write(*,*) '=== COMPREHENSIVE PROGRAMMING LANGUAGE BENCHMARK (Fortran) ==='
    write(*,*)
    
    call cpu_time(total_start)
    
    call benchmark_primes()
    call benchmark_fibonacci()
    call benchmark_matrix_multiplication()
    call benchmark_sorting()
    call benchmark_string_operations()
    
    call cpu_time(total_end)
    write(*,*) '=== BENCHMARK COMPLETE ==='
    write(*,'(A,F8.3,A)') 'Total execution time: ', total_end - total_start, ' seconds'
    
contains

    logical function is_prime(n)
        integer, intent(in) :: n
        integer :: i
        
        if (n <= 1) then
            is_prime = .false.
            return
        end if
        if (n <= 3) then
            is_prime = .true.
            return
        end if
        if (mod(n, 2) == 0 .or. mod(n, 3) == 0) then
            is_prime = .false.
            return
        end if
        
        i = 5
        do while (i * i <= n)
            if (mod(n, i) == 0 .or. mod(n, i + 2) == 0) then
                is_prime = .false.
                return
            end if
            i = i + 6
        end do
        is_prime = .true.
    end function is_prime

    subroutine benchmark_primes()
        integer :: i, count
        
        write(*,'(A,I0,A)') 'Running Prime Numbers Benchmark (up to ', PRIMES_LIMIT, ')...'
        call cpu_time(start_time)
        
        count = 0
        do i = 2, PRIMES_LIMIT - 1
            if (is_prime(i)) count = count + 1
        end do
        
        call cpu_time(end_time)
        write(*,'(A,I0,A,F8.3,A)') 'Found ', count, ' primes in ', end_time - start_time, ' seconds'
        write(*,*)
    end subroutine benchmark_primes

    recursive function fib(n) result(res)
        integer, intent(in) :: n
        integer :: res
        
        if (n <= 1) then
            res = n
        else
            res = fib(n-1) + fib(n-2)
        end if
    end function fib

    subroutine benchmark_fibonacci()
        integer :: result
        
        write(*,'(A,I0,A)') 'Running Fibonacci Benchmark (n=', FIBONACCI_N, ', recursive)...'
        call cpu_time(start_time)
        
        result = fib(FIBONACCI_N)
        
        call cpu_time(end_time)
        write(*,'(A,I0,A,I0,A,F8.3,A)') 'Fibonacci(', FIBONACCI_N, ') = ', result, ' in ', end_time - start_time, ' seconds'
        write(*,*)
    end subroutine benchmark_fibonacci

    subroutine benchmark_matrix_multiplication()
        integer :: i, j, k, idx, n, size
        real :: rnd
        
        write(*,'(A,I0,A,I0,A)') 'Running Matrix Multiplication Benchmark (', MATRIX_SIZE, 'x', MATRIX_SIZE, ')...'
        call cpu_time(start_time)
        
        n = MATRIX_SIZE
        size = n * n
        allocate(matrix_a(size), matrix_b(size), matrix_c(size))
        
        call srand(RAND_SEED)
        do i = 1, size
            call random_number(rnd)
            matrix_a(i) = rnd * MATRIX_RAND_MAX
            call random_number(rnd)
            matrix_b(i) = rnd * MATRIX_RAND_MAX
            matrix_c(i) = 0.0d0
        end do
        
        ! i-k-j loop order for cache efficiency
        do i = 1, n
            do k = 1, n
                do j = 1, n
                    idx = (i-1)*n + j
                    matrix_c(idx) = matrix_c(idx) + matrix_a((i-1)*n + k) * matrix_b((k-1)*n + j)
                end do
            end do
        end do
        
        call cpu_time(end_time)
        write(*,'(A,F8.3,A)') 'Matrix multiplication completed in ', end_time - start_time, ' seconds'
        write(*,*)
        
        deallocate(matrix_a, matrix_b, matrix_c)
    end subroutine benchmark_matrix_multiplication

    subroutine benchmark_sorting()
        integer :: i
        real :: rnd
        
        write(*,'(A,I0,A)') 'Running Sorting Benchmark (', SORT_SIZE, ' elements)...'
        call cpu_time(start_time)
        
        allocate(sort_array(SORT_SIZE))
        call srand(RAND_SEED)
        
        do i = 1, SORT_SIZE
            call random_number(rnd)
            sort_array(i) = int(rnd * 2147483647)
        end do
        
        call quicksort(sort_array, 1, SORT_SIZE)
        
        call cpu_time(end_time)
        write(*,'(A,F8.3,A)') 'Sorting completed in ', end_time - start_time, ' seconds'
        write(*,*)
        
        deallocate(sort_array)
    end subroutine benchmark_sorting

    recursive subroutine quicksort(arr, low, high)
        integer, intent(inout) :: arr(:)
        integer, intent(in) :: low, high
        integer :: pi
        
        if (low < high) then
            pi = partition(arr, low, high)
            call quicksort(arr, low, pi - 1)
            call quicksort(arr, pi + 1, high)
        end if
    end subroutine quicksort

    function partition(arr, low, high) result(pi)
        integer, intent(inout) :: arr(:)
        integer, intent(in) :: low, high
        integer :: pi, pivot, i, j, temp
        
        pivot = arr(high)
        i = low - 1
        
        do j = low, high - 1
            if (arr(j) <= pivot) then
                i = i + 1
                temp = arr(i)
                arr(i) = arr(j)
                arr(j) = temp
            end if
        end do
        
        temp = arr(i + 1)
        arr(i + 1) = arr(high)
        arr(high) = temp
        pi = i + 1
    end function partition

    subroutine benchmark_string_operations()
        character(len=:), allocatable :: hay
        character(len=89) :: words(20)
        integer :: repeats, word_count, i, j, found, total, hay_len, word_len
        integer :: word_start, word_end, pos
        
        write(*,'(A,I0,A)') 'Running String Operations Benchmark (', STRING_OPS, ' operations)...'
        call cpu_time(start_time)
        
        repeats = STRING_OPS / STRING_REDUCTION_FACTOR
        hay_len = len(SENTENCE) * repeats
        allocate(character(len=hay_len) :: hay)
        
        ! Build large string
        do i = 1, repeats
            pos = (i-1) * len(SENTENCE) + 1
            hay(pos:pos+len(SENTENCE)-1) = SENTENCE
        end do
        
        ! Parse words from SENTENCE
        word_count = 0
        word_start = 1
        do i = 1, len(SENTENCE)
            if (SENTENCE(i:i) == ' ' .or. i == len(SENTENCE)) then
                word_end = i
                if (i == len(SENTENCE)) word_end = i
                if (word_end > word_start) then
                    word_count = word_count + 1
                    if (i == len(SENTENCE)) then
                        words(word_count) = SENTENCE(word_start:word_end)
                    else
                        words(word_count) = SENTENCE(word_start:word_end-1)
                    end if
                end if
                word_start = i + 1
            end if
        end do
        
        ! Count occurrences
        total = 0
        do i = 1, word_count
            word_len = len_trim(words(i))
            if (word_len == 0) cycle
            found = 0
            do j = 1, hay_len - word_len + 1
                if (hay(j:j+word_len-1) == trim(words(i))) then
                    found = found + 1
                end if
            end do
            total = total + found
        end do
        
        call cpu_time(end_time)
        write(*,'(A,F8.3,A,I0,A)') 'String operations completed in ', end_time - start_time, ' seconds (found ', total, ' word instances)'
        write(*,*)
        
        deallocate(hay)
    end subroutine benchmark_string_operations

end program bench