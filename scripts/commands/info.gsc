#include scripts\_utility;

cmd(args, prefix)
{
	paragraphs = self scripts\messages::parseMessage(getDvar("scr_commands_info"));
	foreach (paragraph in paragraphs)
		self respond(paragraph);
}
