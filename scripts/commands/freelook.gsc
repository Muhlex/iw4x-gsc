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

	if (!isAlive(target) && !coalesce(target.commands.freelook.active, false))
	{
		self respond("^1Must be alive to enter freelook.");
		return;
	}

	if (!isDefined(target.commands.freelook))
		target.commands.freelook = spawnStruct();

	if (!coalesce(target.commands.freelook.active, false))
	{
		self respond("^2Set ^7" + target.name + " ^2into freelook mode.");
		target scripts\commands\spectate::unsetSpectate();
		target setFreelook();
	}
	else
	{
		self respond("^2Unset ^7" + target.name + " ^2from freelook mode.");
		target unsetFreelook();
	}
}

setFreelook()
{
	if (coalesce(self.commands.freelook.active, false))
		self unsetFreelook();

	self allowSpectateTeam("allies", false);
	self allowSpectateTeam("axis", false);
	self allowSpectateTeam("none", false);
	self allowSpectateTeam("freelook", true);
	self setOrigin(self getEye());
	self.sessionstate = "spectator";
	self.fauxDead = true;
	self.commands.freelook.contents = self setContents(0);

	self.commands.freelook.active = true;
}

unsetFreelook()
{
	if (!coalesce(self.commands.freelook.active, false))
		return;

	self maps\mp\gametypes\_spectating::setSpectatePermissions();
	if (self.sessionstate == "spectator" && self.team != "spectator")
	{
		self setOrigin(playerPhysicsTrace(self.origin, self.origin - (0, 0, self getPlayerViewHeight()), false, self));
		self.sessionstate = ternary(isAlive(self), "playing", "dead");
		self.fauxDead = undefined;
	}
	self setContents(self.commands.freelook.contents);

	self thread cleanupUnsetFreelook();

	self.commands.freelook.active = false;
}

cleanupUnsetFreelook()
{
	self common_scripts\utility::_disableWeapon();

	wait 0.05;

	self common_scripts\utility::_enableWeapon();
	weaponName = self getWeaponsListPrimaries()[0];
	if (isDefined(weaponName))
		self switchToWeaponImmediate(weaponName);
}
