#include scripts\_utility;

cmd(args, prefix, cmd)
{
	if (args.size < 2)
	{
		self respond("^1Usage: " + prefix + args[0] + " [name] <z | forwards z | x y z>");
		return;
	}

	x = 0;
	y = 0;
	z = 0;
	target = undefined;
	firstArgIsName = (int(args[1]) == 0 && args[1] != "0");

	if (firstArgIsName)
	{
		target = getPlayerByName(args[1]);

		if (!isDefined(target))
		{
			self respond("^1Target could not be found.");
			return;
		}

		args = arrayRemoveIndex(args, 1);
	}
	else
	{
		target = self;
	}

	if (!isAlive(target))
	{
		self respond("^1Player is not alive.");
		return;
	}

	switch (args.size)
	{
		case 2:
			z = int(args[1]);
			break;

		case 3:
			forwards = anglesToForward(self.angles) * int(args[1]);
			x = forwards[0];
			y = forwards[1];
			z = int(args[2]);
			break;

		default:
			x = int(args[1]);
			y = int(args[2]);
			z = int(args[3]);
			break;
	}

	vel = (x, y, z);
	target setVelocity(target getVelocity() * (1, 1, 0) + vel);
	speed = length(vel);
	speedMPS = speed * 0.0254;
	self respond("^2Applied ^7" + floatRound(speedMPS, 2) + " ^2m/s to ^7" + target.name + "^2.");
}
