#pragma semicolon 1

#define DEBUG_ALL		0
#define PLUGIN_VERSION	"2.2.7.1"

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

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	//Plugin functions
	Configs_APL(); //configs

	//Modules
	RM_APL(); //ReqMatch
	MI_APL(); //MapInfo

	//Other
	RegPluginLibrary("confogl");
	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "Confogl's Competitive Mod",
	author = "Confogl Team, A1m`",
	description = "A competitive mod for L4D2",
	version = PLUGIN_VERSION,
	url = "https://github.com/L4D-Community/confoglcompmod"
};

public void OnPluginStart()
{
	//Plugin functions
	FNS_OnPluginStart(); //functions
	Debug_OnModuleStart(); //debug
	Configs_OnModuleStart(); //configs
	SI_OnModuleStart(); //survivorindex

	//Modules
	MI_OnModuleStart(); //MapInfo
	WI_OnModuleStart(); //WeaponInformation
	RM_OnModuleStart(); //ReqMatch
	CVS_OnModuleStart(); //CvarSettings
	PS_OnModuleStart(); //PasswordSystem
	UL_OnModuleStart(); //UnreserveLobby
	ER_OnModuleStart(); //EntityRemover
	GW_OnModuleStart(); //GhostWarp
	WS_OnModuleStart(); //WaterSlowdown
	GT_OnModuleStart(); //GhostTank
	UB_OnModuleStart(); //UnprohibitBosses
	BK_OnModuleStart(); //BotKick
	SM_OnModuleStart(); //ScoreMod
	FS_OnModuleStart(); //FinaleSpawn
	BS_OnModuleStart(); //BossSpawning
	WC_OnModuleStart(); //WeaponCustomization
	CLS_OnModuleStart(); //ClientSettings
	IT_OnModuleStart(); //ItemTracking

	//Other
	AddCustomServerTag("confogl", true);
}

public void OnPluginEnd()
{
	//Modules
	CVS_OnModuleEnd(); //CvarSettings
	PS_OnModuleEnd(); //PasswordSystem
	ER_OnModuleEnd(); //EntityRemover
	SM_OnModuleEnd(); //ScoreMod
	WS_OnModuleEnd(); //WaterSlowdown
	MI_OnModuleEnd(); //MapInfo

	//Other
	RemoveCustomServerTag("confogl");
}

public void OnMapStart()
{
	//Modules
	MI_OnMapStart(); //MapInfo
	RM_OnMapStart(); //ReqMatch
	SM_OnMapStart(); //ScoreMod
	BS_OnMapStart(); //BossSpawning
	IT_OnMapStart(); //ItemTracking
}

public void OnMapEnd()
{
	//Modules
	MI_OnMapEnd(); //MapInfo
	WI_OnMapEnd(); //WeaponInformation
	PS_OnMapEnd(); //PasswordSystem
	WS_OnMapEnd(); //WaterSlowdown
}

public void OnConfigsExecuted()
{
	//Modules
	CVS_OnConfigsExecuted(); //CvarSettings
}

public void OnClientDisconnect(int client)
{
	//Modules
	RM_OnClientDisconnect(client); //ReqMatch
}

public bool OnClientConnect(int client, char[] rejectmsg, int maxlen)
{
	//Modules
	if (!BK_OnClientConnect(client)) { //BotKick
		return false;
	}

	return true;
}

public void OnClientPutInServer(int client)
{
	//Modules
	RM_OnClientPutInServer(); //ReqMatch
	UL_OnClientPutInServer(); //UnreserveLobby
	PS_OnClientPutInServer(client); //PasswordSystem
	FS_OnOnClientPutInServer(client); //FinaleSpawn
}

//Hot functions =)
public void OnGameFrame()
{
	//Modules
	WS_OnGameFrame(); //WaterSlowdown
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, \
									int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	//Modules
	if (GW_OnPlayerRunCmd(client, buttons)) { //GhostWarp
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

//Left4Dhooks or Left4Downtown functions
public Action L4D_OnCThrowActivate(int iAbility)
{
	//Modules
	if (GT_OnCThrowActivate() == Plugin_Handled) { //GhostTank
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action L4D_OnSpawnTank(const float vector[3], const float qangle[3])
{
	//Modules
	if (GT_OnTankSpawn_Forward() == Plugin_Handled) { //GhostTank
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public void L4D_OnSpawnTank_Post(int client, const float vecPos[3], const float vecAng[3])
{
	//Modules
	BS_OnTankSpawn_Forward(); //BossSpawning
}

public Action L4D_OnSpawnMob(int &amount)
{
	//Modules
	if (GT_OnSpawnMob_Forward(amount) == Plugin_Handled) { //GhostTank
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action L4D_OnTryOfferingTankBot(int tank_index, bool &enterStasis)
{
	//Modules
	if (GT_OnTryOfferingTankBot(enterStasis) == Plugin_Handled) { //GhostTank
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action L4D_OnGetMissionVSBossSpawning(float &spawn_pos_min, float &spawn_pos_max, float &tank_chance, float &witch_chance)
{
	//Modules
	if (UB_OnGetMissionVSBossSpawning() == Plugin_Handled) { //UnprohibitBosses
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action L4D_OnGetScriptValueInt(const char[] key, int &retVal)
{
	//Modules
	if (UB_OnGetScriptValueInt(key, retVal) == Plugin_Handled) { //UnprohibitBosses
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action L4D_OnFirstSurvivorLeftSafeArea(int client)
{
	if (IsPluginEnabled()) {
		CreateTimer(0.1, OFSLA_ForceMobSpawnTimer);
	}

	return Plugin_Continue;
}

public Action OFSLA_ForceMobSpawnTimer(Handle hTimer)
{
	//Workaround to make tank horde blocking always work
	//Makes the first horde always start 100s after survivors leave saferoom
	static ConVar hCvarMobSpawnTimeMin = null;
	static ConVar hCvarMobSpawnTimeMax = null;

	if (hCvarMobSpawnTimeMin == null) {
		hCvarMobSpawnTimeMin = FindConVar("z_mob_spawn_min_interval_normal");
		hCvarMobSpawnTimeMax = FindConVar("z_mob_spawn_max_interval_normal");
	}

	float fRand = GetRandomFloat(hCvarMobSpawnTimeMin.FloatValue, hCvarMobSpawnTimeMax.FloatValue);
	L4D2_CTimerStart(L4D2CT_MobSpawnTimer, fRand);

	return Plugin_Stop;
}
