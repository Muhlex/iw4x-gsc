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

	item = scripts\_items::getItemByName(itemName);
	def = undefined;

	if (!isDefined(item))
	{
		self respond("^1Unknown item.");
		return;
	}

	if (item.type == "attachment")
	{
		weaponName = target getCurrentWeapon();

		if (!isDefined(weaponName) || weaponName == "" || weaponName == "none")
		{
			self respond("^1^7" + target.name + " ^1is not holding a weapon.");
			return;
		}

		def = scripts\_items::createWeaponDefByName(weaponName);
		defPrev = scripts\_items::createWeaponDefByName(weaponName);

		error = def scripts\_items::weaponDefAddAttachment(item);
		switch (error) {
			case 0: break;
			case 1: return;
			case 2:
				self respond("^1^7" + target.name + "^1's ^7" + def.item.name + " ^1already has 2 attachments.");
				return;
			case 3:
				self respond("^1^7" + item.name + " ^1not compatible with ^7" + target.name + "^1's ^7" + def.item.name + "^1.");
				return;
			default:
				self respond("^1^7" + item.name + " ^1cannot be combined with ^7" + error.name + " ^1on ^7" + target.name + "^1's ^7" + def.item.name + "^1.");
				return;
		}

		target scripts\_items::take(defPrev);
		target scripts\_items::give(def, true);
		self respond("^2Attached ^7" + item.name + " ^2to ^7" + target.name + "^2's ^7" + def.item.name + "^2.");

		return;
	}

	switchTo = (item.type == "weapon");
	target scripts\_items::give(item, switchTo);

	self respond("^2Given ^7" + item.name + " ^2to ^7" + target.name + "^2.");
}
