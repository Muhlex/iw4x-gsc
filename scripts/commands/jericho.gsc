#include scripts\_utility;

cmd(args, prefix, cmd) {
  weap = "deserteaglegold_mp";
  self GiveWeapon(weap);
  visionSetNaked("blacktest");
  wait 0.4;
  self switchToWeapon(weap);
  wait 0.4;
  visionSetNaked(getDvar("mapname"));
  wait 0.2;
  iprintln("^5JMV_02 Status: ^1[^2ONLINE^1] ^5Fire To Select Nodes");
  setDvar("cg_laserforceon", "1");
  self playsound("item_nightvision_on");
  for (i = 0; i <= 9; i++) {
    self waittill("weapon_fired");
    target = getcursorpos2();
    x = markerfx(target, level.oldSchoolCircleYellow);
    self thread jericoMissile(target, x);
  }
  {
    iprintln(
        "^5All Missile Paths Initialized Sir ^5Fire Your Weapon To Launch");
    self waittill("weapon_fired");
    self notify("duckingBoom");
  }
}
jericomissile(target, x) {
  self waittill("duckingBoom");
  x delete ();
  x = markerfx(target, level.oldschoolcirclered);
  location = target + (0, 3500, 5000);
  bomb = spawn("script_model", location);
  bomb playsound("mp_ingame_summary");
  bomb setModel("projectile_rpg7");
  // other models ("projectile_cbu97_clusterbomb"); or ( "projectile_rpg7" );
  bomb.angles = bomb.angles + (90, 90, 90);
  self.killCamEnt = bomb;
  ground = target;
  target = VectorToAngles(ground - bomb.origin);
  bomb rotateto(target, 0.01);
  wait 0.01;
  speed = 3000;
  time = calc(speed, bomb.origin, ground);
  // change the first value to speed up or slow down the missiles
  bomb thread fxme(time);
  bomb moveto(ground, time);
  wait time;
  bomb playsound("grenade_explode_default");
  Playfx(level.expbullt, bomb.origin + (0, 0, 1));
  // change this explosion effect to whatever you use!
  RadiusDamage(bomb.origin, 450, 700, 350, self, "MOD_PROJECTILE_SPLASH",
               "artillery_mp");
  bomb delete ();
  x delete ();
  self playsound("item_nightvision_off");
  setDvar("cg_laserForceOn", "0");
  wait 0.4;
  self takeWeapon("deserteaglegold_mp");
}
vectorScale(vector, scale) // new
{
  return (vector[0] * scale, vector[1] * scale, vector[2] * scale);
}
GetCursorPos() {
  return bulletTrace(
      self getEye(),
      self getEye() +
          vectorScale(anglesToForward(self getPlayerAngles()), 1000000),
      false, self)["position"];
}
MarkerFX(groundpoint, fx) {
  effect = spawnFx(fx, groundpoint, (0, 0, 1), (1, 0, 0));
  triggerFx(effect);

  return effect;
}

fxme(time) {
  for (i = 0; i < time; i++) {
    playFxOnTag(level.rpgeffect, self, "tag_origin");
    wait 0.2;
  }
}

calc(speed, origin, moveTo) { return (distance(origin, moveTo) / speed); }

GetCursorPos2() {
  return bulletTrace(
      self getEye(),
      self getEye() +
          vectorScale(anglesToForward(self getPlayerAngles()), 1000000),
      false, self)["position"];
}

getnewPos(origin, radius) {

  pos = origin +
        ((randomfloat(2) - 1) * radius, (randomfloat(2) - 1) * radius, 0);
  while (distanceSquared(pos, origin) > radius * radius)
    pos = origin +
          ((randomfloat(2) - 1) * radius, (randomfloat(2) - 1) * radius, 0);
  return pos;
}