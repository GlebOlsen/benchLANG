program Bench;
{$mode objfpc}{$H+}
uses SysUtils, DateUtils;

const
    PRIMES_LIMIT    = 20000000;
    FIBONACCI_N     = 45;
    STRING_ITER     = 5000000;
    MANDEL_W        = 4096;
    MANDEL_H        = 4096;
    MANDEL_MAX_ITER = 256;
    TREE_MIN_DEPTH  = 4;
    TREE_MAX_DEPTH  = 18;
    SENTENCE        = 'The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again';

type
    PTreeNode = ^TTreeNode;
    TTreeNode = record
        left, right: PTreeNode;
        item: Int64;
    end;

function IsPrime(n: LongInt): Boolean;
var i: LongInt;
begin
    if n <= 1 then Exit(False);
    if n <= 3 then Exit(True);
    if (n mod 2 = 0) or (n mod 3 = 0) then Exit(False);
    i := 5;
    while Int64(i)*i <= n do
    begin
        if (n mod i = 0) or (n mod (i+2) = 0) then Exit(False);
        i := i + 6;
    end;
    Result := True;
end;

procedure BenchPrimes;
var i, c: LongInt; start: TDateTime;
begin
    start := Now;
    c := 0;
    for i := 2 to PRIMES_LIMIT - 1 do
        if IsPrime(i) then Inc(c);
    WriteLn(Format('Found %d primes in %.3f seconds', [c, MilliSecondsBetween(Now, start) / 1000.0]));
    WriteLn;
end;

function Fib(n: LongInt): Int64;
begin
    if n <= 1 then Exit(n);
    Result := Fib(n-1) + Fib(n-2);
end;

procedure BenchFibRec;
var r: Int64; start: TDateTime;
begin
    start := Now;
    r := Fib(FIBONACCI_N);
    WriteLn(Format('Fibonacci(%d) = %d in %.3f seconds', [FIBONACCI_N, r, MilliSecondsBetween(Now, start) / 1000.0]));
    WriteLn;
end;

procedure BenchStrings;
var
    parts: TStringArray;
    wcount, i, j, iter: LongInt;
    total, count: QWord;
    start: TDateTime;
    wi: String;
begin
    start := Now;
    parts := SENTENCE.Split([' ']);
    wcount := Length(parts);
    total := 0;
    for iter := 0 to STRING_ITER - 1 do
    begin
        for i := 0 to wcount - 1 do
        begin
            count := 0;
            wi := parts[i];
            for j := 0 to wcount - 1 do
                if wi = parts[j] then Inc(count);
            total := total + count;
        end;
    end;
    WriteLn(Format('Strings: total=%u in %.3f seconds', [total, MilliSecondsBetween(Now, start) / 1000.0]));
    WriteLn;
end;

procedure BenchMandelbrot;
var
    px, py, iter: LongInt;
    cx, cy, zx, zy, nx: Double;
    checksum: Int64;
    start: TDateTime;
begin
    start := Now;
    checksum := 0;
    for py := 0 to MANDEL_H - 1 do
    begin
        cy := (Double(py) / Double(MANDEL_H)) * 3.0 - 1.5;
        for px := 0 to MANDEL_W - 1 do
        begin
            cx := (Double(px) / Double(MANDEL_W)) * 3.0 - 2.0;
            zx := 0.0;
            zy := 0.0;
            iter := 0;
            while (iter < MANDEL_MAX_ITER) and (zx * zx + zy * zy <= 4.0) do
            begin
                nx := zx * zx - zy * zy + cx;
                zy := 2.0 * zx * zy + cy;
                zx := nx;
                Inc(iter);
            end;
            checksum := checksum + Int64(iter);
        end;
    end;
    WriteLn(Format('Mandelbrot: checksum=%d in %.3f seconds', [checksum, MilliSecondsBetween(Now, start) / 1000.0]));
    WriteLn;
end;

function MakeTree(item: Int64; depth: LongInt): PTreeNode;
var n: PTreeNode;
begin
    New(n);
    n^.item := item;
    if depth = 0 then
    begin
        n^.left := nil;
        n^.right := nil;
        Exit(n);
    end;
    n^.left := MakeTree(2 * item - 1, depth - 1);
    n^.right := MakeTree(2 * item, depth - 1);
    Result := n;
end;

function CheckTree(n: PTreeNode): Int64;
begin
    if n^.left = nil then Exit(n^.item);
    Result := n^.item + CheckTree(n^.left) - CheckTree(n^.right);
end;

procedure FreeTree(n: PTreeNode);
begin
    if n^.left <> nil then
    begin
        FreeTree(n^.left);
        FreeTree(n^.right);
    end;
    Dispose(n);
end;

procedure BenchBinaryTrees;
var
    d, i, iters: LongInt;
    checksum, sum: Int64;
    stretch, longLived, t: PTreeNode;
    start: TDateTime;
begin
    start := Now;
    checksum := 0;

    stretch := MakeTree(0, TREE_MAX_DEPTH + 1);
    checksum := checksum + CheckTree(stretch);
    FreeTree(stretch);

    longLived := MakeTree(0, TREE_MAX_DEPTH);

    d := TREE_MIN_DEPTH;
    while d <= TREE_MAX_DEPTH do
    begin
        iters := 1 shl (TREE_MAX_DEPTH - d + TREE_MIN_DEPTH);
        sum := 0;
        for i := 0 to iters - 1 do
        begin
            t := MakeTree(Int64(i + 1), d);
            sum := sum + CheckTree(t);
            FreeTree(t);
        end;
        checksum := checksum + sum;
        d := d + 2;
    end;

    checksum := checksum + CheckTree(longLived);
    FreeTree(longLived);

    WriteLn(Format('BinaryTrees: checksum=%d in %.3f seconds', [checksum, MilliSecondsBetween(Now, start) / 1000.0]));
    WriteLn;
end;

var totalStart: TDateTime;
begin
    WriteLn('=== PROGRAMMING LANGUAGE BENCHMARK ===');
    WriteLn;
    totalStart := Now;
    BenchPrimes;
    BenchFibRec;
    BenchStrings;
    BenchMandelbrot;
    BenchBinaryTrees;
    WriteLn('=== BENCHMARK COMPLETE ===');
    WriteLn(Format('Total execution time: %.3f seconds', [MilliSecondsBetween(Now, totalStart) / 1000.0]));
end.
