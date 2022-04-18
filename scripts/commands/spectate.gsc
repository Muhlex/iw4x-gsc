#include scripts\_utility;

cmd(args, prefix)
{
	if (args.size < 2 && !isDefined(self.commands.spectate.target))
	{
		self respond("^1Usage: " + prefix + args[0] + " <name>");
		return;
	}

	if (!isDefined(self.commands.spectate))
		self.commands.spectate = spawnStruct();

	if (!isDefined(self.commands.spectate.target))
	{
		target = getPlayerByName(args[1]);

		if (!isDefined(target))
		{
			self respond("^1Target could not be found.");
			return;
		}

		if (!isAlive(target))
		{
			self respond("^1Target must be alive.");
			return;
		}

		if (target == self)
		{
			self respond("^1You cannot spectate yourself.");
			return;
		}

		self respond("^2Spectating ^7" + target.name + "^2.");
		self scripts\commands\freelook::unsetFreelook();
		self setSpectate(target);
	}
	else
	{
		self respond("^2Stopped spectating ^7" + self.commands.spectate.target.name + "^2.");
		self unsetSpectate();
	}
}

setSpectate(target)
{
	if (isDefined(self.commands.spectate.target))
		self unsetSpectate();

	self.commands.spectate.prevOrigin = self.origin;

	self allowSpectateTeam("allies", true);
	self allowSpectateTeam("axis", true);
	self allowSpectateTeam("none", true);
	self allowSpectateTeam("freelook", false);
	self.sessionstate = "spectator";
	self.fauxDead = true;
	self.forcespectatorclient = target getEntityNumber();
	self.commands.spectate.contents = self setContents(0);

	self.commands.spectate.target = target;
}

unsetSpectate()
{
	if (!isDefined(self.commands.spectate.target))
		return;

	self maps\mp\gametypes\_spectating::setSpectatePermissions();
	if (self.sessionstate == "spectator" && self.team != "spectator")
	{
		self.sessionstate = ternary(isAlive(self), "playing", "dead");
		self.fauxDead = undefined;
		self setOrigin(self.commands.spectate.prevOrigin);
	}
	self.forcespectatorclient = -1;
	self setContents(self.commands.spectate.contents);

	self.commands.spectate.target = undefined;

	self thread cleanupUnsetSpectate();
}

cleanupUnsetSpectate()
{
	wait 0.05;

	if (!isAlive(self))
		return;

	self maps\mp\gametypes\_class::giveLoadout(self.team, self.class, false);
}
