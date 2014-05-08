<?php
header("Content-type: text/xml");
$steamid = $_GET["Steamid"];
include("inc/dbconnect.php");
$sql = "SELECT * FROM `Player` WHERE `STEAMID` LIKE '$steamid'";
$ergebnis = mysql_query($sql);
while ($adr = mysql_fetch_array($ergebnis)){
$NAME = $adr['NAME'];
$KILLS = $adr['KILLS'];
$DEATHS = $adr['DEATHS'];
$SUICIDES = $adr['SUICIDES'];
$POINTS = $adr['POINTS'];
}
if ($POINTS != "")
{
######rank#####
$sql2 = "SELECT ID FROM `Player` WHERE `POINTS` >='$POINTS'";
$ergebnis2 = mysql_query($sql2);
$RANK = mysql_num_rows($ergebnis2);
echo mysql_error();

###############



echo "<?xml version=\"1.0\" encoding=\"utf-8\"?> \r\n";
echo "<player> \r\n";
echo "<STEAMID>".$steamid."</STEAMID>";
echo "<NAME>".$NAME."</NAME>";
echo "<KILLS>".$KILLS."</KILLS>";
echo "<DEATHS>".$DEATHS."</DEATHS>";
echo "<SUICIDES>".$SUICIDES."</SUICIDES>";
echo "<POINTS>".$POINTS."</POINTS>";
echo "<RANK>".$RANK."</RANK>";
echo "</player> \r\n";
}else
{
echo "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?> \r\n";
echo "<player> \r\n";
echo "</player> \r\n";
}
?> 