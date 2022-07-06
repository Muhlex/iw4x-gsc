// TODO: Akimbo default spawn weapon
// TODO: Power-Ups
// TODO: Rocket jumping
// TODO: Speed display / Inventory weapons display

#include scripts\_utility;

PICKUPTYPE_WEAPON = 0;
PICKUPTYPE_HEALTH = 1;

DMGCALC_FLAT = 0;
DMGCALC_MULTIPLY = 1;

init()
{
	setDvarIfUninitialized("scr_quake_enable", false);
	setDvarIfUninitialized("scr_quake_music", false);

	if (!getDvarInt("scr_quake_enable")) return;

	level.quake = spawnStruct();
	level.quake.music = !!getDvarInt("scr_quake_music");

	initDvars();
	initAssets();

	level thread OnGameEnded();
	level thread OnPlayerConnected();

	spawnPickups();

	waittillframeend;

	initHooks();

	if (level.quake.music)
	{
		disableMusic();
		ambientPlay("music_challenge_factory");
	}
}

initHooks()
{
	level.quake.origFuncs = spawnStruct();
	level.quake.origFuncs.callbackPlayerDamage = level.callbackPlayerDamage;
	level.quake.origFuncs.callbackPlayerKilled = level.callbackPlayerKilled;
	level.callbackPlayerDamage = ::OnPlayerDamage;
	level.callbackPlayerKilled = ::OnPlayerKilled;
}

initDvars()
{
	d = [];
	d["g_gravity"] = 1000;
	d["g_speed"] = 280;
	d["player_backSpeedScale"] = 0.85;
	d["player_strafeSpeedScale"] = 0.9;
	d["player_duckedSpeedScale"] = 0.75;
	d["player_proneSpeedScale"] = 0.75;
	d["player_breath_hold_time"] = 0;
	d["player_dmgtimer_timePerPoint"] = 0;
	d["player_dmgtimer_flinchTime"] = 0;
	d["mantle_enable"] = false;
	d["jump_slowdownEnable"] = false;
	d["jump_height"] = 68;
	d["jump_ladderPushVel"] = 256;
	d["bg_fallDamageMaxHeight"] = 800;
	d["bg_fallDamageMinHeight"] = 320;
	d["bg_rocketJump"] = true;
	d["bg_viewBobMax"] = 0;
	d["perk_quickDrawSpeedScale"] = 2147483647;
	d["perk_weapReloadMultiplier"] = 0.8;
	d["perk_weapSpreadMultiplier"] = 0.02;
	d["scr_showperksonspawn"] = false;

	foreach (key, value in d)
	{
		setDvar(key, value);

		if (stringStartsWith(key, "perk_"))
			makeDvarServerInfo(key, value);
	}
}

initClientDvars()
{
	self setClientDvars(
		"cg_gun_y", -1.5,
		"cg_gun_z", -3,
		"cg_drawBreathHint", false,
		"cg_crosshairAlphaMin", 1.0,
		"compassObjectiveWidth", 18, // minimap
		"compassObjectiveHeight", 16, // minimap
		"compassObjectiveIconWidth", 18, // full map
		"compassObjectiveIconHeight", 16 // full map
	);
}

