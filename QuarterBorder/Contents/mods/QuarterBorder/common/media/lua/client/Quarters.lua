if ISMoodlesInLua == nil then return end -- do not remove this

local name = "Quarters" -- Name of your texture set
local path = "media/ui/MIL/Quarter" -- Path to your textures

return ISMoodlesInLuaHandle:registerBorderTextureSet(name, path)
