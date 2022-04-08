#include scripts\_utility;

init()
{
	if (!isDefined(game["_items__items"]))
		parseItems();
}

// ##### PUBLIC START #####

getItems()
{
	if (isDefined(game["_items__items"]))
		return game["_items__items"];
	else
		return parseItems();
}

getItemByName(name, exactMatch, type)
{
	name = coalesce(name, "");
	exactMatch = coalesce(exactMatch, false);

	if (name == "")
		return undefined;

	items = undefined;

	if (isDefined(type))
	{
		if (!isDefined(items[type]))
			return undefined;

		items = getItems()[type];
	}
	else
	{
		items = getItems();
	}

	result = arrayFindRecursive(items, ::itemNameIs, name);
	if (isDefined(result))
		return result;

	if (exactMatch)
		return undefined;

	nameLC = toLower(name);

	result = arrayFindRecursive(items, ::itemNameStartsWithLC, nameLC);
	if (isDefined(result))
		return result;

	result = arrayFindRecursive(items, ::itemNameIsSubStrOfLC, nameLC);
	if (isDefined(result))
		return result;

	return undefined;
}

createWeaponDef(weapon, attachments, camo)
{
	items = getItems();

	attachments = coalesce(attachments, []);
	camo = coalesce(camo, items["camo"]["none"]);

	// Transform parameters to items if strings were passed
	if (isString(weapon))
		weapon = items["weapon"][weapon];

	foreach (i, attachment in attachments)
		if (isString(attachment))
			attachments[i] = items["attachment"][attachment];

	if (isString(camo))
		camo = items["camo"][camo];

	def = spawnStruct();
	def.item = weapon;
	def.attachments = attachments;
	def.camo = camo;
	def.fullName = buildWeaponName(weapon.name, attachments);

	return def;
}

createWeaponDefByName(name)
{
	suffix = ternary(stringEndsWith(name, "_mp"), "_mp", "");
	tokens = strTok(name, "_");

	base = tokens[0] + suffix;
	attachments = [];
	for (i = 1; i < tokens.size; i++)
		attachments[attachments.size] = tokens[i];

	return createWeaponDef(base, attachments);
}

weaponDefAddAttachment(attachment)
{
	if (self.attachments.size >= 2)
		return 2;

	if (isString(attachment))
		attachment = getItems()["attachment"][attachment];

	if (!isDefined(attachment))
		return 1;

	if (!arrayContains(self.item.validAttachments, attachment))
		return 3;

	foreach (existingAtt in self.attachments)
		if (!attachment.combosMap[existingAtt.name])
			return existingAtt;

	self.attachments[self.attachments.size] = attachment;
	self.fullName = buildWeaponName(self.item.name, self.attachments);
	return 0;
}

weaponDefRemoveAttachment(attachment)
{
	if (self.attachments.size == 0)
		return 2;

	if (isString(attachment))
		attachment = getItems()["attachment"][attachment];

	if (!isDefined(attachment))
		return 1;

	if (!arrayContains(self.attachments, attachment))
		return 2;

	self.attachments[self.attachments.size] = attachment;
	self.attachments = arrayRemove(self.attachments, attachment);
	self.fullName = buildWeaponName(self.item.name, self.attachments);
	return 0;
}

weaponDefSetCamo(camo)
{
	if (isString(coalesce(camo, "none")))
		camo = getItems()["camo"][camo];

	if (!isDefined(camo))
		return 1;

	self.camo = camo;
	return 0;
}

give(itemOrDef, switchTo)
{
	def = ternary(isDefined(itemOrDef.item), itemOrDef, undefined);
	item = coalesce(itemOrDef.item, itemOrDef);
	switchTo = coalesce(switchTo, false);

	if (isDefined(item.customGive))
	{
		self [[item.customGive]](item, def);
		return;
	}

	if (!isDefined(item.type)) return;

	weaponName = coalesce(def.fullName, item.name);
	if (item.name == "specialty_tacticalinsertion")
		weaponName = "flare_mp";

	switch (item.type) {
		case "weapon":
			self maps\mp\_utility::_giveWeapon(weaponName, def.camo.id);

			if (self hasPerk("specialty_extraammo", true) && item.class != "projectile")
				self giveMaxAmmo(weaponName);
			break;

		case "equipment":
			self setOffhandPrimaryClass("other");
			self maps\mp\perks\_perks::givePerk(item.name);
			break;

		case "offhand":
			if (weaponName == "flash_grenade_mp")
				self setOffhandSecondaryClass("flash");
			else
				self setOffhandSecondaryClass("smoke");

			self giveWeapon(weaponName);
			break;

		case "perk":
		case "deathstreak":
			self maps\mp\perks\_perks::givePerk(item.name);
			break;
	}

	if (switchTo && self hasWeapon(weaponName))
		self switchToWeaponImmediate(weaponName);
}

