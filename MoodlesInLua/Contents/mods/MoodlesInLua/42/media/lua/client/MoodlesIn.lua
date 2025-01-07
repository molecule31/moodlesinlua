ISMoodlesInLua = ISUIElement:derive("ISMoodlesInLua")

function ISMoodlesInLua:new()
    local o = ISUIElement:new(x, y, moodleSize, moodleSize)
    setmetatable(o, self)
    self.__index = self

    o.defaultMoodleSize = 48
    o.moodleSizes = {[1] = 32,[2] = 48,[3] = 64,[4] = 80,[5] = 96,[6] = 128}

    o.moodlePaths = {
        ["Endurance"] = "media/ui/Moodles/Status_DifficultyBreathing.png",
        ["Bleeding"] = "media/ui/Moodles/Status_Bleeding.png",
        ["Angry"] = "media/ui/Moodles/Mood_Angry.png",
        ["Stress"] = "media/ui/Moodles/Mood_Stressed.png",
        ["Thirst"] = "media/ui/Moodles/Status_Thirst.png",
        ["Panic"] = "media/ui/Moodles/Mood_Panicked.png",
        ["Hungry"] = "media/ui/Moodles/Status_Hunger.png",
        ["Injured"] = "media/ui/Moodles/Status_InjuredMinor.png",
        ["Pain"] = "media/ui/Moodles/Mood_Pained.png",
        ["Sick"] = "media/ui/Moodles/Mood_Nauseous.png",
        ["Bored"] = "media/ui/Moodles/Mood_Bored.png",
        ["Unhappy"] = "media/ui/Moodles/Mood_Sad.png",
        ["Tired"] = "media/ui/Moodles/Mood_Sleepy.png",
        ["HeavyLoad"] = "media/ui/Moodles/Status_HeavyLoad.png",
        ["Drunk"] = "media/ui/Moodles/Mood_Drunk.png",
        ["Wet"] = "media/ui/Moodles/Status_Wet.png",
        ["HasACold"] = "media/ui/Moodles/Mood_Ill.png",
        ["Dead"] = "media/ui/Moodles/Mood_Dead.png",
        ["Zombie"] = "media/ui/Moodles/Mood_Zombified.png",
        ["Windchill"] = "media/ui/Moodles/Status_Windchill.png",
        ["CantSprint"] = "media/ui/Moodles/Status_MovementRestricted.png",
        ["Uncomfortable"] = "media/ui/Moodles/Mood_Discomfort.png",
        ["NoxiousSmell"] = "media/ui/Moodles/Mood_NoxiousSmell.png",
        ["FoodEaten"] = "media/ui/Moodles/Status_Hunger.png",
        ["Hyperthermia"] = "media/ui/Moodles/Status_TemperatureHot.png",
        ["Hypothermia"] = "media/ui/Moodles/Status_TemperatureLow.png"
    }

    o.moodlesDistance = 10
    o.tooltipPadding = 1

    o.tooltipXOffset = 5 -- Can be used to add a larger gap between the tooltip and moodle.

    o.moodleAlpha = 1.0

    o.previousMoodleLevels = {}
    o.moodleAnimations = {}

    o.useCharacter = nil
    o.active = false

    o.textureSets = {}
    o.textureCache = {}
    return o
end

function ISMoodlesInLua:start()
    self.active = true
end
function ISMoodlesInLua:stop()
    self.active = false
end

function ISMoodlesInLua:setCharacter(character)
    self.useCharacter = character
end

function ISMoodlesInLua:registerTextureSet(name, path)
    -- Error Handling: Ensure texture set contains name and path
    if not name or not path then
        error("MIL [registerTextureSet]: ERROR - Texture set registration requires both a name and a path.")
        return
    end

    -- Error Handling: Prevent duplicate entries
    for _, set in ipairs(self.textureSets) do
        if set.name == name then
            print("MIL [registerTextureSet]: ERROR - Texture set '" .. name .. "' is already registered.")
            return
        end
    end

    -- Cache texture set name and path
    table.insert(self.textureSets, { name = name, path = path })

    -- Add to dropdown menu and options
    local MILModOptions = PZAPI.ModOptions:getOptions("MoodlesInLua")
    local BorderTextureDropdown = MILModOptions and MILModOptions:getOption("MoodleBorderSet")

    if BorderTextureDropdown then
        BorderTextureDropdown:addItem(name, false)
    else
        print("MIL [registerTextureSet]: ERROR - Moodle Background dropdown menu has not been initialized.")
    end

    table.insert(BorderTextureOptions, name)
end


function ISMoodlesInLua:getTexturePath(goodBadNeutralId, moodleLevel)
    local basePath = "media/ui/MIL/Default"

    -- Find the registered texture set
    for _, set in ipairs(self.textureSets) do
        if set.name == self.currentMoodleBorderSet then
            basePath = set.path
            break
        end
    end

    return string.format("%s/%s_%d.png", basePath, goodBadNeutralId == 1 and "Good" or goodBadNeutralId == 2 and "Bad" or "Neutral", moodleLevel)
