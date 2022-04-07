#include scripts\_utility;

cmd(args, prefix)
{
	if (args.size < 2)
	{
		self respond("^1Usage: " + prefix + args[0] + " <mapname>");
		return;
	}

	mapname = toLower(args[1]);
	mapnamePrefixed = ternary(stringStartsWith(mapname, "mp_"), mapname, "mp_" + mapname);

	if (mapExists(mapnamePrefixed))
		mapname = mapnamePrefixed;

	if (!mapExists(mapname))
	{
		self respond("^1Unknown map.");
		return;
	}

	map(mapname, false);
}
