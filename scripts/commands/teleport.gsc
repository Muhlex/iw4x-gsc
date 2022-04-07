#include scripts\_utility;

cmd(args, prefix)
{
	if (args.size < 2)
		self thread locationSelectTeleport();
	else
		self playerTeleport(args);
}

playerTeleport(args)
{
	player = ternary(args.size > 2, getPlayerByName(args[1]), self);
	target = ternary(args.size > 2, getPlayerByName(args[2]), getPlayerByName(args[1]));

	if (!isDefined(player) || !isDefined(target))
	{
		self respond("^1Targets could not be found.");
		return;
	}

	if (player == target)
	{
		self respond("^1Cannot teleport a player to themselves.");
		return;
	}

	if (!isAlive(player) || !isAlive(target))
	{
		self respond("^1Both players must be alive to teleport.");
		return;
	}

	player setOrigin(target.origin);
	self respond("^2Teleported ^7" + player.name + " ^2to ^7" + target.name + "^2.");
}

locationSelectTeleport()
{
	if (!isAlive(self))
	{
		self respond("^1Must be alive to teleport.");
		return;
	}

	self scripts\commands\freelook::unsetFreelook();
	self scripts\commands\spectate::unsetSpectate();

	self beginLocationSelection("map_nuke_selector", true, level.mapSize / 16);
	self.selectingLocation = true;

	self thread OnLocationSelect();
	self thread OnLocationSelectEnd();
}

OnLocationSelect()
{
	self endon("disconnect");
	self endon("death");

	self waittill("confirm_location", pos, yaw);

		// When the start is inside a solid, physicsTraces will only hit after exiting the solid.
	FAR = 1024 * 1024;
	pos = (pos[0], pos[1], level.spawnMaxs[2]);
	pos = playerPhysicsTrace(pos, pos + (0, 0, FAR), false);
	pos = playerPhysicsTrace(pos, pos - (0, 0, FAR * 2), false);
	pos = unstuckPos(pos);

	self setOrigin(pos);
	self setPlayerAngles((0, yaw, 0));
}

OnLocationSelectEnd()
{
	self endon("disconnect");

	self waittillAny("confirm_location", "death");

	self endLocationSelection();
	self.selectingLocation = undefined;
}

// Well it's better than nothing but not very reliable:
unstuckPos(pos)
{
	// thread point3D(pos, (1, 1, 0));
	FAR = 1024 * 1024;
	result = pos;

	for (yaw = 0; yaw <= 360; yaw += 90)
	{
		startPos = result;
		result = playerPhysicsTrace(startPos, startPos + anglesToForward((0, yaw, 0)) * FAR, false);
		// thread line3D(startPos, result);
		result = playerPhysicsTrace(result, startPos, false);
		// thread line3D(result + (0, 0, 1), startPos + (0, 0, 1), (1, 0, 0));
	}

	return result;
}
