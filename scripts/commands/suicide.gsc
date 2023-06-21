#include scripts\_utility;

cmd(args, prefix, cmd)
{
	if (!isAlive(self))
	{
		self respond("^1You are not alive.");
		return;
	}

	self suicide();
}
