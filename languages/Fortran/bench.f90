program bench
    implicit none
    
    ! Constants
    integer, parameter :: PRIMES_LIMIT = 20000000
    integer :: FIBONACCI_N
    
    real :: start_time, end_time, total_start, total_end
    character(len=32) :: arg
    integer :: stat
    
    ! Prevent compile-time optimization of fibonacci
    if (command_argument_count() > 0) then
        call get_command_argument(1, arg)
        read(arg, *, iostat=stat) FIBONACCI_N
        if (stat /= 0) FIBONACCI_N = 45
    else
        FIBONACCI_N = 45
    end if
    
    write(*,*) '=== PROGRAMMING LANGUAGE BENCHMARK ==='
    write(*,*)
    
    call cpu_time(total_start)
    
    call benchmark_primes()
    call benchmark_fibonacci()
    
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

end program bench