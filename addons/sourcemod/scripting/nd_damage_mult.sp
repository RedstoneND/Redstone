#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <nd_print>
#include <nd_rounds>
#include <nd_struct_eng>
#include <nd_research_eng>

public Plugin myinfo = 
{
	name 		= "[ND] Damage Multiplers",
	author 		= "Stickz",
	description 	= "Creates new damage multiplers for better game balance",
	version 	= "recompile",
	url 		= "https://github.com/stickz/Redstone/"
};

/* Auto-Updater Support */
#define UPDATE_URL  "https://github.com/stickz/Redstone/raw/build/updater/nd_damage_mult/nd_damage_mult.txt"
#include "updater/standard.sp"

int InfantryBoostLevel[2] = { 0, ...};

/* Plugin Includes */
#include "nd_damage/convars.sp"
#include "nd_damage/damage_events.sp"

public void OnPluginStart()
{
	AddUpdaterLibrary(); //auto-updater
	
	CreatePluginConVars();
	HookConVarChanges();
	LoadTranslations("nd_damage_mult.phrases");
	//AutoExecConfig(true, "nd_damage_mult");
	
	// Account for plugin late-loading
	if (ND_RoundStarted())
	{
		HookEntitiesDamaged(true);
		UpdateConVarCache();	
	}
}

public void OnInfantryBoostResearched(int team, int level) 
{
	InfantryBoostLevel[team-2] = level;
	
	// Notify team the bbq damage has increased by three percent
	if (level == 1)
	{
		float percent = gFloat_Other[nx300_ib1_base_mult];
		int speed = RoundFloat((percent - 1.0) * 100.0);
		PrintMessageTeamTI1(team, "BBQ Damage Increase", speed);
	}
}

public void ND_OnStructureCreated(int entity, const char[] classname)
{
	if (ND_RoundStarted())
	{		
		if (StrEqual(classname, STRUCT_ASSEMBLER))
			SDKHook(entity, SDKHook_OnTakeDamage, ND_OnAssemblerDamaged);
		
		else if (StrEqual(classname, STRUCT_TRANSPORT))
			SDKHook(entity, SDKHook_OnTakeDamage, ND_OnTransportDamaged);

		else if (StrEqual(classname, STRUCT_ARTILLERY))
			SDKHook(entity, SDKHook_OnTakeDamage, ND_OnArtilleryDamaged);
		
		else if (StrEqual(classname, STRUCT_SONIC_TURRET) ||
				 StrEqual(classname, STRUCT_FT_TURRET))
			SDKHook(entity, SDKHook_OnTakeDamage, ND_OnFlamerTurretDamaged);
		
		else if (StrEqual(classname, STRUCT_POWER_STATION))
			SDKHook(entity, SDKHook_OnTakeDamage, ND_OnPowerPlantDamaged);
		
		else if (StrEqual(classname, STRUCT_ARMOURY))
			SDKHook(entity, SDKHook_OnTakeDamage, ND_OnArmouryDamaged);
		
		else if (StrEqual(classname, STRUCT_RADAR))
			SDKHook(entity, SDKHook_OnTakeDamage, ND_OnRadarDamaged);
		
		else if (StrEqual(classname, STRUCT_MG_TURRET))
			SDKHook(entity, SDKHook_OnTakeDamage, ND_OnMGTurretDamaged);
		
		else if (StrEqual(classname, STRUCT_ROCKET_TURRET))
			SDKHook(entity, SDKHook_OnTakeDamage, ND_OnRocketTurretDamaged);
		
		else if (StrEqual(classname, STRUCT_SUPPLY))
			SDKHook(entity, SDKHook_OnTakeDamage, ND_OnSupplyStationDamaged);
			
		else if (StrEqual(classname, STRUCT_WALL))
			SDKHook(entity, SDKHook_OnTakeDamage, ND_OnWallDamaged);
			
		else if (StrEqual(classname, STRUCT_BARRIER))
			SDKHook(entity, SDKHook_OnTakeDamage, ND_OnBarrierDamaged);
	}
}

public void ND_OnRoundStarted()
{
	ResetIBLevel();
	HookEntitiesDamaged();
	UpdateConVarCache();
}

public void ND_OnRoundEndedEX() {
	UnHookEntitiesDamaged();
	ResetIBLevel();
}

