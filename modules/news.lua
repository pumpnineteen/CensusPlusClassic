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
local NEWS_SORT_CHRONOLOGICAL = true -- true = oldest first, false = newest first

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

-- Get all unseen news versions sorted by preference
local function GetAllUnseenNewsVersions(fromVersion)
    fromVersion = fromVersion or 0
    local versions = {}
    
    for version, _ in pairs(NEWS_ITEMS) do
        if version > fromVersion then
            table.insert(versions, version)
        end
    end
    
    table.sort(versions, function(a, b)
        if NEWS_SORT_CHRONOLOGICAL then
            return a < b  -- oldest first
        else
            return a > b  -- newest first
        end
    end)
    
    return versions
end

-- Get filtered news content for a specific version
local function GetNewsContentForVersion(version)
    local newsItems = NEWS_ITEMS[version]
    if not newsItems then return nil end
    
    local filteredNews = FilterNewsForCurrentVersion(newsItems)
    if #filteredNews == 0 then return nil end
    
    return table.concat(filteredNews, "\n\n")
end

function CPp:SetNewsTitle(title)
    default_title = title
end

function CPp.ShowNewsSplash(newsVersion, title)
    title = title or default_title or "What's New"
    
    -- Get all versions with news newer than newsVersion
    local versionsToShow = GetAllUnseenNewsVersions(newsVersion)
    
    -- No news to show
    if #versionsToShow == 0 then
        return
    end
    
    -- Build content for each version that has relevant news
    local newsContent = {}
    local highestVersion = newsVersion
    
    for _, version in ipairs(versionsToShow) do
        local content = GetNewsContentForVersion(version)
        if content then
            table.insert(newsContent, {
                version = version,
                text = content
            })
            if version > highestVersion then
                highestVersion = version
            end
        end
    end
    
    -- Don't show window if no relevant news for current game version
    if #newsContent == 0 then
        db.global.lastSeenNewsVersion = highestVersion
        return
    end
    
    -- Create window
    local window = AceGUI:Create("Window")
    window:SetTitle(title)
    window:SetWidth(300)
    window:SetHeight(200)
    window:SetLayout("Flow")
    window:SetCallback("OnClose", function(widget)
        -- Update to the highest version shown
        db.global.lastSeenNewsVersion = highestVersion
        AceGUI:Release(widget)
    end)

    local frame = AceGUI:Create("ScrollFrame")
    frame:SetLayout("List")
    window:AddChild(frame)

    -- Add news for each version
    for i, content in ipairs(newsContent) do
        -- Add version label
        local versionLabel = AceGUI:Create("Label")
        versionLabel:SetText(string.format("|cFFFFD700Version r%d|r", content.version))
        versionLabel:SetFullWidth(true)
        frame:AddChild(versionLabel)
        
        -- Add spacing after version label
        local spacer1 = AceGUI:Create("Label")
        spacer1:SetText(" ")
        spacer1:SetFullWidth(true)
        frame:AddChild(spacer1)
        
        -- Add news text for this version
        local newsTextWidget = AceGUI:Create("Label")
        newsTextWidget:SetText(content.text)
        newsTextWidget:SetFullWidth(true)
        frame:AddChild(newsTextWidget)
        
        -- Add spacing between versions (but not after the last one)
        if i < #newsContent then
            local spacer2 = AceGUI:Create("Label")
            spacer2:SetText("\n")
            spacer2:SetFullWidth(true)
            frame:AddChild(spacer2)
        end
    end
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