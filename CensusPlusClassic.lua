--[[ CensusPlusClassic for World of Warcraft(tm).

	Copyright 2005 - 2016 Cooper Sellers

	License:
		The MIT License Copyright (c) 2025 Pump 
        Permission is hereby granted, free of charge, to any person obtaining a copy 
        of this software and associated documentation files (the "Software"), to deal 
        in the Software without restriction, including without limitation the rights 
        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
        copies of the Software, and to permit persons to whom the Software is furnished 
        to do so, subject to the following conditions: The above copyright notice and 
        this permission notice shall be included in all copies or substantial portions 
        of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
        EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS 
        OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
        IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
        WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

  Debugging/profiling note:
  Global  CPp.EnableProfiling must be set to True
  the appropriate profiling point must be set in code with
  --CP_profiling_timerstart =	debugprofilestop()
  don't use debugprofilestart() this does a reset of the timer...
  if multiple code (addons) have profiling turned on.. then debugprofilestart()
  will impact timing of the all the code profiles.
]]
--local regionKey = GetCVar("portal") == "public-test" and "PTR" or GetCVar("portal")
--Note: file layout structured for use with NotePad++ as editor using Lua(WoW) language definition

--[[	CensusPlus
--		A WoW UI customization by Cooper Sellers
--
--		CensusPlusClassic
--		Modified by christophrus
]]

local	addon_name, CPp = ...   		-- Addon_name contains the Addon name which must be the same as the container folder name... addon_tableID is a common private table for all .lua files in the directory.
CPp = LibStub("AceAddon-3.0"):NewAddon(CPp, "AceConsole-3.0", "AceEvent-3.0")

local checksum = LibStub:GetLibrary("LibChecksum-1.0", true)

CPp.InterfaceVersion = "Captain Placeholder";   -- random value.. must not match CensusPlus_VERSION string.
local g_CensusPlusTZOffset = -999;
CPp.LocaleSet = false;  -- not used?
CPp.TZWarningSent = false;  -- not used?

-- Bindings
BINDING_NAME_CENSUSPLUSCLASSIC_MANUALWHO = 'Issue a manual /who request'
BINDING_HEADER_CENSUSPLUSCLASSIC = 'CensusPlusClassic'

-- Constants
local CensusPlus_Version_Major = "0"; -- changing this number will force a saved data purge
local CensusPlus_Version_Minor = "8"; -- changing this number will force a saved data purge
local CensusPlus_Version_Maint = "4";
local CensusPlus_SubVersion = "";
--local CensusPlus_VERSION = "WoD"
local CensusPlus_VERSION = CensusPlus_Version_Major.."."..CensusPlus_Version_Minor .."."..CensusPlus_Version_Maint;
local CensusPlus_VERSION_FULL = CensusPlus_VERSION --.."."..CensusPlus_SubVersion ;
local CensusPlus_PTR = GetCVar("portal") == "public-test" and "PTR";	-- enable true for PTR testing  enable false for live use
local CensusPlus_MAXBARHEIGHT = 128;			-- Length of blue bars
local CensusPlus_NUMGUILDBUTTONS = 10;			-- How many guild buttons are on the UI?

-- Constants
local MIN_CHARACTER_LEVEL = 1;					-- Minimum observed level returned by /who command (undocumented and barely acknowledged.)
local MAX_WHO_RESULTS = 49;						-- Maximum number of who results the server will return
CensusPlus_GUILDBUTTONSIZEY = 16;				-- pixil height of guild name lines
local CensusPlus_UPDATEDELAY = 5;				-- Delay time between /who messages
local CensusPlus_UPDATEDELAY2 = 10				-- Delay time from who request to database updated
local CP_MAX_TIMES = 50;

--local g_ServerPrefix = "";					--  US VERSION!!
--local g_ServerPrefix = "EU-";					--  EU VERSION!!

-- debug flags for remote QA testing of version upgrades.
local CP_api = "api"
local CP_letterselect = 0					-- default letter selector pattern... valid options 1 and 2.. testing only
local CensusPlus_WHOPROCESSOR = CP_api      -- default processing of who request to full wholib  CP_api --
local CensusPLus_DEBUGWRITES = false    	-- don't add debug into to censusplus.lua output.
local CP_g_queue_count = 0 					-- process speed checking avg time to process 1 queue

-- Add after other local variables:
local FAILED_QUERY_EXPIRE_DAYS = 14; -- How many days before we forget about failed queries

-- Helper function to generate a unique key for failed queries
local function GetFailedQueryKey(job, realmName)
    return string.format("%s:%d-%d-%s-%s-%s",
        realmName or "",
        job.m_MinLevel or 0,
        job.m_MaxLevel or 0, 
        job.m_Race or "nil",
        job.m_Class or "nil",
        job.m_Letter or "nil"
    )
end

-- Record a failed query
local function RecordFailedQuery(job)
    if job == nil then
        CPp.Msg("Can't record a nil job!")
        return
    end
    local realmName = CensusPlus_GetUniqueRealmName()
    local key = GetFailedQueryKey(job, realmName)
    if g_verbose then
        CPp.Msg("Fail key: "..key)
    end
    CensusPlus_FailedQueries[key] = {
        realm = realmName,
        time = time(),
        minLevel = job.m_MinLevel,
        maxLevel = job.m_MaxLevel,
        race = job.m_Race,
        class = job.m_Class,
        letter = job.m_Letter
    }
    -- CPp.Msg("Failed queries: " .. tostring(#CensusPlus_FailedQueries))
end

-- Check if a query would fail based on history
local function WouldQueryFail(job) 
    if job == nil then 
        return false 
    end

    local realmName = CensusPlus_GetUniqueRealmName()
    local key = GetFailedQueryKey(job, realmName)
    
    local failedQuery = CensusPlus_FailedQueries[key]
    if not failedQuery then
        return false
    end
    
    -- Check if the failed query has expired
    local now = time()
    if (now - failedQuery.time) > (FAILED_QUERY_EXPIRE_DAYS * 24 * 60 * 60) then
        CensusPlus_FailedQueries[key] = nil
        return false
    end
    
    return true
end

-- Global scope variables
local g_TrackUnhandled = false;
CPp.Options_Holder = {}							-- table is populated with existing option settings when Options panel is opened.. cancel resets live options to these settings.
CPp.Options_Holder["AccountWide"] = {}
CPp.Options_Holder["CCOverrides"] = {}

-- File scope variables
local g_addon_loaded = false
local g_player_loaded = false


CPp.AutoCensus = false;						-- AutoCensus mode switch
local g_Options_Scope = "AW"				-- options are AW or CO
CPp.AutoStartTimer = 30						-- default Slider value in Options
local g_FinishSoundNumber = 1				-- default finish sound..
local g_PlayFinishSound = false				-- mode switch
local g_CensusPlusInitialized = false;		-- Is CensusPlusClassic initialized?
local g_CurrentJob = {};					-- Current job being executed
CPp.IsCensusPlusInProgress = false;			-- Is a CensusPlusClassic in progress?
local g_CensusPlusPaused = false			-- Is CensusPlusClassic in progress paused?
CPp.CensusPlusManuallyPaused = false;       -- Is CensusPlusClassic in progress manually paused?
local CensusPlayerOnly = false				-- true if player requests via /census me

CensusPlus_JobQueue.g_NumNewCharacters = 0;					-- How many new characters found this CensusPlusClassic
CensusPlus_JobQueue.g_NumUpdatedCharacters = 0;				-- How many characters were updated during this CensusPlusClassic

local g_MobXPByLevel = {};						-- XP earned for killing
local g_CharacterXPByLevel = {};				-- XP required to advance through the given level
local g_TotalCharacterXPPerLevel = {};			-- Total XP required to attain the given level

CensusPlus_Guilds = {};							-- All known guild

local g_TotalCharacterXP = 0;					-- Total character XP for currently selected search
local g_Consecutive = 0;						-- Current consecutive same realm/faction run count
local g_TotalCount = 0;							-- Total number of characters which meet search criteria
local g_RaceCount = {};							-- Totals for each race given search criteria
local g_ClassCount = {};						-- Totals for each class given search criteria
local g_LevelCount = {};						-- Totals for each level given search criteria
local g_AccumulatorCount = 0;
local g_AccumulatorXPTotal = 0;
local g_AccumulateGuildTotals = true;			-- switch for guild work when scanning characters

CensusPlus_JobQueue.g_TempCount  = {};

CPp.GuildSelected = 0;						-- Search criteria: Currently selected guild, 0 indicates none
CPp.RaceSelected = 0;						-- Search criteria: Currently selected race, 0 indicates none
CPp.ClassSelected = 0;						-- Search criteria: Currently selected class, 0 indicates none
CPp.LevelSelected = 0;
local current_realm = 0;

local g_LastOnUpdateTime = 0;					-- Last time OnUpdate was called
local g_WaitingForWhoUpdate = false;			-- Are we waiting for a who update event?

local g_factionGroup = "Neutral"						-- Faction of character running census. used to select/verify correct faction of race

local g_WhoAttempts = 0;                        -- Counter for detecting stuck who results
local g_MiniOnStart = 1;                        -- Flag to have the mini-censusP displayed on startup

local g_CompleteCensusStarted = false;          -- Flag for counter
local g_TakeHour = 0;                           -- Our timing hour
local g_ResetHour = true;                       -- Rest hour
local g_VariablesLoaded = false;                -- flag to tell us if vars are loaded
CPp.FirstLoad = false						-- Flag to handle (hide) various database rebuild messages on initial database creation
local g_FirstRun = true;
local g_wasPurged = false
local whoquery_answered = false;
local whoquery_active = false
CPp.LastCensusRun = time() -- (CPp.AutoStartTrigger * 60)	--  timer used if auto census is turned on
CPp.LastManualWho = time()

local g_Pre_SFX = nil;
local CP_updatingGuild  = nil;
local g_CurrentlyInBG = false;
local g_CurrentlyInBG_Msg = false;
local g_InternalSearchName = nil;
local g_InternalSearchLevel = nil;
local g_InternalSearchCount = 0;
CPp.EnableProfiling = false;
local CP_profiling_timerstart = 0
local CP_profiling_timediff = 0
local g_CensusPlus_StartTime = 0;
local g_CensusWhoOverrideMsg = nil;
local g_WaitingForOverrideUpdate = false;
local g_ProblematicMessageShown = false;
local g_PratLoaded = false;

--  Battleground info
CENSUSPLUS_CURRENT_BATTLEFIELD_QUEUES = {};

CensusPlus_JobQueue.g_TimeDatabase = {};                      -- Time database
local function CensusPlus_Zero_g_TimeDatabase()
    CensusPlus_JobQueue.g_TimeDatabase = nil;
	CensusPlus_JobQueue.g_TimeDatabase = {};
	CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_DRUID]		= 0;
	CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_HUNTER]		= 0;
	CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_MAGE]			= 0;
	CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_PRIEST]		= 0;
	CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_ROGUE]		= 0;
	CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_WARLOCK]	    = 0;
	CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_WARRIOR]	    = 0;
	CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_SHAMAN]		= 0;
	CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_PALADIN]	    = 0;
end
CensusPlus_Zero_g_TimeDatabase();


local g_FactionCheck = {};
g_FactionCheck[CENSUSPLUS_ORC]		= CENSUSPlus_HORDE;
g_FactionCheck[CENSUSPLUS_TAUREN]	= CENSUSPlus_HORDE;
g_FactionCheck[CENSUSPLUS_TROLL]	= CENSUSPlus_HORDE;
g_FactionCheck[CENSUSPLUS_UNDEAD]	= CENSUSPlus_HORDE;
g_FactionCheck[CENSUSPLUS_BLOODELF]	= CENSUSPlus_HORDE;
g_FactionCheck[CENSUSPLUS_DWARF]	= CENSUSPlus_ALLIANCE;
g_FactionCheck[CENSUSPLUS_GNOME]	= CENSUSPlus_ALLIANCE;
g_FactionCheck[CENSUSPLUS_HUMAN]	= CENSUSPlus_ALLIANCE;
g_FactionCheck[CENSUSPLUS_NIGHTELF]	= CENSUSPlus_ALLIANCE;
g_FactionCheck[CENSUSPLUS_DRAENEI]	= CENSUSPlus_ALLIANCE;


--- PTR debug messages
local channel = 0
local channelName = " "
local channelReady = false
local instanceID = 0
local language = nil -- nil = common for faction
local HortonBug = false
local HortonFingers = false
local HortonChannel = "Hortondebug"

local function HortonChatMsg(hotair)
	DEFAULT_CHAT_FRAME:AddMessage(hotair, 0.7, 0.5, 0.7)
end

local function HortonChannelMsg(hotair)
	SendChatMessage(hotair, "CHANNEL", language, channel)
	-- chattype = CHANNEL
	-- language = COMMON
	-- channel = channel
end

-- local says = HortonChannelMsg
local says = HortonChatMsg -- work around for incomplete work on Starter client sigh
local chat = HortonChatMsg

local function HortonChannelSetup()
	channel, channelName, instanceID = GetChannelName(HortonChannel)
	ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, channel)
	channelReady = true
	says("Horton finds his very own channel")
	says("Horton turned on the chatlog")
end

function CensusPlus_GetUniqueRealmName()

	local realmname = GetRealmName()
	local guid = UnitGUID("player")
    local realmid = string.match(guid, "^Player%-(%d+)")

	return realmid .. "_" .. realmname

end

-- Set up confirmation boxes
StaticPopupDialogs["CP_PURGE_CONFIRM"] = {
	text = CENSUSPLUS_PURGE_LOCAL_CONFIRM,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		CensusPlus_DoPurge()
	end,
	--  sound = "levelup2",
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1
}

-- Set up Continue after override box  .. no longer valid
StaticPopupDialogs["CP_CONTINUE_CENSUS"] = {
	text = CENSUSPlus_OVERRIDE_COMPLET_PAUSED,
	button1 = CENSUSPlus_CONTINUE,
	OnAccept = function()
		CPp.CensusPlusManuallyPaused = false
		CensusPlusTakeButton:SetText(CENSUSPLUS_PAUSE)
	end,
	--  sound = "levelup2",
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1
}


-- Insert a job at the end of the job queue
local function InsertJobIntoQueue(job)
	--CensusPlus_DumpJob( job )
	table.insert(CensusPlus_JobQueue, job)
end

-- Initialize the tables of constants for XP calculations
local function InitConstantTables()
	-- XP earned for killing
	for i = 1, MAX_CHARACTER_LEVEL, 1 do
		g_MobXPByLevel[i] = i
	end

	-- XP required to advance through the given level
	for i = 1, MAX_CHARACTER_LEVEL, 1 do
		g_CharacterXPByLevel[i] = ((8 * i * g_MobXPByLevel[i]) / 100) * 100
	end

	-- Total XP required to attain the given level
	local totalCharacterXP = 0
	for i = 1, MAX_CHARACTER_LEVEL, 1 do
		--g_TotalCharacterXPPerLevel[i] = totalCharacterXP;
		--totalCharacterXP = totalCharacterXP + g_CharacterXPByLevel[i];
		val = (i * 5) / MAX_CHARACTER_LEVEL
		g_TotalCharacterXPPerLevel[i] = math.exp(val)
	end
