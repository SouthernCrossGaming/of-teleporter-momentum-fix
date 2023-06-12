#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "1.0.0"
public Plugin myinfo = {
    name = "[OF] Teleporter Velocity Fix",
    author = "Fraeven & Rowedahelicon",
    description = "Fixes a player's velocity when exiting a teleporter.",
    version = PLUGIN_VERSION,
    url = "https://scg.wtf"
};

ConVar g_cvarEnabled;
float g_vecPlayerVelocity[MAXPLAYERS+1][3];

public void OnPluginStart()
{
    g_cvarEnabled = CreateConVar("sm_teleporter_velocity_fix", "1", "Fix a player's velocity when exiting a teleporter.");

    HookEvent("teamplay_round_start", Event_RoundStart);

    HookTeleporterTriggers();
}

public Action Hook_TeleStartTouch(int entity, int client)
{
    if (!g_cvarEnabled.BoolValue || !IsValidClient(client) || !IsPlayerAlive(client))
    {
        return Plugin_Continue;
    }

    int target = GetTeleportExit(entity);
    if (target == -1)
    {
        return Plugin_Continue;
    }

    float m_vecOrigin[3], m_angRotation[3], m_vecAbsVelocity[3], p_vec[3];
    GetEntPropVector(target, Prop_Send, "m_vecOrigin", m_vecOrigin);
    GetEntPropVector(target, Prop_Send, "m_angRotation", m_angRotation);
    GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", m_vecAbsVelocity);

    // Zero out vertical velocity
    m_vecAbsVelocity[2] = 0.0;

    GetAngleVectors(m_angRotation, p_vec, NULL_VECTOR, NULL_VECTOR);
    NormalizeVector(p_vec, p_vec);

    float speed = GetVectorLength(m_vecAbsVelocity);
    ScaleVector(p_vec, speed);

    g_vecPlayerVelocity[client] = p_vec;

    return Plugin_Continue;
}

public Action Hook_TeleEndTouch(int entity, int client)
{
    if (!g_cvarEnabled.BoolValue || !IsValidClient(client) || !IsPlayerAlive(client))
    {
        return Plugin_Continue;
    }

    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, g_vecPlayerVelocity[client]);

    return Plugin_Continue;
}

stock int GetTeleportExit(int trigger_teleport)
{
    char m_target[128], m_target_name[128];
    int target, f_target;

    GetEntPropString(trigger_teleport, Prop_Data, "m_target", m_target, sizeof(m_target));

    // This is because some maps use one or the other -w-
    while ((target = FindEntityByClassname(target, "info_teleport_destination")) != -1)
    {
        GetEntPropString(target, Prop_Data, "m_iName", m_target_name, sizeof(m_target_name));
        if (StrEqual(m_target_name, m_target))
        {
            f_target = target;
            break;
        }
    }

    while ((target = FindEntityByClassname(target, "point_teleport")) != -1)
    {
        GetEntPropString(target, Prop_Data, "m_iName", m_target_name, sizeof(m_target_name));
        if (StrEqual(m_target_name, m_target))
        {
            f_target = target;
            break;
        }
    }

    return f_target;
}

stock bool IsValidClient(int client)
{
    if (!client || client > MaxClients || client < 1)
    {
        return false;
    }

    if (!IsClientInGame(client))
    {
        return false;
    }

    return true;
}

void HookTeleporterTriggers()
{
    int target = -1;
    while ((target = FindEntityByClassname(target, "trigger_teleport")) != -1)
    {
        SDKHook(target, SDKHook_StartTouch, Hook_TeleStartTouch);
        SDKHook(target, SDKHook_EndTouch, Hook_TeleEndTouch);
    }
}

stock Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    HookTeleporterTriggers();
}