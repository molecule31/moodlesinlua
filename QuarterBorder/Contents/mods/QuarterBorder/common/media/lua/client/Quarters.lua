if ISMoodlesInLuaHandle == nil then return end -- do not remove this

-- Register texture set
local name = "Quarters" -- Name of your texture set
local path = "media/ui/MIL/Quarter" -- Path to your textures

ISMoodlesInLuaHandle:registerBorderTextureSet(name, path)
