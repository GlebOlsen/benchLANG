using System.Diagnostics;
int i, j, n = 10000000;
Stopwatch stopwatch = new Stopwatch();
stopwatch.Start();
for (i = 2; i <= n; i++){ 
    for (j = 2; j <= (i/j); j++){
        if (i%j == 0) {
            break;
        }
    }
    if (j > (i/j)) {Console.WriteLine(i);}
}
Console.WriteLine("Elapsed Time is {0} ms", stopwatch.ElapsedMilliseconds);