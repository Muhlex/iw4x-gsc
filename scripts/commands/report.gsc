#include scripts\_utility;

cmd(args, prefix)
{
	if (args.size < 2)
	{
		self respond("^1Usage: " + prefix + args[0] + " <name> [reason]");
		return;
	}

	if (!isDefined(self.commands.report))
		self.commands.report = spawnStruct();

	target = getPlayerByName(args[1]);
	reason = arrayJoin(arraySlice(args, 2), " ");

	if (!isDefined(target))
	{
		self respond("^1Target could not be found.");
		return;
	}

	if (target == self)
	{
		self respond("^1You cannot report yourself.");
		return;
	}

	if (target isBot())
	{
		self respond("^1You cannot report AI players.");
		return;
	}

	cooldownSecs = getDvarInt("scr_commands_report_cooldown");
	lastReportTime = coalesce(self.commands.report.lastReportTime, -2147483648);

	if (lastReportTime + (cooldownSecs * 1000) > getTime())
	{
		self respond("^1You can only send a report every ^7" + cooldownSecs + " ^1seconds.");
		return;
	}

	self.commands.report.lastReportTime = getTime();

	waittillframeend; // wait for chat log tracking of the current command

	json = "" +
"{" +
	"\"embeds\": [" +
		"{" +
			"\"author\": {" +
					"\"name\": \"" + stringRemoveColors(self.name) + " (" + self.guid + ")\"" +
			"}," +
			"\"title\": \"Player Report\"," +
			"\"description\": \"" + ternary(reason.size > 0, "**Reason:** " + esc(reason), "*No reason provided.*") + "\"," +
			"\"color\": 15735344," +
			"\"fields\": [" +
				"{" +
					"\"name\": \"Name\"," +
					"\"value\": \"" + esc(target.name) + "\"," +
					"\"inline\": true" +
				"}," +
				"{" +
					"\"name\": \"GUID\"," +
					"\"value\": \"" + target.guid + "\"," +
					"\"inline\": true" +
				"}," +
				"{" +
					"\"name\": \"IP Address\"," +
					"\"value\": \"" + target getIP() + "\"," +
					"\"inline\": true" +
				"}," +
				"{" +
					"\"name\": \"Recent Chat History\"," +
					"\"value\": \"" + getChatLogStr() + "\"," +
					"\"inline\": false" +
				"}" +
			"]," +
			"\"footer\": {" +
				"\"text\": \"" + esc(getDvar("sv_hostname")) + "\"" +
			"}," +
			"\"timestamp\": \"%ISODATE%\"" +
		"}" +
	"]" +
"}";

	headers = [];
	headers["Content-Type"] = "application/json";

	url = getDvar("scr_commands_report_webhook_url");
	request = scripts\_http::httpPost(url, headers, json);
	self thread OnRequestError(request);
	self thread OnRequestResponse(request, target.name);
}

OnRequestError(request)
{
	request endon("response");
	request waittill("error", proxyReached, errorMessage);

	printLnConsole("^1Error sending report:");
	printLnConsole(ternary(proxyReached, "Proxy Error: ", "Proxy unavailable.") + coalesce(errorMessage, ""));
	self respond("^1Reporting failed. Please contact the server administrator.");
}

OnRequestResponse(request, targetName)
{
	request endon("error");
	request waittill("response", statusCode, statusMessage);

	if (statusCode < 200 || statusCode > 299)
	{
		printLnConsole("^1Error sending report:");
		printLnConsole("Unexpected HTTP response: [" + statusCode + "] " + statusMessage);
		self respond("^1Reporting failed.");
		return;
	}

	self respond("^2Reported ^7" + targetName + "^2.");
}

getChatLogStr()
{
	log = scripts\_log::getChatLog();

	str = "";
	time = getTime();
	maxAge = getDvarInt("scr_commands_report_chat_log_max_age");
	for (i = log.size - 1; i >= 0; i--)
	{
		msg = log[i];
		if (msg.systemTime + maxAge < getSystemTime())
			break;
		str = "<t:" + msg.systemTime + ":t> **" + esc(msg.name) + ":** " + esc(msg.text) + "\\n" + str;
	}
	return ternary(str != "", getSubStr(str, 0, str.size - 2), "-");
}

esc(str)
{
	return stringEncodeJSON(stringEncodeDiscord(stringRemoveColors(str)));
}
