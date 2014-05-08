<?php
include("inc/dbconnect.php");
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>TF2 Player Stats</title>
<link href=default.css rel=stylesheet type=text/css>
</head>

<body>
<div align="center">
  <h1>Top 10 </h1>
  <p>
 
  </p>
  <table border="1">
    <tr>
      <td>Rank</td>
      <td>Name</td>
      <td>Points</td>
      <td>Playtime</td>
      <td>Last Play time </td>
    </tr>
	<?php
	mysql_query("SET CHARACTER SET 'utf8'");
	
$sql = 'SELECT * FROM `Player` ORDER BY `POINTS` DESC LIMIT 0,10 ';
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
      <td>'.$i.'</td>
      <td><a href="player.php?steamid='.$adr['STEAMID'].'">'.$adr['NAME'].'</a></td>
      <td>'.$adr['POINTS'].'</td>
      <td>'.$adr['PLAYTIME'].' min'.'</td>
      <td>'.$laststr.'</td>
    </tr>
	';
	$i = $i + 1;
}
	?>
  </table>
  <p>&nbsp;</p>
</div>
<blockquote>&nbsp;	</blockquote>
</body>
</html>
