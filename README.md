This repository has been archived as the underlying issue for OF has been fixed.

-------------------

# Open Fortress Teleporter Velocity Fix

This is a sourcemod plugin that fixes a bug affecting Open Fortress linux servers that stops your velocity when exiting a teleporter.

The bug this works around: https://github.com/openfortress/public-issue-tracker/issues/74

## Compatible Games
- Open Fortress

## Supported Platforms
- Linux

## Installation
Copy the `plugins` directory to your `<game>/addons/sourcemod` directory.

## CVars

`sm_teleporter_velocity_fix 0/1 (def. 1)` - Toggles the plugin's effect on or off.

## How It Works
When a player touches the trigger for a teleporter, their current velocity is saved by the plugin. As soon as they stop touching the trigger (ie. the teleport occurs), their velocity is set to what it was when they entered.

## Credits
- Fraeven - Code, Testing
- Rowedahelicon - Code
