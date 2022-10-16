
#include <sourcemod>
#include <zp_fakestar/rpg_ability>
#include <zp_tools>

#define PLUGIN_CODENAME "Dollar Regen"
#define ABILITY_NAME "dollar_regen"
#define REGEN_TIME 3.0

public Plugin myinfo = 
{
	name = "Zeisen Project ★ RPG | Ability | "...PLUGIN_CODENAME,
	author = "Zeisen",
	description = "",
	url = "http://steamcommunity.com/profiles/76561198002384750"
}

Handle g_regenTimer;

public void OnPluginStart()
{
    HookEvent("round_start", OnRegenStopEvent);
    HookEvent("round_end", OnRegenStopEvent);

    HookEvent("round_freeze_end", OnRegenStartEvent);
}

void OnRegenStopEvent(Event event, const char[] name, bool dontBroadcast)
{
    ZT_ClearTimer(g_regenTimer);
}

void OnRegenStartEvent(Event event, const char[] name, bool dontBroadcast)
{
    ZT_ClearTimer(g_regenTimer);
    g_regenTimer = CreateTimer(REGEN_TIME, Timer_DollarRegen, _, TIMER_REPEAT);
}

Action Timer_DollarRegen(Handle timer)
{
    bool isFirstRound = ZT_GetTotalRounds() == 1;
    for (int client=1; client<=MaxClients; client++)
    {
        if (!IsClientInGame(client))
            continue;
        
        if (!IsPlayerAlive(client))
            continue;
        
        int regenVal = Ability_GetValue(client, ABILITY_NAME)
        if (isFirstRound)
            regenVal /= 3;
        
        if (regenVal != 0)
            ZT_AddCash(client, regenVal);
    }

    return Plugin_Continue;
}