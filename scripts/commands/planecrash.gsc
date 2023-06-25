#include scripts\_utility;

cmd(args, prefix, cmd)
{
    self endon("disconnect");
    self endon("death");
    self endon("PilotsCrashed");
    ElectricHaze = spawn("script_model",self.origin+(18000,0,2400));
    ElectricHaze2 = spawn("script_model",self.origin+(-18000,0,2400));
    ElectricHaze setModel("vehicle_ac130_low_mp");
    ElectricHaze2 setModel("vehicle_ac130_low_mp");
    ElectricHaze MoveTo(self.origin+(0,0,2400),10);
    ElectricHaze2 MoveTo(self.origin+(0,0,2400),10);
    ElectricHaze.angles=(0,180,0);
    ElectricHaze2.angles=(0,0,0);
    wait 10;
    level._effect[ "FOW" ]=loadfx("explosions/emp_flash_mp");
    PlayFX(level._effect[ "FOW" ],ElectricHaze.origin);
    self thread PilotCrashFX();
    ElectricHaze delete();
    ElectricHaze2 delete();
}

PilotCrashFX() {
    self endon("disconnect");
    self endon("death");
    earthquake( 0.6, 4, self.origin, 100000 );
    foreach(player in level.players)
    {
        player playlocalsound("nuke_explosion");
        player playlocalsound("nuke_wave");
    }
}