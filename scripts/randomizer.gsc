// TODO: You can somehow very rarely spawn without a weapon?
// TODO: Make it work with killstreaks.

#include scripts\_utility;

init()
{
	LOADOUT_MODES = spawnStruct();
	LOADOUT_MODES.EVERYONE = 0;
	LOADOUT_MODES.PER_TEAM = 1;
	LOADOUT_MODES.PER_PLAYER = 2;
	LOADOUT_MODES.PER_LIFE = 3;

	PERK_UPGRADE_MODES = spawnStruct();
	PERK_UPGRADE_MODES.NEVER = 0;
	PERK_UPGRADE_MODES.ALWAYS = 1;
	PERK_UPGRADE_MODES.IF_UNLOCKED = 2;

	setDvarIfUninitialized("scr_randomizer_enabled", false);
	setDvarIfUninitialized("scr_randomizer_mode", LOADOUT_MODES.EVERYONE);
	setDvarIfUninitialized("scr_randomizer_interval", 0);
	setDvarIfUninitialized("scr_randomizer_next_preview_time", 5.0);
	setDvarIfUninitialized("scr_randomizer_weapon_count", 1);
	setDvarIfUninitialized("scr_randomizer_attachment_count", -1); // -1 is random
	setDvarIfUninitialized("scr_randomizer_perk_ignore_tiers", false);
	setDvarIfUninitialized("scr_randomizer_perk_ignore_hierarchy", false);
	setDvarIfUninitialized("scr_randomizer_perk_count", 1); // per tier when not ignoring tiers
	setDvarIfUninitialized("scr_randomizer_perk_upgrade_mode", PERK_UPGRADE_MODES.ALWAYS); // not applicable when ignoring perk hierarchy
	setDvarIfUninitialized("scr_randomizer_deathstreak_death_count", -1); // -1 uses the regular ones

	items = scripts\_items::getItems();

	listTypes = strTok("blacklist whitelist", " ");
	itemTypes = getArrayKeys(items);

	defaults["blacklist"]["weapons"] = "onemanarmy_mp stinger_mp deserteaglegold_mp";
	defaults["blacklist"]["perks"] = "specialty_bling specialty_onemanarmy";
	defaults["blacklist"]["deathstreaks"] = "specialty_copycat";

	foreach (list in listTypes)
		foreach (item in itemTypes)
			setDvarIfUninitialized("scr_randomizer_" + list + "_" + item, coalesce(defaults[list][item], ""));

	if (!getDvarInt("scr_randomizer_enabled")) return;

	items = parseFilterLists(items, itemTypes, listTypes);

	level.randomizer = spawnStruct();
	level.randomizer.LOADOUT_MODES = LOADOUT_MODES;
	level.randomizer.PERK_UPGRADE_MODES = PERK_UPGRADE_MODES;
	level.randomizer.items = items;
	level.randomizer.loadouts = [];
	level.randomizer.loadouts["everyone"] = [];
	level.randomizer.loadouts["allies"] = [];
	level.randomizer.loadouts["axis"] = [];

	level pushLoadout();

	level thread OnPrematchOver();
	level thread OnPlayerConnected();

	waittillframeend;

	level.randomizer.origFuncs = spawnStruct();
	level.randomizer.origFuncs.onSpawnPlayer = level.onSpawnPlayer;
	level.onSpawnPlayer = ::OnPlayerSpawn;
}

// Ugly hack: Temporarily set the current death streak value to 0 to prevent death streaks
// from being given. Otherwise a splash notification will appear.
OnPlayerSpawn()
{
	self [[level.randomizer.origFuncs.onSpawnPlayer]]();

	self thread OnPlayerSpawned(self.pers["cur_death_streak"]);
	self.pers["cur_death_streak"] = 0;
}

OnPlayerSpawned(deathStreakValue)
{
	self waittill("spawned_player");

	self.pers["cur_death_streak"] = deathStreakValue;
}

