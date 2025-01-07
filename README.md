# moodlesinlua
Moodles In Lua is a mod for Project Zomboid that changes the way moodles works, it disables the rendering of the vanilla system and draws a new one with a more friendly API for modifying textures, as well as some new features and bug fixes

TODO:
- Oscillations
  - MF support / it now uses textures from MoodlesInLua, but still needs to update textures when :apply
- Stack positioning 
- Moodles texture hot swap?

MIL 7 version hierarchy:
```
MoodlesInLua/
├── Contents
│   └── mods
│       └── MoodlesInLua
│           ├── 42
│           │   ├── media
│           │   │   └── lua
│           │   │       └── client
│           │   │           └── MoodlesIn.lua
│           │   ├── mod.info
│           │   ├── moodlesicon.png
│           │   └── poster.png
│           └── common
├── preview.png
└── workshop.txt

9 directories, 6 files
```
