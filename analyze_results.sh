#!/bin/bash
# Parse a benchmark_results_*.txt file, average per-lang times across runs,
# print a sorted overview table (fastest first) with slowness factor vs winner.

set -e

if [ $# -lt 1 ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    FILE=$(ls -t "$SCRIPT_DIR"/benchmark_results_*.txt 2>/dev/null | head -n1)
    if [ -z "$FILE" ]; then echo "Usage: $0 <results.txt>"; exit 1; fi
    echo "Analyzing latest results: $(basename "$FILE")"
else
    FILE=$1
fi

[ -f "$FILE" ] || { echo "Error: $FILE not found"; exit 1; }

awk '
function fmt(x) { return sprintf("%.3f", x) }

/^=== .* - Run [0-9]+ ===$/ {
    line = $0
    sub(/^=== /, "", line); sub(/ - Run [0-9]+ ===$/, "", line)
    current = line; runs[current]++
    next
}
/^Found .* primes in [0-9.]+ seconds/        { if (current) { primes[current]+=$(NF-1); pc[current]++ } ; next }
/^Fibonacci\( *[0-9]+\) = +.* in +[0-9.]+ seconds/ { if (current) { fibR[current]+=$(NF-1); frc[current]++ }; next }
/^Strings: total= *[0-9]+ in +[0-9.]+ seconds/ { if (current) { strs[current]+=$(NF-1); sc[current]++ }; next }
/^Mandelbrot: checksum= *-?[0-9]+ in +[0-9.]+ seconds/ { if (current) { mb_[current]+=$(NF-1); mbc[current]++ }; next }
/^BinaryTrees: checksum= *-?[0-9]+ in +[0-9.]+ seconds/ { if (current) { bt_[current]+=$(NF-1); btc[current]++ }; next }
/^Total execution time: [0-9.]+ seconds/       { if (current) { total[current]+=$(NF-1); tc[current]++ }; next }

END {
    n = 0
    for (lang in total) {
        if (tc[lang] > 0) {
            avg_total[lang]  = total[lang] / tc[lang]
            avg_primes[lang] = (pc[lang]>0)  ? primes[lang]/pc[lang]  : 0
            avg_fibR[lang]   = (frc[lang]>0) ? fibR[lang]/frc[lang]   : 0
            avg_strs[lang]   = (sc[lang]>0)  ? strs[lang]/sc[lang]    : 0
            avg_mb[lang]     = (mbc[lang]>0) ? mb_[lang]/mbc[lang]    : 0
            avg_bt[lang]     = (btc[lang]>0) ? bt_[lang]/btc[lang]    : 0
            langs[n++] = lang
        }
    }
    if (n == 0) { print "No completed runs found."; exit 1 }

    # Sort by avg_total ascending
    for (i = 1; i < n; i++) {
        key = langs[i]; kv = avg_total[key]
        j = i - 1
        while (j >= 0 && avg_total[langs[j]] > kv) { langs[j+1] = langs[j]; j-- }
        langs[j+1] = key
    }
    fastest = avg_total[langs[0]]

    print ""
    print "============================================================================================="
    print "                              BENCHMARK OVERVIEW (averaged)"
    print "============================================================================================="
    printf "%-22s %5s %9s %9s %9s %9s %9s %9s %7s\n", \
           "Language","Runs","Total","Primes","FibRec","Strings","Mandel","BinTrees","Factor"
    print "---------------------------------------------------------------------------------------------"
    for (i = 0; i < n; i++) {
        lang = langs[i]
        factor = (fastest > 0) ? avg_total[lang] / fastest : 1
        printf "%-22s %5d %9s %9s %9s %9s %9s %9s %6.2fx\n", \
               lang, tc[lang], fmt(avg_total[lang]), fmt(avg_primes[lang]), \
               fmt(avg_fibR[lang]), fmt(avg_strs[lang]), \
               fmt(avg_mb[lang]), fmt(avg_bt[lang]), factor
    }
    print "============================================================================================="
    print ""
}
' "$FILE"
