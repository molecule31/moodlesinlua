# moodlesinlua
Moodles In Lua is a mod for Project Zomboid that changes the way moodles works, it disables the rendering of the vanilla system and draws a new one with a more friendly API for modifying textures, as well as some new features and bug fixes

### TODO:
- Stack positioning 
- Moodles texture hot swap?
- Advanced MF support

### Exposed options:
- ```offsetX``` Adjusts the horizontal position (X-axis offset)<br>
- ```offsetY``` Adjusts the vertical position (Y-axis offset)<br>
- ```moodleOffsetX``` Adjusts the horizontal position of the moodle (X-axis offset)<br>
- ```moodleOffsetY``` Adjusts the vertical position of the moodle (Y-axis offset)<br>
- ```moodleAlpha``` Controls the overall opacity of the moodles (Alpha transparency level)<br>
- ```moodlesDistance``` Sets the space between moodles<br>
- ```tooltipPadding``` Defines the padding inside the tooltip for spacing around the text<br>
- ```tooltipXOffset```  Can be used to add a larger gap between the tooltip and moodle<br>

## MIL 7 version hierarchy:
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
