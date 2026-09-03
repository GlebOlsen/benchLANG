#!/bin/bash
# Parses a benchmark_results_*.txt file: averages per-workload times over runs,
# checks that every language produced identical checksums, and prints a table
# sorted by total workload time. Exits 1 on any checksum mismatch.

set -e

if [ $# -lt 1 ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    FILE=$(ls -t "$SCRIPT_DIR"/benchmark_results_*.txt 2>/dev/null | head -n1)
    [ -n "$FILE" ] || { echo "Usage: $0 <results.txt>"; exit 1; }
    echo "Analyzing latest results: $(basename "$FILE")"
else
    FILE=$1
fi
[ -f "$FILE" ] || { echo "Error: $FILE not found"; exit 1; }

awk -F'\t' '
BEGIN {
    nb = split("primes fib strings mandelbrot binarytrees", bench, " ")
}
$1 == "LANG" {
    lang = $2
    if (!(lang in ver)) order[++n] = lang
    ver[lang] = $3; bin[lang] = $4; comp[lang] = $5
}
$1 == "RESULT" {
    lang = $2; b = $4
    t[lang, b] += $6; c[lang, b]++
    if (!((b, $5) in seen)) { seen[b, $5] = 1; distinct[b]++ }
    csum[lang, b] = $5
}
$1 == "RUSAGE" {
    lang = $2
    runs[lang]++; wall[lang] += $4; cpu[lang] += $5 + $6
    if ($7 + 0 > rss[lang]) rss[lang] = $7
}
END {
    bad = 0
    for (j = 1; j <= nb; j++) {
        b = bench[j]
        if (distinct[b] > 1) {
            bad = 1
            printf "\nCHECKSUM MISMATCH in %s:\n", b
            for (i = 1; i <= n; i++) if ((order[i], b) in csum) printf "  %-20s %s\n", order[i], csum[order[i], b]
        }
    }
    if (bad) print "\nRanking below is INVALID: not every language did the same work."

    m = 0
    for (i = 1; i <= n; i++) {
        lang = order[i]
        if (!(runs[lang] > 0)) continue
        total = 0; complete = 1
        for (j = 1; j <= nb; j++) {
            b = bench[j]
            if (c[lang, b] > 0) { avg[lang, b] = t[lang, b] / c[lang, b]; total += avg[lang, b] }
            else complete = 0
        }
        if (!complete) { incomplete[++ni] = lang; continue }
        sum[lang] = total
        langs[++m] = lang
    }
    if (m == 0) {
        nc = 0
        for (i = 1; i <= n; i++) if (comp[order[i]] != "") cl[++nc] = order[i]
        if (nc == 0) { print "No completed runs found."; exit 1 }
        for (i = 2; i <= nc; i++) {
            key = cl[i]; kv = comp[key] + 0; j = i - 1
            while (j >= 1 && comp[cl[j]] + 0 > kv) { cl[j + 1] = cl[j]; j-- }
            cl[j + 1] = key
        }
        sep = "----------------------------------------------------------------------------"
        print ""
        print sep
        printf "%-20s %9s %8s  %s\n", "Language", "Compile", "Bin KiB", "Version"
        print sep
        for (i = 1; i <= nc; i++) {
            lang = cl[i]
            printf "%-20s %9.3f %8s  %s\n", lang, comp[lang],
                (bin[lang] != "" ? sprintf("%.0f", bin[lang] / 1024) : "-"), ver[lang]
        }
        print sep
        print "Compile = wall seconds of the build command on a clean tree. No workloads were run."
        print ""
        exit 0
    }

    for (i = 2; i <= m; i++) {
        key = langs[i]; kv = sum[key]; j = i - 1
        while (j >= 1 && sum[langs[j]] > kv) { langs[j + 1] = langs[j]; j-- }
        langs[j + 1] = key
    }
    fastest = sum[langs[1]]

    sep = "------------------------------------------------------------------------------------------------------------------------------------"
    print ""
    print sep
    printf "%-20s %4s %9s %9s %6s %8s %8s %8s %8s %8s %8s %8s %8s %7s\n",
        "Language", "Runs", "Sum", "Wall", "CPUx", "RSS MiB", "Bin KiB", "Compile", "Primes", "Fib", "Strings", "Mandel", "Trees", "Factor"
    print sep
    for (i = 1; i <= m; i++) {
        lang = langs[i]
        w = wall[lang] / runs[lang]
        printf "%-20s %4d %9.3f %9.2f %6.2f %8.1f %8s %8s %8.3f %8.3f %8.3f %8.3f %8.3f %6.2fx\n",
            lang, runs[lang], sum[lang], w, (w > 0 ? cpu[lang] / runs[lang] / w : 0), rss[lang] / 1024,
            (bin[lang] != "" ? sprintf("%.0f", bin[lang] / 1024) : "-"),
            (comp[lang] != "" ? sprintf("%.2f", comp[lang]) : "-"),
            avg[lang, "primes"], avg[lang, "fib"], avg[lang, "strings"], avg[lang, "mandelbrot"], avg[lang, "binarytrees"],
            (fastest > 0 ? sum[lang] / fastest : 1)
    }
    print sep
    print "Sum = per-workload in-process wall time added up (ranking metric). Wall/CPUx/RSS from GNU time over the whole"
    print "process: CPUx = (user+sys)/wall, >1 means runtime used extra threads (GC, JIT). Bin KiB = stripped native binary."
    print "Compile = wall seconds of the build command on a clean tree, measured once per language."

    for (i = 1; i <= ni; i++) printf "incomplete: %s (missing workloads, see raw file)\n", incomplete[i]

    if (bad) { print "\nCHECKSUM MISMATCH, see above."; exit 1 }
    print "All checksums identical across languages."
    print ""
}
' "$FILE"
