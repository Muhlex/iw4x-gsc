#include scripts\_utility;

cmd(args, prefix)
{
	if (args.size < 2)
	{
		self respond("^1Usage: " + prefix + args[0] + " <name> [reason]");
		return;
	}

	target = getPlayerByName(args[1]);
	reason = arrayJoin(arraySlice(args, 2), " ");

	if (!isDefined(target))
	{
		self respond("^1Target could not be found.");
		return;
	}

	if (target == self)
	{
		self respond("^1You cannot ban yourself.");
		return;
	}

	execStr = "banclient " + target getEntityNumber();
	if (isDefined(reason))
		execStr += " \"" + reason + "\"";

	exec(execStr);
	level respond("^0^7" + target.name + "^1 banned permanently.");
}
