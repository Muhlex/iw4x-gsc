init()
{
	setDvarIfUninitialized("scr_scoreboard_reshows_perks", false);

	thread OnPlayerConnected();
}

reshowPerks()
{
	self openMenu("perks_hidden");
	self openMenu("perk_display");
}

OnPlayerConnected()
{
	for (;;)
	{
		level waittill("connected", player);

		player thread OnPlayerSpawned();
	}
}

OnPlayerSpawned()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("spawned_player");

		thread OnScoreboardClose();
	}
}

OnScoreboardClose()
{
	self endon("disconnect");
	self endon("death");

	self notifyOnPlayerCommand("reshow_perks__scores_closed", "-scores");

	for (;;)
	{
		self waittill("reshow_perks__scores_closed");

		if (!getDvarInt("scr_scoreboard_reshows_perks")) continue;
		self reshowPerks();
	}
}
