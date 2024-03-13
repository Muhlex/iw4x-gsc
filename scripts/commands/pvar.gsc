#include scripts\_utility;

cmd(args, prefix, cmd)
{
	if (args.size < 2)
	{
		self respond("^1Usage: " + prefix + args[0] + " <target> <dvar> <value>");
		return;
	}

	target = getPlayerByName(args[1]);

	if (!isDefined(target))
	{
		self respond("^1Target could not be found.");
		return;
	}

	dvar = args[2];

	value = arrayJoin(arraySlice(args, 3), " ");
	target setClientDvar(dvar, value);
	self respond("^2" + target.name + "'s ^7" + dvar + "^2 set to: ^3" + value);
}
