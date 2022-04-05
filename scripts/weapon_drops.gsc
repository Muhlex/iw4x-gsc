init()
{
	setDvarIfUninitialized("scr_death_drop_weapon", true);

	level.weaponDrops = spawnStruct();

	waittillframeend;

	level.weaponDrops.origFuncs = spawnStruct();
	level.weaponDrops.origFuncs.callbackPlayerKilled = level.callbackPlayerKilled;
	level.callbackPlayerKilled = ::OnPlayerKilled;
}

OnPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	if (!getDvarInt("scr_death_drop_weapon"))
		self.droppedDeathWeapon = true;

	self [[level.weaponDrops.origFuncs.callbackPlayerKilled]](eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);
}