initAssets()
{
	level.quake.weapons = [];
	level.quake.weaponsMap = [];
	// baseName, spread, ammoClip, ammoStockStart, ammoStock, dmgCloseDist, dmgFarDist, dmgClose, dmgFar, dmgCalcType, dmgHeadshotMult, fireTime, icon
	_ = undefined;
	FLAT = DMGCALC_FLAT;
	MULT = DMGCALC_MULTIPLY;
	initWeaponConfig("beretta",      1.0,  _,  90,  _, 100,  800,  40,  10,   FLAT, 1.0,   _, "hud_icon_m9beretta");
	initWeaponConfig("coltanaconda", 0.5,  _,  12,  _, 100,  400,  80,  40,   FLAT, 3.0,   _, "hud_icon_colt_anaconda");
	initWeaponConfig("famas",        0.75, _,  30,  _, 200,  800,  40,  30,   FLAT, 1.0,   _, "hud_icon_famas");
	initWeaponConfig("fal",          0.5,  _,  20,  _, 400, 1200,  60,  50,   FLAT, 1.0,   _, "hud_icon_fnfal");
	initWeaponConfig("uzi",          2.0,  _,  64,  _,  60,  600,  40,  10,   FLAT, 1.0,   _, "hud_icon_mini_uzi");
	initWeaponConfig("m240",         1.0,  _, 100,  _, 100, 1000,  20,   8,   FLAT, 1.0,   _, "hud_icon_m240");
	initWeaponConfig("cheytac",      0.25, _,  10,  _,   0,    1, 100, 100,   FLAT, 4.0,   _, "hud_icon_cheytac");
	initWeaponConfig("spas12",       5.0,  _,   8,  _, 150,  250,  35,  20,   FLAT, 1.0,   _, "hud_icon_spas12");
	initWeaponConfig("ranger",       8.0,  _,   6,  _, 100,  250,  65,  15,   FLAT, 1.0,   _, "hud_icon_sawed_off");
	initWeaponConfig("m79",          0.0,  4,  12, 20, 375, 1200,   4.0, 2.0, MULT, 1.0, 0.5, "hud_icon_m79");
	initWeaponConfig("rpg",          0.0,  4,  12, 20,  64,  200,   0.4, 2.0, MULT, 1.0, 0.6, "hud_icon_rpg_dpad");

	effects = [];
	effects["pickup_weapon_available"] = loadFX("misc/ui_flagbase_silver");
	effects["pickup_unavailable"] = loadFX("misc/ui_flagbase_red");
	effects["pickup_health_available"] = loadFX("misc/flare_ambient_green");
	effects["pickup_health_unavailable"] = loadFX("misc/glow_stick_glow_green");
	effects["gain_health"] = loadFX("misc/aircraft_light_wingtip_green");
	level.quake.effects = effects;
}

initWeaponConfig(baseName, spread, ammoClip, ammoStockStart, ammoStock, dmgCloseDist, dmgFarDist, dmgClose, dmgFar, dmgCalcType, dmgHeadshotMult, fireTime, icon)
{
	c = spawnStruct();
	c.baseName = baseName;
	c.name = baseName + "_mp";
	c.spread = spread;
	c.ammoClip = coalesce(ammoClip, weaponClipSize(c.name));
	c.ammoStockStart = coalesce(ammoStockStart, weaponStartAmmo(c.name));
	c.ammoStock = coalesce(ammoStock, weaponMaxAmmo(c.name));
	c.dmgCloseDist = dmgCloseDist;
	c.dmgFarDist = dmgFarDist;
	c.dmgClose = dmgClose;
	c.dmgFar = dmgFar;
	c.dmgCalcType = dmgCalcType;
	c.dmgHeadshotMult = dmgHeadshotMult;
	c.fireTime = fireTime;
	c.icon = icon;
	precacheShader(icon);

	level.quake.weapons[level.quake.weapons.size] = c;
	level.quake.weaponsMap[c.name] = c;
}

disableMusic()
{
	for (i = 0; i < game["music"]["suspense"].size; i++)
		game["music"]["suspense"][i] = "null";

	game["music"]["spawn_allies"] = "null";
	game["music"]["winning_allies"] = "null";
	game["music"]["losing_allies"] = "null";
	game["music"]["spawn_axis"] = "null";
	game["music"]["winning_axis"] = "null";
	game["music"]["losing_axis"] = "null";
	game["music"]["winning_time"] = "null";
	game["music"]["losing_time"] = "null";
	game["music"]["winning_score"] = "null";
	game["music"]["losing_score"] = "null";
}

OnGameEnded()
{
	level waittill("game_ended", winner);

	if (level.quake.music)
		ambientStop(1.0);
}

