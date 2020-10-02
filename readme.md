# Garry's Mod ShowTriggers

This addon allows users to show trigger brushes. It essentially behaves like and bypasses the `showtriggers` cheat console command.

The following features are included on this addon:
- Showing trigger brushes for trigger_teleport, trigger_multiple and trigger_push, each of which can be shown individually.
- A very useful logging system intended to show what the addon is doing. Also has a debugger perfect for mappers to show entity info.
- An entity tracer called DebugTrace that allows clients to view info about an entity they are aiming at.
- Native command support for the Flow Network gamemodes (supports v7.26 and v8.50). Can also be used standalone if not running those gamemodes.

# Installation
Installing is very simple and straightforward. Download the zip file, extract it and move the gmod-showtriggers folder to your addon folder.
The addon will automatically determine if the server is running the Flow Network gamemode or not.

# Configuring
You can configure the addon by editing the `autorun\showtriggers.lua` file. The following options can be changed:
- Enable/Disable the Logger and the debugger
- Change Chat Prefix Colors
- Change Console Message Colors

You can also add maps to the addon filter that prevents the addon from loading. It's useful to add maps that cause crashes or have unintended side-effects. I'll try to keep the list updated as best as I can. If you do find an issue with a map, feel free to create an issue on the repository.
