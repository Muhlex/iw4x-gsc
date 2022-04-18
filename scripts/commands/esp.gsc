#include scripts\_utility;

cmd(args, prefix)
{
	if (isDefined(args[1]))
		target = getPlayerByName(args[1]);
	else
		target = self;

	if (!isDefined(target))
	{
		self respond("^1Target could not be found.");
		return;
	}

	if (!isDefined(target.commands.esp))
		target.commands.esp = spawnStruct();

	if (!coalesce(target.commands.esp.active, false))
	{
		target initEspHud();
		target.commands.esp.active = true;
		self respond("^2Enabled ESP for ^7" + target.name + "^2.");
	}
	else
	{
		target destroyEspHud();
		target.commands.esp.active = false;
		self respond("^2Disabled ESP for ^7" + target.name + "^2.");
	}
}

initEspHud()
{
	self destroyEspHud();

	self thread OnEspIconSelfJoinTeam();
	self thread OnEspPlayerConnected();

	foreach (target in level.players)
	{
		if (target == self)
			continue;

		self initEspIcon(target);
	}
}

destroyEspHud()
{
	self notify("commands__esp_disable");
}

OnEspIconSelfJoinTeam()
{
	self endon("disconnect");
	self endon("commands__esp_disable");

	self waittillAny("joined_team", "joined_spectators");

	self thread initEspHud(); // thread due to endon
}

OnEspPlayerConnected()
{
	self endon("disconnect");
	self endon("commands__esp_disable");

	for (;;)
	{
		level waittill("connected", player);

		self initEspIcon(player);
	}
}

initEspIcon(target)
{
	if (!self isTeammate(target))
	{
		icon = self createEspIcon(target);
		self thread OnEspIconDisable(icon);
		self thread OnEspIconTargetDisconnect(icon, target);
		self thread OnEspIconTargetJoinTeam(icon, target);
	}
	else
	{
		self thread OnEspIconTargetJoinTeam(undefined, target);
	}
}

createEspIcon(target)
{
	COLORS = [];
	COLORS[0] = (254/255, 74/255, 73/255);
	COLORS[1] = (63/255, 132/255, 229/255);
	COLORS[2] = (42/255, 245/255, 255/255);
	COLORS[3] = (12/255, 202/255, 74/255);
	COLORS[4] = (249/255, 200/255, 14/255);
	COLORS[5] = (214/255, 122/255, 214/255);
	COLORS[6] = (255/255, 255/255, 255/255);

	icon = self hudCreateImage(10, 10, "objpoint_default");
	icon.archived = false;
	icon.color = COLORS[target getEntityNumber() % COLORS.size];
	icon setWaypoint(false, false);
	icon setTargetEnt(target);

	return icon;
}

OnEspIconDisable(icon)
{
	icon endon("death");

	self waittillAny("commands__esp_disable", "disconnect");

	icon destroy();
}

OnEspIconTargetDisconnect(icon, target)
{
	icon endon("death");

	target waittill("disconnect");

	icon destroy();
}

OnEspIconTargetJoinTeam(icon, target)
{
	if (isDefined(icon))
		icon endon("death");
	else
	{
		self endon("commands__esp_disable");
		self endon("disconnect");
		target endon("disconnect");
	}

	target waittillAny("joined_team", "joined_spectators");

	self initEspIcon(target);
	if (isDefined(icon))
		icon destroy();
}