OnPrematchOver()
{
	level waittill("prematch_over");

	interval = getDvarInt("scr_randomizer_interval");
	if (interval <= 0) return;

	level thread OnLoadoutTimer(interval);
}

OnPlayerConnected()
{
	for (;;)
	{
		level waittill("connected", player);

		level.randomizer.loadouts[player.guid] = [];
		// make sure connecting players get their loadouts array filled accordingly
		for (i = 0; i < level.randomizer.loadouts["everyone"].size; i++)
			player pushLoadout();

		player.randomizer = spawnStruct();
		player.randomizer.activeOffhand = undefined;
		player.randomizer.ui = spawnStruct();
		player.randomizer.ui.loadout = [];

		player thread OnPlayerDisconnected();
		player thread OnPlayerChangedKit();
		player thread OnPlayerDeath();
		player thread OnPlayerWeaponSwitchStarted();
		player thread OnPlayerDebugKey();
	}
}

OnPlayerDisconnected()
{
	self waittill("disconnect");

	level.randomizer.loadouts[self.guid] = undefined;
}

OnPlayerChangedKit()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("changed_kit");

		waittillframeend;

		loadout = self getLoadoutForPlayer();
		self thread giveLoadout(loadout);
		self thread uiLoadoutDisplay(loadout);
	}
}

OnPlayerDeath()
{
	self endon("disconnect");

	LOADOUT_MODES = level.randomizer.LOADOUT_MODES;

	for (;;)
	{
		self waittill("death");

		mode = getDvarInt("scr_randomizer_mode");

		if (mode < LOADOUT_MODES.PER_LIFE) continue;

		self pushLoadout();
		self shiftLoadout();
	}
}

OnPlayerWeaponSwitchStarted()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("weapon_switch_started", newWeaponName);

		if (coalesce(weaponInventoryType(newWeaponName), "") == "offhand")
			self.randomizer.activeOffhand = newWeaponName;
		else
			self.randomizer.activeOffhand = undefined;

		self thread OnPlayerOffhandEnd();
	}
}

OnPlayerOffhandEnd()
{
	self endon("disconnect");

	self waittillAny("offhand_end", "death");

	self.randomizer.activeOffhand = undefined;
}

OnPlayerDebugKey()
{
	self endon("disconnect");
	self notifyOnPlayerCommand("randomizer__debug", "+actionslot 2");

	for (;;)
	{
		self waittill("randomizer__debug");

		level thread cycleLoadout(1.5);
	}
}

OnLoadoutTimer(interval)
{
	level endon("game_ended");

	level uiIntervalBarDisplay(interval);

	previewTime = getDvarFloat("scr_randomizer_next_preview_time");

	wait interval - previewTime;

	level cycleLoadout(previewTime);

	level thread OnLoadoutTimer(interval);
}

parseFilterLists(items, itemTypes, listTypes)
{
	foreach (listType in listTypes)
	{
		foreach (itemType in itemTypes)
		{
			names = strTok(getDvar("scr_randomizer_" + listType + "_" + itemType), " ");
			if (names.size == 0) continue;

			switch (listType) {
				case "blacklist":
					foreach (name in names)
						if (isDefined(items[itemType][name]))
							items[itemType][name] = undefined;
					break;

				case "whitelist":
					newItemsOfType = [];
					foreach (name in names)
						if (isDefined(items[itemType][name]))
							newItemsOfType[name] = items[itemType][name];

					items[itemType] = newItemsOfType;
			}
		}
	}

	return items;
}

pushLoadout()
{
	loadouts = level.randomizer.loadouts;

	if (isPlayer(self))
		loadouts[self.guid][loadouts[self.guid].size] = getRandomLoadout();
	else
	{
		foreach (key in strTok("everyone allies axis", " "))
			loadouts[key][loadouts[key].size] = getRandomLoadout();
		foreach (player in level.players)
			loadouts[player.guid][loadouts[player.guid].size] = getRandomLoadout();
	}

	level.randomizer.loadouts = loadouts;
}

