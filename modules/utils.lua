local	addon_name, addonTable = ...  
local CPp = addonTable.CPp or {}

function CPp.split(inputstr, delimiter)
    if inputstr == nil or type(inputstr) ~= "string" then
        return {}
    end
    if delimiter == nil then
        delimiter = "%s"  -- Default: split by whitespace.
    end
    local result = {}
    for substr in string.gmatch(inputstr, "([^" .. delimiter .. "]+)") do
        table.insert(result, substr)
    end
    return result
end

function CPp.join(things, joiner)
    if type(joiner) ~= "string" then
        error("Joiner must be a string!", joiner)
        return nil
    end
    local result = ""
    for i, v in ipairs(things) do
        result = result .. tostring(v)
        if i < #things then
            result = result .. joiner
        end
    end
    return result
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
