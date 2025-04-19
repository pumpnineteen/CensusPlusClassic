local	addon_name, CPp = ... 

g_RaceClassList = { };						-- Used to pick the right icon
g_RaceClassList[CENSUSPLUS_DRUID]		 = 10;
g_RaceClassList[CENSUSPLUS_HUNTER]		 = 11;
g_RaceClassList[CENSUSPLUS_MAGE]		 = 12;
g_RaceClassList[CENSUSPLUS_PRIEST]		 = 13;
g_RaceClassList[CENSUSPLUS_ROGUE]		 = 14;
g_RaceClassList[CENSUSPLUS_WARLOCK]	     = 15;
g_RaceClassList[CENSUSPLUS_WARRIOR]	     = 16;
g_RaceClassList[CENSUSPLUS_SHAMAN]		 = 17;
g_RaceClassList[CENSUSPLUS_PALADIN]	     = 18;
g_RaceClassList[CENSUSPLUS_MONK]	     = 19;
g_RaceClassList[CENSUSPLUS_DEATHKNIGHT]	 = 30;
g_RaceClassList[CENSUSPLUS_DEMONHUNTER]	 = 35;

g_RaceClassList[CENSUSPLUS_DWARF]		 = 20;
g_RaceClassList[CENSUSPLUS_GNOME]		 = 21;
g_RaceClassList[CENSUSPLUS_HUMAN]		 = 22;
g_RaceClassList[CENSUSPLUS_NIGHTELF]	 = 23;
g_RaceClassList[CENSUSPLUS_ORC]		     = 24;
g_RaceClassList[CENSUSPLUS_TAUREN]		 = 25;
g_RaceClassList[CENSUSPLUS_TROLL]		 = 26;
g_RaceClassList[CENSUSPLUS_UNDEAD]		 = 27;
g_RaceClassList[CENSUSPLUS_DRAENEI]		 = 28;
g_RaceClassList[CENSUSPLUS_BLOODELF]	 = 29;
g_RaceClassList[CENSUSPLUS_GOBLIN]	 	 = 31;
g_RaceClassList[CENSUSPLUS_WORGEN]		 = 32;
g_RaceClassList[CENSUSPLUS_PANDAREN]	 = 33;
g_RaceClassList[CENSUSPLUS_HIGHMOUNTAIN] = 36;
g_RaceClassList[CENSUSPLUS_NIGHTBORNE]   = 37;
g_RaceClassList[CENSUSPLUS_LIGHTFORGED]  = 39;
g_RaceClassList[CENSUSPLUS_VOIDELF]      = 40;


CensusPlus_NumRaces = 4

function CensusPlus_GetFactionRaces(faction)
    -- print("GetRaceClasses: ", faction , " | ", CENSUSPlus_HORDE, CENSUSPlus_ALLIANCE)
    local races = {};
    if (faction == CENSUSPlus_HORDE) then 
        if CensusPlus_gameMajorVersion >= 4 then  -- Cataclysm
            races = {CENSUSPLUS_ORC, CENSUSPLUS_TROLL, CENSUSPLUS_TAUREN, CENSUSPLUS_UNDEAD, 
                    CENSUSPLUS_BLOODELF, CENSUSPLUS_GOBLIN};
        elseif CensusPlus_gameMajorVersion >= 2 then  -- TBC and Wrath
            races = {CENSUSPLUS_ORC, CENSUSPLUS_TROLL, CENSUSPLUS_TAUREN, CENSUSPLUS_UNDEAD, 
                    CENSUSPLUS_BLOODELF};
        else  -- Classic Era
            races = {CENSUSPLUS_ORC, CENSUSPLUS_TROLL, CENSUSPLUS_TAUREN, CENSUSPLUS_UNDEAD};
        end
    else
        if CensusPlus_gameMajorVersion >= 4 then  -- Cataclysm
            races = {CENSUSPLUS_HUMAN, CENSUSPLUS_DWARF, CENSUSPLUS_NIGHTELF, CENSUSPLUS_GNOME, 
                    CENSUSPLUS_DRAENEI, CENSUSPLUS_WORGEN};
        elseif CensusPlus_gameMajorVersion >= 2 then  -- TBC and Wrath
            races = {CENSUSPLUS_HUMAN, CENSUSPLUS_DWARF, CENSUSPLUS_NIGHTELF, CENSUSPLUS_GNOME, 
                    CENSUSPLUS_DRAENEI};
        else  -- Classic Era
            races = {CENSUSPLUS_HUMAN, CENSUSPLUS_DWARF, CENSUSPLUS_NIGHTELF, CENSUSPLUS_GNOME};
        end
    end
    CensusPlus_NumRaces = #races;
    return races;