end


-- Return common letters found in zone names
-- only used for census splitting by zone.. not used
local function GetZoneLetters()
	return {"t", "d", "g", "f", "h", "b", "x", "gulch", "valley", "basin" };
end

-- Return common letters found in names, may override this for other languages
-- Worst case scenario is to do it for every letter in the alphabet
--[[
	see http://www.warcraftrealms.com/forum/viewtopic.php?t=4819&start=40
	Advantage: as seen from data sample
	removing the last 3 selectors "mkc" returned about same counts as current set..
	adding the "mkc" making the selector count the same increased found unique names by %0.17
	disavantage: as seen from data sample
	current selector will generates a duplicate name hit of 3.27 duplicates /unique name
	alternate selector will generate a duplicate name hit of 4.04 duplicates /unique name
	shortened alternate will generate duplicate name hit of 3.47 duplicates /unique name
]]
local function GetNameLetters()
	return { "a", "b", "c", "d", "e", "f", "g", "i", "o", "p", "r", "s", "t", "u", "y" }
end

local function GetNameLetters1()
	return {"a", "e", "r", "i", "n", "o", "l", "s", "t", "h", "d", "u", "m", "k", "c" }
end

local function GetNameLetters2()
	return {"a", "e", "r", "i", "n", "o", "l", "s", "t", "h", "d", "u"}
end

-- Called when the main window is shown
function CensusPlus_OnShow() -- referenced by CensusPlusClassic.xml
	-- Initialize if this is the first OnShow event
	if g_CensusPlusInitialized and g_VariablesLoaded then
		CensusPlus_UpdateView()
	end
end

-- Toggle hidden status
function CensusPlus_Toggle()
	if CensusPlusClassic:IsVisible() then
		CensusPlusClassic:Hide()
	else
		CensusPlusClassic:Show()
	end
end

-- Toggle options pane
-- referenced by CensusPlusClassic.xml
function CensusPlus_ToggleOptions(self)
    PlaySound(856, "Master")
    Settings.OpenToCategory("CensusPlusClassic") -- Open directly to our category
end

local function macroMessage()
    CPp.Msg("Please add: |cFFFFFFFF/run ManualWho()|r to your main ability macros to continue data collection!")
end

-- referenced by CensusPlusClassic.xml
function CensusPlus_OnLoad(self)
    -- Load the UI
    -- CensusPlus_CreateTemplates()
    C_Timer.After(30, macroMessage)
    CPp.Msg("Races: " .. CensusPlus_NumRaces .. " Classes: ".. CensusPlus_NumClasses)
    CPp.Msg("Wow major version:" .. tostring(CensusPlus_gameMajorVersion))
    CensusPlus_CreateMainFrameBorders()
    CensusPlus_CreateMainFrameButtons()

	-- Update the version number
	CensusPlusText:SetText(
		"CensusPlusClassic v" .. CensusPlus_VERSION .. CensusPlus_SubVersion
	)
	CensusPlusText2:SetText(CENSUSPLUS_UPLOAD)

	-- Init constant tables
	InitConstantTables()

	-- Register for events
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")

	-- Called once on load
	-- SLASH_CensusPlusVerbose1 = "/censusverbose";
	-- SlashCmdList["CensusPlusVerbose"] = CensusPlus_Verbose_toggle("alter");
	SLASH_CensusPlusCMD1 = "/CensusPlusClassic"
	SLASH_CensusPlusCMD2 = "/Census+"
	SLASH_CensusPlusCMD3 = "/Census"
	SlashCmdList["CensusPlusCMD"] = CensusPlus_Command

	CensusPlus_CheckForBattleground()

	--  Set up an empty frame for updates
	local updateFrame = CreateFrame("Frame")
	updateFrame:SetScript("OnUpdate", CensusPlus_OnUpdate)

	-- CensusPlusWhoButton:SetScript("OnClick", function(self, button, down)
	-- -- As we have not specified the button argument to SetBindingClick,
	-- -- the binding will be mapped to a LeftButton click.
	-- 	ManualWho()
	-- end)
end

function InitializeExperimental()
	hookWorldClicks = CensusPlus_Database["Info"]["UseWorldFrameClicks"]
	if hookWorldClicks then
        -- WorldFrame:EnableMouse(true)
		WorldFrame:HookScript("OnMouseDown", function(self, button)
			ManualWho()
		end)
        -- WorldFrame:HookScript("OnMouseUp", function(self, button)
        --     print("WorldFrame Clicked")
		-- 	ManualWho()
		-- end)

        -- for _, script in pairs({"OnMouseDown", "OnMouseUp", "OnEnter", "OnLeave"}) do
        --     if WorldFrame:HasScript(script) then
        --         print("WorldFrame supports", script)
        --     end
        -- end
	end
end

function CP_SplitJob(job)
    local minLevel = job.m_MinLevel
    local maxLevel = job.m_MaxLevel
    local race = job.m_Race
    local class = job.m_Class
    local zoneLetter = job.m_zoneLetter
    local letter = job.m_Letter

    -- CensusPlus_DumpJob(job)

    if (minLevel < maxLevel) then
        -- The level range is greater than a single level, so split it in half and submit the two jobs
        local pivot = floor((minLevel + maxLevel) / 2)
        local jobLower = CensusPlus_CreateJob(minLevel, pivot, nil, nil, nil)
        InsertJobIntoQueue(jobLower)
        local jobUpper = CensusPlus_CreateJob(pivot + 1, maxLevel, nil, nil, nil)
        InsertJobIntoQueue(jobUpper)
    else
        -- We cannot split the level range any more
        local factionGroup = UnitFactionGroup("player")
        local level = minLevel
        if (race == nil) then
            -- This job does not specify race, so split it that way, making jobs for each race]
            local thisFactionRaces = CensusPlus_GetFactionRaces(factionGroup)
            local numRaces = #thisFactionRaces
            for i = 1, numRaces, 1 do
                if (CENSUSPLUS_LIGHTFORGED ~= thisFactionRaces[i]) and (CENSUSPLUS_HIGHMOUNTAIN ~= thisFactionRaces[i]) then
                    local job =
                        CensusPlus_CreateJob(
                            level,
                            level,
                            thisFactionRaces[i],
                            nil,
                            nil
                        )
                    InsertJobIntoQueue(job)
                end
            end
        else
            if (class == nil) then
                -- This job does not specify class, so split it that way, making jobs for each class
                local thisRaceClasses = GetRaceClasses(race)
                local numClasses = #thisRaceClasses
                for i = 1, numClasses, 1 do
                    if CENSUSPLUS_DEMONHUNTER ~= thisRaceClasses[i] then
                        local job =
                            CensusPlus_CreateJob(
                                level,
                                level,
                                race,
                                thisRaceClasses[i],
                                nil
                            )
                        InsertJobIntoQueue(job)
                    end
                end
            else
                if (letter == nil) then
                    -- There are too many characters with a single level, class and race
                    -- The work around we are going to pursue is to check by name for a,e,i,o,r,s,t,u
                    local letters = {}
                    if CP_letterselect == 0 then
                        letters = GetNameLetters()
                    elseif CP_letterselect == 1 then
                        letters = GetNameLetters1()
                    elseif CP_letterselect == 2 then
                        letters = GetNameLetters2()
                    end

                    for i = 1, #letters, 1 do
                        local job =
                            CensusPlus_CreateJob(
                                level,
                                level,
                                race,
                                class,
                                letters[i]
                            )
                        InsertJobIntoQueue(job)
                    end
                    -- Block of code removed that isn't currently or ever used.. splitting by zone
                else
                    -- There are too many characters with a single level, class, race and letter, give up
                    local whoText = CensusPlus_CreateWhoText(g_CurrentJob)
                    if g_Verbose then
                        CPp.Msg(format(CENSUSPLUS_TOOMANY, whoText))
                    end
                end
            end
        end
    end
    
end


function CP_ProcessWhoEvent(query, result, complete)
	if (CPp.IsCensusPlusInProgress ~= true) then return end

	local numWhoResults = 0
	local cpdb_complete_flag = ""
	whoquery_answered = true

	numWhoResults = C_FriendList.GetNumWhoResults()

	if g_Verbose then
		CPp.Msg(
			CENSUSPLUS_WHOQUERY .. " " .. query .. ", " .. CENSUSPLUS_FOUND .. " " .. numWhoResults .. cpdb_complete_flag
		)
			--CPp.Msg(CENSUSPLUS_WHOQUERY.." "..query);
	end

	if (numWhoResults == 0) then
		--print("no results returned")
		local whoText = CensusPlus_CreateWhoText(g_CurrentJob)
		if whoText and whoText == query then
			g_WaitingForWhoUpdate = false
			whoquery_active = false
			whoquery_answered = false
		end
		-- remove job from the queue
		table.remove(CensusPlus_JobQueue)
		return
	end

	CensusPlus_ProcessWhoResults(result, numWhoResults)

	if (numWhoResults > MAX_WHO_RESULTS) then
        -- Record this as a failed query before handling the overflow
        RecordFailedQuery(g_CurrentJob)
		-- Who list is overflowed, split the query to make the return smaller
        CP_SplitJob(g_CurrentJob)
	else
	end

	local whoText = CensusPlus_CreateWhoText(g_CurrentJob)

	if whoText == query then
		g_WaitingForWhoUpdate = false
	end
end


-- CensusPlusClassic command
function CensusPlus_Command(param)
	local jcmdend = 0
	local jvalend = 0
	local jfolend = 0
	local command = nil
	local value = nil
	local nameval = nil
	local followon = nil
	local levelon = 0
	local _ = nil

	if (param ~= nil) then
		param = string.lower(param)
		_, jcmdend, command = string.find(param, "(%w+)")
		if (command == "options") then
			CensusPlus_ToggleOptions()
		elseif (command == "take") then
			CENSUSPLUS_TAKE_OnClick()
		elseif (command == "me") then
			CensusPlayerOnly = true
			CENSUSPLUS_TAKE_OnClick()
		elseif (command == "stop") then
			CENSUSPLUS_STOPCENSUS()
		elseif (command == "serverprune") then
			_, jvalend, value = string.find(param, "(%w+)", jcmdend + 1) -- alphanumeric selector used to warn of bad input
			if (value ~= nil) then
				value = tonumber(value)
				if (value ~= nil) then
					CENSUSPLUS_PRUNEData(value, 1) -- value isn't a number .. bad user input
				else
					CENSUSPLUS_PRUNEData(0, 1)
				end -- value is nil
			else
				CENSUSPLUS_PRUNEData(0, 1)
			end
		elseif (command == "verbose") then
			CensusPlus_Verbose_toggle("alter")
		elseif (command == "stealth") then
			CensusPlus_Stealth_toggle("alter")
		elseif (command == "prune") then
			_, jvalend, value = string.find(param, "(%w+)", jcmdend + 1) -- alphanumeric selector used to warn of bad input
			if (value ~= nil) then
				value = tonumber(value)
				if (value ~= nil) then
					CENSUSPLUS_PRUNEData(value, nil) -- value isn't a number .. bad user input
				else
					CENSUSPLUS_PRUNEData(30, nil)
				end -- value is nil
			else
				CENSUSPLUS_PRUNEData(30, nil)
			end
		elseif (command == "timer") then
			_, jvalend, value = string.find(param, "(%d+)", jcmdend + 1) -- decimal seletor works here, if bad input just reset timer
			if (value ~= nil) then
				value = tonumber(value)
			end
			CensusPlus_TimerSet(self, value, true)
		elseif (command == "who") then -- get 2nd term
			_, jvalend, nameval = string.find(param, "(%w+)", jcmdend + 1) --alphanumeric selector used to give warning of bad input
			if (nameval ~= nil) then -- nameval found non nil
				_, jfalend, followon = string.find(param, "(%a+)", jcmdend + 1) -- see if same match is found as alpha only
				if (nameval == followon) then -- alpha world so get 3rd term
					_, jfalend, followon =
						string.find(param, "(%w+)", jvalend + 1) --alphanumeric selector used to give warning of bad input
					if (followon == nil) then -- no 3rd term found
						CensusPlus_InternalWho(string.lower(nameval), nil) -- 3rd term found
					else
						levelon = tonumber(followon)
						CensusPlus_InternalWho(
							string.lower(nameval),
							string.lower(levelon)
						)
					end -- 2nd term is a number -- 3rd term is NOT a number
				else
					CPp.Msg(CENSUSPLUS_CMDERR_WHO2NUM)
				end -- 2nd term is nil -- 2nd term is ""
			else
				CPp.Msg(CENSUSPLUS_CMDERR_WHO2)
			end
		elseif (param == "debug") then
			if (HortonBug == false) then
				chat("Horton puts trunk in Rabbit hole and blows real hard")
				HortonChannelSetup()
				JoinTemporaryChannel(HortonChannel)
				LoggingChat(true)
				HortonBug = true
				says("Hello HortonChannel")
			else
				says("Horton turns off the chatlog")
				LoggingChat(false)
				HortonBug = false
			end
		else
			CensusPlus_DisplayUsage()
		end
	else
		CensusPlus_DisplayUsage()
	end
end



-- CensusPlusClassic Display Usage
function CensusPlus_DisplayUsage()
	CensusPlusClassic:Show()
	local stealthUsage = g_stealth
	g_stealth = false
	CPp.Msg(
		CENSUSPLUS_USAGE .. "\n  /CensusPlusClassic" .. CENSUSPLUS_OR .. "/Census+ " .. CENSUSPLUS_OR .. "/Census" .. CENSUSPLUS_AND .. CENSUSPLUS_HELP_0
	)
	CPp.Msg(
		"  /CensusPlusClassic " .. CENSUS_OPTIONS_VERBOSE .. CENSUSPLUS_HELP_1
	)
	CPp.Msg(
		"  /CensusPlusClassic " .. CENSUS_OPTIONS_STEALTH .. CENSUSPLUS_HELP_11
	)
	CPp.Msg(
		"  /CensusPlusClassic " .. CENSUSPLUS_BUTTON_OPTIONS .. CENSUSPLUS_HELP_2
	)
	CPp.Msg(
		"  /CensusPlusClassic " .. CENSUSPLUS_TAKE .. CENSUSPLUS_HELP_3
	)
	CPp.Msg(
		"  /CensusPlusClassic " .. CENSUSPLUS_STOP .. CENSUSPLUS_HELP_4
	)
	CPp.Msg(
		"  /CensusPlusClassic " .. CENSUSPLUS_PRUNE .. CENSUSPLUS_HELP_5
	)
	CPp.Msg("  /CensusPlusClassic serverprune" .. CENSUSPLUS_HELP_6)
	CPp.Msg("  /CensusPlusClassic who name" .. CENSUSPLUS_HELP_7)
	CPp.Msg("  /CensusPlusClassic who unguilded 70" .. CENSUSPLUS_HELP_8)
	CPp.Msg("  /CensusPlusClassic timer X " .. CENSUSPLUS_HELP_9)
	CPp.Msg("  /CensusPlusClassic me" .. CENSUSPLUS_HELP_10)
	g_stealth = stealthUsage
end

