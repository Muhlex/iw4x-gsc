#include scripts\_utility;

// ##### PUBLIC START #####

getItems(items)
{
	items = coalesce(items, []);

	// Add custom items here:
	items = addItem(items, incendiary());

	return items;
}

// ##### PUBLIC END #####

addItem(items, item)
{
	if (isDefined(item.iString))
		precacheString(item.iString);
	if (isDefined(item.iStringDesc))
		precacheString(item.iStringDesc);

	item.custom = true;

	type = item.type;
	index = coalesce(items[type].size, 0);
	items[type][index] = item;
	return items;
}

// ##### DEFINITIONS START #####

incendiary()
{
	incendiary = spawnStruct();
	incendiary.name = "incendiary_grenade_mp";
	incendiary.type = "offhand";
	incendiary.image = "hud_burningbarrelicon";
	incendiary.iString = &"Incendiary Grenade";
	incendiary.iStringDesc = &"Area denial by fire.";
	incendiary.customGive = scripts\incendiary::giveIncendiary;
	incendiary.customTake = scripts\incendiary::takeIncendiary;
	incendiary.customHas = scripts\incendiary::hasIncendiary;
	return incendiary;
}
