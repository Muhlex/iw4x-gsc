// TODO: Improve OnMapLoadTimeout for round based gamemodes.

#include scripts\_utility;

init()
{
	if (!storageHas("_lifecycle__guids"))
		storageSet("_lifecycle__guids", "");

	level thread OnPlayerConnected();
	level thread OnMapLoadTimeout();
}

// Still available after a player disconnects, as long as a reference to their playerstruct is held.
getPlayerNameSafe()
{
	return self._lifecycle.name;
}

OnPlayerConnected()
{
	for (;;)
	{
		level waittill("connected", player);

		player thread OnPlayerDisconnected();

		player._lifecycle = spawnStruct();
		player._lifecycle.name = player.name;

		guids = getGUIDs();
		if (arrayContains(guids, player.guid)) continue;

		guids[guids.size] = player.guid;
		setGUIDs(guids);

		level notify("_lifecycle__joined", player);
	}
}

OnPlayerDisconnected()
{
	self waittill("disconnect");

	guids = getGUIDs();
	guids = arrayRemove(guids, self.guid);
	setGUIDs(guids);

	level notify("_lifecycle__left", false, self);

	if (guids.size == 0)
		level notify("_lifecycle__empty", false);

	if (guids.size == 0 || botsOnly(guids))
		level notify("_lifecycle__empty_ignorebots", false);
}

OnMapLoadTimeout()
{
	// The script engine does not run all the time and players can disconnect between map loads.
	// Thus, clean up the known player list once no one is connecting from the last map anymore.
	wait 60;

	guidsPrev = getGUIDs();
	guids = [];
	foreach (player in level.players)
		guids[guids.size] = player.guid;
	setGUIDs(guids);

	foreach (guid in guidsPrev)
		if (!arrayContains(guids, guid))
			level notify("_lifecycle__left", true);

	if (guidsPrev.size > 0)
	{
		if (guids.size == 0)
			level notify("_lifecycle__empty", true);

		if (guids.size == 0 || botsOnly(guids))
			level notify("_lifecycle__empty_ignorebots", true);
	}
}

botsOnly(guids)
{
	foreach (guid in guids)
		if (!isBotGUID(guid)) return false;

	return true;
}

getGUIDs()
{
	return unserializeGUIDs(storageGet("_lifecycle__guids"));
}

setGUIDs(array)
{
	storageSet("_lifecycle__guids", serializeGUIDs(array));
}

serializeGUIDs(array)
{
	str = "";
	foreach (guid in array)
		str += guid + ";";
	str = getSubStr(str, 0, str.size - 1);

	return str;
}

unserializeGUIDs(str)
{
	return strTok(str, ";");
}
