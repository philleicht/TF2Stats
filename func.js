	function showhideStats(playerSteamID)
 	{
 		
 		PlayerStatRowID = "statrow"+playerSteamID
 		o = document.getElementById(PlayerStatRowID).style;
 		
 		if (navigator.appName.indexOf("Explorer") > -1) {
 			if(o.display != "none"){
 				o.display = "none";
 			}
 			else {
 				o.display = "inline";	
 				ReloadPlayerStats(playerSteamID);
 			}
 		} else {
 			if(o.display != "none"){
 				o.display = "none";
 			}
 			else {
 				o.display = "table-row";	
 				ReloadPlayerStats(playerSteamID);
 			}
 		}
 	}
 	
 	
 	var http_request = false;
	var contentDivID = "";

    function ReloadPlayerStats(steamID) {

        http_request = false;
		var loadurl = "player_mini_stats.php?sid="+steamID;
		contentDivID = "statdiv"+steamID;

        if (window.XMLHttpRequest) { // Mozilla, Safari,...
            http_request = new XMLHttpRequest();
            if (http_request.overrideMimeType) {
                http_request.overrideMimeType('text/xml');
                // zu dieser Zeile siehe weiter unten
            }
        } else if (window.ActiveXObject) { // IE
            try {
                http_request = new ActiveXObject("Msxml2.XMLHTTP");
            } catch (e) {
                try {
                    http_request = new ActiveXObject("Microsoft.XMLHTTP");
                } catch (e) {}
            }
        }

        if (!http_request) {
            return false;
        }

        http_request.onreadystatechange = writeContent;
        http_request.open('GET', loadurl, true);
        http_request.send(null);

    }

    function writeContent() {
 
    	if (http_request.readyState == 4) {
              var answer = http_request.responseText;
        	  if(document.getElementById(contentDivID).innerHTML != answer){
                document.getElementById(contentDivID).innerHTML = answer;
              }
              else{
                document.getElementById(contentDivID).innerHTML = "Nothing in our Database :-(";
              }
        }

    }
