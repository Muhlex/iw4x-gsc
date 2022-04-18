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
		self respond("^1Must be alive to have items taken.");
		return;
	}

	item = scripts\_items::getItemByName(itemName);

	if (!isDefined(item))
	{
		self respond("^1Unknown item.");
		return;
	}

	if (item.type == "attachment" || item.type == "camo")
	{
		weaponName = target getCurrentWeapon();

		if (!isDefined(weaponName) || weaponName == "" || weaponName == "none")
		{
			self respond("^1^7" + target.name + " ^1is not holding a weapon.");
			return;
		}

		if (item.type == "attachment")
		{
			def = scripts\_items::createWeaponDefByName(weaponName);
			defPrev = scripts\_items::createWeaponDefByName(weaponName);

			error = def scripts\_items::weaponDefRemoveAttachment(item);
			if (error) {
				self respond("^1^7" + item.name + " ^1is not on ^7" + target.name + "^1's ^7" + def.item.name + "^1.");
				return;
			}

			target scripts\_items::take(defPrev);
			target scripts\_items::give(def, false, true);
			self respond("^2Removed ^7" + item.name + " ^2from ^7" + target.name + "^2's ^7" + def.item.name + "^2.");
		}
		else if (item.type == "camo")
		{
			def = scripts\_items::createWeaponDefByName(weaponName);
			target scripts\_items::take(def);
			target scripts\commands\give::camoRefresh();
			def scripts\_items::weaponDefSetCamo(undefined);
			target scripts\_items::give(def, false, true);
			self respond("^2Removed camo from ^7" + target.name + "^2's ^7" + def.item.name + "^2.");
		}

		return;
	}

	if (item.type == "weapon")
	{
		defs = [];

		weaponsList = target getWeaponsListPrimaries();
		foreach (weaponName in weaponsList)
		{
			if (item.name == getWeaponNameNoAttachments(weaponName))
			{
				def = scripts\_items::createWeaponDefByName(weaponName);
				target scripts\_items::take(def);
				defs[defs.size] = def;
			}
		}

		if (defs.size == 0)
			self respond("^1^7" + target.name + " ^1does not have ^7" + item.name + "^1.");
		else if (defs.size == 1)
			self respond("^2Taken ^7" + item.name + " ^2from ^7" + target.name + "^2.");
		else
			self respond("^2Taken ^7" + item.name + " ^2(^7x" + defs.size + "^2) ^2from ^7" + target.name + "^2.");
		return;
	}

	if (!target scripts\_items::has(item))
	{
		self respond("^1^7" + target.name + " ^1does not have ^7" + item.name + "^1.");
		return;
	}

	target scripts\_items::take(item);

	self respond("^2Taken ^7" + item.name + " ^2from ^7" + target.name + "^2.");
}
