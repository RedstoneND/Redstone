#define COND_CLOACKED (1<<1)
#define COND_LOCKDOWN (1<<2)
#define NOT_CAPTURING -1

int EntIndexCaping[MAXPLAYERS+1] = { NOT_CAPTURING, ... };

void HookResourceEvents() {
	HookEvent("resource_start_capture", Event_ResourceStartCapture, EventHookMode_Post);
	HookEvent("resource_end_capture", Event_ResourceEndCapture, EventHookMode_Post);
	HookEvent("resource_captured", Event_ResourceCaptured, EventHookMode_Post);	
	HookEvent("resource_break_capture", Event_ResourceBreakCapture, EventHookMode_Post);	
}

public Action Event_ResourceStartCapture(Event event, const char[] name, bool dontBroadcast)
{
	int entindex = event.GetInt("entindex");
	int client = GetClientOfUserId(event.GetInt("userid"));
	EntIndexCaping[client] = entindex;	
}

public Action Event_ResourceEndCapture(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	//EntIndexCaping[client] = NOT_CAPTURING;
}

public Action Event_ResourceCaptured(Event event, const char[] name, bool dontBroadcast)
{
	int entindex = event.GetInt("entindex");
	RemoveCaptureStatus(entindex);
}

public Action Event_ResourceBreakCapture(Event event, const char[] name, bool dontBroadcast)
{
	int entindex = event.GetInt("entindex");
	CheckCloackStatus(entindex);
	RemoveCaptureStatus(entindex);
}

void CheckCloackStatus(int entity)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client) && EntIndexCaping[client] == entity)
		{
			if (GetEntProp(client, Prop_Send, "m_nPlayerCond") & COND_CLOACKED)
			{
				PrintMessage(client, "Stealth Capture");		
			}
			else if (GetEntProp(client, Prop_Send, "m_nPlayerCond") & COND_LOCKDOWN)
			{
				PrintMessage(client, "Lockdown Capture");
			}
		}
	}
}

void RemoveCaptureStatus(int entity)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (EntIndexCaping[client] == entity)
			EntIndexCaping[client] = NOT_CAPTURING;
	}
}
