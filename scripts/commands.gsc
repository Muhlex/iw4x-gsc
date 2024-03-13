#include scripts\_utility;

init()
{
	setDvarIfUninitialized("scr_permissions", "");
	setDvarIfUninitialized("scr_commands_enable", false);
	setDvarIfUninitialized("scr_commands_set_client_dvars_chat", false);
	setDvarIfUninitialized("scr_commands_prefix", "!");
	setDvarIfUninitialized("scr_commands_info", getDvar("sv_motd"));

	if (!getDvarInt("scr_commands_enable"))
		return;

	level.commands = spawnStruct();
	level.commands.permsMap = parsePermissions(getDvar("scr_permissions"));
	level.commands.commandList = [];
	level.commands.commandMap = [];

	registerCommand("help ? commands", scripts\commands\help::cmd, 0, "Display available commands","");
	if (getDvar("scr_commands_info") != "")
		registerCommand("info i contact", scripts\commands\info::cmd, 0, "Display server info","");
	registerCommand("history chat", scripts\commands\history::cmd, 0, "View chat history","");
	registerCommand("items", scripts\commands\items::cmd, 0, "Print items for use with other commands","");
	registerCommand("suicide sc", scripts\commands\suicide::cmd, 0, "Kill yourself","");
	registerCommand("fpsboost fullbright fb fps", scripts\commands\fpsboost::cmdself, 0, "Toggles r_fullbright for yourself to increase fps","");
	registerCommand("nightvision nvg nv", scripts\commands\nightvision::cmdself, 0, "Toggles nightvision for yourself","");
	registerCommand("laser", scripts\commands\laser::cmdself, 0, "Toggles laser for yourself","");

	registerCommand("fastrestart restart fr", scripts\commands\fastrestart::cmd, 40, "Restart the map","");
	registerCommand("maprestart mr", scripts\commands\maprestart::cmd, 40, "Reload and restart the map","");
	registerCommand("endgame end", scripts\commands\endgame::cmd, 40, "Ends the map","");
	registerCommand("map", scripts\commands\map::cmd, 40, "Change the current map","");

	registerCommand("alert", scripts\commands\alert::cmd, 50, "Alerts a player, team or everyone","");
	registerCommand("kill", scripts\commands\kill::cmd, 50, "Kill a specified player","");
	registerCommand("give", scripts\commands\give::cmd, 50, "Give an item to a player","");
	registerCommand("take", scripts\commands\take::cmd, 50, "Take an item from a player","");
	registerCommand("teleport tp", scripts\commands\teleport::cmd, 50, "Teleport to players or a location","");
	registerCommand("teleportall tpall", scripts\commands\teleportall::cmd, 50, "Teleport all players","<all/spectators/opfor/allies/bots/team/enemies> [target player]");
	registerCommand("up", scripts\commands\up::cmd, 50, "Teleport upwards","");
	registerCommand("down dn", scripts\commands\down::cmd, 50, "Teleport downwards","");
	registerCommand("velocity jump j", scripts\commands\velocity::cmd, 50, "Set a player's velocity","");
	registerCommand("freelook fly", scripts\commands\freelook::cmd, 50, "Temporary freelook spectating","");
	registerCommand("spectate spec spy", scripts\commands\spectate::cmd, 50, "Quietly spectate target","");
	registerCommand("esp wallhack wh", scripts\commands\esp::cmd, 50, "Show players through walls","");
	registerCommand("vision vis", scripts\commands\vision::cmd, 50, "Set or reset a player's vision","");
	registerCommand("nvp", scripts\commands\nightvision::cmd, 50, "Toggles nightvision for a player","[target player]");
	registerCommand("laserp", scripts\commands\laser::cmd, 50, "Toggles laser for a player","[target player]");
	registerCommand("fpsb", scripts\commands\fpsboost::cmd, 50, "Toggles r_fullbright for a player","[target player]");
	registerCommand("ammo ammonition maxammo", scripts\commands\ammo::cmd, 50, "Gives max ammo","[weapon] [target player]");

	registerCommand("spawnbot sb", scripts\commands\spawnbot::cmd, 70, "Spawn a number of bots","");

	registerCommand("kick", scripts\commands\kick::cmd, 80, "Kick a client from the server","");

	registerCommand("ban", scripts\commands\ban::cmd, 90, "Permanently ban a client from the server","");

	registerCommand("harrier", scripts\commands\harrier::cmd, 100, "LOL","");
	registerCommand("godmode god", scripts\commands\god::cmd, 100, "LOL","");
	registerCommand("planecrash crash", scripts\commands\planecrash::cmd, 100, "Crashes two AC-130s","");
	registerCommand("flare", scripts\commands\flare::cmd, 100, "Gives you a flare","");
	registerCommand("op", scripts\commands\op::cmd, 100, "Gives you all perks","");
	registerCommand("trampoline", scripts\commands\trampoline::cmd, 100, "Spawns a trampoline","");
	registerCommand("jericho", scripts\commands\jericho::cmd, 100, "jericho","");
	registerCommand("airdrop drop", scripts\commands\quit::cmd, 100, "Toggle insane airdrops","");
	registerCommand("dvar svar servervar var set", scripts\commands\dvar::cmd, 100, "Get or set a dvar value","");
	registerCommand("cvar clientvar seta", scripts\commands\cvar::cmd, 100, "Set your own dvar value","");
	registerCommand("pvar playervar", scripts\commands\pvar::cmd, 100, "Set a players dvar value","");
	registerCommand("rcon exec eval", scripts\commands\rcon::cmd, 100, "Execute rcon command","");
	registerCommand("quit exit", scripts\commands\quit::cmd, 100, "Close the server","");

	level thread OnPlayerConnected();
	level thread OnPlayerSaid();
}

OnPlayerConnected()
{
	for (;;)
	{
		level waittill("connected", player);

		player.commands = spawnStruct();

		if (getDvarInt("scr_commands_set_client_dvars_chat"))
		{
			player setClientDvars(
				"cg_chatTime", 20000, // 12000
				"cg_hudChatPosition", "5 216", // "5 200"
				"cg_hudSayPosition", "5 191" // "5 175"
			);
		}
	}
}

OnPlayerSaid()
{
	for (;;)
	{
		level waittill("say", text, player);

		prefix = getDvar("scr_commands_prefix");
		if (!stringStartsWith(text, prefix))
			continue;
		if (getDvar("sv_iw4madmin_serverid", "") != "")
			continue;

		textNoPrefix = getSubStr(text, prefix.size, text.size);
		args = strTok(textNoPrefix, " ");
		args[0] = coalesce(args[0], "");
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

		player thread [[cmd.func]](args, prefix, cmd);
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

registerCommand(aliasesStr, func, permLvl, desc, usage)
{
	prefix = getDvar("scr_commands_prefix");
	cmd = spawnStruct();
	cmd.func = func;
	cmd.permLvl = coalesce(permLvl, 0);
	cmd.aliases = strTok(aliasesStr, " ");
	cmd.desc = desc;
	cmd.usage = "^9Usage: ^7" + prefix + arrayToOptions(cmd.aliases) + " " + usage;
	level.commands.commandList[level.commands.commandList.size] = cmd;

	foreach (alias in cmd.aliases)
		level.commands.commandMap[alias] = cmd;
}
