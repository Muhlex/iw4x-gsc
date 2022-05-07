// TODO: Map voting?

#include scripts\_utility;

init()
{
	setDvarIfUninitialized("sv_mapRotation_randomize", false);
	setDvarIfUninitialized("sv_mapRotation_playercounts", "");
	setDvarIfUninitialized("sv_mapRotation_timeout", 1);

	if (isPartyServer())
		return;

	res = parseRotationString(getDvar("sv_mapRotation"));
	res.defs = parseRotationPlayercounts(res.defs, getDvar("sv_mapRotation_playercounts"));
	level.nextmap = res;
	level.nextmap.randomize = !!getDvarInt("sv_mapRotation_randomize");
	level.nextmap.afterPickWeight = getDvarInt("sv_mapRotation_timeout") * -1;

	printDefinitions(level.nextmap.defs);

	level OnMapFirstInit();
	level thread OnPlayerConnected();
}

OnMapFirstInit()
{
	// return if not the first time called on this map
	if (storageHas("nextmap__current") && storageGet("nextmap__current") == getDvar("mapname"))
		return;
	storageSet("nextmap__current", getDvar("mapname"));

	// always remove dummy buffer maps (e. g. for when randomization is turned off)
	// expected sv_mapRotationCurrent string: "gametype _null map _null"
	rotationCurrent = strTok(getDvar("sv_mapRotationCurrent"), " ");
	if (rotationCurrent.size > 1 && rotationCurrent[1] == "_null")
		setDvar("sv_mapRotationCurrent", "");

	if (level.nextmap.defs.size == 0) return;

	mapWeights = getWeights("map");
	foreach (map in getArrayKeys(mapWeights))
		mapWeights[map] = mapWeights[map] + 1;
	mapWeights[getDvar("mapname")] = level.nextmap.afterPickWeight;
	setWeights("map", mapWeights);

	gametypeWeights = getWeights("gametype");
	foreach (gametype in getArrayKeys(gametypeWeights))
		gametypeWeights[gametype] = gametypeWeights[gametype] + 1;
	gametypeWeights[getDvar("g_gametype")] = level.nextmap.afterPickWeight;
	setWeights("gametype", gametypeWeights);

	if (level.nextmap.randomize)
		setNextConfig(getRandomConfig());
}

OnPlayerConnected()
{
	for (;;)
	{
		level waittill("connected", player);
		player thread OnPlayerDisconnected();

		waittillframeend;
		player OnPlayercountChange();
	}
}

OnPlayerDisconnected()
{
	self waittill("disconnect");

	self OnPlayercountChange();

	waittillframeend;

	if (level.players.size == 0 && !mapFitsPlayercount(getDvar("mapname")))
		exitLevel(false);
}

OnPlayercountChange()
{
	if (!level.nextmap.randomize) return;
	nextConfig = getNextConfig();
	if (!isDefined(nextConfig.map) || mapFitsPlayercount(nextConfig.map)) return;

	printLnConsole("^3[nextmap]^7 Currently chosen next map does not fit playercount.");
	setNextConfig(getRandomConfig());
}

incrementWeights(weights, type, weightList)
{
	foreach (name in weightList)
	{
		if (!isDefined(weights[name])) continue;
		weights[name] = weights[name] + 1;
	}
	return weights;
}

getWeights(type)
{
	key = "nextmap__weights_" + type;
	weights = [];

	if (!storageHas(key)) return weights;

	entries = strTok(storageGet(key), ";");
	for (i = 0; i < entries.size; i += 2)
	{
		name = entries[i];
		weight = int(entries[i + 1]);
		weights[name] = weight;
	}
	return weights;
}

setWeights(type, weights)
{
	key = "nextmap__weights_" + type;
	str = "";
	foreach (name, weight in weights)
		str += name + ";" + weight + ";";
	str = getSubStr(str, 0, str.size - 1);
	storageSet(key, str);
}

setNextConfig(config)
{
	setNextMap(config.map, config.gametype);
}

setNextMap(map, gametype)
{
	gametypeStr = "";
	if (isDefined(gametype))
		gametypeStr = " (" + gametype + ")";

	printLnConsole("^3[nextmap]^7 Next map set to: " + map + gametypeStr);

	if (isDefined(gametype))
		str = "gametype " + gametype + " map " + map;
	else
		str = "map " + map;
	// add a dummy set to prevent the game from messing with the queue:
	str += " gametype _null map _null";
	setDvar("sv_mapRotationCurrent", str);
}

getNextConfig()
{
	config = spawnStruct();
	args = strTok(getDvar("sv_mapRotationCurrent"), " ");

	if (!isDefined(args[0]))
	{
		config.gametype = undefined;
		config.map = undefined;
	}
	else if (args[0] == "map")
	{
		config.gametype = undefined;
		config.map = args[1];
	}
	else if (args[0] == "gametype")
	{
		config.gametype = args[1];
		config.map = args[3];
	}

	return config;
}

