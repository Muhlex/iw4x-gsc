#include scripts\_utility;

cmd(args, prefix, cmd)
{
	count = int(coalesce(args[1], 1));

	if (count < 1)
	{
		self respond("^1Must spawn at least 1 bot.");
		return;
	}

	exec("spawnbot " + count);
	self respond("^2Spawning ^7" + count + " ^2bot" + ternary(count != 1, "s", "") + "...");
}
