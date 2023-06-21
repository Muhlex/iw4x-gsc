#include scripts\_utility;

cmd(args, prefix, cmd)
{
	if (args.size < 2)
	{
		self respond("^1Usage: " + prefix + args[0] + " <dvar> [value]");
		return;
	}

	dvar = args[1];

	if (args.size == 2)
	{
		value = getDvar(dvar);
		if (value == "")
			self respond("^0^7" + dvar + " ^3is either unset or does not exist");
		else
			self respond("^0^7" + dvar + ": ^3" + value);
		return;
	}

	value = arrayJoin(arraySlice(args, 2), " ");
	setDvar(dvar, value);
	self respond("^2^7" + dvar + "^2 set to: ^3" + value);
}
