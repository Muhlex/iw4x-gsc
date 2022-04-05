init()
{
	setDvarIfUninitialized("scr_allow_classchange", true);

	if (getDvarInt("scr_allow_classchange")) return;

	level.customClassCB = true;
	level thread OnPlayerConnected();
}

OnPlayerConnected()
{
	for (;;)
	{
		level waittill("connected", player);

		player thread OnPlayerMenuResponse();
	}
}

OnPlayerMenuResponse()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("menuresponse", menu, response);

		if (response != "changeclass_marines" && response != "changeclass_opfor")
			continue;

		self iPrintLnBold("Changing classes is ^3disabled^7.");
	}
}
