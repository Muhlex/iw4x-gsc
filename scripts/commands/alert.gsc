#include scripts\_utility;

cmd(args, prefix, cmd)
{
	if (args.size < 2)
	{
		self respond("^1Usage: " + prefix + args[0] + " <all/marines/opfor/player name> <text>");
		return;
	}

	target = args[1];
	self respond("^2Alerting ^7\"" + target + "\"^2.");
		
	shout = spawnstruct();
	shout.titleText = arrayJoin(arraySlice(args, 2), " ");
	shout.glowColor = (0,.4,.9);

	if (target == "all") {
		foreach(player in level.players) {
			player thread maps\mp\gametypes\_hud_message::notifyMessage( shout );
		}
	} else if (target == "marines") {
		foreach(player in level.players) {
			if (player.team == "allies")
				player thread maps\mp\gametypes\_hud_message::notifyMessage( shout );
		}
	} else if (target == "opfor") {
		foreach(player in level.players) {
			if (player.team == "axis")
				player thread maps\mp\gametypes\_hud_message::notifyMessage( shout );
		}
	} else {
		target = getPlayerByName(args[1]);
		if (!isDefined(target))
		{
			self respond("^1Target could not be found.");
			return;
		}
		target thread maps\mp\gametypes\_hud_message::notifyMessage( shout );
	}

	self respond("^2Alerted ^7" + target + "^2.");
}
