#pragma semicolon 1

#if defined(AUTOVERSION)
#include "version.inc"
#else
#define PLUGIN_VERSION	"2.2.6.6"
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

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RM_APL();
	Configs_APL();
	MI_APL();

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
	
	AddCustomServerTag("confogl", true);
}

public void OnPluginEnd()
{
	CVS_OnModuleEnd();
	PS_OnModuleEnd();
	ER_OnModuleEnd();
	SM_OnModuleEnd();
	
	WS_OnModuleEnd();
	RemoveCustomServerTag("confogl");
}

public void OnGameFrame()
{
	WS_OnGameFrame();
}

public void OnMapStart()
{
	MI_OnMapStart();
	RM_OnMapStart();
	
	SM_OnMapStart();
	BS_OnMapStart();
	IT_OnMapStart();
}

public void OnMapEnd()
{
	MI_OnMapEnd();
	WI_OnMapEnd();
	
	PS_OnMapEnd();
	WS_OnMapEnd();
}

public void OnConfigsExecuted()
{
	CVS_OnConfigsExecuted();
}

public void OnClientDisconnect(int client)
{
	RM_OnClientDisconnect(client);
}

public void OnClientPutInServer(int client)
{
	RM_OnClientPutInServer();
	UL_OnClientPutInServer();
	PS_OnClientPutInServer(client);
	FS_OnOnClientPutInServer(client);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, \
									int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (GW_OnPlayerRunCmd(client, buttons)) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action L4D_OnCThrowActivate(int iAbility)
{
	//Modules
	if (GT_OnCThrowActivate() == Plugin_Handled) {//GhostTank
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action L4D_OnSpawnTank(const float vector[3], const float qangle[3])
{
	if (GT_OnTankSpawn_Forward() == Plugin_Handled) {
		return Plugin_Handled;
	}

	BS_OnTankSpawn_Forward();
	return Plugin_Continue;
}

public Action L4D_OnSpawnMob(int &amount)
{
	if (GT_OnSpawnMob_Forward(amount) == Plugin_Handled) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action L4D_OnTryOfferingTankBot(int tank_index, bool &enterStasis)
{
	if (GT_OnTryOfferingTankBot(enterStasis) == Plugin_Handled) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action L4D_OnGetMissionVSBossSpawning(float &spawn_pos_min, float &spawn_pos_max, float &tank_chance, float &witch_chance)
{
	if (UB_OnGetMissionVSBossSpawning() == Plugin_Handled) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action L4D_OnGetScriptValueInt(const char[] key, int &retVal)
{
	if (UB_OnGetScriptValueInt(key, retVal) == Plugin_Handled) {
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
	// Workaround to make tank horde blocking always work
	// Makes the first horde always start 100s after survivors leave saferoom
	static ConVar MobSpawnTimeMin = null;
	static ConVar MobSpawnTimeMax = null;

	if (MobSpawnTimeMin == null) {
		MobSpawnTimeMin = FindConVar("z_mob_spawn_min_interval_normal");
		MobSpawnTimeMax = FindConVar("z_mob_spawn_max_interval_normal");
	}

	L4D2_CTimerStart(L4D2CT_MobSpawnTimer, GetRandomFloat(GetConVarFloat(MobSpawnTimeMin), GetConVarFloat(MobSpawnTimeMax)));
	return Plugin_Stop;
}
