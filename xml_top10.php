<?php
header("Content-type: text/xml");
$steamid = $_GET["Steamid"];
include("inc/dbconnect.php");
mysql_query("SET CHARACTER SET 'utf8'");
$sql = 'SELECT * FROM `Player` ORDER BY `POINTS` DESC LIMIT 0, 10 ';
$ergebnis = mysql_query($sql);
$i = 1;
echo "<?xml version=\"1.0\" encoding=\"utf-8\"?> \r\n";
echo "<players> \r\n";
while ($adr = mysql_fetch_array($ergebnis)){
$NAME = $adr['NAME'];
$POINTS = $adr['POINTS'];
$STEAMID = $adr['STEAMID'];
$SUICIDES = $adr['SUICIDES'];
$DEATHS = $adr['DEATHS'];
$KILLS = $adr['KILLS'];
echo "<player> \r\n";
echo "<rank>".$i."</rank>";
echo "<name>".$NAME."</name>";
echo "<points>".$POINTS."</points>";
echo "<steamid>".$STEAMID."</steamid>";
echo "<suicides>".$SUICIDES."</suicides>";
echo "<deaths>".$DEATHS."</deaths>";
echo "<kills>".$KILLS."</kills>";
echo "</player> \r\n";
$i = $i + 1;
}
echo "</players> \r\n";
?> 