end

CensusPlus_GetFactionRaces(CENSUSPlus_HORDE)
CPp.Msg("CPP Num Races:" .. CensusPlus_NumRaces)


CensusPlus_NumClasses = 8

function CensusPlus_GetFactionClasses(faction)
    local classes = {};
    if CensusPlus_gameMajorVersion >= 3 then  -- Wrath
        classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_PALADIN, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE,
                    CENSUSPLUS_PRIEST, CENSUSPLUS_DEATHKNIGHT, CENSUSPLUS_SHAMAN, CENSUSPLUS_MAGE,
                    CENSUSPLUS_WARLOCK, CENSUSPLUS_DRUID};
    elseif CensusPlus_gameMajorVersion >= 2 then  -- TBC
        classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_PALADIN, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE,
                      CENSUSPLUS_PRIEST, CENSUSPLUS_SHAMAN, CENSUSPLUS_MAGE, CENSUSPLUS_WARLOCK,
                      CENSUSPLUS_DRUID};
    else  -- Classic Era
        if (faction == CENSUSPlus_HORDE) then 
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE, CENSUSPLUS_PRIEST,
                      CENSUSPLUS_SHAMAN, CENSUSPLUS_MAGE, CENSUSPLUS_WARLOCK, CENSUSPLUS_DRUID};
        else
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_PALADIN, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE,
                      CENSUSPLUS_PRIEST, CENSUSPLUS_MAGE, CENSUSPLUS_WARLOCK, CENSUSPLUS_DRUID};
        end
    end
    CensusPlus_NumClasses = #classes;
    return classes;
end

CensusPlus_GetFactionClasses(CENSUSPlus_HORDE)
CPp.Msg("CPP Num Classes:" .. CensusPlus_NumClasses)

