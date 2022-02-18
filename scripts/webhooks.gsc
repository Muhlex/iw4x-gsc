/**
 * NOTE: This script requires a proxy server to transform IW4X's httpGet request into POST
 * HTTP requests that the Discord API expects. Currently IW4X cannot send POST http requests.
 */

#include scripts\_utility;

init()
{
	setDvarIfUninitialized("sv_webhook_proxy_url", "http://127.0.0.1:28950/webhook");
	setDvarIfUninitialized("sv_webhook_url", "");

	if (!isDefined(game["webhooks__map_start_time"]))
		game["webhooks__map_start_time"] = getSystemTime();

	if (!storageHas("webhooks__guids"))
		storageSet("webhooks__guids", "");

	level thread OnPlayerConnected();
	level thread OnGameEnded();
}

OnPlayerConnected()
{
	for (;;)
	{
		level waittill("connected", player);

		if (player entityIsBot()) continue;

		player thread OnPlayerDisconnected(player);

		guidsStr = storageGet("webhooks__guids");
		guids = unserializeGUIDs(guidsStr);
		if (arrayContains(guids, player.guid)) continue;

		if (guids.size > 0) guidsStr += ";";
		guidsStr += player.guid;

		storageSet("webhooks__guids", guidsStr);
		sendWebhookPlayerConnect(player);
	}
}

OnPlayerDisconnected()
{
	self waittill("disconnect");

	guidsStr = storageGet("webhooks__guids");
	guids = unserializeGUIDs(guidsStr);

	guids = arrayRemove(guids, self.guid);
	guidsStr = serializeGUIDs(guids);

	storageSet("webhooks__guids", guidsStr);

	if (level.players.size == 0)
		sendWebhookServerEmpty();
}

OnGameEnded()
{
	level waittill("game_ended");

	CONNECT_TIMEOUT = 60;

	// The script engine does not run all the time and players can disconnect between map loads.
	// Thus, clean up the known player list once no one is connecting from the last map anymore.
	if (getSystemTime() - game["webhooks__map_start_time"] < CONNECT_TIMEOUT) return;

	guids = [];
	foreach (player in level.players)
		guids[guids.size] = player.guid;

	storageSet("webhooks__guids", serializeGUIDs(guids));
}

serializeGUIDs(array)
{
	str = "";
	foreach (guid in array)
		str += guid + ";";
	str = getSubStr(str, 0, str.size - 1);

	return str;
}

unserializeGUIDs(str)
{
	guids = strTok(str, ";");
	return guids;
}

sendWebhookPlayerConnect(newPlayer)
{
	waittillframeend;

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
			// 	"\"url\": \"https://gib.murl.is/static/embed.png\"" +
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
	webhookURL = getDvar("sv_webhook_url");
	if (proxyURL == "" || webhookURL == "") return;

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
