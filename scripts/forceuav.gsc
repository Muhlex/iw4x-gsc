UAV_NONE = 0;
UAV_SWEEP = 1;
UAV_CONSTANT = 2;

init()
{
	setDvarIfUninitialized("scr_fix_forceuav", false);

	if (storageHas("forceuav__compassEnemyFootstep_override"))
	{
		// Set footstep system to defaults if it was changed by us:
		makeDvarServerInfo("compassEnemyFootstepEnabled", false);
		makeDvarServerInfo("compassEnemyFootstepMaxRange", 500);
		makeDvarServerInfo("compassEnemyFootstepMaxZ", 100);
		makeDvarServerInfo("compassEnemyFootstepMinSpeed", 140);

		storageRemove("forceuav__compassEnemyFootstep_override");
	}

	if (!getDvarInt("scr_fix_forceuav")) return;

	level.forceuav = spawnStruct();
	level.forceuav.type = getDvarInt("scr_game_forceuav");

	level thread OnPlayerConnected();

	waittillframeend;

	if (level.forceuav.type == UAV_SWEEP && level.teamBased)
	{
		level.activeUAVs["allies"] += 1;
		level.activeUAVs["axis"] += 1;
		maps\mp\killstreaks\_uav::updateTeamUAVStatus("allies");
		maps\mp\killstreaks\_uav::updateTeamUAVStatus("axis");
	}
	else if (level.forceuav.type == UAV_CONSTANT)
	{
		// Abuse the footstep system to always show enemies everywhere:
		makeDvarServerInfo("compassEnemyFootstepEnabled", true);
		makeDvarServerInfo("compassEnemyFootstepMaxRange", 2147483647);
		makeDvarServerInfo("compassEnemyFootstepMaxZ", 2147483647);
		makeDvarServerInfo("compassEnemyFootstepMinSpeed", 0);

		storageSet("forceuav__compassEnemyFootstep_override", true);
	}
}

OnPlayerConnected()
{
	for (;;)
	{
		level waittill("connected", player);

		player thread OnPlayerConnectedFrameEnd();
	}
}

OnPlayerConnectedFrameEnd()
{
	waittillframeend;

	if (level.forceuav.type == UAV_SWEEP && !level.teamBased)
	{
		level.activeUAVs[self.guid] += 1;
		maps\mp\killstreaks\_uav::updatePlayersUAVStatus();
	}
}
