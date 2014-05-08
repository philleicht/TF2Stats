#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.5.0"
#define MAX_LINE_WIDTH 60

new mapisset
new classfunctionloaded = 0

new Handle:db = INVALID_HANDLE;			/** Database connection */

new Handle:diepoints = INVALID_HANDLE;

new Handle:scattergunpoints = INVALID_HANDLE;
new Handle:batpoints = INVALID_HANDLE;
new Handle:pistolpoints = INVALID_HANDLE;

new Handle:tf_projectile_rocketpoints = INVALID_HANDLE;
new Handle:shotgunpoints = INVALID_HANDLE;
new Handle:shovelpoints = INVALID_HANDLE;

new Handle:flamethrowerpoints = INVALID_HANDLE;
new Handle:fireaxepoints = INVALID_HANDLE;

new Handle:tf_projectile_pipepoints = INVALID_HANDLE;

new Handle:tf_projectile_pipe_remotepoints = INVALID_HANDLE;
new Handle:bottlepoints = INVALID_HANDLE;

new Handle:minigunpoints = INVALID_HANDLE;
new Handle:fistspoints = INVALID_HANDLE;

new Handle:obj_sentrygunpoints = INVALID_HANDLE;
new Handle:wrenchpoints = INVALID_HANDLE;

new Handle:bonesawpoints = INVALID_HANDLE;
new Handle:syringegun_medicpoints = INVALID_HANDLE;

new Handle:clubpoints = INVALID_HANDLE;
new Handle:smgpoints = INVALID_HANDLE;
new Handle:sniperriflepoints = INVALID_HANDLE;

new Handle:revolverpoints = INVALID_HANDLE;
new Handle:knifepoints = INVALID_HANDLE;

new Handle:killsapperpoints = INVALID_HANDLE;
new Handle:killteleinpoints = INVALID_HANDLE;
new Handle:killteleoutpoints = INVALID_HANDLE;
new Handle:killdisppoints = INVALID_HANDLE;
new Handle:killsentrypoints = INVALID_HANDLE;
new Handle:killasipoints = INVALID_HANDLE;
new Handle:killasimedipoints = INVALID_HANDLE;
new Handle:overchargepoints = INVALID_HANDLE;

new Handle:showrankonroundend = INVALID_HANDLE;
new Handle:removeoldplayers = INVALID_HANDLE;
new Handle:removeoldplayersdays = INVALID_HANDLE;

new Handle:removeoldmaps = INVALID_HANDLE;
new Handle:removeoldmapssdays = INVALID_HANDLE;

new Handle:Capturepoints = INVALID_HANDLE;
new Handle:FileCapturepoints = INVALID_HANDLE;
new Handle:Captureblockpoints = INVALID_HANDLE;

new Handle:ubersawpoints = INVALID_HANDLE;
new Handle:flaregunpoints = INVALID_HANDLE;
new Handle:axtinguisherpoints = INVALID_HANDLE;
new Handle:taunt_pyropoints = INVALID_HANDLE;

new sqllite = 0

new String:topsteamIda[20];
new String:topsteamIdb[20];
new String:topsteamIdc[20];
new String:topsteamIdd[20];
new String:topsteamIde[20];
new String:topsteamIdf[20];
new String:topsteamIdg[20];
new String:topsteamIdh[20];
new String:topsteamIdi[20];
new String:topsteamIdj[20];


new TF_classoffsets, maxents, ResourceEnt, maxplayers;

