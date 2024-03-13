#include scripts\_utility;

cmd(args, prefix, cmd) {
  self thread Bouncetramp();
  self beginLocationselection("map_artillery_selector", true,
                              (level.mapSize / 5.625));
  self.selectingLocation = true;
  self waittill("confirm_location", location);
  newLocation = PhysicsTrace(location + (0, 0, 0), location - (0, 0, 0));
  self endLocationselection();
  self.selectingLocation = undefined;
  iPrintln("Trampoline spawned");
  level.tramp = [];
  trampNum = 0;
  for (x = 1; x <= 7; x++) {
    for (y = 1; y <= 14; y++) {
      level.tramp[trampNum] = spawn(
          "script_model",
          newLocation + (0 + (x * 58), 0 + (y * 28), 44.5));
      level.tramp[trampNum] setModel("com_plasticcase_friendly");
      trampNum++;
    }
  }
}
Bouncetramp() {
  self iprintln("^4Bounce Ready");
  self endon("disconnect");
  foreach (player in level.players) {
    for (;;) {
      foreach (pkg in level.tramp) {
        if (distance(player.origin, pkg.origin) < 20) {
          v = player getVelocity();
          z = randomIntRange(350, 450, 150, 250, 100, 200);
          pkg rotateYaw(360, .05);
          foreach (dbag in level.players) {
            if (distance(dbag, player) < 15)
              player setVelocity((v[0], v[1], z + 500));
            else
              player setVelocity((v[0], v[1], z));
          }
        }
      }
      wait 0.03;
    }
  }
}