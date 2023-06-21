#include scripts\_utility;

cmd(args, prefix, cmd)
{
	if (getDvar("scr_airdrop_ac130") > 3) {
		setDvar("scr_airdrop_ac130", 3);
		// setDvar("scr_airdrop_emp", 2);
		setDvar("scr_airdrop_helicopter_minigun", 3);
		setDvar("scr_airdrop_nuke", 1);
		self respond("^2Airdrops are now ^3normal^2.");
	} else {
		setDvar("scr_airdrop_ac130", 99);
		// setDvar("scr_airdrop_emp", 99);
		setDvar("scr_airdrop_helicopter_minigun", 99);
		setDvar("scr_airdrop_nuke", 99);
		self respond("^2Airdrops are now ^1insane^2.");
	}
}
