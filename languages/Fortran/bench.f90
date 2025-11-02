program bench
    implicit none
    
    ! Constants
    integer, parameter :: PRIMES_LIMIT = 20000000
    integer :: FIBONACCI_N
    character(len=93), parameter :: SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"
    
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
    call benchmark_strings()
    
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
        !GCC$ ATTRIBUTES noinline :: fib
        
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

    subroutine benchmark_strings()
        character(len=20), dimension(20) :: words
        integer :: word_starts(20), word_lens(20)
        integer :: i, j, k, rev, words_count, char_idx, current_word_idx
        integer(8) :: match_count, reverse_count
        character(len=100) :: current_chars
        character :: temp_char
        logical :: match
        
        write(*,*) 'Running String Benchmark...'
        call cpu_time(start_time)
        
        ! Split sentence into words (store positions and lengths)
        words_count = 0
        word_starts(1) = 1
        do i = 1, len_trim(SENTENCE)
            if (SENTENCE(i:i) == ' ') then
                if (i > word_starts(words_count + 1)) then
                    words_count = words_count + 1
                    word_lens(words_count) = i - word_starts(words_count)
                    if (words_count < 20) word_starts(words_count + 1) = i + 1
                end if
            end if
        end do
        ! Handle last word
        if (len_trim(SENTENCE) >= word_starts(words_count + 1)) then
            words_count = words_count + 1
            word_lens(words_count) = len_trim(SENTENCE) - word_starts(words_count) + 1
        end if
        
        match_count = 0
        reverse_count = 0
        
        do i = 0, PRIMES_LIMIT - 1
            current_word_idx = mod(i, words_count) + 1
            
            ! Compare current word against all other words
            do j = 1, words_count
                if (word_lens(current_word_idx) == word_lens(j)) then
                    match = .true.
                    do k = 0, word_lens(j) - 1
                        if (SENTENCE(word_starts(current_word_idx) + k:word_starts(current_word_idx) + k) /= &
                            SENTENCE(word_starts(j) + k:word_starts(j) + k)) then
                            match = .false.
                            exit
                        end if
                    end do
                    if (match) match_count = match_count + 1
                end if
            end do
            
            ! Extract and reverse each word from sentence
            char_idx = 0
            do k = 1, len_trim(SENTENCE)
                if (SENTENCE(k:k) == ' ') then
                    if (char_idx > 0) then
                        ! Reverse the word
                        do rev = 0, char_idx - 1
                            temp_char = current_chars(char_idx - rev:char_idx - rev)
                        end do
                        reverse_count = reverse_count + char_idx
                        char_idx = 0
                    end if
                else
                    char_idx = char_idx + 1
                    current_chars(char_idx:char_idx) = SENTENCE(k:k)
                end if
            end do
            ! Handle last word
            if (char_idx > 0) then
                do rev = 0, char_idx - 1
                    temp_char = current_chars(char_idx - rev:char_idx - rev)
                end do
                reverse_count = reverse_count + char_idx
            end if
        end do
        
        call cpu_time(end_time)
        write(*,'(A,I0,A,I0,A,F8.3,A)') 'Matches: ', match_count, ', reverse char count: ', reverse_count, ' in ', end_time - start_time, ' seconds'
        write(*,*)
    end subroutine benchmark_strings

end program bench