-- CensusPlus_InternalWho - will go through our local database and see if we have
-- any info on this person
function CensusPlus_InternalWho(search, level)
	g_InternalSearchName = search
	g_InternalSearchLevel = level
	g_InternalSearchCount = 0
	local realmName = CensusPlus_GetUniqueRealmName()

	CensusPlus_ForAllCharacters(
		realmName,
		UnitFactionGroup("player"),
		nil,
		nil,
		nil,
		nil,
		CensusPlus_InternalWhoResult
	)

	CPp.WhoMsg(
		CENSUSPLUS_FOUND_CAP .. g_InternalSearchCount .. CENSUSPLUS_PLAYERS
	)
end

function CensusPlus_InternalWhoResult(name, level, guild, race, class, lastSeen)
	lowerName = string.lower(name)
	level = string.lower(level)
	lowerGuild = string.lower(CensusPlus_SafeCheck(guild))
	if (g_InternalSearchName == "unguilded") then
		if (guild == "") then
			local doit = 1
			if (g_InternalSearchLevel ~= nil) then
				if (g_InternalSearchLevel ~= level) then
					doit = 0
				end
			end
			if (doit == 1) then
				local out =
					name .. " : " .. LEVEL .. " " .. level .. " " .. race .. " " .. " " .. class
				out = out .. CENSUSPLUS_LASTSEEN_COLON .. lastSeen
				CPp.WhoMsg(out)
				g_InternalSearchCount = g_InternalSearchCount + 1
			end
		end
		-- found someone!
	elseif (string.find(lowerName, g_InternalSearchName) or string.find(
		lowerGuild,
		g_InternalSearchName
	)) then
		local out =
			name .. " : " .. LEVEL .. " " .. level .. " " .. race .. " " .. " " .. class
		if (guild ~= "") then
			out = out .. " <" .. guild .. ">"
		end
		out = out .. CENSUSPLUS_LASTSEEN_COLON .. lastSeen
		CPp.WhoMsg(out)
		g_InternalSearchCount = g_InternalSearchCount + 1
	end
end


-- Minimize the window
-- referenced by CensusPlusClassic.xml
function CensusPlus_OnClickMinimize(self)
    if( CensusPlusClassic:IsVisible() ) then
	    --MiniCensusPlus:Show();
        CensusPlusClassic:Hide();
    end
end

-- Minimize the window
-- referenced by CensusPlusClassic.xml
function CensusPlus_OnClickMaximize(self)
	if MiniCensusPlus:IsVisible() then
		MiniCensusPlus:Hide()
		CensusPlusClassic:Show()
	end
end

-- Take or pause a census depending on current status
-- referenced by CensusPlusClassic.xml
function CENSUSPLUS_TAKE_OnClick(self)
	if CPp.IsCensusPlusInProgress then
		--CPp.Msg(CENSUSPLUS_ISINPROGRESS);
		CensusPlus_TogglePause()
	else
		CensusPlus_StartCensus()
	end
end

-- Display a tooltip for the take button
-- referenced by CensusPlusClassic.xml
function CENSUSPLUS_TAKE_OnEnter(self, motion)
	if (motion == true) then
		if CPp.IsCensusPlusInProgress then
			if CPp.CensusPlusManuallyPaused then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(CENSUSPLUS_UNPAUSECENSUS, 1.0, 1.0, 1.0)
				GameTooltip:Show()
			else
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(CENSUSPLUS_PAUSECENSUS, 1.0, 1.0, 1.0)
				GameTooltip:Show()
			end
		else
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(CENSUSPLUS_TAKECENSUS, 1.0, 1.0, 1.0)
			GameTooltip:Show()
		end
	-- frame created underneath cursor.. not cursor movement to frame
	else
	end
end

-- referenced by CensusPlusClassic.xml
function CENSUSPLUS_STOP_OnEnter(self, motion)
	if (motion == true) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(CENSUSPLUS_STOPCENSUS_TOOLTIP, 1.0, 1.0, 1.0)
		GameTooltip:Show()
	-- frame created underneath cursor.. not cursor movement to frame
	else
	end
end

-- referenced by CensusPlusClassic.xml
function CENSUSPLUS_MANUALWHO_OnEnter(self, motion)
	if (motion == true) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Issues manual who request.", 1.0, 1.0, 1.0)
		GameTooltip:Show()
	-- frame created underneath cursor.. not cursor movement to frame
	else
	end
end


function CensusPlus_TimerSet(self, minutes, ovrride)
	if minutes == nil then
		minutes = 30
	end
	if ovrride then
		CensusPlus_PerCharInfo["AutoCensusTimer"] = minutes * 60
		--print("CCO Timer = "..minutes)
		--print("AW timer = "..minutes)
	else
		CensusPlus_Database["Info"]["AutoCensusTimer"] = minutes * 60
	end
	--CPp.Msg( CENSUS_OPTIONS_AUTOCENSUS.." "..CENSUSPLUS_AUTOCENSUS_DELAYTIME .." ".. minutes);
end

local function CensusPlus_BackgroundAlpha(self,steps)
	CensusPlus_Database["Info"]["CPWindow_Transparency"] = steps
end

-- Pause the current census
function CensusPlus_TogglePause()
	if (CPp.IsCensusPlusInProgress == true) then
		if (CPp.CensusPlusManuallyPaused == true) then
			CensusPlusTakeButton:SetText(CENSUSPLUS_PAUSE)
			CPp.CensusPlusManuallyPaused = false
		else
			CensusPlusTakeButton:SetText(CENSUSPLUS_UNPAUSE)
			if g_Verbose then
				CPp.Msg(CENSUSPLUS_PAUSECENSUS)
			end

			CPp.CensusPlusManuallyPaused = true
			CensusPlayerOnly = false
		end
	end
end

-- Purge the database for this realm and faction
-- referenced by CensusPlusClassic.xml
function CENSUSPLUS_PURGE_OnClick()
	StaticPopup_Show ("CP_PURGE_CONFIRM");
end

-- CensusPlus_DoPurge
function CensusPlus_DoPurge()
	if (CensusPlus_Database["Servers"] ~= nil) then
		CensusPlus_Database["Servers"] = nil
	end
	CensusPlus_Database["Servers"] = {}
	CensusPlus_UpdateView()
	--CPp.Msg(CENSUSPLUS_PURGEMSG);

	if (CensusPlus_Database["Guilds"] ~= nil) then
		CensusPlus_Database["Guilds"] = nil
	end
	CensusPlus_Database["Guilds"] = {}

	if (CensusPlus_Database["TimesPlus"] ~= nil) then
		CensusPlus_Database["TimesPlus"] = nil
	end
	CensusPlus_Database["TimesPlus"] = {}

	if (CensusPlus_Profile ~= nil) then
		CensusPlus_Profile = nil
	end
	CensusPlus_Profile = {}

	if not (CPp.FirstLoad == true) then
		CPp.Msg(CENSUSPLUS_PURGEDALL)
	end
end

-- Take a CensusPlusClassic
function CensusPlus_StartCensus()
	CensusPlusTakeButton:SetText(CENSUSPLUS_PAUSE)

	--[[ work in progress - continue census run from last state on DC or valid Character stop restart.
         Determine if pre-existing jobqueue exists from running job that was DCed or paused and logged out.
         if exists that determine delay since last queue completion..
         if more then x time then dump queues and restart as new start else set below states to active run status and process existing queues.
     --]]

	-- used to trigger queue processing when OnUpdate
	g_FirstRun = true
	g_factionGroup = UnitFactionGroup("player")

    if g_factionGroup == CENSUSPlus_NEUTRAL then
        CPp.IsCensusPlusInProgress = false
        CPp.Msg(CENSUSPLUS_NOTINFACTION)
        return
    end

	local realm = ""
	local lastjobtimediff = 1
	local realmName = CensusPlus_GetUniqueRealmName()
	--print( "Prep for start");
	if (CensusPlus_JobQueue.CensusPlus_last_time and CensusPlus_JobQueue.CensusPlus_last_time > 1) then
		lastjobtimediff = time() - CensusPlus_JobQueue.CensusPlus_last_time
		--print( "got time");
		--print( lastjobtimediff);
	else
		CensusPlus_JobQueue.CensusPlus_last_time = 1000
		lastjobtimediff = time() - CensusPlus_JobQueue.CensusPlus_last_time
	end
	if not CensusPlus_JobQueue.CensusPlus_LoginRealm then
		CensusPlus_JobQueue.CensusPlus_LoginRealm = " "
		--print( "typed Realm");
	end
	if not CensusPlus_JobQueue.CensusPlus_LoginFaction then
		CensusPlus_JobQueue.CensusPlus_LoginFaction = " "
	end
	--print(lastjobtimediff);
	if (lastjobtimediff <= 300 and CensusPlus_JobQueue.CensusPlus_LoginFaction and CensusPlus_JobQueue.CensusPlus_LoginRealm and (CensusPlus_JobQueue.CensusPlus_LoginFaction == g_factionGroup) and (CensusPlus_JobQueue.CensusPlus_LoginRealm == realmName)) then
		--print ("continue last Census");
		local queue_entry_count = #CensusPlus_JobQueue
		--print (queue_entry_count);
		g_FirstRun = False
		--print ("Start new Census");
	else
		CensusPlus_JobQueue = {}
		CensusPlus_JobQueue.g_NumNewCharacters = 0
		CensusPlus_JobQueue.g_NumUpdatedCharacters = 0
		CensusPlus_Zero_g_TimeDatabase()
		CensusPlus_JobQueue.g_TempCount = nil
		CensusPlus_JobQueue.g_TempCount = {}
	end

	CensusPlus_UpdateView()
	if (g_factionGroup == nil or g_factionGroup == CENSUSPlus_NEUTRAL) then
		CPp.Msg(CENSUSPLUS_NOTINFACTION)
		CPp.LastCensusRun = time()
	--return;
	elseif CPp.IsCensusPlusInProgress then
		--if( CPp.CensusPlusManuallyPaused == true ) then
		--  CPp.CensusPlusManuallyPaused = false;
		--  CensusPlusPauseButton:SetText( CENSUSPLUS_PAUSE );
		--else
		-- D.o not initiate a new CensusPlusClassic whi.le one is in progress
		CPp.Msg(
			"Census in progress but this message should not have shown"
		)
		  --return
		--end
	elseif g_CurrentlyInBG then
		CPp.LastCensusRun = time() - 600
		if not g_CurrentlyInBG_Msg then
			CPp.Msg(CENSUSPLUS_ISINBG)
			g_CurrentlyInBG_Msg = true
		end
	else
		--
		--  Set a timer
		--
		g_CensusPlus_StartTime = time()
		--
		-- Initialize the job queue and counters
		--
		CPp.Msg(CENSUSPLUS_TAKINGONLINE)

		local realmName = CensusPlus_GetUniqueRealmName()
		CensusPlus_JobQueue.CensusPlus_LoginRealm = realmName
		CensusPlus_JobQueue.CensusPlus_LoginFaction = g_factionGroup
		if (HortonBug == true) then
			says("after check local realm = " .. realmName)
		end

		if CensusPlayerOnly then
			if (UnitLevel("player") >= MIN_CHARACTER_LEVEL) then
				local meplayer = GetUnitName("player")
				local job =
					CensusPlus_CreateJob(
						MIN_CHARACTER_LEVEL,
						MAX_CHARACTER_LEVEL,
						nil,
						nil,
						meplayer
					)
				InsertJobIntoQueue(job)
				CPp.IsCensusPlusInProgress = true
				g_WaitingForWhoUpdate = false
				CPp.CensusPlusManuallyPaused = false

				local hour, minute = GetGameTime()
				g_TakeHour = hour
				g_ResetHour = true

			-- queue who for player into job que
			elseif (UnitLevel("player") < MIN_CHARACTER_LEVEL) then
				CPp.Msg("Player is below level 20")
				CensusPlayerOnly = false
			elseif CPp.IsCensusPlusInProgress then
				CPp.Msg(CENSUSPLUS_ISINPROGRESS)
				CensusPlayerOnly = false
			end
		else
			if (CensusPlus_Database["Info"]["CensusButtonAnimi"] == true) then
				CensusButton:SetNormalFontObject(GameFontNormalSmall)
				CensusButton:SetText(MAX_CHARACTER_LEVEL)
			end

			if g_FirstRun then
				CensusPlus_Load_JobQueue()
			end

			CPp.IsCensusPlusInProgress = true
			g_WaitingForWhoUpdate = false
			CPp.CensusPlusManuallyPaused = false

			local hour, minute = GetGameTime()
			g_TakeHour = hour
			g_ResetHour = true
		end
	end
end


-- First we load the stack with our jobs... First in last out
function CensusPlus_Load_JobQueue()
	-- first load queue with jobs in increment of 10 from 1-10 thru max_character_level-19 - max_character_level-10
	for counter = MIN_CHARACTER_LEVEL / 10, floor(
		MAX_CHARACTER_LEVEL / 10
	) - 1, 1 do
		local job =
			CensusPlus_CreateJob(counter * 10, counter * 10 + 9, nil, nil, nil)
		InsertJobIntoQueue(job)
	end
	-- next to last job to load is Max_character_level-9 thrun Max_character_level-1  if Max_character_level modulo 10 = 0
	local job =
		CensusPlus_CreateJob(
			MAX_CHARACTER_LEVEL - 9,
			MAX_CHARACTER_LEVEL - 1,
			nil,
			nil,
			nil
		)
	InsertJobIntoQueue(job)

	-- last job to load in last in first out queus is MAX_CHARACTER_LEVEL to MAX_CHARACTER_LEVEL
	-- this is one job that will almost always en.d up having to be broken up and reloaded (depending on realm population)
	local job =
		CensusPlus_CreateJob(
			MAX_CHARACTER_LEVEL,
			MAX_CHARACTER_LEVEL,
			nil,
			nil,
			nil
		)
	InsertJobIntoQueue(job)

	--for counter = 60, MAX_CHARACTER_LEVEL, 1  do
	--  local job = CensusPlus_CreateJob( counter, counter, nil, nil, nil );
	--  InsertJobIntoQueue(job);
	--end

	--	Test inserts
	--local job = CensusPlus_CreateJob( 11, 12, "Troll", nil, nil );
	--InsertJobIntoQueue(job);
end

-- Stop a CensusPlusClassic
-- referenced by CensusPlusClassic.xml
function CENSUSPLUS_STOPCENSUS()
	if CPp.IsCensusPlusInProgress then
		CensusPlusTakeButton:SetText(CENSUSPLUS_TAKE)
		CPp.CensusPlusManuallyPaused = false
		whoquery_answered = false
		whoquery_active = false

		CensusPlusScanProgress:SetText(CENSUSPLUS_SCAN_PROGRESS_0)

		CensusPlus_DisplayResults()
		CensusPlus_JobQueue = {}

		--  Clean up the times
		CENSUSPLUS_PRUNETimes()
	else
		CPp.Msg(CENSUSPLUS_NOCENSUS)
	end

	-- Add revert CensusButton back to defauit
	CensusButton:SetNormalFontObject(GameFontNormal)
	CensusButton:SetText("C+")
end

function CENSUSPLUS_MANUALWHO()
	-- print("istsecure() = ", issecure())
	ManualWho()
