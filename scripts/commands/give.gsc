#include scripts\_utility;

cmd(args, prefix)
{
	if (args.size < 2)
	{
		self respond("^1Usage: " + prefix + args[0] + " [name] <item>");
		return;
	}

	itemName = ternary(args.size > 2, args[2], args[1]);
	target = ternary(args.size > 2, getPlayerByName(args[1]), self);

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
