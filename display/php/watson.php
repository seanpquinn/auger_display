<?php

$datei = fopen("../stats/watson.txt","r");
$count = fgets($datei,1000);
fclose($datei);
$count=$count + 1 ;
echo "$count" ;
echo " hits" ;
echo "\n" ;

$datei = fopen("../stats/watson.txt","w");
fwrite($datei, $count);
fclose($datei);

?>
