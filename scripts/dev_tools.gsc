init()
{
	setDvarIfUninitialized("dev_log_coords", false);

	if (!getDvarInt("dev_log_coords")) return;

	thread OnPlayerConnected();
}

OnPlayerConnected()
{
	for (;;)
	{
		level waittill("connected", player);

		player thread OnPlayerLogCoords();
	}
}

OnPlayerLogCoords()
{
	self endon("disconnect");
	self endon("death");

	self notifyOnPlayerCommand("dev_tools__log_coords", "+actionslot 3");

	for (;;)
	{
		self waittill("dev_tools__log_coords");

		map = getDvar("mapname");
		pos = (int(self.origin[0]), int(self.origin[1]), int(self.origin[2]));
		self iPrintLnBold("Logged position: ^2", pos);
		logPrint("coords_" + map + ": (" + pos[0] + ", " + pos[1] + ", " + pos[2] + ")\n");
	}
}
