#include scripts\_utility;

cmd(args, prefix, cmd)
{
	self playerTeleportAll(args, prefix, cmd);
}

printUsage(cmd) {
	self respond(cmd.usage);
}

playerTeleportAll(args, prefix, cmd)
{
	source = "all";
	target = self;
	if (args.size > 2) {
    	target = getPlayerByName(arrayJoin(arraySlice(args, 1), " "));
	}
	if (args.size > 1) {
		source = args[1];
	}

	if (!isDefined(target))
	{
		self respond("^1Target player could not be found.");
		printUsage(cmd);
		return;
	}

	if (!isAlive(target))
	{
		self respond("^1Target player must be alive to teleport.");
		printUsage(cmd);
		return;
	}

	foreach (player in level.players) {
		if (source == "spectators" && player.team != "spectator") continue;
		if (source == "players" && player.team == "spectator") continue;
		if (source == "opfor" && player.team != "axis") continue;
		if (source == "marines" && player.team != "allies") continue;
		if (source == "bots" && !isBotGUID(player)) continue;
		if (source == "team" && !isTeammate(player)) continue;
		if (source == "enemies" && !isEnemy(player)) continue;
		if (!isDefined(player)) continue;
		if (player == target) continue;
		if (!isAlive(player)) continue;
		player setOrigin(target.origin);
		player setPlayerAngles(target getPlayerAngles());
	}

	self respond("^2Teleported ^7" + level.players.size + "^2 players to ^7" + target.name + "^2.");
}