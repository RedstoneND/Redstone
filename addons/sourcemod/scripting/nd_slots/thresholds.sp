int GetMapPlayerCount(const char[] checkMap)
{
	if (ND_IsLargeMap(checkMap))
		return GetSlotCount(26, 28, 30);
		
	else if	(ND_IsMediumMap(checkMap))
		return GetSlotCount(26, 28, 28);
		
	else if (ND_IsTinyMap(checkMap))
		return GetSlotCount(22, 26, 26);

	/* oasis, coast, hydro, roadwork */
	return GetSlotCount(24, 26, 28);
}

bool ND_IsLargeMap(const char[] checkMap)
{
	return ND_StockMapEquals(checkMap, ND_Oilfield)
		|| ND_CustomMapEquals(checkMap, ND_Rock)
		|| ND_StockMapEquals(checkMap, ND_Gate) 		
		|| ND_StockMapEquals(checkMap, ND_Downtown);
}

bool ND_IsMediumMap(const char[] checkMap)
{
	return ND_StockMapEquals(checkMap, ND_Clocktower)
		|| ND_CustomMapEquals(checkMap, ND_Nuclear)
		|| ND_CustomMapEquals(checkMap, ND_MetroImp)
		|| ND_StockMapEquals(checkMap, ND_Silo);
}

bool ND_IsTinyMap(const char[] checkMap)
{
	return ND_CustomMapEquals(checkMap, ND_Corner)
		|| ND_CustomMapEquals(checkMap, ND_Mars)
		|| ND_CustomMapEquals(checkMap, ND_Sandbrick)
		|| ND_CustomMapEquals(checkMap, ND_Port);	
}

int GetSlotCount(int min, int med, int max)
{
	if (!ND_GEA_AVAILBLE() || !eSkillBasedSlots())
		return max;	
		
	float avSkill = ND_GetEnhancedAverage();	
	return avSkill < g_Cvar[LowSkill].IntValue  ? max : avSkill < g_Cvar[HighSkill].IntValue ? med : min;
}

bool eSkillBasedSlots() {
	return ND_GetClientCount() > g_Cvar[MinPlayServerSlots].IntValue;
}
