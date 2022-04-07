#include scripts\_utility;

init()
{
	setDvarIfUninitialized("scr_permissions", "");
	setDvarIfUninitialized("scr_commands_prefix", "!");

	level.commands = spawnStruct();
	level.commands.permsMap = parsePermissions(getDvar("scr_permissions"));
	level.commands.commandList = [];
	level.commands.commandMap = [];

	registerCommand("help ? commands", scripts\commands\help::cmd, 0, "Display available commands");
	registerCommand("suicide sc", scripts\commands\suicide::cmd, 10, "Kill yourself");
	registerCommand("fastrestart restart fr", scripts\commands\fastrestart::cmd, 40, "Restart the map");
	registerCommand("maprestart mr", scripts\commands\maprestart::cmd, 40, "Reload and restart the map");
	registerCommand("map", scripts\commands\map::cmd, 40, "Change the current map");
	registerCommand("give", scripts\commands\give::cmd, 50, "Give a weapon to a player");
	registerCommand("kill", scripts\commands\kill::cmd, 50, "Kill a specified player");
	registerCommand("freelook fly", scripts\commands\freelook::cmd, 50, "Temporary freelook spectating");
	registerCommand("spectate spec spy", scripts\commands\spectate::cmd, 50, "Quietly spectate target");
	registerCommand("teleport tp", scripts\commands\teleport::cmd, 50, "Teleport to players or a location");
	registerCommand("up", scripts\commands\up::cmd, 50, "Teleport upwards");
	registerCommand("down dn", scripts\commands\down::cmd, 50, "Teleport downwards");
	registerCommand("spawnbot sb", scripts\commands\spawnbot::cmd, 70, "Spawn a number of bots");
	registerCommand("kick", scripts\commands\kick::cmd, 80, "Kick a client from the server");
	registerCommand("ban", scripts\commands\ban::cmd, 90, "Permanently ban a client from the server");
	registerCommand("rcon", scripts\commands\rcon::cmd, 100, "Execute rcon command");
	registerCommand("quit exit", scripts\commands\quit::cmd, 100, "Close the server");

	level thread OnPlayerConnected();
	level thread OnPlayerSay();
}

OnPlayerConnected()
{
	for (;;)
	{
		level waittill("connected", player);

		player.commands = spawnStruct();
	}
}

OnPlayerSay()
{
	for (;;)
	{
		level waittill("say", text, player);

		prefix = getDvar("scr_commands_prefix");
		if (!stringStartsWith(text, prefix))
			continue;

		textNoPrefix = getSubStr(text, prefix.size, text.size);
		args = strTok(textNoPrefix, " ");
		args[0] = toLower(args[0]);
		cmd = level.commands.commandMap[args[0]];

		if (!isDefined(cmd))
		{
			player respond("^1Unknown command. Use ^7" + prefix + "help ^1for a list of commands.");
			continue;
		}

		if (!player hasPermForCmd(cmd))
		{
			player respond("^1Insufficient permissions.");
			continue;
		}

		player thread [[cmd.func]](args, prefix);
	}
}

parsePermissions(str)
{
	rawData = strTok(str, " ");

	if (rawData.size & 1)
	{
		assertMsg("[commands] Uneven number of arguments in 'scr_permissions' dvar.");
		return [];
	}

	map = [];
	for (i = 0; i < rawData.size; i += 2)
	{
		guid = rawData[i];
		permLvl = int(rawData[i + 1]);
		map[guid] = permLvl;
	}

	return map;
}

getPermLvl()
{
	return coalesce(level.commands.permsMap[self.guid], 0);
}

hasPermForCmd(cmd)
{
	if (!isDefined(self) || !isPlayer(self))
		return false;

	return (self getPermLvl() >= cmd.permLvl);
}

registerCommand(aliasesStr, func, permLvl, desc)
{
	cmd = spawnStruct();
	cmd.func = func;
	cmd.permLvl = coalesce(permLvl, 0);
	cmd.aliases = strTok(aliasesStr, " ");
	cmd.desc = desc;
	level.commands.commandList[level.commands.commandList.size] = cmd;

	foreach (alias in cmd.aliases)
		level.commands.commandMap[alias] = cmd;
}
