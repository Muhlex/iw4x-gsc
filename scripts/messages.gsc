#include scripts\_utility;

PRINT_ALL = 0;
PRINT_SELF = 1;
PRINT_ALL_BUT_SELF = 2;

init()
{
	setDvarIfUninitialized("scr_message_welcome", "");
	setDvarIfUninitialized("scr_message_join", "");
	setDvarIfUninitialized("scr_message_leave", "");

	level thread OnPlayerJoined();
	level thread OnPlayerLeft();
}

OnPlayerJoined()
{
	for (;;)
	{
		level waittill("_lifecycle__joined", player);

		player thread OnPlayerFirstSpawned();

		player printMessage(getDvar("scr_message_join"), PRINT_ALL_BUT_SELF);
	}
}

OnPlayerFirstSpawned()
{
	self waittill("spawned_player");

	self printMessage(getDvar("scr_message_welcome"), PRINT_SELF);
}

OnPlayerLeft()
{
	for (;;)
	{
		level waittill("_lifecycle__left", delayedNotify, player);
		if (delayedNotify) continue;

		player printMessage(getDvar("scr_message_leave"), PRINT_ALL);
	}
}

printMessage(msg, mode)
{
	mode = coalesce(mode, PRINT_ALL);
	if (!isDefined(msg) || msg == "") return;

	paragraphs = self parseMessage(msg);

	if (mode == PRINT_ALL)
	{
		foreach (paragraph in paragraphs)
			level printChat(paragraph);
	}
	else if (mode == PRINT_SELF)
	{
		foreach (paragraph in paragraphs)
			self printChat(paragraph);
	}
	else if (mode == PRINT_ALL_BUT_SELF)
	{
		foreach (paragraph in paragraphs)
			foreach (player in level.players)
				if (player != self)
					player printChat(paragraph);
	}
}

parseMessage(msg)
{
	replaceMap = [];
	replaceMap["NAME"] = ::getPlayerName;
	replaceMap["NAME_NOCOLORS"] = ::getPlayerNameNoColors;
	replaceMap["HOSTNAME"] = ::getHostName;
	replaceMap["HOSTNAME_NOCOLORS"] = ::getHostNameNoColors;

	foreach (delim, func in replaceMap)
		msg = arrayJoin(stringSplit(msg, "{" + delim + "}"), self [[func]]());

	return stringSplit(msg, "%");
}

getPlayerName()
{
	return self scripts\_lifecycle::getPlayerNameSafe();
}

getPlayerNameNoColors()
{
	return stringRemoveColors(self getPlayerName());
}

getHostName()
{
	return getDvar("sv_hostname");
}

getHostNameNoColors()
{
	return stringRemoveColors(self getHostName());
}