shiftLoadout()
{
	loadouts = level.randomizer.loadouts;

	if (isPlayer(self))
		loadouts[self.guid] = arrayRemoveIndex(loadouts[self.guid], 0);
	else
	{
		foreach (key in strTok("everyone allies axis", " "))
			loadouts[key] = arrayRemoveIndex(loadouts[key], 0);
		foreach (player in level.players)
			loadouts[player.guid] = arrayRemoveIndex(loadouts[player.guid], 0);
	}

	level.randomizer.loadouts = loadouts;
}

getLoadoutForPlayer(index)
{
	index = coalesce(index, 0);

	LOADOUT_MODES = level.randomizer.LOADOUT_MODES;
	mode = getDvarInt("scr_randomizer_mode");
	loadouts = level.randomizer.loadouts;

	if (mode == LOADOUT_MODES.EVERYONE)
		return loadouts["everyone"][ternary(index < 0, loadouts["everyone"].size + index, index)];

	if (mode == LOADOUT_MODES.PER_TEAM)
	{
		if (level.teamBased)
			return loadouts[self.team][ternary(index < 0, loadouts[self.team].size + index, index)];
		else
			return loadouts["allies"][ternary(index < 0, loadouts["allies"].size + index, index)];
	}

	if (mode == LOADOUT_MODES.PER_PLAYER || mode >= LOADOUT_MODES.PER_LIFE)
		return loadouts[self.guid][ternary(index < 0, loadouts[self.guid].size + index, index)];
}

cycleLoadout(delay)
{
	level pushLoadout();

	foreach (player in level.players)
		if (player.team != "spectator")
			player thread uiLoadoutDisplay(player getLoadoutForPlayer(-1), delay, true);

	wait delay;

	foreach (player in level.players)
		if (player.team != "spectator" && isAlive(player))
			player thread giveLoadout(player getLoadoutForPlayer(1), player getLoadoutForPlayer(0));

	level shiftLoadout();
}

getRandomLoadout()
{
	weaponCount = getDvarInt("scr_randomizer_weapon_count");
	perksIgnoreTiers = !!getDvarInt("scr_randomizer_perk_ignore_tiers");
	perksIgnoreHierarchy = !!getDvarInt("scr_randomizer_perk_ignore_hierarchy");
	perkCount = getDvarInt("scr_randomizer_perk_count");

	loadout = spawnStruct();
	loadout.weapons = getRandomWeapons(weaponCount);
	loadout.equipment = getRandomEquipment();
	loadout.offhand = getRandomOffhand();
	loadout.perks = getRandomPerks(perksIgnoreTiers, perksIgnoreHierarchy, perkCount);
	loadout.deathstreak = getRandomDeathstreak();
	return loadout;
}

getRandomWeapons(count)
{
	attachmentCount = getDvarInt("scr_randomizer_attachment_count");
	if (attachmentCount > 2) attachmentCount = 2;
	else if (attachmentCount < 0) attachmentCount = randomInt(3);

	rest = level.randomizer.items["weapon"];
	weaponDefs = [];

	for (i = 0; i < count; i++)
	{
		item = arrayGetRandom(rest);
		rest = arrayRemove(rest, item);

		attachmentNames = getRandomAttachments(item.validAttachments, attachmentCount);
		weaponDefs[i] = scripts\_items::createWeaponDef(item, attachmentNames, getRandomCamo());
	}
	return weaponDefs;
}

getRandomAttachments(validAttachments, count)
{
	rest = validAttachments;

	attachments = [];
	for (i = 0; i < count; i++)
	{
		if (rest.size == 0)
			continue;

		if (i > 0)
		{
			prevAttachment = attachments[i - 1];
			prevRest = rest;
			rest = [];
			foreach (attachment in prevRest)
				if (attachment.combosMap[prevAttachment.name])
					rest[rest.size] = attachment;
		}

		attachments[attachments.size] = arrayGetRandom(rest);
	}
	return attachments;
}