end

-- Display Census results
function CensusPlus_DisplayResults()
	--
	-- We are all done, report our results
	--
	CPp.IsCensusPlusInProgress = false
	CensusPlusScanProgress:SetText(CENSUSPLUS_SCAN_PROGRESS_0)
	g_Consecutive = g_Consecutive + 1
	CensusPlusConsecutive:SetText(format(CENSUSPLUS_CONSECUTIVE, g_Consecutive))

	--
	--  Finish our timer
	--
	local total_time = time() - g_CensusPlus_StartTime
	local realmslisttext = ""
	if not g_stealth then
		--print( CensusPlus_JobQueue.g_NumNewCharacters);
		--print( CensusPlus_JobQueue.g_NumUpdatedCharacters);
		CPp.Msg(
			format(
				CENSUSPLUS_FINISHED,
				CensusPlus_JobQueue.g_NumNewCharacters,
				CensusPlus_JobQueue.g_NumUpdatedCharacters,
				SecondsToTime(total_time)
			)
		)
		--print( CP_g_queue_count);
		if (CP_g_queue_count > 0) then
			local avg_Time_per_que = total_time / CP_g_queue_count
			--print( avg_Time_per_que);
		end

		realmslisttext = string.sub(realmslisttext, 3)
		ChatFrame1:AddMessage(realmslisttext, 1.0, 0.3, 0.1)
		ChatFrame1:AddMessage(CENSUSPLUS_UPLOAD, 0.1, 1.0, 1.0)
	end
	CensusPlus_UpdateView()
	CPp.LastCensusRun = time()
	CensusPlus_JobQueue.g_NumNewCharacters = 0
	CensusPlus_JobQueue.g_NumUpdatedCharacters = 0
	CensusPlusTakeButton:SetText(CENSUSPLUS_TAKE)
end

-- Create a who command text for the input job
function CensusPlus_CreateWhoText(job)
	local whoText = ""
	local race = job.m_Race
	local locale = GetLocale()
	if (race ~= nil) then
		if (locale == "ruRU") then
			whoText = whoText .. ' р-"' .. race .. '"'
		else
			whoText = whoText .. ' r-"' .. race .. '"'
		end
	end

	local class = job.m_Class
	if (class ~= nil) then
		if (locale == "ruRU") then
			whoText = whoText .. ' к-"' .. class .. '"'
		else
			whoText = whoText .. ' c-"' .. class .. '"'
		end
	end

	local letter = job.m_Letter
	if (letter ~= nil) then
		if (locale == "ruRU") then
			whoText = whoText .. " и-" .. letter
		else
			whoText = whoText .. " n-" .. letter
		end
	end

	local minLevel = tostring(job.m_MinLevel)
	if (minLevel == nil) then
		minLevel = 1
	end
	local maxLevel = job.m_MaxLevel
	if (maxLevel == nil) then
		maxLevel = MAX_CHARACTER_LEVEL
	end
	whoText = whoText .. " " .. minLevel .. "-" .. maxLevel

	local zoneLetter = job.m_zoneLetter
	if (zoneLetter ~= nil) then
		if (locale == "ruRU") then
			whoText = whoText .. " з-" .. zoneLetter
		else
			whoText = whoText .. " z-" .. zoneLetter
		end
	end

	return whoText
end

-- Create a job
function CensusPlus_CreateJob(minLevel, maxLevel, race, class, letter)
	local job = {}
	job.m_MinLevel = minLevel
	job.m_MaxLevel = maxLevel
	job.m_Race = race
	job.m_Class = class
	job.m_Letter = letter

	-- CensusPlus_DumpJob(job)

	return job
end

-- Debug function do dump a job
function CensusPlus_DumpJob(job)
	local whoText = ""
	local race = job.m_Race
	if (race ~= nil) then
		whoText = whoText .. " R: " .. race
	end

	local class = job.m_Class
	if (class ~= nil) then
		whoText = whoText .. " C: " .. class
	end

	local letter = job.m_Letter
	if (letter ~= nil) then
		whoText = whoText .. " N: " .. letter
	end

	local minLevel = job.m_MinLevel
	if (minLevel ~= nil and minLevel ~= 0) then
		whoText = whoText .. " min: " .. minLevel
	end

	local maxLevel = job.m_MaxLevel
	if (maxLevel ~= nil and maxLevel ~= 0) then
		whoText = whoText .. " max: " .. maxLevel
	end

	local zoneLetter = job.m_zoneLetter
	if (zoneLetter ~= nil) then
		whoText = whoText .. " Z: " .. zoneLetter
	end

	CPp.Msg( "JOB DUMP: " .. whoText );
end

local whoMsg

-- Called on events
-- referenced by CensusPlusClassic.xml
function CensusPlus_OnEvent(self, event, ...)
	local arg1, arg2, arg3, arg4 = ...
	if (arg1 == nil) then
		arg1 = "nil"
	end
	if (arg2 == nil) then
		arg2 = "nil"
	end
	if (arg3 == nil) then
		arg3 = "nil"
	end
	if (arg4 == nil) then
		arg4 = "nil"
	end

	-- If we have not been initialized,  nothing
	if (g_CensusPlusInitialized == false) then
		if ((event == "ADDON_LOADED") and (arg1 == "CensusPlusClassic")) then
			self:UnregisterEvent("ADDON_LOADED") -- need this or we get hit on all preceeding addon loaded.. including the LOD's
			--  Initialize our variables
			g_addon_loaded = true
			--print("Addon Loaded")
			return
		end
		if (event == "PLAYER_ENTERING_WORLD") then
			g_player_loaded = true
			--print("Player in world")
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")
			if g_addon_loaded and g_player_loaded then
				CensusPlus_InitializeVariables()
				InitializeExperimental()
			end
		end
	end

	-- WHO_LIST_UPDATE
	if (event == "WHO_LIST_UPDATE") then
		CensusPlusClassic:UnregisterEvent("WHO_LIST_UPDATE")
		C_FriendList.SetWhoToUi(false)
		if WhoFrame:IsShown() then
		  FriendsFrameCloseButton:Click()
		end
    FriendsFrame:RegisterEvent("WHO_LIST_UPDATE")
		CP_ProcessWhoEvent(whoMsg)
	end

	if (event == "TRAINER_SHOW" or event == "MERCHANT_SHOW" or event == "TRADE_SHOW" or event == "GUILD_REGISTRAR_SHOW" or event == "AUCTION_HOUSE_SHOW" or event == "BANKFRAME_OPENED" or event == "QUEST_DETAIL") then
		-- print(" Event triggered = " .. event)
		if CPp.IsCensusPlusInProgress then
			g_CensusPlusPaused = true
		end
	elseif (event == "TRAINER_CLOSED" or event == "MERCHANT_CLOSED" or event == "TRADE_CLOSED" or event == "GUILD_REGISTRAR_CLOSED" or event == "AUCTION_HOUSE_CLOSED" or event == "BANKFRAME_CLOSED" or event == "QUEST_FINISHED") then
		-- print(" Event triggered = " .. event)
		if CPp.IsCensusPlusInProgress then
			g_CensusPlusPaused = false
		end

	--[[
	-- Guild roster info not ready for release
	elseif (event == "GUILD_ROSTER_UPDATE") th.en

		--  Process Guild info
		--CPp.Msg( " UPDATE GUILD " );
		if(not CP_updatingGuild ) th.en
			CP_updatingGuild  = 1;
			CensusPlus_ProcessGuildResults();
			CP_updatingGuild  = nil;
		end

	elseif (( event == "ADDON_LOADED") and (arg1 == "CensusPlusClassic")) then
		self:UnregisterEvent("ADDON_LOADED")   -- need this or we get hit on all preceeding addon loaded.. including the LOD's

		--  Initialize our variables
		CensusPlus_InitializeVariables()
	--]]

	elseif (event == "ZONE_CHANGED_NEW_AREA") then
		--  We need to check to see if we entered a battleground
		CensusPlus_CheckForBattleground()
	elseif (event == "UPDATE_BATTLEFIELD_STATUS") then
		CensusPlus_UpdateBattleGroundInfo()
	end
end

-- ProcessTarget --  called when UNIT_FOCUS event is fired
function CensusPlus_ProcessTarget(unit)
	if (not UnitIsPlayer(unit) or UnitIsUnit(unit, "player")) then
		return -- bail out on non-player unit or unit focus on self
	end

	local sightingData = {}
	sightingData = CensusPlus_CollectSightingData(unit)

	if (sightingData == nil or sightingData.faction == nil or sightingData.faction == CENSUSPlus_NEUTRAL) then
		-- worthless Neutral
		return
	end

	if (sightingData.level < 1) then
		--	Run away, Run Away.. Uncountable DEATH
		return
	end

	if (sightingData ~= nil and (sightingData.faction == CENSUSPlus_ALLIANCE or sightingData.faction == CENSUSPlus_HORDE)) then
		if (sightingData.guild == nil) then
			sightingData.guild = ""
			-- RGK testing [GUILD]
			sightingData.guildRankName = ""
			sightingData.guildRankIndex = ""
			--RGK endblock
		else
			sightingData.guild =
				PTR_Color_ProblemRealmGuilds_check(sightingData.guild)
		end
		--
		-- Get the portion of the database for this server
		--
		realmName = CensusPlus_GetUniqueRealmName()

		local realmDatabase = CensusPlus_Database["Servers"][realmName]
		if (realmDatabase == nil) then
			CensusPlus_Database["Servers"][realmName] = {}
			realmDatabase = CensusPlus_Database["Servers"][realmName]
		end

		-- Get the portion of the database for this faction
		local factionDatabase = realmDatabase[sightingData.faction]
		if (factionDatabase == nil) then
			realmDatabase[sightingData.faction] = {}
			factionDatabase = realmDatabase[sightingData.faction]
		end

		-- Get racial database
		local raceDatabase = factionDatabase[sightingData.race]
		if (raceDatabase == nil) then
			factionDatabase[sightingData.race] = {}
			raceDatabase = factionDatabase[sightingData.race]
		end

		-- Get class database
		local classDatabase = raceDatabase[sightingData.class]
		if (classDatabase == nil) then
			raceDatabase[sightingData.class] = {}
			classDatabase = raceDatabase[sightingData.class]
		end

		sightingData.name = PTR_Color_ProblemNames_check(sightingData.name)

		--
		local entry = classDatabase[sightingData.name]
		if (entry == nil) then
			classDatabase[sightingData.name] = {}
			entry = classDatabase[sightingData.name]
		end

		sightingData.lastSeen = CensusPlus_DetermineServerDate() .. ""

		--
		-- Update the information
		--
		entry[1] = sightingData.level
		entry[2] = sightingData.guild
		entry[3] = sightingData.lastSeen
		entry[4] =
			checksum:generate(
				realmName .. sightingData.faction .. sightingData.race .. sightingData.class .. sightingData.name .. sightingData.level .. sightingData.guild .. sightingData.lastSeen .. sightingData.sex
			)
		entry[5] = sightingData.sex
	end
end


-- Gather targeting data
function CensusPlus_CollectSightingData(unit)
	if (UnitIsPlayer(unit) and UnitName(unit) ~= "Unknown") then
		-- create the return structure as non-nil fields
		local ret = {}
		local _ = nil
		ret.name = ""
		ret.realm = ""
		ret.relationship = ""
		ret.race = ""
		ret.level = 0
		ret.sex = 1
		ret.class = ""
		ret.guild = ""
		ret.guildrealm = ""
		ret.faction = ""

		-- now populate the return structure
		ret.name, ret.realm = UnitName(unit) -- returns realm also Y +?
		ret.relationship = UnitRealmRelationship(unit) -- compares against self returns LE_REALM_RELATION_VIRTUAL|LE_REALM_RELATION_COALESCED|LE_REALM_RELATION_SAME
		if ((ret.realm == nil) or ret.relationship == 1) then
			ret.realm = CensusPlus_GetUniqueRealmName()
		end
		ret.level = UnitLevel(unit) -- a number  YNum
		ret.sex = UnitSex(unit) -- a number 2=male 3=female  YNum
		ret.race, _ = UnitRace(unit) -- localized , non Y + Y non is english race treated as one word.. i.e. Blood Elf  Bloodelf
		ret.class, _ = UnitClass(unit) -- localized ,non (warning if npc the npc name is returned!) y + y  Monk  MONK
		ret.guild, ret.guildRankName, ret.guildRankIndex = GetGuildInfo(unit) -- ? + ? +Ynum=0?
		--[Note] getGuildinfo call does return all of the above.. or if not valid nil or zero for the index
		if (ret.guild == nil) then
			ret.guild = ""
			ret.guildrealm = ""
		end
		if (ret.guildrealm == nil) then
			if (ret.guild == "") then
				ret.guildrealm = ""
			else
				ret.guildrealm = CensusPlus_GetUniqueRealmName()
			end
		end
		ret.faction, _ = UnitFactionGroup(unit)
		return ret
	else
		return nil
	end
end

