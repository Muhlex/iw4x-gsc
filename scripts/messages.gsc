#include scripts\_utility;

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

		player printMessageJoin();
	}
}

OnPlayerFirstSpawned()
{
	self waittill("spawned_player");

	self printMessageWelcome();
}

OnPlayerLeft()
{
	for (;;)
	{
		level waittill("_lifecycle__left", delayedNotify, player);
		if (delayedNotify) continue;

		player printMessageLeave();
	}
}

printMessageWelcome()
{
	msg = getDvar("scr_message_welcome");
	if (msg == "") return;

	foreach (paragraph in self parseMessage(msg))
		self printChat(paragraph);
}

printMessageJoin()
{
	msg = getDvar("scr_message_join");
	if (msg == "") return;

	foreach (paragraph in self parseMessage(msg))
		foreach (player in level.players)
			if (player != self)
				player printChat(paragraph);
}

printMessageLeave()
{
	msg = getDvar("scr_message_leave");
	if (msg == "") return;

	foreach (paragraph in self parseMessage(msg))
		level printChat(paragraph);
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
