<?


function getPlayerSince($steamFriendID){

  $url = "http://steamcommunity.com/profiles/".$steamFriendID;
  $source = @file_get_contents($url) or die('Could not access file:'. $url);
  $pattern = '@<div class="statsItemName">Member since:</div>\s*([A-Za-z]*)\s+([0-9]+)\,\s*([0-9]+).*@is';
  if(preg_match($pattern, $source, $result)) {
    # [1] => September
    # [2] => 8
    # [3] => 2007
    # $result[0] = <div class="statsItemName">Member since:</div>September 12, 2003</div>
    //return $result[2].".".getMonthByName($result[1]).".".$result[4];
  	unset($result[0]);
  	$result[2] = str_pad($result[2], 2, "0", STR_PAD_LEFT);
  	return $result[2].".".getMonthByName($result[1]).".".$result[3];
  }else{
  	return "N/A";
  }

}

function getMonthByName($month){

$monthnames = array("null", 
					"01" => "January", 
					"02" => "February", 
					"03" => "March", 
					"04" => "April", 
					"05" => "May", 
					"06" => "June",
					"07" => "July", 
					"08" => "August", 
					"09" => "September", 
					"10" => "October", 
					"11" => "November", 
					"12" => "December");
 
return $monthnumber = array_search($month,$monthnames);
}

function getPlayerAvatar($steamFriendID){

  $url = "http://steamcommunity.com/profiles/".$steamFriendID;
  $source = @file_get_contents($url) or die('Could not access file:'. $url);
  $pattern = '@<div class="avatarFull"><img src="(.*?)"@is';
  if(preg_match($pattern, $source, $result)) {
    # $result[1] = url of the players picture
    # $result[0] = <div class="avatarFull"><img src="$picture_url"
    return $result[1];
  }else{
  	return "images/avatar_placeholder.jpg";
  }
}

function getPlayerSteamRating($steamFriendID){
  
  $url = "http://steamcommunity.com/profiles/".$steamFriendID;
  $source = @file_get_contents($url) or die('Could not access file:'. $url);
  $pattern = '@<div class="statsItemName">Steam Rating:</div>\s+(.+?) \- ([^\t]+)@is';
  //$pattern_2_words = '@<div class="statsItemName">Steam Rating:</div>\s*([0-9]+\.?[0-9]+)\s+-\s+([A-Za-z0-9]*\s+[A-Za-z0-9]+).*@is';
  //$pattern_2_words_exlamationmarks = '@<div class="statsItemName">Steam Rating:</div>\s*([0-9]+\.?[0-9]+)\s+-\s+([A-Za-z0-9]*.?\s+[A-Za-z0-9]+.?).*@is';
  if(preg_match($pattern, $source, $result)) {

    # [1] => 9.6 (Number)
    # [2] => Still not 10 (Title)
   
    return $result[1]." - ".$result[2];

  }else{

  	return "N/A";

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

$steamid = $_GET["sid"];
$friendid = steam2friend($steamid);
include("inc/dbconnect.php");
mysql_query("SET CHARACTER SET 'utf8'");
$sql = "SELECT KILLS, Death, PLAYTIME, POINTS FROM `Player` WHERE `STEAMID` LIKE '$steamid'";
$ergebnis = mysql_query($sql);
while ($player = mysql_fetch_array($ergebnis)){
?>

	<table cellpadding="0" cellspacing="0" border="0" width="100%">
		
		<tr>
			<td rowspan="4"><img src="<?=getPlayerAvatar($friendid)?>" width="50%" height="50%" border="0"></td>
			<td>Kills: <?=$player['KILLS']?></td>
			<td>Points per Minute: <?=($player['PLAYTIME'] != 0) ? round($player['POINTS']/$player['PLAYTIME'], 2) : '0' ?></td>
		</tr>
		<tr>
			<td>Deaths: <?=$player['Death']?></td>
			<td>Kills per Minute: <?=($player['PLAYTIME'] != 0) ? round($player['KILLS']/$player['PLAYTIME'], 2) : '0' ?></td>
		</tr>
		<tr>
			<td>Steam Member since: <?=getPlayerSince($friendid)?></td>
			<td>Steam Rating: <?=getPlayerSteamRating($friendid)?></td>
		</tr>
		<tr>
			<td><a href="http://steamcommunity.com/profiles/<?=$friendid?>" target="_blank">View SteamID Page</a></td>
			<td><a href="steam://friends/add/<?=$friendid?>">Add to your Steam friends</a></td>
		</tr>
	</table>
<?
}
?>
