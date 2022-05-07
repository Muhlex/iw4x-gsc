#include scripts\_utility;

init()
{
	setDvarIfUninitialized("scr_spawn_open_eyes_effect", false);

	level thread OnPlayerConnected();
}

OnPlayerConnected()
{
	for (;;)
	{
		level waittill("connected", player);

		player thread OnPlayerSpawned();
	}
}

OnPlayerSpawned()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("spawned_player");

		if (getDvarInt("scr_spawn_open_eyes_effect"))
			self thread playOpenEyesEffect();
	}
}

playOpenEyesEffect()
{
	self endon("disconnect");

	bars = [];
	bars[0] = self hudCreateRectangle(640, 240, (0, 0, 0));
	bars[1] = self hudCreateRectangle(640, 240, (0, 0, 0));
	foreach (bar in bars)
	{
		bar.archived = false;
		bar.foreground = true;
		bar.x = -106.6666; // ??
		// ^ moveOverTime is weird like that and needs the horizontal start pos adjusted to be visually at 0
		bar.sort = 1000;
		bar.horzAlign = "fullscreen";
		bar.vertAlign = "middle";
	}
	bars[0].alignY = "bottom";
	bars[1].alignY = "top";

	foreach (bar in bars)
	{
		bar moveOverTime(0.35);
		bar.x = 0;
	}
	bars[0].y = -240;
	bars[1].y = 240;

	self setBlurForPlayer(6.0, 0.0);

	wait 0.05;

	self setBlurForPlayer(0.0, 0.5);

	wait 1.0;

	foreach (bar in bars)
		bar destroy();
}