getRandomCamo()
{
	return arrayGetRandom(level.randomizer.items["camo"]);
}

getRandomEquipment()
{
	return arrayGetRandom(level.randomizer.items["equipment"]);
}

getRandomOffhand()
{
	return arrayGetRandom(level.randomizer.items["offhand"]);
}

getRandomPerks(ignoreTiers, ignoreHierarchy, perkCount)
{
	perkItems = level.randomizer.items["perk"];
	perkList = [];

	if (ignoreTiers)
	{
		rest = [];
		foreach (tierNum, tier in perkItems["base"])
			rest = arrayCombine(rest, tier);
		if (ignoreHierarchy)
			foreach (tierNum, tier in perkItems["upgrade"])
				rest = arrayCombine(rest, tier);

		for (i = 0; i < perkCount; i++)
		{
			if (rest.size == 0) break;

			rolledPerk = arrayGetRandom(rest);
			perkList[perkList.size] = rolledPerk;

			rest = arrayRemove(rest, rolledPerk);
		}
	}
	else
	{
		foreach (tierNum, tier in perkItems["base"])
		{
			rest = tier;
			if (ignoreHierarchy)
				rest = arrayCombine(rest, perkItems["upgrade"][tierNum]);

			for (i = 0; i < perkCount; i++)
			{
				if (rest.size == 0) break;

				rolledPerk = arrayGetRandom(rest);
				perkList[perkList.size] = rolledPerk;

				rest = arrayRemove(rest, rolledPerk);
			}
		}
	}

	perks = spawnStruct();
	perks.perkList = perkList;
	perks.ignoreTiers = ignoreTiers;
	perks.ignoreHierarchy = ignoreHierarchy;

	return perks;
}

getRandomDeathstreak()
{
	return arrayGetRandom(level.randomizer.items["deathstreak"]);
}

giveLoadout(loadout, prevLoadout)
{
	self endon("disconnect");
	self endon("death");
	self endon("changed_kit");

	isSpawn = (getTime() == self.spawnTime);
	hadBlastshield = self maps\mp\_utility::_hasPerk("specialty_blastshield");

	self thread OnGiveLoadoutEnd(isSpawn, hadBlastshield);

	if (!isSpawn)
	{
		self common_scripts\utility::_disableWeaponSwitch();
		self common_scripts\utility::_disableOffhandWeapons();
	}

	self takeAllWeapons();
	if (isDefined(prevLoadout))
		self takeItemsNoPerks(prevLoadout);

	if (isDefined(self.randomizer.activeOffhand))
	{
		self waittill("offhand_end");

		waittillframeend; // let scripted equipment process
	}

	// TI needs the perk to be present, thus clear those after the wait
	self maps\mp\_utility::_clearPerks();
	if (isDefined(prevLoadout))
		self takeItemsOnlyPerks(prevLoadout);

	// give perks first because they can influence other items (scavenger pro)
	self givePerks(loadout.perks, getDvarInt("scr_randomizer_perk_upgrade_mode"));
	self giveWeapons(loadout.weapons, isSpawn);
	self giveEquipment(loadout.equipment);
	self giveOffhand(loadout.offhand);
	self giveDeathstreak(loadout.deathstreak, isSpawn);

	self notify("giveLoadout");

	level notify("changed_kit"); // updates sitrep models

	if (!isSpawn)
	{
		wait 1.0;
		self refreshCurrentOffhand();
	}
}

