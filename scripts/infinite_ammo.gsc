#include scripts\_utility;

init()
{
	INFINITE_MODES = spawnStruct();
	INFINITE_MODES.NONE = 0;
	INFINITE_MODES.CLIP = 1;
	INFINITE_MODES.STOCK = 2;

	setDvarIfUninitialized("scr_infinite_ammo", INFINITE_MODES.NONE);
	mode = getDvarInt("scr_infinite_ammo");

	level.infiniteAmmo = spawnStruct();
	level.infiniteAmmo.INFINITE_MODES = INFINITE_MODES;
	level.infiniteAmmo.mode = mode;

	setDvar("player_sustainAmmo", (mode == INFINITE_MODES.CLIP));

	level thread OnPlayerConnected();
}

OnPlayerConnected()
{
	for (;;)
	{
		level waittill("connected", player);

		player thread OnPlayerReloaded();
		player thread OnPlayerWeaponChanged();
	}
}

OnPlayerReloaded()
{
	self endon("disconnect");

	INFINITE_MODES = level.infiniteAmmo.INFINITE_MODES;
	mode = level.infiniteAmmo.mode;

	for (;;)
	{
		self waittill("reload");

		if (mode != INFINITE_MODES.NONE) {
			self setWeaponAmmoStockToClipsize(self getCurrentWeapon());
		}
	}
}

OnPlayerWeaponChanged()
{
	self endon("disconnect");

	INFINITE_MODES = level.infiniteAmmo.INFINITE_MODES;
	mode = level.infiniteAmmo.mode;

	for (;;)
	{
		self waittill("weapon_change", weaponName);

		if (mode != INFINITE_MODES.NONE) {
			self setWeaponAmmoStockToClipsize(weaponName);
		}
	}
}
