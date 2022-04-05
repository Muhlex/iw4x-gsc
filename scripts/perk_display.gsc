init()
{
	setDvarIfUninitialized("scr_scoreboard_reshows_perks", false);

	level thread OnPlayerConnected();
}

OnPlayerConnected()
{
	for (;;)
	{
		level waittill("connected", player);

		player notifyOnPlayerCommand("perk_display__scores_closed", "-scores");
		player thread OnPlayerSpawned();
	}
}

OnPlayerSpawned()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("spawned_player");

		self thread OnScoreboardClose();
	}
}

OnScoreboardClose()
{
	self endon("disconnect");
	self endon("death");

	for (;;)
	{
		self waittill("perk_display__scores_closed");

		if (getDvarInt("scr_scoreboard_reshows_perks"))
		{
			self notify("perks_hidden");
			self openMenu("perk_display");
			self thread maps\mp\gametypes\_playerlogic::hidePerksAfterTime(5.0); // kind of useless
			self thread maps\mp\gametypes\_playerlogic::hidePerksOnDeath();
		}
	}
}
