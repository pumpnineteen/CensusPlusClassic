local	addon_name, CPp = ... 

CensusPlus_Borders = {}

function CensusPlus_CreateMainFrameBorders()
    -- Create the main frame
    CPp.Msg("Creating main frame borders...")
    CPp.Msg("Window width: " .. CP_WINDOW_WIDTH)
    CensusPlusClassic:SetSize(CP_WINDOW_WIDTH, 512)
    CensusPlusClassic:SetPoint("CENTER")
    CensusPlusClassic:EnableMouse(true)
    CensusPlusClassic:SetMovable(true)
    CensusPlusClassic:SetToplevel(true)
    CensusPlusClassic:Hide()

    -- Background texture
    CensusPlusBackground = CensusPlusClassic:CreateTexture("CensusPlusBackground", "BACKGROUND")
    CensusPlusBackground:SetTexture("Interface\\Dialogframe\\UI-DialogBox-Background-Dark")
    CensusPlusBackground:SetSize(CP_WINDOW_WIDTH - 4, 512)
    CensusPlusBackground:SetPoint("TOPLEFT", 0, 0)

    -- local width, height = CensusPlusBackground:GetSize()
    -- CPp.Msg("Background size: " .. width .. "x" .. height)

    -- Create all the border textures
    local function CreateCorner(x, y, texCoords)
        local corner = CensusPlusClassic:CreateTexture(nil, "BORDER")
        corner:SetTexture("Interface\\Dialogframe\\Dialogframe-Corners")
        corner:SetSize(32, 32)
        corner:SetPoint("TOPLEFT", x, y)
        corner:SetTexCoord(texCoords["left"], texCoords["right"], texCoords["top"], texCoords["bottom"])
        return corner
    end

    local function CreateBorder(name, x, y, width, height)
        local border = CensusPlusClassic:CreateTexture(nil, "BORDER")
        border:SetTexture("Interface\\Dialogframe\\Dialogframe-" .. name)
        border:SetSize(width, height)
        border:SetPoint("TOPLEFT", x, y)
        return border
        
    end

    local tex_topleft = {top = "0", left = "0", bottom = ".5", right = ".5"}
    local tex_topright = {top = "0", left = ".5", bottom = ".5", right = "1"}
    local tex_bottomleft = {top = ".5", left = "0", bottom = "1", right = ".5"}
    local text_bottomright = {top = ".5", left = ".5", bottom = "1", right = "1"}

    CensusPlus_Borders["outer_border"] = {}
    CensusPlus_Borders["outer_border"]["corners"] = {}
    -- Top Left Outer Corner
    CensusPlus_Borders["outer_border"]["corners"]["topleft"] = CreateCorner(-5, 7, tex_topleft )
    -- Top Right Outer Corner  
    CensusPlus_Borders["outer_border"]["corners"]["topright"] = CreateCorner(CP_WINDOW_WIDTH - 26, 7, tex_topright )
    -- Bottom Left Outer Corner
    CensusPlus_Borders["outer_border"]["corners"]["bottomleft"] = CreateCorner(-5, -488, tex_bottomleft )
    -- Bottom Right Outer Corner
    CensusPlus_Borders["outer_border"]["corners"]["bottomright"] = CreateCorner(CP_WINDOW_WIDTH - 26, -488, text_bottomright)

    CensusPlus_Borders["outer_border"]["sides"] = {}
    -- Left Outer Border
    CensusPlus_Borders["outer_border"]["sides"]["left"] = CreateBorder("Left", -4, -8, 16, 488)
    -- Right Outer Border
    CensusPlus_Borders["outer_border"]["sides"]["right"] = CreateBorder("Right", CP_WINDOW_WIDTH - 10, -18, 16, 488)
    -- Top Outer Border
    CensusPlus_Borders["outer_border"]["sides"]["top"] = CreateBorder("Top", 8, 6, CP_WINDOW_WIDTH - 30, 16)
    -- Bottom Outer Border
    CensusPlus_Borders["outer_border"]["sides"]["bottom"] = CreateBorder("Bot", 8, -504, CP_WINDOW_WIDTH - 30, 16)

    -- local width, height = CensusPlus_Borders["outer_border"]["sides"]["bottom"]:GetSize()
    -- CPp.Msg("Border size: " .. width .. "x" .. height)

    local top_shader = CensusPlusClassic:CreateTexture(nil, "ARTWORK")
    top_shader:SetTexture("Interface\\AddOns\\CensusPlusClassic\\skins\\CensusPlus_Window_Top_Shader")
    top_shader:SetSize(CP_WINDOW_WIDTH - 10, 64)
    top_shader:SetPoint("TOPLEFT", 6, -6)

    CensusPlus_Borders["top_shader"] = top_shader

    -- Levels borders
    CP_Justify_Levels = math.floor((CP_WINDOW_WIDTH - CP_LEVEL_SECTION_WIDTH) / 2)
    -- CPp.Msg("CP_Justify_Levels: " .. CP_Justify_Levels .. " levels width: " .. CP_LEVEL_SECTION_WIDTH .. " window: " .. CP_WINDOW_WIDTH)
    CP_Justify_Levels = CP_Justify_Levels - 16
    CensusPlus_Borders["levels"] = {}
    CensusPlus_Borders["levels"]["corners"] = {}
    -- Top Left Levels Corner
    CensusPlus_Borders["levels"]["corners"]["topleft"] = CreateCorner(CP_Justify_Levels, -309, tex_topleft)
    -- Top Right Levels Corner
    CensusPlus_Borders["levels"]["corners"]["topright"] = CreateCorner(CP_LEVEL_SECTION_WIDTH + CP_Justify_Levels, -309, tex_topright)
    -- Bottom Left Levels Corner
    CensusPlus_Borders["levels"]["corners"]["bottomleft"] = CreateCorner(CP_Justify_Levels, -432, tex_bottomleft)
    -- Bottom Right Levels Corner
    CensusPlus_Borders["levels"]["corners"]["bottomright"] = CreateCorner(CP_LEVEL_SECTION_WIDTH + CP_Justify_Levels, -432, text_bottomright)

    CensusPlus_Borders["levels"]["sides"] = {}
    -- Left Levels Border
    CensusPlus_Borders["levels"]["sides"]["left"] = CreateBorder("Left", 1 + CP_Justify_Levels, -326, 16, 114)
    -- Right Levels Border
    CensusPlus_Borders["levels"]["sides"]["right"] = CreateBorder("Right", CP_LEVEL_SECTION_WIDTH + 16 + CP_Justify_Levels, -326, 16, 114)
    -- Top Levels Border
    CensusPlus_Borders["levels"]["sides"]["top"] = CreateBorder("Top", 12 + CP_Justify_Levels, -310, CP_LEVEL_SECTION_WIDTH, 16)
    -- Bottom Levels Border
    CensusPlus_Borders["levels"]["sides"]["bottom"] = CreateBorder("Bot", 12 + CP_Justify_Levels, -448, CP_LEVEL_SECTION_WIDTH, 16)

    -- Races borders
    CensusPlus_Borders["races"] = {}
    CensusPlus_Borders["races"]["corners"] = {}
    -- Top Left Races Corner
    CensusPlus_Borders["races"]["corners"]["topleft"] = CreateCorner(8, -107, tex_topleft)
    -- Top Right Races Corner
    CensusPlus_Borders["races"]["corners"]["topright"] = CreateCorner(CP_RACE_SECTION_WIDTH + 8, -107, tex_topright)
    -- Bottom Left Races Corner
    CensusPlus_Borders["races"]["corners"]["bottomleft"] = CreateCorner(8, -228, tex_bottomleft)
    -- Bottom Right Races Corner
    CensusPlus_Borders["races"]["corners"]["bottomright"] = CreateCorner(CP_RACE_SECTION_WIDTH + 8, -228, text_bottomright)

    CensusPlus_Borders["races"]["sides"] = {}
    -- Left Races Border
    CensusPlus_Borders["races"]["sides"]["left"] = CreateBorder("Left", 9, -122, 16, 110)
    -- Right Races Border
    CensusPlus_Borders["races"]["sides"]["right"] = CreateBorder("Right", CP_RACE_SECTION_WIDTH + 24, -122, 16, 110)
    -- Top Races Border
    CensusPlus_Borders["races"]["sides"]["top"] = CreateBorder("Top", 25, -108, CP_RACE_SECTION_WIDTH, 16)
    -- Bottom Races Border
    CensusPlus_Borders["races"]["sides"]["bottom"] = CreateBorder("Bot", 25, -244, CP_RACE_SECTION_WIDTH, 16)


    -- Classes borders
    local classes_left = CP_RACE_SECTION_WIDTH + 24 + 25
    local classes_right = classes_left + CP_CLASS_SECTION_WIDTH
    CensusPlus_Borders["classes"] = {}
    CensusPlus_Borders["classes"]["corners"] = {}
    -- Top Left Classes Corner
    CensusPlus_Borders["classes"]["corners"]["topleft"] = CreateCorner(classes_left, -107, tex_topleft)
    -- Top Right Classes Corner
    CensusPlus_Borders["classes"]["corners"]["topright"] = CreateCorner(classes_right, -107, tex_topright)
    -- Bottom Left Classes Corner
    CensusPlus_Borders["classes"]["corners"]["bottomleft"] = CreateCorner(classes_left, -228, tex_bottomleft)
    -- Bottom Right Classes Corner
    CensusPlus_Borders["classes"]["corners"]["bottomright"] = CreateCorner(classes_right, -228, text_bottomright)

    CensusPlus_Borders["classes"]["sides"] = {}
    -- Left Classes Border
    CensusPlus_Borders["classes"]["sides"]["left"] = CreateBorder("Left", classes_left + 1, -122, 16, 126)
    -- Right Classes Border
    CensusPlus_Borders["classes"]["sides"]["right"] = CreateBorder("Right", classes_right + 16, -122, 16, 126)
    -- Top Classes Border
    CensusPlus_Borders["classes"]["sides"]["top"] = CreateBorder("Top", classes_left + 16, -108, CP_CLASS_SECTION_WIDTH, 16)
    -- Bottom Classes Border
    CensusPlus_Borders["classes"]["sides"]["bottom"] = CreateBorder("Bot", classes_left + 16, -244, CP_CLASS_SECTION_WIDTH, 16)

    -- Guilds borders
    local guilds_left = CP_WINDOW_WIDTH - CP_GUILDS_LEFT_OFFSET
    local guilds_right = guilds_left + 204
    CensusPlus_Borders["guilds"] = {}
    CensusPlus_Borders["guilds"]["corners"] = {}
    -- Top Left Guilds Corner
    CensusPlus_Borders["guilds"]["corners"]["topleft"] = CreateCorner(guilds_left, -107, tex_topleft)
    -- Top Right Guilds Corner
    CensusPlus_Borders["guilds"]["corners"]["topright"] = CreateCorner(guilds_right, -107, tex_topright)
    -- Bottom Left Guilds Corner
    CensusPlus_Borders["guilds"]["corners"]["bottomleft"] = CreateCorner(guilds_left, -260, tex_bottomleft)
    -- Bottom Right Guilds Corner
    CensusPlus_Borders["guilds"]["corners"]["bottomright"] = CreateCorner(guilds_right, -260, text_bottomright)

    CensusPlus_Borders["guilds"]["sides"] = {}
    -- Left Guilds Border
    CensusPlus_Borders["guilds"]["sides"]["left"] = CreateBorder("Left", guilds_left + 1, -122, 16, 156)
    -- Right Guilds Border
    CensusPlus_Borders["guilds"]["sides"]["right"] = CreateBorder("Right", guilds_right + 15, -122, 16, 156)
    -- Top Guilds Border
    CensusPlus_Borders["guilds"]["sides"]["top"] = CreateBorder("Top", guilds_left + 9, -108, 212, 16)
    -- Bottom Guilds Border
    CensusPlus_Borders["guilds"]["sides"]["bottom"] = CreateBorder("Bot", guilds_left + 9, -276, 212, 16)


    -- Add text elements
    CensusPlusText = CensusPlusClassic:CreateFontString("CensusPlusText", "ARTWORK", "GameFontHighlight")
    CensusPlusText:SetPoint("TOPLEFT", CensusPlusClassic, 16, -12)
    CensusPlusText:SetText(CENSUSPLUS_TEXT)

    CensusPlusText2 = CensusPlusClassic:CreateFontString("CensusPlusText2", "ARTWORK", "GameFontHighlight")
    CensusPlusText2:SetPoint("TOPLEFT", CensusPlusClassic, 220, -12)
    CensusPlusText2:SetText("WarcraftRealms.com")
    CensusPlusText2:SetTextColor(0.4, 0.8, 1.0)

    CensusPlusRealmName = CensusPlusClassic:CreateFontString("CensusPlusRealmName", "ARTWORK", "GameFontHighlight")
    CensusPlusRealmName:SetPoint("TOPLEFT", CensusPlusClassic, 16, -32)
    CensusPlusRealmName:SetText(CENSUSPlus_BUTTON_REALMUNKNOWN)

    CensusPlusFactionName = CensusPlusClassic:CreateFontString("CensusPlusFactionName", "ARTWORK", "GameFontHighlight")
    CensusPlusFactionName:SetPoint("TOPLEFT", CensusPlusClassic, 16, -48)
    CensusPlusFactionName:SetText(CENSUSPLUS_FACTIONUNKNOWN)

    CensusPlusLocaleName = CensusPlusClassic:CreateFontString("CensusPlusLocaleName", "ARTWORK", "GameFontHighlight")
    CensusPlusLocaleName:SetPoint("TOPLEFT", CensusPlusClassic, 16, -64)
    CensusPlusLocaleName:SetText(CENSUSPLUS_LOCALEUNKNOWN)

    CensusPlusTotalCharacters = CensusPlusClassic:CreateFontString("CensusPlusTotalCharacters", "ARTWORK", "GameFontHighlight")
    CensusPlusTotalCharacters:SetPoint("TOPLEFT", CensusPlusClassic, 240, -48)
    CensusPlusTotalCharacters:SetText(CENSUSPLUS_TOTALCHAR_0)

    CensusPlusScanProgress = CensusPlusClassic:CreateFontString("CensusPlusScanProgress", "ARTWORK", "GameFontHighlight")
    CensusPlusScanProgress:SetPoint("TOPLEFT", CensusPlusClassic, 240, -32)
    CensusPlusScanProgress:SetText(CENSUSPLUS_SCAN_PROGRESS_0)

    CensusPlusConsecutive = CensusPlusClassic:CreateFontString("CensusPlusConsecutive", "ARTWORK", "GameFontHighlight")
    CensusPlusConsecutive:SetPoint("TOPLEFT", CensusPlusClassic, 240, -64)
    CensusPlusConsecutive:SetText(CENSUSPLUS_CONSECUTIVE_0)

    CensusPlusTopGuildsTitle = CensusPlusClassic:CreateFontString("CensusPlusTopGuildsTitle", "ARTWORK", "GameFontHighlight")
    CensusPlusTopGuildsTitle:SetPoint("TOPLEFT", CensusPlusClassic, 683, -90)
    CensusPlusTopGuildsTitle:SetText(CENSUSPLUS_TOPGUILD)

    CensusPlusRacesTitle = CensusPlusClassic:CreateFontString("CensusPlusRacesTitle", "ARTWORK", "GameFontHighlight")
    CensusPlusRacesTitle:SetPoint("TOPLEFT", CensusPlusClassic, 76, -90)
    CensusPlusRacesTitle:SetText(CENSUSPLUS_RACE)

    CensusPlusClassesTitle = CensusPlusClassic:CreateFontString("CensusPlusClassesTitle", "ARTWORK", "GameFontHighlight")
    CensusPlusClassesTitle:SetPoint("TOPLEFT", CensusPlusClassic, 335, -90)
    CensusPlusClassesTitle:SetText(CENSUSPLUS_CLASS)

    CensusPlusLevelsTitle = CensusPlusClassic:CreateFontString("CensusPlusLevelsTitle", "ARTWORK", "GameFontHighlight")
    CensusPlusLevelsTitle:SetPoint("TOPLEFT", CensusPlusClassic, 340, -300)
    CensusPlusLevelsTitle:SetText(CENSUSPLUS_LEVEL)
end


-- CreateMainFrame()

-- local f = CreateFrame("Frame")
-- f:RegisterEvent("ADDON_LOADED")
-- f:SetScript("OnEvent", function(self, event, addon)
--     if addon == "CensusPlusClassic" then
--         CreateMainFrame()
--     end
-- end)