-- Initialize our primary save variables --  called when CensusPlusClassic ADDON_LOADED event is fired
function CensusPlus_InitializeVariables()
	if (CensusPlus_Database["Servers"] == nil) then
		CensusPlus_Database["Servers"] = {}
	end

	if (CensusPlus_Database["Times"] ~= nil) then
		CensusPlus_Database["Times"] = nil
	end

	if (CensusPlus_Database["TimesPlus"] == nil) then
		CensusPlus_Database["TimesPlus"] = {}
	end

	--  Make sure info is last so it will be first in the output so we can grab the version number
	if (CensusPlus_Database["Info"] == nil) then
		CensusPlus_Database["Info"] = {}
	end
	if (CensusPlus_PerCharInfo["Version"] == nil) then
		CensusPlus_PerCharInfo["Version"] = {}
	end

	-- V 6.0.1 to 6.1.0 database purge
	if (CensusPlus_Database["Info"]["Version"] ~= nil) then
		g_InterfaceVersion = CensusPlus_Database["Info"]["Version"]
		-- keep left V.v to compare with V.v in code
		local _, cpsubset = string.find(g_InterfaceVersion, "%.")
		local _, cpsubset2 = string.find(g_InterfaceVersion, "%.", cpsubset + 1)
		g_InterfaceVersion = string.sub(g_InterfaceVersion, 1, cpsubset2 - 1)
		--		print("found interface version "..g_InterfaceVersion)
		local _, cpsubset = string.find(CensusPlus_VERSION, "%.")
		local _, cpsubset2 = string.find(CensusPlus_VERSION, "%.", cpsubset + 1)
		local CensusPlus_Version_subset =
			string.sub(CensusPlus_VERSION, 1, cpsubset2 - 1)
		--		print("coded interface version "..CensusPlus_Version_subset)
		if (g_InterfaceVersion ~= CensusPlus_Version_subset) then
			CensusPlus_Database["Info"] = {}
			CensusPlus_PerCharInfo = nil
			CensusPlus_PerCharInfo = {}
			CensusPlus_PerCharInfo["Version"] = CensusPlus_VERSION
			CensusPlus_DoPurge()
			g_wasPurged = true
			CPp.Msg(CENSUSPLUS_OBSOLETEDATAFORMATTEXT)
		end
	end
	CPp.FirstLoad = true

	CensusPlus_Database["Info"]["Version"] = CensusPlus_VERSION

	local g_templang = GetLocale()
	if (CensusPlus_Database["Info"]["ClientLocale"] ~= g_templang) then
		-- Client language has been changed must purge
		CensusPlus_DoPurge()
		g_wasPurged = true
		CPp.Msg(CENSUSPLUS_LANGUAGECHANGED)
	end
	CensusPlus_Database["Info"]["ClientLocale"] = GetLocale()
	CensusPlusLocaleName:SetText( format(CENSUSPLUS_LOCALE, CensusPlus_Database["Info"]["ClientLocale"]) )

	CensusPlus_Database["Info"]["LoginServer"] = GetCVar("portal")
	CensusPlus_Database["Info"]["LogVer"] = CensusPlus_VERSION_FULL

	local wowVersion, wowBuild = GetBuildInfo()
	wowVersion = format("%s (%s)", wowVersion, wowBuild)

	CensusPlus_Database["Info"]["wowVersion"] = wowVersion
	CensusPlus_Database["Info"]['versionChecksum'] = checksum:generate(CensusPlus_VERSION_FULL..wowVersion)

	if (CensusPlus_Database["Info"]["AutoCensus"] == nil) then
		CensusPlus_Database["Info"]["AutoCensus"] = true
	end
	if (CensusPlus_Database["Info"]["Verbose"] == nil) then
		CensusPlus_Database["Info"]["Verbose"] = false
	end
	if (CensusPlus_Database["Info"]["Stealth"] == nil) then
		CensusPlus_Database["Info"]["Stealth"] = false
	end
	if (CensusPlus_Database["Info"]["PlayFinishSound"] == nil) then
		CensusPlus_Database["Info"]["PlayFinishSound"] = false
	end
	if (CensusPlus_Database["Info"]["SoundFile"] == nil) then
		CensusPlus_Database["Info"]["SoundFile"] = g_FinishSoundNumber
	end

	if (CensusPlus_Database["Info"]["AutoCensusTimer"] == nil) then
		CensusPlus_Database["Info"]["AutoCensusTimer"] = 1800
	end

	if (CensusPlus_JobQueue["CensusPlus_last_time"] == nil) then
		CensusPlus_JobQueue["CensusPlus_last_time"] = time() - (CPp.AutoStartTimer *60)
	end

	if (CensusPlus_JobQueue["CensusPlus_LoginRealm_last"] == nil) then
		CensusPlus_JobQueue["CensusPlus_LoginRealm_last"] = ""
	end

	if (CensusPlus_JobQueue["CensusPlus_LoginFaction_last"] == nil) then
		CensusPlus_JobQueue["CensusPlus_LoginFaction_last"] = ""
	end

	if (CensusPlus_Database["Info"]["CPWindow_Transparency"] == nil) then
		CensusPlus_Database["Info"]["CPWindow_Transparency"] = 0.5
	end

	if (CensusPlus_Database["Info"]["CensusButtonShown"] == nil) then
		CensusPlus_Database["Info"]["CensusButtonShown"] = true
	end

    -- print("Turning on CensusButtonFrame", CensusPlus_Database["Info"]["CensusButtonShown"])
	if (CensusPlus_Database["Info"]["CensusButtonShown"] == true) then
		CensusButtonFrame:Show()
	else
		CensusButtonFrame:Hide()
	end

	if (CensusPlus_Database["Info"]["CensusButtonAnimi"] == nil) then
		CensusPlus_Database["Info"]["CensusButtonAnimi"] = true
	end

	if (CensusPlus_Database["Info"]["UseLogBars"] == nil) then
		CensusPlus_Database["Info"]["UseLogBars"] = true
	end

	if (CensusPlus_Database["Info"]["UseWorldFrameClicks"] == nil) then
		CensusPlus_Database["Info"]["UseWorldFrameClicks"] = true
	end

	--CensusPlusSetCheckButtonState()
	CPp.Msg(" v" .. CensusPlus_VERSION .. CENSUSPLUS_MSG1)
    CPp.Msg("Races: " .. CensusPlus_NumRaces .. " Classes: ".. CensusPlus_NumClasses)

	g_VariablesLoaded = true

	--CensusPlus_CheckTZ();
	InitConstantTables()

	g_CensusPlusInitialized = true

	--  If we are in a guild, attempt to gather the guild roster data
	--	if (IsInGuild()) then
	--		GuildRoster();
	--	end

	--  Prune times if we have too many
	CENSUSPLUS_PRUNETimes()

	--
	CensusPlus_Unhandled = nil
	CensusPlus_Unhandled = {}

	CPp.Options:CensusPlusBlizzardOptions()
	CPp.Options:CensusPlusSetCheckButtonState()
	CPp.FirstLoad = false -- main table initialized and options initialized

end


function CensusPlus_AutoStart()
    local currentFaction = UnitFactionGroup("player")
    g_factionGroup = currentFaction
    if currentFaction == CENSUSPlus_NEUTRAL then
        --  We are not in a faction, so we cannot run a census
        CPp.AutoCensus = false
        CPp.Msg(CENSUSPLUS_NOTINFACTION)
        return
    end

	local currentRealm = CensusPlus_GetUniqueRealmName()
	local lastRealm = CensusPlus_JobQueue["CensusPlus_LoginRealm_last"]
	local lastFaction = CensusPlus_JobQueue["CensusPlus_LoginFaction_last"]
	local lastRun = CensusPlus_JobQueue["CensusPlus_last_time"]

	if (g_wasPurged or currentRealm ~= lastRealm or currentFaction ~= lastFaction or (lastRun < time() - (CPp.AutoStartTimer * 60))) then
		CENSUSPLUS_TAKE_OnClick()
	end

end


-- referenced by CensusPlusClassic.xml
function CensusPlus_OnUpdate()
    if g_verbose then
        CPp.Msg("CensusPlus_OnUpdate")
    end
	if g_FirstRun then
		CensusButton:SetText("C+")
		if (g_VariablesLoaded and not CPp.IsCensusPlusInProgress and CPp.AutoCensus == true) then
			CensusPlus_AutoStart()
		end
	elseif (g_VariablesLoaded and not CPp.IsCensusPlusInProgress and CPp.AutoCensus == true and (CPp.LastCensusRun < time() - (CPp.AutoStartTimer * 60))) then
		CENSUSPLUS_TAKE_OnClick()
	end
	if (CPp.IsCensusPlusInProgress and not g_CensusPlusPaused and not CPp.CensusPlusManuallyPaused) then

		--  update our progress
		local numJobs = #CensusPlus_JobQueue
		if (numJobs > 0) then
            local currentJob = CensusPlus_JobQueue[numJobs]
            if WouldQueryFail(currentJob) then
                table.remove(CensusPlus_JobQueue)
                CP_SplitJob(currentJob)
                CensusPlus_OnUpdate()
            end
			CensusPlusScanProgress:SetText(
				format(
					CENSUSPLUS_SCAN_PROGRESS,
					numJobs,
					CensusPlus_CreateWhoText(currentJob)
				)
			)
		end

		if (not whoquery_active or g_FirstRun) then
			--ok to request next query
			whoquery_answered = false

			-- Determine if there is any more work to
			if (numJobs > 0) then
				-- Send the job and remove it later after it is processed in CP_ProcessWhoEvent (Lib-Who callback)
				local job = CensusPlus_JobQueue[numJobs]
				local whoText = CensusPlus_CreateWhoText(job)
				g_FirstRun = false

				--  Zap our current job
				g_CurrentJob = nil

				g_CurrentJob = job
				g_WaitingForWhoUpdate = true

				CensusPlus_SendWho(whoText)
				g_WhoAttempts = 0
				g_LastOnUpdateTime = GetTime()
				CensusPlus_JobQueue.CensusPlus_last_time = time()
			else
				-- We are all done, hide the friends frame and report our results
				if CensusPlus_PerCharInfo["PlayFinishSound"] then
					if (CensusPlus_PerCharInfo["SoundFile"] == nil) then
						g_FinishSoundNumber = 1
					else
						g_FinishSoundNumber =
							CensusPlus_PerCharInfo["SoundFile"]
					end
					local CPSoundFile =
						"Interface\\AddOns\\CensusPlusClassic\\sounds\\CensusComplete" .. g_FinishSoundNumber .. ".ogg"
					local willplay = PlaySoundFile(CPSoundFile, "Master")
					if not willplay then
						local CPSoundFile =
							"Interface\\AddOns\\CensusPlusClassic\\sounds\\CensusComplete" .. g_FinishSoundNumber .. ".mp3"
						PlaySoundFile(CPSoundFile, "Master")
					end
				elseif ((CensusPlus_PerCharInfo["PlayFinishSound"] == nil) and CensusPlus_Database["Info"]["PlayFinishSound"]) then
					if (CensusPlus_Database["Info"]["SoundFile"] == nil) then
						g_FinishSoundNumber = 1
					else
						g_FinishSoundNumber =
							CensusPlus_Database["Info"]["SoundFile"]
					end
					local CPSoundFile =
						"Interface\\AddOns\\CensusPlusClassic\\sounds\\CensusComplete" .. g_FinishSoundNumber .. ".ogg"
					local willplay = PlaySoundFile(CPSoundFile, "Master")
					if not willplay then
						local CPSoundFile =
							"Interface\\AddOns\\CensusPlusClassic\\sounds\\CensusComplete" .. g_FinishSoundNumber .. ".mp3"
						PlaySoundFile(CPSoundFile, "Master")
					end
				end
				if not CensusPlayerOnly then
					CensusPlus_DoTimeCounts()
				end
				CensusPlayerOnly = false
				CensusPlus_JobQueue.CensusPlus_LoginRealm_last = CensusPlus_JobQueue.CensusPlus_LoginRealm
				CensusPlus_JobQueue.CensusPlus_LoginFaction_last = CensusPlus_JobQueue.CensusPlus_LoginFaction
				CensusPlus_JobQueue.CensusPlus_LoginRealm = ""
				CensusPlus_JobQueue.CensusPlus_LoginFaction = ""
				CensusPlus_JobQueue.g_TempCount = {}
				CensusPlus_DisplayResults()

				-- Add CensusButton reset
				CensusButton:SetText("C+")
			end
		elseif whoquery_answered then
			local now = GetTime()
			local delta = now - g_LastOnUpdateTime
			if (delta > CensusPlus_UPDATEDELAY2) then
				g_LastOnUpdateTime = now
				print(CENSUSPLUS_TOOSLOW) -- >10 seconds to finish query!
			end
		else
			local now = GetTime()
			local delta2 = now - g_LastOnUpdateTime
			if (delta2 > CensusPlus_UPDATEDELAY) then
				g_LastOnUpdateTime = now
				--
				-- Resend /who command
				--
				g_WhoAttempts = g_WhoAttempts + 1
				local whoText = CensusPlus_CreateWhoText(g_CurrentJob)
				if (CensusPlus_PerCharInfo["Verbose"] == true) then
					CPp.Msg(CENSUSPLUS_WAITING) -- this hasn't shown up in testing yet.
				end
				if (g_WhoAttempts < 2) then
					CensusPlus_SendWho(whoText)
				else
					g_WaitingForWhoUpdate = false
				end
			end
			--return -- server hasn't returned query.. so wait for next frame update
		end
	end
end


-- Take final tally
function CensusPlus_DoTimeCounts()
	-- first zero counts in g_TimeDatabase each realm/faction
	--CensusPlus_JobQueue.g_NumUpdatedCharacters = 0;
	--CensusPlus_JobQueue.g_NumNewCharacters = 0;
	local factionGroup = UnitFactionGroup("player")

	local realmName = CensusPlus_GetUniqueRealmName()


	CensusPlus_Zero_g_TimeDatabase()
	local thisFactionClasss = CensusPlus_GetFactionClasses(factionGroup)
	local numClasses = #thisFactionClasss
	for i = 1, numClasses, 1 do
		local charClass = thisFactionClasss[i]
		local classCount = 0

		for realmKey, factionData in
			pairs(CensusPlus_JobQueue.g_TempCount) -- realmname, factionname
		do
			for factionKey, classData in pairs(factionData) do
				if (factionKey == factionGroup) then
					for classKey, NameData in pairs(classData) do
						if (charClass == classKey) then
							for nameKey, charData in
								pairs(NameData)
							do
								--												if (HortonBug == true) then
								--													s.ays("TempCount level 3");
								--												end

								local gotcha = charData[1]
								if (gotcha == charClass) then
									classCount = classCount + 1
								end
							end
						end
					end
				end
			end
		end

		if (CENSUSPlusFemale[charClass] ~= nil) then
			charClass = CENSUSPlusFemale[class]
		end
        if CensusPlus_JobQueue.g_TimeDatabase[charClass] == nil then
            -- print("ERROR: charclass:", charClass)
            CensusPlus_JobQueue.g_TimeDatabase[charClass] = 0
        end
		CensusPlus_JobQueue.g_TimeDatabase[charClass] =
			CensusPlus_JobQueue.g_TimeDatabase[charClass] + classCount
		CensusPlus_JobQueue.g_NumUpdatedCharacters =
			CensusPlus_JobQueue.g_NumUpdatedCharacters + classCount
	end
	if (CensusPlus_Database["TimesPlus"][realmName] == nil) then
		CensusPlus_Database["TimesPlus"][realmName] = {}
	end
	if (CensusPlus_Database["TimesPlus"][realmName][factionGroup] == nil) then
		CensusPlus_Database["TimesPlus"][realmName][factionGroup] = {}
	end

	if CensusPLus_DEBUGWRITES then
		CensusPlus_Database["TimesPlus"][realmName][factionGroup] =
			CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_DRUID] .. "&" .. CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_HUNTER] .. "&" .. CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_MAGE] .. "&" .. CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_PRIEST] .. "&" .. CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_ROGUE] .. "&" .. CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_WARLOCK] .. "&" .. CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_WARRIOR] .. "&" .. CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_SHAMAN] .. "&" .. CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_PALADIN] .. "&" .. CensusPlus_WHOPROCESSOR .. ":" .. CensusPlus_JobQueue.g_NumNewCharacters .. "," .. CensusPlus_JobQueue.g_NumUpdatedCharacters .. "," .. total_time
	else
		local TimeDataTime = date("!%Y-%m-%d&%H:%M:%S", GetServerTime())

		CensusPlus_Database["TimesPlus"][realmName][factionGroup][TimeDataTime] =
			CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_DRUID] .. "&" ..
			CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_HUNTER] .. "&" ..
			CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_MAGE] .. "&" ..
			CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_PRIEST] .. "&" ..
			CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_ROGUE] .. "&" ..
			CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_WARLOCK] .. "&" ..
			CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_WARRIOR] .. "&" ..
			CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_SHAMAN] .. "&" ..
			CensusPlus_JobQueue.g_TimeDatabase[CENSUSPLUS_PALADIN]

		CensusPlus_Database["TimesPlus"][realmName][factionGroup][TimeDataTime] =
			CensusPlus_Database["TimesPlus"][realmName][factionGroup][TimeDataTime] .. ":" ..
			checksum:generate(
				CensusPlus_Database["TimesPlus"][realmName][factionGroup][TimeDataTime] ..
				realmName ..
				factionGroup ..
				TimeDataTime
			)
	end
	CensusPlus_Zero_g_TimeDatabase() --b temp data no longer needed