OnGiveLoadoutEnd(isSpawn, hadBlastshield)
{
	self endon("disconnect");

	self waittillAny("death", "changed_kit", "giveLoadout");

	// fix a case where the blast shield leaves players with a black screen when switching while toggling
	if (hadBlastshield)
		self visionSetNakedForPlayer(getDvar("mapname"), 0);

	if (!isSpawn)
	{
		self common_scripts\utility::_enableWeaponSwitch();
		self common_scripts\utility::_enableOffhandWeapons();
	}
}

takeItemsNoPerks(loadout)
{
	foreach (weapon in loadout.weapons)
		self scripts\_items::take(weapon);

	self scripts\_items::take(loadout.equipment);
	self scripts\_items::take(loadout.offhand);
	self scripts\_items::take(loadout.deathstreak);
}

takeItemsOnlyPerks(loadout)
{
	foreach (perk in loadout.perks.perkList)
	{
		self scripts\_items::take(perk);
		self scripts\_items::take(perk.upgrade);
	}
}

refreshCurrentOffhand()
{
	// This primarily cleans up the hud when a offhand (including equipment) was held when switching loadouts.
	currentOffhand = self getCurrentOffhand();
	if (!arrayContains(self getWeaponsListOffhands(), self getCurrentOffhand()))
	{
		self maps\mp\_utility::_giveWeapon(currentOffhand); // re-giving is required to update hud
		self takeWeapon(currentOffhand);
	}
}

giveWeapons(weaponDefs, isSpawn)
{
	weaponDefs = coalesce(weaponDefs, []);

	foreach (weaponDef in weaponDefs)
		self scripts\_items::give(weaponDef);

	self.primaryWeapon = weaponDefs[0].fullName;
	self.secondaryWeapon = weaponDefs[1].fullName;
	self.isSniper = (coalesce(weaponDefs[0].item.class, "") == "sniper");

	if (isDefined(weaponDefs[0]))
	{
		if (isSpawn)
		{
			self setSpawnWeapon(weaponDefs[0].fullName);
			self maps\mp\gametypes\_class::_detachAll();
			self setPlayerModelForWeaponClass(weaponDefs[0].item.class);
		}
		else
		{
			self switchToWeapon(weaponDefs[0].fullName);
		}
	}

	self maps\mp\gametypes\_weapons::updateMoveSpeedScale("primary");

	if (isDefined(weaponDefs[0].fullName) && weaponDefs[0].fullName == "riotshield_mp" && level.inGracePeriod)
		self notify("weapon_change", "riotshield_mp");
}

giveEquipment(equipment)
{
	if (!isDefined(equipment)) return;
	self scripts\_items::give(equipment);
}

giveOffhand(offhand)
{
	if (!isDefined(offhand)) return;
	self scripts\_items::give(offhand);
}

givePerks(perks, upgradeMode)
{
	if (!isDefined(perks)) return;

	foreach (perk in perks.perkList)
	{
		self scripts\_items::give(perk);

		if (self doPerkUpgrade(perk, upgradeMode, perks.ignoreHierarchy))
			self scripts\_items::give(perk.upgrade);
	}
}

doPerkUpgrade(perk, upgradeMode, ignoreHierarchy)
{
	PERK_UPGRADE_MODES = level.randomizer.PERK_UPGRADE_MODES;
	alwaysUpgrade = (upgradeMode == PERK_UPGRADE_MODES.ALWAYS);
	doUnlockUpgrade = (upgradeMode == PERK_UPGRADE_MODES.IF_UNLOCKED && self isItemUnlocked(perk.upgrade.name));
	return !ignoreHierarchy && (alwaysUpgrade || doUnlockUpgrade);
}

giveDeathstreak(deathstreak, isSpawn)
{
	if (!isDefined(deathstreak)) return;

	deathCount = deathstreak.deathCount;

	deathCountOverride = getDvarInt("scr_randomizer_deathstreak_death_count");
	if (deathCountOverride > -1)
		deathCount = deathCountOverride;

	if (self maps\mp\_utility::_hasPerk("specialty_rollover"))
		deathCount -= 1;

	if (self.pers["cur_death_streak"] < deathCount) return;

	self scripts\_items::give(deathstreak);

	if (isSpawn)
		self thread maps\mp\gametypes\_hud_message::splashNotify(deathstreak.name);
}

