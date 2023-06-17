#include <stdio.h> 
#include <time.h>
int main ()
{
    clock_t t;
    t = clock();
    int fib(int n) {
        if (n <= 1) {
            return n;
        }
        return fib(n-1) + fib(n-2);
    }
    fib(45);
    t = clock() - t;
    double time_taken = ((double)t)/CLOCKS_PER_SEC;
    printf("%f seconds to execute\n", time_taken);
    return 0;
}