<?php

function steam2friend($steam_id){
    $steam_id=strtolower($steam_id);
    if (substr($steam_id,0,7)=='steam_0') {
        $tmp=explode(':',$steam_id);
        if ((count($tmp)==3) && is_numeric($tmp[1]) && is_numeric($tmp[2])){
            return bcadd((($tmp[2]*2)+$tmp[1]),'76561197960265728');
        }else return false;
        }else{
            return false;
        }
    }
    
function getMostEffectiveClasses($player){
	$scoutstats = 0; 
}  

$steamid = $_GET["steamid"];
$friendid = steam2friend($steamid);
include("inc/dbconnect.php");
mysql_query("SET CHARACTER SET 'utf8'");
$sql = "SELECT * FROM `Player` WHERE `STEAMID` LIKE '$steamid'";
$ergebnis = mysql_query($sql);
while ($adr = mysql_fetch_array($ergebnis)){
	?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" contnet=1>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Player <?=$adr['NAME']?></title>
<link rel=stylesheet type=text/css href=default.css>
</head>

<body>
<div align="center">
  <h1>Player Info </h1>
  <p>&nbsp;</p>
  <table class="main_table" style="border: 3px ridge #8D8D8D; width="598">
    <tr>
      <td height="228" style="border:none"><div align="center">
        <table border="0" cellpadding="0" cellspacing="0">
          <tr bgcolor="" valign="bottom">
            <td colspan="2" align="left" class="coltitle tlarge">Player Profile</td>
            </tr>
          <tr>
            <td class=flatrow width="112" align="left">Name:</td>
              <td class=flatrow width="180" align="left"><div align="right">
                <?=$adr['NAME']?>          
              </div></td>
            </tr>
          <tr>
            <td class=flatrow align="left">Steam ID:</td>
              <td class=flatrow align="left"><div align="right">
                <?=$adr['STEAMID']?>          
              </div></td>
            </tr>
          <tr>
            <td class=flatrow align="left">Last Connect:</td>
              <?php
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
  
 $days = floor( $adr['PLAYTIME']/60/24 );
 $hours = floor( $adr['PLAYTIME']/60-$days*24 );
 $mins  = $adr['PLAYTIME']-$hours*60-$days*24*60; 

 if( (int)$mins == 0){
	$mins = '00';
 }
 if($days == 0){
	$adr['PLAYTIME'] = $hours.'h '.$mins.'m';
	if($hours == 0){
    	$adr['PLAYTIME'] = $mins.'m';
	}
 } else {
    $adr['PLAYTIME'] = $days.'d '.$hours.'h '.$mins.'m';
 }

	  ?>
            <td class=flatrow align="left"><div align="right">
              <?=$laststr?>          
            </div></td>
            </tr>
          <tr bgcolor="">
            <td class=flatrow align="left">Total Play Time:</td>
              <td class=flatrow align="left"><div align="right">
                  <?=$adr['PLAYTIME']?>
              </div></td>
            </tr>
            <tr>
            <td class=flatrow align="left" valign="top"><b>STEAMcommunity</b>:</td>
              <td class=flatrow align="left"><div align="right">
                <?php
				
				$clnedid = ereg_replace("STEAM_","",$adr['STEAMID']);
                echo '<a href="http://steamcommunity.com/profiles/'.$friendid.'" target="_blank">View SteamID Page</a>';
				echo "<br>";
				echo '<a href="steam://friends/add/'.$friendid.'">Add to your Steam friends</a>';
				?>          
              </div></td>
            </tr>
        </table>
      </div></td>
      <td height="228" style="border:none"><div align="center">
        <table id=goerge width="84%" border="0" cellpadding="0" cellspacing="0">
            <tr bgcolor="#abccd6" valign="bottom">
              <td colspan="3" class="tlarge coltitle">Statistics Summary</td>
            </tr>
            <tr bgcolor="">
              <td width="52%">Rank:</td>
              <td colspan="2" width="48%"><div align="right">
                <?php
		$sql2 = "SELECT STEAMID FROM `Player` WHERE `POINTS` >= '".$adr['POINTS']."'";
		  $ergebnis2 = mysql_query($sql2);
		  $anzahl = mysql_num_rows($ergebnis2);
		  echo $anzahl;
		  ?>
              </div></td>
            </tr>
            <tr bgcolor="">
              <td width="52%">Points:</td>
              <td colspan="2" width="48%"><div align="right">
                <?=$adr['POINTS']?>
              </div></td>
            </tr>
            <tr bgcolor="">
              <td width="52%">Kills:</td>
              <td colspan="2" width="48%"><div align="right">
                <?=$adr['KILLS']?>
              </div></td>
            </tr>
            <tr bgcolor="">
              <td width="52%">Deaths:</td>
              <td colspan="2" width="48%"><div align="right">
                <?=$adr['Death']?>
              </div></td>
            </tr>
            <tr bgcolor="">
              <td width="52%">Kills per Death:</td>
              <td colspan="2" width="48%"><div align="right">
                <?php
				if ($adr['Death'] != 0)
				{
				echo round($adr['KILLS']/$adr['Death'], 2);
				}
				else
				{
				echo "0";
				}
		  
		  ?>
              </div></td>
            </tr>
            <tr bgcolor="">
              <td width="52%">Kills per Minute:</td>
              <td colspan="2" width="48%"><div align="right">
                <?php
				if ($adr['PLAYTIME'] != 0)
				{
				echo round($adr['KILLS']/$adr['PLAYTIME'], 2);
				}
				else
				{
				echo "0";
				}
		  		?>
              </div></td>
            </tr>
              </table>
      </div></td>
    </tr>
    <tr>
      <td width="266" height="494" style="border:none"><div align="center">
        <table class=flatrow width="61%" border="0" cellpadding="0" cellspacing="0">
          <tr valign="bottom">
            <td width="47%" align="center" class="coltitle tlarge">Weapon</td>
              <td width="15%" align="center" class="coltitle tlarge">Kills</td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/axe.png" width="58" height="33" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Axe']?></td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/bnsw.png" width="65" height="27" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Bnsw']?></td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/bt.png" width="65" height="28" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Bt']?></td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/bttl.png" width="57" height="29" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Bttl']?></td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/cg.png" width="60" height="21" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Cg']?></td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/fsts.png" width="62" height="28" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Fsts']?></td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/ft.png" width="66" height="28" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Ft']?></td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/gl.png" width="69" height="32" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Gl']?></td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/kn.png" width="78" height="17" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Kn']?></td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/mctte.png" width="70" height="21" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Mctte']?></td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/mgn.png" width="52" height="32" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Mgn']?></td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/ndl.png" width="71" height="26" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Ndl']?></td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/pistl.png" width="34" height="31" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Pistl']?></td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/rkt.png" width="54" height="17" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Rkt']?></td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/sg.png" width="70" height="25" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Sg']?></td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/sky.png" width="49" height="31" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Sky']?></td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/smg.png" width="53" height="34" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Smg']?></td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/spr.png" width="31" height="31" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Spr']?></td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/stgn.png" width="77" height="22" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Stgn']?></td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/wrnc.png" width="58" height="34" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Wrnc']?></td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/sntry.png" width="49" height="50" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Sntry']?></td>
            </tr>
          <tr>
            <td align="center" bgcolor="#000000"><img src="images/weaponicons/shvl.png" width="67" height="32" /></td>
              <td align="right" bgcolor=""><?=$adr['KW_Shvl']?></td>
            </tr>
        </table>
      </div></td>
      <td valign=top width="320" style="border:none"><div align="center">
          <table class=flatrow width="100%" border="0" cellpadding="0" cellspacing="0">
            <tr bgcolor="#abccd6" valign="bottom">
              <td colspan="2" align="left" class="coltitle tlarge">Action</td>
		    </tr>
            <tr>
              <td width="72%" bgcolor="">Kill Assist</td>
            <td width="28%" align="right" bgcolor=""><?=$adr['KillAssist']?></td>
            </tr>
            <tr>
              <td bgcolor="">Kill Assist - Medic</td>
            <td align="right" bgcolor=""><?=$adr['KillAssistMedic']?></td>
            </tr>
            <tr>
              <td bgcolor="">Built Object - Sentrygun</td>
            <td align="right" bgcolor=""><?=$adr['BuildSentrygun']?></td>
            </tr>
            <tr>
              <td bgcolor="">Built Object - Dispenser</td>
            <td align="right" bgcolor=""><?=$adr['BuildDispenser']?></td>
            </tr>
            <tr>
              <td bgcolor="">Headshot Kill</td>
            <td align="right" bgcolor=""><?=$adr['HeadshotKill']?></td>
            </tr>
            <tr>
              <td bgcolor="">Killed Object - Sentrygun</td>
            <td align="right" bgcolor=""><?=$adr['KOSentrygun']?></td>
            </tr>
            <tr>
              <td bgcolor="">Domination</td>
            <td align="right" bgcolor=""><?=$adr['Domination']?></td>
            </tr>
            <tr>
              <td bgcolor="">Ubercharge</td>
            <td align="right" bgcolor=""><?=$adr['Overcharge']?></td>
            </tr>
            <tr>
              <td bgcolor="">Killed Object - Attachment Sapper</td>
            <td align="right" bgcolor=""><?=$adr['KOSapper']?></td>
            </tr>
            <tr>
              <td bgcolor="">Built Object - Teleporter Entrance</td>
            <td align="right" bgcolor=""><?=$adr['BOTeleporterentrace']?></td>
            </tr>
            <tr>
              <td bgcolor="">Killed Object - Dispenser</td>
            <td align="right" bgcolor=""><?=$adr['KODispenser']?></td>
            </tr>
            <tr>
              <td bgcolor="">Built Object - Teleporter Exit</td>
            <td align="right" bgcolor=""><?=$adr['BOTeleporterExit']?></td>
            </tr>
            <tr>
              <td bgcolor="">Capture Blocked</td>
            <td align="right" bgcolor=""><?=$adr['CPBlocked']?></td>
            </tr>
            <tr>
              <td bgcolor="">Point Captured</td>
            <td align="right" bgcolor=""><?=$adr['CPCaptured']?></td>
             </tr>
            <tr>
              <td bgcolor="">File Captured</td>
            <td align="right" bgcolor=""><?=$adr['FileCaptured']?></td>
             </tr>
            <tr>
              <td bgcolor="">AD Captured</td>
            <td align="right" bgcolor=""><?=$adr['ADCaptured']?></td>
            </tr>
            <tr>
              <td bgcolor="">Killed Object - Teleporter Exit</td>
            <td align="right" bgcolor=""><?=$adr['KOTeleporterExit']?></td>
            </tr>
            <tr>
              <td bgcolor="">Killed Object - Teleporter Entrance</td>
            <td align="right" bgcolor=""><?=$adr['KOTeleporterEntrace']?></td>
            </tr>
            <tr>
              <td bgcolor="">Revenge</td>
            <td align="right" bgcolor=""><?=$adr['Revenge']?></td>
            </tr>
             <tr>
              <td height="25" bgcolor="">Built Object - Attachment Sapper</td>
            <td align="right" bgcolor=""><?=$adr['BOSapper']?></td>
            </tr>
            </table>
      </div></td>
    </tr>
  </table>
  <p>&nbsp;</p>
</div>
</body>
</html>
<?php
}
?>