setPlayerModelForWeaponClass(class)
{
	team = self.team;

	switch (class)
	{
		case "assault":
			[[game[team + "_model"]["ASSAULT"]]]();
			break;

		case "shotgun":
			[[game[team + "_model"]["SHOTGUN"]]]();
			break;

		case "smg":
			[[game[team + "_model"]["SMG"]]]();
			break;

		case "sniper":
			if (level.environment != "" && self isItemUnlocked("ghillie_" + level.environment))
				[[game[team + "_model"]["GHILLIE"]]]();
			else
				[[game[team + "_model"]["SNIPER"]]]();
			break;

		case "lmg":
			[[game[team + "_model"]["LMG"]]]();
			break;

		case "riot":
			[[game[team + "_model"]["RIOT"]]]();
			break;

		default:
			[[game[team + "_model"]["ASSAULT"]]]();
			break;
	}
}

uiIntervalBarDisplay(time)
{
	bar = level hudCreateRectangle(0, 2, (134/255, 192/255, 0/255));
	bar.alpha = 0.75;
	bar hudSetPos("TOP LEFT", "TOP LEFT", 0, 0);
	bar.horzAlign = "fullscreen";
	bar scaleOverTime(time, 640, bar.height);
	bar.archived = false;
	bar.hidewheninmenu = true;
	bar.foreground = true;

	level thread uiIntervalBarOnTimeEnd(time, bar);
	level thread uiIntervalBarOnGameEnded(bar);
}

uiIntervalBarOnTimeEnd(time, bar)
{
	wait time;

	bar destroy();
}

uiIntervalBarOnGameEnded(bar)
{
	level waittill("game_ended");

	bar destroy();
}

