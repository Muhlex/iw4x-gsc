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

	execStr = "clientkick " + target getEntityNumber();
	if (isDefined(reason))
		execStr += " \"" + reason + "\"";

	exec(execStr);
}
