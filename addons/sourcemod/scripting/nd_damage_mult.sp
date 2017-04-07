#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <nd_rounds>

#define WEAPON_NX300_DT -2147481592
#define WEAPON_RED_DT 64

#define STRUCT_ASSEMBLER "struct_assembler"

public Plugin myinfo = 
{
	name 		= "[ND] Damage Multiplers",
	author 		= "Stickz",
	description 	= "Creates new damage multiplers for better game balance",
	version 	= "dummy",
	url 		= "https://github.com/stickz/Redstone/"
};

/* Auto-Updater Support */
#define UPDATE_URL  "https://github.com/stickz/Redstone/raw/build/updater/nd_damage_mult/nd_damage_mult.txt"
#include "updater/standard.sp"

/* The convar mess starts here! */
#define CONFIG_VARS 3
enum
{
    	nx300_bunker_mult = 0,
    	red_bunker_mult,
	red_assembler_mult
}
ConVar g_Cvar[CONFIG_VARS];
float g_Float[CONFIG_VARS];

public void OnPluginStart()
{
	// Account for plugin late-loading
	if (ND_RoundStarted())
	{
		HookEntitiesDamaged();
		UpdateConVarCache();	
	}
		
	AddUpdaterLibrary(); //auto-updater
	
	CreatePluginConVars();
	HookConVarChanges();
	AutoExecConfig(true, "nd_damage_mult");
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (ND_RoundStarted() && StrEqual(classname, STRUCT_ASSEMBLER, true))
		SDKHook(entity, SDKHook_OnTakeDamage, ND_OnAssemblerDamaged);
}

public void ND_OnRoundStarted() {
	HookEntitiesDamaged();
	UpdateConVarCache();
}

void HookEntitiesDamaged()
{
	SDK_HookEntityDamaged("struct_command_bunker", ND_OnBunkerDamaged);
	SDK_HookEntityDamaged(STRUCT_ASSEMBLER, ND_OnAssemblerDamaged);
}

public Action ND_OnBunkerDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) 
{
	// If the damage type is flamethrower, reduce the total damage
	if (damagetype == WEAPON_NX300_DT)
		damage *= g_Float[nx300_bunker_mult];
	
	// If the damage type is a RED, increase the total damage
	else if (damagetype == WEAPON_RED_DT)
		damage *= g_Float[red_bunker_mult];
	
	//PrintToChatAll("The damage type is %d.", damagetype);
}

public Action ND_OnAssemblerDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) 
{
	// If the damage type is a RED, increase the total damage
	if (damagetype == WEAPON_RED_DT)
		damage *= g_Float[red_assembler_mult];
}

void SDK_HookEntityDamaged(const char[] classname, SDKHookCB callback)
{
        /* Find and hook when entities is damaged. */
	int loopEntity = INVALID_ENT_REFERENCE;
	while ((loopEntity = FindEntityByClassname(loopEntity, classname)) != INVALID_ENT_REFERENCE) {
		SDKHook(loopEntity, SDKHook_OnTakeDamage, callback);		
	}
}

/* The convar mess for controlling plugin settings on the fly */
void CreatePluginConVars()
{
	char convarName[CONFIG_VARS][] = {
		"sm_mult_bunker_nx300",
		"sm_mult_bunker_red",
		"sm_mult_assembler_red"
	};
	
	char convarDef[CONFIG_VARS][] = { "85", "120", "105" };
	
	char convarDesc[CONFIG_VARS][] = {
		"Percentage of normal damage nx300 does to bunker",
		"Percentage of normal damage REDs do to the bunker",
		"Percentage of normal damage REDs deal to assemblers"
	};
	
	for (int convar = 0; convar < CONFIG_VARS; convar++) {
		g_Cvar[convar] = CreateConVar(convarName[convar], convarDef[convar], convarDesc[convar]);	
	}
}

void UpdateConVarCache()
{
	for (int i = 0; i < CONFIG_VARS; i++)	{
		g_Float[i] = g_Cvar[i].FloatValue / 100.0;	
	}
}

void HookConVarChanges()
{
	for (int i = 0; i < CONFIG_VARS; i++)	{
		HookConVarChange(g_Cvar[i], OnConfigPercentChange);
	}
}

public void OnConfigPercentChange(ConVar convar, char[] oldValue, char[] newValue) {	
	UpdateConVarCache();
}
