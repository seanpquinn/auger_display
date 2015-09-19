<?php

$datei = fopen("../stats/gallery.txt","r");
$count = fgets($datei,1000);
fclose($datei);
$count=$count + 1 ;
echo "$count" ;
echo " hits" ;
echo "\n" ;

$datei = fopen("../stats/gallery.txt","w");
fwrite($datei, $count);
fclose($datei);

?>
