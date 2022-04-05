/**
 * NOTE: This script requires a proxy server to transform IW4X's httpGet request into POST
 * HTTP requests that the Discord API expects. Currently IW4X cannot send POST http requests.
 */

#include scripts\_utility;

init()
{
	setDvarIfUninitialized("sv_webhook_proxy_url", "http://127.0.0.1:28950/webhook");
	setDvarIfUninitialized("sv_webhook_urls", "");

	level thread OnPlayerJoined();
	level thread OnServerEmpty();
}

OnPlayerJoined()
{
	for (;;)
	{
		level waittill("_lifecycle__joined", player);

		if (player isBot()) continue;

		sendWebhookPlayerConnect(player);
	}
}

OnServerEmpty()
{
	for (;;)
	{
		level waittill("_lifecycle__empty_ignorebots");

		sendWebhookServerEmpty();
	}
}

sendWebhookPlayerConnect(newPlayer)
{
	waittillframeend; // wait for player to be added to level.players

	json = escapeURIString(
"{" +
	"\"embeds\": [" +
		"{" +
			"\"title\": \"Player joined\"," +
			"\"color\": 11313056," +
			"\"fields\": [" +
				"{" +
					"\"name\": \"Players\"," +
					"\"value\": \"" + buildPlayerList(newPlayer) + "\"," +
					"\"inline\": true" +
				"}," +
				"{" +
					"\"name\": \"Map\"," +
					"\"value\": \"" + getDvar("mapname") + "\"," +
					"\"inline\": true" +
				"}" +
			"]," +
			"\"footer\": {" +
				"\"text\": \"" + stringRemoveColors(getDvar("sv_hostname")) + "\"" +
			"}," +
			"\"timestamp\": \"%CURRENTTIME%\"" + // currently timestamp is put in via proxy server
			// "\"thumbnail\": {" +
			// 	"\"url\": \"https://example.com\"" +
			// "}" +
		"}" +
	"]" +
"}");

	executeWebhook(json);
}

sendWebhookServerEmpty()
{
	json = escapeURIString(
"{" +
	"\"embeds\": [" +
		"{" +
			"\"title\": \"Server empty\"," +
			"\"description\": \"Party's over! %F0%9F%8C%9A\"," +
			"\"color\": 11313056," +
			"\"footer\": {" +
				"\"text\": \"" + stringRemoveColors(getDvar("sv_hostname")) + "\"" +
			"}," +
			"\"timestamp\": \"%CURRENTTIME%\"" + // currently timestamp is put in via proxy server
		"}" +
	"]" +
"}");

	executeWebhook(json);
}

executeWebhook(json)
{
	proxyURL = getDvar("sv_webhook_proxy_url");
	webhookURLs = strTok(getDvar("sv_webhook_urls"), " ");
	if (proxyURL == "" || webhookURLs.size == 0) return;

	foreach (webhookURL in webhookURLs)
		request = httpGet(proxyURL + "?url=" + webhookURL + "&body=" + json);
}

escapeURIString(str)
{
	map = [];
	map["!"] = "%21";
	map["#"] = "%23";
	map["$"] = "%24";
	// map["%"] = "%25"; // probably not necessary due to % being unavailable in the client anyway... allows for URL encoded emoji
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

		if (isDefined(map[letter]))
			result += map[letter];
		else
			result += letter;
	}

	return result;
}

buildPlayerList(newPlayer)
{
	str = "";
	foreach (player in level.players)
	{
		newPrefix = "";
		if (isDefined(newPlayer) && player == newPlayer)
			newPrefix = "%F0%9F%86%95 ";
		str += newPrefix + player.name + "\\n";
	}
	return stringRemoveColors(str);
}
