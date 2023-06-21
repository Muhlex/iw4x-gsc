#include scripts\_utility;

cmd(args, prefix, cmd)
{
	command = arrayJoin(arraySlice(args, 1), " ");
	if (command == "")
	{
		self respond("^1Usage: " + prefix + args[0] + " <command>");
		return;
	}
	exec(command);
}
