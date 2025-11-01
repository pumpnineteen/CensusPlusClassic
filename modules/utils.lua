local addon_name, CPp = ... -- Get addon name and shared table

local WOW_PROJECT_ID = _G.WOW_PROJECT_ID
local WOW_PROJECT_CLASSIC = _G.WOW_PROJECT_CLASSIC
local WOW_PROJECT_BURNING_CRUSADE_CLASSIC = _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local WOW_PROJECT_WRATH_CLASSIC = _G.WOW_PROJECT_WRATH_CLASSIC
local WOW_PROJECT_CATACLYSM_CLASSIC = _G.WOW_PROJECT_CATACLYSM_CLASSIC
local WOW_PROJECT_MISTS_CLASSIC = _G.WOW_PROJECT_MISTS_CLASSIC
local WOW_PROJECT_MAINLINE = _G.WOW_PROJECT_MAINLINE
local LE_EXPANSION_LEVEL_CURRENT = _G.LE_EXPANSION_LEVEL_CURRENT
local LE_EXPANSION_BURNING_CRUSADE =_G.LE_EXPANSION_BURNING_CRUSADE
local LE_EXPANSION_WRATH_OF_THE_LICH_KING = _G.LE_EXPANSION_WRATH_OF_THE_LICH_KING
local LE_EXPANSION_CATACLYSM = _G.LE_EXPANSION_CATACLYSM
local LE_EXPANSION_MISTS = _G.LE_EXPANSION_MISTS_OF_PANDARIA
local LE_EXPANSION_WARLORDS = _G.LE_EXPANSION_WARLORDS_OF_DRAENOR
local LE_EXPANSION_LEGION = _G.LE_EXPANSION_LEGION
local LE_EXPANSION_BFA = _G.LE_EXPANSION_BATTLE_FOR_AZEROTH
local LE_EXPANSION_SHADOWLANDS = _G.LE_EXPANSION_SHADOWLANDS
local LE_EXPANSION_DRAGONFLIGHT = _G.LE_EXPANSION_DRAGONFLIGHT
local LE_EXPANSION_WAR_WITHIN = _G.LE_EXPANSION_WAR_WITHIN

function CPp.IsClassicWow() --luacheck: ignore 212
    return WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
end

function CPp.IsTBCWow() --luacheck: ignore 212
    return WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC and LE_EXPANSION_LEVEL_CURRENT == LE_EXPANSION_BURNING_CRUSADE
end

function CPp.IsWrathWow() --luacheck: ignore 212
    return WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC and LE_EXPANSION_LEVEL_CURRENT == LE_EXPANSION_WRATH_OF_THE_LICH_KING
end

function CPp.IsCataWow() --luacheck: ignore 212
    return WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC and LE_EXPANSION_LEVEL_CURRENT == LE_EXPANSION_CATACLYSM
end

function CPp.IsMistsWow() --luacheck: ignore 212
    return WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC and LE_EXPANSION_LEVEL_CURRENT == LE_EXPANSION_MISTS
end

function CPp.IsRetailWow() --luacheck: ignore 212
    return WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
end

-- Message functions with debug prints
function CPp.Msg(msg)
    -- print("[DEBUG] CPp.Msg called with:", msg) -- Debug print
    -- print("[DEBUG] CPp.stealth =", CPp.stealth) -- Debug print
    -- print("[DEBUG] CENSUSPLUS_TEXT =", CENSUSPLUS_TEXT) -- Debug print
    -- print("[DEBUG] ChatFrame1 exists:", ChatFrame1 ~= nil) -- Debug print

    if msg == nil then
        msg = " NIL "
    end
    if not CPp.stealth then
        if ChatFrame1 then -- Add nil check
            ChatFrame1:AddMessage(CENSUSPLUS_TEXT.." "..msg, 1.0, 1.0, 0.5)
        else
            print("[DEBUG] ERROR: ChatFrame1 is nil!") -- Debug print
        end
    else
        print("[DEBUG] Message not shown because stealth mode is enabled") -- Debug print
    end
end

function CPp.WhoMsg(msg)
    -- print("[DEBUG] CPp.WhoMsg called with:", msg) -- Debug print
    
    if msg == nil then
        msg = " NIL "
    end
    if ChatFrame1 then -- Add nil check
        ChatFrame1:AddMessage(CENSUSPLUS_TEXT.." "..WHO..": "..msg, 0.8, 0.8, 0.1)
    else
        print("[DEBUG] ERROR: ChatFrame1 is nil in WhoMsg!") -- Debug print
    end
end

function CPp.Msg2(msg)
    -- print("[DEBUG] CPp.Msg2 called with:", msg) -- Debug print
    -- print("[DEBUG] CPp.stealth =", CPp.stealth) -- Debug print
    -- print("[DEBUG] ChatFrame2 exists:", ChatFrame2 ~= nil) -- Debug print

    if msg == nil then
        msg = " NIL "
    end
    if not CPp.stealth then
        if ChatFrame2 then -- Add nil check
            ChatFrame2:AddMessage(CENSUSPLUS_TEXT..": "..msg, 0.5, 1.0, 1.0)
        else
            print("[DEBUG] ERROR: ChatFrame2 is nil!") -- Debug print
        end
    else
        print("[DEBUG] Message not shown because stealth mode is enabled") -- Debug print
    end
end

function CPp.debug(...)
    if not CP_DEBUG then return end
    
    local args = {...}
    local msg = "DEBUG: "
    for i, v in ipairs(args) do
        msg = msg .. tostring(v) .. " "
    end
    
    CPp.Msg(msg)
end

