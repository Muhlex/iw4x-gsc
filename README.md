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
1. `git clone` this repository or [download the source as a .zip file](https://github.com/Muhlex/iw4x-gsc/archive/refs/heads/main.zip)
and extract it.<br>
2. Drop the mods from the `scripts` folder into `<IW4X>/userraw/scripts`.
3. All mods are disabled by default. Refer to their respective documentation to enable them.

It is possible to only include some scripts if you know what you are doing.
However some scripts may rely on the presence of others (especially `_` prefixed ones) to work correctly.

## 🗯️ Chat Command System

<img align="right" width="50%" src="https://user-images.githubusercontent.com/21311428/167745720-2d0f947a-a9c4-4de3-8e79-bfc686055e31.png" alt="Command demo">

> Chat-based commands for administrators and players.

Commands are accessible only if a player's permission level matches or exceeds the one required for the command.
The required permission level per command can be edited inside of `commands.gsc`.
The permission level is set per-player using the [`scr_permissions`](#scr_permissions) dvar.
<br clear="both">

### List of available commands
| **Command**     | Aliases     | Arguments                         | Description                              | Permission<br>Level |
|:----------------|:------------|:----------------------------------|:-----------------------------------------|--------------------:|
| **help**        | ? commands  | [page]                            | Display available commands               | 0                   |
| **info**        | i contact   |                                   | Display server info                      | 0                   |
| **report**      | r           | <name> [reason]                   | Report a player                          | 0                   |
| **<a name="items">items</a>**||                                   | Print items for use with other commands  | 10                  |
| **suicide**     | sc          |                                   | Kill yourself                            | 20                  |
| **fastrestart** | restart fr  |                                   | Restart the map                          | 40                  |
| **maprestart**  | mr          |                                   | Reload and restart the map               | 40                  |
| **map**         |             | <mapname>                         | Change the current map                   | 40                  |
| **kill**        |             | <name>                            | Kill a specified player                  | 50                  |
| **give**        |             | [name] <item>                     | Give an item to a player                 | 50                  |
| **take**        |             | [name] <item>                     | Take an item from a player               | 50                  |
| **teleport**    | tp          | [name] [name]                     | Teleport to players or a location        | 50                  |
| **up**          |             | [name]                            | Teleport upwards                         | 50                  |
| **down**        | dn          | [name]                            | Teleport downwards                       | 50                  |
| **velocity**    | jump j      | [name] <z \| forwards z \| x y z> | Set a player's velocity                  | 50                  |
| **freelook**    | fly         | [name]                            | Temporary freelook spectating            | 50                  |
| **spectate**    | spec spy    | <name>                            | Quietly spectate target                  | 50                  |
| **esp**         | wallhack wh | [name]                            | Show players through walls               | 50                  |
| **vision**      | vis         | [visionfile]                      | Set or reset a player's vision           | 50                  |
| **spawnbot**    | sb          |                                   | Spawn a number of bots                   | 70                  |
| **kick**        |             | <name> [reason]                   | Kick a client from the server            | 80                  |
| **ban**         |             | <name> [reason]                   | Permanently ban a client from the server | 90                  |
| **dvar**        |             | <dvar> [value]                    | Get or set a dvar value                  | 100                 |
| **rcon**        |             | <command>                         | Execute rcon command                     | 100                 |
| **quit**        |             |                                   | Close the server                         | 100                 |

### Related DVars
| **DVar**                                          | Default Value        | Description                                                                                                                      |
|:--------------------------------------------------|---------------------:|:---------------------------------------------------------------------------------------------------------------------------------|
| **<a name="scr_permissions">scr_permissions</a>** | `""`                 | Space seperated list of GUIDs followed by a permission level.<br>Example: `"a0b1c2d3e4f5g6h7 100 b1c2d3e4f5g6h7i8 50"`           |
| **scr_commands_enable**                           | `0`                  | Enable the chat command system.                                                                                                  |
| **scr_commands_set_client_dvars_chat**            | `0`                  | When enabled will set clientside dvars to show chat positioned better and for longer than the default.                           |
| **scr_commands_prefix**                           | `"!"`                | Prefix used to trigger commands.                                                                                                 |
| **scr_commands_info**                             | `getDvar("sv_motd")` | String to display when the `info` command is used.                                                                               |
| **scr_commands_report_webhook_url**               | `""`                 | Discord Webhook URL to send reports to. <a href="#http-proxy">⚠ Requires a proxy server to send outgoing HTTP POST requests.</a> |
| **scr_commands_report_cooldown**                  | `20`                 | Time in seconds that must pass between a player's report attempts.                                                               |
| **scr_commands_report_chat_log_max_age**          | `300`                | Maximum age of chat messages in seconds that are appended to a report at the time of reporting.                                  |


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

With the Free-for-all variant known as the Sharpshooter gamemode in later CoD games,
the Randomizer script can be used to add random class loadouts to any gamemode.
Random loadouts are determined at the beginning of a round and can be rerolled on a timer.
Loadouts can either be synced for everyone or be different per team, per player or per life.
A white-/blacklist system allows precise configuration of the available items.

<br clear="both">

### Related DVars
| **DVar**                                   | Default Value | Description                                                                                                                                                                                                                                                                                                      |
|:-------------------------------------------|----------------------------------------------------------------------------------------------------------:|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **scr_randomizer_enable**                  | `0`                                                                                                       | Enable randomizer mode.                                                                                                                                                                                              |
| **scr_randomizer_mode**                    | `0`                                                                                                       | Mode of loadout synchronization:<br>`0`: Same loadout for everyone.<br>`1`: Same loadout for all players of a team.<br>`2`: Different loadouts for everyone.<br>`3`: Different loadouts for everyone for every life. |
| **scr_randomizer_interval**                | `0`                                                                                                       | Time interval (in seconds) in which loadouts are re-randomized. `0` to disable.                                                                                                                                      |
| **scr_randomizer_next_preview_time**       | `5.0`                                                                                                     | Time to show a preview for the upcoming loadout (see image above). Used in combination with `scr_randomizer_interval`.                                                                                               |
| **scr_randomizer_weapon_count**            | `1`                                                                                                       | Amount of weapons to give per loadout.                                                                                                                                                                               |
| **scr_randomizer_attachment_count**        | `-1`                                                                                                      | Amount of attachments to add to weapons (if applicable). `-1` for a random amount.                                                                                                                                   |
| **scr_randomizer_perk_ignore_tiers**       | `0`                                                                                                       | Ignore perk tiers (red - 1, blue - 2, yellow - 3). Will mix tiers when enabled. Otherwise rolls `scr_randomizer_perk_count` of *each* tier.                                                                          |
| **scr_randomizer_perk_ignore_hierarchy**   | `0`                                                                                                       | Ignore "Pro" and base perk relationships. The upgrade ("Pro" effect) of a perk will be considered a standalone perk, just as the base effect is.                                                                     |
| **scr_randomizer_perk_count**              | `1`                                                                                                       | Amount of perks to give per loadout. If `scr_randomizer_perk_ignore_tiers` is disabled, this is the amount of perks *per tier*, otherwise *in total*.                                                                |
| **scr_randomizer_perk_upgrade_mode**       | `1`                                                                                                       | Mode of giving perk upgrades:<br>`0`: No upgrades.<br>`1`: Always upgrade.<br>`2`: Upgrade if player has the pro variant unlocked.<br>Not applicable when `scr_randomizer_perk_ignore_hierarchy` is enabled.         |
| **scr_randomizer_deathstreak_death_count** | `-1`                                                                                                      | Amount of consecutive deaths required to activate deathstreaks. `-1` for their usual amount.                                                                                                                         |
| ℹ                                          |                                                                                                           | *Use the <a href="#items">`items`</a> command for a list of internal item names used by the following settings. Use `"none"` as a value for a whitelist to not allow any item of that category.*                     |
| **scr_randomizer_blacklist_weapon**        | Refer to [^scr_randomizer_blacklist_weapon]                                                               | Space-separated list of weapons not allowed.                                                                                                                                                                         |
| **scr_randomizer_blacklist_attachment**    | `""`                                                                                                      | Space-separated list of attachments not allowed.                                                                                                                                                                     |
| **scr_randomizer_blacklist_camo**          | `""`                                                                                                      | Space-separated list of camos not allowed.                                                                                                                                                                           |
| **scr_randomizer_blacklist_equipment**     | `""`                                                                                                      | Space-separated list of equipment not allowed.                                                                                                                                                                       |
| **scr_randomizer_blacklist_offhand**       | `""`                                                                                                      | Space-separated list of offhand items not allowed.                                                                                                                                                                   |
| **scr_randomizer_blacklist_perk**          | Refer to [^scr_randomizer_blacklist_perk]                                                                 | Space-separated list of perks not allowed.                                                                                                                                                                           |
| **scr_randomizer_blacklist_deathstreak**   | `"specialty_copycat"`                                                                                     | Space-separated list of deathstreaks not allowed.                                                                                                                                                                    |
| **scr_randomizer_whitelist_weapon**        | `""`                                                                                                      | Space-separated list of allowed weapons.                                                                                                                                                                             |
| **scr_randomizer_whitelist_attachment**    | `""`                                                                                                      | Space-separated list of allowed attachments.                                                                                                                                                                         |
| **scr_randomizer_whitelist_camo**          | `""`                                                                                                      | Space-separated list of allowed camos.                                                                                                                                                                               |
| **scr_randomizer_whitelist_equipment**     | `""`                                                                                                      | Space-separated list of allowed equipment.                                                                                                                                                                           |
| **scr_randomizer_whitelist_offhand**       | `""`                                                                                                      | Space-separated list of allowed offhand items.                                                                                                                                                                       |
| **scr_randomizer_whitelist_perk**          | `""`                                                                                                      | Space-separated list of allowed perks.                                                                                                                                                                               |
| **scr_randomizer_whitelist_deathstreak**   | `""`                                                                                                      | Space-separated list of allowed deathstreaks.                                                                                                                                                                        |

[^scr_randomizer_blacklist_weapon]: `scr_randomizer_blacklist_weapon` default value:<br>`"onemanarmy_mp stinger_mp deserteaglegold_mp ak47classic_mp"`
[^scr_randomizer_blacklist_perk]: `scr_randomizer_blacklist_perk` default value:<br>`"specialty_bling specialty_secondarybling specialty_onemanarmy specialty_omaquickcharge"`
## 🟣 Discord Integration

<img align="right" src="https://user-images.githubusercontent.com/21311428/169694154-96812790-a35d-410e-9029-6e37d5189fdc.png" alt="Discord webhook notifications">

> Discord Webhooks for server events.

This script can be used to notify a Discord channel when events happen on a gameserver.
It uses [Discord Webhooks](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks) to allow automated messages without requiring the use of a Discord bot.

Currently support is limited to the features I personally need: Notifications for a player joining and for when the server gets empty.

<a name="http-proxy"></a>

---

⚠ IW4X currently does not support HTTP POST-type requests.
These are required to make outgoing HTTP requests for sending webhooks.
Instead of doing the sensible thing (trying to add POST requests to IW4X)
these scripts include a proxy server to transform GET requests into POST requests.

To use any sort of Discord integration, run `/js/http_proxy.js` using [Node.js](https://nodejs.org/) alongside your gameserver.
Also remember to start IW4X with the `-scriptablehttp` [launch option](https://github.com/XLabsProject/iw4x-client#command-line-arguments)!

---
<br clear="both">

### Related DVars
| **DVar**                     | Default Value | Description                                             |
|:-----------------------------|--------------:|:--------------------------------------------------------|
| **scr_discord_webhook_urls** | `""`          | Space-separated list of Discord Webhook URLs to notify. |
| **scr_discord_join**         | `0`           | Enable notifications on players joining.                |
| **scr_discord_empty**        | `0`           | Enable notifications on the server getting empty.       |

## 🧰 Other Tweaks
### Infinite Ammo
| **DVar**              | Default Value | Description                                                                                                                                                                                              |
|:----------------------|--------------:|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **scr_infinite_ammo** | `0`           | A more flexible version of `player_sustainAmmo`.<br><br>Infinite ammo modes:<br>`0`: Disabled.<br>`1`: Infinite stock & clip ammo, no reloading.<br>`2`: Infinite stock ammo pool. Still need to reload. |

### Offhand Ammo Limit
| **DVar**                 | Default Value | Description                                                                                                                                     |
|:-------------------------|--------------:|:------------------------------------------------------------------------------------------------------------------------------------------------|
| **scr_offhand_max_ammo** | `-1`          | Limit equipment/special grenade ammo. `-1` to disable. Use `0` to ban any equipment/special grenade; `1` to limit special grenades to only one. |

### Force UAV (fixed)
| **DVar**              | Default Value | Description                                                                                                                                   |
|:----------------------|--------------:|:----------------------------------------------------------------------------------------------------------------------------------------------|
| **scr_fix_forceuav**  | `0`           | Enable this fix for the built-in `scr_game_forceuav` which does (almost) nothing by default.                                                  |
| **scr_game_forceuav** | `0`           | Radar modes:<br>`0`: Disabled.<br>`1`: Sweeping radar (1 UAV killstreak always active).<br>`2`: Constant radar (perfectly accurate red dots). |

### Force-set Killstreaks & Perkstreaks
| **DVar**                   | Default Value | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
|:---------------------------|--------------:|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **scr_forced_killstreaks** | `""`          | Force-set every player's equipped killstreak rewards. Takes a space-separated list of killcounts and the according reward. Example:<br>`"2 predator_missile 4 helicopter 8 ac130 20 nuke"`<br><br>Available killstreak rewards:<br>`uav`<br>`counter_uav`<br>`airdrop`<br>`airdrop_sentry_minigun`<br>`sentry`<br>`predator_missile`<br>`precision_airstrike`<br>`harrier_airstrike`<br>`helicopter`<br>`airdrop_mega`<br>`helicopter_flares`<br>`stealth_airstrike`<br>`helicopter_minigun`<br>`ac130`<br>`emp`<br>`nuke` |
| **scr_perkstreaks**        | `""`          | Award players with perks for killstreaks. Takes a space-separated list of killcounts and the according reward. Perk upgrades ("Pro"-Perks) must be explicitly listed. Example:<br>`"2 specialty_fastreload 2 specialty_quickdraw 3 specialty_heartbreaker 3 specialty_quieter"`                                                                                                                                                                                                                                            |

### Status Messages
| **DVar**                | Default Value | Description                                                                           |
|:------------------------|--------------:|:--------------------------------------------------------------------------------------|
| **scr_message_welcome** | `""`          | Chat message to print to players after connecting to the server and spawning.         |
| **scr_message_join**    | `""`          | Chat message to print to all other players when a player connects to the server.      |
| **scr_message_leave**   | `""`          | Chat message to print to all other players when a player disconnects from the server. |

Use `%` inside of a message to start a new line.

The following strings will be replaced with dynamic values when used inside a message:

| Identifier            | Resulting Value                               |
|:----------------------|:----------------------------------------------|
| `{NAME}`              | Name of the player.                           |
| `{NAME_NOCOLORS}`     | Name of the player without colors.            |
| `{HOSTNAME}`          | Server name as it appears in the server list. |
| `{HOSTNAME_NOCOLORS}` | Server name without colors.                   |

### Re-show Perk Display
| **DVar**                         | Default Value | Description                                                             |
|:---------------------------------|--------------:|:------------------------------------------------------------------------|
| **scr_scoreboard_reshows_perks** | `0`           | Re-show the equipped perk display every time the scoreboard was opened. |

### Disable Weapon Drops
| **DVar**                  | Default Value | Description                                     |
|:--------------------------|--------------:|:------------------------------------------------|
| **scr_death_drop_weapon** | `1`           | Prevents weapon drops on death when set to `0`. |

### Disable changing Classes
| **DVar**                  | Default Value | Description                                                                                                        |
|:--------------------------|--------------:|:-------------------------------------------------------------------------------------------------------------------|
| **scr_allow_classchange** | `1`           | Due to the in-built `ui_allow_classchange` not working, this can be used to prevent players from changing classes. |

### Eyecandy
| **DVar**                       | Default Value | Description                                                           |
|:-------------------------------|--------------:|:----------------------------------------------------------------------|
| **scr_spawn_open_eyes_effect** | `0`           | Players appear to open their eyes when spawning in.                   |
| **scr_game_end_slowmo_effect** | `0`           | Adds a match-wide slow motion effect to the action that wins a round. |
