<?php
$starttime = microtime(true);
$n = 10000000;
for ($i = 2; $i <= $n; $i++){ 
    for ($j = 2; $j <= ($i/$j); $j++){
        if ($i%$j == 0) {
            break;
        }
    }
    if ($j > ($i/$j)) {
        echo($i. "\n");
    }
}
$endtime = microtime(true);
$timediff = $endtime - $starttime;
echo $timediff
?>