take(itemOrDef)
{
	def = ternary(isDefined(itemOrDef.item), itemOrDef, undefined);
	item = coalesce(itemOrDef.item, itemOrDef);

	if (isDefined(item.customTake))
	{
		self [[item.customTake]](item, def);
		return;
	}

	if (!isDefined(item.type)) return;

	weaponName = coalesce(def.fullName, item.name);
	if (item.name == "specialty_tacticalinsertion")
		weaponName = "flare_mp";
	wasActive = (self getCurrentWeapon() == weaponName);

	switch (item.type) {
		case "weapon":
			self takeWeapon(weaponName);
			break;

		case "equipment":
			self setOffhandPrimaryClass("other");
			self maps\mp\_utility::_unsetPerk(item.name);
			if (self hasWeapon(weaponName))
				self takeWeapon(weaponName);
			break;

		case "offhand":
			self setOffhandSecondaryClass("smoke");
			self takeWeapon(weaponName);
			break;

		case "perk":
		case "deathstreak":
			self maps\mp\_utility::_unsetPerk(item.name);
			break;
	}

	if (wasActive)
		self switchToWeaponImmediate(self getWeaponsListPrimaries()[0]);
}

has(itemOrDef)
{
	def = ternary(isDefined(itemOrDef.item), itemOrDef, undefined);
	item = coalesce(itemOrDef.item, itemOrDef);

	if (isDefined(item.customHas))
	{
		return self [[item.customHas]](item, def);
	}

	if (!isDefined(item.type)) return;

	weaponName = coalesce(def.fullName, item.name);
	if (item.name == "specialty_tacticalinsertion")
		weaponName = "flare_mp";

	switch (item.type) {
		case "weapon":
			return self hasWeapon(weaponName);

		case "equipment":
			return (self maps\mp\_utility::_hasPerk(item.name) || self hasWeapon(weaponName));

		case "offhand":
			return self hasWeapon(weaponName);

		case "perk":
		case "deathstreak":
			return self maps\mp\_utility::_hasPerk(item.name);
	}
}

printItems(items)
{
	foreach (weapon in items["weapon"])
	{
		attachmentStr = "";
		foreach (attachment in weapon.validAttachments)
			attachmentStr += attachment.name + ", ";
		attachmentStr = getSubStr(attachmentStr, 0, attachmentStr.size - 2);
		self iPrintLn("^3[items] ^6[weapon] ^5" + weapon.name + " ^7(" + weapon.class + ") [" + attachmentStr + "]");
	}
	self iPrintLn("-----------------------------------");

	foreach (attachment in items["attachment"])
	{
		combosStr = "";
		foreach (comboAtt, valid in attachment.combosMap)
			if (valid) combosStr += comboAtt + ", ";
		combosStr = getSubStr(combosStr, 0, combosStr.size - 2);

		self iPrintLn("^3[items] ^6[attachment] ^5" + attachment.name + " ^7(" + attachment.kind + ") [" + combosStr + "]");
	}
	self iPrintLn("-----------------------------------");

	foreach (camo in items["camo"])
		self iPrintLn("^3[items] ^6[camo] ^5" + camo.name + " ^7(" + camo.id + ")");
	self iPrintLn("-----------------------------------");

	foreach (equipment in items["equipment"])
		self iPrintLn("^3[items] ^6[equipment] ^5" + equipment.name);
	self iPrintLn("-----------------------------------");

	foreach (offhand in items["offhand"])
		self iPrintLn("^3[items] ^6[offhand] ^5" + offhand.name);
	self iPrintLn("-----------------------------------");

	foreach (tierNum, tier in items["perk"]["base"])
		foreach (perk in tier)
			self iPrintLn("^3[items] ^6[perk " + tierNum + "] ^5" + perk.name + " ^7(-> " + perk.upgrade.name + ")");
	foreach (tierNum, tier in items["perk"]["upgrade"])
		foreach (perk in tier)
			self iPrintLn("^3[items] ^6[perk upgrade " + tierNum + "] ^5" + perk.name + " ^7(<- " + perk.base.name + ")");
	self iPrintLn("-----------------------------------");

	foreach (deathstreak in items["deathstreak"])
		self iPrintLn("^3[items] ^6[deathstreak] ^5" + deathstreak.name + " ^7(" + deathstreak.deathCount + ")");
	self iPrintLn("-----------------------------------");
}