end

-- Add the contents of the guild results to the database
local function CensusPlus_ProcessGuildResults()
	if not g_VariablesLoaded then return end

	--  Grab temp var
	local showOfflineTemp = GetGuildRosterShowOffline()
	SetGuildRosterShowOffline(true)

	-- Walk through the guild info
	local numGuildMembers, numOnline = GetNumGuildMembers()
	if (numOnline < 2) then
		return -- only guild member online is player who is counted elsewhere
	end
	--	CPp.Msg("Processing "..numOnline.." online of "..numGuildMembers.." total guild members.");

	local realmName = CensusPlus_GetUniqueRealmName()
	CensusPlus_Database["Guilds"] = nil
	if (CensusPlus_Database["Guilds"] == nil) then
		CensusPlus_Database["Guilds"] = {}
	end

	if (CensusPlus_Database["Guilds"][realmName] == nil) then
		CensusPlus_Database["Guilds"][realmName] = {}
	end

	local guildRealmDatabase = CensusPlus_Database["Guilds"][realmName]
	if (guildRealmDatabase == nil) then
		CensusPlus_Database["Guilds"][realmName] = {}
		guildRealmDatabase = CensusPlus_Database["Guilds"][realmName]
	end

	local factionGroup = UnitFactionGroup("player")
	if (factionGroup == nil) then
		CensusPlus_Database["Guilds"] = nil
		SetGuildRosterShowOffline(showOfflineTemp)
		return
	end

	local factionDatabase = guildRealmDatabase[factionGroup]
	if (factionDatabase == nil) then
		guildRealmDatabase[factionGroup] = {}
		factionDatabase = guildRealmDatabase[factionGroup]
	end

	CensusPlus_Database["Guilds"][realmName][factionGroup] = nil
	CensusPlus_Database["Guilds"][realmName][factionGroup] = {}

	factionDatabase = CensusPlus_Database["Guilds"][realmName][factionGroup]

	local Ginfo = GetGuildInfo("player")
	if (Ginfo == nil) then
		CensusPlus_Database["Guilds"] = nil
		SetGuildRosterShowOffline(showOfflineTemp)
		return
	end
	local guildDatabase = factionDatabase[Ginfo]
	if (guildDatabase == nil) then
		factionDatabase[Ginfo] = {}
		guildDatabase = factionDatabase[Ginfo]
	end

	local info = guildDatabase["GuildInfo"]
	if (info == nil) then
		guildDatabase["GuildInfo"] = {}
		info = guildDatabase["GuildInfo"]
	end

	info["Update"] = date("%m-%d-%Y", time()) .. ""
	info["ShowOnline"] = 1 --  Variable comes from FriendsFrame
	guildDatabase["Members"] = nil
	guildDatabase["Members"] = {}

	local members = guildDatabase["Members"]

	for index = 1, numGuildMembers, 1 do
		local name,
			rank,
			rankIndex,
			level,
			class,
			zone,
			note,
			officernote,
			online,
			status
		= GetGuildRosterInfo(index)

		if (members[name] == nil) then
			members[name] = {}
		end

		--CPp.Msg( "Name =>" .. name );
		--CPp.Msg( "rank =>" .. rank );
		--CPp.Msg( "rankIndex =>" .. rankIndex );
		--CPp.Msg( "level =>" .. level );
		--CPp.Msg( "class =>" .. class );
		members[name]["Rank"] = rank
		members[name]["RankIndex"] = rankIndex
		members[name]["Level"] = level
		members[name]["Class"] = class
		--members[name]["Zone"]= zone;
		--members[name]["Note"]= CensusPlus_SafeSet( note );
		--members[name]["OfficerNote"]= CensusPlus_SafeSet( officernote );
		--members[name]["Online"]= online;
		--members[name]["Status"]= CensusPlus_SafeSet( status );
	end

	SetGuildRosterShowOffline(showOfflineTemp)
end

function CensusPlus_SafeCheck(param)
	if (param == nil) then
		return "nil"
	else
		return param
	end
end

-- Add the contents of the who results to the database
function CensusPlus_ProcessWhoResults(result, numWhoResults)
	--  If we are in a BG th.en stop a census
	if (g_CurrentlyInBG and CPp.IsCensusPlusInProgress) then
		CPp.LastCensusRun = time() - 600
		CPp.Msg(CENSUSPLUS_ISINBG)
		CENSUSPLUS_STOPCENSUS()
	end

	--[[
		Old process, assume single realm.. process realm,faction,level,race,class,
		new process no assumption. process realm, then faction, level, race,class
		need to build dotimes for each realm found in Virtual realm set.

		name comes in as name-realm
		split to name, realm
		process

	--]]
	--5.4

	local numWhoResults = C_FriendList.GetNumWhoResults()



	if g_Verbose then
		CPp.Msg(format(CENSUSPLUS_PROCESSING, numWhoResults))
	end

	local name = ""
	--5.4
	local realm = ""
	--
	local guild = ""
	--5.4
	local guildRealm = ""
	--
	local level = ""
	local race = ""
	local class = ""
	local zone = ""
	local sex = ""
	--	local relate = ""
	for i = 1, numWhoResults, 1 do
		local tmpNmst = nil
		local tmpNmend = nil
		local tmpGldst = nil
		local tmpGldend = nil
		local relationship = nil

		local p = C_FriendList.GetWhoInfo(i)
		name = p.fullName
		guild = p.fullGuildName
		level = p.level
		race = p.raceStr
		class = p.classStr
		zone = p.area
		sex = p.gender
		if (CENSUSPlusFemale[race] ~= nil) then
			race = CENSUSPlusFemale[race]
		end
		if (CENSUSPlusFemale[class] ~= nil) then
			class = CENSUSPlusFemale[class]
		end
		if (HortonBug == true) then
			says("who API returned " .. name)
		end
		local orig_name = name
		local orig_guild = guild
		tmpNmst, tmpNmend = string.find(name, "-")
		if tmpNmst then
			realm = string.sub(name, tmpNmst + 1)
			name = string.sub(name, 1, tmpNmst - 1)
		else
			realm = CensusPlus_GetUniqueRealmName()
		end

		if ((guild ~= nil) and (guild ~= "")) then
			local guildName = ""
			guildName, _, _ = GetGuildInfo(orig_name)
			if (guildName == nil) then
				tmpGldst, tmpGldend = string.find(orig_guild, "-")
				if tmpGldst then
					guildRealm = string.sub(orig_guild, tmpGldst + 1)
					guild = string.sub(orig_guild, 1, tmpGldst - 1)
				else
					guildRealm = CensusPlus_GetUniqueRealmName()
				end
			else
				if (guildRealm == nil) then
					guildRealm = CensusPlus_GetUniqueRealmName()
				end
			end
		else
			guild = ""
			guildRealm = ""
		end

		--[[
				PTR testing modifications
				Blizzard has odd naming allowances in PTR realms
				name (US) or name (EU)  ditto for guild names

		--]]

		realm = PTR_Color_ProblemRealmGuilds_check(realm)
		name = PTR_Color_ProblemNames_check(name)
		if ((guild ~= nil) and (guild ~= "")) then
			guild = PTR_Color_ProblemRealmGuilds_check(guild)
		end
		if ((guildRealm ~= nil) and (guildRealm ~= "")) then
			guildRealm = PTR_Color_ProblemRealmGuilds_check(guildRealm)
		end

		local realmName = CensusPlus_GetUniqueRealmName()

		-- coalesced realms should not show up here via /who queries.
		local realmDatabase = CensusPlus_Database["Servers"][realmName]
		if (realmDatabase == nil) then
			CensusPlus_Database["Servers"][realmName] = {}
			realmDatabase = CensusPlus_Database["Servers"][realmName]
		end

		-- Get the portion of the database for this faction
		local factionGroup = UnitFactionGroup("player")
		if (factionGroup == nil or factionGroup == "Neutral") then return end

		local factionDatabase = realmDatabase[factionGroup]
		if (factionDatabase == nil) then
			realmDatabase[factionGroup] = {}
			factionDatabase = realmDatabase[factionGroup]
		end

		-- Get racial database
		local raceDatabase = factionDatabase[race]
		if (raceDatabase == nil) then
			factionDatabase[race] = {}
			raceDatabase = factionDatabase[race]
		end

		-- Get class database
		local classDatabase = raceDatabase[class]
		if (classDatabase == nil) then
			raceDatabase[class] = {}
			classDatabase = raceDatabase[class]
		end

		-- Get this player's entry
		local entry = classDatabase[name]
		if (entry == nil) then
			classDatabase[name] = {}
			entry = classDatabase[name]
			CensusPlus_JobQueue.g_NumNewCharacters =
				CensusPlus_JobQueue.g_NumNewCharacters + 1
		end

		lastSeen = CensusPlus_DetermineServerDate() .. ""

		-- Update the information
		entry[1] = level
		entry[2] = guild
		--local hour, minute = GetGameTime();
		entry[3] = lastSeen
		entry[4] =
			checksum:generate(
				realmName .. factionGroup .. race .. class .. name .. level .. guild .. lastSeen .. sex
			)
		entry[5] = sex

		-- 5.3 g_TempCount[name] = class;
		-- 5.4 g_TempCount[realm][name] = class;
		local gct_realm = CensusPlus_JobQueue.g_TempCount[realmName]
		if (gct_realm == nil) then
			CensusPlus_JobQueue.g_TempCount[realmName] = {}
			gct_realm = CensusPlus_JobQueue.g_TempCount[realmName]
		end

		local gct_faction = gct_realm[factionGroup]
		if (gct_faction == nil) then
			gct_realm[factionGroup] = {}
			gct_faction = gct_realm[factionGroup]
		end

		local gct_class = gct_faction[class]
		if (gct_class == nil) then
			gct_faction[class] = {}
			gct_class = gct_faction[class]
		end

		local gct_name = gct_class[name]
		if (gct_name == nil) then
			gct_class[name] = {}
			gct_name = gct_class[name]
		end
		gct_name[1] = class
	end

	-- remove the job
	table.remove(CensusPlus_JobQueue)
	whoquery_active = false
	--CensusPlus_UpdateView();
end

-- Process a single entry
-- not currently used since we don't want to activity record foreign realm characters that we spot id.
local function WR_ProcessSingleEntry(name, level, race, class, guild, zone)
	CPp.Msg2(BLIZZARD_STORE_PROCESSING .. name)

	if (CENSUSPlusFemale[race] ~= nil) then
		race = CENSUSPlusFemale[race]
	end

	if (CENSUSPlusFemale[class] ~= nil) then
		class = CENSUSPlusFemale[class]
	end

	-- Get the portion of the database for this server
	local realmName = CensusPlus_GetUniqueRealmName()
	local realmDatabase = CensusPlus_Database["Servers"][realmName]
	if (realmDatabase == nil) then
		CensusPlus_Database["Servers"][realmName] = {}
		realmDatabase = CensusPlus_Database["Servers"][realmName]
	end

	-- Get the portion of the database for this faction
	local factionGroup = UnitFactionGroup("player")
	if (factionGroup == nil) then return end

	local factionDatabase = realmDatabase[factionGroup]
	if (factionDatabase == nil) then
		realmDatabase[factionGroup] = {}
		factionDatabase = realmDatabase[factionGroup]
	end

	--  Remove the trailing ] that I can't remove through patterns
	--	local oldname = name;
	--	name = string.sub( oldname, 1, string.len(oldname) - 3 );

	level = tonumber(level)

	--  Test the name for possible color coding
	--  for example |cffff0000Rollie|r
	local karma_check = string.find(name, "|cff")
	if (karma_check ~= nil) then
		name = string.sub(name, 11, -3)
	end

	local pattern = "[0-9\| :]"
	if (string.find(name, pattern) ~= nil) then
		if not g_ProblematicMessageShown then
			CPp.Msg(
				CENSUSPLUS_PROBLEMNAME .. name .. CENSUSPLUS_PROBLEMNAME_ACTION
			)
		end
		return
	end

	--  Do a race check just to be sure this is working
	if (g_FactionCheck[race] == nil) then
		CPp.Msg(
			CENSUSPLUS_UNKNOWNRACE .. race .. CENSUSPLUS_UNKNOWNRACE_ACTION
		)
		return
	end

	-- Get racial database
	local raceDatabase = factionDatabase[race]
	if (raceDatabase == nil) then
		factionDatabase[race] = {}
		raceDatabase = factionDatabase[race]
	end

	-- Get class database
	local classDatabase = raceDatabase[class]
	if (classDatabase == nil) then
		raceDatabase[class] = {}
		classDatabase = raceDatabase[class]
	end

	-- Get this player's entry
	local entry = classDatabase[name]
	if (entry == nil) then
		classDatabase[name] = {}
		entry = classDatabase[name]
		CensusPlus_JobQueue.g_NumNewCharacters =
			CensusPlus_JobQueue.g_NumNewCharacters + 1
	end

	-- Update the information
	entry[1] = level
	entry[2] = guild
	--		local hour, minute = GetGameTime();
	entry[3] = CensusPlus_DetermineServerDate() .. ""

	g_TempCount[name] = class

	--CPp.Msg2( "Processed 	" .. name );
end

-- Find a guild in the CensusPlus_Guilds array by name
local function FindGuildByName(name)
	local i
	local size = #CensusPlus_Guilds
	for i = 1, size, 1 do
		local entry = CensusPlus_Guilds[i]
		--5.4 to be done
		-- if name and realm == name and realm   to differentiate same name guild of different realms
		if (entry.m_Name == name) then
			return i
		end
	end
	return nil
end

-- Add up the total character XP and count
local function TotalsAccumulator(name, level, guild, raceName, className, lastseen, realmName, guildRealm)
	--  Add character to our player list
	--print(name.." ".. level.." "..className.." "..raceName.." "..realmName.." "..guild.." "..guildRealm.." "..lastseen)
	if g_AccumulateGuildTotals then
		CensusPlus_AddPlayerToList(
			name,
			level,
			guild,
			raceName,
			className,
			lastseen,
			realmName,
			guildRealm
		)
	end

	if g_TotalCharacterXPPerLevel[level] then
		InitConstantTables()
	end

	local totalCharacterXP = g_TotalCharacterXPPerLevel[level]
	if (totalCharacterXP == nil) then
		totalCharacterXP = 0
	end
	if (g_TotalCharacterXP == nil) then
		g_TotalCharacterXP = 0
	end
	g_TotalCharacterXP = g_TotalCharacterXP + totalCharacterXP
	g_TotalCount = g_TotalCount + 1
	--	print("g_TCount = "..g_TotalCount.." "..guild)
	if (g_AccumulateGuildTotals and (guild ~= nil)) then
		local index = FindGuildByName(guild)
		if (index == nil) then
			local size = #CensusPlus_Guilds
			index = size + 1
			CensusPlus_Guilds[index] = {
				m_Name = guild,
				m_TotalCharacterXP = 0,
				m_Count = 0,
				m_GuildRealm = guildRealm,
				m_GNfull = guild
			}
		end
		local entry = CensusPlus_Guilds[index]
		entry.m_TotalCharacterXP = entry.m_TotalCharacterXP + totalCharacterXP
		entry.m_Count = entry.m_Count + 1
	end