function GetRaceClasses(race)
    local classes = {};
    if CensusPlus_gameMajorVersion >= 4 then  -- Cataclysm
        if (race == CENSUSPLUS_HUMAN) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_PALADIN, CENSUSPLUS_ROGUE, CENSUSPLUS_PRIEST,
                      CENSUSPLUS_DEATHKNIGHT, CENSUSPLUS_MAGE, CENSUSPLUS_WARLOCK};
        elseif (race == CENSUSPLUS_DWARF) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_PALADIN, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE,
                      CENSUSPLUS_PRIEST, CENSUSPLUS_DEATHKNIGHT, CENSUSPLUS_SHAMAN, CENSUSPLUS_MAGE,
                      CENSUSPLUS_WARLOCK};
        elseif (race == CENSUSPLUS_NIGHTELF) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE, CENSUSPLUS_PRIEST,
                      CENSUSPLUS_DEATHKNIGHT, CENSUSPLUS_DRUID, CENSUSPLUS_MAGE};
        elseif (race == CENSUSPLUS_GNOME) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_ROGUE, CENSUSPLUS_DEATHKNIGHT, CENSUSPLUS_MAGE,
                      CENSUSPLUS_WARLOCK, CENSUSPLUS_PRIEST};
        elseif (race == CENSUSPLUS_DRAENEI) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_PALADIN, CENSUSPLUS_HUNTER, CENSUSPLUS_PRIEST,
                      CENSUSPLUS_DEATHKNIGHT, CENSUSPLUS_SHAMAN, CENSUSPLUS_MAGE};
        elseif (race == CENSUSPLUS_WORGEN) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE, CENSUSPLUS_PRIEST,
                      CENSUSPLUS_DEATHKNIGHT, CENSUSPLUS_MAGE, CENSUSPLUS_WARLOCK, CENSUSPLUS_DRUID};
        elseif (race == CENSUSPLUS_ORC) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE, CENSUSPLUS_DEATHKNIGHT,
                      CENSUSPLUS_SHAMAN, CENSUSPLUS_MAGE, CENSUSPLUS_WARLOCK};
        elseif (race == CENSUSPLUS_UNDEAD) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_ROGUE, CENSUSPLUS_PRIEST, CENSUSPLUS_DEATHKNIGHT,
                      CENSUSPLUS_MAGE, CENSUSPLUS_WARLOCK};
        elseif (race == CENSUSPLUS_TAUREN) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_HUNTER, CENSUSPLUS_DEATHKNIGHT, CENSUSPLUS_PRIEST,
                      CENSUSPLUS_SHAMAN, CENSUSPLUS_DRUID, CENSUSPLUS_PALADIN};
        elseif (race == CENSUSPLUS_TROLL) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE, CENSUSPLUS_PRIEST,
                      CENSUSPLUS_DEATHKNIGHT, CENSUSPLUS_SHAMAN, CENSUSPLUS_MAGE, CENSUSPLUS_DRUID,
                      CENSUSPLUS_WARLOCK};
        elseif (race == CENSUSPLUS_BLOODELF) then
            classes = {CENSUSPLUS_PALADIN, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE, CENSUSPLUS_PRIEST,
                      CENSUSPLUS_DEATHKNIGHT, CENSUSPLUS_MAGE, CENSUSPLUS_WARLOCK, CENSUSPLUS_WARRIOR};
        elseif (race == CENSUSPLUS_GOBLIN) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE, CENSUSPLUS_DEATHKNIGHT,
                      CENSUSPLUS_SHAMAN, CENSUSPLUS_MAGE, CENSUSPLUS_WARLOCK, CENSUSPLUS_PRIEST};
        end
    elseif CensusPlus_gameMajorVersion >= 3 then  -- Wrath
        if (race == CENSUSPLUS_HUMAN) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_PALADIN, CENSUSPLUS_ROGUE, CENSUSPLUS_PRIEST,
                      CENSUSPLUS_DEATHKNIGHT, CENSUSPLUS_MAGE, CENSUSPLUS_WARLOCK};
        elseif (race == CENSUSPLUS_DWARF) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_PALADIN, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE,
                      CENSUSPLUS_PRIEST, CENSUSPLUS_DEATHKNIGHT};
        elseif (race == CENSUSPLUS_NIGHTELF) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE, CENSUSPLUS_PRIEST,
                      CENSUSPLUS_DEATHKNIGHT, CENSUSPLUS_DRUID};
        elseif (race == CENSUSPLUS_GNOME) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_ROGUE, CENSUSPLUS_DEATHKNIGHT, CENSUSPLUS_MAGE,
                      CENSUSPLUS_WARLOCK};
        elseif (race == CENSUSPLUS_DRAENEI) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_PALADIN, CENSUSPLUS_HUNTER, CENSUSPLUS_PRIEST,
                      CENSUSPLUS_DEATHKNIGHT, CENSUSPLUS_SHAMAN, CENSUSPLUS_MAGE};
        elseif (race == CENSUSPLUS_ORC) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE, CENSUSPLUS_DEATHKNIGHT,
                      CENSUSPLUS_SHAMAN, CENSUSPLUS_WARLOCK};
        elseif (race == CENSUSPLUS_UNDEAD) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_ROGUE, CENSUSPLUS_PRIEST, CENSUSPLUS_DEATHKNIGHT,
                      CENSUSPLUS_MAGE, CENSUSPLUS_WARLOCK};
        elseif (race == CENSUSPLUS_TAUREN) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_HUNTER, CENSUSPLUS_DEATHKNIGHT, CENSUSPLUS_SHAMAN,
                      CENSUSPLUS_DRUID};
        elseif (race == CENSUSPLUS_TROLL) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE, CENSUSPLUS_PRIEST,
                      CENSUSPLUS_DEATHKNIGHT, CENSUSPLUS_SHAMAN, CENSUSPLUS_MAGE};
        elseif (race == CENSUSPLUS_BLOODELF) then
            classes = {CENSUSPLUS_PALADIN, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE, CENSUSPLUS_PRIEST,
                      CENSUSPLUS_DEATHKNIGHT, CENSUSPLUS_MAGE, CENSUSPLUS_WARLOCK};
        end
    elseif CensusPlus_gameMajorVersion >= 2 then  -- TBC
        if (race == CENSUSPLUS_HUMAN) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_PALADIN, CENSUSPLUS_ROGUE, CENSUSPLUS_PRIEST,
                      CENSUSPLUS_MAGE, CENSUSPLUS_WARLOCK};
        elseif (race == CENSUSPLUS_DWARF) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_PALADIN, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE,
                      CENSUSPLUS_PRIEST};
        elseif (race == CENSUSPLUS_NIGHTELF) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE, CENSUSPLUS_PRIEST,
                      CENSUSPLUS_DRUID};
        elseif (race == CENSUSPLUS_GNOME) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_ROGUE, CENSUSPLUS_MAGE, CENSUSPLUS_WARLOCK};
        elseif (race == CENSUSPLUS_DRAENEI) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_PALADIN, CENSUSPLUS_HUNTER, CENSUSPLUS_PRIEST,
                      CENSUSPLUS_SHAMAN, CENSUSPLUS_MAGE};
        elseif (race == CENSUSPLUS_ORC) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE, CENSUSPLUS_SHAMAN,
                      CENSUSPLUS_WARLOCK};
        elseif (race == CENSUSPLUS_UNDEAD) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_ROGUE, CENSUSPLUS_PRIEST, CENSUSPLUS_MAGE,
                      CENSUSPLUS_WARLOCK};
        elseif (race == CENSUSPLUS_TAUREN) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_HUNTER, CENSUSPLUS_SHAMAN, CENSUSPLUS_DRUID};
        elseif (race == CENSUSPLUS_TROLL) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE, CENSUSPLUS_PRIEST,
                      CENSUSPLUS_SHAMAN, CENSUSPLUS_MAGE};
        elseif (race == CENSUSPLUS_BLOODELF) then
            classes = {CENSUSPLUS_PALADIN, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE, CENSUSPLUS_PRIEST,
                      CENSUSPLUS_MAGE, CENSUSPLUS_WARLOCK};
        end
    else  -- Classic Era
        if (race == CENSUSPLUS_HUMAN) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_PALADIN, CENSUSPLUS_ROGUE, CENSUSPLUS_PRIEST,
                      CENSUSPLUS_MAGE, CENSUSPLUS_WARLOCK};
        elseif (race == CENSUSPLUS_DWARF) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_PALADIN, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE,
                      CENSUSPLUS_PRIEST};
        elseif (race == CENSUSPLUS_NIGHTELF) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE, CENSUSPLUS_PRIEST,
                      CENSUSPLUS_DRUID};
        elseif (race == CENSUSPLUS_GNOME) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_ROGUE, CENSUSPLUS_MAGE, CENSUSPLUS_WARLOCK};
        elseif (race == CENSUSPLUS_ORC) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE, CENSUSPLUS_SHAMAN,
                      CENSUSPLUS_WARLOCK};
        elseif (race == CENSUSPLUS_UNDEAD) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_ROGUE, CENSUSPLUS_PRIEST, CENSUSPLUS_MAGE,
                      CENSUSPLUS_WARLOCK};
        elseif (race == CENSUSPLUS_TAUREN) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_HUNTER, CENSUSPLUS_SHAMAN, CENSUSPLUS_DRUID};
        elseif (race == CENSUSPLUS_TROLL) then
            classes = {CENSUSPLUS_WARRIOR, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE, CENSUSPLUS_PRIEST,
                      CENSUSPLUS_SHAMAN, CENSUSPLUS_MAGE};
        end
    end
    return classes;