// ##### PUBLIC END #####

itemNameIs(item, name)
{
	if (!isDefined(item.name)) return false;
	return (item.name == name);
}

itemNameStartsWithLC(item, nameLC)
{
	if (!isDefined(item.name)) return false;
	return (stringStartsWith(toLower(item.name), nameLC));
}

itemNameIsSubStrOfLC(item, nameLC)
{
	if (!isDefined(item.name)) return false;
	return (isSubStr(toLower(item.name), nameLC));
}

parseItems()
{
	items = [];
	items = parsePerkTable(items, "mp/perkTable.csv"); // Must parse equipment before offhands!
	items = parseAttachmentsTable(items, "mp/attachmentTable.csv"); // Must parse attachments before weapons!
	items = parseAttachmentCombosTable(items, "mp/attachmentcombos.csv");
	items = parseStatsTable(items, "mp/statstable.csv");
	items = parseCamoTable(items, "mp/camoTable.csv");

	items = scripts\_items_plugins::getItems(items);
	game["_items__items"] = items;

	return items;
}

parsePerkTable(items, path)
{
	CUT_DEATHSTREAKS = [];
	CUT_DEATHSTREAKS[0] = "specialty_c4death";

	perks = [];
	deathstreaks = [];
	equipments = [];
	// equipment such as the blast shield may exist multiple times,
	// thus we filter only allow one entry per associated image:
	knownImages = [];

	for (i = 1; tableLookupByRow(path, i, 0) != ""; i++)
	{
		type = tableLookupByRow(path, i, 5);
		if (type == "") continue;

		name = tableLookupByRow(path, i, 1);
		image = tableLookupByRow(path, i, 3);
		// tableLookupIStringByRow exists... but it doesn't work :)
		iString = tableLookupIString(path, 1, name, 2);
		iStringDesc = tableLookupIString(path, 1, name, 4);

		switch (type) {
			case "perk1":
			case "perk2":
			case "perk3":
				if (name == "specialty_null") continue;

				base = spawnStruct();
				base.name = name;
				base.type = "perk";
				base.tier = int(getSubStr(type, type.size - 1, type.size));
				base.image = image;
				precacheShader(base.image);
				base.iString = iString;
				base.iStringDesc = iStringDesc;

				upgradeName = tableLookupByRow(path, i, 8);
				if (upgradeName == "specialty_null" || upgradeName == "") continue;

				upgrade = spawnStruct();
				upgrade.name = upgradeName;
				upgrade.type = "perk";
				upgrade.tier = base.tier;
				upgrade.image = tableLookup(path, 1, upgrade.name, 3);
				precacheShader(upgrade.image);
				upgrade.iString = tableLookupIString(path, 1, base.name, 9);
				upgrade.iStringDesc = tableLookupIString(path, 1, upgrade.name, 4);

				base.upgrade = upgrade;
				upgrade.base = base;

				perks["base"][base.tier][base.name] = base;

				perks["upgrade"][upgrade.tier][upgrade.name] = upgrade;
				break;

			case "perk4":
				if (arrayContains(CUT_DEATHSTREAKS, name)) continue;

				deathstreak = spawnStruct();
				deathstreak.name = name;
				deathstreak.type = "deathstreak";
				deathstreak.deathCount = int(tableLookupByRow(path, i, 6));
				deathstreak.image = image;
				precacheShader(deathstreak.image);
				deathstreak.iString = iString;
				deathstreak.iStringDesc = iStringDesc;
				deathstreaks[name] = deathstreak;
				break;

			case "equipment":
				if (isDefined(knownImages[image])) continue;

				equipment = spawnStruct();
				equipment.name = name;
				equipment.type = "equipment";
				equipment.image = image;
				precacheShader(equipment.image);
				equipment.iString = iString;
				equipment.iStringDesc = iStringDesc;
				equipments[name] = equipment;
				break;

			default:
				continue;
		}

		knownImages[image] = image;
	}

	items["perk"] = perks;
	items["deathstreak"] = deathstreaks;
	items["equipment"] = equipments;
	return items;
}

