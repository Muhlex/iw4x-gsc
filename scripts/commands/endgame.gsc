#include scripts\_utility;

cmd(args, prefix, cmd)
{
	if (getDvar("scr_war_timelimit") == 1) {
		setDvar("scr_dm_timelimit", 10);
		setDvar("scr_war_timelimit", 20);
		setDvar("scr_dom_timelimit", 2.5);
		setDvar("scr_dd_timelimit", 2.5);
		setDvar("scr_sd_timelimit", 2.5);
		setDvar("scr_sab_timelimit", 20);
		setDvar("scr_ctf_timelimit", 10);
		setDvar("scr_oneflag_timelimit", 3);
		setDvar("scr_koth_timelimit", 15);
		setDvar("scr_arena_timelimit", 2.5);
		setDvar("scr_gtnw_timelimit", 10);
		self respond("Restored normal game time limits.");
	} else {
		setDvar("scr_dm_timelimit", 1);
		setDvar("scr_war_timelimit", 1);
		setDvar("scr_dom_timelimit", 1);
		setDvar("scr_dd_timelimit", 1);
		setDvar("scr_sd_timelimit", 1);
		setDvar("scr_sab_timelimit", 1);
		setDvar("scr_ctf_timelimit", 1);
		setDvar("scr_oneflag_timelimit", 1);
		setDvar("scr_koth_timelimit", 1);
		setDvar("scr_arena_timelimit", 1);
		setDvar("scr_gtnw_timelimit", 1);
		self respond("Set all game time limits to 1 second.");
	}
}