OnPlayerConnected()
{
	for (;;)
	{
		level waittill("connected", player);

		player.quake = spawnStruct();
		player.quake.inventory = [];

		player initClientDvars();
		player thread OnPlayerSpawned();
		player thread OnPlayerTryWeaponChange();
		player thread OnPlayerWeaponChanged();
		player thread OnPlayerWeaponFired();
	}
}

OnPlayerSpawned()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("spawned_player");

		self takeAllWeapons();
		self maps\mp\_utility::_clearPerks();

		self setPlayerModel(game[self.team + "_model"]["RIOT"]);
		// Configured to allow instant scoping:
		self maps\mp\perks\_perks::givePerk("specialty_quickdraw");
		// Configured to only be slightly faster:
		self maps\mp\perks\_perks::givePerk("specialty_fastreload");

		spawnWeaponConfig = level.quake.weapons[0];
		self maps\mp\_utility::_giveWeapon(spawnWeaponConfig.name);
		self setSpawnWeapon(spawnWeaponConfig.name);
		self setWeaponAmmoStock(spawnWeaponConfig.name, spawnWeaponConfig.ammoStockStart);
		self setSpreadOverrideCustom(spawnWeaponConfig.spread);
		self allowADS(weaponClass(spawnWeaponConfig.name) == "sniper");

		self common_scripts\utility::_disableWeaponSwitch(); // replaced with custom weapon change logic
		self allowSprint(false);
		self player_recoilScaleOn(0); // 0 - 100 (in percent)
		self thread preventProneThink();
	}
}

OnPlayerTryWeaponChange()
{
	level endon("game_ended");
	self endon("disconnect");

	self notifyOnPlayerCommand("quake__changeweapon", "weapnext");
	self notifyOnPlayerCommand("quake__changeweapon", "weapprev");

	// We want weapon changing to not have stow times, thus we recreate it:
	// TODO: Allow action slot usage.
	for (;;)
	{
		self waittill("quake__changeweapon");

		prevWeaponName = self getCurrentPrimaryWeapon();

		foreach (weaponName in self getWeaponsListPrimaries())
		{
			if (weaponName == prevWeaponName) continue;

			self switchToWeaponFast(weaponName);
			break;
		}
	}
}

switchToWeaponFast(weaponName)
{
	oldWeaponName = self getCurrentPrimaryWeapon();
	if (oldWeaponName == weaponName) return;

	clipR = undefined;
	clipL = undefined;
	stock = undefined;
	if (oldWeaponName != "none")
	{
		clipR = self getWeaponAmmoClip(oldWeaponName, "right");
		clipL = self getWeaponAmmoClip(oldWeaponName, "left");
		stock = self getWeaponAmmoStock(oldWeaponName);
		self takeWeapon(oldWeaponName);
	}

	self switchToWeapon(weaponName);
	self playLocalSound("weap_raise");

	wait 0.05;

	if (oldWeaponName != "none")
	{
		self maps\mp\_utility::_giveWeapon(oldWeaponName);
		self setWeaponAmmoClip(oldWeaponName, clipR, "right");
		if (isSubStr(oldWeaponName, "_akimbo"))
			self setWeaponAmmoClip(oldWeaponName, clipL, "left");
		self setWeaponAmmoStock(oldWeaponName, stock);
	}
}

OnPlayerWeaponChanged()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("weapon_change", weaponName);

		if (weaponName == "none") continue;

		self allowADS(weaponClass(weaponName) == "sniper");

		weaponConfig = level.quake.weaponsMap[weaponName];
		if (!isDefined(weaponConfig)) continue;

		self setSpreadOverrideCustom(weaponConfig.spread);
	}
}

OnPlayerWeaponFired()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("weapon_fired", weaponName);

		self iPrintLnBold(weaponName + " fired");

		weaponConfig = level.quake.weaponsMap[weaponName];
		if (!isDefined(weaponConfig)) continue;

		if (isDefined(weaponConfig.fireTime))
			self thread handleWeaponFireTime(weaponConfig.fireTime);
	}
}

