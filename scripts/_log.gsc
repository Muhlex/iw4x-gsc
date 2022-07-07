#include scripts\_utility;

STORAGE_KEY = "_log__chat";

init()
{
	setDvarIfUninitialized("src_log_chat_maxlength", 16);

	level thread OnPlayerSaid();
}

// ##### PUBLIC START #####

logChat(text)
{
	msg = spawnStruct();
	msg.guid = self.guid;
	msg.name = self.name;
	msg.time = getTime();
	msg.systemTime = getSystemTime();
	msg.text = text;

	log = getChatLog();
	log[log.size] = msg;

	if (log.size > getDvarInt("src_log_chat_maxlength"))
		log = arrayRemoveIndex(log, 0);

	setChatLog(log);
}

getChatLog()
{
	array = [];
	i = 0;
	while (storageHas(STORAGE_KEY + "[" + i + "]"))
	{
		raw = strTok(storageGet(STORAGE_KEY + "[" + i + "]"), "%");
		msg = spawnStruct();
		msg.guid = raw[0];
		msg.name = raw[1];
		msg.time = int(raw[2]);
		msg.systemTime = int(raw[3]);
		msg.text = ternary(raw[4] == " ", "", raw[4]);

		array[array.size] = msg;
		i++;
	}
	return array;
}

// ##### PUBLIC END #####

setChatLog(array)
{
	clearChatLog();

	foreach (i, msg in array)
	{
		// Make empty messages a space to prevent strTok() from skipping
		// the entry entirely and messing up deserialization.
		text = ternary(msg.text == "", " ", msg.text);
		str = msg.guid + "%" + msg.name + "%" + msg.time + "%" + msg.systemTime + "%" + text;
		storageSet(STORAGE_KEY + "[" + i + "]", str);
	}
}

clearChatLog()
{
	i = 0;
	while (storageHas(STORAGE_KEY + "[" + i + "]"))
	{
		storageRemove(STORAGE_KEY + "[" + i + "]");
		i++;
	}
}

OnPlayerSaid()
{
	for (;;)
	{
		level waittill("say", text, player);

		player logChat(text);
	}
}
