#include scripts\_utility;

cmd(args, prefix, cmd)
{
    precacheItem("lightstick_mp");
    self takeweapon( "semtex_mp" );
    self takeweapon( "claymore_mp" );
    self takeweapon( "frag_grenade_mp" );
    self takeweapon( "c4_mp" );
    self takeweapon( "throwingknife_mp" );
    self takeweapon( "concussion_grenade_mp" );
    self takeweapon( "smoke_grenade_mp" );
    self giveweapon("c4_mp",0,false);
    wait 0.01;
    self takeweapon( "c4_mp" );
    wait 0.5;
    self giveweapon("lightstick_mp",0,false);
}