handleWeaponFireTime(fireTime)
{
	self common_scripts\utility::_disableWeapon();
	wait fireTime;
	self common_scripts\utility::_enableWeapon();
}

OnPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	customDamage = iDamage;
	customHitLoc = sHitLoc;
	weaponConfig = level.quake.weaponsMap[sWeapon];

	if (sMeansOfDeath == "MOD_MELEE")
	{
		customDamage = 50;
	}
	else if (isDefined(weaponConfig))
	{
		isHeadshot = maps\mp\gametypes\_damage::isHeadShot(sWeapon, sHitLoc, sMeansOfDeath, eAttacker);
		distance = clamp(distance(eAttacker getEye(), vPoint), weaponConfig.dmgCloseDist, weaponConfig.dmgFarDist);

		customDamage = remapRange(
			distance,
			weaponConfig.dmgCloseDist, weaponConfig.dmgFarDist,
			weaponConfig.dmgClose,     weaponConfig.dmgFar
		);
		customHitLoc = "none";

		if (weaponConfig.dmgCalcType == DMGCALC_MULTIPLY)
		{
			customDamage *= iDamage;
		}

		if (isHeadshot)
		{
			customDamage *= weaponConfig.dmgHeadshotMult;
			if (weaponConfig.dmgHeadshotMult > 1.0)
				customHitLoc = "head";
		}

		customDamage = int(customDamage);
	}

	self [[level.quake.origFuncs.callbackPlayerDamage]](eInflictor, eAttacker, customDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, customHitLoc, psOffsetTime);
}

OnPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	if (isDefined(attacker) && isPlayer(attacker) && attacker != self)
		attacker giveHealth(100);

	self.droppedDeathWeapon = true; // Prevent weapon drops under any circumstances

	if (getDvarInt("scr_death_drop_weapon", 1))
	{
		weaponConfig = level.quake.weaponsMap[self getCurrentWeapon()];
		if (isDefined(weaponConfig))
			self dropWeaponForDeath(weaponConfig);
	}

	self [[level.quake.origFuncs.callbackPlayerKilled]](eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);
}

spawnCustomItemWeapon(origin, weaponName, ammo)
{
	item = spawn("weapon_" + weaponName, origin);
	item itemWeaponSetAmmo(0, 0, 0);
	item.weaponName = weaponName;
	item.ammo = ammo;
	item thread OnCustomItemWeaponThink();
	return item;
}

OnCustomItemWeaponDroppedUse()
{
	self endon("death");

	for (;;)
	{
		self waittill("trigger", player, droppedItem);

		self thread OnCustomItemWeaponUse(player, droppedItem);
		// TODO: ...
	}
}

OnCustomItemWeaponUse(player, droppedItem)
{
	if (isDefined(droppedItem))
		droppedItem delete();

	player playerInvWeaponReplenishAmmo(self.weaponName, self.ammo);
}

OnCustomItemWeaponThink()
{
	self endon("death");
	self endon("trigger");

	for (;;)
	{
		// Could also use a trigger but too many entities can cause problems. Thus we do it on a timer:
		wait 0.1;

		playersInRadius = getPosInRadiusToPlayers(self.origin, 64);
		if (playersInRadius.size == 0)
			continue;

		weaponConfig = level.quake.weaponsMap[self.weaponName];

		targetPlayer = undefined;
		foreach (player in arrayShuffle(playersInRadius))
		{
			if (!player hasWeapon(self.weaponName)) continue;

			clipFull = (player getWeaponAmmoClip(self.weaponName) == weaponConfig.ammoClip);
			stockFull = (player getWeaponAmmoStock(self.weaponName) == weaponConfig.ammoStock);
			if (!clipFull || !stockFull)
			{
				targetPlayer = player;
				break;
			}
		}

		if (!isDefined(targetPlayer))
			continue;

		self thread customItemWeaponThinkTrigger(targetPlayer);
		break;
	}
}
customItemWeaponThinkTrigger(targetPlayer)
{
	self notify("trigger", targetPlayer, undefined);
	self delete();
}

