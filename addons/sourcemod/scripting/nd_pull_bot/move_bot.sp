#define fMaxDistance 300.0
#define RETRY_DELAY 8
#define INVALID_USERID 0

bool CanPullBot[MAXPLAYERS+1] = { true , ... };

void RegPullBotCommand() {
	RegConsoleCmd("sm_PullBot", Command_pull);
}

void ResetPullCooldowns() {
	for (int client = 1; client <= MaxClients; client++)
		CanPullBot[client] = true;
}

public Action Command_pull(client, args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;
		
	if (!CanPullBot[client])
	{
		PrintToChat(client, "Please try again in %s seconds.", NumberInEnglish(RETRY_DELAY));
		return Plugin_Handled;
	}

    	// Get the angle the player is looking
	float vecAngles[3];
	GetClientEyeAngles(client, vecAngles);
	
	// Get the location position the player is looking
	float vecOrigin[3];
	GetClientEyePosition(client, vecOrigin);	
	
	Handle hTrace = TR_TraceRayFilterEx(vecOrigin, vecAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if(TR_DidHit(hTrace)) 
	{
		//This is the first function i ever saw that anything comes before the handle
		float vecPos[3];
		TR_GetEndPosition(vecPos, hTrace);
		
		int target = TR_GetEntityIndex(hTrace);
		if (target > 0 && IsFakeClient(target)) 
		{
			if(GetVectorDistance(vecOrigin, vecPos) < fMaxDistance) 
			{
				TeleportEntity(target, vecOrigin, NULL_VECTOR, NULL_VECTOR);
				PrintToChat(client, "bot moved");
			}
			
			else
				PrintToChat(client, "bot too far");
		}
	}	
	CloseHandle(hTrace);
	
	// Create cooldown before the client can pull a bot again
	CanPullBot[client] = false;
	CreateTimer(float(RETRY_DELAY), PullBotCooldown, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Handled;
}

public Action PullBotCooldown(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == INVALID_USERID)
		return Plugin_Handled;
	
	CanPullBot[client] = true;	
	return Plugin_Continue;
}

public bool TraceEntityFilterPlayer(entity, contentsMask) {
 	return entity < MaxClients && IsFakeClient(entity);
}
