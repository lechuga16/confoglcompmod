#if defined __bot_kick_included
	#endinput
#endif
#define __bot_kick_included

#define CHECKALLOWEDTIME			0.1
#define BOTREPLACEVALIDTIME			0.2

static int
	BK_iEnable = 0,
	BK_lastvalidbot = -1;

static ConVar
	BK_hEnable = null;

void BK_OnModuleStart()
{
	BK_hEnable = CreateConVarEx( \
		"blockinfectedbots", \
		"1", \
		"Blocks infected bots from joining the game, minus when a tank spawns (1 allows bots from tank spawns, 2 removes all infected bots)", \
		_, true, 0.0, true, 2.0 \
	);

	BK_iEnable = BK_hEnable.IntValue;
	BK_hEnable.AddChangeHook(BK_ConVarChange);

	HookEvent("player_bot_replace", BK_PlayerBotReplace);
}

public void BK_ConVarChange(ConVar hConVar, const char sOldValue, const char[] sNewValue)
{
	BK_iEnable = BK_hEnable.IntValue;
}

public bool OnClientConnect(int iClient, char[] sRejectMsg, int iMaxlen)
{
	if (BK_iEnable == 0 || !IsPluginEnabled() || !IsFakeClient(iClient)) { // If the BK_iEnable is false, we don't do anything
		return true;
	}

	char name[11];
	GetClientName(iClient, name, sizeof(name));

	// If the client doesn't have a bot infected's name, let it in
	if (StrContains(name, "smoker", false) == -1
		&& StrContains(name, "boomer", false) == -1
		&& StrContains(name, "hunter", false) == -1
		&& StrContains(name, "spitter", false) == -1
		&& StrContains(name, "jockey", false) == -1
		&& StrContains(name, "charger", false) == -1)
	{
		return true;
	}

	if (BK_iEnable == 1 && IsTankInPlay()) { // Bots only allowed to try to connect when there's a tank in play.
		// Check this bot in CHECKALLOWEDTIME seconds to see if he's supposed to be allowed.
		CreateTimer(CHECKALLOWEDTIME, BK_CheckInfBotReplace_Timer, iClient, TIMER_FLAG_NO_MAPCHANGE);
		//BK_bAllowBot = false;
		return true;
	}

	KickClient(iClient, "[Confogl] Kicking infected bot..."); // If all else fails, bots arent allowed and must be kicked

	return false;
}

public Action BK_CheckInfBotReplace_Timer(Handle hTimer, any iClient)
{
	if (iClient != BK_lastvalidbot && IsClientInGame(iClient) && IsFakeClient(iClient)) {
		KickClient(iClient, "[Confogl] Kicking late infected bot...");
	} else {
		BK_lastvalidbot = -1;
	}

	return Plugin_Stop;
}

public void BK_PlayerBotReplace(Event hEvent, const char[] sEventName, bool bDontBroadcast)
{
	if (!IsTankInPlay()) {
		return;
	}

	int iClient = GetClientOfUserId(hEvent.GetInt("player"));

	if (iClient > 0 && IsClientInGame(iClient) && GetClientTeam(iClient) == TEAM_INFECTED) {
		BK_lastvalidbot = GetClientOfUserId(hEvent.GetInt("bot"));
		CreateTimer(BOTREPLACEVALIDTIME, BK_CancelValidBot_Timer, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action BK_CancelValidBot_Timer(Handle hTimer)
{
	BK_lastvalidbot = -1;

	return Plugin_Stop;
}