preventProneThink()
{
	self endon("disconnect");
	self endon("death");

	for (;;)
	{
		if (self getStance() == "prone")
			self setStance("crouch");

		wait 0.05;
	}
}

dropWeaponForDeath(weaponConfig)
{
	iPrintLnBold("drop weapon for death: ^3" + weaponConfig.name);

	// TODO: ...
}

getSpawnPointEnts()
{
	targetnames = "" +
	"flag_primary gtnw_zone bombzone ctf_flag_allies ctf_flag_axis " +
	"sd_bomb_pickup_trig sab_bomb_pickup_trig sab_bomb_axis sab_bomb_allies hq_hardpoint";

	ents = [];
	foreach (targetname in strTok(targetnames, " "))
		ents = arrayCombine(ents, getEntArray(targetname, "targetname"));

	// foreach (hq in getEntArray("hq_hardpoint", "targetname"))
	// {
	// 	thread point3D(hq.origin, (1, 0, 0), 9999999);
	// 	thread line3D(hq.origin, hq.origin + anglesToForward(hq.angles) * 48, (1, 0, 0), 9999999);
	// }

	// foreach (ent in ents)
	// 	thread text3D(ent.origin, ent.targetname, (0, 1, 1), 0.5, 0.66, 999999);

	return ents;
}

spawnPickups()
{
	// IMPORTANT: Most of these spawn point entities are cleared in this same frame
	// due to them not being necessary for the gamemode at hand!

	spawnPointStructs = [];
	foreach (ent in getSpawnPointEnts()) {
		struct = spawnStruct();
		struct.ent = ent;
		origin = ent.origin;
		if (ent.targetname == "hq_hardpoint")
			origin += anglesToForward(ent.angles) * 48;
		struct.origin = origin;
		spawnPointStructs[spawnPointStructs.size] = struct;
	}

	waittillframeend; // _gameobjects.gsc will remove unnecessary objects for the current gamemode

	validSpawnOrigins = [];
	foreach (struct in spawnPointStructs) {
		// If the entity wasn't killed by _gameobjects.gsc, don't spawn a pickup there:
		if (isDefined(struct.ent)) continue;

		origin = bulletTrace(struct.origin + (0, 0, 32), struct.origin + (0, 0, -128), false)["position"];

		if (getPosInRadiusToPositions(origin, validSpawnOrigins, 256)) continue;

		validSpawnOrigins[validSpawnOrigins.size] = origin;
	}

	pickupWeapons = arraySlice(level.quake.weapons, 1);
	healthPickupMaxCount = 4;

	foreach (i, origin in arrayShuffle(validSpawnOrigins))
	{
		if (i < pickupWeapons.size)
			spawnWeaponPickup(origin, pickupWeapons[i]);
		else if (i < pickupWeapons.size + healthPickupMaxCount)
			spawnHealthPickup(origin);
		else
			break;
	}
}

spawnWeaponPickup(origin, weaponConfig)
{
	pickup = spawn("script_model", origin + (0, 0, 32)); // linking item weapons to a script_origin looks worse
	pickup.type = PICKUPTYPE_WEAPON;
	pickup.weaponConfig = weaponConfig;
	trace = bulletTrace(origin + (0, 0, 2), origin + (0, 0, -4), false);
	pickup.particleOrigin = trace["position"];
	pickup.particleAngles = vectorToAngles(trace["normal"]);

	pickup spawnItemForWeaponPickup();
	pickup animatePickup();

	objectiveID = maps\mp\gametypes\_gameobjects::getNextObjID();
	objective_add(objectiveID, "invisible", (0, 0, 0));
	objective_position(objectiveID, origin);
	objective_state(objectiveID, "active");
	objective_icon(objectiveID, weaponConfig.icon);
	pickup.objectiveID = objectiveID;

	pickup thread OnPickupItemWeaponUse();
}

