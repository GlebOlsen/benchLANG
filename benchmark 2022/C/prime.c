#include <stdio.h>
#include <time.h>
int is_prime(int n) {
    if (n <= 1)
        return 0;
    if (n <= 3)
        return 1;
    if (n % 2 == 0 || n % 3 == 0)
        return 0;
    int i = 5;
    while (i * i <= n) {
        if (n % i == 0 || n % (i + 2) == 0)
            return 0;
        i += 6;
    }
    return 1;
}
int main() {
    clock_t t;
    t = clock();
    int i;
    for (i = 2; i < 10000000; i++) {
        if (is_prime(i))
            printf("%d\n", i);
    }
    t = clock() - t;
    double time_taken = ((double)t) / CLOCKS_PER_SEC;
    printf("%f seconds to execute\n", time_taken);
    return 0;
}
