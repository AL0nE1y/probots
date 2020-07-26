#pragma semicolon 1

#include <sourcemod>
#include <clientprefs>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>

char g_saGrenadeWeaponNames[][] = {
    "weapon_flashbang",
    "weapon_molotov",
    "weapon_smokegrenade",
    "weapon_hegrenade",
    "weapon_decoy",
    "weapon_incgrenade"
};

int g_iaGrenadeOffsets[sizeof(g_saGrenadeWeaponNames)];

bool g_bFlashed[MAXPLAYERS + 1] = false;
bool g_bFreezetimeEnd = false;
ConVar g_cvPredictionConVars[1] = {null};
ConVar g_cvFFA;
ConVar g_cvAimBotEnable;
 
public Plugin myinfo =
{
};

public void OnPluginStart()
{
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Post);
	HookEvent("round_start", OnRoundStart);
	HookEvent("round_freeze_end", OnFreezetimeEnd);
	HookEventEx("player_blind", Event_PlayerBlind, EventHookMode_Pre);
	
	g_cvPredictionConVars[0] = FindConVar("weapon_recoil_scale");
	g_cvFFA = FindConVar("mp_teammates_are_enemies");
	g_cvAimBotEnable = CreateConVar("bot_aimlock", "1", "1 = Enable Bot Aimlock , 0 = Disable Bot Aimlock", _, true, 0.0, true, 1.0);
}