end

-- Predicate function which can be used to compare two guilds for sorting
local function GuildPredicate(lhs, rhs)

	-- nil references are always less than
	if (lhs == nil) then
		if (rhs == nil) then
			return false
		else
			return true
		end
	elseif (rhs == nil) then
		return false
	end

	-- unguilded always first
	if (lhs.m_Name == "") then
		return true
	end

	if (rhs.m_Name == "") then
		return false
	end

	-- Sort by total XP first
	if (rhs.m_TotalCharacterXP < lhs.m_TotalCharacterXP) then
		return true
	elseif (lhs.m_TotalCharacterXP < rhs.m_TotalCharacterXP) then
		return false
	end

	-- Sort by name
	if (lhs.m_Name < rhs.m_Name) then
		return true
	elseif (rhs.m_Name < lhs.m_Name) then
		return false
	end

	-- identical
	return false
end

-- Another accumulator for adding up XP and counts
local function CensusPlus_Accumulator(name, level, guild)
	if (g_TotalCharacterXPPerLevel[level] == nil) then
		InitConstantTables()
	end
	local totalCharacterXP = g_TotalCharacterXPPerLevel[level]
	if (totalCharacterXP == nil or g_TotalCharacterXPPerLevel[level] == nil) then return end
	g_AccumulatorXPTotal = g_AccumulatorXPTotal + totalCharacterXP
	g_AccumulatorCount = g_AccumulatorCount + 1
end

-- Reset the above accumulator
local function CensusPlus_ResetAccumulator()
	g_AccumulatorCount = 0
	g_AccumulatorXPTotal = 0
end

-- Constants for chunked processing
local CHUNK_SIZE_MIN = 50
local CHUNK_SIZE_MAX = 500
local CHUNK_SIZE_DEFAULT = 100
local PROCESS_TIMEOUT = 0.016 
local PROCESS_TARGET = 0.008

-- Processing state
local g_ProcessingState = {}

-- Processing state
local g_ProcessingState = {
    isProcessing = false,
    isPaused = false,
    chunkSize = CHUNK_SIZE_DEFAULT,
    processedCount = 0,
    totalCount = 0,
    lastProcessTime = 0,
    currentPhase = nil, -- 'init', 'race', 'class', 'level', 'guild'
    accumulator = {
        totalXP = 0,
        totalCount = 0,
        raceCount = {},
        classCount = {},
        levelCount = {},
        guilds = {},
        maxCount = 0
    },
    searchCriteria = {
        realmKey = nil,
        factionKey = nil,
        raceKey = nil,
        classKey = nil,
        guildKey = nil,
        levelKey = nil
    },
    onComplete = nil
}

-- Control functions for processing
local function StartProcessing()
    if g_ProcessingState.isProcessing then
        return false -- Already processing
    end
    
    g_ProcessingState.isProcessing = true
    g_ProcessingState.isPaused = false
    g_ProcessingState.processedCount = 0
    g_ProcessingState.lastProcessTime = debugprofilestop()
    
    -- Start with first phase
    g_ProcessingState.currentPhase = 'init'
    
    -- Schedule first chunk
    C_Timer.After(0, ProcessNextChunk)
    
    if g_Verbose then
        CPp.Msg("Starting data processing...")
    end
    return true
end

local function StopProcessing()
    if not g_ProcessingState.isProcessing then
        return false
    end
    
    local wasProcessing = g_ProcessingState.isProcessing
    g_ProcessingState.isProcessing = false
    g_ProcessingState.isPaused = false
    
    -- Call completion callback if exists
    if wasProcessing and g_ProcessingState.onComplete then
        g_ProcessingState.onComplete()
    end
    
    if g_Verbose then
        CPp.Msg(format("Processing stopped. Processed %d entries.", g_ProcessingState.processedCount))
    end
    return true
end

-- Search the character database using the search criteria and update display
function CensusPlus_UpdateView()

	--  No need to do anything if the window is not open
	if not CensusPlusClassic:IsVisible() then return end

	-- Get realm and faction
	local realmName = CensusPlus_GetUniqueRealmName()

	CensusPlusTopGuildsTitle:SetText(CENSUSPLUS_TOPGUILD)
	g_AccumulateGuildTotals = true

	if (realmName == nil) then return end

	if (CensusPlus_PTR ~= false) then
		realmName = PTR_Color_ProblemRealmGuilds_check(realmName)
	end -- not PTR must be live

	CensusPlusRealmName:SetText(format(CENSUSPLUS_REALMNAME, string.match(realmName, "_(.*)")))

	local factionGroup, factionGName = UnitFactionGroup("player")
	if (factionGroup == nil or factionGroup == "Neutral") then
		return -- rework this area?.. if neutral display warn message elif display faction  ..or not needed handled in xml
	end

	CensusPlusFactionName:SetText(format(CENSUSPLUS_FACTION, factionGName))

	if not g_VariablesLoaded then
		return -- if variables aren't loaded show partial window data and escape
	end

	local guildKey = nil
	local raceKey = nil
	local classKey = nil
	local levelKey = nil
	g_TotalCharacterXP = 0
	g_TotalCount = 0



	-- Has the user selected a guild?
	if (CPp.GuildSelected > 0) then
		guildKey = CensusPlus_Guilds[CPp.GuildSelected].m_Name;
	end

	-- Has the user added any search criteria?
	if (CPp.RaceSelected > 0) then
		local thisFactionRaces = CensusPlus_GetFactionRaces(factionGroup)
		raceKey = thisFactionRaces[CPp.RaceSelected]
	end
	if (CPp.ClassSelected > 0) then
		local thisFactionClasses = CensusPlus_GetFactionClasses(factionGroup)
		classKey = thisFactionClasses[CPp.ClassSelected]
	end
	if (CPp.LevelSelected > 0 or CPp.LevelSelected < 0) then
		levelKey = CPp.LevelSelected
	end

	-- Has the user added any search criteria?
	if ((guildKey ~= nil) or (raceKey ~= nil) or (classKey ~= nil) or (levelKey ~= nil)) then
		-- Get totals for this criteria
		g_AccumulateGuildTotals = false;
		CensusPlus_ForAllCharacters(realmName, factionGroup, raceKey, classKey, guildKey, levelKey, TotalsAccumulator);

		if( CensusPlus_EnableProfiling ) then
			CPp.Msg( "PROFILE: Time to do calcs 1 " .. debugprofilestop() / 1000000000 );
			--debugprofilestart();
		end

	else
		-- Get the overall totals and find guild information
		CensusPlus_Guilds = {};
		g_AccumulateGuildTotals = true;
		CensusPlus_ForAllCharacters(realmName, factionGroup, nil, nil, nil, nil, TotalsAccumulator);

		if( CensusPlus_EnableProfiling ) then
			CPp.Msg( "PROFILE: Time to do calcs 1 " .. debugprofilestop() / 1000000000 );
			--debugprofilestart();
		end

		local size = table.getn(CensusPlus_Guilds);
		if (size) then
			table.sort(CensusPlus_Guilds, GuildPredicate);
		end

		if( CensusPlus_EnableProfiling ) then
			CPp.Msg( "PROFILE: Time to sort guilds " .. debugprofilestop() / 1000000000 );
			--debugprofilestart();
		end
	end

	local levelSearch = nil;
	if (levelKey ~= nil) then
		levelSearch = "  ("..CENSUSPLUS_LEVEL..": ";
		local level = levelKey;
		if (levelKey < 0) then
			levelSearch = levelSearch.."!";
			level = 0 - levelKey;
		end
		levelSearch = levelSearch..level..")";
	end

	local totalCharactersText = nil;
	if (levelSearch ~= nil) then
		totalCharactersText = format(CENSUSPLUS_TOTALCHAR, g_TotalCount) .. levelSearch
	else
		totalCharactersText = format(CENSUSPLUS_TOTALCHAR, g_TotalCount)
	end
	CensusPlusTotalCharacters:SetText(totalCharactersText);
	--CensusPlusTotalCharacterXP:SetText(format(CENSUSPlus_TOTALCHARXP, g_TotalCharacterXP));
	CensusPlus_UpdateGuildButtons();

	if( CensusPlus_EnableProfiling ) then
		CPp.Msg( "PROFILE: Update Guilds " .. debugprofilestop() / 1000000000 );
		--debugprofilestart();
	end

	-- Accumulate totals for each race
	local maxCount = 0;
	local thisFactionRaces = CensusPlus_GetFactionRaces(factionGroup);
	local numRaces = table.getn(thisFactionRaces);
	for i = 1, numRaces, 1 do
		local race = thisFactionRaces[i];
		CensusPlus_ResetAccumulator();
		if ((raceKey == nil) or (raceKey == race)) then
			CensusPlus_ForAllCharacters(realmName, factionGroup, race, classKey, guildKey, levelKey, CensusPlus_Accumulator);
		end
		if (g_AccumulatorCount > maxCount) then
			maxCount = g_AccumulatorCount;
		end
		g_RaceCount[i] = g_AccumulatorCount;
	end

	-- Update race bars
	for i = 1, numRaces, 1 do
		local race = thisFactionRaces[i];
		local buttonName = "CensusPlusRaceBar"..i;
		local button = _G[buttonName];
		local thisCount = g_RaceCount[i];
		if ((thisCount ~= nil) and (thisCount > 0) and (maxCount > 0)) then
			local height = floor((thisCount / maxCount) * CensusPlus_MAXBARHEIGHT);
			if (height < 1 or height == nil ) then height = 1; end
			button:SetHeight(height);
			button:Show();
		else
			button:Hide();
		end
		local normalTextureName= "Interface\\AddOns\\CensusPlusClassic\\skins\\CensusPlus_" .. g_RaceClassList[race]
		local legendName = "CensusPlusRaceLegend"..i;
		local legend = _G[legendName]
		legend:SetNormalTexture(normalTextureName);
		if (CPp.RaceSelectedd == i) then
			legend:LockHighlight();
		else
			legend:UnlockHighlight();
		end
	end

	if( CensusPlus_EnableProfiling ) then
		CPp.Msg( "PROFILE: Update Races " .. debugprofilestop() / 1000000000 );
		--debugprofilestart();
	end

	-- Accumulate totals for each class
	local maxCount = 0;
	local thisFactionClasss = CensusPlus_GetFactionClasses(factionGroup);
	local numClasses = table.getn(thisFactionClasss);
	for i = 1, numClasses, 1 do
		local class = thisFactionClasss[i];
		CensusPlus_ResetAccumulator();
		if ((classKey == nil) or (classKey == class)) then
			CensusPlus_ForAllCharacters(realmName, factionGroup, raceKey, class, guildKey, levelKey, CensusPlus_Accumulator);
		end
		if (g_AccumulatorCount > maxCount) then
			maxCount = g_AccumulatorCount;
		end
		g_ClassCount[i] = g_AccumulatorCount;
	end

	-- Update class bars
	for i = 1, numClasses, 1 do
		local class = thisFactionClasss[i];

		local buttonName = "CensusPlusClassBar"..i;
		local button = _G[buttonName]
		local thisCount = g_ClassCount[i];
		if ((thisCount ~= nil) and (thisCount > 0) and (maxCount > 0)) then
			local height = floor((thisCount / maxCount) * CensusPlus_MAXBARHEIGHT);
			if (height < 1 or height == nil ) then height = 1; end
			button:SetHeight(height);
			button:Show();
		else
			button:Hide();
		end

		local normalTextureName="Interface\\AddOns\\CensusPlusClassic\\skins\\CensusPlus_" .. g_RaceClassList[class]
		local legendName = "CensusPlusClassLegend"..i;
		local legend = _G[legendName]
		legend:SetNormalTexture(normalTextureName);
		if (g_ClassSelected == i) then
			legend:LockHighlight();
		else
			legend:UnlockHighlight();
		end
	end

	if( CensusPlus_EnableProfiling ) then
		CPp.Msg( "PROFILE: Update Classes " .. debugprofilestop() / 1000000000 );
		--debugprofilestart();
	end

	-- Accumulate totals for each level
	local maxCount = 0;
	for i = 1, MAX_CHARACTER_LEVEL, 1 do
	    if ((levelKey == nil) or (levelKey == i) or (levelKey < 0 and levelKey + i ~= 0)) then
			CensusPlus_ResetAccumulator();
			CensusPlus_ForAllCharacters(realmName, factionGroup, raceKey, classKey, guildKey, i, CensusPlus_Accumulator);
			if (g_AccumulatorCount > maxCount) then
				maxCount = g_AccumulatorCount;
			end
			g_LevelCount[i] = g_AccumulatorCount;
		else
			g_LevelCount[i] = 0;
		end
	end

	-- Update level bars
	for i = 1, MAX_CHARACTER_LEVEL, 1 do
		local buttonName = "CensusPlusLevelBar"..i;
		local buttonEmptyName = "CensusPlusLevelBarEmpty"..i;
		local button = getglobal(buttonName);
		local emptyButton = getglobal(buttonEmptyName);
		local thisCount = g_LevelCount[i];
		if ((thisCount ~= nil) and (thisCount > 0) and (maxCount > 0)) then
			local height = floor((thisCount / maxCount) * CensusPlus_MAXBARHEIGHT);
			if (height < 1 or height == nil ) then height = 1; end
			button:SetHeight(height);
			button:Show();
			if (emptyButton ~= nil) then
				emptyButton:Hide();
			end
		else
			button:Hide();
			if (emptyButton ~= nil) then
				emptyButton:SetHeight(CensusPlus_MAXBARHEIGHT);
				emptyButton:Show();
			end
		end
	end

	if( CensusPlus_EnableProfiling ) then
		CPp.Msg( "PROFILE: Update Levels " .. debugprofilestop() / 1000000000 );
		--debugprofilestart();
	end

	if( CP_PlayerListWindow:IsVisible() ) then
		CensusPlus_PlayerListOnShow();
	end


	debugprofilestop();
end

-- Walk the character database and call the callback function for every entry that matches the search criteria
function CensusPlus_ForAllCharacters(realmKey, factionKey, raceKey, classKey, guildKey, levelKey, callback)
	for realmName, realmDatabase in pairs(CensusPlus_Database["Servers"]) do
		if ((realmKey == nil) or (realmKey == realmName)) then
			for factionName, factionDatabase in pairs(realmDatabase) do
				if ((factionKey == nil) or (factionKey == factionName)) then
					for raceName, raceDatabase in pairs(factionDatabase) do
						if ((raceKey == nil) or (raceKey == raceName)) then
							for className, classDatabase in pairs(raceDatabase) do
								if ((classKey == nil) or (classKey == className)) then
									for characterName, character in pairs(classDatabase) do
									local characterGuild = character[2];
										if ((guildKey == nil) or (guildKey == characterGuild)) then
											local characterLevel = character[1];
											if( characterLevel == nil ) then
												characterLevel = 0;
											end
											if ((levelKey == nil) or (levelKey == characterLevel) or (levelKey < 0 and levelKey + characterLevel ~= 0)) then
												callback(characterName, characterLevel, characterGuild, raceName, className, character[3] );
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