spawnItemForWeaponPickup()
{
	weaponConfig = self.weaponConfig;
	totalAmmo = (weaponConfig.ammoClip + weaponConfig.ammoStockStart);

	item = spawnCustomItemWeapon(self.origin, weaponConfig.name, totalAmmo);
	item.angles = self.angles;
	item linkTo(self);
	self.item = item;
}

OnPickupItemWeaponUse()
{
	self endon("death");

	for (;;)
	{
		self.item waittill("trigger", player, droppedItem);

		self.item thread OnCustomItemWeaponUse(player, droppedItem);

		self hide();
		self animatePickupParticle(false);
		objective_state(self.objectiveID, "invisible");

		playerCount = (level.teamCount["allies"] + level.teamCount["axis"]);
		// wait clamp(30.0 - (3.0 * playerCount), 3.0, 24.0);
		wait 4.0;

		self show();
		self animatePickupParticle(true);
		objective_state(self.objectiveID, "active");
		self spawnItemForWeaponPickup();
	}
}

spawnHealthPickup(origin)
{
	pickup = spawn("script_model", origin + (0, 0, 32));
	pickup.type = PICKUPTYPE_HEALTH;
	pickup.particleOrigin = origin + (0, 0, 8);
	pickup.particleAngles = (-90, 0, 0);

	pickup setModel("weapon_oma_pack");

	pickup animatePickup();

	pickup thread OnHealthPickupUse();
}

OnHealthPickupUse()
{
	self endon("death");

	for (;;)
	{
		// Could also use a trigger but too many entities can cause problems. Thus we do it on a timer:
		wait 0.1;

		playersInRadius = getPosInRadiusToPlayers(self.origin, 64);
		if (playersInRadius.size == 0)
			continue;

		maxhealth = maps\mp\gametypes\_tweakables::getTweakableValue("player", "maxhealth");

		targetPlayer = undefined;
		foreach (player in arrayShuffle(playersInRadius))
		{
			if (player.health < maxhealth)
			{
				targetPlayer = player;
				break;
			}
		}

		if (!isDefined(targetPlayer))
			continue;

		targetPlayer giveHealth(100, maxhealth);

		targetPlayer playLocalSound("intelligence_pickup");

		self hide();
		self animatePickupParticle(false);

		wait 10.0;

		self show();
		self animatePickupParticle(true);
	}
}

animatePickup()
{
	self thread animatePickupZ();
	self thread animatePickupYaw();
	self animatePickupParticle(true);
}
animatePickupZ()
{
	self endon("death");

	for (;;)
	{
		self moveZ(16, 1.0, 0.5, 0.5);
		wait 1.0;
		self moveZ(-16, 1.0, 0.5, 0.5);
		wait 1.0;
	}
}
animatePickupYaw()
{
	self endon("death");

	for (;;)
	{
		self rotateYaw(360, 3.0, 0, 0);
		wait 3.0;
	}
}
animatePickupParticle(available)
{
	if (isDefined(self.particleEmitter))
		self.particleEmitter delete();

	effect = undefined;
	origin = self.particleOrigin;

	if (self.type == PICKUPTYPE_WEAPON)
	{
		effect = level.quake.effects[ternary(available, "pickup_weapon_available", "pickup_unavailable")];
	}
	else if (self.type == PICKUPTYPE_HEALTH)
	{
		effect = level.quake.effects[ternary(available, "pickup_health_available", "pickup_health_unavailable")];
		if (!available) origin += (0, 0, 24);
	}

	emitter = spawnFX(
		effect,
		origin,
		anglesToForward(self.particleAngles),
		anglesToRight(self.particleAngles)
	);
	triggerFX(emitter);

	self thread OnWeaponPickupDeathParticle(emitter);
	self.particleEmitter = emitter;
}
OnWeaponPickupDeathParticle(emitter)
{
	self waittill("death");
	emitter delete();
}

