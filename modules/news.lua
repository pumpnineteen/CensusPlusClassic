local addon_name, CPp = ... -- Get addon name and shared table
local AceGUI = LibStub("AceGUI-3.0")

local ipairs = ipairs
local pairs = pairs
local table = table
local string = string

local NEWS_ALL = "all"
local NEWS_CLASSIC = "classic"
local NEWS_TBC = "tbc"
local NEWS_WRATH = "wrath"
local NEWS_CATA = "cata"
local NEWS_MOP = "mop"


local VERSION = CPp.VERSION or 0

local NEWS_ITEMS = {
    [8] = {
        {text = "1.15.8 restored the functionality for semi-auto census! Make sure you enable it, if you disabled it during 1.15.7.", versions = {NEWS_CLASSIC}},
    },
}

local VERSION_CHECKS = {
    [NEWS_ALL] = function() return true end,
    [NEWS_CLASSIC] = CPp.IsClassicWow,
    [NEWS_TBC] = CPp.IsTBCWow,
    [NEWS_WRATH] = CPp.IsWrathWow,
    [NEWS_CATA] = CPp.IsCataWow,
    [NEWS_MOP] = CPp.IsMistsWow,
}

local db -- declare at module level
local default_title

local function FilterNewsForCurrentVersion(newsItems)
    local filtered = {}
    
    for _, item in ipairs(newsItems) do
        for _, versionId in ipairs(item.versions) do
            local checkFunc = VERSION_CHECKS[versionId]
            if checkFunc and checkFunc() then
                table.insert(filtered, item.text)
                break -- Don't add the same item multiple times
            end
        end
    end
    
    return filtered
end

local function GetLatestUnseenNews()
    local lastSeen = db.global.lastSeenNewsVersion or 0
    local latestNewsVersion = nil
    
    -- Find the highest news version that's greater than lastSeen
    for version, _ in pairs(NEWS_ITEMS) do
        if version > lastSeen then
            if not latestNewsVersion or version > latestNewsVersion then
                latestNewsVersion = version
            end
        end
    end
    
    return latestNewsVersion
end

function CPp:SetNewsTitle(title)
    default_title = title
end

function CPp.ShowNewsSplash(newsVersion, title)
    local newsItems = NEWS_ITEMS[newsVersion]
    if not newsItems then return end

    title = title or default_title or "What's New"
    
    -- Filter news for current game version
    local filteredNews = FilterNewsForCurrentVersion(newsItems)
    
    -- Don't show window if no relevant news for this version
    if #filteredNews == 0 then
        db.global.lastSeenNewsVersion = newsVersion
        return
    end
    
    -- Combine all news items with line breaks
    local newsText = table.concat(filteredNews, "\n\n")
    
    local window = AceGUI:Create("Window")
    window:SetTitle(title)
    window:SetWidth(300)
    window:SetHeight(150)
    window:SetLayout("Flow")
    window:SetCallback("OnClose", function(widget)
        -- Update the last seen version when window is closed
        db.global.lastSeenNewsVersion = newsVersion
        AceGUI:Release(widget)
    end)

    local frame = AceGUI:Create("ScrollFrame")
    frame:SetLayout("List")
    window:AddChild(frame)

    -- Add version label
    local versionLabel = AceGUI:Create("Label")
    versionLabel:SetText(string.format("|cFFFFD700Version r%d|r", newsVersion))
    versionLabel:SetFullWidth(true)
    frame:AddChild(versionLabel)
    
    -- Add spacing
    local spacer1 = AceGUI:Create("Label")
    spacer1:SetText(" ")
    spacer1:SetFullWidth(true)
    frame:AddChild(spacer1)
    
    -- Add news text
    local newsTextWidget = AceGUI:Create("Label")
    newsTextWidget:SetText(newsText)
    newsTextWidget:SetFullWidth(true)
    frame:AddChild(newsTextWidget)
    
end

function CPp:CheckAndShowNews()
    local latestUnseen = GetLatestUnseenNews()
    
    if latestUnseen then
        self:ShowNewsSplash(latestUnseen)
    end
end

function CPp:InitializeNews(dbInstance)
    db = dbInstance
    -- Optionally check and show news immediately
    local latestUnseen = GetLatestUnseenNews()
    if latestUnseen then
        self:ShowNewsSplash(latestUnseen)
    end
end