#include scripts\_utility;

cmdself(args, prefix, cmd) {
	cmd(args, prefix, cmd);
}

cmd(args, prefix, cmd)
{
	// self _SetActionSlot( 3, "laser" );
	self SetActionSlot( 3, "laser" );
	if (args.size < 1)
	{
		self respond("^1Usage: " + prefix + args[0] + " <target>");
		return;
	}

	target = self;
	if (args.size > 2) {
		target = getPlayerByName(arrayJoin(arraySlice(args, 1), " "));
	}

	if (!isDefined(target))
	{
		self respond("^1Target could not be found.");
		return;
	}

	if (!isDefined(target.commands)) {
		target.commands = spawnstruct();
	}
	if (!isDefined(target.commands.laser)) {
		target.commands.laser = false;
	}

	if (target.commands.laser) {
		target.commands.laser = false;
		target setClientDvar("laserForceOn", "0");
		target setClientDvar("laserLight", "0");
		target setClientDvar("cg_laserLight", "0");
		target setClientDvar("laserLightWithoutNightvision", "0");
		self respond("^2"+target.name+" ^7no longer has laser");
	} else {
		target.commands.laser = true;
		target setClientDvar("laserForceOn", "1");
		target setClientDvar("laserLight", "1");
		target setClientDvar("cg_laserLight", "1");
		target setClientDvar("laserLightWithoutNightvision", "1");
		self respond("^2"+target.name+" ^7has now laser");
	}
}