end


-- Calculate total widths
local function CalculateWindowSizes()
    -- Race section - 4 icons in Classic, 5 in TBC, 6 in Cata
    local numRaces = CensusPlus_NumRaces
    CP_RACE_SECTION_WIDTH = (numRaces * CP_ICON_SIZE) + ((numRaces-1) * CP_ICON_SPACING)

    local numClasses = CensusPlus_NumClasses
    CP_CLASS_SECTION_WIDTH = (numClasses * CP_ICON_SIZE) + ((numClasses-1) * CP_ICON_SPACING)

    local maxLevel = MAX_CHARACTER_LEVEL 
    CP_LEVEL_SECTION_WIDTH = (maxLevel * CP_LEVEL_BAR_WIDTH) + (maxLevel * CP_LEVEL_BAR_SPACING)

    local width_needed = CP_RACE_SECTION_WIDTH + CP_CLASS_SECTION_WIDTH + 100 + CP_GUILDS_LEFT_OFFSET

    if  width_needed > CP_WINDOW_WIDTH then
        CP_WINDOW_WIDTH = width_needed
    end

    CPp.Msg("Window width: " .. CP_WINDOW_WIDTH)

    while CP_LEVEL_SECTION_WIDTH > CP_WINDOW_WIDTH - 40 do
        CPp.Msg("Adjusting levels width: " .. CP_LEVEL_SECTION_WIDTH .. " (" .. CP_WINDOW_WIDTH .. ")")
        CP_LEVEL_BAR_WIDTH = CP_LEVEL_BAR_WIDTH - 1
        CP_LEVEL_SECTION_WIDTH = (maxLevel * CP_LEVEL_BAR_WIDTH) + (maxLevel * CP_LEVEL_BAR_SPACING)
    end

    CPp.Msg("Levels width: " .. CP_LEVEL_SECTION_WIDTH)
end

-- Call this after MAX_CHARACTER_LEVEL is set
CalculateWindowSizes()