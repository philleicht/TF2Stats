<?php
/*
function getSteamNameFromProfile($steamFriendID, $steamNameFromDB){
  $url = "http://steamcommunity.com/profiles/".$steamFriendID;
  $source = @file_get_contents($url) or die('Could not access file:'. $url);
  $pattern = '@<h2>SteamID</h2>\s*<h1>([^<]+)@is';
  if(preg_match($pattern, $source, $result)) {
    # $result[0] => <h2>SteamID</h2>
	#	<h1>m##n
    # $result[1] => m##n
  	return $result[1];
  }else{
  	return $steamNameFromDB;
  }	
}

function steam2friend($steam_id){
    $steam_id=strtolower($steam_id);
    if (substr($steam_id,0,7)=='steam_0') {
        $tmp=explode(':',$steam_id);
        if ((count($tmp)==3) && is_numeric($tmp[1]) && is_numeric($tmp[2])){
            return bcadd((($tmp[2]*2)+$tmp[1]),'76561197960265728');
        }else return false;
        
        }
        else{
            return false;
        }
}
*/


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
	  
	$maxplayercount = mysql_num_rows( mysql_query( "SELECT name FROM `Player`" ) );
	$lastpage = floor($maxplayercount / $ppp);	  
	  
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
         
         $days = floor( $adr['PLAYTIME']/60/24 );
         $hours = floor( $adr['PLAYTIME']/60-$days*24 );
         $mins  = $adr['PLAYTIME']-$hours*60-$days*24*60;
         if( (int)$mins == 0)
         {
            $mins = '00';
         }
	 
		if($days == 0){
	    	$playtime = $hours.'h '.$mins.'m';
	    	if($hours == 0){
            	$playtime = $mins.'m';
			}
		} 
		else {
            $playtime = $days.'d '.$hours.'h '.$mins.'m';
		}
	          
  
         $foundPlayers[] = array(
            'points' => $adr['POINTS'],
            'lastOnTime' => $adr['LASTONTIME'],
            'steamId' => $adr['STEAMID'],
             'name' => $adr['NAME'],
             'playtime' => $playtime,
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
<script language='JavaScript' type='text/javascript' src='func.js'></script>
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
  <table class=flatrow width="400">
    <tr>
      <td width="40%"><?
	  if ($page > 1)
	  {
	  	echo '<a href="?page='.$prevpage.'&amp;ppp=100&playername='.$playername.'">&lt; previous 100</a>';
	  }
	  ?>
	  </td>
	  <td width="20%">
	  <? echo $page." / ".$lastpage; ?> 
      </td>
      <td width="40%">
      <?
      if (count($foundPlayers) == 100)
      {
      	echo '<a href="?page='.$nextpage.'&amp;ppp=100&playername='.$playername.'">next 100 &gt;</a>';
      }
      ?>
      </td>
    </tr>
  </table>
<br \>
  <table class=flatrow border="1" width="600">
    <tr>
      <td>Rank</td>
      <td>Name</td>
      <td>Points</td>
      <td>Playtime</td>
      <td>Last Play time </td>
    </tr>
	<?php
	$rowcount = 1;
	
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
              	<tr onClick="showhideStats(\''.$player['steamId'].'\')">
                	<td>'.$player['rank'].'</td>
                	<td><a href="player.php?steamid='.$player['steamId'].'">'.$player['name'].'</a></td>
                	<td>'.$player['points'].'</td>
                	<td>'.$player['playtime'].'</td>
                	<td>'.$laststr.'</td>
              	</tr>
				<tr id="statrow'.$player['steamId'].'" style="display: none">
					<td colspan="5" align="center">
							<div id="statdiv'.$player['steamId'].'">
									<img src="images/loading.gif">
							</div>				
					</td>
				</tr>
			';
			$rowcount++;			  
}
	?>
			
  </table>
<br \>
  <table class=flatrow width="400">
    <tr>
      <td width="40%"><?
	  if ($page > 1)
	  {
	  	echo '<a href="?page='.$prevpage.'&amp;ppp=100&playername='.$playername.'">&lt; previous 100</a>';
	  }
	  ?>
	  </td>
	  <td width="20%">
	  <? echo $page." / ".$lastpage; ?> 
      </td>
      <td width="40%">
      <?
      if (count($foundPlayers) == 100)
      {
      	echo '<a href="?page='.$nextpage.'&amp;ppp=100&playername='.$playername.'">next 100 &gt;</a>';
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
