#include scripts\_utility;

init()
{
	setDvarIfUninitialized("scr_forced_killstreaks", "");
	setDvarIfUninitialized("scr_perkstreaks", "");

	level.killstreaks = spawnStruct();
	level.killstreaks.forcedKillstreaks = parseStreaks(getDvar("scr_forced_killstreaks"), false);
	level.killstreaks.perkStreaks = parseStreaks(getDvar("scr_perkstreaks"), true);

	level thread OnPlayerConnected();
}

OnPlayerConnected()
{
	for (;;)
	{
		level waittill("connected", player);

		player thread OnPlayerLoadoutGiven();
		player thread OnPlayerKilledEnemy();
	}
}

OnPlayerLoadoutGiven()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("giveLoadout");

		self setForcedKillstreaks();
		self giveEarnedPerkStreaks(false);
	}
}

OnPlayerKilledEnemy()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("killed_enemy");

		self giveEarnedPerkStreaks(true);
	}
}

setForcedKillstreaks()
{
	if (!level.killstreakRewards) return;
	if (!isDefined(level.killstreaks.forcedKillstreaks)) return;

	modifier = self getModifier();
	killStreaks = [];
	foreach (killcount, streak in level.killstreaks.forcedKillstreaks)
		killStreaks[killcount + modifier] = streak;

	self.killStreaks = killStreaks;
}

giveEarnedPerkStreaks(killedEnemy)
{
	if (!isDefined(level.killstreaks.perkStreaks)) return;

	currentStreak = self.pers["cur_kill_streak"] - level.killStreakMod;
	perksGiven = 0;
	modifier = self getModifier();

	foreach (streakVal, perks in level.killstreaks.perkStreaks)
		if (currentStreak >= streakVal + modifier)
			foreach(perk in perks)
				if (!self maps\mp\_utility::_hasPerk(perk))
				{
					perksGiven++;
					self maps\mp\perks\_perks::givePerk(perk);
				}

	if (killedEnemy && perksGiven > 0)
		self displayPerks();
}

displayPerks()
{
	// TODO: Probably replace this with a custom UI
	self notify("perks_hidden");
	self openMenu("perk_display");
	self thread maps\mp\gametypes\_playerlogic::hidePerksAfterTime(5.0); // kind of useless
	self thread maps\mp\gametypes\_playerlogic::hidePerksOnDeath();
}

parseStreaks(string, multiplePerKillcount)
{
	if (string == "") return undefined;

	streaks = [];
	rawData = strTok(string, " ");

	if (rawData.size == 0 || rawData.size % 2) return streaks; // needs to be pairs of streak numbers and reward names

	// map e.g. ["3", "uav", "4", "counter_uav"] to streaks[3] = "uav"; streaks[4] = "counter_uav"
	for (i = 0; i < rawData.size; i += 2)
	{
		killcount = int(rawData[i]);
		streak = rawData[i + 1];
		if (multiplePerKillcount)
		{
			index = 0;
			if (isDefined(streaks[killcount])) index = streaks[killcount].size;
			streaks[killcount][index] = streak;
		}
		else
		{
			streaks[killcount] = streak;
		}
	}

	return streaks;
}

getModifier()
{
	modifier = 0;
	if (self maps\mp\_utility::_hasPerk("specialty_hardline") && (getDvarInt("scr_classic") != 1))
		modifier = -1;

	return modifier;
}
