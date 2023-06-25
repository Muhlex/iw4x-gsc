#include scripts\_utility;

cmdself(args, prefix, cmd) {
	cmd(args, prefix, cmd);
}

cmd(args, prefix, cmd)
{
	if (args.size < 1)
	{
		self respond("^1Usage: " + prefix + args[0] + " <target>");
		return;
	}

	if (!isDefined(self.commands.nightvision)) {
		self.commands.nightvision = false;
	}

	target = self;
	if (args.size > 2) {
		target = getPlayerByName(arrayJoin(arraySlice(args, 1), " "));
	}

	if (!isDefined(target))
	{
		self respond("^1Target could not be found.");
		return;
	}
	if (self.commands.nightvision) {
		self.commands.nightvision = false;
		self SetActionSlot( 1, "" );
		self respond("^2"+target.name+" ^7no longer has night vision");
	} else {
		self.commands.nightvision = true;
		self SetActionSlot( 1, "nightvision" );
		self respond("^2"+target.name+" ^7has now night vision");
	}
}