end

function ISMoodlesInLua:getTexture(path)
    -- Check if the texture is already cached
    if not self.textureCache[path] then
        print("Loading texture: " .. path)
        -- Attempt to load the texture
        local texture = getTexture(path)

        -- Error handling: Check if texture loading was successful
        if texture == nil then
            print("Error: Texture not found for path: " .. path)
            return nil -- Skip drawing if texture is not found
        end

        -- Cache the texture if it's loaded
        self.textureCache[path] = texture
    end

    return self.textureCache[path]
end

function ISMoodlesInLua:clearTextureCache()
    if self.textureCache then
        for path, _ in pairs(self.textureCache) do
            print("Releasing texture: " .. path)
        end
        self.textureCache = {} -- Clear all cached textures
    end
end

function ISMoodlesInLua:getMoodleSize()
    -- Get Preset
    local moodleSize = getCore():getOptionMoodleSize()

     -- Auto size
    if moodleSize == 7 then
        local fontEnum = UIFont.Small
        return getTextManager():getFontFromEnum(fontEnum):getLineHeight()*3
    end

    -- Preset size
    return self.moodleSizes[moodleSize] or self.defaultMoodleSize
end

function ISMoodlesInLua:updateMoodleBorderType(newType)
    self.currentMoodleBorderSet = newType
end

function ISMoodlesInLua:drawMoodleTooltip(moodles, moodleId, moodleX, moodleY)
    local moodleSize = self:getMoodleSize()

    local title = moodles:getMoodleDisplayString(moodleId)
    local description = moodles:getMoodleDescriptionString(moodleId)

    local textPadding = 10
    local titleLength = getTextManager():MeasureStringX(UIFont.Small, title) + textPadding
    local descriptionLength = getTextManager():MeasureStringX(UIFont.Small, description) + textPadding
    local textLength = math.max(titleLength, descriptionLength)

    local titleHeight = getTextManager():MeasureStringY(UIFont.Small, title)
    local descriptionHeight = getTextManager():MeasureStringY(UIFont.Small, description)
    local rectHeight = titleHeight + descriptionHeight + self.tooltipPadding * 4
    --local centerTooltipOnMoodle = (moodleSize > self.defaultMoodleSize) and (moodleSize - rectHeight) / 2 or 0
    local anchorTooltipOnMoodle = math.floor((moodleSize - rectHeight) / 2)
    -- Draw Tooltip Rectangle
    self:drawRect(moodleX - textLength - textPadding - self.tooltipXOffset, moodleY + anchorTooltipOnMoodle, textLength + textPadding, rectHeight, 0.6, 0, 0, 0)
    -- Draw Tooltip Text & Description (not necessary when using moodlesUI:setVisible() state)
    self:drawTextRight(title, moodleX - textPadding - self.tooltipXOffset, moodleY + self.tooltipPadding + anchorTooltipOnMoodle, 1, 1, 1, 1)
    self:drawTextRight(description, moodleX - textPadding - self.tooltipXOffset, moodleY + titleHeight + self.tooltipPadding * 2 + anchorTooltipOnMoodle, 1, 1, 1, 0.7)
end

