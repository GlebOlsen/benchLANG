program Bench;
uses SysUtils;

const
  PRIMES_LIMIT = 20000000;
  FIBONACCI_N = 45;

function IsPrime(n: Int64): Boolean;
var
  i: Int64;
begin
  if n <= 1 then
  begin
    IsPrime := False;
    Exit;
  end;
  if n <= 3 then
  begin
    IsPrime := True;
    Exit;
  end;
  if (n mod 2 = 0) or (n mod 3 = 0) then
  begin
    IsPrime := False;
    Exit;
  end;
  
  i := 5;
  while i * i <= n do
  begin
    if (n mod i = 0) or (n mod (i + 2) = 0) then
    begin
      IsPrime := False;
      Exit;
    end;
    Inc(i, 6);
  end;
  IsPrime := True;
end;

procedure BenchmarkPrimes;
var
  i, count: Int64;
  startTime: TDateTime;
  elapsed: Double;
begin
  WriteLn(Format('Running Prime Numbers Benchmark (up to %d)...', [PRIMES_LIMIT]));
  startTime := Now;
  
  count := 0;
  for i := 2 to PRIMES_LIMIT - 1 do
    if IsPrime(i) then Inc(count);
  
  elapsed := (Now - startTime) * 86400; // Convert to seconds
  WriteLn(Format('Found %d primes in %.3f seconds', [count, elapsed]));
  WriteLn;
end;

function Fib(n: Integer): Int64;
begin
  if n <= 1 then 
    Fib := n
  else 
    Fib := Fib(n-1) + Fib(n-2);
end;

procedure BenchmarkFibonacci;
var
  result: Int64;
  startTime: TDateTime;
  elapsed: Double;
begin
  WriteLn(Format('Running Fibonacci Benchmark (n=%d, recursive)...', [FIBONACCI_N]));
  startTime := Now;
  
  result := Fib(FIBONACCI_N);
  
  elapsed := (Now - startTime) * 86400;
  WriteLn(Format('Fibonacci(%d) = %d in %.3f seconds', [FIBONACCI_N, result, elapsed]));
  WriteLn;
end;

var
  totalStart: TDateTime;
  totalElapsed: Double;

begin
  WriteLn('=== PROGRAMMING LANGUAGE BENCHMARK ===');
  WriteLn;
  
  totalStart := Now;
  
  BenchmarkPrimes;
  BenchmarkFibonacci;
  
  totalElapsed := (Now - totalStart) * 86400;
  WriteLn('=== BENCHMARK COMPLETE ===');
  WriteLn(Format('Total execution time: %.3f seconds', [totalElapsed]));
end.