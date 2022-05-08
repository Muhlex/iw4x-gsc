#include scripts\_utility;

init()
{
	setDvarIfUninitialized("src_log_chat_maxlength", 16);

	if (!storageHas("_log__chat"))
		storageSet("_log__chat", "");

	level thread OnPlayerSay();
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
	return unserializeChatLog(storageGet("_log__chat"));
}

// ##### PUBLIC END #####

setChatLog(array)
{
	storageSet("_log__chat", serializeChatLog(array));
}

serializeChatLog(array)
{
	str = "";

	foreach (msg in array)
	{
		// Make empty messages a space to prevent strTok from skipping the entry entirely
		// thus messing up deserialization.
		text = ternary(msg.text == "", " ", msg.text);
		str += msg.guid + "%" + msg.name + "%" + msg.time + "%" + msg.systemTime + "%" + text + "%";
	}
	str = getSubStr(str, 0, str.size - 1);
	return str;
}

unserializeChatLog(str)
{
	array = strTok(str, "%");
	result = [];
	for (i = 0; i < array.size; i += 5)
	{
		msg = spawnStruct();
		msg.guid = array[i];
		msg.name = array[i + 1];
		msg.time = int(array[i + 2]);
		msg.systemTime = int(array[i + 3]);
		msg.text = array[i + 4];
		result[result.size] = msg;
	}
	return result;
}

OnPlayerSay()
{
	for (;;)
	{
		level waittill("say", text, player);

		player logChat(text);
	}
}
