#include scripts\_utility;

cmdself(args, prefix, cmd) { cmd(args, prefix, cmd); }

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
  if (!isDefined(target.commands)) {
    target.commands = spawnstruct();
  }
  if (!isDefined(target.commands.god)) {
    target.commands.god = false;
  }

  if (target.commands.god) {
    target.commands.god = false;
    self notify("end_god");
    self respond("^2" + target.name + " ^7no longer has godmode");
  } else {
    target.commands.god = true;
    target thread doGod();
    self respond("^2" + target.name + " ^7has now godmode");
  }
}

doGod() {
  self endon("disconnect");
  self endon("death");
  self endon("end_god");
  self.maxhealth = 90000;
  self.health = self.maxhealth;
  while (1) {
    wait .4;
    if (self.health < self.maxhealth)
      self.health = self.maxhealth;
  }
}