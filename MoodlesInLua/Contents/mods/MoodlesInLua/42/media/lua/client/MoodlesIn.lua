moodlesinlua = ISUIElement:derive("moodlesinlua")

local MoodlesInConfig = require "MoodlesInConfig" -- retrieve config variables

if not MoodlesInConfig then
    print("MoodlesInConfig.lua not found")
    return
end

local function HideVanillaMoodles()
    local moodlesUI = MoodlesUI.getInstance()
    if moodlesUI then
        moodlesUI:setDefaultDraw(false)
    end
end

Events.OnPreUIDraw.Add(HideVanillaMoodles)

-- moodle instances management
local moodlesinluaInstances = {}

function moodlesinlua:new(player)
    local borderPaths = MoodlesInConfig.borderPaths -- retrieve paths for borders
    -- it's here because we need to reduce calls for options so if later it needed to be dynamic just put in o:updateSettings

    local moodlePaths = {
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

    -- Get the initial position for rendering
    local moodlesUI = MoodlesUI.getInstance()
    local x, y = moodlesUI:getX(), moodlesUI:getY()

    -- create new ISUIelement (with x, y, sizes)
    local o = ISUIElement:new(x, y, textureWidth, textureHeight)
    setmetatable(o, self)
    self.__index = self

    -- Add animation tracking properties
    o.moodleAnimations = {}

    o.previousMoodleLevels = {}

    -- store properties
    o.player = player
    o.borderPaths = borderPaths
    o.moodlePaths = moodlePaths

    function o:updateSettings()

        local options = PZAPI.ModOptions:getOptions("moodlesinlua") -- retrieve changable variables

        -- updated moodle size
        local function getCurrentMoodleSize()
            return getCore():getOptionMoodleSize()
        end

        -- get the moodle size
        local moodleSize = getCurrentMoodleSize()

        -- animations fps

        local function getlockFPS()
            return PerformanceSettings.getLockFPS()
        end
        local UIRenderFPS = getlockFPS()
        self.UIRenderFPS = UIRenderFPS


        local fontSize = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()*3-32

        -- maybe works only with 1:1 never tested / FIXME


        -- Declare variables before the if-else block
        local textureWidth, textureHeight, moodleWidth, moodleHeight

        -- Unchangeable / static variables
        if moodleSize <= 6 then
            textureWidth = MoodlesInConfig.textureDefaultSizes[moodleSize].width
            textureHeight = MoodlesInConfig.textureDefaultSizes[moodleSize].height
            moodleWidth = MoodlesInConfig.moodleDefaultSizes[moodleSize].width
            moodleHeight = MoodlesInConfig.moodleDefaultSizes[moodleSize].height
        elseif moodleSize == 7 then
            textureWidth = MoodlesInConfig.textureDefaultSizes[1].width + fontSize
            textureHeight = MoodlesInConfig.textureDefaultSizes[1].height + fontSize
            moodleWidth = MoodlesInConfig.moodleDefaultSizes[1].width + fontSize
            moodleHeight = MoodlesInConfig.moodleDefaultSizes[1].height + fontSize
        end

        local staticExtraX = MoodlesInConfig.staticExtraX
        local staticExtraY = MoodlesInConfig.staticExtraY

        local moodlesDistanceBetween = options:getOption("moodlesDistanceBetween"):getValue()
        local tooltipPadding = options:getOption("tooltipPadding"):getValue()
        local moodlesExtraX = options:getOption("moodlesExtraX"):getValue()
        local moodlesExtraY = options:getOption("moodlesExtraY"):getValue()
        local moodlesAnimationStart = options:getOption("moodlesAnimationStart"):getValue()
        local moodlesPositionStack = options:getOption("moodlesPositionStack"):getValue()

        -- Update object properties
        self.textureWidth = textureWidth
        self.textureHeight = textureHeight
        self.moodleWidth = moodleWidth
        self.moodleHeight = moodleHeight
        self.staticExtraX = staticExtraX
        self.staticExtraY = staticExtraY
        self.moodlesExtraX = moodlesExtraX
        self.moodlesExtraY = moodlesExtraY
        self.moodlesDistanceBetween = moodlesDistanceBetween
        self.tooltipPadding = tooltipPadding
        self.moodlesAnimationStart = moodlesAnimationStart
        self.moodlesPositionStack = moodlesPositionStack

        -- extra logic which must be updated
        local extraX = moodlesExtraX + staticExtraX
        local extraY = moodlesExtraY + staticExtraY
        self.extraX, self.extraY = extraX, extraY -- here we combine and use universal x y
    end

    o:updateSettings() -- initial
    return o
end

function moodlesinlua:render()

    -- check if game in escape menu and then we update stuff
    if UIManager.isShowPausedMessage() then
        self:updateSettings()
    elseif not UIManager.isShowPausedMessage() then return end -- if not then we render

    local player = self.player
    if not player or not player:getMoodles() then return end

    local moodles = player:getMoodles()
    local numMoodles = moodles:getNumMoodles()

    local moodlesUI = MoodlesUI.getInstance()

    -- initialize moodle change tracking
    self.moodleOscillations = self.moodleOscillations or {}

    -- Create a table to hold moodle IDs and their levels
    local moodleList = {}

    for id = 0, numMoodles - 1 do

        local moodleType = MoodleType.FromIndex(id)
        local moodleLevel = moodles:getMoodleLevel(moodleType)
        local moodleGoodBad = moodles:getGoodBadNeutral(id)

        table.insert(moodleList, { id = id, level = moodleLevel, goodbad = moodleGoodBad, type = moodleType })
    end

    -- Sort the moodleList based on levels (highest to lowest)

    table.sort(moodleList, function(a, b)
        if self.moodlesPositionStack == 1 then
            return a.id == b.id -- 0, 1, 2, ...
        elseif self.moodlesPositionStack == 2 then
            return a.level > b.level -- if level bigger then higher in list
        elseif self.moodlesPositionStack == 3 then
            return a.level < b.level -- if level lower then higher in list
        end
    end)

    local displayedMoodlesCount = 0

    -- Now render the moodles in the sorted order
    for _, moodle in ipairs(moodleList) do

        local id = moodle.id
        local moodleLevel = moodle.level
        local moodleGoodBad = moodle.goodbad
        local moodleType = moodle.type

        local currentX = moodlesUI:getAbsoluteX() + self.extraX
        local currentY = moodlesUI:getAbsoluteY() + self.extraY + (displayedMoodlesCount * (self.textureHeight + self.moodlesDistanceBetween))

        local prevLevel = self.previousMoodleLevels[tostring(moodleType)] or 0

        self.previousMoodleLevels[tostring(moodleType)] = moodleLevel

        if moodleLevel > 0 then

            if moodleLevel ~= prevLevel and moodleLevel > 1 then
                self.moodleOscillations[tostring(moodleType)] = 1
            end

            if prevLevel == 0 and moodleLevel == 1 then
                self.moodleAnimations[tostring(moodleType)] = {
                    progress = 0,
                    startX = currentX,
                    startY = currentY,
                    targetX = currentX,
                    targetY = currentY
                }

                if self.moodlesAnimationStart == 1 then
                    -- No animation
                elseif self.moodlesAnimationStart == 2 then
                    self.moodleAnimations[tostring(moodleType)].targetY = 10000 -- change later to get screen height + 512
                elseif self.moodlesAnimationStart == 3 then
                    self.moodleAnimations[tostring(moodleType)].targetX = 10000
                end
            end

            -- Handle Start animation
            local anim = self.moodleAnimations[tostring(moodleType)]
            if anim then
                -- Update and clamp progress using math functions
                anim.progress = math.min(anim.progress + (3 / self.UIRenderFPS), 1)

                -- Smooth cubic ease-out interpolation
                local t = 1 - math.pow(1 - anim.progress, 3)
                local animX = anim.targetX + (anim.startX - anim.targetX) * t
                local animY = anim.targetY + (anim.startY - anim.targetY) * t

                -- Auto-remove and reset animation
                if anim.progress >= 1 then
                    self.moodleAnimations[tostring(moodleType)] = nil
                    animX, animY = currentX, currentY
                end

                currentX, currentY = animX, animY
            end

            local borderTextureKey = moodleGoodBad * 10 + moodleLevel
            local borderTexturePath = self.borderPaths[borderTextureKey]
            local borderTexture = getTexture(borderTexturePath)

            local moodleTexturePath = tostring(moodleType)
            local moodleTexture = getTexture(self.moodlePaths[moodleTexturePath])

            if borderTexture then
                local oscillationOffset = 0
                local moodleOscillation = self.moodleOscillations[tostring(moodleType)] or 0

                if moodleOscillation < 0.015 then
                    moodleOscillation = 0
                end

                if moodleOscillation > 0 then
                    self.moodleOscillations[tostring(moodleType)] = moodleOscillation - moodleOscillation * 4 / self.UIRenderFPS
                    oscillationOffset = math.sin(moodleOscillation * 10) * 6
                end

                UIManager.DrawTexture(borderTexture, currentX + oscillationOffset, currentY, self.textureWidth, self.textureHeight, 1)
                UIManager.DrawTexture(moodleTexture, currentX + oscillationOffset, currentY, self.moodleWidth, self.moodleHeight, 1)
            else
                print("Can't render moodle: " .. moodleTexturePath .. " (Border: " .. moodleLevel .. moodleGoodBad .. ")")
            end

            local mouseX, mouseY = getMouseX(), getMouseY()
            if mouseX >= currentX and mouseX <= currentX + self.textureWidth and mouseY >= currentY and mouseY <= currentY + self.textureHeight then
                self:drawMoodleTooltip(moodles, moodle, moodleList) -- if mouse actually over then draw tooltip
            end

             displayedMoodlesCount = displayedMoodlesCount + 1
        end
    end
end

function moodlesinlua:drawMoodleTooltip(moodles, moodle, moodleList) -- draws tooltip / mouseover
    local title = moodles:getMoodleDisplayString(moodle.id)
    local description = moodles:getMoodleDescriptionString(moodle.id)

    local moodlesUI = MoodlesUI.getInstance()
    local currentX = moodlesUI:getX() + self.extraX
    local currentY = moodlesUI:getY() + self.extraY
    local offsetY = 0


    -- Calculate offsetY based on the sorted moodleList
    for _, m in ipairs(moodleList) do
        if m.id == moodle.id then
            break  -- Stop when we reach the current moodle
        end
        local prevMoodleLevel = m.level  -- Use the level from the sorted list
        if prevMoodleLevel > 0 then
            offsetY = offsetY + self.textureHeight + self.moodlesDistanceBetween
        end
    end

    local titleLength = getTextManager():MeasureStringX(UIFont.Small, title) + 10
    local descriptionLength = getTextManager():MeasureStringX(UIFont.Small, description) + 10
    local textLength = math.max(titleLength, descriptionLength)

    local titleHeight = getTextManager():MeasureStringY(UIFont.Small, title)
    local descriptionHeight = getTextManager():MeasureStringY(UIFont.Small, description)
    local heightPadding = self.tooltipPadding
    local rectHeight = titleHeight + descriptionHeight + heightPadding * 3 + 1

    local centering = (self.textureHeight > 32) and math.floor((self.textureHeight - rectHeight) / 2) or -2 - heightPadding

    -- set initial position to 0
    self:setY(0)
    self:setX(0)

    self:drawRect(currentX + (-textLength - 20), currentY + offsetY + centering, textLength + 10, rectHeight, 0.6, 0, 0, 0)
    self:drawTextRight(title, currentX - 20, currentY + (offsetY + heightPadding) + centering, 1, 1, 1, 1)
    self:drawTextRight(description, currentX - 20, currentY + (offsetY + titleHeight + heightPadding * 2) + centering, 1, 1, 1, 0.7)
end

-- handle player spawn
Events.OnCreatePlayer.Add(function(playerIndex)
    local player = getSpecificPlayer(playerIndex)
    if player then
        if moodlesinluaInstances[playerIndex] then
            local oldInstance = moodlesinluaInstances[playerIndex]
            oldInstance:removeFromUIManager()
        end

        local moodlesinlua = moodlesinlua:new(player)
        moodlesinlua:initialise()
        moodlesinlua:addToUIManager()
        moodlesinluaInstances[playerIndex] = moodlesinlua
    end
end)

-- handle player death
Events.OnPlayerDeath.Add(function(player)
    for playerIndex, instance in pairs(moodlesinluaInstances) do
        if instance.player == player then
            instance:removeFromUIManager() -- Remove from UI manager
            moodlesinluaInstances[playerIndex] = nil -- Clear the instance
        end
    end
end)

-- handle player respawn/new character
Events.OnCreatePlayer.Add(function(playerIndex)
    local player = getSpecificPlayer(playerIndex)
    if player then
        -- remove any existing instance for this player
        if moodlesinluaInstances[playerIndex] then
            local oldInstance = moodlesinluaInstances[playerIndex]
            oldInstance:removeFromUIManager() -- Remove old instance from UI
        end

        -- create new moodle instance
        local moodlesinlua = moodlesinlua:new(player)
        moodlesinlua:initialise()
        moodlesinlua:addToUIManager()
        moodlesinluaInstances[playerIndex] = moodlesinlua -- Store the new instance
    end
end)

require "MF_ISMoodle"

if MF ~=nil then
    local oldNew = MF.ISMoodle.new

    function MF.ISMoodle.new(self,moodleName,character)

        local borderPaths = MoodlesInConfig.borderPaths

        local o = oldNew(self,moodleName,character)
        for g = 1, 2 do
            for l = 1, 4 do
                local MFtextureKey = g * 10 + l
                local MFtexture = borderPaths[MFtextureKey]
                if MFtexture then
                    o:setBackground(g, l, getTexture(MFtexture))  -- Set the background texture
                else
                    print("Texture not found for key: " .. MFtextureKey)
                end
            end
        end
        return o
    end
end
