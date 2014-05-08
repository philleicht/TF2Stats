<?php
include("inc/dbconnect.php");
?>
<title>Das schlechtbesuchteste TF2 Ranking ALLER ZEITEN by K-Play</title>
<link rel=stylesheet type=text/css href=default.css>
<div align="center">
  <h1><strong><img src="images/logo.png" alt="TF2" width="912" height="213" /></strong></h1>
</div>
<div align=center class=main_table style="margin-right:auto;margin-left:auto;width: 40%; padding: 10px">
  <h1><a href="player_ranking.php">Player Ranking</a></h1>
  <h1><a href="map_ranking.php">Map Stats</a></h1>
  <h3 class="flatrow_dark">Online Players:</h3>
  <table width="200" border="1">
    	<?php
	mysql_query("SET CHARACTER SET 'utf8'");
	$ts1 = time() - 90;
$sql = 'SELECT * FROM `Player` WHERE LASTONTIME >= '.$ts1.' ORDER BY `POINTS` DESC';
$ergebnis = mysql_query($sql);
$i = 1;
$i = $i + $fromplayer;
while ($adr = mysql_fetch_array($ergebnis)){
 $timestamp = $adr['LASTONTIME'];
 if ($timestamp == 0)
 {
 $laststr = "never";
 }
 else
 {
 $datum = date("d.m.Y",$timestamp);
  $uhrzeit = date("H:i",$timestamp);
  $laststr = $datum." - ".$uhrzeit;
  }
echo '
    <tr>
      <td><a href="player.php?steamid='.$adr['STEAMID'].'">'.$adr['NAME'].'</a></td>
    </tr>
	';
}
	?>
  </table>
  <p class="flatrow_dark">&nbsp;</p>
  <p>&nbsp;</p>
  <p><strong><a href="http://compactaim.de" target="_blank">TF2 Stats Webinterface Version 1.0.2 by R-Hehl Design by Goerge</a></strong></p>
  <h5>Visit #schlechtbesuchtester on irc.quakenet.org. </h5>
  <h5>Special thank's to:</h5>
  <h5>K-Play &amp; FPS-Banana 4 Alpha Testing</h5>
  <h5> Tom 4 Creating the Weapon Icons</h5>
  <h5>and much More  </h5>
  <p>&nbsp;</p>
</div>
