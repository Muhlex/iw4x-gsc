#include scripts\_utility;

cmd(args, prefix)
{
	command = arrayJoin(arraySlice(args, 1), " ");
	exec(command);
}