function ISMoodlesInLua:render()

    local moodlesUI = MoodlesUI.getInstance()

    --Ensures ISMoodlesInLua and MoodlesUI are active
    if not self.active or not moodlesUI then return end

    --Disable Framework Functionality & Use Vanilla Moodle System If "Default" Is Selected
    moodlesUI:setDefaultDraw(self.currentMoodleBorderSet == "Default")
    if self.currentMoodleBorderSet == "Default" then return end

    --Vanilla moodles tooltip still displayed on pause? Anyway, it's a game bug

    local moodleSize = self:getMoodleSize()
    local x, y = moodlesUI:getAbsoluteX(), moodlesUI:getAbsoluteY()

    local player = self.useCharacter
    if player and player:getMoodles() then
        local moodles = player:getMoodles()
        for moodleId = 0, moodles:getNumMoodles() - 1 do
            local moodleType = MoodleType.FromIndex(moodleId)
            local moodleLevel = moodles:getMoodleLevel(moodleType)
            local goodBadNeutralId = moodles:getGoodBadNeutral(moodleId)

            local prevLevel = self.previousMoodleLevels[tostring(moodleType)] or 0
            self.previousMoodleLevels[tostring(moodleType)] = moodleLevel
            local baseY = y -- Save the starting Y for this moodle
            local animY = baseY -- Default to base Y if no animation

            if moodleLevel > 0 --[[and not (moodleType == MoodleType.FoodEaten and moodleLevel < 3)]] then

                --[[ Wiggle Animation?
                if moodleLevel ~= prevLevel and moodleLevel > 1 or prevLevel == 2 and moodleLevel == 1 then

                end
                ]]

                if prevLevel == 0 and moodleLevel == 1 then
                    self.moodleAnimations[tostring(moodleType)] = {
                        progress = 0,
                        startY = baseY,
                        targetY = 10000
                    }
                end

                -- Handle Start animation
                local deltaTime = UIManager.getMillisSinceLastUpdate() / 1000 -- Convert ms to seconds
                local anim = self.moodleAnimations[tostring(moodleType)]
                if anim then
                    -- Update and clamp progress using time since last frame
                    anim.progress = math.min(anim.progress + (deltaTime * 0.5), 1)

                    -- Smooth cubic ease-out interpolation
                    local t = 1 - math.pow(1 - anim.progress, 3)
                    local animY = anim.targetY + (anim.startY - anim.targetY) * t

                    -- Auto-remove and reset animation
                    if anim.progress >= 1 then
                        self.moodleAnimations[tostring(moodleType)] = nil
                        animY = baseY
                    end

                    -- Apply animation to y position
                    y = animY
                end

                -- Draw moodle textures
                local path = self:getTexturePath(goodBadNeutralId, moodleLevel)
                local texture = self:getTexture(path)
                local moodleTexturePath = tostring(moodleType)
                local moodleTexture = self:getTexture(self.moodlePaths[moodleTexturePath])

                if texture then
                    UIManager.DrawTexture(texture, x, y, moodleSize, moodleSize, self.moodleAlpha)
                    UIManager.DrawTexture(moodleTexture, x, y, moodleSize, moodleSize, self.moodleAlpha)
                end

                -- Draw moodle tooltip on mouse hover
                local mouseX, mouseY = getMouseX(), getMouseY()
                if mouseX >= x and mouseX <= x + moodleSize and mouseY >= y and mouseY <= y + moodleSize then
                    self:drawMoodleTooltip(moodles, moodleId, x, y)
                end

                -- Increment position for the next moodle
                y = baseY + self.moodlesDistance + moodleSize
            end
        end
    end
end




--[[HANDLER]]--

ISMoodlesInLuaHandle = ISMoodlesInLua:new()

-- Initialize the framework and add it to the UIManager
local function initializeMIL()
    ISMoodlesInLuaHandle:initialise()
    ISMoodlesInLuaHandle:addToUIManager()
    ISMoodlesInLuaHandle:start()
end
Events.OnGameStart.Add(initializeMIL)

-- Update player character
local function updateCharacter(id,player)
    ISMoodlesInLuaHandle:setCharacter(player)
end
Events.OnCreatePlayer.Add(updateCharacter)




--[[MOD OPTIONS]]--

local MILOptions = PZAPI.ModOptions:create("MoodlesInLua", getText("Moodles In Lua"))

local borderkey = "MoodleBorderSet"
local uiName = getText("Border texture pack:")

BorderTextureOptions = {
    [1] = "Default",
}


local MoodleBorderSetDropdown = MILOptions:addComboBox(borderkey, uiName, "tooltip")
MoodleBorderSetDropdown:addItem("Default", true)

function MILOptions:apply()
    -- Release textures from the previous moodle set
    if ISMoodlesInLuaHandle.currentMoodleBorderSet then
        ISMoodlesInLuaHandle:clearTextureCache()
    end

    -- Update to the new moodle set
    local selectedIndex = self:getOption("MoodleBorderSet"):getValue()
    local newType = BorderTextureOptions[selectedIndex]
    ISMoodlesInLuaHandle:updateMoodleBorderType(newType)
    ISMoodlesInLuaHandle:update()
end

local og_load = PZAPI.ModOptions.load
PZAPI.ModOptions.load = function(self)
    og_load(self)
    pcall(function ()
        MILOptions:apply()
    end)
end




--[[MOODLE FRAMEWORK COMPATIBILITY]]--

require "MF_ISMoodle"

if MF ~= nil then
    local oldNew = MF.ISMoodle.new

    function MF.ISMoodle.new(self, moodleName, character)
        local o = oldNew(self, moodleName, character)

        for g = 1, 2 do
            for l = 1, 4 do
                local goodBadNeutralId = g
                local moodleLevel = l

                -- Get the texture path from ISMoodlesInLua
                local MFtexturePath = ISMoodlesInLuaHandle:getTexturePath(goodBadNeutralId, moodleLevel)
                -- Load the texture
                local MFtexture = getTexture(MFtexturePath)

                if MFtexture then
                    o:setBackground(g, l, MFtexture)  -- Set the background texture
                else
                    print("MIL: Texture not found for MF, path: " .. texturePath)
                end
            end
        end
        return o
    end
end
