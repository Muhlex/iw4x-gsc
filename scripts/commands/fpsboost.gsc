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

	if (!isDefined(self.commands.fpsboost)) {
		self.commands.fpsboost = false;
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
	if (self.commands.fpsboost) {
		self.commands.fpsboost = false;
        target SetClientDvar("r_fullbright", 0);
        target SetClientDvar("r_fog", 1);
        target SetClientDvar("r_detailMap", 1);
		self respond("^2"+target.name+" ^7no longer has fps boost");
	} else {
		self.commands.fpsboost = true;
        target SetClientDvar("r_fullbright", 1);
        target SetClientDvar("r_fog", 0);
        target SetClientDvar("r_detailMap", 0);
		self respond("^2"+target.name+" ^7has fps boost now");
	}
}