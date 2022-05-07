#include scripts\_utility;

cmd(args, prefix)
{
	target = self;
	vision = getDvar("mapname");
	if (isDefined(args[2]))
	{
		target = getPlayerByName(args[1]);
		vision = args[2];
	}
	else if (isDefined(args[1]))
	{
		vision = args[1];
	}

	if (!isDefined(target))
	{
		self respond("^1Target could not be found.");
		return;
	}

	target visionSetNakedForPlayer(vision, 1.0);
}
