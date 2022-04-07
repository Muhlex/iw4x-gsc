#include scripts\_utility;

cmd(args, prefix)
{
	if (isDefined(args[1]))
		target = getPlayerByName(args[1]);
	else
		target = self;

	if (!isDefined(target))
	{
		self respond("^1Target could not be found.");
		return;
	}

	if (!isDefined(target.commands.tempspec))
		target.commands.tempspec = spawnStruct();

	if (!coalesce(target.commands.tempspec.active, false))
		target setTempspec();
	else
		target unsetTempspec();

	target thread OnTempspecDeath();
}

setTempspec()
{
	self setOrigin(self getEye());
	self allowSpectateTeam("freelook", true);
	self.sessionstate = "spectator";

	self.commands.tempspec.active = true;
}

unsetTempspec()
{
	self setOrigin(playerPhysicsTrace(self.origin, self.origin + (0, 0, -64), false, self));
	self allowSpectateTeam("freelook", false);
	if (self.sessionstate == "spectator")
		self.sessionstate = "playing";

	self.commands.tempspec.active = false;
}

OnTempspecDeath()
{
	self endon("disconnect");

	self waittill("death");

	self unsetTempspec();
}
