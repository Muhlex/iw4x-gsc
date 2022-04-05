#include scripts\_utility;

init()
{
	setDvarIfUninitialized("scr_parser_print", false);

	if (isDefined(game["_parser__items"]))
		return;

	parseItems();
}

getItems()
{
	if (isDefined(game["_parser__items"]))
		return game["_parser__items"];
	else
		return parseItems();
}

parseItems()
{
	items = [];
	items = parsePerkTable(items, "mp/perkTable.csv"); // must parse equipment before offhands!
	items = parseStatsTable(items, "mp/statstable.csv");
	items = parseCamoTable(items, "mp/camoTable.csv");
	items = parseAttachmentsTable(items, "mp/attachmentTable.csv");
	items = parseAttachmentCombosTable(items, "mp/attachmentcombos.csv");
	game["_parser__items"] = items;

	if (getDvarInt("scr_parser_print"))
		printItems(items);

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
				base.tier = int(getSubStr(type, type.size - 1, type.size));
				base.image = image;
				precacheShader(base.image);
				base.iString = iString;
				base.iStringDesc = iStringDesc;

				upgradeName = tableLookupByRow(path, i, 8);
				if (upgradeName == "specialty_null" || upgradeName == "") continue;

				upgrade = spawnStruct();
				upgrade.name = upgradeName;
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

	items["perks"] = perks;
	items["deathstreaks"] = deathstreaks;
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
				weapon.class = getSubStr(class, "weapon_".size, class.size);
				weapon.image = image;
				precacheShader(weapon.image);
				weapon.iString = iString;
				weapon.iStringDesc = iStringDesc;
				weapon.validAttachments = [];

				for (j = 11; j < 22 ; j++)
				{
					attachment = tableLookupByRow(path, i, j);
					if (attachment != "")
						weapon.validAttachments[weapon.validAttachments.size] = attachment;
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
				offhand.image = image;
				precacheShader(offhand.image);
				offhand.iString = iString;
				offhand.iStringDesc = iStringDesc;
				offhands[name] = offhand;
		}
	}

	items["weapons"] = weapons;
	items["offhands"] = offhands;
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
		camo.image = tableLookupByRow(path, i, 4);
		precacheShader(camo.image);
		camo.iString = tableLookupIString(path, 0, id, 2);
		camo.iStringDesc = tableLookupIString(path, 0, id, 3);
		camos[name] = camo;
	}

	items["camos"] = camos;
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
		type = tableLookupByRow(path, i, 2);
		if (type == "none") continue;
		if (type == "") break;

		name = tableLookupByRow(path, i, 4);
		if (arrayContains(CUT_ATTACHMENTS, name)) continue;

		attachment = spawnStruct();
		attachment.type = type;
		attachment.name = name;
		attachment.image = tableLookupByRow(path, i, 6);
		precacheShader(attachment.image);
		attachment.iString = tableLookupIString(path, 4, name, 3);
		attachment.iStringDesc = tableLookupIString(path, 4, name, 7);
		attachment.combosMap = []; // filled later

		attachments[name] = attachment;
	}

	items["attachments"] = attachments;
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
			items["attachments"][a1].combosMap[a2] = (tableLookup(path, 0, a1, colIndex) != "no");

	return items;
}

printItems(items)
{
	foreach (weapon in items["weapons"])
	{
		attachmentStr = "";
		foreach (attachment in weapon.validAttachments)
			attachmentStr += attachment + ", ";
		attachmentStr = getSubStr(attachmentStr, 0, attachmentStr.size - 2);
		printLn("^3[parser] ^6[weapon] ^5" + weapon.name + " ^7(" + weapon.class + ") [" + attachmentStr + "]");
	}
	printLn("-----------------------------------");

	foreach (attachment in items["attachments"])
	{
		combosStr = "";
		foreach (comboAtt, valid in attachment.combosMap)
			if (valid) combosStr += comboAtt + ", ";
		combosStr = getSubStr(combosStr, 0, combosStr.size - 2);

		printLn("^3[parser] ^6[attachment] ^5" + attachment.name + " ^7(" + attachment.type + ") [" + combosStr + "]");
	}
	printLn("-----------------------------------");

	foreach (camo in items["camos"])
		printLn("^3[parser] ^6[camo] ^5" + camo.name + " ^7(" + camo.id + ")");
	printLn("-----------------------------------");

	foreach (equipment in items["equipment"])
		printLn("^3[parser] ^6[equipment] ^5" + equipment.name);
	printLn("-----------------------------------");

	foreach (offhand in items["offhands"])
		printLn("^3[parser] ^6[offhand] ^5" + offhand.name);
	printLn("-----------------------------------");

	foreach (tierNum, tier in items["perks"]["base"])
		foreach (perk in tier)
			printLn("^3[parser] ^6[perk " + tierNum + "] ^5" + perk.name + " ^7(-> " + perk.upgrade.name + ")");
	foreach (tierNum, tier in items["perks"]["upgrade"])
		foreach (perk in tier)
			printLn("^3[parser] ^6[perk upgrade " + tierNum + "] ^5" + perk.name + " ^7(<- " + perk.base.name + ")");
	printLn("-----------------------------------");

	foreach (deathstreak in items["deathstreaks"])
		printLn("^3[parser] ^6[deathstreak] ^5" + deathstreak.name + " ^7(" + deathstreak.deathCount + ")");
	printLn("-----------------------------------");
}
