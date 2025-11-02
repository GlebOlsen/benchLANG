program Bench;
uses SysUtils;

const
  PRIMES_LIMIT = 20000000;
  FIBONACCI_N = 45;
  SENTENCE = 'The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again';

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

procedure BenchmarkStrings;
var
  words: array of string;
  wordsCount, j, k, rev, charIdx: Integer;
  i, matchCount, reverseCount: Int64;
  startTime: TDateTime;
  elapsed: Double;
  currentWord, otherWord: string;
  tempSentence: string;
  currentChars: array of Char;
  temp: Char;
begin
  WriteLn('Running String Benchmark...');
  startTime := Now;
  
  tempSentence := SENTENCE;
  SetLength(words, 0);
  wordsCount := 0;
  
  // Split sentence into words
  while Pos(' ', tempSentence) > 0 do
  begin
    SetLength(words, wordsCount + 1);
    words[wordsCount] := Copy(tempSentence, 1, Pos(' ', tempSentence) - 1);
    Inc(wordsCount);
    Delete(tempSentence, 1, Pos(' ', tempSentence));
  end;
  if Length(tempSentence) > 0 then
  begin
    SetLength(words, wordsCount + 1);
    words[wordsCount] := tempSentence;
    Inc(wordsCount);
  end;
  
  matchCount := 0;
  reverseCount := 0;
  
  for i := 0 to PRIMES_LIMIT - 1 do
  begin
    currentWord := words[i mod wordsCount];
    
    // Compare current word against all other words
    for j := 0 to wordsCount - 1 do
    begin
      otherWord := words[j];
      if currentWord = otherWord then
        Inc(matchCount);
    end;
    
    // Extract and reverse each word from sentence
    SetLength(currentChars, 100);
    charIdx := 0;
    for k := 1 to Length(SENTENCE) do
    begin
      if SENTENCE[k] = ' ' then
      begin
        if charIdx > 0 then
        begin
          // Reverse the word
          for rev := 0 to charIdx - 1 do
          begin
            temp := currentChars[charIdx - 1 - rev];
          end;
          reverseCount := reverseCount + charIdx;
          charIdx := 0;
        end;
      end
      else
      begin
        currentChars[charIdx] := SENTENCE[k];
        Inc(charIdx);
      end;
    end;
    // Handle last word
    if charIdx > 0 then
    begin
      for rev := 0 to charIdx - 1 do
      begin
        temp := currentChars[charIdx - 1 - rev];
      end;
      reverseCount := reverseCount + charIdx;
    end;
  end;
  
  elapsed := (Now - startTime) * 86400;
  WriteLn(Format('Matches: %d, reverse char count: %d in %.3f seconds', [matchCount, reverseCount, elapsed]));
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
  BenchmarkStrings;
  
  totalElapsed := (Now - totalStart) * 86400;
  WriteLn('=== BENCHMARK COMPLETE ===');
  WriteLn(Format('Total execution time: %.3f seconds', [totalElapsed]));
end.