-- Race legend clicked
-- referenced by CensusPlusClassic.xml
function CensusPlus_OnClickRace(self )
	--  default click is "LeftButton" and up .. no RegisterForClicks used
	local id = self:GetID()
	if (id == CPp.RaceSelected) then
		CPp.RaceSelected = 0
	else
		CPp.RaceSelected = id
	end
	CensusPlus_UpdateView()
end

-- Class legend clicked
-- referenced by CensusPlusClassic.xml
function CensusPlus_OnClickClass(self)
	--  default click is "LeftButton" and up .. no RegisterForClicks used
	local id = self:GetID()
	if (id == CPp.ClassSelected) then
		CPp.ClassSelected = 0
	else
		CPp.ClassSelected = id
	end
	CensusPlus_UpdateView()
end

-- Level bar loaded
-- referenced by CensusPlusClassic.xml
function CensusPlus_OnLoadLevel(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
end

-- Level bar clicked
-- referenced by CensusPlusClassic.xml
function CensusPlus_OnClickLevel(self, CP_button)
	-- both right and left buttons up registered.
	local id = self:GetID()
	if (((CP_button == "LeftButton") and (id == CPp.LevelSelected)) or ((CP_button == "RightButton") and (id + CPp.LevelSelected == 0))) then
		CPp.LevelSelected = 0
	elseif (CP_button == "RightButton") then
		CPp.LevelSelected = 0 - id
	else
		CPp.LevelSelected = id
	end
	CensusPlus_UpdateView()
end

-- Race tooltip
-- referenced by CensusPlusClassic.xml
function CensusPlus_OnEnterRace(self, motion)
	if motion then
		local factionGroup = UnitFactionGroup("player")
		local thisFactionRaces = CensusPlus_GetFactionRaces(factionGroup)
		local id = self:GetID()
		local raceName = thisFactionRaces[id]
		local count = g_RaceCount[id]
		if (count ~= nil) and (g_TotalCount > 0) then
			local percent = string.format("%.2f", (count / g_TotalCount) * 100)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(
				raceName .. "\n" .. count .. "\n" .. percent .. "%",
				1.0,
				1.0,
				1.0
			)
			GameTooltip:Show()
			-- this should never happen
			--GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			--GameTooltip:SetText(raceName.."\n 0", 1.0, 1.0, 1.0);
			--GameTooltip:Show();
		else
		end
	end -- event triggered by frame creation.. not moues movement.. so ignore
end

-- Class tooltip
-- referenced by CensusPlusClassic.xml
function CensusPlus_OnEnterClass(self, motion)
	if motion then
		local factionGroup = UnitFactionGroup("player")
		local thisFactionClasses = CensusPlus_GetFactionClasses(factionGroup)
		local id = self:GetID()
		local className = thisFactionClasses[id]
		local count = g_ClassCount[id]
		if (count ~= nil) and (g_TotalCount > 0) then
			local percent = string.format("%.2f", (count / g_TotalCount) * 100)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(
				className .. "\n" .. count .. "\n" .. percent .. "%",
				1.0,
				1.0,
				1.0
			)
			GameTooltip:Show()
			-- this should never happen
			--GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			--GameTooltip:SetText(className.."\n 0", 1.0, 1.0, 1.0);
			--GameTooltip:Show();
		else
		end
	end -- entered via frame creation.. not mouse motion .. ignore
end

-- Level tooltip
-- referenced by CensusPlusClassic.xml
function CensusPlus_OnEnterLevel(self, motion )
	if motion then
		local id = self:GetID()
		local count = g_LevelCount[id]
		if (count ~= nil) and (g_TotalCount > 0) then
			local percent = string.format("%.2f", (count / g_TotalCount) * 100)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(
				LEVEL .. " " .. id .. "\n" .. count .. "\n" .. percent .. "%",
				1.0,
				1.0,
				1.0
			)
			GameTooltip:Show()
			-- this should never happen
			--GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			--GameTooltip:SetText("Level "..id.."\n 0", 1.0, 1.0, 1.0);
			--GameTooltip:Show();
		else
		end
	end -- entered via frame creation .. not mouse movement.. ignore
end

-- Clicked a guild button
-- referenced by CensusPlusClassic.xml
function CensusPlus_GuildButton_OnClick(self )
	local id = self:GetID();
	local offset = FauxScrollFrame_GetOffset(CensusPlusGuildScrollFrame);
	local newSelection = id + offset;
	if (CPp.GuildSelected ~= newSelection) then
		CPp.GuildSelected = newSelection;
	else
		CPp.GuildSelected = 0;
	end
	CensusPlus_UpdateView();
end

-- Update the guild button contents
function CensusPlus_UpdateGuildButtons()
	-- Determine where the scroll bar is
	local offset = FauxScrollFrame_GetOffset(CensusPlusGuildScrollFrame)
	-- Walk through all the rows in the frame
	local size = #CensusPlus_Guilds
	--	print("num guild buttons = "..size)
	local i = 1
	while (i <= CensusPlus_NUMGUILDBUTTONS) do
		-- Get the index to the ad displayed in this row
		local iGuild = i + offset
		-- Get the button on this row
		local button = _G["CensusPlusGuildButton" .. i]
		-- Is there a valid guild on this row?
		if (iGuild <= size) then
			local guild = CensusPlus_Guilds[iGuild]
			-- Update the button text
			button:Show()
			local textField = "CensusPlusGuildButton" .. i .. "Text"
			if (guild.m_Name == "") then
				_G[textField]:SetText(CENSUSPLUS_UNGUILDED)
			else
				_G[textField]:SetText(guild.m_GNfull)
			end
			-- If this is the guild, highlight it
			if (CPp.GuildSelected == iGuild) then
				button:LockHighlight();
			else
				button:UnlockHighlight();
			end
		-- Hide the button
		else
			button:Hide()
		end
		--
		-- Next row
		--
		i = i + 1
	end

	-- Update the scroll bar
	FauxScrollFrame_Update(
		CensusPlusGuildScrollFrame,
		size,
		CensusPlus_NUMGUILDBUTTONS,
		CensusPlus_GUILDBUTTONSIZEY
	)
end

-- Walk the character database prune all characters entries that are older than X days
-- referenced by CensusPlusClassic.xml
function CENSUSPLUS_PRUNEData(nDays, sServer)

	local pruneTime = 24 * 60 * 60 * nDays

	for realmName, realmDatabase in pairs(CensusPlus_Database["Servers"]) do
		for factionName, factionDatabase in pairs(realmDatabase) do
			if ((factionKey == nil) or (factionKey == factionName)) then
				for raceName, raceDatabase in pairs(factionDatabase) do
					if ((raceKey == nil) or (raceKey == raceName)) then
						for className, classDatabase in
							pairs(raceDatabase)
						do
							if ((classKey == nil) or (classKey == className)) then
								for characterName, character in
									pairs(classDatabase)
								do
									if (characterName ~= nil) then
										--[[
											if( sServer == 1 ) then
												if( realmName ~= thisRealmName ) then
													CensusPlus_AccumulatePruneData( realmName, factionName, raceName, className, characterName );
												end
											else
												if( realmName == thisRealmName ) then
										--]]
										local lastSeen = character[3] --  2005-05-02
										local tYear, tMonth, tDay
										tYear = string.sub(lastSeen, 1, 4)
										tMonth = string.sub(lastSeen, 6, 7)
										tDay = string.sub(lastSeen, 9)

										local lastSeenTime = time({
											year = tYear,
											month = tMonth,
											day = tDay,
											hour = 0
										})

										if (time() - lastSeenTime > pruneTime) then
											CensusPlus_AccumulatePruneData(
												realmName,
												factionName,
												raceName,
												className,
												characterName
											)
										end
										--end
										--end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	CENSUSPLUS_PRUNETimes()
	CensusPlus_UpdateView()
	CENSUSPLUS_PRUNETheData()
	CENSUSPLUS_PRUNEDeadBranches()
end


function CensusPlus_CheckForBattleground()
	--CPp.Msg( "Checking for BG" );
	g_CurrentlyInBG_Msg = false

	local battlefieldTime = GetBattlefieldInstanceRunTime()
	if (battlefieldTime > 0) then
		--  We are in a battleground so cancel the current take
		g_CurrentlyInBG = true -- if player in battlefield
	else
		if (GetBattlefieldStatInfo(1) ~= nil) then
			g_CurrentlyInBG = true
		else
			g_CurrentlyInBG = false
		end
	end
end

-- CensusPlus_DetermineServerDate
function CensusPlus_DetermineServerDate()
	return date("!%Y-%m-%d", GetServerTime())
end

-- Check time zone
function CensusPlus_CheckTZ()
	local UTCTimeHour = date("!%H", time())
	local LocTimeHour = date("%H", time())
	local hour, minute = GetGameTime()
	local locDiff = LocTimeHour - UTCTimeHour
	local servDiff = hour - UTCTimeHour
	g_CensusPlusTZOffset = servDiff
end

function ManualWho()
  if (CPp.IsCensusPlusInProgress and not g_CurrentlyInBG) then
    now = time()
    local deltaManual = now - CPp.LastManualWho
    if deltaManual > CensusPlus_UPDATEDELAY then
      if g_Verbose then
        print("ManualWho:", whoMsg)
      end
      CPp.LastManualWho = time()
      if (whoquery_active) then
        FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE")
        C_FriendList.SetWhoToUi(true)
        CensusPlusClassic:RegisterEvent("WHO_LIST_UPDATE")
        C_FriendList.SendWho(whoMsg)
      end
    end
  end
end

function CensusPlus_SendWho(msg)
	if g_Verbose then
		CPp.Msg(format(CENSUSPLUS_SENDING, msg))
	end

	-- Add CensusButton show top of whoquery
	if g_CensusButtonAnimi then
		local _, _, topwho = string.find(msg, "(%d+)")
		topwho = string.sub(msg, string.find(msg, "-", -4) + 1)
		topwhoval = tonumber(topwho)
		if (topwhoval > 99) then
			--topwho = topwho - 100
			CensusButton:SetNormalFontObject(GameFontNormalSmall)
			topwho = "|cffff5e16" .. topwho .. "|r"
		else
			CensusButton:SetNormalFontObject(GameFontNormal)
		end
		CensusButton:SetText(topwho)
	end

	whoMsg = msg

	whoquery_active = true
	CP_g_queue_count = CP_g_queue_count + 1
end

function PTR_Color_ProblemNames_check(name)
	--[[
			PTR testing modifications
			Blizzard has odd naming allowances in PTR realms
			name (US) or name (EU)  ditto for guild names
	--]]

	if (CensusPlus_PTR ~= false) then
		local cp_ptr_name_check, _, _ = string.find(name, "  %(")
		if (cp_ptr_name_check ~= nil) then
			name =
				string.sub(name, 1, cp_ptr_name_check - 1) .. string.sub(
					name,
					cp_ptr_name_check + 3,
					cp_ptr_name_check + 4
				)
		end
		local cp_ptr_name_check, _, _ = string.find(name, " %(")
		if (cp_ptr_name_check ~= nil) then
			name =
				string.sub(name, 1, cp_ptr_name_check - 1) .. string.sub(
					name,
					cp_ptr_name_check + 2,
					cp_ptr_name_check + 3
				)
		end
		local cp_ptr_name_check, _, _ = string.find(name, "%(")
		if (cp_ptr_name_check ~= nil) then
			name =
				string.sub(name, 1, cp_ptr_name_check - 1) .. string.sub(
					name,
					cp_ptr_name_check + 1,
					cp_ptr_name_check + 2
				)
		end
	end

	--  Test the name for possible color coding
	--  for example |cffff0000Rollie|r
	local karma_check = string.find(name, "|cff")
	if (karma_check ~= nil) then
		name = string.sub(name, 11, -3)
	end

	--  Further check for problematic chars
	local pattern = "[%d| ]"
	if (string.find(name, pattern) ~= nil) then
		if not g_ProblematicMessageShown then
			CPp.Msg(
				CENSUSPLUS_PROBLEMNAME .. name .. CENSUSPLUS_PROBLEMNAME_ACTION
			)
			g_ProblematicMessageShown = true
		end
		name = ""
	end
	return name
end

function PTR_Color_ProblemRealmGuilds_check(name)
	--[[
			PTR testing modifications
			Blizzard has odd naming allowances in PTR realms
			name (US) or name (EU)  ditto for guild names
´	--]]

	if (CensusPlus_PTR ~= false) then
		local cp_ptr_name_check, _, _ = string.find(name, "  %(")
		if (cp_ptr_name_check ~= nil) then
			name =
				string.sub(name, 1, cp_ptr_name_check - 1) .. string.sub(
					name,
					cp_ptr_name_check + 3,
					cp_ptr_name_check + 4
				)
			if (HortonBug == true) then
				says("1 " .. name)
			end
		end
		local cp_ptr_name_check, _, _ = string.find(name, " %(")
		if (cp_ptr_name_check ~= nil) then
			name =
				string.sub(name, 1, cp_ptr_name_check - 1) .. string.sub(
					name,
					cp_ptr_name_check + 2,
					cp_ptr_name_check + 3
				)
			if (HortonBug == true) then
				says("2 " .. name)
			end
		end
		local cp_ptr_name_check, _, _ = string.find(name, "%(")
		if (cp_ptr_name_check ~= nil) then
			name =
				string.sub(name, 1, cp_ptr_name_check - 1) .. string.sub(
					name,
					cp_ptr_name_check + 1,
					cp_ptr_name_check + 2
				)
			if (HortonBug == true) then
				says("3 " .. name)
			end
		end
	end
	return name
end

function CensusPlus_Mini_OnMouseDown(
self,
	mCP_button -- referenced by CensusPlusClassic.xml
)
	if ((not self.isLocked or (self.isLocked == 0)) and (mCP_button == "LeftButton")) then
		self:StartMoving()
		self.isMoving = true
	end
end

-- referenced by CensusPlusClassic.xml
function CensusPlus_Census_OnMouseDown(self, CP_button)
	if (not self.isLocked or (self.isLocked == 0)) then
		self:StartMoving()
		self.isMoving = true
	end
end

-- print("Adding main frame scripts...")
-- -- Add frame scripts
-- CensusPlusClassic:SetScript("OnLoad", CensusPlus_OnLoad)
-- CensusPlusClassic:SetScript("OnEvent", CensusPlus_OnEvent)
-- CensusPlusClassic:SetScript("OnShow", CensusPlus_OnShow)
-- CensusPlusClassic:SetScript("OnMouseDown", CensusPlus_Census_OnMouseDown)
-- CensusPlusClassic:SetScript("OnMouseUp", function(self)
--     if self.isMoving then
--         self:StopMovingOrSizing()
--         self.isMoving = false
--     end
-- end)

local db_defaults = {}

function CPp:OnEnable()
    CensusPlus_DB = LibStub("AceDB-3.0"):New("CensusPlusDB", db_defaults)
    self:InitializeNews(CensusPlus_DB)
    self:CheckAndShowNews()
end