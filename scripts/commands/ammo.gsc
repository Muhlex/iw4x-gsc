#include scripts\_utility;

cmd(args, prefix, cmd)
{
	if (args.size < 1)
	{
		self respond("^1Usage: " + prefix + args[0] + "[weapon] [target]");
		return;
	}

	target = self;
	if (args.size > 2) {
		target = getPlayerByName(args[3]);
	}
	if (!isDefined(target))
	{
		self respond("^1Target could not be found.");
		return;
	}

	weapon = target getCurrentWeapon();
	if (args.size > 1) {
		weapon = args[1];
	}

	self respond("Giving " + target.name + " max ammo for " + weapon.name + ".");
	target giveMaxAmmo(weapon);
	target setWeaponAmmoStockToClipsize(weapon);
	self respond("Given " + target.name + " max ammo for " + weapon.name + ".");
}