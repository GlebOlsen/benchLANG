#include <stdio.h> 
#include <time.h>
int main ()
{
    clock_t t;
    t = clock();
    int i, j;
    for(i=2; i<10000000; i++)
    {
        for(j=2; j <= (i/j); j++)
            if(!(i%j))
                break;
        if(j > (i/j))
            printf("%d\n", i);
    }
    t = clock() - t;
    double time_taken = ((double)t)/CLOCKS_PER_SEC;
    printf("%f seconds to execute\n", time_taken);
    return 0;
}