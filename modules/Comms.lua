local	addon_name, CPp = ...  

------------------------------
-- Configuration & Libraries
------------------------------

local CURRENT_VERSION = CENSUSPLUS__VERSION  -- Your addon's current version
local MIN_POOL_SIZE = 10                     -- Minimum active users required in pool
local ACTIVE_THRESHOLD = 15 * 60             -- Consider users active if seen within last 15 minutes

local COMM_PREFIX = "CPGOSPROT"              -- Unique prefix for our protocol

local AceComm = LibStub("AceComm-3.0")
local AceDB = LibStub("AceDB-3.0")

------------------------------
-- Database Setup (Realm-Wide)
------------------------------

local defaults = {
    realm = {
        userDB = {}  -- Format: [playerName] = { lastSeen = <timestamp>, flag = <string> }
    }
}

local CP_NetworkDB = AceDB:New("CP_NetworkDB", defaults, "Default")

-- Record/update a peer in the shared database.
local function RecordUser(userName, flag)
    local entry = CP_NetworkDB.realm.userDB[userName] or {}
    entry.lastSeen = time()
    entry.flag = flag or entry.flag
    CP_NetworkDB.realm.userDB[userName] = entry
    CPp.debug("Updated active user:", userName, "at", entry.lastSeen)
end

------------------------------
-- Active User Pool Functions
------------------------------

-- Build a sorted list of active users based on last seen delta.
function CPp:BuildActiveUserPool()
    local activeUsers = {}
    local now = time()
    for name, info in pairs(CP_NetworkDB.realm.userDB) do
        local delta = now - info.lastSeen
        table.insert(activeUsers, { name = name, delta = delta })
    end
    table.sort(activeUsers, function(a, b) return a.delta < b.delta end)
    return activeUsers  
end

-- Return a comma-separated list of up to 'n' random active user names.
function CPp:GetRandomActiveUsers(n)
    local pool = CPp:BuildActiveUserPool()
    local results = {}
    if #pool == 0 then return "" end
    for i = 1, math.min(n, #pool) do
        local idx = math.random(#pool)
        table.insert(results, pool[idx].name)
    end
    return table.concat(results, ",")
end

------------------------------
-- HELLO Message Functions
------------------------------

-- Modified SendHello:
-- If 'activeList' is provided, it is appended to the message.
-- Format: "HELLO:<flag>:<version>[:<activeList>]"
function CPp:SendHello(target, flag, version, activeList)
    flag = flag or "init"
    version = version or CURRENT_VERSION
    local msg = "HELLO:" .. flag .. ":" .. version
    if activeList and activeList ~= "" then
        msg = msg .. ":" .. activeList
    end

    if target then
        AceComm:SendCommMessage(COMM_PREFIX, msg, "WHISPER", target)
    else
        -- If in a guild (and you are), broadcast on GUILD; otherwise, nothing happens.
        -- You might also want to use another channel for public broadcasts.
        AceComm:SendCommMessage(COMM_PREFIX, msg, "GUILD")
    end
end

------------------------------
-- Communication Handler
------------------------------

function CPp:OnCommReceived(prefix, message, distribution, sender)
    if prefix ~= COMM_PREFIX then return end

    -- Parse messages. Expect either:
    -- "HELLO:<flag>:<version>" OR "HELLO:<flag>:<version>:<activeList>"
    local msgType, flag, versionStr, activeList = message:match("^(%w+):(%w+):([%d%.]+):?(.*)$")
    if msgType == "HELLO" then
        local receivedVersion = tonumber(versionStr) or 0
        CPp.debug("Received HELLO from", sender, "flag:", flag, "version:", receivedVersion)
        
        RecordUser(sender, flag)  -- Update our database for this sender.
        
        -- Version check: if the received version is higher, alert the user.
        if receivedVersion > CURRENT_VERSION then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[CensusPlus]|r New version available: " ..
                receivedVersion .. " (you are on " .. CURRENT_VERSION .. "). Please update!")
        end

        -- As a reply, if this message is not already a reply, send back our own HELLO.
        if flag ~= "reply" then
            -- Get 10 random active peers from our pool.
            local randomPeers = CPp:GetRandomActiveUsers(10)
            CPp:SendHello(sender, "reply", CURRENT_VERSION, randomPeers)
        end
    end
end

AceComm:RegisterComm(COMM_PREFIX, "OnCommReceived")

------------------------------
-- Peer Discovery Logic (Census)
------------------------------

-- This function sends HELLO messages to build the initial active user pool.
-- If you're in a guild, you can broadcast. Otherwise, use your saved database.
function CPp:ProbeForPeers()
    if IsInGuild() then
        -- Preferred: broadcast to guild if available.
        SendHello(nil, "init", CURRENT_VERSION)
    else
        -- Not in a guild: iterate through our database in ascending order
        -- until the active pool meets the minimum requirement.
        local activePool = CPp:BuildActiveUserPool()
        if #activePool < MIN_POOL_SIZE then
            print("Active pool below minimum (" .. #activePool .. "). Messaging unknown peers from census...")
            -- Here, you would iterate through players found during your census.
            -- For this example, we'll simulate by iterating through the database.
            for name, _ in pairs(CP_NetworkDB.realm.userDB) do
                CPp:SendHello(name, "init", CURRENT_VERSION)
            end
        else
            -- If we have enough active peers, message them in ascending order.
            for i, user in ipairs(activePool) do
                CPp:SendHello(user.name, "init", CURRENT_VERSION)
            end
        end
    end
end

------------------------------
-- Updating the Database on New Finds
------------------------------

-- Suppose during your census you encounter a new player (not yet in your DB). When detected,
-- you should record them and send a HELLO message.
function CPp:OnCensusFind(newPlayerName)
    if not CP_NetworkDB.realm.userDB[newPlayerName] then
        CPp.debug("New player found in census:", newPlayerName)
        RecordUser(newPlayerName, "census")
        SendHello(newPlayerName, "init", CURRENT_VERSION)
    end
end