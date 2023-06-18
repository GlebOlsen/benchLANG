<?php
function is_prime($n) {
    if ($n <= 1)
        return 0;
    if ($n <= 3)
        return 1;
    if ($n % 2 == 0 || $n % 3 == 0)
        return 0;
    $i = 5;
    while ($i * $i <= $n) {
        if ($n % $i == 0 || $n % ($i + 2) == 0)
            return 0;
        $i += 6;
    }
    return 1;
}
$t = microtime(true);
for ($i = 2; $i < 10000000; $i++) {
    if (is_prime($i))
        echo $i . "\n";
}
$time_taken = microtime(true) - $t;
echo $time_taken . " seconds to execute\n";
?>