#include scripts\_utility;

cmd(args, prefix, cmd)
{
	if (isDefined(args[1]))
		target = getPlayerByName(args[1]);
	else
		target = self;

	if (!isDefined(target))
	{
		self respond("^1Target could not be found.");
		return;
	}

	if (!isDefined(target.commands.fpsboost))
		target.commands.fpsboost = spawnStruct();

	if (!coalesce(target.commands.fpsboost.active, false))
	{
        target SetClientDvar("r_fullbright", 1);
        target SetClientDvar("r_fog", 0);
        target SetClientDvar("r_detailMap", 0);
        target iPrintlnBold("^7FPS Booster ^1Enabled");
		target.commands.fpsboost.active = true;
		self respond("^2Enabled FPS Boost for ^7" + target.name + "^2.");
	}
	else
	{
        target SetClientDvar("r_fullbright", 0);
        target SetClientDvar("r_fog", 1);
        target SetClientDvar("r_detailMap", 1);
        target iPrintlnBold("^7FPS Booster ^1Disabled");
		target.commands.fpsboost.active = false;
		self respond("^2Disabled FPS Boost for ^7" + target.name + "^2.");
	}
}