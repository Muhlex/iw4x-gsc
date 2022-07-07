#include scripts\_utility;

cmd(args, prefix)
{
	waittillframeend;

	log = scripts\_log::getChatLog();
	self respond("^2Recent chat log:");
	foreach (msg in log)
	{
		timeStr = "[" + scripts\_date::unixToRelativeTimeString(msg.systemTime) + "]";
		self respond(timeStr + " ^3" + msg.name + "^3: ^7" + msg.text);
	}

	if (isDedicatedServer())
		self respond("^2Older messages printed to console.");
}
