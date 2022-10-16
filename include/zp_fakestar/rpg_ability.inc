
#if defined _rpg_ability_included_
  #endinput
#endif
#define _rpg_ability_included_

native any Ability_GetValue(int client, const char[] abilityName);
native void Ability_AddValue(int client, const char[] abilityName, any value);
native void Ability_Reset(int client, const char[] abilityName, any value);

forward void Ability_OnGetValue(int client, const char[] abilityName, any &value);
forward void Ability_OnResetValue(int client);

public SharedPlugin __pl_rpg_ability = 
{
	name = "rpg_ability",
	file = "rpg_ability.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_rpg_ability_SetNTVOptional()
{
	MarkNativeAsOptional("Ability_GetValue");
	MarkNativeAsOptional("Ability_AddValue");
	MarkNativeAsOptional("Ability_Reset");
}
#endif
