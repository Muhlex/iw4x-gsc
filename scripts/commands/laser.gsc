#include scripts\_utility;

cmd(args, prefix, cmd)
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

	if (!isDefined(target.commands.laser))
		target.commands.laser = spawnStruct();

	if (!coalesce(target.commands.laser.active, false))
	{
		SetClientDvars(target, 1);
		target.commands.laser.active = true;
		self respond("^2Enabled Laser Sight for ^7" + target.name + "^2.");
	}
	else
	{
		SetClientDvars(target, 0);
		target.commands.laser.active = false;
		self respond("^2Disabled Laser Sight for ^7" + target.name + "^2.");
	}
}

SetClientDvars(client, value) {
    client setClientDvar( "laserLight", value );
    client setClientDvar( "cg_laserlight", value );
    client setClientDvar( "laserLightWithoutNightvision", value );
    client setClientDvar( "laserForceOn", value );
    if (value == 1) {
        client iPrintlnBold("Laser Enabled");
    } else {
        client iPrintlnBold("Laser Disabled");
    }

}