uiLoadoutDisplay(loadout, time, upcoming)
{
	if (!isDefined(time)) time = 3.0;
	if (!isDefined(upcoming)) upcoming = false;

	if (!upcoming && self.randomizer.ui.loadout.size > 0) return;

	self uiLoadoutDestroy();

	PADDING_BG = 6;
	PADDING_HORZ = 10;
	BAR_HEIGHT = 10;

	ui = [];
	uiTopRow = [];

	h = 100;
	bg = self hudCreateRectangle(0, 0, (0, 0, 0));
	bg.alpha = 0.2 + (upcoming * 0.2);
	bg.sort = -1;
	bg hudSetPos("TOP RIGHT", "TOP RIGHT", 0, 110);
	ui[ui.size] = bg;

	foreach (i, weaponDef in loadout.weapons)
	{
		weaponText = self hudCreateText("objective", 1.0);
		weaponText.label = weaponDef.item.iString;
		if (i == 0)
		{
			weaponText hudSetParent(bg);
			weaponText hudSetPos("TOP LEFT", "TOP LEFT", PADDING_BG, PADDING_BG);
		}
		ui[ui.size] = weaponText;

		weaponImage = self hudCreateImage(99, 50, weaponDef.item.image);
		if (i == 0)
		{
			weaponImage hudSetParent(weaponText);
			weaponImage hudSetPos("TOP LEFT", "BOTTOM LEFT", 0, 4);
		}
		else
		{
			weaponImage hudSetParent(uiTopRow[uiTopRow.size - 1]);
			weaponImage hudSetPos("TOP LEFT", "TOP RIGHT", PADDING_HORZ, 0);
			weaponText hudSetParent(weaponImage);
			weaponText hudSetPos("BOTTOM LEFT", "TOP LEFT", 0, -4);
		}
		ui[ui.size] = weaponImage;
		uiTopRow[uiTopRow.size] = weaponImage;

		foreach (j, attachment in weaponDef.attachments)
		{
			if (!isDefined(attachment)) continue;

			attachmentImage = self hudCreateImage(20, 20, attachment.image);
			attachmentImage.sort = 1;
			if (j == 0)
			{
				attachmentImage hudSetParent(ui[ui.size - 1]);
				attachmentImage hudSetPos("TOP LEFT", "BOTTOM LEFT", 0, -12);
			}
			else
			{
				attachmentImage hudSetParent(ui[ui.size - 2]);
				attachmentImage hudSetPos("TOP LEFT", "BOTTOM LEFT", 0, -4);
			}
			ui[ui.size] = attachmentImage;

			attachmentText = self hudCreateText("default", 0.875);
			attachmentText.sort = 1;
			attachmentText.label = attachment.iString;
			attachmentText hudSetParent(ui[ui.size - 1]);
			attachmentText hudSetPos("CENTER LEFT", "CENTER RIGHT", 4, -1);
			ui[ui.size] = attachmentText;
		}
	}

	equipmentImage = undefined;

	if (isDefined(loadout.equipment))
	{
		equipmentImage = self hudCreateImage(22, 22, loadout.equipment.image);
		equipmentImage hudSetParent(uiTopRow[uiTopRow.size - 1]);
		equipmentImage hudSetPos("TOP LEFT", "TOP RIGHT", PADDING_HORZ, 0);
		ui[ui.size] = equipmentImage;
		uiTopRow[uiTopRow.size] = equipmentImage;
	}

	if (isDefined(loadout.offhand))
	{
		offhandImage = self hudCreateImage(22, 22, loadout.offhand.image);
		if (isDefined(equipmentImage))
		{
			offhandImage hudSetParent(equipmentImage);
			offhandImage hudSetPos("TOP LEFT", "BOTTOM LEFT", 0, 2);
		}
		else
		{
			offhandImage hudSetParent(uiTopRow[uiTopRow.size - 1]);
			offhandImage hudSetPos("TOP LEFT", "TOP RIGHT", PADDING_HORZ, 0);
		}
		ui[ui.size] = offhandImage;
	}

	foreach (i, perk in loadout.perks.perkList)
	{
		image = perk.image;
		if (self doPerkUpgrade(perk, getDvarInt("scr_randomizer_perk_upgrade_mode"), loadout.perks.ignoreHierarchy))
			image = perk.upgrade.image;

		perkImage = self hudCreateImage(22, 22, image);
		if (i == 0)
		{
			perkImage hudSetParent(uiTopRow[uiTopRow.size - 1]);
			perkImage hudSetPos("TOP LEFT", "TOP RIGHT", PADDING_HORZ, 0);
		}
		else if (i % 3 == 0)
		{
			perkImage hudSetParent(uiTopRow[uiTopRow.size - 1]);
			perkImage hudSetPos("TOP LEFT", "TOP RIGHT", 2, 0);
		}
		else
		{
			perkImage hudSetParent(ui[ui.size - 1]);
			perkImage hudSetPos("TOP LEFT", "BOTTOM LEFT", 0, 2);
		}
		ui[ui.size] = perkImage;
		if (i % 3 == 0)
			uiTopRow[uiTopRow.size] = perkImage;
	}

	if (isDefined(loadout.deathstreak))
	{
		deathstreakImage = self hudCreateImage(22, 22, loadout.deathstreak.image);
		deathstreakImage.alpha = 0.5;
		deathstreakImage hudSetParent(uiTopRow[uiTopRow.size - 1]);
		deathstreakImage hudSetPos("TOP LEFT", "TOP RIGHT", PADDING_HORZ, 0);
		ui[ui.size] = deathstreakImage;
		uiTopRow[uiTopRow.size] = deathstreakImage;
	}

	size = bg hudComputeSizeRecursive();
	w = size["width"] + PADDING_BG * 2; // double padding on the right
	h = size["height"] + PADDING_BG + (upcoming * BAR_HEIGHT);
	bg hudUpdateRect(w, h);

	if (upcoming)
	{
		bar = self hudCreateRectangle(0, BAR_HEIGHT, (134/255, 192/255, 0/255));
		bar.dontStagger = true;
		bar hudSetParent(bg);
		bar hudSetPos("BOTTOM LEFT", "BOTTOM LEFT", 0, 0);
		bar scaleOverTime(time, bg.width, bar.height);
		ui[ui.size] = bar;

		barText = self hudCreateText("hudbig", 0.375);
		barText.dontStagger = true;
		barText.sort = 1;
		barText hudSetParent(bar);
		barText hudSetPos("CENTER LEFT", "CENTER LEFT", PADDING_BG, 0);
		barText.label = &"Next Loadout in &&1";
		barText setValue(int(time));
		ui[ui.size] = barText;

		self thread uiLoadoutUpdateTime(barText, int(time));
	}

	foreach (el in ui)
	{
		el.archived = false;
		el.hidewheninmenu = true;
		el.foreground = true;
	}

	self.randomizer.ui.loadout = ui;

	self thread uiLoadoutFadeIn(0.5, 0.05);
	self thread uiLoadoutOnTimeEnd(time, 1.0, upcoming);
	self thread uiLoadoutOnPlayerDeath(upcoming);
	self thread uiLoadoutOnGameEnded();
}

