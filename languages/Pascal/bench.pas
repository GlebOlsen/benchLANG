program Bench;
{$mode objfpc}{$H+}
uses SysUtils, UnixType, Linux;

const
    PRIMES_LIMIT    = 20000000;
    FIBONACCI_N     = 45;
    STRING_ITER     = 5000000;
    MANDEL_SIZE     = 4096;
    MANDEL_MAX_ITER = 256;
    TREE_MIN_DEPTH  = 4;
    TREE_MAX_DEPTH  = 18;
    SENTENCE_TEXT   = 'The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again';

type
    PNode = ^TNode;
    TNode = record
        left, right: PNode;
        item: Int64;
    end;

function MonoNow: Double;
var ts: timespec;
begin
    clock_gettime(CLOCK_MONOTONIC, @ts);
    Result := ts.tv_sec + ts.tv_nsec / 1e9;
end;

procedure Report(const name: String; checksum: Int64; secs: Double);
begin
    WriteLn(Format('%s %d %.3f', [name, checksum, secs]));
end;

function IsPrime(n: LongInt): Boolean;
var i: LongInt;
begin
    if n < 2 then Exit(False);
    if n < 4 then Exit(True);
    if (n mod 2 = 0) or (n mod 3 = 0) then Exit(False);
    i := 5;
    while i * i <= n do
    begin
        if (n mod i = 0) or (n mod (i + 2) = 0) then Exit(False);
        i := i + 6;
    end;
    Result := True;
end;

function BenchPrimes(limit: LongInt): Int64;
var i: LongInt;
begin
    Result := 0;
    for i := 2 to limit - 1 do
        if IsPrime(i) then Inc(Result);
end;

function Fib(n: LongInt): Int64;
begin
    if n < 2 then Exit(n);
    Result := Fib(n - 1) + Fib(n - 2);
end;

function BenchStrings(const sentence: String; iters: LongInt): Int64;
var
    words: TStringArray;
    it, i, j, wcount: LongInt;
begin
    words := sentence.Split([' ']);
    wcount := Length(words);
    Result := 0;
    for it := 1 to iters do
        for i := 0 to wcount - 1 do
            for j := 0 to wcount - 1 do
                if words[i] = words[j] then Inc(Result);
end;

function BenchMandelbrot(size: LongInt): Int64;
var
    px, py, iter: LongInt;
    cx, cy, zx, zy, nx: Double;
begin
    Result := 0;
    for py := 0 to size - 1 do
    begin
        cy := py / size * 3.0 - 1.5;
        for px := 0 to size - 1 do
        begin
            cx := px / size * 3.0 - 2.0;
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
            Result := Result + iter;
        end;
    end;
end;

function MakeTree(item: Int64; depth: LongInt): PNode;
begin
    New(Result);
    Result^.item := item;
    if depth = 0 then
    begin
        Result^.left := nil;
        Result^.right := nil;
        Exit;
    end;
    Result^.left := MakeTree(2 * item - 1, depth - 1);
    Result^.right := MakeTree(2 * item, depth - 1);
end;

function CheckTree(n: PNode): Int64;
begin
    if n^.left = nil then Exit(n^.item);
    Result := n^.item + CheckTree(n^.left) - CheckTree(n^.right);
end;

procedure FreeTree(n: PNode);
begin
    if n^.left <> nil then
    begin
        FreeTree(n^.left);
        FreeTree(n^.right);
    end;
    Dispose(n);
end;

function BenchBinaryTrees(maxDepth: LongInt): Int64;
var
    d, i, iters: LongInt;
    stretch, longLived, t: PNode;
begin
    Result := 0;
    stretch := MakeTree(0, maxDepth + 1);
    Result := Result + CheckTree(stretch);
    FreeTree(stretch);
    longLived := MakeTree(0, maxDepth);
    d := TREE_MIN_DEPTH;
    while d <= maxDepth do
    begin
        iters := 1 shl (maxDepth - d + TREE_MIN_DEPTH);
        for i := 0 to iters - 1 do
        begin
            t := MakeTree(i + 1, d);
            Result := Result + CheckTree(t);
            FreeTree(t);
        end;
        d := d + 2;
    end;
    Result := Result + CheckTree(longLived);
    FreeTree(longLived);
end;

var
    t: Double;
    r: Int64;
begin
    t := MonoNow; r := BenchPrimes(PRIMES_LIMIT);          Report('primes', r, MonoNow - t);
    t := MonoNow; r := Fib(FIBONACCI_N);                   Report('fib', r, MonoNow - t);
    t := MonoNow; r := BenchStrings(SENTENCE_TEXT, STRING_ITER); Report('strings', r, MonoNow - t);
    t := MonoNow; r := BenchMandelbrot(MANDEL_SIZE);        Report('mandelbrot', r, MonoNow - t);
    t := MonoNow; r := BenchBinaryTrees(TREE_MAX_DEPTH);    Report('binarytrees', r, MonoNow - t);
end.
