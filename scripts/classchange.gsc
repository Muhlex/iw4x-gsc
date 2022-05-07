init()
{
	setDvarIfUninitialized("scr_allow_classchange", true);

	if (getDvarInt("scr_allow_classchange")) return;

	level.customClassCB = true; // disables ability to open class menu
	replaceFunc(maps\mp\gametypes\_menus::beginClassChoice, ::beginClassChoice);
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

beginClassChoice(forceNewChoice)
{
	assert(self.pers["team"] == "axis" || self.pers["team"] == "allies");

	if (!isAlive(self))
		self thread maps\mp\gametypes\_playerlogic::predictAboutToSpawnPlayerOverTime(0.1);

	self.selectedClass = true;
	self maps\mp\gametypes\_menus::menuClass("class10");
}
