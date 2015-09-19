<?php

$datei = fopen("../stats/aera.txt","r");
$count = fgets($datei,1000);
fclose($datei);
$count=$count + 1 ;
echo "$count" ;
echo " hits" ;
echo "\n" ;

$datei = fopen("../stats/aera.txt","w");
fwrite($datei, $count);
fclose($datei);

?>
