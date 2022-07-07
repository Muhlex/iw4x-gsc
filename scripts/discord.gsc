#include scripts\_utility;

init()
{
	setDvarIfUninitialized("scr_discord_webhook_urls", "");
	setDvarIfUninitialized("scr_discord_join", false);
	setDvarIfUninitialized("scr_discord_empty", false);

	level thread OnPlayerJoined();
	level thread OnServerEmpty();
}

OnPlayerJoined()
{
	for (;;)
	{
		level waittill("_lifecycle__joined", player);

		if (player isBot()) continue;

		if (getDvarInt("scr_discord_join"))
			sendWebhookPlayerConnect(player);
	}
}

OnServerEmpty()
{
	for (;;)
	{
		level waittill("_lifecycle__empty_ignorebots");

		if (getDvarInt("scr_discord_empty"))
			sendWebhookServerEmpty();
	}
}

sendWebhookPlayerConnect(newPlayer)
{
	waittillframeend; // wait for player to be added to level.players

	json = "" +
"{" +
	"\"embeds\": [" +
		"{" +
			"\"title\": \"Player joined\"," +
			"\"color\": 9158559," +
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
				"\"text\": \"" + esc(getDvar("sv_hostname")) + "\"" +
			"}," +
			"\"timestamp\": \"" + scripts\_date::getSystemTimeISO() + "\"" +
		"}" +
	"]" +
"}";

	executeWebhook(json);
}

sendWebhookServerEmpty()
{
	json = "" +
"{" +
	"\"embeds\": [" +
		"{" +
			"\"title\": \"Server empty\"," +
			"\"description\": \"Party's over! " + scripts\_http::emoji("new moon face") + "\"," +
			"\"color\": 16543359," +
			"\"footer\": {" +
				"\"text\": \"" + esc(getDvar("sv_hostname")) + "\"" +
			"}," +
			"\"timestamp\": \"" + scripts\_date::getSystemTimeISO() + "\"" +
		"}" +
	"]" +
"}";

	executeWebhook(json);
}

// sendWebhookRoundEnd()
// {
// 	json = "" +
// "{" +
// 	"\"embeds\": [" +
// 		"{" +
// 			"\"title\": \"Round ended\"," +
// 			"\"description\": \"Party's over! %F0%9F%8C%9A\"," +
// 			"\"color\": 7640298," +
// 			"\"footer\": {" +
// 				"\"text\": \"" + stringRemoveColors(getDvar("sv_hostname")) + "\"" +
// 			"}," +
// 			"\"timestamp\": \"" + scripts\_date::getSystemTimeISO() + "\"" +
// 		"}" +
// 	"]" +
// "}";

// 	executeWebhook(json);
// }

executeWebhook(json)
{
	urls = strTok(getDvar("scr_discord_webhook_urls"), " ");
	if (urls.size == 0) return;

	headers = [];
	headers["Content-Type"] = "application/json";

	foreach (url in urls)
		request = scripts\_http::httpPost(url, headers, json);
}

buildPlayerList(newPlayer)
{
	str = "";
	foreach (player in level.players)
	{
		newPrefix = "";
		if (isDefined(newPlayer) && player == newPlayer)
			newPrefix = scripts\_http::emoji("new button") + " ";
		str += newPrefix + esc(player.name) + "\\n";
	}
	return str;
}

esc(str)
{
	return stringEncodeJSON(stringEncodeDiscord(stringRemoveColors(str)));
}
