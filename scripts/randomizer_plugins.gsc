#include scripts\_utility;

getItems(items)
{
	items = coalesce(items, []);

	items = addItem(items, "offhands", incendiary());

	return items;
}

addItem(items, type, item)
{
	index = coalesce(items[type].size, 0);
	items[type][index] = item;
	return items;
}

// ##### DEFINITIONS START #####

incendiary()
{
	incendiary = spawnStruct();
	incendiary.name = "incendiary_grenade_mp";
	incendiary.image = "hud_burningbarrelicon";
	incendiary.iString = &"Incendiary Grenade";
	incendiary.iStringDesc = &"Area denial by fire.";
	incendiary.customGive = scripts\incendiary::giveIncendiary;
	incendiary.customTake = scripts\incendiary::takeIncendiary;
	return incendiary;
}
