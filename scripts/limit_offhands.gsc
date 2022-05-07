init()
{
	setDvarIfUninitialized("scr_offhand_max_ammo", -1);

	level thread OnPlayerConnected();
}

OnPlayerConnected()
{
	for (;;)
	{
		level waittill("connected", player);

		player thread OnPlayerLoadoutGiven();
	}
}

OnPlayerLoadoutGiven()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("giveLoadout");

		maxAmmo = getDvarInt("scr_offhand_max_ammo");

		if (maxAmmo < 0) return;

		foreach (name in self getWeaponsListOffhands())
		{
			ammo = self getWeaponAmmoClip(name);
			if (ammo > maxAmmo)
				self setWeaponAmmoClip(name, maxAmmo);
		}
	}
}
