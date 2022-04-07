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

runAfterDelay(func, delay, a1, a2, a3, a4, a5, a6, a7, a8)
{
	wait delay;
	self [[func]](a1, a2, a3, a4, a5, a6, a7, a8);
}

runAfterEvent(func, event, a1, a2, a3, a4, a5, a6, a7, a8)
{
	self waittill(event);
	self [[func]](a1, a2, a3, a4, a5, a6, a7, a8);
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

isArray(var)
{
	return isDefined(getArrayKeys(var).size);
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
		if (self [[func]](el, a1, a2, a3, a4, a5, a6, a7, a8))
			return el;
	return undefined;
}

arrayFilter(array, func, a1, a2, a3, a4, a5, a6, a7, a8)
{
	result = [];

	foreach (el in array)
		if (self [[func]](el, a1, a2, a3, a4, a5, a6, a7, a8))
			result[result.size] = el;

	return result;
}

stringStartsWith(str, startstr)
{
	return (getSubStr(str, 0, startstr.size) == startstr);
}

stringEndsWith(str, endstr)
{
	return (getSubStr(str, str.size - endstr.size, str.size) == endstr);
}

stringSplit(str, delim)
{
	// strTok only works as expected with singular characters
	// https://www.cplusplus.com/reference/cstring/strtok/
	array = [];

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

stringRemoveColors(str)
{
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

setWeaponAmmoStockToClipsize(weapon)
{
	maxClipSize = weaponClipSize(weapon);
	if (isSubStr(weapon, "_akimbo")) maxClipSize *= 2;
	self setWeaponAmmoStock(weapon, maxClipSize);
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
		self iPrintLn(msg);
}

buildWeaponName(name, attachments)
{
	for (i = 0; i < 2; i++)
		if (!isDefined(attachments[i]))
			attachments[i] = "none";

	if (stringEndsWith(name, "_mp"))
		name = getSubStr(name, 0, name.size - "_mp".size);

	name = _buildWeaponName(name, attachments[0], attachments[1]);

	return name;
}

// -- modified from _class.gsc --
// This is bad, but cba to rewrite it atm. It sorts the attachments alphabetically.
// Kind of... Don't use the original function directly because it breaks permanently
// when calling it too early (before level.weaponList is defined)... Seriously.
_buildWeaponName(baseName, attachment1, attachment2)
{
	if ( !isDefined( level.letterToNumber ) )
		level.letterToNumber = maps\mp\gametypes\_class::makeLettersToNumbers();

	weaponName = baseName;
	attachments = [];

	if ( attachment1 != "none" && attachment2 != "none" )
	{
		if ( level.letterToNumber[attachment1[0]] < level.letterToNumber[attachment2[0]] )
		{
			attachments[0] = attachment1;
			attachments[1] = attachment2;
		}
		else if ( level.letterToNumber[attachment1[0]] == level.letterToNumber[attachment2[0]] )
		{
			if ( level.letterToNumber[attachment1[1]] < level.letterToNumber[attachment2[1]] )
			{
				attachments[0] = attachment1;
				attachments[1] = attachment2;
			}
			else
			{
				attachments[0] = attachment2;
				attachments[1] = attachment1;
			}
		}
		else
		{
			attachments[0] = attachment2;
			attachments[1] = attachment1;
		}
	}
	else if ( attachment1 != "none" )
		attachments[0] = attachment1;
	else if ( attachment2 != "none" )
		attachments[0] = attachment2;

	foreach ( attachment in attachments )
		weaponName += "_" + attachment;

	return ( weaponName + "_mp" );
}

getPlayerByName(name, exactMatch)
{
	exactMatch = coalesce(exactMatch, false);

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
	return [];
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
