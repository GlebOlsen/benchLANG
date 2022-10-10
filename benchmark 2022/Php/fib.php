<?php
$starttime = microtime(true);
function fib(int $n) {
	if ($n <= 1) {
		return $n;
	}
	return fib($n-1) + fib($n-2);
}
fib(45);
$endtime = microtime(true);
$timediff = $endtime - $starttime;
echo $timediff
?>