uiLoadoutDestroy()
{
	self.randomizer.ui.loadout = hudDestroyRecursive(self.randomizer.ui.loadout);
	self notify("randomizer__ui_loadout_destroy");
}

uiLoadoutUpdateTime(barText, time)
{
	self endon("disconnect");
	self endon("randomizer__ui_loadout_destroy");

	for (;;)
	{
		self playLocalSound("mp_defcon_text_slide");
		wait 1.0;
		time--;
		barText setValue(time);

		if (time <= 0) break;
	}
}

uiLoadoutFadeIn(fadeTime, staggerTime)
{
	self endon("disconnect");
	self endon("randomizer__ui_loadout_destroy");

	staggerEls = [];
	instantEls = [];

	foreach (el in self.randomizer.ui.loadout)
	{
		el.targetAlpha = el.alpha;
		el.alpha = 0;

		if (isDefined(el.dontStagger) && el.dontStagger)
			instantEls[instantEls.size] = el;
		else
			staggerEls[staggerEls.size] = el;
	}

	foreach (el in instantEls)
	{
		el fadeOverTime(fadeTime);
		el.alpha = el.targetAlpha;
	}

	foreach (el in staggerEls)
	{
		el fadeOverTime(fadeTime);
		el.alpha = el.targetAlpha;
		wait staggerTime;
	}
}

uiLoadoutFadeOut(fadeTime)
{
	self endon("disconnect");
	self endon("randomizer__ui_loadout_destroy");

	foreach (el in self.randomizer.ui.loadout)
	{
		el fadeOverTime(fadeTime);
		el.alpha = 0.0;
	}

	wait fadeTime;
}

uiLoadoutOnTimeEnd(time, fadeOutTime, upcoming)
{
	self endon("disconnect");
	self endon("randomizer__ui_loadout_destroy");

	wait time;

	if (upcoming) self playLocalSound("mp_ingame_summary");

	self uiLoadoutFadeOut(fadeOutTime); // waits inside
	self thread uiLoadoutDestroy();
}

uiLoadoutOnPlayerDeath(upcoming)
{
	self endon("disconnect");
	self endon("randomizer__ui_loadout_destroy");

	if (upcoming) return;

	self waittill("death");

	self thread uiLoadoutDestroy();
}

uiLoadoutOnGameEnded()
{
	self endon("disconnect");
	self endon("randomizer__ui_loadout_destroy");

	level waittill("game_ended");

	self thread uiLoadoutDestroy();
}
