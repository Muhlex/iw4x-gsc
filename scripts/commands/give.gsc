#include scripts\_utility;

cmd(args, prefix)
{
	if (args.size < 2)
	{
		self respond("^1Usage: " + prefix + args[0] + " <itemname> [name]");
		return;
	}

	itemName = args[1];
	if (isDefined(args[2]))
		target = getPlayerByName(args[2]);
	else
		target = self;

	if (!isDefined(target))
	{
		self respond("^1Target could not be found.");
		return;
	}

	if (!isAlive(target))
	{
		self respond("^1Must be alive to receive items.");
		return;
	}

	target maps\mp\_utility::_giveWeapon(itemName);
	target switchToWeapon(itemName);
	self respond("^2Given ^7" + itemName + " ^2to ^7" + target.name + "^2.");
}
