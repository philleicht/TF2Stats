<?php
include("inc/dbconnect.php");
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Map Ranking</title>
<link href=default.css rel=stylesheet type=text/css>
</head>

<body>
<h1 align="center">Map Stats</h1>
<div align="center">
  <table class=flatrow border="1">
    <tr>
      <td>Rank</td>
      <td>Name</td>
      <td>Playtime</td>
      <td>Last Played time </td>
    </tr>
    <?php
mysql_query("SET CHARACTER SET 'utf8'");
	
$sql = 'SELECT * FROM `Map` ORDER BY `PLAYTIME` DESC';
$ergebnis = mysql_query($sql);
$i = 1;
while ($adr = mysql_fetch_array($ergebnis)){
$timestamp = $adr['LASTONTIME'];
$datum = date("d.m.Y",$timestamp);
$uhrzeit = date("H:i",$timestamp);
$laststr = $datum." - ".$uhrzeit;

echo '
   <tr>
   <td>'.$i.'</td>
   <td>'.$adr['NAME'].'</td>
   <td>'.$adr['PLAYTIME'].' min'.'</td>
   <td>'.$laststr.'</td>
   </tr>
	';
	$i = $i + 1;
}
	?>
  </table>
</div>
<p align="center">&nbsp;</p>
</body>
</html>
