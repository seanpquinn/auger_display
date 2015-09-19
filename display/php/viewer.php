<?php

$datei = fopen("../stats/viewer.txt","r");
$count = fgets($datei,1000);
fclose($datei);
$count=$count + 1 ;
echo "$count" ;
echo " hits" ;
echo "\n" ;

$datei = fopen("../stats/viewer.txt","w");
fwrite($datei, $count);
fclose($datei);

?>
