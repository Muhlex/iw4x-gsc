#include scripts\_utility;

DIFF_MODE_NONE = 0;
DIFF_MODE_NEG = 1;
DIFF_MODE_POS = 2;
DIFF_MODE_ALL = 3;

HEALTH_POS_BOTTOM = 0;
HEALTH_POS_CENTER = 1;
HEALTH_POS_CENTER_OFFSET = 2;

init()
{
	setDvarIfUninitialized("scr_extendedhud_health_enable", false);
	setDvarIfUninitialized("scr_extendedhud_health_position", 0);
	setDvarIfUninitialized("scr_extendedhud_health_show_diff", DIFF_MODE_NONE);
	setDvarIfUninitialized("scr_extendedhud_damage_enable", false);
	setDvarIfUninitialized("scr_extendedhud_damage_batching_time", 1.0);

	level thread OnPlayerConnected();
	scripts\_overrides::subscribe("finishPlayerDamage", ::OnPlayerDamageTaken);
}

OnPlayerConnected()
{
	for (;;)
	{
		level waittill("connected", player);

		player.extendedhud = spawnStruct();
		player.extendedhud.ui = [];
		player thread OnPlayerSpawned();
	}
}

OnPlayerSpawned()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("spawned_player");

		if (getDvarInt("scr_extendedhud_health_enable"))
			self createHealthUI();
	}
}

OnPlayerDamageTaken(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, stunFraction)
{
	dmgHudEnabled = !!getDvarInt("scr_extendedhud_damage_enable");
	if (dmgHudEnabled && isDefined(eAttacker) && isPlayer(eAttacker) && self != eAttacker)
		eAttacker thread showDamageDealtPopup(self, iDamage);
}

createHealthUI()
{
	position = getDvarInt("scr_extendedhud_health_position");

	healthEl = self hudCreateText("hudbig", 1.0625);
	if (position == HEALTH_POS_CENTER)
		healthEl hudSetPos("CENTER CENTER", "CENTER CENTER", 0, 72);
	else if (position == HEALTH_POS_CENTER_OFFSET)
		healthEl hudSetPos("CENTER RIGHT", "CENTER CENTER", -72, 64);
	else // HEALTH_POS_BOTTOM
		healthEl hudSetPos("BOTTOM CENTER", "BOTTOM CENTER", 0, -33);
	healthEl.foreground = true;
	healthEl.hidewheninmenu = true;
	healthEl.archived = false;
	healthEl.glowAlpha = true;
	healthEl.label = &"";
	healthEl.sort = 200;
	healthEl.position = position;

	self thread OnPlayerDeleteHealthUI(healthEl);
	self thread OnPlayerUpdateHealthUI(healthEl);
}

OnPlayerDeleteHealthUI(healthEl)
{
	self endon("disconnect");
	self waittillAnyEntities(level, "game_ended", self, "death", self, "joined_team", self, "joined_spectators");

	healthEl destroy();
}

OnPlayerUpdateHealthUI(healthEl)
{
	self endon("disconnect");
	healthEl endon("death");

	// Don't use self.maxhealth as that gets reduced when disabling health regeneration!
	maxhealth = maps\mp\gametypes\_tweakables::getTweakableValue("player", "maxhealth");
	diffMode = getDvarInt("scr_extendedhud_health_show_diff");

	healthPrev = self.health;
	self updateHealthUI(healthEl, maxhealth, healthPrev, diffMode, true);

	for (;;)
	{
		self updateHealthUI(healthEl, maxhealth, healthPrev, diffMode);
		healthPrev = self.health;
		wait 0.05;
	}
}

updateHealthUI(healthEl, maxhealth, healthPrev, diffMode, forceUpdate)
{
	forceUpdate = coalesce(forceUpdate, false);

	healthDiff = self.health - healthPrev;
	if (healthDiff == 0 && !forceUpdate) return;

	healthFrac = self.health / maxhealth;
	healthProxToHalf = (1 - abs(healthFrac - 0.5)) * 2;
	healthGlowAlpha = (1 - healthFrac + 0.75) * 0.33;

	color = (
		(1 - healthFrac) + healthProxToHalf * 0.25,
		healthFrac + healthProxToHalf * 0.25,
		0.2
	);

	glowColor = (
		((1 - healthFrac) * 0.6 + healthProxToHalf) * healthGlowAlpha,
		(healthFrac * 0.6 + healthProxToHalf) * healthGlowAlpha,
		healthGlowAlpha
	);

	healthEl setValue(self.health);
	healthEl.color = color;
	healthEl.glowColor = glowColor;

	if (diffMode == DIFF_MODE_NONE) return;
	if (diffMode == DIFF_MODE_NEG && healthDiff > 0) return;
	if (diffMode == DIFF_MODE_POS && healthDiff < 0) return;

	self thread showHealthDiffPopup(healthDiff, healthEl);
}

