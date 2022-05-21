# IW4X GSC Scripts
A collection of small-ish GSC only mods that work in a self-contained manner.
These **do not modify base game files**, which makes them modular and compatible with some other mods.

These scripts are built for **[IW4X](https://github.com/XLabsProject/iw4x-client)** and may use engine functions that do not
exist on other clients.

## 🗺️ Quick Navigation
<p align="center">
	<b>
		<a href="#%EF%B8%8F-chat-command-system">🗯️&#8239;Commands</a>
		•
		<a href="#-advanced-map-rotation">🔄&#8239;Advanced Map-Rotation</a>
		•
		<a href="#-incendiary-grenade">🔥&#8239;Incendiary</a>
		•
		<a href="#-randomizer-mode">🎲&#8239;Randomizer</a>
		•
		<a href="#-discord-integration">🟣&#8239;Discord</a>
		•
		<a href="#-other-tweaks">🧰&#8239;Tweaks</a>
	</b>
</p>

## 📦 Installation
Drop the mods from the `scripts` folder into `<IW4X>/userraw/scripts`.

It is possible to only include some scripts if you know what you are doing.
However some scripts may rely on the presence of others (especially `_` prefixed ones) to work correctly.

All mods are disabled by default. Refer to their respective documentation to enable them.

## 🗯️ Chat Command System

<img align="right" width="50%" src="https://user-images.githubusercontent.com/21311428/167745720-2d0f947a-a9c4-4de3-8e79-bfc686055e31.png" alt="Command demo">

> Chat-based commands for administrators and players.

Commands are accessible only if a player's permission level matches or exceeds the one required for the command.
The required permission level per command can be edited inside of `commands.gsc`.
The permission level is set per-player using the [`scr_permissions`](#scr_permissions) dvar.
<br clear="both">

### List of available commands
| **Command**     | Aliases     | Arguments                         | Description                              | Permission<br>Level |
|:----------------|:------------|:----------------------------------|:-----------------------------------------|-----:|
| **help**        | ? commands  | [page]                            | Display available commands               | 0    |
| **info**        | i contact   |                                   | Display server info                      | 0    |
| **report**      | r           | <name> [reason]                   | Report a player                          | 0    |
| **items**       |             |                                   | Print items for use with other commands  | 10   |
| **suicide**     | sc          |                                   | Kill yourself                            | 20   |
| **fastrestart** | restart fr  |                                   | Restart the map                          | 40   |
| **maprestart**  | mr          |                                   | Reload and restart the map               | 40   |
| **map**         |             | <mapname>                         | Change the current map                   | 40   |
| **kill**        |             | <name>                            | Kill a specified player                  | 50   |
| **give**        |             | [name] <item>                     | Give an item to a player                 | 50   |
| **take**        |             | [name] <item>                     | Take an item from a player               | 50   |
| **teleport**    | tp          | [name] [name]                     | Teleport to players or a location        | 50   |
| **up**          |             | [name]                            | Teleport upwards                         | 50   |
| **down**        | dn          | [name]                            | Teleport downwards                       | 50   |
| **velocity**    | jump j      | [name] <z \| forwards z \| x y z> | Set a player's velocity                  | 50   |
| **freelook**    | fly         | [name]                            | Temporary freelook spectating            | 50   |
| **spectate**    | spec spy    | <name>                            | Quietly spectate target                  | 50   |
| **esp**         | wallhack wh | [name]                            | Show players through walls               | 50   |
| **vision**      | vis         | [visionfile]                      | Set or reset a player's vision           | 50   |
| **spawnbot**    | sb          |                                   | Spawn a number of bots                   | 70   |
| **kick**        |             | <name> [reason]                   | Kick a client from the server            | 80   |
| **ban**         |             | <name> [reason]                   | Permanently ban a client from the server | 90   |
| **dvar**        |             | <dvar> [value]                    | Get or set a dvar value                  | 100  |
| **rcon**        |             | <command>                         | Execute rcon command                     | 100  |
| **quit**        |             |                                   | Close the server                         | 100  |

### Related DVars
| **DVar**                                          | Default Value        | Description                                                                                                            |
|:--------------------------------------------------|---------------------:|:-----------------------------------------------------------------------------------------------------------------------|
| **<a name="scr_permissions">scr_permissions</a>** | `""`                 | Space seperated list of GUIDs followed by a permission level.<br>Example: `"a0b1c2d3e4f5g6h7 100 b1c2d3e4f5g6h7i8 50"` |
| **scr_commands_enable**                           | `0`                  | Enable the chat command system.                                                                  |
| **scr_commands_set_client_dvars_chat**            | `0`                  | When enabled will set clientside dvars to show chat positioned better and for longer than the default.                 |
| **scr_commands_prefix**                           | `"!"`                | Prefix used to trigger commands.                                                                                       |
| **scr_commands_info**                             | `getDvar("sv_motd")` | String to display when the `info` command is used.                                                                     |
| **scr_commands_report_webhook_url**               | `""`                 | Discord Webhook URL to send reports to.                                                                                |
| **scr_commands_report_cooldown**                  | `20`                 | Time in seconds that must pass between a player's report attempts.                                                     |
| **scr_commands_report_chat_log_max_age**          | `300`                | Maximum age of chat messages in seconds that are appended to a report at the time of reporting.                        |


## 🔄 Advanced Map-Rotation
> Smart randomized map rotation based on playercounts.

Usually, `sv_mapRotation` linearly plays the configured maps and gamemodes.
With the addition of `sv_randomMapRotation` in [IW4X 0.7.0](https://github.com/XLabsProject/iw4x-client/releases/tag/v0.7.0)
this can be set to be randomized [(Thanks, @diamante0018!)](https://github.com/XLabsProject/iw4x-client/pull/146).
However this will shuffle all maps every time they have all been played through, enabling potential duplicate maps at the end of a cycle.
Also gamemodes can no longer be set per map, as they will be shuffled in-between the maps randomly.
	
For an overengineered solution to this, as well as the option to only consider maps which fit the amount of connected players,
this script module can be used. It uses weights for defining the likelihood of a map being picked. A map's weight goes up over time
and is reset once the map is picked.
Use `sv_mapRotation` to setup map and gamemode combinations as usual, leave the inbuilt dvar
`sv_randomMapRotation` at `0` and refer to the table of related dvars to set up the advanced features:
	
### Related DVars
| **DVar**                           | Default Value | Description                                                                                                                                                                                                                |
|:-----------------------------------|--------------:|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **scr_nextmap_randomize**          | `0`           | Enable weighted map randomization.                                                                                                                                                                                         |
| **scr_nextmap_playercounts**       | `""`          | Pairs of maps and min-max playercounts. Make sure to define maps for playercounts of 0 to `sv_maxclients`! Only used when `scr_nextmap_randomize` is enabled.<br>Example: `"mp_rust 0-3,mp_boneyard 4-8,mp_terminal 5-10"` |
| **scr_nextmap_map_timeout**        | `1`           | Once a random map is picked, this amount of other maps must be played until the map is considered again. Make sure to always have enough maps in the pool when increasing this.                                            |
| **scr_nextmap_empty_switch_delay** | `20`          | When the server empties and the active map is not configured for 0 players, it will be changed to a map configured for 0 players after this delay (in seconds).                                                            |

## 🔥 Incendiary Grenade
> Special grenade exploding into a pool of fire on impact.

https://user-images.githubusercontent.com/21311428/168055048-c27cc71d-cb77-438a-a27e-bdf66bf115dc.mp4

Useful for clearing out rooms or blocking off chokepoints. Duration and Damage are configurable.
Damage and tagging (slowdown on getting hit) scale with the amount of time the fire pool has been burning, allowing targets to react.
Either dvar `scr_incendiary_replace_offhand` or functions inside of `incendiary.gsc` can be used to give players the grenade.
Fire pools can also be spawned and deleted programatically.

### Related DVars
| **DVar**                           | Default Value | Description                                                                                                                                                                                                                                                                                                                                             |
|:-----------------------------------|--------------:|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **scr_incendiary_duration**        | `6.0`         | Time in seconds the grenade's fire pool persists for.                                                                                                                                                                                                                                                                                                   |
| **scr_incendiary_radius**          | `176.0`       | Radius of the grenade's fire pool in inches (in-game units).                                                                                                                                                                                                                                                                                            |
| **scr_incendiary_damage**          | `50`          | Base damage of the grenade's fire. Exact damage is calculated as follows:<br>`int(min(fireAliveSeconds / 6.0 + 0.4, 1) * (1 - min(distanceTargetFire / scr_incendiary_radius * 2, 1)) * scr_incendiary_damage)`                                                                                                                                         |
| **scr_incendiary_flame_radius**    | `72`          | Radius (X, Y) of a single flame's damage trigger cylinder. You should not have to change this.                                                                                                                                                                                                                                                          |
| **scr_incendiary_flame_height**    | `96`          | Height (Z) of a single flame's damage trigger cylinder. You should not have to change this.                                                                                                                                                                                                                                                             |
| **scr_incendiary_replace_offhand** | `""`          | Space seperated list of special grenades to get replaced by the incendiary grenade. This allows the grenade to be used without any other mod by replacing player's loadouts at the cost of removing a grenade from the base game.<br>Example (causes Stun and Smoke Grenade to be replaced with Incendiary): `"concussion_grenade_mp smoke_grenade_mp"` |

## 🎲 Randomizer Mode

<img align="right" width="50%" src="https://user-images.githubusercontent.com/21311428/169546431-9ab040fd-d4d0-4b9e-9585-e039821d124e.png" alt="Randomizer next loadout notification">

> Widely configurable random loadouts.

Known as the Sharpshooter gamemode in later CoD games, the Randomizer script can be used to add random class loadouts to any gamemode.
Random loadouts are determined at the beginning of a round and can be rerolled on a timer.
Loadouts can either be synced for everyone or be different per team, per player or per life.
A white-/blacklist system allows precise configuration of the available items.

<br clear="both">

### Related DVars
| **DVar**                                   | Default Value | Description                                                                                                                                                                                                          |
|:-------------------------------------------|--------------:|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **scr_randomizer_enable**                  | `0`           | Enable randomizer mode.                                                                                                                                                                                              |
| **scr_randomizer_mode**                    | `0`           | Mode of loadout synchronization:<br>`0`: Same loadout for everyone.<br>`1`: Same loadout for all players of a team.<br>`2`: Different loadouts for everyone.<br>`3`: Different loadouts for everyone for every life. |
| **scr_randomizer_interval**                | `0`           | Time interval (in seconds) in which loadouts are re-randomized. `0` to disable.                                                                                                                                      |
| **scr_randomizer_next_preview_time**       | `5.0`         | Time to show a preview for the upcoming loadout (see image above). Used in combination with `scr_randomizer_interval`.                                                                                               |
| **scr_randomizer_weapon_count**            | `1`           | Amount of weapons to give per loadout.                                                                                                                                                                               |
| **scr_randomizer_attachment_count**        | `-1`          | Amount of attachments to add to weapons (if applicable). `-1` for a random amount.                                                                                                                                   |
| **scr_randomizer_perk_ignore_tiers**       | `0`           | Ignore perk tiers (red - 1, blue - 2, yellow - 3). Will mix tiers when enabled. Otherwise rolls `scr_randomizer_perk_count` of *each* tier.                                                                          |
| **scr_randomizer_perk_ignore_hierarchy**   | `0`           | Ignore "Pro" and base perk relationships. The upgrade ("Pro" effect) of a perk will be considered a standalone perk, just as the base effect is.                                                                     |
| **scr_randomizer_perk_count**              | `1`           | Amount of perks to give per loadout. If `scr_randomizer_perk_ignore_tiers` is disabled, this is the amount of perks *per tier*, otherwise *in total*.                                                                |
| **scr_randomizer_perk_upgrade_mode**       | `1`           | Mode of giving perk upgrades:<br>`0`: No upgrades.<br>`1`: Always upgrade.<br>`2`: Upgrade if player has the pro variant unlocked.<br>Not applicable when `scr_randomizer_perk_ignore_hierarchy` is enabled.         |
| **scr_randomizer_deathstreak_death_count** | `-1`          | Amount of consecutive deaths required to activate deathstreaks. `-1` for their usual amount.                                                                                                                         |
TODO: Black/Whitelists

## 🟣 Discord Integration
## 🧰 Other Tweaks
### Infinite Ammo
### Offhand (Grenade) Limits
### Force-set Killstreaks & Perkstreaks
### Status Messages
### Perks on Scoreboard
### Disable Weapon Drops
### Eyecandy