parseStatsTable(items, path)
{
	weapons = [];
	offhands = [];

	for (i = 1; tableLookupByRow(path, i, 0) != ""; i++)
	{
		class = tableLookupByRow(path, i, 2);
		if (!stringStartsWith(class, "weapon_")) continue;

		name = tableLookupByRow(path, i, 4);
		image = tableLookupByRow(path, i, 6);
		iString = tableLookupIString(path, 4, name, 3);
		// handle special cases where menu name differs from the ingame one
		if (name == "rpg") iString = &"WEAPON_RPG";
		if (name == "m79") iString = &"WEAPON_M79";
		iStringDesc = tableLookupIString(path, 4, name, 7);
		name += "_mp";

		switch (weaponInventoryType(name)) {
			case "primary":
				weapon = spawnStruct();
				weapon.name = name;
				weapon.type = "weapon";
				weapon.class = getSubStr(class, "weapon_".size, class.size);
				weapon.image = image;
				precacheShader(weapon.image);
				weapon.iString = iString;
				weapon.iStringDesc = iStringDesc;
				weapon.validAttachments = [];

				for (j = 11; j < 22 ; j++)
				{
					attachmentName = tableLookupByRow(path, i, j);
					if (attachmentName != "")
						weapon.validAttachments[weapon.validAttachments.size] = items["attachment"][attachmentName];
				}

				weapons[name] = weapon;
				break;

			case "offhand":
				equipmentNames = [];
				foreach (equipment in items["equipment"])
					equipmentNames[equipmentNames.size] = equipment.name;
				if (arrayContains(equipmentNames, name)) continue; // requires equipment to be parsed!

				offhand = spawnStruct();
				offhand.name = name;
				offhand.type = "offhand";
				offhand.image = image;
				precacheShader(offhand.image);
				offhand.iString = iString;
				offhand.iStringDesc = iStringDesc;
				offhands[name] = offhand;
		}
	}

	items["weapon"] = weapons;
	items["offhand"] = offhands;
	return items;
}

parseCamoTable(items, path)
{
	CUT_CAMOS = [];
	CUT_CAMOS[0] = "gold";
	CUT_CAMOS[1] = "prestige";

	camos = [];

	for (i = 0; true; i++)
	{
		id = tableLookupByRow(path, i, 0);
		if (id == "") break;
		id = int(id);

		name = tableLookupByRow(path, i, 1);
		if (arrayContains(CUT_CAMOS, name)) continue;

		camo = spawnStruct();
		camo.id = id;
		camo.name = name;
		camo.type = "camo";
		camo.image = tableLookupByRow(path, i, 4);
		precacheShader(camo.image);
		camo.iString = tableLookupIString(path, 0, id, 2);
		camo.iStringDesc = tableLookupIString(path, 0, id, 3);
		camos[name] = camo;
	}

	items["camo"] = camos;
	return items;
}

parseAttachmentsTable(items, path)
{
	CUT_ATTACHMENTS = [];
	CUT_ATTACHMENTS[0] = "lockair";
	CUT_ATTACHMENTS[1] = "boom";

	attachments = [];

	for (i = 1; true; i++)
	{
		kind = tableLookupByRow(path, i, 2);
		if (kind == "none") continue;
		if (kind == "") break;

		name = tableLookupByRow(path, i, 4);
		if (arrayContains(CUT_ATTACHMENTS, name)) continue;

		attachment = spawnStruct();
		attachment.name = name;
		attachment.type = "attachment";
		attachment.kind = kind;
		attachment.image = tableLookupByRow(path, i, 6);
		precacheShader(attachment.image);
		attachment.iString = tableLookupIString(path, 4, name, 3);
		attachment.iStringDesc = tableLookupIString(path, 4, name, 7);
		attachment.combosMap = []; // filled later

		attachments[name] = attachment;
	}

	items["attachment"] = attachments;
	return items;
}

parseAttachmentCombosTable(items, path)
{
	attachmentCols = [];

	for (i = 1; true; i++)
	{
		attachment = tableLookupByRow(path, i, 0);
		if (attachment == "") break;

		attachmentCols[attachment] = tableLookupRowNum(path, 0, attachment);
	}

	foreach (a1 in getArrayKeys(attachmentCols))
		foreach (a2, colIndex in attachmentCols)
			items["attachment"][a1].combosMap[a2] = (tableLookup(path, 0, a1, colIndex) != "no");

	return items;
}
