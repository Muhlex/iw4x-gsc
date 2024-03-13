#include scripts\_utility;

cmd(args, prefix, cmd)
{
	PER_PAGE = 5;
	pageIndex = int(coalesce(args[1], 1)) - 1;
	commands = self arrayFilter(level.commands.commandList, scripts\commands::hasPermForCmd);
	pageCount = ceil(commands.size / PER_PAGE);

	if (pageIndex < 0 || pageIndex >= pageCount)
	{
		self respond("^1This page does not exist.");
		return;
	}

	commandsPage = arraySlice(commands, pageIndex * PER_PAGE, pageIndex * PER_PAGE + PER_PAGE);

	self respond("^5List of commands ^7(page " + (pageIndex + 1) + "/" + pageCount + ")^5:");
	foreach (cmd in commandsPage)
		self respond("^5^3" + getAliasesStr(cmd.aliases) + ": ^7" + cmd.desc);
	if (pageCount > 1 && pageIndex < pageCount - 1)
		self respond("^5Use ^7" + prefix + args[0] + " " + (pageIndex + 2) + " ^5for the next page.");
}

getAliasesStr(aliases)
{
	result = "";
	foreach (i, alias in aliases)
	{
		if (i == 0)
		{
			result += alias;
			continue;
		}

		if (i == 1)
			result += " (";

		result += alias;

		if (i == aliases.size - 1)
			result += ")";
		else
			result += ", ";
	}
	return result;
}
