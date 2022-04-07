#include scripts\_utility;

cmd(args, prefix)
{
	if (!isAlive(self))
	{
		self respond("^1You are not alive.");
		return;
	}

	self suicide();
}