getWeightedRandomItem(type, array)
{
	weights = getWeights(type);
	pool = [];
	result = undefined;

	foreach (item in array)
	{
		weight = array.size;
		if (isDefined(weights[item])) weight = weights[item];

		for (i = 0; i < weight; i++)
			pool[pool.size] = item;
	}

	if (pool.size > 0)
		result = pool[randomInt(pool.size)];
	else if (array.size > 0)
		result = array[randomInt(array.size)];

	return result;
}

getRandomConfig()
{
	defs = level.nextmap.defs;
	maps = [];

	foreach (def in defs)
	{
		if (!mapFitsPlayercount(def.map)) continue;
		maps[maps.size] = def.map;
	}

	if (maps.size == 0)
	{
		printLnConsole("^3[nextmap]^7 ^1No maps defined for current player count.");
		maps[0] = defs[getFirstArrayKey(defs)].map;
	}
	map = getWeightedRandomItem("map", maps);
	gametype = getWeightedRandomItem("gametype", defs[map].gametypes);

	config = spawnStruct();
	config.map = map;
	config.gametype = gametype;
	return config;
}

mapFitsPlayercount(map)
{
	def = level.nextmap.defs[map];
	count = 0;
	if (isDefined(level.players)) count = level.players.size;
	if (!isDefined(def)) return false;
	if (isDefined(def.minPlayers) && count < def.minPlayers) return false;
	if (isDefined(def.maxPlayers) && count > def.maxPlayers) return false;
	return true;
}

parseRotationString(str)
{
	args = strTok(toLower(str), " ");
	if (!isDefined(args)) args = [];

	result = spawnStruct();
	maps = [];
	gametypes = [];
	defs = [];

	gametype = undefined;

	if (args.size & 1)
	{
		printLnConsole("^3[nextmap]^7 ^1sv_mapRotation: Invalid Syntax. Uneven number of arguments.");
		return;
	}

	for (i = 0; i < args.size; i += 2)
	{
		key = args[i];
		value = args[i + 1];

		switch (key)
		{
			case "gametype":
				if (!isValidGameType(value))
				{
					printLnConsole("^3[nextmap]^7 ^1sv_mapRotation: Unknown gametype specified: " + value);
					return;
				}

				gametypes[value] = value;
				gametype = value;
				break;

			case "map":
				if (!mapExists(value))
				{
					printLnConsole("^3[nextmap]^7 ^1sv_mapRotation: Unknown map specified: " + value);
					return;
				}

				maps[value] = value;
				if (!isDefined(defs[value]))
				{
					def = spawnStruct();
					def.map = value;
					def.gametypes = [];
					if (isDefined(gametype))
						def.gametypes[0] = gametype;

					defs[value] = def;
				}
				else if (isDefined(gametype))
				{
					def = defs[value];
					def.gametypes[def.gametypes.size] = gametype;
				}

				break;

			default:
				printLnConsole("^3[nextmap]^7 ^1sv_mapRotation: Invalid Syntax. \"map\" or \"gametype\" missing or misspelled.");
				return;
		}
	}

	result.maps = maps;
	result.gametypes = gametypes;
	result.defs = defs;
	return result;
}

parseRotationPlayercounts(defs, str)
{
	configs = strTok(toLower(str), ",");

	foreach (config in configs)
	{
		configArray = strTok(config, " ");

		if (configArray.size != 2)
		{
			printLnConsole("^3[nextmap]^7 ^1sv_mapRotation_playercounts: Invalid Syntax. Must have 2 arguments per map (<mapname> <min>-<max>).");
			continue;
		}

		map = configArray[0];
		if (!isDefined(defs[map])) continue;

		minMaxArray = strTok(configArray[1], "-");

		if (minMaxArray.size != 2)
		{
			printLnConsole("^3[nextmap]^7 ^1sv_mapRotation_playercounts: Invalid Syntax. Must have min and max player counts separated by \"-\" (<min>-<max>).");
			continue;
		}

		defs[map].minPlayers = int(minMaxArray[0]);
		defs[map].maxPlayers = int(minMaxArray[1]);
	}

	return defs;
}

printDefinitions(defs)
{
	if (defs.size == 0)
	{
		printLnConsole("^3[nextmap]^7 No map rotation configured.");
		return;
	}

	printLnConsole("^3[nextmap]^7 Configured map rotation:");
	foreach (def in defs)
	{
		gametypesStr = "";
		if (def.gametypes.size > 0)
		{
			foreach (gametype in def.gametypes)
				gametypesStr += gametype + ", ";
			gametypesStr = " [" + getSubStr(gametypesStr, 0, gametypesStr.size - 2) + "]";
		}

		playercountStr = "";
		if (isDefined(def.minPlayers) && isDefined(def.maxPlayers))
			playercountStr = " (" + def.minPlayers + "-" + def.maxPlayers + " players)";

		printLnConsole("^3[nextmap]^7 " + def.map + gametypesStr + playercountStr);
	}
	printLnConsole("-----------------------------------");
}
