using System;
using System.Diagnostics;
static bool IsPrime(int n)
{
    if (n <= 1)
        return false;
    if (n <= 3)
        return true;
    if (n % 2 == 0 || n % 3 == 0)
        return false;
    int i = 5;
    while (i * i <= n)
    {
        if (n % i == 0 || n % (i + 2) == 0)
            return false;
        i += 6;
    }
    return true;
}
Stopwatch stopwatch = Stopwatch.StartNew();
for (int i = 2; i < 10000000; i++)
{
    if (IsPrime(i))
        Console.WriteLine(i);
}
stopwatch.Stop();
double timeTaken = stopwatch.Elapsed.TotalSeconds;
Console.WriteLine($"{timeTaken} seconds to execute");
