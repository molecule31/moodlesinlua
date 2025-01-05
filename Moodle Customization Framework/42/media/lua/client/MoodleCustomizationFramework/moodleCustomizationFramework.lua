ISMoodleCustomizationFramework = ISUIElement:derive("ISMoodleCustomizationFramework")

function ISMoodleCustomizationFramework:new()
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

    o.moodleAlpha = 1.0

    o.previousMoodleLevels = {}
    o.moodleAnimations = {}

    o.useCharacter = nil
    o.active = false

    o.textureSets = {}
    o.textureCache = {}
    return o
end

function ISMoodleCustomizationFramework:start()
    self.active = true
end
function ISMoodleCustomizationFramework:stop()
    self.active = false
end

function ISMoodleCustomizationFramework:setCharacter(character)
    self.useCharacter = character
end

function ISMoodleCustomizationFramework:registerTextureSet(name, path)
    -- Error Handling: Ensure texture set contains name and path
    if not name or not path then
        error("MCF [registerTextureSet]: ERROR - Texture set registration requires both a name and a path.")
        return
    end
    
    -- Error Handling: Prevent duplicate entries
    for _, set in ipairs(self.textureSets) do
        if set.name == name then
            print("MCF [registerTextureSet]: ERROR - Texture set '" .. name .. "' is already registered.")
            return
        end
    end

    -- Cache texture set name and path
    table.insert(self.textureSets, { name = name, path = path })

    -- Add to dropdown menu and options
    local mcfModOptions = PZAPI.ModOptions:getOptions("Moodle_Customization_Framework")
    local moodleBackgroundDropdown = mcfModOptions and mcfModOptions:getOption("Moodle_Background_Set")

    if moodleBackgroundDropdown then
        moodleBackgroundDropdown:addItem(name, false)
    else
        print("MCF [registerTextureSet]: ERROR - Moodle Background dropdown menu has not been initialized.")
    end

    table.insert(moodleBackgroundOptions, name)
end


function ISMoodleCustomizationFramework:getTexturePath(goodBadNeutralId, moodleLevel)
    local basePath = "media/ui/MCF/Vanilla (Default)"
    
    -- Find the registered texture set
    for _, set in ipairs(self.textureSets) do
        if set.name == self.currentMoodleBackgroundSet then
            basePath = set.path
            break
        end
    end

    return string.format("%s/%s_%d.png", basePath, goodBadNeutralId == 1 and "Good" or goodBadNeutralId == 2 and "Bad" or "Neutral", moodleLevel)
end

function ISMoodleCustomizationFramework:getTexture(path)
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

function ISMoodleCustomizationFramework:clearTextureCache()
    if self.textureCache then
        for path, _ in pairs(self.textureCache) do
            print("Releasing texture: " .. path)
        end
        self.textureCache = {} -- Clear all cached textures
    end
end

function ISMoodleCustomizationFramework:getMoodleSize()
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

function ISMoodleCustomizationFramework:updateMoodleBorderType(newType)
    self.currentMoodleBackgroundSet = newType
end

function ISMoodleCustomizationFramework:drawMoodleTooltip(moodles, moodleId, moodleX, moodleY)
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
    local anchorTooltipOnMoodle = (moodleSize > self.defaultMoodleSize) and (moodleSize - 56) / 2 or 0 --56 is the height of the vanilla tooltip
    local tooltipXOffset = 0 -- Can be used to add a larger gap between the tooltip and moodle. 0 is default vanilla position

    -- Draw Tooltip Rectangle
    self:drawRect(moodleX - textLength - textPadding - tooltipXOffset, moodleY + anchorTooltipOnMoodle, textLength + textPadding, rectHeight, 0.6, 0, 0, 0)
    -- Draw Tooltip Text & Description (not necessary when using moodlesUI:setVisible() state)
    self:drawTextRight(title, moodleX - textPadding - tooltipXOffset, moodleY + self.tooltipPadding + anchorTooltipOnMoodle, 1, 1, 1, 1)
    self:drawTextRight(description, moodleX - textPadding - tooltipXOffset, moodleY + titleHeight + self.tooltipPadding * 2 + anchorTooltipOnMoodle, 1, 1, 1, 0.7)
end

function ISMoodleCustomizationFramework:update()

    local moodlesUI = MoodlesUI.getInstance()

    --Ensures ISMoodleCustomizationFramework and MoodlesUI are active
    if not self.active or not moodlesUI then return end

    --Disable Framework Functionality & Use Vanilla Moodle System If "Vanilla (Default)" Is Selected
    moodlesUI:setDefaultDraw(self.currentMoodleBackgroundSet == "Vanilla (Default)")
    if self.currentMoodleBackgroundSet == "Vanilla (Default)" then return end

    --[[ Doesn't Disable The Moodle Hover Tooltip Text For Some Reason?
    moodlesUI:setVisible(self.currentMoodleBackgroundSet == "Vanilla (Default)")
    if self.currentMoodleBackgroundSet == "Vanilla (Default)" then return end
    --]]

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

ISMoodleCustomizationFrameworkHandle = ISMoodleCustomizationFramework:new()

-- Initialize the framework and add it to the UIManager
local function initializeMoodleCustomizationFramework()
    ISMoodleCustomizationFrameworkHandle:initialise()
    ISMoodleCustomizationFrameworkHandle:addToUIManager()
    ISMoodleCustomizationFrameworkHandle:start()
end
Events.OnGameStart.Add(initializeMoodleCustomizationFramework)

-- Update player character
local function updateCharacter(id,player)
    ISMoodleCustomizationFrameworkHandle:setCharacter(player)
end
Events.OnCreatePlayer.Add(updateCharacter)

-- Ensure the framework updates on each frame
local function onPreUIDraw()
    ISMoodleCustomizationFrameworkHandle:update()
end
Events.OnPreUIDraw.Add(onPreUIDraw)




--[[MOD OPTIONS]]

local vanillaOptions = PZAPI.ModOptions:create("Moodle_Customization_Framework", getText("Moodle Customization Framework"))

local key = "Moodle_Background_Set"
local uiName = getText("Moodle Background Set")

moodleBackgroundOptions = {
    [1] = "Vanilla (Default)",
}

local moodleBackgroundSetDropdown = vanillaOptions:addComboBox(key, uiName, "tooltip")
moodleBackgroundSetDropdown:addItem("Vanilla (Default)", true)

function vanillaOptions:apply()
    -- Release textures from the previous moodle set
    if ISMoodleCustomizationFrameworkHandle.currentMoodleBackgroundSet then
        ISMoodleCustomizationFrameworkHandle:clearTextureCache()
    end

    -- Update to the new moodle set
    local selectedIndex = self:getOption("Moodle_Background_Set"):getValue()
    local newType = moodleBackgroundOptions[selectedIndex]
    ISMoodleCustomizationFrameworkHandle:updateMoodleBorderType(newType)
    ISMoodleCustomizationFrameworkHandle:update()
end

local og_load = PZAPI.ModOptions.load
PZAPI.ModOptions.load = function(self)
    og_load(self)
    pcall(function ()
        vanillaOptions:apply()
    end)
end