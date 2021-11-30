#pragma semicolon 1

#if defined(AUTOVERSION)
#include "version.inc"
#else
#define PLUGIN_VERSION	"2.2.6.4"
#endif

#if !defined(DEBUG_ALL)
#define DEBUG_ALL 	0
#endif

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#define LEFT4FRAMEWORK_INCLUDE 1
#include <left4framework>
//#undef REQUIRE_PLUGIN
//#include <l4d2lib> //ItemTracking (commented out)

#include "includes/constants.sp"
#include "includes/functions.sp"
#include "includes/debug.sp"
#include "includes/survivorindex.sp"
#include "includes/configs.sp"
#include "includes/customtags.inc"

#include "modules/MapInfo.sp"
#include "modules/WeaponInformation.sp"
#include "modules/ReqMatch.sp"
#include "modules/CvarSettings.sp"
#include "modules/GhostTank.sp"
#include "modules/WaterSlowdown.sp"
#include "modules/UnreserveLobby.sp"
#include "modules/GhostWarp.sp"
#include "modules/UnprohibitBosses.sp"
#include "modules/PasswordSystem.sp"
#include "modules/BotKick.sp"
#include "modules/EntityRemover.sp"
#include "modules/ScoreMod.sp"
#include "modules/FinaleSpawn.sp"
#include "modules/BossSpawning.sp"
#include "modules/WeaponCustomization.sp"
#include "modules/ClientSettings.sp"
#include "modules/ItemTracking.sp"
//#include "modules/SpectatorHud.sp"

public Plugin:myinfo = 
{
	name = "Confogl's Competitive Mod",
	author = "Confogl Team",
	description = "A competitive mod for L4D2",
	version = PLUGIN_VERSION,
	url = "http://confogl.googlecode.com/"
}

public OnPluginStart()
{
	Debug_OnModuleStart();
	Configs_OnModuleStart();
	MI_OnModuleStart();
	SI_OnModuleStart();
	WI_OnModuleStart();
	
	RM_OnModuleStart();
	
	CVS_OnModuleStart();
	PS_OnModuleStart();
	UL_OnModuleStart();
	
	ER_OnModuleStart();
	GW_OnModuleStart();
	WS_OnModuleStart();
	GT_OnModuleStart();
	UB_OnModuleStart();
	
	BK_OnModuleStart();
	
	SM_OnModuleStart();
	FS_OnModuleStart();
	BS_OnModuleStart();
	WC_OnModuleStart();
	CLS_OnModuleStart();
	IT_OnModuleStart();
	//SH_OnModuleStart();
	
	AddCustomServerTag("confogl", true);
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	RM_APL();
	Configs_APL();
	MI_APL();
	RegPluginLibrary("confogl");
}

public OnPluginEnd()
{
	CVS_OnModuleEnd();
	PS_OnModuleEnd();
	ER_OnModuleEnd();
	SM_OnModuleEnd();
	
	WS_OnModuleEnd();
	RemoveCustomServerTag("confogl");
}

public OnGameFrame()
{
	WS_OnGameFrame();
}

public OnMapStart()
{
	MI_OnMapStart();
	RM_OnMapStart();
	
	SM_OnMapStart();
	BS_OnMapStart();
	IT_OnMapStart();
}

public OnMapEnd()
{
	MI_OnMapEnd();
	WI_OnMapEnd();
	
	PS_OnMapEnd();
	WS_OnMapEnd();
}

public OnConfigsExecuted()
{
	CVS_OnConfigsExecuted();
}

public OnClientDisconnect(client)
{
	RM_OnClientDisconnect(client);
	//GT_OnClientDisconnect(client);
	//SH_OnClientDisconnect(client);
}

public OnClientPutInServer(client)
{
	RM_OnClientPutInServer();
	UL_OnClientPutInServer();
	PS_OnClientPutInServer(client);
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if(GW_OnPlayerRunCmd(client, buttons))
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action:L4D_OnCThrowActivate(iAbility)
{
	//Modules
	if (GT_OnCThrowActivate() == Plugin_Handled) {//GhostTank
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action:L4D_OnSpawnTank(const Float:vector[3], const Float:qangle[3])
{
	if(GT_OnTankSpawn_Forward() == Plugin_Handled)
		return Plugin_Handled;

	BS_OnTankSpawn_Forward();
	return Plugin_Continue;
}

public Action:L4D_OnSpawnMob(&amount)
{
	if(GT_OnSpawnMob_Forward(amount) == Plugin_Handled)
		return Plugin_Handled;

	return Plugin_Continue;
}

public Action:L4D_OnTryOfferingTankBot(tank_index, &bool:enterStasis)
{
	if(GT_OnTryOfferingTankBot(enterStasis) == Plugin_Handled)
		return Plugin_Handled;

	return Plugin_Continue;
}

public Action:L4D_OnGetMissionVSBossSpawning(&Float:spawn_pos_min, &Float:spawn_pos_max, &Float:tank_chance, &Float:witch_chance)
{
	if (UB_OnGetMissionVSBossSpawning() == Plugin_Handled)
		return Plugin_Handled;

	return Plugin_Continue;
}

public Action:L4D_OnGetScriptValueInt(const String:key[], &retVal)
{
	if (UB_OnGetScriptValueInt(key, retVal) == Plugin_Handled)
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action:L4D_OnFirstSurvivorLeftSafeArea(client)
{
	if(IsPluginEnabled())
	{
		CreateTimer(0.1, OFSLA_ForceMobSpawnTimer);
	}
	return Plugin_Continue;
}

public Action:OFSLA_ForceMobSpawnTimer(Handle:timer)
{
	// Workaround to make tank horde blocking always work
	// Makes the first horde always start 100s after survivors leave saferoom
	static Handle:MobSpawnTimeMin, Handle:MobSpawnTimeMax;
	if(MobSpawnTimeMin == INVALID_HANDLE)
	{
		MobSpawnTimeMin = FindConVar("z_mob_spawn_min_interval_normal");
		MobSpawnTimeMax = FindConVar("z_mob_spawn_max_interval_normal");
	}
	L4D2_CTimerStart(L4D2CT_MobSpawnTimer, GetRandomFloat(GetConVarFloat(MobSpawnTimeMin), GetConVarFloat(MobSpawnTimeMax)));
}
