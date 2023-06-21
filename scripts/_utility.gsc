ternary(condition, truthy, falsy)
{
	if (condition)
		return truthy;
	else
		return falsy;
}

coalesce(a1, a2, a3, a4, a5, a6, a7, a8)
{
	if (isDefined(a1)) return a1;
	if (isDefined(a2)) return a2;
	if (isDefined(a3)) return a3;
	if (isDefined(a4)) return a4;
	if (isDefined(a5)) return a5;
	if (isDefined(a6)) return a6;
	if (isDefined(a7)) return a7;
	if (isDefined(a8)) return a8;
	return undefined;
}

waittillAny(a1, a2, a3, a4, a5, a6, a7, a8)
{
	if (isDefined(a1)) self endon(a1);
	if (isDefined(a2)) self endon(a2);
	if (isDefined(a3)) self endon(a3);
	if (isDefined(a4)) self endon(a4);
	if (isDefined(a5)) self endon(a5);
	if (isDefined(a6)) self endon(a6);
	if (isDefined(a7)) self endon(a7);
	if (isDefined(a8)) self endon(a8);
	level waittill("eternity");
}

// Useful for calling a function when not knowing the amount of parameters
// without raising a script runtime error for passing too many.
callFunc(func, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
{
	if (isDefined(a10))
		return self [[func]](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10);
	if (isDefined(a9))
		return self [[func]](a1, a2, a3, a4, a5, a6, a7, a8, a9);
	if (isDefined(a8))
		return self [[func]](a1, a2, a3, a4, a5, a6, a7, a8);
	if (isDefined(a7))
		return self [[func]](a1, a2, a3, a4, a5, a6, a7);
	if (isDefined(a6))
		return self [[func]](a1, a2, a3, a4, a5, a6);
	if (isDefined(a5))
		return self [[func]](a1, a2, a3, a4, a5);
	if (isDefined(a4))
		return self [[func]](a1, a2, a3, a4);
	if (isDefined(a3))
		return self [[func]](a1, a2, a3);
	if (isDefined(a2))
		return self [[func]](a1, a2);
	if (isDefined(a1))
		return self [[func]](a1);

	return self [[func]]();
}

callAfterDelay(func, delay, a1, a2, a3, a4, a5, a6, a7, a8)
{
	wait delay;
	self callFunc(func, a1, a2, a3, a4, a5, a6, a7, a8);
}

callAfterEvent(func, event, a1, a2, a3, a4, a5, a6, a7, a8)
{
	self waittill(event);
	self callFunc(func, a1, a2, a3, a4, a5, a6, a7, a8);
}

isPartyServer()
{
	return (getDvarInt("party_enable") && getDvarInt("party_host"));
}

isDedicatedServer()
{
	return !(isDefined(level.player) && level.player isHost());
	// return (getDvar("r_useD3D9Ex").size == 0);
}

isBotGUID(guid)
{
	return (stringStartsWith(guid, "bot") && guid.size < 16);
}

isEnemy(player)
{
	if (!isDefined(player.team) || !isDefined(self.team))
		return false;

	if (self.team != "allies" && self.team != "axis")
		return false;

	if (player.team != "allies" && player.team != "axis")
		return false;

	if (!level.teamBased)
		return true;

	return (player.team != self.team);
}

isTeammate(player)
{
	if (!isDefined(player.team) || !isDefined(self.team))
		return false;

	if (self.team != "allies" && self.team != "axis")
		return false;

	if (player.team != "allies" && player.team != "axis")
		return false;

	if (!level.teamBased)
		return false;

	return (player.team == self.team);
}

arrayContains(array, item)
{
	foreach (el in array)
		if (el == item)
			return true;

	return false;
}

arrayRemove(array, item)
{
	result = [];
	foreach (el in array)
		if (el != item)
			result[result.size] = el;

	return result;
}

arrayRemoveIndex(array, index)
{
	result = [];
	foreach (i, el in array)
		if (i != index)
			result[result.size] = el;

	return result;
}

arrayInsert(array, item, index)
{
	assertEx(index >= 0 && index <= array.size, "arrayInsert index must be in range of the target array!");

	if (index == array.size)
	{
		array[array.size] = item;
		return array;
	}

	result = array;
	for (i = index; i < array.size; i++)
	{
		if (i == index)
			result[i] = item;
		result[i + 1] = array[i];
	}

	return result;
}

arrayGetRandom(array)
{
	keys = getArrayKeys(array); // make it work with string indices
	if (keys.size == 0) return undefined;
	return array[keys[randomInt(keys.size)]];
}

arraySlice(array, start, end)
{
	start = coalesce(start, 0);
	end = coalesce(end, array.size);

	if (start < 0) start = 0;
	if (end > array.size) end = array.size;

	result = [];
	for (i = start; i < end; i++)
		result[result.size] = array[i];

	return result;
}

arrayCombine(array1, array2)
{
	result = [];
	foreach (el in array1)
		result[result.size] = el;
	foreach (el in array2)
		result[result.size] = el;
	return result;
}

arrayShuffle(array)
{
	for (i = array.size - 1; i > 0; i--)
	{
		j = randomInt(i + 1);
		temp = array[i];
		array[i] = array[j];
		array[j] = temp;
	}
	return array;
}

arrayJoin(array, delim)
{
	result = "";
	foreach (i, part in array)
	{
		if (i == 0)
			result += part;
		else
			result += delim + part;
	}

	return result;
}

arrayFind(array, func, a1, a2, a3, a4, a5, a6, a7, a8)
{
	foreach (el in array)
		if (self callFunc(func, el, a1, a2, a3, a4, a5, a6, a7, a8))
			return el;
	return undefined;
}

arrayFindRecursive(array, func, a1, a2, a3, a4, a5, a6, a7, a8)
{
	foreach (el in array)
	{
		if (isArray(el))
		{
			result = self arrayFindRecursive(el, func, a1, a2, a3, a4, a5, a6, a7, a8);
			if (isDefined(result)) return result;
		}
		else
		{
			if (self callFunc(func, el, a1, a2, a3, a4, a5, a6, a7, a8))
				return el;
		}
	}
	return undefined;
}

arrayFilter(array, func, a1, a2, a3, a4, a5, a6, a7, a8)
{
	result = [];

	foreach (el in array)
		if (self callFunc(func, el, a1, a2, a3, a4, a5, a6, a7, a8))
			result[result.size] = el;

	return result;
}

arrayRunRecursive(array, func, a1, a2, a3, a4, a5, a6, a7, a8)
{
	foreach (el in array)
	{
		if (isArray(el))
			self arrayRunRecursive(el, func, a1, a2, a3, a4, a5, a6, a7, a8);
		else
			self callFunc(func, el, a1, a2, a3, a4, a5, a6, a7, a8);
	}
}

arrayIsMap(array)
{
	keys = getArrayKeys(array);
	isMap = false;
	foreach (key in keys)
	{
		if (int(key) + "" != key + "")
		{
			isMap = true;
			break;
		}
	}
	return isMap;
}

arrayToString(array)
{
	isMap = arrayIsMap(array);
	str = ternary(isMap, "{", "[");
	foreach (key, value in array)
	{
		if (isArray(value))
			value = arrayToString(value);
		else if (isString(value))
			value = "\"" + value + "\"";

		keyStr = key; // don't modify iteration due to changing key
		if (isMap && isString(keyStr))
			keyStr = "\"" + keyStr + "\"";

		if (isMap)
			str += keyStr + ": " + value + ", ";
		else
			str += value + ", ";
	}
	if (array.size > 0)
		str = getSubStr(str, 0, str.size - 2);
	str += ternary(isMap, "}", "]");

	return str;
}

arrayToOptions(arr) {
	opts = "^9<";
	for (i = 0; i < arr.size; i++)
	{
		opts += "^7" + arr[i];
		if (i < arr.size - 1)
			opts += "^9/";
	}
	opts += "^9>";
	return opts;
}

stringStartsWith(str, startstr)
{
	return (getSubStr(str, 0, startstr.size) == startstr);
}

stringEndsWith(str, endstr)
{
	return (getSubStr(str, str.size - endstr.size, str.size) == endstr);
}

stringPadStart(str, targetSize, padstr)
{
	str = ternary(isString(str), str, str + "");
	padstr = coalesce(padstr, " ");

	padSize = (targetSize - str.size);
	if (padSize < 1) return str;

	padResult = "";
	for (i = 0; i < padSize; i++)
		padResult += padstr;

	return (padResult + str);
}

stringSplit(str, delim)
{
	// strTok only works as expected with singular characters
	// https://www.cplusplus.com/reference/cstring/strtok/

	array = [];
	if (delim.size == 0)
	{
		for (i = 0; i < str.size; i++)
			array[i] = str[i];
		return array;
	}

	// if (delim.size == 1)
	// {
	// 	array = strTok(str, delim);
	// 	if (stringStartsWith(str, delim))
	// 		array = arrayInsert(array, "", 0);
	// 	if (stringEndsWith(str, delim))
	// 		array[array.size] = "";
	// 	return array;
	// }

	strChars = [];
	delimChars = [];
	for (i = 0; i < str.size; i++)
		strChars[i] = getSubStr(str, i, i + 1);
	for (i = 0; i < delim.size; i++)
		delimChars[i] = getSubStr(delim, i, i + 1);

	copyStart = 0;
	offset = 0;
	foreach (i, strChar in strChars)
	{
		if (strChar == delimChars[offset])
			offset++;
		else
			offset = 0;

		if (offset == delim.size)
		{
			array[array.size] = getSubStr(str, copyStart, i - offset + 1);
			copyStart = i + 1;
			offset = 0;
		}
	}

	array[array.size] = getSubStr(str, copyStart, str.size);
	return array;
}

stringRemoveColors(str) {
	parts = strTok(str, "^");
	foreach (i, part in parts)
	{
		if (i == 0 && str[0] != "^") continue;

		switch (part[0])
		{
			case "0":
			case "1":
			case "2":
			case "3":
			case "4":
			case "5":
			case "6":
			case "7":
			case "8":
			case "9":
			case ":":
			case ";":
				parts[i] = getSubStr(part, 1);
		}
	}
	result = "";
	foreach (part in parts) result += part;
	return result;
}

stringEncodeDiscord(str) {
	chars = [];
	chars[0] = "\\"; // Must be first!
	chars[1] = "_";
	chars[2] = "*";
	chars[3] = "|";
	chars[4] = "~";
	chars[5] = "`";

	foreach (char in chars)
		str = arrayJoin(stringSplit(str, char), "\\" + char);

	return str;
}

stringEncodeJSON(str)
{
	return arrayJoin(stringSplit(str, "\\"), "\\\\");
}

pow(base, exponent)
{
	return exp(exponent * log(base));
}

round(float)
{
	if (float - int(float) < 0.5)
		return floor(float);
	else
		return ceil(float);
}

floatRound(float, digits)
{
	digits = coalesce(digits, 0);
	pow = pow(10, digits);

	result = float;
	result *= pow;
	result = round(result);
	result /= pow;

	return result;
}

printLnConsole(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
{
	if (isDefined(a10))
		printConsole(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, "\n");
	else if (isDefined(a9))
		printConsole(a1, a2, a3, a4, a5, a6, a7, a8, a9, "\n");
	else if (isDefined(a8))
		printConsole(a1, a2, a3, a4, a5, a6, a7, a8, "\n");
	else if (isDefined(a7))
		printConsole(a1, a2, a3, a4, a5, a6, a7, "\n");
	else if (isDefined(a6))
		printConsole(a1, a2, a3, a4, a5, a6, "\n");
	else if (isDefined(a5))
		printConsole(a1, a2, a3, a4, a5, "\n");
	else if (isDefined(a4))
		printConsole(a1, a2, a3, a4, "\n");
	else if (isDefined(a3))
		printConsole(a1, a2, a3, "\n");
	else if (isDefined(a2))
		printConsole(a1, a2, "\n");
	else if (isDefined(a1))
		printConsole(a1, "\n");
	else
		printConsole("\n");
}

// Dedicated server only (IW4X 0.6.1)
printChat(msg)
{
	if (!isDedicatedServer()) return;

	if (isPlayer(self))
	{
		if (self isBot()) return;
		exec("tellraw " + self getEntityNumber() + " \"" + msg + "\"");
	}
	else
		exec("sayraw \"" + msg + "\"");
}

respond(msg)
{
	if (isDedicatedServer())
		self printChat(msg);
	else
		if (isPlayer(self))
			self iPrintLn(msg);
		else
			iPrintLn(msg);
}

setWeaponAmmoStockToClipsize(weapon)
{
	maxClipSize = weaponClipSize(weapon);
	if (isSubStr(weapon, "_akimbo")) maxClipSize *= 2;
	self setWeaponAmmoStock(weapon, maxClipSize);
}

getWeaponNameNoAttachments(name)
{
	suffix = ternary(stringEndsWith(name, "_mp"), "_mp", "");

	return strTok(name, "_")[0] + suffix;
}

buildWeaponName(name, attachments)
{
	assertEx(attachments.size <= 2, "Cannot put more than 2 attachments on a weapon.");

	// Allow passing attachment structs from _items.gsc
	foreach (i, attachment in attachments)
		if (!isString(attachment))
			attachments[i] = attachment.name;

	suffix = ternary(stringEndsWith(name, "_mp"), "_mp", "");
	name = getSubStr(name, 0, name.size - suffix.size);

	foreach (attachment in common_scripts\utility::alphabetize(attachments))
		name += "_" + attachment;

	name += suffix;

	return name;
}

getPlayerByName(name, exactMatch)
{
	name = coalesce(name, "");
	exactMatch = coalesce(exactMatch, false);

	if (name == "")
		return undefined;

	foreach (player in level.players)
		if (player.name == name)
			return player;

	if (exactMatch)
		return undefined;

	nameLC = toLower(name);

	foreach (player in level.players)
		if (stringStartsWith(toLower(player.name), nameLC))
			return player;

	foreach (player in level.players)
		if (isSubStr(toLower(player.name), nameLC))
			return player;

	return undefined;
}

hudSetPos(selfAlign, parentAlign, x, y)
{
	self maps\mp\gametypes\_hud_util::setPoint(selfAlign, parentAlign, x, y, undefined);
}

hudSetParent(element)
{
	self maps\mp\gametypes\_hud_util::setParent(element);
}

hudCreateText(font, scale, team)
{
	if (isPlayer(self))
		return maps\mp\gametypes\_hud_util::createFontString(font, scale);
	else
		return maps\mp\gametypes\_hud_util::createServerFontString(font, scale, team);
}

hudCreateImage(w, h, shader, team)
{
	if (isPlayer(self))
		return maps\mp\gametypes\_hud_util::createIcon(shader, w, h);
	else
		return maps\mp\gametypes\_hud_util::createServerIcon(shader, w, h, team);
}

hudCreateRectangle(w, h, color, team)
{
	rect = undefined;
	if (isPlayer(self))
		rect = newClientHudElem(self);
	else if (isDefined(team))
		rect = newTeamHudElem(team);
	else
		rect = newHudElem();
	rect.elemType = "rect";
	rect.x = 0;
	rect.y = 0;
	rect.xOffset = 0;
	rect.yOffset = 0;
	rect.width = w;
	rect.height = h;
	rect.baseWidth = w;
	rect.baseHeight = h;
	rect.color = color;
	rect.alpha = 1.0;
	rect.children = [];
	rect maps\mp\gametypes\_hud_util::setParent(level.uiParent);
	rect.hidden = false;
	rect setShader("white", int(w), int(h));
	rect.shader = "white";

	return rect;
}

hudUpdateRect(w, h, color)
{
	if (isDefined(w)) self.width = w;
	if (isDefined(h)) self.height = h;
	if (isDefined(color)) self.color = color;

	self setShader("white", int(self.width), int(self.height));
	self maps\mp\gametypes\_hud_util::updateChildren();
}

hudDestroyRecursive(elements)
{
	foreach (element in elements)
	{
		if (isArray(element)) hudDestroyRecursive(element);
		else
		{
			element destroy();
			element = undefined;
		}
	}
}

hudComputeSizeRecursive()
{
	val = [];
	val["minX"] = self.x;
	val["minY"] = self.y;
	val["maxX"] = self.x + self.width;
	val["maxY"] = self.y + self.height;

	val = self _hudComputeSizeRecursive(val);

	result = [];
	result["width"] = int(val["maxX"] - val["minX"]);
	result["height"] = int(val["maxY"] - val["minY"]);
	return result;
}

_hudComputeSizeRecursive(val)
{
	if (self.x < val["minX"]) val["minX"] = self.x;
	if (self.y < val["minY"]) val["minY"] = self.y;
	if (self.x + self.width > val["maxX"]) val["maxX"] = self.x + self.width;
	if (self.y + self.height > val["maxY"]) val["maxY"] = self.y + self.height;

	if (isDefined(self.children))
		foreach (child in self.children)
			val = child _hudComputeSizeRecursive(val);

	return val;
}

text3D(pos, text, color, alpha, scale, time)
{
	color = coalesce(color, (1, 1, 1));
	alpha = coalesce(alpha, 1.0);
	scale = coalesce(scale, 1.0);
	time = coalesce(time, 10);

	for (i = 0; i < time * 20; i++)
	{
		print3D(pos, text, color, alpha, scale, 1);
		wait 0.05;
	}
}

line3D(start, end, color, time)
{
	color = coalesce(color, (1, 1, 1));
	time = coalesce(time, 10);

	for (i = 0; i < time * 20; i++)
	{
		line(start, end, color);
		wait 0.05;
	}
}

point3D(pos, color, time)
{
	thread line3D((pos[0] + 1, pos[1] + 1, pos[2] + 1), (pos[0] - 1, pos[1] - 1, pos[2] - 1), color, time);
	thread line3D((pos[0] - 1, pos[1] + 1, pos[2] + 1), (pos[0] + 1, pos[1] - 1, pos[2] - 1), color, time);
	thread line3D((pos[0] + 1, pos[1] - 1, pos[2] + 1), (pos[0] - 1, pos[1] + 1, pos[2] - 1), color, time);
	line3D((pos[0] - 1, pos[1] - 1, pos[2] + 1), (pos[0] + 1, pos[1] + 1, pos[2] - 1), color, time);
}

box3D(mins, maxs, color, time)
{
	verts = [];
	verts[0] = (mins[0], mins[1], mins[2]);
	verts[1] = (maxs[0], mins[1], mins[2]);
	verts[2] = (maxs[0], maxs[1], mins[2]);
	verts[3] = (mins[0], maxs[1], mins[2]);
	verts[4] = (mins[0], mins[1], maxs[2]);
	verts[5] = (maxs[0], mins[1], maxs[2]);
	verts[6] = (maxs[0], maxs[1], maxs[2]);
	verts[7] = (mins[0], maxs[1], maxs[2]);

	edges = [];

	for (i = 0; i < 4; i++)
	{
		// connect vertices horizontally
		edges[i][0] = i;
		edges[i][1] = (i + 1) % 4;
		edges[i + 4][0] = i + 4;
		edges[i + 4][1] = (i + 1) % 4 + 4;

		// connect vertices vertically
		edges[i + 8][0] = i;
		edges[i + 8][1] = i + 4;
	}

	for (i = 0; i < edges.size; i++)
		if (i < edges.size - 1)
			thread line3D(verts[edges[i][0]], verts[edges[i][1]], color, time);
		else
			line3D(verts[edges[i][0]], verts[edges[i][1]], color, time);
}

circle3D(pos, radius, color, time)
{
	SEGMENTS = 32;

	for (i = 0; i < SEGMENTS; i++)
	{
		angle = i / SEGMENTS * 360;
		nextAngle = (i + 1) / SEGMENTS * 360;

		linePos = pos + (cos(angle) * radius, sin(angle) * radius, 0);
		nextLinePos = pos + (cos(nextAngle) * radius, sin(nextAngle) * radius, 0);

		if (i < SEGMENTS - 1)
			thread line3D(linePos, nextLinePos, color, time);
		else
			line3D(linePos, nextLinePos, color, time);
	}
}

_(var)
{
	if (!isDefined(var)) var = "undefined";
	else if (isString(var)) var = "\"" + var + "^7\"";
	else if (isArray(var)) var = arrayToString(var) + "^7";
	printLn("^0[^1#^3#^2#^5#^4#^6#^0] ^7" + var);
}
