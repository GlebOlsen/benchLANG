program Bench;
{$mode objfpc}{$H+}
uses SysUtils, StrUtils, Math, UnixType, Linux, Generics.Collections, Generics.Defaults;

const
    PRIMES_LIMIT    = 8000000;
    FIBONACCI_N     = 43;
    STRING_ITER     = 1200000;
    MANDEL_SIZE     = 2048;
    MANDEL_MAX_ITER = 256;
    TREE_MIN_DEPTH  = 4;
    TREE_MAX_DEPTH  = 17;
    SENTENCE_TEXT   = 'The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again';
    KNUC_LENGTH     = 6000000;
    KNUC_SEED       = 42;
    KNUC_IM         = 139968;
    KNUC_IA         = 3877;
    KNUC_IC         = 29573;
    KNUC_QUERY      = 'GGTATTTTAATTTATAGT';

type
    PNode = ^TNode;
    TNode = record
        left, right: PNode;
        item: Int64;
    end;
    TKmerCounts = specialize TDictionary<String, LongInt>;
    TKmer = specialize TPair<String, LongInt>;
    TKmerArray = specialize TArray<TKmer>;
    TKmerSort = specialize TArrayHelper<TKmer>;
    TKmerComparer = specialize TComparer<TKmer>;

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
    words, cur: TStringArray;
    it, i, j, w, wcount: LongInt;
begin
    words := sentence.Split([' ']);
    wcount := Length(words);
    cur := Copy(words);
    Result := 0;
    for it := 0 to iters - 1 do
    begin
        w := it mod wcount;
        cur[w] := ReverseString(cur[w]);
        for i := 0 to wcount - 1 do
            for j := 0 to wcount - 1 do
                if cur[i] = words[j] then Inc(Result);
    end;
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
    stretch := MakeTree(0, maxDepth + 1);
    Result := CheckTree(stretch);
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

function CompareKmers(constref a, b: TKmer): LongInt;
begin
    Result := CompareValue(b.Value, a.Value);
    if Result = 0 then Result := CompareStr(a.Key, b.Key);
end;

function BenchKnucleotide(len: LongInt): Int64;
const
    ks: array[0..6] of LongInt = (1, 2, 3, 4, 6, 12, 18);
var
    seq, key: String;
    counts: TKmerCounts;
    entries: TKmerArray;
    seed, i, k, c, r: LongInt;
begin
    SetLength(seq, len);
    seed := KNUC_SEED;
    for i := 1 to len do
    begin
        seed := (seed * KNUC_IA + KNUC_IC) mod KNUC_IM;
        if seed < 42404 then seq[i] := 'A'
        else if seed < 70116 then seq[i] := 'C'
        else if seed < 97766 then seq[i] := 'G'
        else seq[i] := 'T';
    end;
    Result := 0;
    for k in ks do
    begin
        counts := TKmerCounts.Create;
        for i := 1 to len - k + 1 do
        begin
            key := Copy(seq, i, k);
            if counts.TryGetValue(key, c) then
                counts[key] := c + 1
            else
                counts.Add(key, 1);
        end;
        Result := Result + counts.Count;
        if k <= 2 then
        begin
            entries := counts.ToArray;
            TKmerSort.Sort(entries, TKmerComparer.Construct(@CompareKmers));
            for r := 0 to High(entries) do
                Result := Result + Int64(r + 1) * entries[r].Value;
        end
        else if counts.TryGetValue(Copy(KNUC_QUERY, 1, k), c) then
            Result := Result + c;
        counts.Free;
    end;
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
    t := MonoNow; r := BenchKnucleotide(KNUC_LENGTH);       Report('knucleotide', r, MonoNow - t);
end.
