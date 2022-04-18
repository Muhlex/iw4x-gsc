/**
 * NOTE: This script requires a proxy server to transform IW4X's httpGet request into POST
 * http requests. Currently IW4X cannot send POST requests. A node.js proxy is distributed
 * with this script.
 */

#include scripts\_utility;

init()
{
	setDvarIfUninitialized("scr_http_proxy_url", "http://127.0.0.1:28950/iw4x-proxy");

	level._http = spawnStruct();
	level._http.emoji = [];

	registerEmoji("new moon face", "%F0%9F%8C%9A");
	registerEmoji("new button", "%F0%9F%86%95");
}

// ##### PUBLIC START #####

/**
 * Status code can be awaited using:
 *
 * request = httpPost(...);
 * request waittill("response", statusCode, statusMessage);
 * request waittill("error", proxyReached, errorMessage);
 * OR (combined and similar to httpGet, but without proxy error messages):
 * request waittill("done", success, statusCode, statusMessage);
 */
httpPost(url, headers, body)
{
	proxyURL = getDvar("scr_http_proxy_url");
	headersStr = "";
	foreach (key, value in headers)
		headersStr += "&headers[" + stringEncodeURI(key) + "]=" + stringEncodeURI(value);

	url = stringEncodeURI(url);
	body = stringEncodeURI(body);
	request = httpGet(proxyURL + "?method=POST" + "&url=" + url + headersStr + "&body=" + body);

	wrappedRequest = spawnStruct();
	wrappedRequest.request = request;

	wrappedRequest thread OnHttpPostDone();

	return wrappedRequest;
}


// Returns a URL-encoded emoji compatible with stringEncodeURI
emoji(id)
{
	return coalesce(level._http.emoji[id], "");
}

// ##### PUBLIC END #####

OnHttpPostDone()
{
	self.request waittill("done", success, str);

	if (!success)
	{
		self notify("error", false);
		self notify("done", false);
		return;
	}

	statusCode = int(getSubStr(str, 0, 3));
	statusMessage = getSubStr(str, 3, str.size);

	if (statusCode == 0)
	{
		self notify("error", true, statusMessage);
		self notify("done", false);
		return;
	}

	self notify("response", statusCode, statusMessage);
	self notify("done", true, statusCode, statusMessage);
}

registerEmoji(id, urlEncoded)
{
	level._http.emoji[id] = arrayJoin(stringSplit(urlEncoded, "%"), "%%");
}

// IMPORTANT: Will actually turn '%%' into an UNESCAPED '%'.
// Most likely not much of an issue as '%' cannot be entered in the IW4 client.
stringEncodeURI(str)
{
	map = [];
	map["!"] = "%21";
	map["#"] = "%23";
	map["$"] = "%24";
	map["%"] = "%25";
	map["&"] = "%26";
	map["'"] = "%27";
	map["("] = "%28";
	map[")"] = "%29";
	map["*"] = "%2A";
	map["+"] = "%2B";
	map[","] = "%2C";
	map["/"] = "%2F";
	map[":"] = "%3A";
	map[";"] = "%3B";
	map["="] = "%3D";
	map["?"] = "%3F";
	map["@"] = "%40";
	map["["] = "%5B";
	map["\\"] = "%5C";
	map["]"] = "%5D";

	result = "";

	for (i = 0; i < str.size; i++)
	{
		letter = str[i];
		nextLetter = str[i + 1];

		if (isDefined(nextLetter) && letter == "%" && nextLetter == "%")
		{
			result += letter;
			i++;
			continue;
		}

		if (isDefined(map[letter]))
			result += map[letter];
		else
			result += letter;
	}

	return result;
}
