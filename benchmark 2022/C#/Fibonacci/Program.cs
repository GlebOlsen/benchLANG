using System.Diagnostics;
Stopwatch stopwatch = new Stopwatch();
stopwatch.Start();
int fib(int n) {
	if (n <= 1) {
		return n;
	}
	return fib(n-1) + fib(n-2);
}
fib(45);
Console.WriteLine("Elapsed Time is {0} ms", stopwatch.ElapsedMilliseconds);