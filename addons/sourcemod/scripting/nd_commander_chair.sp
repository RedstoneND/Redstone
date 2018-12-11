/*
This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

/* Auto-Updater Support */
#define UPDATE_URL  "https://github.com/stickz/Redstone/raw/build/updater/nd_commander_chair/nd_commander_chair.txt"
#include "updater/standard.sp"

#include <sourcemod>
#include <autoexecconfig>
#include <sdktools>
#include <nd_stocks>
#include <nd_com_eng>
#include <nd_redstone>
#include <nd_rounds>
#include <nd_print>

public Plugin myinfo =
{
	name = "[ND] Commander Chair",
	author = "Stickz",
	description = "Blocks entering chair until both team gets a commander",
	version = "dummy",
	url = "https://github.com/stickz/Redstone/"
}

ConVar cvarMinTeam;
ConVar cvarMinTotal;
ConVar cvarMaxRStart;
ConVar cvarMaxPromote;
ConVar cvarSelectMin;
ConVar cvarSelectMax;

bool ChairWaitRStartElapsed = false;
bool ChairWaitPromoteElapsed[2] = { false, ...};

Handle BunkerDelayTimer = INVALID_HANDLE;
Handle PromoteDelayTimer[2] = { INVALID_HANDLE, ...};

public void OnPluginStart()
{
	CreatePluginConvars(); // for convars	

	LoadTranslations("nd_common.phrases");
	LoadTranslations("nd_commander_chair.phrases");
	
	AddUpdaterLibrary(); //auto-updater
	
	// If the plugin loads late, disable the chair waiting
	bool rStart = ND_RoundStarted();	
	ToggleWaitPromote(rStart);
	ChairWaitRStartElapsed = rStart;
}

public void ND_OnPreRoundStart()
{
	// If we have enough players, set commander selection time to min; otherwise, set it to max.
	int selectTime = ChairBlockThresholdReached() ? cvarSelectMin.IntValue : cvarSelectMax.IntValue;
	ServerCommand("sm_cvar nd_commander_election_time %d", selectTime);
}

public void ND_OnRoundStarted() 
{
	ToggleWaitPromote(false);
	ChairWaitRStartElapsed = false;
	BunkerDelayTimer = CreateTimer(cvarMaxRStart.FloatValue, TIMER_EnterChairRStartDelay, _, TIMER_FLAG_NO_MAPCHANGE);
}

public void ND_OnRoundEnded() 
{
	if (BunkerDelayTimer != INVALID_HANDLE && IsValidHandle(BunkerDelayTimer))
		CloseHandle(BunkerDelayTimer);
	
	for (int h = 0; h < 2; h++) {
		if (PromoteDelayTimer[h] != INVALID_HANDLE && IsValidHandle(PromoteDelayTimer[h])) {
			CloseHandle(PromoteDelayTimer[h]);
		}
	}
}

public void ND_OnCommanderPromoted(int client, int team)
{
	PromoteDelayTimer[team-2] = CreateTimer(cvarMaxRStart.FloatValue, TIMER_EnterChairPromoteDelay, 
						GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public void ND_BothCommandersPromoted(int consort, int empire)
{
	// Show early chair unlock message
	if (!ChairWaitRStartElapsed)
		NotifyCommandersOfChairUnlock("Chair Unlocked");
}

public Action TIMER_EnterChairRStartDelay(Handle timer)
{
	ChairWaitRStartElapsed = true;
	
	// Show chair lock expire message, if commanders aren't selected in-time
	if (!ND_InitialCommandersReady(true))
		NotifyCommandersOfChairUnlock("May Enter Chair");
		
	return Plugin_Continue;
}

public Action TIMER_EnterChairPromoteDelay(Handle timer, any:userid)
{
	// Get client and check if userid is valid
	int client = GetClientOfUserId(userid);		
	if (client == INVALID_USERID)
		return Plugin_Handled;
	
	// Set the promote wait elapsed to true
	int team = GetClientTeam(client);
	ChairWaitPromoteElapsed[team-2] = true;
	
	// Show chair lock expire message, if commanders aren't selected in-time
	if (!ND_InitialCommandersReady(true) && ChairWaitRStartElapsed)
		PrintMessage(client, "May Enter Chair");
		
	return Plugin_Continue;
}

public Action ND_OnCommanderEnterChair(int client, int team)
{	
	if (!ND_InitialCommandersReady(true) && ChairBlockThresholdReached())
	{
		if (!ChairWaitRStartElapsed)
		{
			PrintMessageTI1(client, "Wait Enter Chair", cvarMaxRStart.IntValue);
			return Plugin_Handled;
		}
		else if (!ChairWaitPromoteElapsed[team-2])
		{
			PrintMessageTI1(client, "Wait Enter Chair", cvarMaxPromote.IntValue);
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

bool ChairBlockThresholdReached()
{
	return 	RED_OnTeamCount() >= cvarMinTeam.IntValue || 
		ND_GetClientCount() >= cvarMinTotal.IntValue;
}

void ToggleWaitPromote(bool value)
{
	ChairWaitPromoteElapsed[0] = value;
	ChairWaitPromoteElapsed[1] = value;
}

void NotifyCommandersOfChairUnlock(const char[] phrase)
{
	// Send may enter chair to empire commander, if availible
	int empireCommander = ND_GetCommanderOnTeam(TEAM_EMPIRE);
	if (empireCommander != -1)
		PrintMessage(empireCommander, phrase);
			
	// Send may enter chair to consort commander, if availible
	int consortCommander =  ND_GetCommanderOnTeam(TEAM_CONSORT);
	if (consortCommander != -1)
		PrintMessage(consortCommander, phrase);
}

void CreatePluginConvars()
{
	AutoExecConfig_Setup("nd_commander_chair");
	
	cvarMinTeam		=	AutoExecConfig_CreateConVar("sm_chair_block_team", "8", "Min number of players on a team required to block the command chair");
	cvarMinTotal		=	AutoExecConfig_CreateConVar("sm_chair_block_total", "12", "Min number of total players required to block the command chair");
	cvarMaxRStart		= 	AutoExecConfig_CreateConVar("sm_chair_max_rstart", "120", "How long to block chair after round start if nobody applies for commander?");
	cvarMaxPromote		= 	AutoExecConfig_CreateConVar("sm_chair_max_promote", "60", "How long to block chair after promotion if nobody applies for commander?");	
	cvarSelectMin		=	AutoExecConfig_CreateConVar("sm_chair_select_min", "15", "Duration to wait to select commanders, with chair blocking");
	cvarSelectMax		=	AutoExecConfig_CreateConVar("sm_chair_select_max", "30", "Duration to wait to select commanders, without chair blocks");
	
	AutoExecConfig_EC_File();
}
