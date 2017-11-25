#include <sourcemod>
#include <sdktools>
#include <nd_stocks>
#include <nd_rounds>
#include <nd_maps>
#include <nd_redstone>

#define TERTIARY_MODEL "models/rts_structures/rts_resource/rts_resource_tertiary.mdl"
#define VECTOR_SIZE 3
 
public Plugin myinfo =
{
    name = "[ND] Resource Spawner",
    author = "Xander, Stickz",
    description = "Add additional resource points to maps.",
    version = "dummy",
    url = "https://github.com/stickz/Redstone"
};

#define UPDATE_URL  "https://github.com/stickz/Redstone/raw/build/updater/nd_resource_spawner/nd_resource_spawner.txt"
#include "updater/standard.sp"

int resSpawnCount = 0;
bool tertsSpawned = false;

public void OnPluginStart()
{
	// Fire round start event if plugin loads late
	if (ND_RoundStarted())
		ND_OnRoundStarted();

	AddUpdaterLibrary(); //auto-updater
}

public void OnClientPutInServer(int client) {
	if (!tertsSpawned)
		CheckTertiarySpawns();
}

public void ND_OnRoundStarted()
{
	resSpawnCount = 0;
	tertsSpawned = false;
	CheckTertiarySpawns();
}

void CheckTertiarySpawns()
{
	char map_name[64];   
	GetCurrentMap(map_name, sizeof(map_name));
	
	// Will throw tag mismatch warning, it's okay
	if (ND_CustomMapEquals(map_name, ND_Submarine))
	{
		SpawnTertiaryPoint({987.0, -7562.0, 23.0});
		SpawnTertiaryPoint({-1483.0, 9135.0, 123.0});
	}
	
	else if (ND_CustomMapEquals(map_name, ND_MetroImp) && RED_OnTeamCount() >= 18)
	{
		SpawnTertiaryPoint({2620.0, 529.0, 5.0});
		SpawnTertiaryPoint({-2235.0, -3249.0, -85.0});
	}
	
	else if (ND_StockMapEquals(map_name, ND_Silo) && RED_OnTeamCount() >= 14)
	{
		SpawnTertiaryPoint({-3375.0, 1050.0, 2.0});
		SpawnTertiaryPoint({-36.0, -2000.0, 5.0});	
	}
	else
		tertsSpawned = true;
}

public void SpawnTertiaryPoint(float[VECTOR_SIZE] origin)
{
	int rt = CreateEntityByName("nd_info_tertiary_resource_point");
	int trigger = CreateEntityByName("nd_trigger_resource_point");
       
	SpawnResourcePoint("tertiary", TERTIARY_MODEL, rt, trigger, origin);
	tertsSpawned = true;
}

public void SpawnResourcePoint( const char[] type, const char[] model, int rt, int trigger, float[VECTOR_SIZE] origin)
{	
	char rt_name[32];
	char trigger_name[32];

	Format(rt_name, sizeof(rt_name), "%s-%i", type, resSpawnCount);
	Format(trigger_name, sizeof(trigger_name), "%s-%i-area", type, resSpawnCount);
		
	DispatchSpawn(rt);
	DispatchSpawn(trigger);
       
	ActivateEntity(rt);
	ActivateEntity(trigger);
       
	SetEntPropString(rt, Prop_Data, "m_iName", rt_name);
	SetEntPropString(trigger, Prop_Data, "m_iName", trigger_name);
       
	SetEntPropString(trigger, Prop_Data, "m_iszResourcePointName", rt_name);
	SetEntPropFloat(trigger, Prop_Data, "m_flCapTime", 5.0);
	SetEntProp(trigger, Prop_Data, "m_iButtonsToCap", 0);
	SetEntProp(trigger, Prop_Data, "m_iNumPlayersToCap", 1);
       
	SetEntProp(trigger, Prop_Send, "m_nSolidType", 2);
 
	SetEntityModel(rt, TERTIARY_MODEL);
	SetEntityModel(trigger, TERTIARY_MODEL); //will throw warning in game console; required and no model displayed for brush entity
       
	TeleportEntity(rt, origin, NULL_VECTOR, NULL_VECTOR);
	TeleportEntity(trigger, origin, NULL_VECTOR, NULL_VECTOR);
       
	float min_bounds[VECTOR_SIZE] = {-300.0, -300.0, -300.0};
	float max_bounds[VECTOR_SIZE] = {300.0, 300.0, 300.0};
	
	SetEntPropVector(trigger, Prop_Send, "m_vecMins", min_bounds);
	SetEntPropVector(trigger, Prop_Send, "m_vecMaxs", max_bounds);
	
	resSpawnCount++;
}