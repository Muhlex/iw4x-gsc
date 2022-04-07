#include scripts\_utility;

cmd(args, prefix)
{
	if (args.size < 2)
	{
		self respond("^1Usage: " + prefix + args[0] + " <name>");
		return;
	}

	target = getPlayerByName(args[1]);

	if (!isDefined(target))
	{
		self respond("^1Target could not be found.");
		return;
	}

	if (!isAlive(target))
	{
		self respond("^1Player is not alive.");
		return;
	}

	target suicide();
	self respond("^2Killed ^7" + target.name + "^2.");
}
