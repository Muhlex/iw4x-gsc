#include scripts\_utility;

cmd(args, prefix)
{
	if (args.size < 2)
	{
		self respond("^1Usage: " + prefix + args[0] + " <name> [reason]");
		return;
	}

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

	json = "" +
"{" +
	"\"embeds\": [" +
		"{" +
			"\"author\": {" +
					"\"name\": \"" + stringRemoveColors(self.name) + " (" + self.guid + ")\"" +
			"}," +
			"\"title\": \"Player Report\"," +
			"\"description\": \"" + ternary(reason.size > 0, "**Reason:** " + reason, "*No reason provided.*") + "\"," +
			"\"color\": 15735344," +
			"\"fields\": [" +
				"{" +
					"\"name\": \"Name\"," +
					"\"value\": \"" + stringRemoveColors(target.name) + "\"," +
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
				"}" +
			"]," +
			"\"footer\": {" +
				"\"text\": \"" + stringRemoveColors(getDvar("sv_hostname")) + "\"" +
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

	self respond("^2Reported " + targetName + "^2.");
}
