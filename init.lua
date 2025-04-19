-- Initialize global tables
CensusPlus_Database = CensusPlus_Database or {}
CensusPlus_PerCharInfo = CensusPlus_PerCharInfo or {}

CensusPlus_Unhandled = CensusPlus_Unhandled or {};
CensusPlus_JobQueue = CensusPlus_JobQueue or {};						-- The queue of pending jobs
CensusPlus_FailedQueries = CensusPlus_FailedQueries or {}

g_stealth = false;					        -- Stealth mode switch
g_Verbose = CensusPlus_Database["Info"] and CensusPlus_Database["Info"]["Verbose"] or false -- Sync with saved variable

-- Get game version info
local gameVersion, buildNumber, _, _ = GetBuildInfo()
-- Extract major version (e.g. "1" from "1.15.6")
CensusPlus_gameMajorVersion = tonumber(string.match(gameVersion, "^(%d+)%."))

-- Default values for database
CensusPlus_Database["Info"] = CensusPlus_Database["Info"] or {
    AutoCensus = true,
    Verbose = false, 
    Stealth = false,
    PlayFinishSound = false,
    SoundFile = 1,
    AutoCensusTimer = 1800,
    CensusButtonShown = true,
    CensusButtonAnimi = true,
    CPWindow_Transparency = 0.5,
    UseLogBars = true,
    UseWorldFrameClicks = false
}

-- Default values for character settings
CensusPlus_PerCharInfo["Version"] = CensusPlus_PerCharInfo["Version"] or {}

print("Game Version: " .. gameVersion .. " (Major Version: " .. CensusPlus_gameMajorVersion .. ")")

MAX_CHARACTER_LEVEL = 60;					-- Maximum level a PC can attain  testing only comment out for live
if CensusPlus_gameMajorVersion == 1 then
    MAX_CHARACTER_LEVEL = 60
elseif CensusPlus_gameMajorVersion == 2 then
    MAX_CHARACTER_LEVEL = 70
elseif CensusPlus_gameMajorVersion == 3 then
    MAX_CHARACTER_LEVEL = 80
elseif CensusPlus_gameMajorVersion == 4 then
    MAX_CHARACTER_LEVEL = 85
end

-- UI Layout Constants
CP_ICON_SPACING = 6      -- Space between icons
CP_ICON_SIZE = 32       -- Size of race/class icons 
CP_LEVEL_BAR_WIDTH = 10 -- Width of level bars
CP_LEVEL_BAR_SPACING = 2 -- Space between level bars
CP_WINDOW_WIDTH = 880
CP_GUILDS_LEFT_OFFSET = 264 

CENSUSPlus_HORDE    = "Horde";
CENSUSPlus_ALLIANCE = "Alliance";
