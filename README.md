# moodlesinlua
Moodles In Lua is a mod for Project Zomboid that changes the way moodles works, it disables the rendering of the vanilla system and draws a new one with a more friendly API for modifying textures, as well as some new features and bug fixes

TODO:
- Fix a bug for wiggle effect when they multiply Oscilator if they are started at the same time
- Stack positioning 
- Moodles texture hot swap?
- more MF support
- auto detect custom width height and scale them properly 

MIL 7 version hierarchy:
```
MoodlesInLua/
├── Contents
│   └── mods
│       └── MoodlesInLua
│           ├── 42
│           │   ├── media
│           │   │   ├── lua
│           │   │   │   └── client
│           │   │   │       └── MoodlesIn.lua
│           │   │   └── ui
│           │   │       └── MIL
│           │   │           └── Default
│           │   │               ├── bad_1.png
│           │   │               ├── bad_2.png
│           │   │               ├── bad_3.png
│           │   │               ├── bad_4.png
│           │   │               ├── good_1.png
│           │   │               ├── good_2.png
│           │   │               ├── good_3.png
│           │   │               └── good_4.png
│           │   ├── mod.info
│           │   ├── moodlesicon.png
│           │   └── poster.png
│           └── common
├── preview.png
└── workshop.txt

12 directories, 14 files
```