public void OnMapStart()
{
	CreateTimer(1.0, Timer_CheckPlayer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public void OnRoundStart(Handle event, char[] name, bool dbc)
{
	g_bFreezetimeEnd = false;
}

public void OnFreezetimeEnd(Handle event, char[] name, bool dbc)
{
	g_bFreezetimeEnd = true;
}

public Action CS_OnBuyCommand(int client, const char[] weapon)
{
	if(IsValidClient(client) && IsFakeClient(client))
	{	
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) != -1)
		{
			SetEntProp(client, Prop_Send, "m_bInBuyZone", 0);
			return Plugin_Continue;
		}
	
		int m_iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
		if(StrEqual(weapon,"m4a1"))
		{ 
			int iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			
			if ((GetRandomInt(1,100) <= 40) && (m_iAccount >= 2900))
			{
				if (iWeapon != -1)
				{
					FakeClientCommandEx(client, "slot1");
					FakeClientCommandEx(client, "drop");
				}
				
				m_iAccount -= 2900;
				GivePlayerItem(client, "weapon_m4a1_silencer");
				SetClientMoney(client, m_iAccount);
				return Plugin_Handled; 
			}
			else if ((GetRandomInt(1,100) <= 20) && (m_iAccount >= 3300))
			{
				if (iWeapon != -1)
				{
					FakeClientCommandEx(client, "slot1");
					FakeClientCommandEx(client, "drop");
				}
				
				m_iAccount -= 3300;
				GivePlayerItem(client, "weapon_aug");
				SetClientMoney(client, m_iAccount);
				return Plugin_Handled; 
			}
			else
			{
				return Plugin_Continue;
			}
		}
		else if(StrEqual(weapon,"ak47"))
		{
			int iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			
			if ((GetRandomInt(1,100) <= 10) && (m_iAccount >= 3000))
			{
				if (iWeapon != -1)
				{
					FakeClientCommandEx(client, "slot1");
					FakeClientCommandEx(client, "drop");
				}
				
				m_iAccount -= 3000;
				GivePlayerItem(client, "weapon_sg556");
				SetClientMoney(client, m_iAccount);
				return Plugin_Handled; 
			}
		}
		else if(StrEqual(weapon,"mac10"))
		{
			int iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			
			if ((GetRandomInt(1,100) <= 30) && (m_iAccount >= 1800))
			{
				if (iWeapon != -1)
				{
					FakeClientCommandEx(client, "slot1");
					FakeClientCommandEx(client, "drop");
				}
				
				m_iAccount -= 1800;
				GivePlayerItem(client, "weapon_galilar");
				SetClientMoney(client, m_iAccount);
				return Plugin_Handled; 
			}
			else
			{
				return Plugin_Continue;
			}
		}
		else if(StrEqual(weapon,"mp9"))
		{
			int iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			
			if ((GetRandomInt(1,100) <= 30) && (m_iAccount >= 2050))
			{
				if (iWeapon != -1)
				{
					FakeClientCommandEx(client, "slot1");
					FakeClientCommandEx(client, "drop");
				}
				
				m_iAccount -= 2050;
				GivePlayerItem(client, "weapon_famas");
				SetClientMoney(client, m_iAccount);
				return Plugin_Handled; 
			}
			else
			{
				return Plugin_Continue;
			}
		}
		else if(StrEqual(weapon,"mp7"))
		{
			int iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			
			if ((GetRandomInt(1,100) <= 50) && (m_iAccount >= 1500))
			{
				if (iWeapon != -1)
				{
					FakeClientCommandEx(client, "slot1");
					FakeClientCommandEx(client, "drop");
				}
				
				m_iAccount -= 1500;
				GivePlayerItem(client, "weapon_mp5sd");
				SetClientMoney(client, m_iAccount);
				return Plugin_Handled; 
			}
			else
			{
				return Plugin_Continue;
			}
		}
		else
		{
			return Plugin_Continue;
		}
	}
	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{  
	if (!IsFakeClient(client)) return Plugin_Continue;
	
	int ActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"); 
	if (ActiveWeapon == -1)  return Plugin_Continue;
	
	int index = GetEntProp(ActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");
	
	if(IsValidClient(client) && IsPlayerAlive(client))
	{
		float clientEyes[3], targetEyes[3], targetEyes2[3];
		GetClientEyePosition(client, clientEyes);
		int Ent = GetClosestClient(client);
		
		int iClipAmmo = GetEntProp(ActiveWeapon, Prop_Send, "m_iClip1");
		if (iClipAmmo > 0 && g_bFreezetimeEnd)
		{
			if(IsValidClient(Ent))
			{
				GetClientAbsOrigin(Ent, targetEyes);
				GetClientEyePosition(Ent, targetEyes2);
				
				if (g_cvAimBotEnable.IntValue == 1)
				{
					if((IsWeaponSlotActive(client, CS_SLOT_PRIMARY) && index != 40 && index != 11 && index != 38 && index != 9) || index == 63)
					{
						if(GetRandomInt(1,3) == 1)
						{
							targetEyes[2] = targetEyes2[2];
						}
						else
						{
							targetEyes[2] = targetEyes2[2] - GetRandomFloat(10.5, 17.5);
						}
						
						buttons |= IN_ATTACK;
					}
					else if(buttons & IN_ATTACK && IsWeaponSlotActive(client, CS_SLOT_SECONDARY) && index != 63 && index != 1)
					{
						if(GetRandomInt(1,3) == 1)
						{
							targetEyes[2] = targetEyes2[2];
						}
						else
						{
							targetEyes[2] = targetEyes2[2] - GetRandomFloat(10.5, 17.5);
						}
					}
					else if(buttons & IN_ATTACK && index == 1)
					{
						targetEyes[2] = targetEyes2[2];
					}
					else if(buttons & IN_ATTACK && (index == 40 || index == 11 || index == 38))
					{
						if(GetRandomInt(1,3) == 1)
						{
							targetEyes[2] = targetEyes2[2];
						}
						else
						{
							targetEyes[2] = targetEyes2[2] - GetRandomFloat(10.5, 17.5);
						}
					}	
				}
				
				if(buttons & IN_ATTACK && IsWeaponSlotActive(client, CS_SLOT_GRENADE))
				{
					targetEyes[2] = targetEyes2[2] - GetRandomFloat(35.5, 45.5);
					buttons &= ~IN_ATTACK; 
				}
				else if(buttons & IN_ATTACK && index == 9)
				{
					targetEyes[2] = targetEyes2[2] - 10.5;
				}
				else
				{
					return Plugin_Continue;
				}
				
				float fTargetAngles[3]; float fFinalPos[3];
				
				GetClientEyeAngles(Ent, fTargetAngles);
				
				float fVecFinal[3];
				AddInFrontOf(targetEyes, fTargetAngles, 7.0, fVecFinal);
				MakeVectorFromPoints(clientEyes, fVecFinal, fFinalPos);
				
				GetVectorAngles(fFinalPos, fFinalPos);
				
				float vecPunchAngle[3];
	
				if (GetEngineVersion() == Engine_CSGO || GetEngineVersion() == Engine_CSS)
				{
					GetEntPropVector(client, Prop_Send, "m_aimPunchAngle", vecPunchAngle);
				}
				else
				{
					GetEntPropVector(client, Prop_Send, "m_vecPunchAngle", vecPunchAngle);
				}
				
				if(g_cvPredictionConVars[0] != null)
				{
					fFinalPos[0] -= vecPunchAngle[0] * GetConVarFloat(g_cvPredictionConVars[0]);
					fFinalPos[1] -= vecPunchAngle[1] * GetConVarFloat(g_cvPredictionConVars[0]);
				}
				
				TeleportEntity(client, NULL_VECTOR, fFinalPos, NULL_VECTOR);
				
				if (buttons & IN_ATTACK)
				{
					if(index == 7 || index == 8 || index == 10 || index == 13 || index == 14 || index == 16 || index == 39 || index == 60 || index == 28)
					{
						buttons |= IN_DUCK;
						return Plugin_Changed;
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

public Action Timer_CheckPlayer(Handle Timer, any data)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsFakeClient(i))
		{
			int m_iAccount = GetEntProp(i, Prop_Send, "m_iAccount");
			
			if(GetRandomInt(1,100) <= 5)
			{
				FakeClientCommand(i, "+lookatweapon");
				FakeClientCommand(i, "-lookatweapon");
			}
			if ((m_iAccount >= 650) && (GetEntProp(i, Prop_Data, "m_ArmorValue") == 0))
			{
				SetEntProp(i, Prop_Data, "m_ArmorValue", 100, 1); 
				m_iAccount -= 650;
				SetClientMoney(i, m_iAccount);
			}
		}
	}	
}

public void OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast) 
{
	for (int i = 1; i <= MaxClients; i++)
	{		
		if (!i) return;
		
		if(IsValidClient(i) && IsFakeClient(i))
		{
			CreateTimer(0.5, RFrame_CheckBuyZoneValue, GetClientSerial(i)); 
			
			if(GetRandomInt(1,100) >= 10)
			{
				if(GetClientTeam(i) == CS_TEAM_CT)
				{
					char usp[32];
					
					GetClientWeapon(i, usp, sizeof(usp));

					if(StrEqual(usp, "weapon_hkp2000"))
					{
						CSGO_ReplaceWeapon(i, CS_SLOT_SECONDARY, "weapon_usp_silencer");
					}
				}
			}
		}
	}
}

public Action RFrame_CheckBuyZoneValue(Handle timer, int serial) 
{
	int client = GetClientFromSerial(serial);

	if (!client || !IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;
	int team = GetClientTeam(client);
	if (team < 2) return Plugin_Stop;

	int m_iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
	
	bool m_bInBuyZone = view_as<bool>(GetEntProp(client, Prop_Send, "m_bInBuyZone"));
	
	if (!m_bInBuyZone) return Plugin_Stop;
	
	int iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	int iPrimary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
	char default_primary[64];
	GetClientWeapon(client, default_primary, sizeof(default_primary));

	if (((m_iAccount >= 1100) && (m_iAccount < 3000) && iPrimary == -1 && (StrEqual(default_primary, "weapon_hkp2000") || StrEqual(default_primary, "weapon_usp_silencer") || StrEqual(default_primary, "weapon_glock")))) 
	{
		if (iWeapon != -1)
				{
					FakeClientCommand(client, "slot2");
					FakeClientCommand(client, "drop");
				}
		
		int rndpistol = GetRandomInt(1,3);
		
		switch(rndpistol)
		{
			case 1:
			{
				if (m_iAccount >= 300) 
				{
					m_iAccount -= 300;
					GivePlayerItem(client, "weapon_p250");
					SetClientMoney(client, m_iAccount);
				}
			}
			case 2:
			{
				if(team == CS_TEAM_CT)
				{
					int ctcz = GetRandomInt(1,2);
					
					switch(ctcz)
					{
						case 1:
						{	if (m_iAccount >= 500) 
							{
								m_iAccount -= 500;
								GivePlayerItem(client, "weapon_fiveseven");
								SetClientMoney(client, m_iAccount);
							}
						}
						case 2:
						{
							if (m_iAccount >= 500) 
							{
								m_iAccount -= 500;
								GivePlayerItem(client, "weapon_cz75a");
								SetClientMoney(client, m_iAccount);
							}
						}
					}
				}
				else if(team == CS_TEAM_T)
				{
					int tcz = GetRandomInt(1,2);
					
					switch(tcz)
					{
						case 1:
						{	if (m_iAccount >= 500) 
							{
								m_iAccount -= 500;
								GivePlayerItem(client, "weapon_tec9");
								SetClientMoney(client, m_iAccount);
							}
						}
						case 2:
						{
							if (m_iAccount >= 500) 
							{
								m_iAccount -= 500;
								GivePlayerItem(client, "weapon_cz75a");
								SetClientMoney(client, m_iAccount);
							}
						}
					}
				}
			}
			case 3:
			{
				if (m_iAccount >= 700) 
				{
					m_iAccount -= 700;
					GivePlayerItem(client, "weapon_deagle");
					SetClientMoney(client, m_iAccount);
				}
			}
		}
	}
	if (m_iAccount >= 3000 || iPrimary != -1) 
	{
		m_iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
		if (((GetEntProp(client, Prop_Data, "m_ArmorValue") < 30) || (GetEntProp(client, Prop_Send, "m_bHasHelmet") == 0)) && (m_iAccount >= 1000))
		{
			SetEntProp(client, Prop_Data, "m_ArmorValue", 100, 1); 
			SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
			
			m_iAccount -= 1000;
			SetClientMoney(client, m_iAccount);
		}
		m_iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
		if (team == CS_TEAM_T) 
		{ 
			if ((m_iAccount >= 200) && (GetEntProp(client, Prop_Send, "m_iAmmo", _, g_iaGrenadeOffsets[0]) == 0))
			{
				m_iAccount -= 200;
				GivePlayerItem(client, "weapon_flashbang");
				SetClientMoney(client, m_iAccount);
			}
			if ((m_iAccount >= 300) && (GetEntProp(client, Prop_Send, "m_iAmmo", _, g_iaGrenadeOffsets[2]) == 0))
			{
				m_iAccount -= 300;
				GivePlayerItem(client, "weapon_smokegrenade");
				SetClientMoney(client, m_iAccount);
			}
			if ((m_iAccount >= 300) && (GetEntProp(client, Prop_Send, "m_iAmmo", _, g_iaGrenadeOffsets[3]) == 0))
			{
				m_iAccount -= 300;
				GivePlayerItem(client, "weapon_hegrenade");
				SetClientMoney(client, m_iAccount);
			}
			if ((m_iAccount >= 400) && (GetEntProp(client, Prop_Send, "m_iAmmo", _, g_iaGrenadeOffsets[1]) == 0))
			{
				m_iAccount -= 400;
				GivePlayerItem(client, "weapon_incgrenade");
				SetClientMoney(client, m_iAccount);
			}
		}
		else 
		{ 
			if ((m_iAccount >= 1000) && (GetEntProp(client, Prop_Send, "m_bHasDefuser") == 0))
			{
				m_iAccount -= 400;
				SetEntProp(client, Prop_Send, "m_bHasDefuser", 1); 
				SetClientMoney(client, m_iAccount);
			}
			if ((m_iAccount >= 200) && (GetEntProp(client, Prop_Send, "m_iAmmo", _, g_iaGrenadeOffsets[0]) == 0))
			{
				m_iAccount -= 200;
				GivePlayerItem(client, "weapon_flashbang");
				SetClientMoney(client, m_iAccount);
			}
			if ((m_iAccount >= 300) && (GetEntProp(client, Prop_Send, "m_iAmmo", _, g_iaGrenadeOffsets[2]) == 0))
			{
				m_iAccount -= 300;
				GivePlayerItem(client, "weapon_smokegrenade");
				SetClientMoney(client, m_iAccount);
			}
			if ((m_iAccount >= 300) && (GetEntProp(client, Prop_Send, "m_iAmmo", _, g_iaGrenadeOffsets[3]) == 0))
			{
				m_iAccount -= 300;
				GivePlayerItem(client, "weapon_hegrenade");
				SetClientMoney(client, m_iAccount);
			}
			if ((m_iAccount >= 600) && (GetEntProp(client, Prop_Send, "m_iAmmo", _, g_iaGrenadeOffsets[5]) == 0))
			{
				m_iAccount -= 600;
				GivePlayerItem(client, "weapon_incgrenade");
				SetClientMoney(client, m_iAccount);
			}
		}
	}
	/*
	m_iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
	if ((m_iAccount >= 8000 || iPrimary != -1) && (givegun[client] == false))
	{
		int rndrifle = GetRandomInt(1,3);
		
		switch(rndrifle)
		{
			case 1:
			{
				if(team == CS_TEAM_CT)
				{
					if (m_iAccount >= 3300) 
							{
								m_iAccount -= 3300;
								GivePlayerItem(client, "weapon_aug");
								SetClientMoney(client, m_iAccount);
								givegun[client] = true;
							}
				}
				else if(team == CS_TEAM_T)
				{
					if (m_iAccount >= 3000) 
							{
								m_iAccount -= 3000;
								GivePlayerItem(client, "weapon_sg556");
								SetClientMoney(client, m_iAccount);
								givegun[client] = true;
							}
				}
			}
			case 2:
			{
				if(team == CS_TEAM_CT)
				{
					int ctrf = GetRandomInt(1,2);
					
					switch(ctrf)
					{
						case 1:
						{	if (m_iAccount >= 3100) 
							{
								m_iAccount -= 3100;
								GivePlayerItem(client, "weapon_m4a1");
								SetClientMoney(client, m_iAccount);
								givegun[client] = true;
							}
						}
						case 2:
						{
							if (m_iAccount >= 2900) 
							{
								m_iAccount -= 2900;
								GivePlayerItem(client, "weapon_m4a1_silencer");
								SetClientMoney(client, m_iAccount);
								givegun[client] = true;
							}
						}
					}
				}
				else if(team == CS_TEAM_T)
				{
					if (m_iAccount >= 2700) 
							{
								m_iAccount -= 2700;
								GivePlayerItem(client, "weapon_ak47");
								SetClientMoney(client, m_iAccount);
								givegun[client] = true;
							}
				}
			}
			case 3:
			{
				if(team == CS_TEAM_CT)
				{
					if (m_iAccount >= 2050) 
							{
								m_iAccount -= 2050;
								GivePlayerItem(client, "weapon_famas");
								SetClientMoney(client, m_iAccount);
								givegun[client] = true;
							}
				}
				else if(team == CS_TEAM_T)
				{
					if (m_iAccount >= 1800) 
							{
								m_iAccount -= 1800;
								GivePlayerItem(client, "weapon_galilar");
								SetClientMoney(client, m_iAccount);
								givegun[client] = true;
							}
				}
			}
		}
	}
	*/
	return Plugin_Stop;
}

public Action Event_PlayerBlind(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(IsValidClient(client) && IsFakeClient(client))
	{
		if (GetEntPropFloat(client, Prop_Send, "m_flFlashMaxAlpha") >= 180.0)
		{
			float duration = GetEntPropFloat(client, Prop_Send, "m_flFlashDuration");
			if (duration >= 1.5)
			{
				g_bFlashed[client] = true;
				CreateTimer(duration, UnFlashed_Timer, client);
			}
		}
	}
}

public Action UnFlashed_Timer(Handle timer, int client)
{
	g_bFlashed[client] = false;
}

public void SetClientMoney(int client, int money)
{
	SetEntProp(client, Prop_Send, "m_iAccount", money);
	
	int moneyEntity = CreateEntityByName("game_money");
	
	DispatchKeyValue(moneyEntity, "Award Text", "");
	
	DispatchSpawn(moneyEntity);
	
	AcceptEntityInput(moneyEntity, "SetMoneyAmount 0");

	AcceptEntityInput(moneyEntity, "AddMoneyPlayer", client);
	
	AcceptEntityInput(moneyEntity, "Kill");
}

stock void CSGO_SetMoney(int client, int amount)
{
	if (amount < 0)
		amount = 0;
	
	int max = FindConVar("mp_maxmoney").IntValue;
	
	if (amount > max)
		amount = max;
	
	SetEntProp(client, Prop_Send, "m_iAccount", amount);
}

stock int CSGO_ReplaceWeapon(int client, int slot, const char[] class)
{
	int weapon = GetPlayerWeaponSlot(client, slot);

	if (IsValidEntity(weapon))
	{
		if (GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity") != client)
			SetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity", client);

		CS_DropWeapon(client, weapon, false, true);
		AcceptEntityInput(weapon, "Kill");
	}

	weapon = GivePlayerItem(client, class);

	if (IsValidEntity(weapon))
		EquipPlayerWeapon(client, weapon);

	return weapon;
}

stock bool IsWeaponSlotActive(int client, int slot)
{
    return GetPlayerWeaponSlot(client, slot) == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
}

stock int GetClosestClient(int client)
{
	float fClientOrigin[3], fTargetOrigin[3];
	
	GetClientAbsOrigin(client, fClientOrigin);
	
	int clientTeam = GetClientTeam(client);
	int iClosestTarget = -1;
	
	float fClosestDistance = -1.0;
	float fTargetDistance;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if (client == i || GetClientTeam(i) == clientTeam || !IsPlayerAlive(i) || g_cvFFA.IntValue == 0)
			{
				continue;
			}
			
			GetClientAbsOrigin(i, fTargetOrigin);
			fTargetDistance = GetVectorDistance(fClientOrigin, fTargetOrigin);

			if (fTargetDistance > fClosestDistance && fClosestDistance > -1.0)
			{
				continue;
			}

			if (!ClientCanSeeTarget(client, i))
			{
				continue;
			}

			if (GetEngineVersion() == Engine_CSGO)
			{
				if (GetEntPropFloat(i, Prop_Send, "m_fImmuneToGunGameDamageTime") > 0.0)
				{
					continue;
				}
			}
			
			if (!IsTargetInSightRange(client, i))
			{
				continue;
			}
			
			if (g_bFlashed[client])
			{
				continue;
			}
			
			if(LineGoesThroughSmoke(fClientOrigin, fTargetOrigin))
			{
				continue;
			}
			
			fClosestDistance = fTargetDistance;
			iClosestTarget = i;
		}
	}
	
	return iClosestTarget;
}

stock bool IsTargetInSightRange(int client, int target, float angle = 40.0, float distance = 0.0, bool heightcheck = true, bool negativeangle = false)
{
	if (angle > 360.0)
		angle = 360.0;
	
	if (angle < 0.0)
		return false;
	
	float clientpos[3];
	float targetpos[3];
	float anglevector[3];
	float targetvector[3];
	float resultangle;
	float resultdistance;
	
	GetClientEyeAngles(client, anglevector);
	anglevector[0] = anglevector[2] = 0.0;
	GetAngleVectors(anglevector, anglevector, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(anglevector, anglevector);
	if (negativeangle)
		NegateVector(anglevector);
	
	GetClientAbsOrigin(client, clientpos);
	GetClientAbsOrigin(target, targetpos);
	
	if (heightcheck && distance > 0)
		resultdistance = GetVectorDistance(clientpos, targetpos);
	
	clientpos[2] = targetpos[2] = 0.0;
	MakeVectorFromPoints(clientpos, targetpos, targetvector);
	NormalizeVector(targetvector, targetvector);
	
	resultangle = RadToDeg(ArcCosine(GetVectorDotProduct(targetvector, anglevector)));
	
	if (resultangle <= angle / 2)
	{
		if (distance > 0)
		{
			if (!heightcheck)
				resultdistance = GetVectorDistance(clientpos, targetpos);
			
			if (distance >= resultdistance)
				return true;
			else return false;
		}
		else return true;
	}
	
	return false;
}

stock bool ClientCanSeeTarget(int client, int iTarget, float fDistance = 0.0, float fHeight = 50.0)
{
	float fClientPosition[3]; float fTargetPosition[3];

	GetEntPropVector(client, Prop_Send, "m_vecOrigin", fClientPosition);
	fClientPosition[2] += fHeight;
	
	GetClientEyePosition(iTarget, fTargetPosition);
	
	if (fDistance == 0.0 || GetVectorDistance(fClientPosition, fTargetPosition, false) < fDistance)
	{
		Handle hTrace = TR_TraceRayFilterEx(fClientPosition, fTargetPosition, MASK_VISIBLE, RayType_EndPoint, Base_TraceFilter);
		
		if (TR_DidHit(hTrace))
		{
			delete hTrace;
			return false;
		}
		
		delete hTrace;
		return true;
	}
	
	return false;
}

public bool Base_TraceFilter(int iEntity, int iContentsMask, int iData)
{
	return iEntity == iData;
}

stock void AddInFrontOf(float fVecOrigin[3], float fVecAngle[3], float fUnits, float fOutPut[3])
{
	float fVecView[3]; GetViewVector(fVecAngle, fVecView);
	
	fOutPut[0] = fVecView[0] * fUnits + fVecOrigin[0];
	fOutPut[1] = fVecView[1] * fUnits + fVecOrigin[1];
	fOutPut[2] = fVecView[2] * fUnits + fVecOrigin[2];
}

stock void GetViewVector(float fVecAngle[3], float fOutPut[3])
{
	fOutPut[0] = Cosine(fVecAngle[1] / (180 / FLOAT_PI));
	fOutPut[1] = Sine(fVecAngle[1] / (180 / FLOAT_PI));
	fOutPut[2] = -Sine(fVecAngle[0] / (180 / FLOAT_PI));
}

stock bool LineGoesThroughSmoke(float from[3], float to[3])
{
	static Address TheBots;
	static Handle CBotManager_IsLineBlockedBySmoke;
	static int OS;
	
	if(OS == 0)
	{
		Handle hGameConf = LoadGameConfigFile("LineGoesThroughSmoke.games");
		if(!hGameConf)
		{
			SetFailState("Could not read LineGoesThroughSmoke.games.txt");
			return false;
		}
		
		OS = GameConfGetOffset(hGameConf, "OS");
		
		TheBots = GameConfGetAddress(hGameConf, "TheBots");
		if(!TheBots)
		{
			CloseHandle(hGameConf);
			SetFailState("TheBots == null");
			return false;
		}
		
		StartPrepSDKCall(SDKCall_Raw);
		PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CBotManager::IsLineBlockedBySmoke");
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
		if(OS == 1) PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
		PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
		if(!(CBotManager_IsLineBlockedBySmoke = EndPrepSDKCall()))
		{
			CloseHandle(hGameConf);
			SetFailState("Failed to get CBotManager::IsLineBlockedBySmoke function");
			return false;
		}
		
		CloseHandle(hGameConf);
	}
	
	if(OS == 1) return SDKCall(CBotManager_IsLineBlockedBySmoke, TheBots, from, to, 1.0);
	return SDKCall(CBotManager_IsLineBlockedBySmoke, TheBots, from, to);
}

stock bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client);
}