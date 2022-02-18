arrayRemove(array, item)
{
	result = [];
	foreach (el in array)
		if (el != item)
			result[result.size] = el;

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

arrayContains(array, item)
{
	foreach (el in array)
		if (el == item)
			return true;

	return false;
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

entityIsBot()
{
	if (!isDefined(self.guid)) return false;
	return getSubStr(self.guid, 0, 3) == "bot";
}