public Plugin:myinfo = 
{
	name = "TF2 Stats",
	author = "R-Hehl",
	description = "TF2 Player Stats",
	version = PLUGIN_VERSION,
	url = "http://compactaim.de"
};
public OnPluginStart()
{
	LoadTranslations("tf2stats.phrases");
	openDatabaseConnection()
	createdb()
	convarcreating()
	CreateConVar("sm_tf2_stats_version", PLUGIN_VERSION, "TF2 Player Stats", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	TF_classoffsets = FindSendPropOffs("CTFPlayerResource", "m_iPlayerClass");
	starteventhooking()
	RegConsoleCmd("say", Command_Say);
	RegAdminCmd("rank_admin", Menu_adm, ADMFLAG_GENERIC, "Open Rank Admin Menu");
	initonlineplayers()
	CreateTimer(60.0,sec60evnt,INVALID_HANDLE,TIMER_REPEAT);
	
}
public Action:sec60evnt(Handle:timer, Handle:hndl)
{
	playerstimeupdateondb()
	if (sqllite != 1)
{
	refreshmaptime()
}
	}
public refreshmaptime()
{
	new String:name[MAX_LINE_WIDTH];
	GetCurrentMap(name,MAX_LINE_WIDTH);
	new time = GetTime()
	new String:query[512];
	Format(query, sizeof(query), "UPDATE Map SET PLAYTIME = PLAYTIME + 1, LASTONTIME = %i WHERE NAME LIKE '%s'",time ,name);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
}
public playerstimeupdateondb()
{
	new String:clsteamId[MAX_LINE_WIDTH];
	new maxclients = GetMaxClients()
	new time = GetTime()
	for(new i=1; i <= maxclients; i++)
	{
	if(IsClientInGame(i))
	{
	GetClientAuthString(i, clsteamId, sizeof(clsteamId));
	new String:query[512];
	Format(query, sizeof(query), "UPDATE Player SET PLAYTIME = PLAYTIME + 1, LASTONTIME = %i WHERE STEAMID = '%s'",time ,clsteamId);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	}
}
openDatabaseConnection()
{
	if (SQL_CheckConfig("tf2stats"))
	{
	new String:error[255]
	db = SQL_Connect("tf2stats",true,error, sizeof(error))
	if (db == INVALID_HANDLE)
	{
	PrintToServer("Failed to connect: %s", error)
	}
	else 
	{
	LogMessage("DatabaseInit (CONNECTED) with db config");
	decl String:query[255];
	Format(query, sizeof(query), "SET NAMES 'utf8'");
		if (!SQL_FastQuery(db, query))
		{
		LogError("Can't select character set (%s)", query);
		}
	}
	} 
	else 
	{
	new String:error[255]
	sqllite = 1
	db = SQL_ConnectEx(SQL_GetDriver("sqlite"), "", "", "", "tf2stats", error, sizeof(error), true, 0);	
	if (db == INVALID_HANDLE)
	{
	PrintToServer("Failed to connect: %s", error)
	}
	else 
	{
	LogMessage("DatabaseInit SQLLITE (CONNECTED)");
	}
	}
	
}
createdb()
{
if (sqllite != 1)
{
createdbplayer()
createdbmap()
}
else
{
createdbplayersqllite()
}
}

createdbplayer()
{
	new len = 0;
	decl String:query[2048];
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `Player`");
	len += Format(query[len], sizeof(query)-len, " (`STEAMID` varchar(25) NOT NULL, `NAME` varchar(30) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,");
	len += Format(query[len], sizeof(query)-len, "  `POINTS` int(25) NOT NULL,`PLAYTIME` int(25) NOT NULL, `LASTONTIME` int(25) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KILLS` int(11) NOT NULL , `Death` int(11) NOT NULL , `KillAssist` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KillAssistMedic` int(11) NOT NULL , `BuildSentrygun` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `BuildDispenser` int(11) NOT NULL , `HeadshotKill` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KOSentrygun` int(11) NOT NULL , `Domination` int(11) NOT NULL , `Overcharge` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KOSapper` int(11) NOT NULL , `BOTeleporterentrace` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KODispenser` int(11) NOT NULL , `BOTeleporterExit` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `CPBlocked` int(11) NOT NULL , `CPCaptured` int(11) NOT NULL , `FileCaptured` int(11) NOT NULL , `ADCaptured` int(11) NOT NULL , `KOTeleporterExit` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KOTeleporterEntrace` int(11) NOT NULL , `BOSapper` int(11) NOT NULL , `Revenge` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KW_Axe` int(11) NOT NULL , `KW_Bnsw` int(11) NOT NULL , `KW_Bt` int(11) NOT NULL , `KW_Bttl` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KW_Cg` int(11) NOT NULL , `KW_Fsts` int(11) NOT NULL , `KW_Ft` int(11) NOT NULL , `KW_Gl` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KW_Kn` int(11) NOT NULL , `KW_Mctte` int(11) NOT NULL , `KW_Mgn` int(11) NOT NULL , `KW_Ndl` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KW_Pistl` int(11) NOT NULL , `KW_Rkt` int(11) NOT NULL , `KW_Sg` int(11) NOT NULL , `KW_Sky` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KW_Smg` int(11) NOT NULL , `KW_Spr` int(11) NOT NULL , `KW_Stgn` int(11) NOT NULL , `KW_Wrnc` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KW_Sntry` int(11) NOT NULL , `KW_Shvl` int(11) NOT NULL , `KW_Ubersaw` int(11) NOT NULL , `KW_Flaregun` int(11) NOT NULL ,")
	len += Format(query[len], sizeof(query)-len, " `KW_Axtinguisher` int(11) NOT NULL , `KW_taunt_pyro` int(11) NOT NULL , PRIMARY KEY (`STEAMID`));");
	SQL_FastQuery(db, query);
}
createdbplayersqllite()
{
	new len = 0;
	decl String:query[2048];
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `Player`");
	len += Format(query[len], sizeof(query)-len, " (`STEAMID` TEXT, `NAME` TEXT,");
	len += Format(query[len], sizeof(query)-len, "  `POINTS` INTEGER,`PLAYTIME` INTEGER, `LASTONTIME` INTEGER,");
	len += Format(query[len], sizeof(query)-len, " `KILLS` INTEGER, `Death` INTEGER, `KillAssist` INTEGER,");
	len += Format(query[len], sizeof(query)-len, " `KillAssistMedic` INTEGER, `BuildSentrygun` INTEGER,");
	len += Format(query[len], sizeof(query)-len, " `BuildDispenser` INTEGER, `HeadshotKill` INTEGER,");
	len += Format(query[len], sizeof(query)-len, " `KOSentrygun` INTEGER, `Domination` INTEGER, `Overcharge` INTEGER,");
	len += Format(query[len], sizeof(query)-len, " `KOSapper` INTEGER, `BOTeleporterentrace` INTEGER,");
	len += Format(query[len], sizeof(query)-len, " `KODispenser` INTEGER, `BOTeleporterExit` INTEGER,");
	len += Format(query[len], sizeof(query)-len, " `CPBlocked` INTEGER, `CPCaptured` INTEGER, `FileCaptured` INTEGER, `ADCaptured` INTEGER, `KOTeleporterExit` INTEGER,");
	len += Format(query[len], sizeof(query)-len, " `KOTeleporterEntrace` INTEGER, `BOSapper` INTEGER, `Revenge` INTEGER,");
	len += Format(query[len], sizeof(query)-len, " `KW_Axe` INTEGER, `KW_Bnsw` INTEGER, `KW_Bt` INTEGER, `KW_Bttl` INTEGER,");
	len += Format(query[len], sizeof(query)-len, " `KW_Cg` INTEGER, `KW_Fsts` INTEGER, `KW_Ft` INTEGER, `KW_Gl` INTEGER,");
	len += Format(query[len], sizeof(query)-len, " `KW_Kn` INTEGER, `KW_Mctte` INTEGER, `KW_Mgn` INTEGER, `KW_Ndl`,");
	len += Format(query[len], sizeof(query)-len, " `KW_Pistl` INTEGER, `KW_Rkt`, `KW_Sg`, `KW_Sky`,");
	len += Format(query[len], sizeof(query)-len, " `KW_Smg` INTEGER, `KW_Spr`, `KW_Stgn`, `KW_Wrnc`,");
	len += Format(query[len], sizeof(query)-len, " `KW_Sntry` INTEGER, `KW_Shvl` INTEGER, `KW_Ubersaw` INTEGER, `KW_Flaregun` INTEGER, `KW_Axtinguisher` INTEGER, `KW_taunt_pyro` INTEGER);");
	SQL_FastQuery(db, query);
}
createdbmap()
{
	new len = 0;
	decl String:query[2048];
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `Map`");
	len += Format(query[len], sizeof(query)-len, " (`NAME` varchar(30) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,");
	len += Format(query[len], sizeof(query)-len, "  `POINTS` int(25) NOT NULL,`PLAYTIME` int(25) NOT NULL, `LASTONTIME` int(25) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KILLS` int(11) NOT NULL , `Death` int(11) NOT NULL , `KillAssist` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KillAssistMedic` int(11) NOT NULL , `BuildSentrygun` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `BuildDispenser` int(11) NOT NULL , `HeadshotKill` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KOSentrygun` int(11) NOT NULL , `Domination` int(11) NOT NULL , `Overcharge` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KOSapper` int(11) NOT NULL , `BOTeleporterentrace` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KODispenser` int(11) NOT NULL , `BOTeleporterExit` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `CPBlocked` int(11) NOT NULL , `Captured` int(11) NOT NULL , `KOTeleporterExit` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KOTeleporterEntrace` int(11) NOT NULL , `BOSapper` int(11) NOT NULL , `Revenge` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KW_Axe` int(11) NOT NULL , `KW_Bnsw` int(11) NOT NULL , `KW_Bt` int(11) NOT NULL , `KW_Bttl` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KW_Cg` int(11) NOT NULL , `KW_Fsts` int(11) NOT NULL , `KW_Ft` int(11) NOT NULL , `KW_Gl` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KW_Kn` int(11) NOT NULL , `KW_Mctte` int(11) NOT NULL , `KW_Mgn` int(11) NOT NULL , `KW_Ndl` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KW_Pistl` int(11) NOT NULL , `KW_Rkt` int(11) NOT NULL , `KW_Sg` int(11) NOT NULL , `KW_Sky` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KW_Smg` int(11) NOT NULL , `KW_Spr` int(11) NOT NULL , `KW_Stgn` int(11) NOT NULL , `KW_Wrnc` int(11) NOT NULL ,");
	len += Format(query[len], sizeof(query)-len, " `KW_Sntry` int(11) NOT NULL , `KW_Shvl` int(11) NOT NULL , PRIMARY KEY (`NAME`));");
	SQL_FastQuery(db, query);
}
public Action:OnClientPreAdminCheck(client)
{
	InitializeClientonDB(client);
	updateplayername(client)
}
public InitializeClientonDB(client)
{
new String:name[MAX_LINE_WIDTH];
new String:steamId[MAX_LINE_WIDTH];
new String:buffer[2024];
GetClientName( client, name, sizeof(name) );
ReplaceString(name, sizeof(name), "'", "");
ReplaceString(name, sizeof(name), "<?", "");
ReplaceString(name, sizeof(name), "?>", "");
ReplaceString(name, sizeof(name), "\"", "");
ReplaceString(name, sizeof(name), "<?PHP", "");
ReplaceString(name, sizeof(name), "<?php", "");
GetClientAuthString(client, steamId, sizeof(steamId));
new String:buffer1[2048];
Format(buffer1, sizeof(buffer1), "SELECT NAME FROM Player WHERE STEAMID LIKE '%s'", steamId);
new Handle:queryBase = SQL_Query(db, buffer1)
if(!SQL_FetchRow(queryBase))
{
	Format(buffer, sizeof(buffer), "INSERT INTO Player (STEAMID, NAME, POINTS,PLAYTIME, LASTONTIME, KILLS, Death, KillAssist, KillAssistMedic, BuildSentrygun, BuildDispenser, HeadshotKill, KOSentrygun, Domination, Overcharge, KOSapper, BOTeleporterentrace, KODispenser, BOTeleporterExit, CPBlocked, CPCaptured, FileCaptured, ADCaptured, KOTeleporterExit, KOTeleporterEntrace, BOSapper, Revenge, KW_Axe, KW_Bnsw, KW_Bt, KW_Bttl, KW_Cg, KW_Fsts, KW_Ft, KW_Gl, KW_Kn, KW_Mctte, KW_Mgn, KW_Ndl, KW_Pistl, KW_Rkt, KW_Sg, KW_Sky, KW_Smg, KW_Spr, KW_Stgn, KW_Wrnc, KW_Sntry, KW_Shvl) VALUES ('%s','%s',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);",steamId ,name)
	SQL_TQuery(db, SQLErrorCheckCallback, buffer);
}
}
public SQLErrorCheckCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(!StrEqual("", error))
	{
	LogMessage("Last Connect SQL Error: %s", error);
	}
}
public convarcreating()
{
	diepoints = CreateConVar("rank_diepoints","3","Set the points a player lose on Death");
	scattergunpoints = CreateConVar("rank_scattergunpoints","4","Set the points the attacker get");
	batpoints = CreateConVar("rank_batpoints","5","Set the points the attacker get");
	pistolpoints = CreateConVar("rank_pistolpoints","4","Set the points the attacker get");
	tf_projectile_rocketpoints = CreateConVar("rank_tf_projectile_rocketpoints","1","Set the points the attacker get");
	shotgunpoints = CreateConVar("rank_shotgunpoints","2","Set the points the attacker get");
	shovelpoints = CreateConVar("rank_shovelpoints","2","Set the points the attacker get");
	flamethrowerpoints = CreateConVar("rank_flamethrowerpoints","2","Set the points the attacker get");
	fireaxepoints = CreateConVar("rank_fireaxepoints","3","Set the points the attacker get");
	tf_projectile_pipepoints = CreateConVar("rank_tf_projectile_pipepoints","3","Set the points the attacker get");
	tf_projectile_pipe_remotepoints = CreateConVar("rank_tf_projectile_pipe_remotepoints","3","Set the points the attacker get");
	bottlepoints = CreateConVar("rank_bottlepoints","4","Set the points the attacker get");
	minigunpoints = CreateConVar("rank_minigunpoints","1","Set the points the attacker get");
	fistspoints = CreateConVar("rank_fistspoints","2","Set the points the attacker get");
	obj_sentrygunpoints = CreateConVar("rank_obj_sentrygunpoints","3","Set the points the attacker get");
	wrenchpoints = CreateConVar("rank_wrenchpoints","4","Set the points the attacker get");
	bonesawpoints = CreateConVar("rank_bonesawpoints","6","Set the points the attacker get");
	syringegun_medicpoints = CreateConVar("rank_syringegun_medicpoints","5","Set the points the attacker get");
	clubpoints = CreateConVar("rank_clubpoints","2","Set the points the attacker get");
	smgpoints = CreateConVar("rank_smgpoints","1","Set the points the attacker get");
	sniperriflepoints = CreateConVar("rank_sniperriflepoints","1","Set the points the attacker get");
	revolverpoints = CreateConVar("rank_revolverpoints","3","Set the points the attacker get");
	knifepoints = CreateConVar("rank_knifepoints","3","Set the points the attacker get");
	killsapperpoints = CreateConVar("rank_killsapperpoints","1","Set the points the attacker get");
	killteleinpoints = CreateConVar("rank_killteleinpoints","1","Set the points the attacker get");
	killteleoutpoints = CreateConVar("rank_killteleoutpoints","1","Set the points the attacker get");
	killdisppoints = CreateConVar("rank_killdisppoints","2","Set the points the attacker get");
	killsentrypoints = CreateConVar("rank_killsentrypoints","3","Set the points the attacker get");
	showrankonroundend = CreateConVar("rank_showrankonroundend","1","Shows Top 10 on Roundend");
	removeoldplayers = CreateConVar("rank_removeoldplayers","1","Enable Automatic Removing Player who doesn't conect a specific time on every Roundend");
	removeoldplayersdays = CreateConVar("rank_removeoldplayersdays","14","The time in days after a player get removed if he doesn't connect min 1 day");
	killasipoints = CreateConVar("rank_killasipoints","2","Set the points the attacker get"); 
	Capturepoints = CreateConVar("rank_capturepoints","2","Set the points");
	Captureblockpoints = CreateConVar("rank_blockcapturepoints","2","Set the points");
	FileCapturepoints = CreateConVar("rank_filecapturepoints","2","Set the points");
	killasimedipoints = CreateConVar("rank_killasimedicpoints","2","Set the points the attacker get");
	overchargepoints = CreateConVar("rank_overchargepoints","2","Set the points the medic get");
	removeoldmaps = CreateConVar("rank_removeoldmaps","1","Enable Automatic Removing Maps who wasn't played a specific time on every Roundend");
	removeoldmapssdays = CreateConVar("rank_removeoldmapsdays","14","The time in days after a map get removed, min 1 day");
	
	ubersawpoints = CreateConVar("rank_ubersawpoints","6","Set the points the attacker get");
	flaregunpoints = CreateConVar("rank_flaregunpoints","4","Set the points the attacker get");
	axtinguisherpoints = CreateConVar("rank_axtinguisherpoints","3","Set the points the attacker get");
	taunt_pyropoints = CreateConVar("rank_taunt_pyropoints","8","Set the points the attacker get");
	
	}
public starteventhooking()
{
	HookEvent("player_death", Event_PlayerDeath)
	HookEvent("player_builtobject", Event_player_builtobject)
	HookEvent("object_destroyed", Event_object_destroyed)
	HookEvent("teamplay_round_win", Event_round_end)
	HookEvent("teamplay_point_captured", Event_point_captured)
	HookEvent("ctf_flag_captured", Event_flag_captured)
	HookEvent("teamplay_capture_blocked", Event_capture_blocked)
	HookEvent("player_invulned", Event_player_invulned)
	
}

public Event_player_invulned(Handle:event, const String:name[], bool:dontBroadcast)
{
	new userid = GetEventInt(event, "medic_userid")
	new client = GetClientOfUserId(userid)
	new String:steamIdassister[MAX_LINE_WIDTH];
	GetClientAuthString(client, steamIdassister, sizeof(steamIdassister));
	decl String:query[512];
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, Overcharge = Overcharge + 1 WHERE STEAMID = '%s'",GetConVarInt(overchargepoints), steamIdassister);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victimId = GetEventInt(event, "userid")
	new attackerId = GetEventInt(event, "attacker")
	new assisterId = GetEventInt(event, "assister")
	new assister = GetClientOfUserId(assisterId)
	new victim = GetClientOfUserId(victimId)
	new attacker = GetClientOfUserId(attackerId)
	new dominated = GetEventInt(event, "dominated")
	new assister_dominated = GetEventInt(event, "assister_dominated")
	new revenge = GetEventInt(event, "revenge")
	new assister_revenge = GetEventInt(event, "assister_revenge")
	
	
	if (attacker != 0)
	{
	if (attacker != victim)
	{
	decl String:query[512];
	if (assister != 0)
	{
	
	new class = TF_GetClass(assister)
	new String:steamIdassister[MAX_LINE_WIDTH];
	GetClientAuthString(assister, steamIdassister, sizeof(steamIdassister));
	if (class == 5)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KillAssistMedic = KillAssistMedic + 1 WHERE STEAMID = '%s'",GetConVarInt(killasipoints), steamIdassister);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KillAssist = KillAssist + 1 WHERE STEAMID = '%s'",GetConVarInt(killasimedipoints), steamIdassister);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	if (assister_dominated)
	{
	Format(query, sizeof(query), "UPDATE Player SET Domination = Domination + 1 WHERE STEAMID = '%s'", steamIdassister);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	if (assister_revenge)
	{
	Format(query, sizeof(query), "UPDATE Player SET Revenge = Revenge + 1 WHERE STEAMID = '%s'", steamIdassister);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	}
	new String:weapon[64]
	GetEventString(event, "weapon", weapon, sizeof(weapon))
	PrintToConsole(attacker,"[N1G-Debug] Weapon = %s", weapon)
	
	new String:steamIdattacker[MAX_LINE_WIDTH];
	new String:steamIdavictim[MAX_LINE_WIDTH];
	GetClientAuthString(attacker, steamIdattacker, sizeof(steamIdattacker));
	GetClientAuthString(victim, steamIdavictim, sizeof(steamIdavictim));
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS - %i, Death = Death + 1 WHERE STEAMID = '%s'",GetConVarInt(diepoints) ,steamIdavictim);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	
	if (dominated)
	{
	Format(query, sizeof(query), "UPDATE Player SET Domination = Domination + 1 WHERE STEAMID = '%s'", steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	if (revenge)
	{
	Format(query, sizeof(query), "UPDATE Player SET Revenge = Revenge + 1 WHERE STEAMID = '%s'", steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	if (strcmp(weapon[0], "scattergun", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Sg = KW_Sg + 1 WHERE steamId = '%s'",GetConVarInt(scattergunpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "bat", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Bt = KW_Bt + 1 WHERE STEAMID = '%s'",GetConVarInt(batpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "pistol_scout", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Pistl = KW_Pistl + 1 WHERE STEAMID = '%s'",GetConVarInt(pistolpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "tf_projectile_rocket", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Rkt = KW_Rkt + 1 WHERE STEAMID = '%s'",GetConVarInt(tf_projectile_rocketpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "shotgun_soldier", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Stgn = KW_Stgn + 1 WHERE STEAMID = '%s'",GetConVarInt(shotgunpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "shovel", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Shvl = KW_Shvl + 1 WHERE STEAMID = '%s'",GetConVarInt(shovelpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "flamethrower", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Ft = KW_Ft + 1 WHERE STEAMID = '%s'",GetConVarInt(flamethrowerpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "fireaxe", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Axe = KW_Axe + 1 WHERE STEAMID = '%s'",GetConVarInt(fireaxepoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "shotgun_pyro", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Stgn = KW_Stgn + 1 WHERE STEAMID = '%s'",GetConVarInt(shotgunpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "tf_projectile_pipe", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Gl = KW_Gl + 1 WHERE STEAMID = '%s'",GetConVarInt(tf_projectile_pipepoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "tf_projectile_pipe_remote", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Sky = KW_Sky + 1 WHERE STEAMID = '%s'",GetConVarInt(tf_projectile_pipe_remotepoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "bottle", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Bttl = KW_Bttl + 1 WHERE STEAMID = '%s'",GetConVarInt(bottlepoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "minigun", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_CG = KW_CG + 1 WHERE STEAMID = '%s'",GetConVarInt(minigunpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "fists", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Fsts = KW_Fsts + 1 WHERE STEAMID = '%s'",GetConVarInt(fistspoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "shotgun_hwg", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Stgn = KW_Stgn + 1 WHERE STEAMID = '%s'",GetConVarInt(shotgunpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "obj_sentrygun", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Sntry = KW_Sntry + 1 WHERE STEAMID = '%s'",GetConVarInt(obj_sentrygunpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "wrench", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Wrnc = KW_Wrnc + 1 WHERE STEAMID = '%s'",GetConVarInt(wrenchpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "pistol", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Pistl = KW_Pistl + 1 WHERE STEAMID = '%s'",GetConVarInt(pistolpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "shotgun_primary", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Stgn = KW_Stgn + 1 WHERE STEAMID = '%s'",GetConVarInt(shotgunpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "bonesaw", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Bnsw = KW_Bnsw + 1 WHERE STEAMID = '%s'",GetConVarInt(bonesawpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "syringegun_medic", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Ndl = KW_Ndl + 1 WHERE STEAMID = '%s'",GetConVarInt(syringegun_medicpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "club", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Mctte = KW_Mctte + 1 WHERE STEAMID = '%s'",GetConVarInt(clubpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "smg", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Smg = KW_Smg + 1 WHERE STEAMID = '%s'",GetConVarInt(smgpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "sniperrifle", false) == 0)
	{
	new customkill = GetEventInt(event, "customkill")
	if (customkill == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Spr = KW_Spr + 1 WHERE STEAMID = '%s'",GetConVarInt(sniperriflepoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, HeadshotKill = HeadshotKill + 1, KILLS = KILLS + 1, KW_Spr = KW_Spr + 1 WHERE STEAMID = '%s'",GetConVarInt(sniperriflepoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)	
	}
	}
	else if (strcmp(weapon[0], "revolver", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Mgn = KW_Mgn + 1 WHERE STEAMID = '%s'",GetConVarInt(revolverpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "knife", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Kn = KW_Kn + 1 WHERE STEAMID = '%s'",GetConVarInt(knifepoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "ubersaw", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Ubersaw = KW_Ubersaw + 1 WHERE STEAMID = '%s'",GetConVarInt(ubersawpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "flaregun", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Flaregun = KW_Flaregun + 1 WHERE STEAMID = '%s'",GetConVarInt(flaregunpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "axtinguisher", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_Axtinguisher = KW_Axtinguisher + 1 WHERE STEAMID = '%s'",GetConVarInt(axtinguisherpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (strcmp(weapon[0], "taunt_pyro", false) == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KILLS = KILLS + 1, KW_taunt_pyro = KW_taunt_pyro + 1 WHERE STEAMID = '%s'",GetConVarInt(taunt_pyropoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	}
	}
}
public Action:Event_player_builtobject(Handle:event, const String:name[], bool:dontBroadcast)
{
	new String:steamIdbuilder[MAX_LINE_WIDTH];
	new userId = GetEventInt(event, "userid")
	new user = GetClientOfUserId(userId)
	new object = GetEventInt(event, "object")
	GetClientAuthString(user, steamIdbuilder, sizeof(steamIdbuilder));
	new String:query[512];
	if (object == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET BuildDispenser = BuildDispenser + 1 WHERE STEAMID = '%s'",steamIdbuilder);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (object == 1)
	{
	Format(query, sizeof(query), "UPDATE Player SET BOTeleporterentrace = BOTeleporterentrace + 1 WHERE STEAMID = '%s'",steamIdbuilder);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (object == 2)
	{
	Format(query, sizeof(query), "UPDATE Player SET BOTeleporterExit = BOTeleporterExit + 1 WHERE STEAMID = '%s'",steamIdbuilder);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (object == 3)
	{
	Format(query, sizeof(query), "UPDATE Player SET BuildSentrygun = BuildSentrygun + 1 WHERE STEAMID = '%s'",steamIdbuilder);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (object == 4)
	{
	Format(query, sizeof(query), "UPDATE Player SET BOSapper = BOSapper + 1 WHERE STEAMID = '%s'",steamIdbuilder);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
}
public Action:Event_object_destroyed(Handle:event, const String:name[], bool:dontBroadcast)
{
if (GetEventInt(event, "userid") != GetEventInt(event, "attacker"))
{
	new userId = GetEventInt(event, "attacker")
	new object = GetEventInt(event, "objecttype")
	new user = GetClientOfUserId(userId)
	new String:steamIdattacker[MAX_LINE_WIDTH];
	GetClientAuthString(user, steamIdattacker, sizeof(steamIdattacker));
	new String:query[512];
	if (object == 0)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KODispenser = KODispenser + 1 WHERE STEAMID = '%s'",GetConVarInt(killdisppoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (object == 1)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KOTeleporterEntrace = KOTeleporterEntrace + 1 WHERE STEAMID = '%s'",GetConVarInt(killteleinpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (object == 2)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KOTeleporterExit = KOTeleporterExit + 1 WHERE STEAMID = '%s'",GetConVarInt(killteleoutpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (object == 3)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KOSentrygun = KOSentrygun + 1 WHERE STEAMID = '%s'",GetConVarInt(killsentrypoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	else if (object == 4)
	{
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, KOSapper = KOSapper + 1 WHERE STEAMID = '%s'",GetConVarInt(killsapperpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}

}
}
public Action:Command_Say(client, args){
	new String:text[192], String:command[64];

	new startidx = 0;

	GetCmdArgString(text, sizeof(text));

	if (text[strlen(text)-1] == '"')
	{		
	text[strlen(text)-1] = '\0';
	startidx = 1;	
	} 	
	if (strcmp(command, "say2", false) == 0)
	startidx += 4;
	if (strcmp(text[startidx], "!Rank", false) == 0)
{
	echo_rank(client)
}
	else if (strcmp(text[startidx], "Rank", false) == 0)
{
	echo_rank(client)
}
	else if (strcmp(text[startidx], "Top10", false) == 0)
{
	top10pnl(client)
}
	else if (strcmp(text[startidx], "Top", false) == 0)
{
	top10pnl(client)
}
	else if (strcmp(text[startidx], "rankinfo", false) == 0)
{
	rankinfo(client)
}
	else if (strcmp(text[startidx], "players", false) == 0)
{
	listplayers(client)
}

	return Plugin_Continue;
}

public Action:rankinfo(client)
{
	new Handle:infopanel = CreatePanel();
	SetPanelTitle(infopanel, "About Rank:")
	DrawPanelText(infopanel, "Plugin Coded by R-Hehl")
	DrawPanelText(infopanel, "Visit CompactAim.de")
	DrawPanelText(infopanel, "Contact me for")
	DrawPanelText(infopanel, "Feature Request or Bugreport")
	DrawPanelText(infopanel, "Icq 87-47-94")
	DrawPanelText(infopanel, "E-Mail tf2stats@n1g.de")
	DrawPanelText(infopanel, "Thanks to my alpha tester")
	DrawPanelText(infopanel, "K-Play and FPS-Banana")
	DrawPanelItem(infopanel, "Close")
 
	SendPanelToClient(infopanel, client, InfoPanelHandler, 20)
 
	CloseHandle(infopanel)
 
	return Plugin_Handled
}
public InfoPanelHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		
	} else if (action == MenuAction_Cancel) {
		
	}
}
/* old code */
public echo_rank(client){
	if(IsClientInGame(client))
	{
	new String:steamId[MAX_LINE_WIDTH]
	GetClientAuthString(client, steamId, sizeof(steamId));
	rankpanel(client, steamId)
}
}
public Action:top10pnl(client)
{
	new Handle:top10panel = CreatePanel();	
	new String:value2[MAX_LINE_WIDTH]
	Format(value2, sizeof(value2), "%t", "Top 10 Menu");
	SetPanelTitle(top10panel, value2)
	
	new String:name[MAX_LINE_WIDTH];
	new String:buffer1[512];
	Format(buffer1, sizeof(buffer1), "SELECT NAME,steamId FROM `Player` ORDER BY POINTS DESC LIMIT 0,10");
	new Handle:queryBase = SQL_Query(db, buffer1)
	new i = 1
	
	while (SQL_FetchRow(queryBase))
	{
	SQL_FetchString(queryBase, 0, name, sizeof(name));
	if (i == 1)
	{
	SQL_FetchString(queryBase, 1, topsteamIda, sizeof(topsteamIda));
	}
	else if (i == 2)
	{
	SQL_FetchString(queryBase, 1, topsteamIdb, sizeof(topsteamIdb));
	}
	else if (i == 3)
	{
	SQL_FetchString(queryBase, 1, topsteamIdc, sizeof(topsteamIdc));
	}
	else if (i == 4)
	{
	SQL_FetchString(queryBase, 1, topsteamIdd, sizeof(topsteamIdd));
	}
	else if (i == 5)
	{
	SQL_FetchString(queryBase, 1, topsteamIde, sizeof(topsteamIde));
	}
	else if (i == 6)
	{
	SQL_FetchString(queryBase, 1, topsteamIdf, sizeof(topsteamIdf));
	}
	else if (i == 7)
	{
	SQL_FetchString(queryBase, 1, topsteamIdg, sizeof(topsteamIdg));
	}
	else if (i == 8)
	{
	SQL_FetchString(queryBase, 1, topsteamIdh, sizeof(topsteamIdh));
	}
	else if (i == 9)
	{
	SQL_FetchString(queryBase, 1, topsteamIdi, sizeof(topsteamIdi));
	}
	else
	{
	SQL_FetchString(queryBase, 1, topsteamIdj, sizeof(topsteamIdj));
	}
	
	DrawPanelItem(top10panel, name)
	i++
	}
	new String:value[MAX_LINE_WIDTH]
	Format(value, sizeof(value), " ");
	DrawPanelText(top10panel, value)
	Format(value, sizeof(value), "%t", "top10ad1");
	DrawPanelText(top10panel, value)
	Format(value, sizeof(value), "%t", "top10ad2");
	DrawPanelText(top10panel, value)
	SendPanelToClient(top10panel, client, Top10PanelHandler, 20)
	CloseHandle(top10panel)
 
	return Plugin_Handled
}
public Top10PanelHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
	if (param2 == 0)
	{
	rankpanel(param1, topsteamIdj)
	}
	else if (param2 == 1)
	{
	rankpanel(param1, topsteamIda)
	}
	else if (param2 == 2)
	{
	rankpanel(param1, topsteamIdb)
	}
	else if (param2 == 3)
	{
	rankpanel(param1, topsteamIdc)
	}
	else if (param2 == 4)
	{
	rankpanel(param1, topsteamIdd)
	}
	else if (param2 == 5)
	{
	rankpanel(param1, topsteamIde)
	}
	else if (param2 == 6)
	{
	rankpanel(param1, topsteamIdf)
	}
	else if (param2 == 7)
	{
	rankpanel(param1, topsteamIdg)
	}
	else if (param2 == 8)
	{
	rankpanel(param1, topsteamIdh)
	}
	else
	{
	rankpanel(param1, topsteamIdi)
	}
	
	}else if (action == MenuAction_Cancel) {
		
	}
	
}
public Action:rankpanel(client, const String:steamid[])
{
	new String:name[MAX_LINE_WIDTH]
	new Handle:rnkpanel = CreatePanel();
	new String:value2[MAX_LINE_WIDTH]
	Format(value2, sizeof(value2), "%t", "Rank panel player titel");
	SetPanelTitle(rnkpanel, value2)
	new points,plytime,kills,death
	new String:buffer1[2048];
	Format(buffer1, sizeof(buffer1), "SELECT POINTS,PLAYTIME,NAME,KILLS,Death FROM `Player` WHERE `STEAMID` LIKE '%s'", steamid);
	new Handle:queryBase = SQL_Query(db, buffer1)
	while (SQL_FetchRow(queryBase))
	{
	points = SQL_FetchInt(queryBase, 0);
	plytime = SQL_FetchInt(queryBase, 1);
	SQL_FetchString(queryBase, 2, name, sizeof(name));
	kills = SQL_FetchInt(queryBase, 3);
	death = SQL_FetchInt(queryBase, 4);
	}		
	new rank
	Format(buffer1, sizeof(buffer1), "SELECT NAME FROM `Player` WHERE `POINTS` >=%i", points);
	new Handle:queryBase2 = SQL_Query(db, buffer1)
	rank = SQL_GetRowCount(queryBase2)
	
	

	new String:value[MAX_LINE_WIDTH]
	Format(value, sizeof(value), "%t", "Rank panel Name" , name);
	DrawPanelText(rnkpanel, value)
	Format(value, sizeof(value), "%t", "Rank panel Rank" , rank);
	DrawPanelText(rnkpanel, value)
	Format(value, sizeof(value), "%t", "Rank panel Points" , points);
	DrawPanelText(rnkpanel, value)
	Format(value, sizeof(value), "%t", "Rank panel Playtime" , plytime);
	DrawPanelText(rnkpanel, value)
	Format(value, sizeof(value), "%t", "Rank panel Kills" , kills);
	DrawPanelText(rnkpanel, value)
	Format(value, sizeof(value), "%t", "Rank panel Deaths" , death);
	DrawPanelText(rnkpanel, value)
	
	/*DrawPanelItem(rnkpanel, "More")*/
	DrawPanelItem(rnkpanel, "Close")
 
	SendPanelToClient(rnkpanel, client, RankPanelHandler, 20)
 
	CloseHandle(rnkpanel)
 
	return Plugin_Handled
}
public RankPanelHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
	if (param2 == 1)
	{
	PrintToConsole(param1, "You selected more")	
	}	
	} else if (action == MenuAction_Cancel) {
	PrintToServer("Client %d's menu was cancelled.  Reason: %d", param1, param2)
	}
}
/* end of old code*/
public Action:Event_round_end(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarInt(showrankonroundend) == 1)
	{
	/*showeallrank()*/
	}
	if (GetConVarInt(removeoldplayers) == 1)
	{
	removetooldplayers()
	}
	if (sqllite == 0)
	{
	if (GetConVarInt(removeoldmaps) == 1)
	{
	removetooldmaps()
	}
	}
}
public showeallrank()
{
	new l_maxplayers
	l_maxplayers = GetMaxClients()
	for (new i=1; i<=l_maxplayers; i++)
	{
		if (IsClientInGame(i))
		
		{
		new String:steamIdclient[MAX_LINE_WIDTH];
		GetClientAuthString(i, steamIdclient, sizeof(steamIdclient));
		rankpanel(i, steamIdclient)
		}
	}

}
public removetooldplayers()
{
new remdays = GetConVarInt(removeoldplayersdays)
if (remdays >= 1)
{
new timesec = GetTime() - (remdays * 86400)
new String:query[512];
Format(query, sizeof(query), "DELETE FROM Player WHERE LASTONTIME < '%i'",timesec);
SQL_TQuery(db,SQLErrorCheckCallback, query)
}
}
public Event_point_captured(Handle:event, const String:name[], bool:dontBroadcast)
{
	new team = GetEventInt(event, "team")
	new l_maxplayers
	l_maxplayers = GetMaxClients()
	for (new i=1; i<=l_maxplayers; i++)
	{
		if (IsClientInGame(i))
		{
		if (GetClientTeam(i) == team)
		{
		new String:steamIdattacker[MAX_LINE_WIDTH];
		GetClientAuthString(i, steamIdattacker, sizeof(steamIdattacker));
		new String:query[512];
		Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, CPCaptured = CPCaptured + 1 WHERE STEAMID = '%s'",GetConVarInt(Capturepoints) ,steamIdattacker);
		SQL_TQuery(db,SQLErrorCheckCallback, query)
		}
		}
	}
}
public Event_flag_captured(Handle:event, const String:name[], bool:dontBroadcast)
{
	new team = GetEventInt(event, "capping_team")
	new l_maxplayers
	l_maxplayers = GetMaxClients()
	for (new i=1; i<=l_maxplayers; i++)
	{
		if (IsClientInGame(i))
		{
		if (GetClientTeam(i) == team)
		{
		new String:steamIdattacker[MAX_LINE_WIDTH];
		GetClientAuthString(i, steamIdattacker, sizeof(steamIdattacker));
		new String:query[512];
		Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, FileCaptured = FileCaptured + 1 WHERE STEAMID = '%s'",GetConVarInt(FileCapturepoints) ,steamIdattacker);
		SQL_TQuery(db,SQLErrorCheckCallback, query)
		}
		}
	}
}

public Event_capture_blocked(Handle:event, const String:name[], bool:dontBroadcast)
{
	new blocker = GetEventInt(event, "blocker")
	new String:steamIdattacker[MAX_LINE_WIDTH];
	GetClientAuthString(blocker, steamIdattacker, sizeof(steamIdattacker));
	new String:query[512];
	Format(query, sizeof(query), "UPDATE Player SET POINTS = POINTS + %i, CPBlocked = CPBlocked + 1 WHERE STEAMID = '%s'",GetConVarInt(Captureblockpoints) ,steamIdattacker);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	
}
public OnMapStart()
{
	MapInit()
}
public OnMapEnd()
{
	mapisset = 0
}
public MapInit()
{
	if (mapisset == 0)
{
	InitializeMaponDB()
	if (classfunctionloaded == 0)
{
	maxplayers = GetMaxClients();
	maxents = GetMaxEntities();
	ResourceEnt = FindResourceObject();
	if(ResourceEnt == -1){
	LogMessage("Attetion! Server could not find player data table");
	classfunctionloaded = 1
	}
	}
}
}
public InitializeMaponDB()
{
if (mapisset == 0)
{
new String:name[MAX_LINE_WIDTH];
GetCurrentMap(name,MAX_LINE_WIDTH);
new String:query[512];
Format(query, sizeof(query), "INSERT IGNORE INTO Map (`NAME`) VALUES ('%s')", name)
SQL_TQuery(db,SQLErrorCheckCallback, query)
mapisset = 1
}
}
stock TF_GetClass(client){
	return GetEntData(ResourceEnt, TF_classoffsets + (client*4), 4);
}
stock FindResourceObject(){
	new i, String:classname[64];
	
	//Isen't there a easier way?
	//FindResourceObject does not work
	for(i = maxplayers; i <= maxents; i++){
	 	if(IsValidEntity(i)){
			GetEntityNetClass(i, classname, 64);
			if(StrEqual(classname, "CTFPlayerResource")){
			 		//LogMessage("Found CTFPlayerResource at %d", i)
					return i;
			}
		}
	}
	return -1;	
}
public removetooldmaps()
{
new remdays = GetConVarInt(removeoldmapssdays)
if (remdays >= 1)
{
new timesec = GetTime() - (remdays * 86400)
new String:query[512];
Format(query, sizeof(query), "DELETE FROM Map WHERE LASTONTIME < '%i'",timesec);
SQL_TQuery(db,SQLErrorCheckCallback, query)
}
}
public updateplayername(client)
{
	new String:steamId[MAX_LINE_WIDTH];
	GetClientAuthString(client, steamId, sizeof(steamId));
	new String:name[MAX_LINE_WIDTH];
	GetClientName( client, name, sizeof(name) );
	ReplaceString(name, sizeof(name), "'", "");
	ReplaceString(name, sizeof(name), "<?", "");
	ReplaceString(name, sizeof(name), "?>", "");
	ReplaceString(name, sizeof(name), "\"", "");
	ReplaceString(name, sizeof(name), "<?PHP", "");
	ReplaceString(name, sizeof(name), "<?php", "");
	new String:query[512];
	Format(query, sizeof(query), "UPDATE Player SET NAME = '%s' WHERE STEAMID = '%s'",name ,steamId);
	SQL_TQuery(db,SQLErrorCheckCallback, query)
}
public initonlineplayers()
{
	
	new l_maxplayers
	l_maxplayers = GetMaxClients()
	for (new i=1; i<=l_maxplayers; i++)
	{
	if (IsClientInGame(i))
	{
	updateplayername(i)
	InitializeClientonDB(i)
	}
	}
}
public Action:Menu_adm(client, args)
{
	new Handle:menu = CreateMenu(MenuHandlerrnkadm)
	SetMenuTitle(menu, "Rank Admin Menu")
	AddMenuItem(menu, "reset", "Reset Rank")
	SetMenuExitButton(menu, true)
	DisplayMenu(menu, client, 20)
 
	return Plugin_Handled
}
public MenuHandlerrnkadm(Handle:menu, MenuAction:action, param1, param2)
{
	/* Either Select or Cancel will ALWAYS be sent! */
	if (action == MenuAction_Select)
	{
	new String:info[32]
	GetMenuItem(menu, param2, info, sizeof(info))
	if (strcmp(info,"rank",false))
	{
	resetdb()
	}
	} 
	/* If the menu has ended, destroy it */
	if (action == MenuAction_End)
	{
		CloseHandle(menu)
	}
}
public resetdb()
{
	new String:query[512];
	Format(query, sizeof(query), "TRUNCATE TABLE Player");
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	if (sqllite == 0)
	{
	Format(query, sizeof(query), "TRUNCATE TABLE Map");
	SQL_TQuery(db,SQLErrorCheckCallback, query)
	}
	initonlineplayers()
}

public listplayers(client)
{
	Menu_playerlist(client)
}

public Action:Menu_playerlist(client)
{
	new Handle:menu = CreateMenu(MenuHandlerplayerslist)
	SetMenuTitle(menu, "Online Players:")
	new maxClients = GetMaxClients();
	for (new i=1; i<=maxClients; i++)
		{
			if (!IsClientInGame(i))
			{
				continue;
			}
			new String:name[65];
			GetClientName(i, name, sizeof(name));
			new String:steamId[MAX_LINE_WIDTH];
			GetClientAuthString(i, steamId, sizeof(steamId));
			AddMenuItem(menu, steamId, name)
		}
	SetMenuExitButton(menu, true)
	DisplayMenu(menu, client, 20)
	return Plugin_Handled
}
public MenuHandlerplayerslist(Handle:menu, MenuAction:action, param1, param2)
{
	/* Either Select or Cancel will ALWAYS be sent! */
	if (action == MenuAction_Select)
	{
	new String:info[32]
	GetMenuItem(menu, param2, info, sizeof(info))
	rankpanel(param1, info)
	}
	
	
	/* If the menu has ended, destroy it */
	if (action == MenuAction_End)
	{
		CloseHandle(menu)
	}
}