giveHealth(amount, maxhealthOverride)
{
	maxhealth = coalesce(maxhealthOverride, maps\mp\gametypes\_tweakables::getTweakableValue("player", "maxhealth"));
	prevHealth = self.health;

	self.health += amount;
	if (self.health > maxhealth)
		self.health = maxhealth;

	if (self.health != prevHealth)
		self thread OnGiveHealthFX();
}

OnGiveHealthFX()
{
	self notify("quake__give_health_fx_start");

	self endon("disconnect");
	self endon("death");
	self endon("quake__give_health_fx_start");

	self stopHealthFX();
	wait 0.05;
	self playHealthFX();

	wait 1.0;

	self stopHealthFX();
}
playHealthFX()
{
	playFXOnTag(level.quake.effects["gain_health"], self, "j_shouldertwist_le");
	playFXOnTag(level.quake.effects["gain_health"], self, "j_shouldertwist_ri");
	playFXOnTag(level.quake.effects["gain_health"], self, "j_knee_bulge_le");
	playFXOnTag(level.quake.effects["gain_health"], self, "j_knee_bulge_ri");
}
stopHealthFX()
{
	stopFXOnTag(level.quake.effects["gain_health"], self, "j_shouldertwist_le");
	stopFXOnTag(level.quake.effects["gain_health"], self, "j_shouldertwist_ri");
	stopFXOnTag(level.quake.effects["gain_health"], self, "j_knee_bulge_le");
	stopFXOnTag(level.quake.effects["gain_health"], self, "j_knee_bulge_ri");
}

getPosInRadiusToPositions(pos, positions, radius)
{
	foreach (p in positions)
		if (distanceSquared(pos, p) < radius * radius)
			return true;

	return false;
}

getPosInRadiusToPlayers(pos, radius)
{
	players = [];

	foreach (player in level.players)
	{
		if (player.team != "allies" && player.team != "axis") continue;
		if (!isAlive(player)) continue;

		if (distanceSquared(pos, player getTagOrigin("pelvis")) < radius * radius)
			players[players.size] = player;
	}

	return players;
}

setSpreadOverrideCustom(spread)
{
	if (spread > 1.0)
	{
		if (maps\mp\_utility::_hasPerk("specialty_bulletaccuracy"))
			self maps\mp\_utility::_unsetPerk("specialty_bulletaccuracy");

		self setSpreadOverride(int(spread));
	}
	else
	{
		// Cannot set spread override to float values, so we work around it using the perk.
		// It must be configured to multiply spread by 0.02 (important)!
		if (!maps\mp\_utility::_hasPerk("specialty_bulletaccuracy"))
			self maps\mp\perks\_perks::givePerk("specialty_bulletaccuracy");

		self setSpreadOverride(int(max(spread * 50, 1)));
	}
}

playerInvInit()
{}

playerInvClear()
{}

playerInvWeaponAdd()
{}

playerInvWeaponRemove()
{}

playerInvWeaponReload()
{}

playerInvWeaponReplenishAmmo(weaponName, ammo)
{
	// TODO: actually use the inventory
	weaponConfig = level.quake.weaponsMap[weaponName];

	clip = self getWeaponAmmoClip(weaponName);
	clipMissing = (weaponConfig.ammoClip - clip);
	clipAdd = clipMissing;
	if (ammo < clipMissing)
		clipAdd = ammo;
	self setWeaponAmmoClip(weaponName, clip + clipAdd);
	ammo -= clipAdd;

	if (ammo == 0) return;

	stock = self getWeaponAmmoStock(weaponName);
	stockMissing = (weaponConfig.ammoStock - stock);
	stockAdd = stockMissing;
	if (ammo < stockMissing)
		stockAdd = ammo;
	self setWeaponAmmoStock(weaponName, stock + stockAdd);
}

playerInvWeaponUpdateRealAmmo()
{

}
