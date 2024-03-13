#include scripts\_utility;

cmd(args, prefix, cmd)
{
	if (args.size < 2)
	{
		self respond("^1Usage: " + prefix + args[0] + " <dvar> <value>");
		return;
	}

	target = self;

	if (!isDefined(target))
	{
		self respond("^1Target could not be found.");
		return;
	}

	dvar = args[1];

	value = arrayJoin(arraySlice(args, 2), " ");
	target setClientDvar(dvar, value);
	self respond("^2Your ^7" + dvar + "^2 set to: ^3" + value);
}