showHealthDiffPopup(healthDiff, healthEl)
{
	if (healthDiff == 0) return;

	positive = (healthDiff > 0);

	diffEl = self hudCreateText("hudbig", ternary(positive, 1.1875, 0.75));
	diffEl hudSetParent(healthEl);
	diffEl.foreground = true;
	diffEl.hidewheninmenu = true;
	diffEl.archived = false;
	diffEl.glowAlpha = true;
	diffEl.color = (1.0, 1.0, 1.0);
	diffEl.alpha = 0.0;
	diffEl.sort = 201;
	horizontal = ternary(healthEl.position == HEALTH_POS_CENTER_OFFSET, "RIGHT", "CENTER");
	if (positive)
	{
		diffEl hudSetPos("BOTTOM " + horizontal, "TOP " + horizontal, 0, -4);
		diffEl.label = &"+";
		diffEl.color = (0.6, 1.0, 0.6);
		diffEl.glowColor = (0.3, 0.8, 0.3);
	}
	else
	{
		diffEl hudSetPos("TOP " + horizontal, "BOTTOM " + horizontal, 0, -8);
		diffEl.color = (1.0, 0.75, 0.8);
		diffEl.glowColor = (1.0, 0.5, 0.5);
	}
	diffEl setValue(healthDiff);

	transitionTime = ternary(positive, 1.8, 0.6);
	fadeInTime = transitionTime * 0.1;
	fadeOutTime = transitionTime * 0.3;

	diffEl fadeOverTime(fadeInTime);
	diffEl.alpha = 1.0;

	diffEl.x += 362.6666; // moveOverTime buggyness yay
	diffEl moveOverTime(transitionTime);
	diffEl.x -= 362.6666;
	if (positive)
		diffEl.y += ternary(healthEl.position == HEALTH_POS_BOTTOM, -64, -24);
	else
		diffEl.y += 16;
	wait transitionTime - fadeOutTime;

	diffEl fadeOverTime(fadeOutTime);
	diffEl.alpha = 0.0;
	wait fadeOutTime;

	diffEl destroy();
}

showDamageDealtPopup(victim, damage)
{
	ui = self.extendedhud.ui;
	dmgEl = ui["damage"];

	if (!isDefined(dmgEl) || dmgEl.leaving)
	{
		dmgEl = self hudCreateText("default", 1.0);
		dmgEl hudSetPos("BOTTOM RIGHT", "CENTER CENTER", 48, -16);
		dmgEl.foreground = true;
		dmgEl.hidewheninmenu = true;
		dmgEl.archived = false;
		dmgEl.glowAlpha = true;
		dmgEl.color = (1.0, 0.75, 0.8);
		dmgEl.glowColor = (1.0, 0.5, 0.5);
		dmgEl.alpha = 0.0;
		dmgEl.label = &"-";
		dmgEl setValue(damage);

		dmgEl.value = damage;
		dmgEl.leaving = false;

		ui["damage"] = dmgEl;
		self.extendedhud.ui = ui;

		dmgEl fadeOverTime(0.1);
		dmgEl.alpha = 1.0;
	}
	else
	{
		newValue = dmgEl.value + damage;
		dmgEl setValue(newValue);
		dmgEl.value = newValue;
		dmgEl notify("extendedhud__cancel_batch_timeout");
	}

	dmgEl thread OnDamageDealtPopupTimeout();
}

OnDamageDealtPopupTimeout()
{
	self endon("death");
	self endon("extendedhud__cancel_batch_timeout");

	wait getDvarFloat("scr_extendedhud_damage_batching_time");

	self.leaving = true;

	transitionTime = 0.5;

	self fadeOverTime(transitionTime);
	self.alpha = 0.0;

	self.x += 362.6666; // moveOverTime buggyness yay
	self moveOverTime(transitionTime);
	self.x -= 362.6666;
	self.y += -32;

	wait transitionTime;

	self destroy();
}
