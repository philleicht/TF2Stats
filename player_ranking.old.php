<?php
include("inc/dbconnect.php");
$page = $_GET["page"];
$ppp = $_GET["ppp"];
$playername = $_GET['playername'];
if ($page == "")
	{
	$page = 1;
	}
	if ($ppp == "")
	{
	$ppp = 100;
	}
	$fromplayer = ($page * $ppp) - $ppp;
	$toplayer = $page * $ppp;
	  $nextpage = $page + 1;
	  $prevpage = $page - 1;
	  
	  
	  
$foundPlayers = array();	  
	  
	mysql_query("SET CHARACTER SET 'utf8'");
	
$sql = 'SELECT * FROM `Player`';
if ($playername)
{
  $sql .= ' WHERE `NAME` LIKE \'%'.$playername.'%\'';
}
$sql .= ' ORDER BY `POINTS` DESC LIMIT '.$fromplayer.','.$ppp.' ';

$ergebnis = mysql_query($sql);
while ($adr = mysql_fetch_array($ergebnis)){
         
                     $sql = 'SELECT COUNT(*) as rank FROM Player WHERE POINTS >= '.$adr['POINTS'];
            $rank = mysql_fetch_row( mysql_query( $sql ) );
         
         
         $hours = floor( $adr['PLAYTIME']/60 );
         $mins  = $adr['PLAYTIME']-$hours*60;
         if( (int)$mins == 0)
         {
            $mins = '00';
         }
           
         $foundPlayers[] = array(
            'points' => $adr['POINTS'],
            'lastOnTime' => $adr['LASTONTIME'],
            'steamId' => $adr['STEAMID'],
             'name' => $adr['NAME'],
             'playtime' => $hours.':'.$mins,
             'rank' => $rank[0],
            );
}

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>TF2 Player Stats</title>
<link rel=stylesheet type=text/css href=default.css>
</head>

<body>
<div align="center">
<h1>Player search</h1>
  <form method="get" action="#">
    <input type="text" value="<?php echo $playername; ?>" name="playername" />
    <input type="submit" value="Search" name="searchbutton" />
  </form>
</div>


<div align="center">
  <h1>Player Ranking  </h1>
  <p>
 
  </p>
  <table class=flatrow width="200">
    <tr>
      <td><?php
	  if ($page > 1)
	  {
	  echo '<a href="?page='.$prevpage.'&amp;ppp=100&playername='.$playername.'">&lt;&lt;</a>';
	  }
	  ?></td>
      <td><?php echo $fromplayer+1 ; ?></td>
      <td>-</td>
      <td><?php echo count($foundPlayers)+$fromplayer ; ?></td>
      <td>
      <?php 
        if (count($foundPlayers) == 100)
        {
         echo '<a href="?page='.$nextpage.'&amp;ppp=100&playername='.$playername.'">&gt;&gt;</a>';
        }
       ?>
    </td>
    </tr>
  </table>
<br \>
  <table class=flatrow border="1">
    <tr>
      <td>Rank</td>
      <td>Name</td>
      <td>Points</td>
      <td>Playtime</td>
      <td>Last Play time </td>
    </tr>
	<?php

foreach ($foundPlayers as $player){

           $timestamp = $player['lastOnTime'];
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
                <td>'.$player[ 'rank' ].'</td>
                <td><a href="player.php?steamid='.$player['steamId'].'">'.$player['name'].'</a></td>
                <td>'.$player['points'].'</td>
                <td>'.$player['playtime'].' hrs'.'</td>
                <td>'.$laststr.'</td>
              </tr>
            ';
}
	?>
  </table>
<br \>
  <table class=flatrow width="200">
    <tr>
      <td><?php
	  if ($page > 1)
	  {
	  echo '<a href="?page='.$prevpage.'&amp;ppp=100&playername='.$playername.'">&lt;&lt;</a>';
	  }
	  ?></td>
      <td><?php echo $fromplayer+1 ; ?></td>
      <td>-</td>
      <td><?php echo count($foundPlayers)+$fromplayer ; ?></td>
      <td>
	  <?php 
        if (count($foundPlayers) == 100)
        {
         echo '<a href="?page='.$nextpage.'&amp;ppp=100&playername='.$playername.'">&gt;&gt;</a>';
        }
    ?>
    </td>
    </tr>
  </table>
  <p>&nbsp;</p>
</div>
<blockquote>&nbsp;	</blockquote>
</body>
</html>
