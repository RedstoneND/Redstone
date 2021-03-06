#if defined _nd_entities_included
 #endinput
#endif
#define _nd_entities_included

#include <sdkhooks>

#define ENTITY_NOT_FOUND -1

native int ND_GetPrimeEntity();
native int ND_GetPlayerManagerEntity();
native int ND_GetTeamBunkerEntity(int team);
native void ND_UpdateEntityCache();

/** 
 * Retreives the bunker distance from a given position
 *
 * @param team		Team index of Bunker.
 * @param pos[3]	X,Y,Z vector position
 *
 * @return		The distance the vector is from the team's bunker
 */ 
stock float ND_GetBunkerDistance(int team, float pos[3]) 
{
	// Get the bunker entity based on the team
	int bunker = ND_GetTeamBunkerEntity(team);
	
	float bunkerPos[3]; // Get the position of the bunker
	GetEntPropVector(bunker, Prop_Send, "m_vecOrigin", bunkerPos);
	
	// Return distance between inputted and bunker position
	return GetVectorDistance(pos, bunkerPos);	
}

stock float ND_GetEntityBunkerDistance(int team, int entity)
{
	// Get the bunker entity based on the team
	int bunker = ND_GetTeamBunkerEntity(team);
	
	// Get the position of the bunker
	float bunkerPos[3];
	GetEntPropVector(bunker, Prop_Send, "m_vecOrigin", bunkerPos);
	
	// Get the position of the entity
	float entityPos[3]; 
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entityPos);

	// Return distance between entity and bunker position
	return GetVectorDistance(entityPos, bunkerPos);
}

/** 
 * Retreives the level of a given client index
 *
 * @param client		Client index.
 * @return			The level of the client or some value less than 2 (if not loaded)
 */ 
stock int ND_RetreiveLevel(int client) {
	return GetEntProp(ND_GetPlayerManagerEntity(), Prop_Send, "m_iPlayerRank", 1, client);
}

/** 
 * Retreives the current score of a given client index
 *
 * @param client		Client index.
 * @return			The score of the client.
 */ 
stock int ND_RetrieveScore(int client) {
	return GetEntProp(ND_GetPlayerManagerEntity(), Prop_Send, "m_iScore", 1, client);
}

/** 
 * Retreives the current squad of a given client index
 *
 * @param client		Client index.
 * @return			The squad of the client.
 */ 
stock int ND_RetreiveSquad(int client) {
	return GetEntProp(client, Prop_Send, "m_iSquad");
}

/** 
 * Retreives the building health of a given entity
 *
 * @param entity		entity index.
 * @return			The health of the building.
 */ 
stock int ND_GetBuildingHealth(int entity) {
 	return GetEntProp(entity, Prop_Send, "m_iHealth");
}

/** 
 * Retreives the resources left on prime before trickling
 *
 * @return			The resources left on prime
 */ 
stock int ND_GetPrimeResources() {
	return GetEntProp(ND_GetPrimeEntity(), Prop_Send, "m_iCurrentResources");
}
stock bool ND_GetPrimeDepleted() {
	return ND_GetPrimeResources() <= 0;
}


/** 
 * Retreives the owner of a resource point
 *
 * @return			return owner team or -1
 */ 
stock int ND_GetPrimeOwner() {
	return GetEntProp(ND_GetPrimeEntity(), Prop_Send, "m_iTeamNum"); 
}
stock int ND_GetResourceOwner(int entity) {
	return GetEntProp(entity, Prop_Send, "m_iTeamNum");
}

/** 
 * Sets the resources left on prime before trickling
 *
 * @param resources		resource amount.
 */ 
stock void ND_SetPrimeResources(int resources) {
	SetEntProp(ND_GetPrimeEntity(), Prop_Send, "m_iCurrentResources", resources);
}

stock void ND_SetCurrentResources(int entity, int resources) {
	SetEntProp(entity, Prop_Send, "m_iCurrentResources", resources);
}

stock void SDK_HookEntityDamaged(const char[] classname, SDKHookCB callback)
{
        /* Find and hook when entities is damaged. */
	int loopEntity = INVALID_ENT_REFERENCE;
	while ((loopEntity = FindEntityByClassname(loopEntity, classname)) != INVALID_ENT_REFERENCE) {
		SDKHook(loopEntity, SDKHook_OnTakeDamage, callback);		
	}
}

stock void SDK_UnHookEntityDamaged(const char[] classname, SDKHookCB callback)
{
	/* Find and unhook when entities are damaged. */
	int loopEntity = INVALID_ENT_REFERENCE;
	while ((loopEntity = FindEntityByClassname(loopEntity, classname)) != INVALID_ENT_REFERENCE) {
		SDKUnhook(loopEntity, SDKHook_OnTakeDamage, callback);		
	}
}
