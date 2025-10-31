program Bench;
uses SysUtils;

const
  PRIMES_LIMIT = 20000000;
  FIBONACCI_N = 45;
  MATRIX_SIZE = 2000;
  MATRIX_RAND_MAX = 100;
  SENTENCE = 'The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again';
  STRING_OPS = 200000000;
  STRING_REDUCTION_FACTOR = 100;
  SORT_SIZE = 10000000;
  RAND_SEED = 42;

type
  TMatrix = array of Double;
  TIntArray = array of Int64;
  TStringArray = array of string;

var
  MatrixA, MatrixB, MatrixC: TMatrix;
  SortArray: TIntArray;

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

procedure BenchmarkMatrixMultiplication;
var
  i, j, k, n: Int64;
  size: Int64;
  startTime: TDateTime;
  elapsed: Double;
begin
  WriteLn(Format('Running Matrix Multiplication Benchmark (%dx%d)...', [MATRIX_SIZE, MATRIX_SIZE]));
  startTime := Now;
  
  n := MATRIX_SIZE;
  size := n * n;
  SetLength(MatrixA, size);
  SetLength(MatrixB, size);
  SetLength(MatrixC, size);
  
  RandSeed := RAND_SEED;
  for i := 0 to size - 1 do
  begin
    MatrixA[i] := Random(MATRIX_RAND_MAX);
    MatrixB[i] := Random(MATRIX_RAND_MAX);
    MatrixC[i] := 0.0;
  end;
  
  // i-k-j loop order for cache efficiency
  for i := 0 to n - 1 do
    for k := 0 to n - 1 do
      for j := 0 to n - 1 do
        MatrixC[i * n + j] := MatrixC[i * n + j] + MatrixA[i * n + k] * MatrixB[k * n + j];
  
  elapsed := (Now - startTime) * 86400;
  WriteLn(Format('Matrix multiplication completed in %.3f seconds', [elapsed]));
  WriteLn;
end;

procedure QuickSort(var arr: TIntArray; low, high: Int64);
type
  TStackItem = record
    low, high: Int64;
  end;
var
  stack: array[0..1000] of TStackItem;
  top: Integer;
  i, j, pivot, temp: Int64;
  curLow, curHigh: Int64;
begin
  top := -1;
  
  // Push initial range
  Inc(top);
  stack[top].low := low;
  stack[top].high := high;
  
  while top >= 0 do
  begin
    // Pop range
    curLow := stack[top].low;
    curHigh := stack[top].high;
    Dec(top);
    
    if curLow < curHigh then
    begin
      // Partition
      pivot := arr[curHigh];
      i := curLow - 1;
      
      for j := curLow to curHigh - 1 do
      begin
        if arr[j] <= pivot then
        begin
          Inc(i);
          temp := arr[i];
          arr[i] := arr[j];
          arr[j] := temp;
        end;
      end;
      
      temp := arr[i + 1];
      arr[i + 1] := arr[curHigh];
      arr[curHigh] := temp;
      
      // Push sub-ranges
      if (i + 1) > curLow then
      begin
        Inc(top);
        stack[top].low := curLow;
        stack[top].high := i;
      end;
      
      if (i + 2) < curHigh then
      begin
        Inc(top);
        stack[top].low := i + 2;
        stack[top].high := curHigh;
      end;
    end;
  end;
end;

procedure BenchmarkSorting;
var
  i: Int64;
  startTime: TDateTime;
  elapsed: Double;
begin
  WriteLn(Format('Running Sorting Benchmark (%d elements)...', [SORT_SIZE]));
  startTime := Now;
  
  SetLength(SortArray, SORT_SIZE);
  RandSeed := RAND_SEED;
  
  for i := 0 to SORT_SIZE - 1 do
    SortArray[i] := Random(MaxInt);
  
  QuickSort(SortArray, 0, SORT_SIZE - 1);
  
  elapsed := (Now - startTime) * 86400;
  WriteLn(Format('Sorting completed in %.3f seconds', [elapsed]));
  WriteLn;
end;

function SplitString(const s: string; delimiter: Char): TStringArray;
var
  i, start, count: Int64;
  temp: TStringArray;
begin
  count := 0;
  start := 1;
  
  // Count words
  for i := 1 to Length(s) do
    if (s[i] = delimiter) or (i = Length(s)) then Inc(count);
  
  SetLength(temp, count);
  count := 0;
  start := 1;
  
  // Extract words
  for i := 1 to Length(s) do
  begin
    if (s[i] = delimiter) or (i = Length(s)) then
    begin
      if i = Length(s) then
        temp[count] := Copy(s, start, i - start + 1)
      else
        temp[count] := Copy(s, start, i - start);
      Inc(count);
      start := i + 1;
    end;
  end;
  
  SplitString := temp;
end;

procedure BenchmarkStringOperations;
var
  hay: AnsiString;
  words: TStringArray;
  i, j, k, repeats, found, total, wordLen, hayLen: Int64;
  startTime: TDateTime;
  elapsed: Double;
  match: Boolean;
  sentenceLen: Int64;
begin
  WriteLn(Format('Running String Operations Benchmark (%d operations)...', [STRING_OPS]));
  startTime := Now;
  
  repeats := STRING_OPS div STRING_REDUCTION_FACTOR;
  sentenceLen := Length(SENTENCE);
  
  // Build large string using SetLength and Move for efficiency
  SetLength(hay, sentenceLen * repeats);
  for i := 0 to repeats - 1 do
    Move(SENTENCE[1], hay[i * sentenceLen + 1], sentenceLen);
  
  words := SplitString(SENTENCE, ' ');
  total := 0;
  hayLen := Length(hay);
  
  for i := 0 to High(words) do
  begin
    wordLen := Length(words[i]);
    if wordLen = 0 then Continue;
    found := 0;
    
    // Manual string search
    for j := 1 to hayLen - wordLen + 1 do
    begin
      match := True;
      for k := 1 to wordLen do
      begin
        if hay[j + k - 1] <> words[i][k] then
        begin
          match := False;
          break;
        end;
      end;
      if match then Inc(found);
    end;
    
    total := total + found;
  end;
  
  elapsed := (Now - startTime) * 86400;
  WriteLn(Format('String operations completed in %.3f seconds (found %d word instances)', [elapsed, total]));
  WriteLn;
end;

var
  totalStart: TDateTime;
  totalElapsed: Double;

begin
  WriteLn('=== COMPREHENSIVE PROGRAMMING LANGUAGE BENCHMARK (Pascal) ===');
  WriteLn;
  
  totalStart := Now;
  
  BenchmarkPrimes;
  BenchmarkFibonacci;
  BenchmarkMatrixMultiplication;
  BenchmarkSorting;
  BenchmarkStringOperations;
  
  totalElapsed := (Now - totalStart) * 86400;
  WriteLn('=== BENCHMARK COMPLETE ===');
  WriteLn(Format('Total execution time: %.3f seconds', [totalElapsed]));
end.