local MoodlesInConfig = require "MoodlesInConfig"

local function MoodlesInModMenu()

    if not MoodlesInConfig then
        print("MoodlesInConfig.lua not found")
        return nil
    end

    -- Create mod options
    local options = PZAPI.ModOptions:create("moodlesinlua", "Moodles In Lua Configuration")

    -- Tooltip Padding Slider
    MoodlesInConfig.tooltipPadding = options:addSlider(
        "tooltipPadding",                                          -- Option ID
        getText("UI_MoodlesIn_TooltipPadding"),                    -- Display text
        0,                                                         -- Minimum value
        10,                                                        -- Maximum value
        1,                                                         -- Step size
        MoodlesInConfig.tooltipPadding,                            -- Default/current value
        getText("UI_MoodlesIn_TooltipPadding_Tooltip")             -- Tooltip text
    )

    -- Moodles Distance Slider
    MoodlesInConfig.moodlesDistanceBetween = options:addSlider(
        "moodlesDistanceBetween",
        getText("UI_MoodlesIn_MoodlesDistance"),
        0,                                                         -- Minimum value
        100,                                                       -- Maximum value
        1,                                                         -- Step size
        MoodlesInConfig.moodlesDistanceBetween,                    -- Default/current value
        getText("UI_MoodlesIn_MoodlesDistance_Tooltip")            -- Tooltip text
    )

    -- Moodles Extra X Slider
    MoodlesInConfig.moodlesExtraX = options:addSlider(
        "moodlesExtraX",
        getText("UI_MoodlesIn_moodlesExtraX"),
        -1000,                                                     -- Minimum value
        1000,                                                      -- Maximum value
        1,                                                         -- Step size
        MoodlesInConfig.moodlesExtraX,                             -- Default/current value
        getText("UI_MoodlesIn_moodlesExtraX_Tooltip")              -- Tooltip text
    )

    -- Moodles Extra Y Slider
    MoodlesInConfig.moodlesExtraY = options:addSlider(
        "moodlesExtraY",
        getText("UI_MoodlesIn_moodlesExtraY"),
        -1000,                                                     -- Minimum value
        1000,                                                      -- Maximum value
        1,                                                         -- Step size
        MoodlesInConfig.moodlesExtraY,                             -- Default/current value
        getText("UI_MoodlesIn_moodlesExtraY_Tooltip")              -- Tooltip text
    )

    -- Moodles Start Animation ComboBox
    MoodlesInConfig.moodlesAnimationStart = options:addComboBox(
        "moodlesAnimationStart",
        getText("UI_MoodlesIn_moodlesAnimationStart"),             -- Title
        getText("UI_MoodlesIn_moodlesAnimationStart_Tooltip")      -- Tooltip text
    )

    ---- whichever is set to "true" will be the initially selected box.
    --- NOTE: calling getValue on the option will return the number of the entry.
    MoodlesInConfig.moodlesAnimationStart:addItem(getText("UI_MoodlesIn_moodlesAnimationStart_1"), false) -- Disabled
    MoodlesInConfig.moodlesAnimationStart:addItem(getText("UI_MoodlesIn_moodlesAnimationStart_2"), true) -- Slide by y
    MoodlesInConfig.moodlesAnimationStart:addItem(getText("UI_MoodlesIn_moodlesAnimationStart_3"), false) -- Slide by x

    -- Moodles Start Animation ComboBox
    MoodlesInConfig.moodlesPositionStack = options:addComboBox(
        "moodlesPositionStack",
        getText("UI_MoodlesIn_moodlesPositionStack"),             -- Title
        getText("UI_MoodlesIn_moodlesPositionStack_Tooltip")      -- Tooltip text
    )

    ---- whichever is set to "true" will be the initially selected box.
    MoodlesInConfig.moodlesPositionStack:addItem(getText("UI_MoodlesIn_moodlesPositionStack_1"), true) -- Default / vanilla
    MoodlesInConfig.moodlesPositionStack:addItem(getText("UI_MoodlesIn_moodlesPositionStack_2"), false) -- By level if level bigger then higher in stack
    MoodlesInConfig.moodlesPositionStack:addItem(getText("UI_MoodlesIn_moodlesPositionStack_3"), false) -- By level if level lower then higher in stack

    -- Apply function to update options
    local function applyOptions()
        local options = PZAPI.ModOptions:getOptions("moodlesinlua")

        -- Update config values
        MoodlesInConfig.moodlesDistanceBetween = options:getOption("moodlesDistanceBetween"):getValue()
        MoodlesInConfig.tooltipPadding = options:getOption("tooltipPadding"):getValue()
        MoodlesInConfig.moodlesExtraX = options:getOption("moodlesExtraX"):getValue()
        MoodlesInConfig.moodlesExtraY = options:getOption("moodlesExtraY"):getValue()
        MoodlesInConfig.moodlesAnimationStart = options:getOption("moodlesAnimationStart"):getValue()
        MoodlesInConfig.moodlesPositionStack = options:getOption("moodlesPositionStack"):getValue()

    end

    -- Set apply method
    options.apply = applyOptions  -- Just assign the function, don't call it

    -- Add to main menu enter event
    Events.OnMainMenuEnter.Add(applyOptions)
    Events.OnGameStart.Add(applyOptions)

    return options
end

-- Initialize mod menu
local moodlesOptions = MoodlesInModMenu()

return MoodlesInConfig