void ResetIBLevel() {
	InfantryBoostLevel[0] = 0;
	InfantryBoostLevel[1] = 0;
}

void HookEntitiesDamaged(bool lateLoad = false)
{
	SDK_HookEntityDamaged(STRUCT_BUNKER, ND_OnBunkerDamaged);
	SDK_HookEntityDamaged(STRUCT_ASSEMBLER, ND_OnAssemblerDamaged);
	SDK_HookEntityDamaged(STRUCT_TRANSPORT, ND_OnTransportDamaged);
	
	if (lateLoad) // Save interations by only checking for these when required
	{
		SDK_HookEntityDamaged(STRUCT_ARTILLERY, ND_OnArtilleryDamaged);
		
		// Flamethrower and sonic turrets on same event
		SDK_HookEntityDamaged(STRUCT_SONIC_TURRET, ND_OnFlamerTurretDamaged);
		SDK_HookEntityDamaged(STRUCT_FT_TURRET, ND_OnFlamerTurretDamaged);
		SDK_HookEntityDamaged(STRUCT_POWER_STATION, ND_OnPowerPlantDamaged);
		SDK_HookEntityDamaged(STRUCT_ARMOURY, ND_OnArmouryDamaged);
		SDK_HookEntityDamaged(STRUCT_RADAR, ND_OnRadarDamaged);
		SDK_HookEntityDamaged(STRUCT_MG_TURRET, ND_OnMGTurretDamaged);
		SDK_HookEntityDamaged(STRUCT_ROCKET_TURRET, ND_OnRocketTurretDamaged);
		SDK_HookEntityDamaged(STRUCT_SUPPLY, ND_OnSupplyStationDamaged);
		SDK_HookEntityDamaged(STRUCT_WALL, ND_OnWallDamaged);
		SDK_HookEntityDamaged(STRUCT_BARRIER, ND_OnBarrierDamaged);
	}
}

void UnHookEntitiesDamaged()
{
	SDK_UnHookEntityDamaged(STRUCT_BUNKER, ND_OnBunkerDamaged);
	SDK_UnHookEntityDamaged(STRUCT_ASSEMBLER, ND_OnAssemblerDamaged);
	SDK_UnHookEntityDamaged(STRUCT_TRANSPORT, ND_OnTransportDamaged);	
	SDK_UnHookEntityDamaged(STRUCT_ARTILLERY, ND_OnArtilleryDamaged);
	SDK_UnHookEntityDamaged(STRUCT_SONIC_TURRET, ND_OnFlamerTurretDamaged);
	SDK_UnHookEntityDamaged(STRUCT_FT_TURRET, ND_OnFlamerTurretDamaged);
	SDK_UnHookEntityDamaged(STRUCT_POWER_STATION, ND_OnPowerPlantDamaged);
	SDK_UnHookEntityDamaged(STRUCT_ARMOURY, ND_OnArmouryDamaged);
	SDK_UnHookEntityDamaged(STRUCT_RADAR, ND_OnRadarDamaged);
	SDK_UnHookEntityDamaged(STRUCT_MG_TURRET, ND_OnMGTurretDamaged);
	SDK_UnHookEntityDamaged(STRUCT_ROCKET_TURRET, ND_OnRocketTurretDamaged);
	SDK_UnHookEntityDamaged(STRUCT_SUPPLY, ND_OnSupplyStationDamaged);
	SDK_UnHookEntityDamaged(STRUCT_WALL, ND_OnWallDamaged);
	SDK_UnHookEntityDamaged(STRUCT_BARRIER, ND_OnBarrierDamaged);
}

void SDK_HookEntityDamaged(const char[] classname, SDKHookCB callback)
{
        /* Find and hook when entities is damaged. */
	int loopEntity = INVALID_ENT_REFERENCE;
	while ((loopEntity = FindEntityByClassname(loopEntity, classname)) != INVALID_ENT_REFERENCE) {
		SDKHook(loopEntity, SDKHook_OnTakeDamage, callback);		
	}
}

void SDK_UnHookEntityDamaged(const char[] classname, SDKHookCB callback)
{
	/* Find and unhook when entities are damaged. */
	int loopEntity = INVALID_ENT_REFERENCE;
	while ((loopEntity = FindEntityByClassname(loopEntity, classname)) != INVALID_ENT_REFERENCE) {
		SDKUnhook(loopEntity, SDKHook_OnTakeDamage, callback);		
	}
}
