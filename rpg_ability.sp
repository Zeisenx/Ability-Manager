
#include <sourcemod>

Handle g_fwOnGetValue, g_fwOnResetValue;

methodmap Ability < StringMap
{
    public Ability(int owner)
    {
        StringMap map = new StringMap();
        map.SetValue("owner", owner);
        return view_as<Ability>(map);
    }

    property int owner
    {
        public get()
        {
            int owner;
            this.GetValue("owner", owner);

            return owner;
        }
    }

    public any GetAbility(const char[] name)
    {
        any value;
        this.GetValue(name, value);

        Call_StartForward(g_fwOnGetValue);
        Call_PushCell(this.owner);
        Call_PushString(name);
        Call_PushCellRef(value);
        Call_Finish();

        return value;
    }

    public any AddAbility(const char[] name, any addValue)
    {
        any value = this.GetAbility(name);
        value += addValue;
        this.SetValue(name, value);
        return value;
    }

    public void Store()
    {
        int owner = this.owner;

        this.Clear();

        this.SetValue("owner", owner);
        Call_StartForward(g_fwOnResetValue);
        Call_PushCell(this.owner);
        Call_Finish();
    }
}
Ability g_abilityData[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    RegPluginLibrary("rpg_ability");

    g_fwOnGetValue = CreateGlobalForward("Ability_OnGetValue", ET_Ignore, Param_Cell, Param_String, Param_CellByRef);
    g_fwOnResetValue = CreateGlobalForward("Ability_OnResetValue", ET_Ignore, Param_Cell);

    CreateNative("Ability_GetValue", Native_GetValue);
    CreateNative("Ability_AddValue", Native_AddValue);

    CreateNative("Ability_Reset", Native_Reset);

    return APLRes_Success;
}

public void OnPluginStart()
{
    HookEvent("player_spawn", OnPlayerSpawnPre, EventHookMode_Pre);
}

public void OnPlayerSpawnPre(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (g_abilityData[client] != null)
        g_abilityData[client].Store();
}

public void OnClientPutInServer(int client)
{
    if (g_abilityData[client] == null)
        g_abilityData[client] = new Ability(client);

    g_abilityData[client].Store();
}

public int Native_Reset(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);

    g_abilityData[client].Store();

    return 0;
}

public int Native_GetValue(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    char abilityName[64];
    GetNativeString(2, abilityName, sizeof(abilityName));

    return view_as<int>(g_abilityData[client].GetAbility(abilityName));
}

public int Native_AddValue(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    char abilityName[64];
    GetNativeString(2, abilityName, sizeof(abilityName));
    float value = GetNativeCell(3);

    g_abilityData[client].AddAbility(abilityName, value);

    return 0;
}