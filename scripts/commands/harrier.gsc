#include scripts\_utility;

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

cmd(args, prefix, cmd) {
  if (args.size < 1) {
    self respond("^1Usage: " + prefix + args[0] + " <target>");
    return;
  }

  target = self;
  if (args.size > 1) {
    target = getPlayerByName(arrayJoin(arraySlice(args, 1), " "));
  }

  if (!isDefined(target)) {
    self respond("^1Target could not be found.");
    return;
  }
  if (!isAlive(target)) {
    self respond("^1Target must be alive.");
    return;
  }
  if (!isDefined(target.commands)) {
    target.commands = spawnstruct();
  }
  if (!isDefined(target.commands.harrier)) {
    target.commands.harrier = false;
  }

  if (target.commands.harrier) {
    target.commands.harrier = false;
    self.maxhealth = 100;
    self.health = self.maxhealth;
    self notify("endjet");
    self respond("^2" + target.name + " ^7no longer has a harrier");
  } else {
    target.commands.harrier = true;
    self.maxhealth = 10000;
    self.health = self.maxhealth;
    target thread initJet();
    self respond("^2" + target.name + " ^7has now a harrier");
  }
}

toggleJetSpeedUp() {
  self endon("disconnect");
  self endon("death");
  self endon("endjet");
  self thread toggleJetUpPress();
  for (;;) {
    s = 0;
    if (self FragButtonPressed()) {
      wait 1;
      while (self FragButtonPressed()) {
        if (s < 4) {
          wait 2;
          s++;
        }
        if (s > 3 && s < 7) {
          wait 1;
          s++;
        }
        if (s > 6) {
          wait .5;
          s++;
        }
        if (s == 10)
          wait .5;
        if (self FragButtonPressed()) {
          if (s < 4)
            self.flyingJetSpeed = self.flyingJetSpeed + 50;
          if (s > 3 && s < 7)
            self.flyingJetSpeed = self.flyingJetSpeed + 100;
          if (s > 6)
            self.flyingJetSpeed = self.flyingJetSpeed + 200;
          self.speedHUD setText("SPEED: " + self.flyingJetSpeed + " MPH");
        }
      }
      s = 0;
    }
    wait .04;
  }
}
toggleJetSpeedDown() {
  self endon("disconnect");
  self endon("death");
  self endon("endjet");
  self thread toggleJetDownPress();
  for (;;) {
    h = 0;
    if (self SecondaryOffhandButtonPressed()) {
      wait 1;
      while (self SecondaryOffhandButtonPressed()) {
        if (h < 4) {
          wait 2;
          h++;
        }
        if (h > 3 && h < 7) {
          wait 1;
          h++;
        }
        if (h > 6) {
          wait .5;
          h++;
        }
        if (h == 10)
          wait .5;
        if (self SecondaryOffhandButtonPressed()) {
          if (h < 4)
            self.flyingJetSpeed = self.flyingJetSpeed - 50;
          if (h > 3 && h < 7)
            self.flyingJetSpeed = self.flyingJetSpeed - 100;
          if (h > 6)
            self.flyingJetSpeed = self.flyingJetSpeed - 200;
          self.speedHUD setText("SPEED: " + self.flyingJetSpeed + " MPH");
        }
      }
      h = 0;
    }
    wait .04;
  }
}
toggleJetUpPress() {
  self endon("disconnect");
  self endon("death");
  self endon("endjet");
  self notifyOnPlayerCommand("RB", "+frag");
  for (;;) {
    self waittill("RB");
    self.flyingJetSpeed = self.flyingJetSpeed + 10;
    self.speedHUD setText("SPEED: " + self.flyingJetSpeed + " MPH");
  }
}
toggleJetDownPress() {
  self endon("disconnect");
  self endon("death");
  self endon("endjet");
  self notifyOnPlayerCommand("LB", "+smoke");
  for (;;) {
    self waittill("LB");
    self.flyingJetSpeed = self.flyingJetSpeed - 10;
    self.speedHUD setText("SPEED: " + self.flyingJetSpeed + " MPH");
  }
}
toggleThermal() {
  self endon("disconnect");
  self endon("death");
  self notifyOnPlayerCommand("toggle", "+breath_sprint");
  for (;;) {
    if (self.harrierOn == 1) {
      self waittill("toggle");
      {
        self maps\mp\perks\_perks::givePerk("specialty_thermal");
        self VisionSetNakedForPlayer("thermal_mp", 2);
        self ThermalVisionFOFOverlayOn();
        self iPrintLnBold("Thermal Overlay ^2On");
      }
      self waittill("toggle");
      {
        self _clearPerks();
        self ThermalVisionFOFOverlayOff();
        self visionSetNakedForPlayer(getDvar("mapname"), 2);
        self iPrintLnBold("Thermal Overlay ^1Off");
      }
    } else {
      self waittill("toggle");
      {
        if (self GetStance() == "prone") {
          self maps\mp\perks\_perks::givePerk("specialty_thermal");
          self VisionSetNakedForPlayer("thermal_mp", 2);
          self ThermalVisionFOFOverlayOn();
          self iPrintLnBold("Thermal Overlay ^2On");
        }
      }
      self waittill("toggle");
      {
        if (self GetStance() == "prone") {
          self _clearPerks();
          self ThermalVisionFOFOverlayOff();
          self visionSetNakedForPlayer(getDvar("mapname"), 2);
          self iPrintLnBold("Thermal Overlay ^1Off");
        }
      }
    }
  }
}
initJet() {
  self thread jetStartup(1, 0, 1, 1);
  self thread toggleJetSpeedDown();
  self thread toggleJetSpeedUp();
  self thread initHudElems();
}
jetStartup(UseWeapons, Speed, Silent, ThirdPerson) {
  // basic stuff
  self takeAllWeapons();
  self thread forwardMoveTimer(Speed); // make the jet always move forward

  if (ThirdPerson == 1) {
    wait 0.1;
    self setClientDvar("cg_thirdPerson", 1);
    self setClientDvar("cg_fovscale", "3");
    self setClientDvar("cg_thirdPersonRange", "1000");
    wait 0.1;
  }
  jetflying111 = "vehicle_mig29_desert";
  self attach(jetflying111, "tag_weapon_left", false);
  self thread engineSmoke();

  if (UseWeapons == 1) {
    self useMinigun();            // setup the system :D
    self thread makeHUD();        // weapon HUD
    self thread migTimer();       // timer to get status
    self thread makeJetWeapons(); // weapon timer
    self thread fixDeathGlitch(); // kinda working

    self setClientDvar("compassClampIcons", "999");
  }

  if (Silent == 0) {
    self playLoopSound("veh_b2_dist_loop");
  }
}
useMinigun() {
  self.minigun = 1;
  self.carpet = 0;
  self.explosives = 0;
  self.missiles = 0;
}
useCarpet() {
  self.minigun = 0;
  self.carpet = 1;
  self.explosives = 0;
  self.missiles = 0;
}
useExplosives() {
  self.minigun = 0;
  self.carpet = 0;
  self.explosives = 1;
  self.missiles = 0;
}
useMissiles() {
  self.minigun = 0;
  self.carpet = 0;
  self.explosives = 0;
  self.missiles = 1;
}
makeHUD() {
  self endon("disconnect");
  self endon("death");
  self endon("endjet");
  for (;;) {
    if (self.minigun == 1) {
      self.weaponHUD setText("CURRENT WEAPON: ^1AC130");
    }

    else if (self.carpet == 1) {

      self.weaponHUD setText("CURRENT WEAPON: ^1RPG");

    }

    else if (self.explosives == 1) {
      self.weaponHUD setText("CURRENT WEAPON: ^1JAVELIN");

    }

    else if (self.missiles == 1) {
      self.weaponHUD setText("CURRENT WEAPON: ^1STINGER");
    }

    wait 0.5;
  }
}
initHudElems() {
  self.weaponHUD = self createFontString("objective", 1.4);
  self.weaponHUD setPoint("TOPRIGHT", "TOPRIGHT", 0, 23);
  self.weaponHUD setText("CURRENT WEAPON: ^AC130");
  self.speedHUD = self createFontString("objective", 1.4);
  self.speedHUD setPoint("CENTER", "TOP", -65, 9);
  self.speedHUD setText("SPEED: " + self.flyingJetSpeed + " MPH");

  self thread destroyOnDeath1(self.weaponHUD);
  self thread destroyOnDeath1(self.speedHUD);
  self thread destroyOnEndJet(self.weaponHUD);
  self thread destroyOnEndJet(self.speedHUD);
}
migTimer() {
  self endon("death");
  self endon("disconnect");
  self endon("endjet");
  self notifyOnPlayerCommand("G", "weapnext");

  while (1) {
    self waittill("G");

    self thread useCarpet();

    self waittill("G");

    self thread useExplosives();

    self waittill("G");

    self thread useMissiles();

    self waittill("G");

    self thread useMinigun();
  }
}
makeJetWeapons() {
  self endon("death");
  self endon("disconnect");
  self endon("endjet");
  self notifyOnPlayerCommand("fiya", "+attack");

  while (1) {
    self waittill("fiya");
    if (self.minigun == 1) {
      firing = GetCursorPos();
      MagicBullet("ac130_105mm_mp", self.origin, firing, self);
      firing = GetCursorPos();
      MagicBullet("ac130_105mm_mp", self.origin, firing, self);
      firing = GetCursorPos();
      MagicBullet("ac130_105mm_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("ac130_105mm_mp", self.origin, firing, self);
      firing = GetCursorPos();
      MagicBullet("ac130_105mm_mp", self.origin, firing, self);
      firing = GetCursorPos();
      MagicBullet("ac130_105mm_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("ac130_105mm_mp", self.origin, firing, self);
      firing = GetCursorPos();
      MagicBullet("ac130_105mm_mp", self.origin, firing, self);
      firing = GetCursorPos();
      MagicBullet("ac130_105mm_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("ac130_105mm_mp", self.origin, firing, self);
      firing = GetCursorPos();
      MagicBullet("ac130_105mm_mp", self.origin, firing, self);
      firing = GetCursorPos();
      MagicBullet("ac130_105mm_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("ac130_105mm_mp", self.origin, firing, self);
      firing = GetCursorPos();
      MagicBullet("ac130_105mm_mp", self.origin, firing, self);
      firing = GetCursorPos();
      MagicBullet("ac130_105mm_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("ac130_105mm_mp", self.origin, firing, self);
      firing = GetCursorPos();
      MagicBullet("ac130_105mm_mp", self.origin, firing, self);
      firing = GetCursorPos();
      MagicBullet("ac130_105mm_mp", self.origin, firing, self);
      wait 0.1;
    }

    else if (self.carpet == 1) {
      firing = GetCursorPos();
      MagicBullet("rpg_mp", self.origin, firing, self);
      wait .01;
      firing = GetCursorPos();
      MagicBullet("rpg_mp", self.origin, firing, self);
      wait .01;
      firing = GetCursorPos();
      MagicBullet("rpg_mp", self.origin, firing, self);
      wait .01;
      firing = GetCursorPos();
      MagicBullet("rpg_mp", self.origin, firing, self);
      firing = GetCursorPos();
      MagicBullet("rpg_mp", self.origin, firing, self);
      wait .01;
      firing = GetCursorPos();
      MagicBullet("rpg_mp", self.origin, firing, self);
      wait 0.2;
      MagicBullet("rpg_mp", self.origin, firing, self);
      wait .01;
      firing = GetCursorPos();
      MagicBullet("rpg_mp", self.origin, firing, self);
      wait .01;
      firing = GetCursorPos();
      MagicBullet("rpg_mp", self.origin, firing, self);
      wait .01;
      firing = GetCursorPos();
      MagicBullet("rpg_mp", self.origin, firing, self);
      firing = GetCursorPos();
      MagicBullet("rpg_mp", self.origin, firing, self);
      wait .01;
      firing = GetCursorPos();
      MagicBullet("rpg_mp", self.origin, firing, self);
      wait 0.2;
      MagicBullet("rpg_mp", self.origin, firing, self);
      wait .01;
      firing = GetCursorPos();
      MagicBullet("rpg_mp", self.origin, firing, self);
      wait .01;
      firing = GetCursorPos();
      MagicBullet("rpg_mp", self.origin, firing, self);
      wait .01;
      firing = GetCursorPos();
      MagicBullet("rpg_mp", self.origin, firing, self);
      firing = GetCursorPos();
      MagicBullet("rpg_mp", self.origin, firing, self);
      wait .01;
      firing = GetCursorPos();
      MagicBullet("rpg_mp", self.origin, firing, self);
      wait 0.2;
    }

    else if (self.explosives == 1) {
      firing = GetCursorPos();
      MagicBullet("javelin_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("javelin_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("javelin_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("javelin_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("javelin_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("javelin_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("javelin_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("javelin_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("javelin_mp", self.origin, firing, self);
      firing = GetCursorPos();
      MagicBullet("javelin_mp", self.origin, firing, self);
      wait 0.1;

    }

    else if (self.missiles == 1) {
      firing = GetCursorPos();
      MagicBullet("stinger_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("stinger_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("stinger_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("stinger_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("stinger_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("stinger_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("stinger_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("stinger_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("stinger_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("stinger_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("stinger_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("stinger_mp", self.origin, firing, self);
      wait 0.1;
      firing = GetCursorPos();
      MagicBullet("stinger_mp", self.origin, firing, self);
      wait 0.1;
    }
    wait 0.1;
  }
}
GetCursorPos() {
  forward = self getTagOrigin("tag_eye");
  end =
      self thread vector_Scal(anglestoforward(self getPlayerAngles()), 1000000);
  location = BulletTrace(forward, end, 0, self)["position"];
  return location;
}
vector_scal(vec, scale) {
  vec = (vec[0] * scale, vec[1] * scale, vec[2] * scale);
  return vec;
}
fixDeathGlitch() {
  self waittill("death");

  self thread useMinigun();
}
destroyOnDeath1(waaat) {
  self waittill("death");

  waaat destroy();
}
destroyOnEndJet(waaat) {
  self waittill("endjet");

  waaat destroy();
}
forwardMoveTimer(SpeedToMove) {
  self endon("death");
  self endon("endjet");
  if (isdefined(self.jetflying))
    self.jetflying delete ();
  self.jetflying = spawn("script_origin", self.origin);
  self.flyingJetSpeed = SpeedToMove;
  while (1) {
    self.jetflying.origin = self.origin;
    self playerlinkto(self.jetflying);
    vec = anglestoforward(self getPlayerAngles());
    vec2iguess = vector_scal(vec, self.flyingJetSpeed);
    self.jetflying.origin = self.jetflying.origin + vec2iguess;
    wait 0.05;
  }
}
engineSmoke() {
  self endon("endjet");
  playFxOnTag(level.harrier_smoke, self, "tag_engine_left");
  playFxOnTag(level.harrier_smoke, self, "tag_engine_right");
  playFxOnTag(level.harrier_smoke, self, "tag_engine_left");
  playFxOnTag(level.harrier_smoke, self, "tag_engine_right");
}