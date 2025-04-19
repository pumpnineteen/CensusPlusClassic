local	addon_name, CPp = ... 

function CensusPlus_CreateMainFrameButtons()
    CPp.Msg("Creating MainFrame buttons...")
    -- Create main frame
    local mainFrame = CensusPlusClassic
    
    -- Add buttons
    local function CreateButton(name, template, text, parent, point, x, y, width, height)
        local button = CreateFrame("Button", name, parent, template)
        button:SetSize(width or 128, height or 21)
        button:SetPoint(unpack(point))
        if text then
            button:SetText(text)
        end
        return button
    end

    -- Options Button
    local optionsBtn = CreateButton("CP_DisplayOptionsButton", 
        "UIPanelButtonTemplate",
        CENSUSPLUS_BUTTON_OPTIONS,
        mainFrame,
        {"TOPRIGHT", mainFrame, "TOPRIGHT", -20, -60}
    )
    optionsBtn:SetScript("OnClick", CensusPlus_ToggleOptions)

    -- Add minimize button
    local minimizeBtn = CreateButton(
        "CensusPlusMinimizeButton",
        "UIPanelButtonTemplate", 
        CENSUSPlus_BUTTON_MINIMIZE,
        mainFrame,
        {"TOPRIGHT", mainFrame, "TOPLEFT", 600, -8},
        128,
        21
    )
    minimizeBtn:Hide() -- Start hidden
    
    -- Add minimize button scripts
    minimizeBtn:SetScript("OnClick", CensusPlus_OnClickMinimize)
    minimizeBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(CENSUSPlus_MINIMIZE, 1.0, 1.0, 1.0)
        GameTooltip:Show()
    end)
    minimizeBtn:SetScript("OnLeave", function(self)
        GameTooltip:Hide() 
    end)

    -- Add Take Census button
    local takeBtn = CreateButton(
        "CensusPlusTakeButton",
        "UIPanelButtonTemplate",
        CENSUSPLUS_TAKE,
        mainFrame,
        {"BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 20, 10},
        128,
        21
    )

    takeBtn:SetScript("OnClick", CENSUSPLUS_TAKE_OnClick)
    takeBtn:SetScript("OnEnter", CENSUSPLUS_TAKE_OnEnter)
    takeBtn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Add Stop Census button
    local stopBtn = CreateButton(
        "CensusPlusStopButton",
        "UIPanelButtonTemplate",
        CENSUSPLUS_STOP,
        mainFrame,
        {"TOPLEFT", takeBtn, "TOPLEFT", 134, 0},
        128,
        21
    )

    stopBtn:SetScript("OnClick", CENSUSPLUS_STOPCENSUS)
    stopBtn:SetScript("OnEnter", CENSUSPLUS_STOP_OnEnter)
    stopBtn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Add Manual Who button
    local whoBtn = CreateButton(
        "CensusPlusWhoButton",
        "UIPanelButtonTemplate",
        "ManualWho",
        mainFrame,
        {"TOPLEFT", takeBtn, "TOPLEFT", 265, 0},
        128,
        21
    )

    whoBtn:SetScript("OnClick", CENSUSPLUS_MANUALWHO)
    whoBtn:SetScript("OnEnter", CENSUSPLUS_MANUALWHO_OnEnter)
    whoBtn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Add Prune button
    local pruneBtn = CreateButton(
        "CensusPlusPruneButton",
        "UIPanelButtonTemplate",
        CENSUSPLUS_PRUNE,
        mainFrame,
        {"TOPLEFT", stopBtn, "TOPLEFT", 320, 0},
        128,
        21
    )

    pruneBtn:SetScript("OnClick", function(self)
        CENSUSPLUS_PRUNEData(30, false)
    end)
    pruneBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(CENSUSPLUS_PRUNECENSUS, 1.0, 1.0, 1.0)
        GameTooltip:Show()
    end)
    pruneBtn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Add Purge button
    local purgeBtn = CreateButton(
        "CensusPlusPurgeButton",
        "UIPanelButtonTemplate",
        CENSUSPLUS_PURGE,
        mainFrame,
        {"TOPLEFT", pruneBtn, "TOPLEFT", 136, 0},
        128,
        21
    )

    purgeBtn:SetScript("OnClick", CENSUSPLUS_PURGE_OnClick)
    purgeBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(CENSUSPLUS_PURGEDATABASE, 1.0, 1.0, 1.0)
        GameTooltip:Show()
    end)
    purgeBtn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    local last_race_legend
    -- Create race legends and bars
    local function CreateRaceButtons()
        -- Get max races based on game version 
        local maxRaces = CensusPlus_NumRaces
        CPp.Msg("Creating race buttons for ".. maxRaces .. " races...")

        -- Create first race legend
        local firstLegend = CreateFrame("Button", "CensusPlusRaceLegend1", mainFrame, "CensusPlusRaceLegendTemplate")
        firstLegend:SetID(1)
        firstLegend:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 22, -256)

        -- Create first race bar
        local firstBar = CreateFrame("Button", "CensusPlusRaceBar1", mainFrame, "CensusPlusRaceBarTemplate")
        firstBar:SetID(1)
        firstBar:SetPoint("BOTTOM", firstLegend, "TOP", 1, 8)

        local previousLegend = firstLegend
        -- Create remaining race legends and bars
        for i = 2, maxRaces do
            local legend = CreateFrame("Button", "CensusPlusRaceLegend"..i, mainFrame, "CensusPlusRaceLegendTemplate")
            legend:SetID(i)
            legend:SetPoint("LEFT", previousLegend, "RIGHT", 6, 0)

            last_race_legend = "CensusPlusRaceLegend"..i

            local bar = CreateFrame("Button", "CensusPlusRaceBar"..i, mainFrame, "CensusPlusRaceBarTemplate") 
            bar:SetID(i)
            bar:SetPoint("BOTTOM", legend, "TOP", 1, 8)

            previousLegend = legend
        end
    end

    -- Create class legends and bars 
    local function CreateClassButtons()
        -- Get max classes based on game version
        local maxClasses = CensusPlus_NumClasses
        CPp.Msg("Creating class buttons for ".. maxClasses .. " classes...")
        -- Create first class legend
        local firstLegend = CreateFrame("Button", "CensusPlusClassLegend1", mainFrame, "CensusPlusClassLegendTemplate")
        firstLegend:SetID(1)
        firstLegend:SetPoint("LEFT", _G[last_race_legend], "RIGHT", 41, 0)

        -- Create first class bar
        local firstBar = CreateFrame("Button", "CensusPlusClassBar1", mainFrame, "CensusPlusClassBarTemplate")
        firstBar:SetID(1)
        firstBar:SetPoint("BOTTOM", firstLegend, "TOP", 0, 8)

        local previousLegend = firstLegend
        -- Create remaining class legends and bars
        for i = 2, maxClasses do
            local legend = CreateFrame("Button", "CensusPlusClassLegend"..i, mainFrame, "CensusPlusClassLegendTemplate")
            legend:SetID(i)
            legend:SetPoint("LEFT", previousLegend, "RIGHT", 6, 0)

            local bar = CreateFrame("Button", "CensusPlusClassBar"..i, mainFrame, "CensusPlusClassBarTemplate")
            bar:SetID(i)
            bar:SetPoint("BOTTOM", legend, "TOP", 0, 8)

            previousLegend = legend
        end
    end

    -- Create level bars
    local function CreateLevelBars()
        -- local template = _G["CensusPlusLevelBarTemplate"]
        -- print("Bar template: ", template)
        -- print(CensusPlusLevelBarTemplate)
        -- if template then
        --     template:SetWidth(CP_LEVEL_BAR_WIDTH) 
        -- end

        local previousBar
        for i = 1, MAX_CHARACTER_LEVEL do
            local bar = CreateFrame("Button", "CensusPlusLevelBar"..i, mainFrame, "CensusPlusLevelBarTemplate")
            bar:SetID(i)
            bar:SetWidth(CP_LEVEL_BAR_WIDTH) 
            
            if i == 1 then
                bar:SetPoint("BOTTOMLEFT", mainFrame, "TOPLEFT", 16 + CP_Justify_Levels, -452)
            else
                bar:SetPoint("BOTTOMLEFT", previousBar, "BOTTOMRIGHT", 2, 0)
            end
            
            previousBar = bar
        end
    end

    -- Create guild buttons
    local function CreateGuildButtons()
        local previousButton
        for i = 1, 10 do
            local button = CreateFrame("Button", "CensusPlusGuildButton"..i, mainFrame, "CensusPlusGuildButtonTemplate")
            button:SetID(i)

            if i == 1 then
                button:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", CP_WINDOW_WIDTH - 251, -120)
            else
                button:SetPoint("TOPLEFT", previousButton, "BOTTOMLEFT", 0, 0)
            end
            
            previousButton = button
        end

        -- Add Show Characters button anchored to last guild button
        local showCharsBtn = CreateButton(
            "CP_DisplayCharactersButton",
            "UIPanelButtonTemplate",
            CENSUSPLUS_BUTTON_CHARACTERS,
            mainFrame,
            {"TOPLEFT", _G["CensusPlusGuildButton10"], "BOTTOMLEFT", 40, -10},
            128,
            21
        )

        showCharsBtn:SetScript("OnClick", function(self)
            PlaySound(856, "Master")
            if CP_PlayerListWindow:IsVisible() then
                HideUIPanel(CP_PlayerListWindow)
            else
                CensusPlus_ShowPlayerList()
            end
        end)
    end

