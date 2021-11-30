#if defined __unreserve_lobby_included
	#endinput
#endif
#define __unreserve_lobby_included

new Handle:UL_hEnable;

UL_OnModuleStart()
{
	UL_hEnable	= CreateConVarEx("match_killlobbyres", "1", "Sets whether the plugin will clear lobby reservation once a match have begun");

	RegAdminCmd("sm_killlobbyres", UL_KillLobbyRes, ADMFLAG_BAN, "Forces the plugin to kill lobby reservation");
}

UL_OnClientPutInServer()
{
	if(!IsPluginEnabled() || !GetConVarBool(UL_hEnable)){return;}
	
	L4D_LobbyUnreserve();
}

public Action:UL_KillLobbyRes(client,args)
{
	L4D_LobbyUnreserve();

	return Plugin_Handled;
}
