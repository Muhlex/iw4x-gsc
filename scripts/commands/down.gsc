#include scripts\_utility;

cmd(args, prefix, cmd)
{
	target = self;
	if (isDefined(args[1]))
		target = getPlayerByName(args[1]);

	if (!isDefined(target))
	{
		self respond("^1Target could not be found.");
		return;
	}

	if (!isAlive(target))
	{
		self respond("^1Must be alive to teleport.");
		return;
	}

	FAR = 1024 * 1024;
	pos = target.origin;
	pos = physicsTrace(pos, pos - (0, 0, FAR), false, target);
	pos -= (0, 0, 16);
	farPos = pos - (0, 0, FAR);
	pos = physicsTrace(pos, farPos, false, target);

	if (pos == farPos)
	{
		self respond("^1No ground found below.");
		return;
	}

	pos = physicsTrace(pos, pos + (0, 0, FAR), false, target);
	pos = playerPhysicsTrace(pos, pos - (0, 0, FAR * 2), false, target);

	target setOrigin(pos);
}