local  function CreateGuildScrollbar()
    -- Create scroll frame for guild list 
    local scrollFrame = CreateFrame("ScrollFrame", "CensusPlusGuildScrollFrame", mainFrame, "FauxScrollFrameTemplate")
    scrollFrame:SetSize(190, 160)
    scrollFrame:SetPoint("TOPLEFT", _G["CensusPlusGuildButton1"], "TOPLEFT", 0, 0)
    scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, CensusPlus_GUILDBUTTONSIZEY, CensusPlus_UpdateGuildButtons)
    end)
end

    -- Setup scripts
    mainFrame:SetScript("OnLoad", CensusPlus_OnLoad)
    mainFrame:SetScript("OnShow", CensusPlus_OnShow)
    mainFrame:SetScript("OnUpdate", CensusPlus_OnUpdate)
    mainFrame:SetScript("OnEvent", CensusPlus_OnEvent)
    
    -- Create remaining UI elements...
    CreateRaceButtons()
    CreateClassButtons()
    CreateLevelBars()
    CreateGuildButtons()
    CreateGuildScrollbar()
    
    return mainFrame
end

-- CreateCensusPlusUI()

-- local f = CreateFrame("Frame")
-- f:RegisterEvent("ADDON_LOADED")
-- f:SetScript("OnEvent", function(self, event, addon)
--     if addon == "CensusPlusClassic" then
--         CreateCensusPlusUI()
--     end
-- end)