local	addon_name, addonTable = ...  
local CPp = addonTable.CPp or {}

-- Create module if it doesn't exist
if not CPp.Options then
    CPp.Options = {}
end

local Options = CPp.Options

-- Constants
local ENABLE = "Enable"
local DISABLE = "Disable"

local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
-- Create a header text
function Options:CensusPlusBlizzardOptions()
	-- Create main frame for information text
	CensusPlusOptions = CreateFrame("FRAME", "CensusPlusOptions")
	CensusPlusOptions.name = GetAddOnMetadata("CensusPlusClassic", "Title")
	CensusPlusOptions.default = function(self)
		Options:CensusPlus_ResetConfig()
	end
	CensusPlusOptions.refresh = function(self)
		Options:CensusPlusSetCheckButtonState()
	end
	CensusPlusOptions.cancel = function(self)
		Options:CensusPlusRestoreSettings()
	end
	CensusPlusOptions.okay = function(self)
		Options:CensusPlusCloseOptions()
	end
	-- InterfaceOptions_AddCategory(CensusPlusOptions)
    local category = Settings.RegisterCanvasLayoutCategory(CensusPlusOptions, "CensusPlusClassic")
    Settings.RegisterAddOnCategory(category)
    CPp.settingsCategory = category
	CPp.settingsID = category:GetID()


	-- Create Title frame
	CensusPlusOptionsHeader = CensusPlusOptions:CreateFontString(nil, "ARTWORK")
	CensusPlusOptionsHeader:SetFontObject(GameFontNormalLarge)
	CensusPlusOptionsHeader:SetJustifyH("LEFT")
	CensusPlusOptionsHeader:SetJustifyV("TOP")
	CensusPlusOptionsHeader:ClearAllPoints()
	CensusPlusOptionsHeader:SetPoint("TOPLEFT", 16, -16)
	CensusPlusOptionsHeader:SetText(
		"CensusClassic v" .. CPp.CensusPlus_VERSION_FULL
	)

	-- Create Top Text frame (section 1 header)
	CensusPlusOptionsWL = CensusPlusOptions:CreateFontString(nil, "ARTWORK")
	CensusPlusOptionsWL:SetFontObject(GameFontWhite)
	CensusPlusOptionsWL:SetJustifyH("LEFT")
	CensusPlusOptionsWL:SetJustifyV("TOP")
	CensusPlusOptionsWL:ClearAllPoints()
	CensusPlusOptionsWL:SetPoint(
		"TOPLEFT",
		CensusPlusOptionsHeader,
		"BOTTOMLEFT",
		14,
		-6
	)
	CensusPlusOptionsWL:SetText(
		CENSUSPLUS_ACCOUNT_WIDE .. " " .. CENSUSPLUS_BUTTON_OPTIONS
	)

	-- Create Top Text frame (section 1 header)
	CensusPlusOptionsWR = CensusPlusOptions:CreateFontString(nil, "ARTWORK")
	CensusPlusOptionsWR:SetFontObject(GameFontWhite)
	CensusPlusOptionsWR:SetJustifyH("LEFT")
	CensusPlusOptionsWR:SetJustifyV("TOP")
	CensusPlusOptionsWR:ClearAllPoints()
	CensusPlusOptionsWR:SetPoint(
		"TOPLEFT",
		CensusPlusOptionsWL,
		"TOPRIGHT",
		100,
		0
	)
	CensusPlusOptionsWR:SetText(CENSUSPLUS_CCO_OPTIONOVERRIDES)

	--Create Frame CheckButton (Verbose)
	CensusPlusCheckButton1 =
		CreateFrame(
			"CheckButton",
			"CensusPlusCheckButton1",
			CensusPlusOptions,
			"InterfaceOptionsCheckButtonTemplate"
		)
	CensusPlusCheckButton1:SetPoint(
		"TOPLEFT",
		CensusPlusOptionsWL,
		"BOTTOMLEFT",
		2,
		-10
	)
	CensusPlusCheckButton1:SetScript("OnClick", function(self)
		local g_AW_Verbose = CensusPlusCheckButton1:GetChecked()
		-- print("CB1 = ", g_AW_Verbose)
		if g_AW_Verbose then
			CensusPlus_Database["Info"]["Verbose"] = true
			CensusPlus_Database["Info"]["Stealth"] = false
			CensusPlusCheckButton2:SetChecked(false)
			Options:CensusPlus_Stealth(self)
		else
			CensusPlus_Database["Info"]["Verbose"] = false
		end
		Options:CensusPlus_Verbose(self)
	end)
	CensusPlusCheckButton1Text:SetText(CENSUS_OPTIONS_VERBOSE)
	CensusPlusCheckButton1.tooltipText = CENSUS_OPTIONS_VERBOSE_TOOLTIP

	--Create Frame tri-selector button (CO - Verbose - enable)
	CensusPlusOptionsRadioButton_C1a =
		CreateFrame(
			"CheckButton",
			"CensusPlusOptionsRadioButton_C1a",
			CensusPlusOptions,
			"UIRadioButtonTemplate"
		)
	CensusPlusOptionsRadioButton_C1a:SetHeight(20)
	CensusPlusOptionsRadioButton_C1a:SetWidth(20)
	CensusPlusOptionsRadioButton_C1a:SetHitRectInsets(0, -5, 0, 0)
	CensusPlusOptionsRadioButton_C1a:ClearAllPoints()
	CensusPlusOptionsRadioButton_C1a:SetPoint(
		"TOPLEFT",
		CensusPlusCheckButton1,
		"TOPRIGHT",
		210,
		0
	)
	CensusPlusOptionsRadioButton_C1a:SetChecked(false)
	CensusPlusOptionsRadioButton_C1a:SetScript("OnEnter", function(self)
		if self.tooltipText then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1)
		end
		if self.tooltipRequirement then
			GameTooltip:AddLine(self.tooltipRequirement, 1.0, 1.0, 1.0, 1.0)
			GameTooltip:Show()
		end
	end)
	CensusPlusOptionsRadioButton_C1a:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	CensusPlusOptionsRadioButton_C1a:SetScript("OnClick", function(self)
		local g_CO_Verbose = CensusPlusOptionsRadioButton_C1a:GetChecked()
		if g_CO_Verbose then
			CensusPlusOptionsRadioButton_C1b:SetChecked(false)
			CensusPlusOptionsRadioButton_C1c:SetChecked(false)
			CensusPlus_PerCharInfo["Verbose"] = true
			CensusPlus_PerCharInfo["Stealth"] = false
			CensusPlusOptionsRadioButton_C2a:SetChecked(false)
			CensusPlusOptionsRadioButton_C2b:SetChecked(true)
			CensusPlusOptionsRadioButton_C2c:SetChecked(false)
			Options:CensusPlus_Stealth(self)
		elseif not CensusPlusOptionsRadioButton_C1b:GetChecked() then
			CensusPlusOptionsRadioButton_C1c:SetChecked(true)
			CensusPlus_PerCharInfo["Verbose"] = nil
		end
		Options:CensusPlus_Verbose(self)
	end)
	CensusPlusOptionsRadioButton_C1a.tooltipText = ENABLE

	--Create Frame tri-selector button (CO - Verbose - disable)
	CensusPlusOptionsRadioButton_C1b =
		CreateFrame(
			"CheckButton",
			"CensusPlusOptionsRadioButton_C1b",
			CensusPlusOptions,
			"UIRadioButtonTemplate"
		)
	CensusPlusOptionsRadioButton_C1b:SetHeight(20)
	CensusPlusOptionsRadioButton_C1b:SetWidth(20)
	CensusPlusOptionsRadioButton_C1b:SetHitRectInsets(0, -5, 0, 0)
	CensusPlusOptionsRadioButton_C1b:ClearAllPoints()
	CensusPlusOptionsRadioButton_C1b:SetPoint(
		"TOPLEFT",
		CensusPlusOptionsRadioButton_C1a,
		"TOPRIGHT",
		20,
		0
	)
	CensusPlusOptionsRadioButton_C1b:SetChecked(false)
	CensusPlusOptionsRadioButton_C1b:SetScript("OnEnter", function(self)
		if self.tooltipText then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1)
		end
		if self.tooltipRequirement then
			GameTooltip:AddLine(self.tooltipRequirement, 1.0, 1.0, 1.0, 1.0)
			GameTooltip:Show()
		end
	end)
	CensusPlusOptionsRadioButton_C1b:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	CensusPlusOptionsRadioButton_C1b:SetScript("OnClick", function(self)
		local g_CO_Verbose = CensusPlusOptionsRadioButton_C1b:GetChecked()
		if g_CO_Verbose then
			CensusPlusOptionsRadioButton_C1a:SetChecked(false)
			CensusPlusOptionsRadioButton_C1c:SetChecked(false)
			CensusPlus_PerCharInfo["Verbose"] = false --if (not(CensusPlusOptionsRadioButton_C1a:GetChecked()))then
		else
			CensusPlusOptionsRadioButton_C1c:SetChecked(true)
			CensusPlus_PerCharInfo["Verbose"] = nil
			if CensusPlusOptionsRadioButton_C2a:GetChecked() then
				CensusPlusOptionsRadioButton_C2a:SetChecked(false)
				CensusPlusOptionsRadioButton_C2c:SetChecked(true)
				CensusPlus_PerCharInfo["Stealth"] = nil
				Options:CensusPlus_Stealth(self)
			end
		end
		Options:CensusPlus_Verbose(self)
	end)
	CensusPlusOptionsRadioButton_C1b.tooltipText = DISABLE

	--Create Frame tri-selector button (CO - Verbose - remove)
	CensusPlusOptionsRadioButton_C1c =
		CreateFrame(
			"CheckButton",
			"CensusPlusOptionsRadioButton_C1c",
			CensusPlusOptions,
			"UIRadioButtonTemplate"
		)
	CensusPlusOptionsRadioButton_C1c:SetHeight(20)
	CensusPlusOptionsRadioButton_C1c:SetWidth(20)
	CensusPlusOptionsRadioButton_C1c:SetHitRectInsets(0, -5, 0, 0)
	CensusPlusOptionsRadioButton_C1c:ClearAllPoints()
	CensusPlusOptionsRadioButton_C1c:SetPoint(
		"TOPLEFT",
		CensusPlusOptionsRadioButton_C1b,
		"TOPRIGHT",
		20,
		0
	)
	CensusPlusOptionsRadioButton_C1c:SetChecked(true)
	_G[CensusPlusOptionsRadioButton_C1c:GetName() .. "Text"]:SetText(
		CENSUS_OPTIONS_VERBOSE .. " " .. CENSUSPLUS_OPTIONS_OVERRIDE
	)
	CensusPlusOptionsRadioButton_C1c:SetScript("OnEnter", function(self)
		if self.tooltipText then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1)
		end
		if self.tooltipRequirement then
			GameTooltip:AddLine(self.tooltipRequirement, 1.0, 1.0, 1.0, 1.0)
			GameTooltip:Show()
		end
	end)
	CensusPlusOptionsRadioButton_C1c:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	CensusPlusOptionsRadioButton_C1c:SetScript("OnClick", function(self)
		local g_CO_Verbose = CensusPlusOptionsRadioButton_C1c:GetChecked()
		if g_CO_Verbose then
			CensusPlusOptionsRadioButton_C1a:SetChecked(false)
			CensusPlusOptionsRadioButton_C1b:SetChecked(false)
			CensusPlus_PerCharInfo["Verbose"] = nil
			if (CensusPlusCheckButton1:GetChecked() and CensusPlusOptionsRadioButton_C2a:GetChecked()) then
				CensusPlusOptionsRadioButton_C2a:SetChecked(false)
				CensusPlusOptionsRadioButton_C2c:SetChecked(true)
				CensusPlus_PerCharInfo["Stealth"] = false
				Options:CensusPlus_Stealth(self)
			end
		elseif not (CensusPlusOptionsRadioButton_C1a:GetChecked() or CensusPlusOptionsRadioButton_C1b:GetChecked()) then
			CensusPlusOptionsRadioButton_C1c:SetChecked(true)
			CensusPlus_PerCharInfo["Verbose"] = nil
		end
		Options:CensusPlus_Verbose(self)
	end)
	CensusPlusOptionsRadioButton_C1c.tooltipText =
		CENSUS_OPTIONS_CCO_REMOVE_OVERRIDE

	--Create Frame enable Stealth Mode
	CensusPlusCheckButton2 =
		CreateFrame(
			"CheckButton",
			"CensusPlusCheckButton2",
			CensusPlusOptions,
			"InterfaceOptionsCheckButtonTemplate"
		)
	CensusPlusCheckButton2:SetPoint(
		"TOPLEFT",
		CensusPlusCheckButton1,
		"BOTTOMLEFT",
		0,
		-4
	)
	CensusPlusCheckButton2:SetScript("OnClick", function(self)
		local g_AW_Stealth = CensusPlusCheckButton2:GetChecked()
		if g_AW_Stealth then
			CensusPlus_Database["Info"]["Stealth"] = true
			CensusPlus_Database["Info"]["Verbose"] = false
			CensusPlusCheckButton1:SetChecked(false)
			Options:CensusPlus_Verbose(self)
		else
			CensusPlus_Database["Info"]["Stealth"] = false
		end
		Options:CensusPlus_Stealth(self)
	end)
	CensusPlusCheckButton2Text:SetText(CENSUS_OPTIONS_STEALTH)
	CensusPlusCheckButton2.tooltipText = CENSUS_OPTIONS_STEALTH_TOOLTIP

	--Create Frame tri-selector button (CO - Stealth - enable)
	CensusPlusOptionsRadioButton_C2a =
		CreateFrame(
			"CheckButton",
			"CensusPlusOptionsRadioButton_C2a",
			CensusPlusOptions,
			"UIRadioButtonTemplate"
		)
	CensusPlusOptionsRadioButton_C2a:SetHeight(20)
	CensusPlusOptionsRadioButton_C2a:SetWidth(20)
	CensusPlusOptionsRadioButton_C2a:SetHitRectInsets(0, -5, 0, 0)
	CensusPlusOptionsRadioButton_C2a:ClearAllPoints()
	CensusPlusOptionsRadioButton_C2a:SetPoint(
		"TOPLEFT",
		CensusPlusCheckButton2,
		"TOPRIGHT",
		210,
		0
	)
	CensusPlusOptionsRadioButton_C2a:SetChecked(false)
	CensusPlusOptionsRadioButton_C2a:SetScript("OnEnter", function(self)
		if self.tooltipText then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1)
		end
		if self.tooltipRequirement then
			GameTooltip:AddLine(self.tooltipRequirement, 1.0, 1.0, 1.0, 1.0)
			GameTooltip:Show()
		end
	end)
	CensusPlusOptionsRadioButton_C2a:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	CensusPlusOptionsRadioButton_C2a:SetScript("OnClick", function(self)
		local g_CO_Stealth = CensusPlusOptionsRadioButton_C2a:GetChecked()
		if g_CO_Stealth then
			CensusPlusOptionsRadioButton_C2b:SetChecked(false)
			CensusPlusOptionsRadioButton_C2c:SetChecked(false)
			CensusPlus_PerCharInfo["Stealth"] = true
			CensusPlus_PerCharInfo["Verbose"] = false
			CensusPlusOptionsRadioButton_C1a:SetChecked(false)
			CensusPlusOptionsRadioButton_C1b:SetChecked(true)
			CensusPlusOptionsRadioButton_C1c:SetChecked(false)
			Options:CensusPlus_Verbose(self)
		elseif not CensusPlusOptionsRadioButton_C2b:GetChecked() then
			CensusPlusOptionsRadioButton_C2c:SetChecked(true)
			CensusPlus_PerCharInfo["Stealth"] = nil
		end
		Options:CensusPlus_Stealth(self)
	end)
	CensusPlusOptionsRadioButton_C2a.tooltipText = ENABLE

	--Create Frame tri-selector button (CO - Stealth - disable)
	CensusPlusOptionsRadioButton_C2b =
		CreateFrame(
			"CheckButton",
			"CensusPlusOptionsRadioButton_C2b",
			CensusPlusOptions,
			"UIRadioButtonTemplate"
		)
	CensusPlusOptionsRadioButton_C2b:SetHeight(20)
	CensusPlusOptionsRadioButton_C2b:SetWidth(20)
	CensusPlusOptionsRadioButton_C2b:SetHitRectInsets(0, -5, 0, 0)
	CensusPlusOptionsRadioButton_C2b:ClearAllPoints()
	CensusPlusOptionsRadioButton_C2b:SetPoint(
		"TOPLEFT",
		CensusPlusOptionsRadioButton_C2a,
		"TOPRIGHT",
		20,
		0
	)
	CensusPlusOptionsRadioButton_C2b:SetChecked(false)
	CensusPlusOptionsRadioButton_C2b:SetScript("OnEnter", function(self)
		if self.tooltipText then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1)
		end
		if self.tooltipRequirement then
			GameTooltip:AddLine(self.tooltipRequirement, 1.0, 1.0, 1.0, 1.0)
			GameTooltip:Show()
		end
	end)
	CensusPlusOptionsRadioButton_C2b:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	CensusPlusOptionsRadioButton_C2b:SetScript("OnClick", function(self)
		local g_CO_Stealth = CensusPlusOptionsRadioButton_C2b:GetChecked()
		if g_CO_Stealth then
			CensusPlusOptionsRadioButton_C2a:SetChecked(false)
			CensusPlusOptionsRadioButton_C2c:SetChecked(false)
			CensusPlus_PerCharInfo["Stealth"] = false --if(not(CensusPlusOptionsRadioButton_C2a:GetChecked()) )then
		else
			CensusPlusOptionsRadioButton_C2c:SetChecked(true)
			CensusPlus_PerCharInfo["Stealth"] = nil
			if CensusPlusOptionsRadioButton_C1a:GetChecked() then
				CensusPlusOptionsRadioButton_C1a:SetChecked(false)
				CensusPlusOptionsRadioButton_C1c:SetChecked(true)
				CensusPlus_PerCharInfo["Verbose"] = nil
				Options:CensusPlus_Verbose(self)
			end
		end
		Options:CensusPlus_Stealth(self)
	end)
	CensusPlusOptionsRadioButton_C2b.tooltipText = DISABLE

	--Create Frame tri-selector button (CO - Stealth - remove)
	CensusPlusOptionsRadioButton_C2c =
		CreateFrame(
			"CheckButton",
			"CensusPlusOptionsRadioButton_C2c",
			CensusPlusOptions,
			"UIRadioButtonTemplate"
		)
	CensusPlusOptionsRadioButton_C2c:SetHeight(20)
	CensusPlusOptionsRadioButton_C2c:SetWidth(20)
	CensusPlusOptionsRadioButton_C2c:SetHitRectInsets(0, -5, 0, 0)
	CensusPlusOptionsRadioButton_C2c:ClearAllPoints()
	CensusPlusOptionsRadioButton_C2c:SetPoint(
		"TOPLEFT",
		CensusPlusOptionsRadioButton_C2b,
		"TOPRIGHT",
		20,
		0
	)
	CensusPlusOptionsRadioButton_C2c:SetChecked(true)
	_G[CensusPlusOptionsRadioButton_C2c:GetName() .. "Text"]:SetText(
		CENSUS_OPTIONS_STEALTH .. " " .. CENSUSPLUS_OPTIONS_OVERRIDE
	)
	CensusPlusOptionsRadioButton_C2c:SetScript("OnEnter", function(self)
		if self.tooltipText then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1)
		end
		if self.tooltipRequirement then
			GameTooltip:AddLine(self.tooltipRequirement, 1.0, 1.0, 1.0, 1.0)
			GameTooltip:Show()
		end
	end)
	CensusPlusOptionsRadioButton_C2c:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	CensusPlusOptionsRadioButton_C2c:SetScript("OnClick", function(self)
		local g_CO_Stealth = CensusPlusOptionsRadioButton_C2c:GetChecked()
		if g_CO_Stealth then
			CensusPlusOptionsRadioButton_C2b:SetChecked(false)
			CensusPlusOptionsRadioButton_C2a:SetChecked(false)
			CensusPlus_PerCharInfo["Stealth"] = nil
			if (CensusPlusCheckButton2:GetChecked() and CensusPlusOptionsRadioButton_C1a:GetChecked()) then
				CensusPlusOptionsRadioButton_C1a:SetChecked(false)
				CensusPlusOptionsRadioButton_C1c:SetChecked(true)
				CensusPlus_PerCharInfo["Verbose"] = nil
				Options:CensusPlus_Verbose(self)
			end
			--CensusPlusOptionsRadioButton_C2c:SetChecked(true)
		elseif not (CensusPlusOptionsRadioButton_C2a:GetChecked() or CensusPlusOptionsRadioButton_C2b:GetChecked()) then
			CensusPlus_PerCharInfo["Stealth"] = nil
		end
		Options:CensusPlus_Stealth(self)
	end)
	CensusPlusOptionsRadioButton_C2c.tooltipText =
		CENSUS_OPTIONS_CCO_REMOVE_OVERRIDE

	--Create Frame enable Census Button
	CensusPlusCheckButton3 =
		CreateFrame(
			"CheckButton",
			"CensusPlusCheckButton3",
			CensusPlusOptions,
			"InterfaceOptionsCheckButtonTemplate"
		)
	CensusPlusCheckButton3:SetPoint(
		"TOPLEFT",
		CensusPlusCheckButton2,
		"BOTTOMLEFT",
		2,
		-4
	)

	--CensusPlusOptionsWMZ
	CensusPlusCheckButton3:SetScript("OnClick", function(self)
		local g_AW_CensusButtonShown = CensusPlusCheckButton3:GetChecked()
		if g_AW_CensusButtonShown then
			CensusPlus_Database["Info"]["CensusButtonShown"] = true
		else
			CensusPlus_Database["Info"]["CensusButtonShown"] = false
			CensusPlus_Database["Info"]["CensusButtonAnimi"] = false
			CensusPlusCheckButton4:SetChecked(false)
			CPp.Options:CensusPlus_CensusButtonAnimi(self)
		end
		CPp.Options:CensusPlus_CensusButtonShown(self)
	end)
	CensusPlusCheckButton3Text:SetText(CENSUS_OPTIONS_BUTSHOW)
	CensusPlusCheckButton3.tooltipText = CENSUS_OPTIONS_BUTSHOW

	-- Create Frame tri-selector button (CO - CensusPlusClassic Button - enable)
	CensusPlusOptionsRadioButton_C3a =
		CreateFrame(
			"CheckButton",
			"CensusPlusOptionsRadioButton_C3a",
			CensusPlusOptions,
			"UIRadioButtonTemplate"
		)
	CensusPlusOptionsRadioButton_C3a:SetHeight(20)
	CensusPlusOptionsRadioButton_C3a:SetWidth(20)
	CensusPlusOptionsRadioButton_C3a:SetHitRectInsets(0, -5, 0, 0)
	CensusPlusOptionsRadioButton_C3a:ClearAllPoints()
	CensusPlusOptionsRadioButton_C3a:SetPoint(
		"TOPLEFT",
		CensusPlusCheckButton3,
		"TOPRIGHT",
		210,
		0
	)
	CensusPlusOptionsRadioButton_C3a:SetChecked(false)
	CensusPlusOptionsRadioButton_C3a:SetScript("OnEnter", function(self)
		if self.tooltipText then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1)
		end
		if self.tooltipRequirement then
			GameTooltip:AddLine(self.tooltipRequirement, 1.0, 1.0, 1.0, 1.0)
			GameTooltip:Show()
		end
	end)
	CensusPlusOptionsRadioButton_C3a:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	CensusPlusOptionsRadioButton_C3a:SetScript("OnClick", function(self)
		local g_CO_CensusButtonShown =
			CensusPlusOptionsRadioButton_C3a:GetChecked()
		if g_CO_CensusButtonShown then
			CensusPlusOptionsRadioButton_C3b:SetChecked(false)
			CensusPlusOptionsRadioButton_C3c:SetChecked(false)
			CensusPlus_PerCharInfo["CensusButtonShown"] = true -- if (not(CensusPlusOptionsRadioButton_C3b:GetChecked()) )then
		else
			CensusPlusOptionsRadioButton_C3c:SetChecked(true)
			CensusPlus_PerCharInfo["CensusButtonShown"] = nil
			if CensusPlusOptionsRadioButton_C4a:GetChecked() then
				CensusPlusOptionsRadioButton_C4a:SetChecked(false)
				CensusPlusOptionsRadioButton_C4c:SetChecked(true)
				CensusPlus_PerCharInfo["CensusButtonAnimi"] = nil
				CPp.Options:CensusPlus_CensusButtonAnimi(self)
			end
		end
		CPp.Options:CensusPlus_CensusButtonShown(self)
	end)
	CensusPlusOptionsRadioButton_C3a.tooltipText = ENABLE

	--Create Frame tri-selector button (CO - CensusPlusClassic Button - disable)
	CensusPlusOptionsRadioButton_C3b =
		CreateFrame(
			"CheckButton",
			"CensusPlusOptionsRadioButton_C3b",
			CensusPlusOptions,
			"UIRadioButtonTemplate"
		)
	CensusPlusOptionsRadioButton_C3b:SetHeight(20)
	CensusPlusOptionsRadioButton_C3b:SetWidth(20)
	CensusPlusOptionsRadioButton_C3b:SetHitRectInsets(0, -5, 0, 0)
	CensusPlusOptionsRadioButton_C3b:ClearAllPoints()
	CensusPlusOptionsRadioButton_C3b:SetPoint(
		"TOPLEFT",
		CensusPlusOptionsRadioButton_C3a,
		"TOPRIGHT",
		20,
		0
	)
	CensusPlusOptionsRadioButton_C3b:SetChecked(false)
	CensusPlusOptionsRadioButton_C3b:SetScript("OnEnter", function(self)
		if self.tooltipText then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1)
		end
		if self.tooltipRequirement then
			GameTooltip:AddLine(self.tooltipRequirement, 1.0, 1.0, 1.0, 1.0)
			GameTooltip:Show()
		end
	end)
	CensusPlusOptionsRadioButton_C3b:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	CensusPlusOptionsRadioButton_C3b:SetScript("OnClick", function(self)
		local g_CO_CensusButtonShown =
			CensusPlusOptionsRadioButton_C3b:GetChecked()
		if g_CO_CensusButtonShown then
			CensusPlusOptionsRadioButton_C3a:SetChecked(false)
			CensusPlusOptionsRadioButton_C3c:SetChecked(false)
			CensusPlus_PerCharInfo["CensusButtonShown"] = false
			if (CensusPlusCheckButton4:GetChecked() or CensusPlusOptionsRadioButton_C4a:GetChecked()) then
				CensusPlusOptionsRadioButton_C4a:SetChecked(false)
				CensusPlusOptionsRadioButton_C4b:SetChecked(true)
				CensusPlusOptionsRadioButton_C4c:SetChecked(false)
				CensusPlus_PerCharInfo["CensusButtonAnimi"] = false
				CPp.Options:CensusPlus_CensusButtonAnimi(self)
			end --if (not(CensusPlusOptionsRadioButton_C3a:GetChecked()) )then
		else
			CensusPlusOptionsRadioButton_C3c:SetChecked(true)
			CensusPlus_PerCharInfo["CensusButtonShown"] = nil
		end
		CPp.Options:CensusPlus_CensusButtonShown(self)
	end)
	CensusPlusOptionsRadioButton_C3b.tooltipText = DISABLE

	--Create Frame tri-selector button (CO - CensusPlusClassic Button - remove)
	CensusPlusOptionsRadioButton_C3c =
		CreateFrame(
			"CheckButton",
			"CensusPlusOptionsRadioButton_C3c",
			CensusPlusOptions,
			"UIRadioButtonTemplate"
		)
	CensusPlusOptionsRadioButton_C3c:SetHeight(20)
	CensusPlusOptionsRadioButton_C3c:SetWidth(20)
	CensusPlusOptionsRadioButton_C3c:SetHitRectInsets(0, -5, 0, 0)
	CensusPlusOptionsRadioButton_C3c:ClearAllPoints()
	CensusPlusOptionsRadioButton_C3c:SetPoint(
		"TOPLEFT",
		CensusPlusOptionsRadioButton_C3b,
		"TOPRIGHT",
		20,
		0
	)
	CensusPlusOptionsRadioButton_C3c:SetChecked(true)
	_G[CensusPlusOptionsRadioButton_C3c:GetName() .. "Text"]:SetText(
		CENSUS_OPTIONS_BUTSHOW .. " " .. CENSUSPLUS_OPTIONS_OVERRIDE
	)
	CensusPlusOptionsRadioButton_C3c:SetScript("OnEnter", function(self)
		if self.tooltipText then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1)
		end
		if self.tooltipRequirement then
			GameTooltip:AddLine(self.tooltipRequirement, 1.0, 1.0, 1.0, 1.0)
			GameTooltip:Show()
		end
	end)
	CensusPlusOptionsRadioButton_C3c:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	CensusPlusOptionsRadioButton_C3c:SetScript("OnClick", function(self)
		local g_CO_CensusButtonShown =
			CensusPlusOptionsRadioButton_C3c:GetChecked()
		if g_CO_CensusButtonShown then
			CensusPlusOptionsRadioButton_C3b:SetChecked(false)
			CensusPlusOptionsRadioButton_C3a:SetChecked(false)
			CensusPlus_PerCharInfo["CensusButtonShown"] = nil
		elseif not (CensusPlusOptionsRadioButton_C3a:GetChecked() or CensusPlusOptionsRadioButton_C3b:GetChecked()) then
			CensusPlusOptionsRadioButton_C3c:SetChecked(true)
			CensusPlus_PerCharInfo["CensusButtonShown"] = nil
		end
		CPp.Options:CensusPlus_CensusButtonShown(self)
	end)
	CensusPlusOptionsRadioButton_C3c.tooltipText =
		CENSUS_OPTIONS_CCO_REMOVE_OVERRIDE

	--Create Frame CensusButton Animation
	CensusPlusCheckButton4 =
		CreateFrame(
			"CheckButton",
			"CensusPlusCheckButton4",
			CensusPlusOptions,
			"InterfaceOptionsCheckButtonTemplate"
		)
	CensusPlusCheckButton4:SetPoint(
		"TOPLEFT",
		CensusPlusCheckButton3,
		"BOTTOMLEFT",
		0,
		-4
	)
	CensusPlusCheckButton4:SetScript("OnClick", function(self)
		local g_AWCensusButtonAnimi = CensusPlusCheckButton4:GetChecked()
		if g_AWCensusButtonAnimi then
			CensusPlus_Database["Info"]["CensusButtonAnimi"] = true
			CensusPlus_Database["Info"]["CensusButtonShown"] = true
			CensusPlusCheckButton3:SetChecked(true)
			CPp.Options:CensusPlus_CensusButtonShown(self)
		else
			CensusPlus_Database["Info"]["CensusButtonAnimi"] = false
		end
		CPp.Options:CensusPlus_CensusButtonAnimi(self)
	end)
	CensusPlusCheckButton4Text:SetText(CENSUSPLUS_CENSUSBUTTONANIMITEXT)
	CensusPlusCheckButton4.tooltipText =
		ENABLE .. " " .. CENSUSPLUS_CENSUSBUTTONANIMITEXT

	--Create Frame tri-selector button (CO - Census button animation - enable)
	CensusPlusOptionsRadioButton_C4a =
		CreateFrame(
			"CheckButton",
			"CensusPlusOptionsRadioButton_C4a",
			CensusPlusOptions,
			"UIRadioButtonTemplate"
		)
	CensusPlusOptionsRadioButton_C4a:SetHeight(20)
	CensusPlusOptionsRadioButton_C4a:SetWidth(20)
	CensusPlusOptionsRadioButton_C4a:SetHitRectInsets(0, -5, 0, 0)
	CensusPlusOptionsRadioButton_C4a:ClearAllPoints()
	CensusPlusOptionsRadioButton_C4a:SetPoint(
		"TOPLEFT",
		CensusPlusCheckButton4,
		"TOPRIGHT",
		210,
		0
	)
	CensusPlusOptionsRadioButton_C4a:SetChecked(false)
	CensusPlusOptionsRadioButton_C4a:SetScript("OnEnter", function(self)
		if self.tooltipText then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1)
		end
		if self.tooltipRequirement then
			GameTooltip:AddLine(self.tooltipRequirement, 1.0, 1.0, 1.0, 1.0)
			GameTooltip:Show()
		end
	end)
	CensusPlusOptionsRadioButton_C4a:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	CensusPlusOptionsRadioButton_C4a:SetScript("OnClick", function(self)
		local g_CO_CPBAnimi = CensusPlusOptionsRadioButton_C4a:GetChecked()
		if g_CO_CPBAnimi then
			CensusPlusOptionsRadioButton_C4b:SetChecked(false)
			CensusPlusOptionsRadioButton_C4c:SetChecked(false)
			CensusPlus_PerCharInfo["CensusButtonAnimi"] = true
			CensusPlusOptionsRadioButton_C3a:SetChecked(true)
			CensusPlusOptionsRadioButton_C3b:SetChecked(false)
			CensusPlusOptionsRadioButton_C3c:SetChecked(false)
			CensusPlus_PerCharInfo["CensusButtonShown"] = true
			CPp.Options:CensusPlus_CensusButtonShown(self)
		elseif not CensusPlusOptionsRadioButton_C4a:GetChecked() then
			CensusPlusOptionsRadioButton_C4c:SetChecked(true)
			CensusPlus_PerCharInfo["CensusButtonAnimi"] = nil
		end
		CPp.Options:CensusPlus_CensusButtonAnimi(self)
	end)
	CensusPlusOptionsRadioButton_C4a.tooltipText = ENABLE

	--Create Frame tri-selector button (CO - Census button animation - disable)
	CensusPlusOptionsRadioButton_C4b =
		CreateFrame(
			"CheckButton",
			"CensusPlusOptionsRadioButton_C4b",
			CensusPlusOptions,
			"UIRadioButtonTemplate"
		)
	CensusPlusOptionsRadioButton_C4b:SetHeight(20)
	CensusPlusOptionsRadioButton_C4b:SetWidth(20)
	CensusPlusOptionsRadioButton_C4b:SetHitRectInsets(0, -5, 0, 0)
	CensusPlusOptionsRadioButton_C4b:ClearAllPoints()
	CensusPlusOptionsRadioButton_C4b:SetPoint(
		"TOPLEFT",
		CensusPlusOptionsRadioButton_C4a,
		"TOPRIGHT",
		20,
		0
	)
	CensusPlusOptionsRadioButton_C4b:SetChecked(false)
	CensusPlusOptionsRadioButton_C4b:SetScript("OnEnter", function(self)
		if self.tooltipText then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1)
		end
		if self.tooltipRequirement then
			GameTooltip:AddLine(self.tooltipRequirement, 1.0, 1.0, 1.0, 1.0)
			GameTooltip:Show()
		end
	end)
	CensusPlusOptionsRadioButton_C4b:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	CensusPlusOptionsRadioButton_C4b:SetScript("OnClick", function(self)
		local g_CO_CPBAnimi = CensusPlusOptionsRadioButton_C4b:GetChecked()
		if g_CO_CPBAnimi then
			CensusPlusOptionsRadioButton_C4a:SetChecked(false)
			CensusPlusOptionsRadioButton_C4c:SetChecked(false)
			CensusPlus_PerCharInfo["CensusButtonAnimi"] = false --if (not(CensusPlusOptionsRadioButton_C4a:GetChecked()))then
		else
			CensusPlusOptionsRadioButton_C4c:SetChecked(true)
			CensusPlus_PerCharInfo["CensusButtonAnimi"] = nil
		end
		CPp.Options:CensusPlus_CensusButtonAnimi(self)
	end)
	CensusPlusOptionsRadioButton_C4b.tooltipText = DISABLE

	--Create Frame tri-selector button (CO - Census button animation - remove)
	CensusPlusOptionsRadioButton_C4c =
		CreateFrame(
			"CheckButton",
			"CensusPlusOptionsRadioButton_C4c",
			CensusPlusOptions,
			"UIRadioButtonTemplate"
		)
	CensusPlusOptionsRadioButton_C4c:SetHeight(20)
	CensusPlusOptionsRadioButton_C4c:SetWidth(20)
	CensusPlusOptionsRadioButton_C4c:SetHitRectInsets(0, -5, 0, 0)
	CensusPlusOptionsRadioButton_C4c:ClearAllPoints()
	CensusPlusOptionsRadioButton_C4c:SetPoint(
		"TOPLEFT",
		CensusPlusOptionsRadioButton_C4b,
		"TOPRIGHT",
		20,
		0
	)
	CensusPlusOptionsRadioButton_C4c:SetChecked(true)
	_G[CensusPlusOptionsRadioButton_C4c:GetName() .. "Text"]:SetText(
		CENSUSPLUS_CENSUSBUTTONANIMITEXT .. " " .. CENSUSPLUS_OPTIONS_OVERRIDE
	)
	CensusPlusOptionsRadioButton_C4c:SetScript("OnEnter", function(self)
		if self.tooltipText then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1)
		end
		if self.tooltipRequirement then
			GameTooltip:AddLine(self.tooltipRequirement, 1.0, 1.0, 1.0, 1.0)
			GameTooltip:Show()
		end
	end)
	CensusPlusOptionsRadioButton_C4c:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	CensusPlusOptionsRadioButton_C4c:SetScript("OnClick", function(self)
		local g_CO_CPBAnimi = CensusPlusOptionsRadioButton_C4c:GetChecked()
		if g_CO_CPBAnimi then
			CensusPlusOptionsRadioButton_C4b:SetChecked(false)
			CensusPlusOptionsRadioButton_C4a:SetChecked(false)
			CensusPlus_PerCharInfo["CensusButtonAnimi"] = nil
		elseif not (CensusPlusOptionsRadioButton_C4a:GetChecked() or CensusPlusOptionsRadioButton_C4b:GetChecked()) then
			CensusPlusOptionsRadioButton_C4c:SetChecked(true)
			CensusPlus_PerCharInfo["CensusButtonAnimi"] = nil
		end
		CPp.Options:CensusPlus_CensusButtonAnimi(self)
	end)
	CensusPlusOptionsRadioButton_C4c.tooltipText =
		CENSUS_OPTIONS_CCO_REMOVE_OVERRIDE

	-- Create Frame AutoCensus enable
	CensusPlusCheckButton5 =
		CreateFrame(
			"CheckButton",
			"CensusPlusCheckButton5",
			CensusPlusOptions,
			"InterfaceOptionsCheckButtonTemplate"
		)
	CensusPlusCheckButton5:SetPoint(
		"TOPLEFT",
		CensusPlusCheckButton4,
		"BOTTOMLEFT",
		0,
		-4
	)
	CensusPlusCheckButton5:SetScript("OnClick", function(self)
		local g_AW_AutoCensus = CensusPlusCheckButton5:GetChecked()
		if g_AW_AutoCensus then
			CensusPlus_Database["Info"]["AutoCensus"] = true
		else
			CensusPlus_Database["Info"]["AutoCensus"] = false
			CensusPlus_Database["Info"]["AutoCensusTimer"] = 1800
			if not CensusPlusOptionsRadioButton_C5a:GetChecked() then
				CensusPlusSlider1:SetValue(15)
			end
		end
		CPp.Options:CensusPlus_SetAutoCensus(self)
	end)
	CensusPlusCheckButton5Text:SetText(CENSUS_OPTIONS_AUTOCENSUS)
	CensusPlusCheckButton5.tooltipText = CENSUSPLUS_AUTOCENSUSTEXT

	--Create Frame tri-selector button (CO - CENSUS_OPTIONS_AUTOCENSUS - enable)
	CensusPlusOptionsRadioButton_C5a =
		CreateFrame(
			"CheckButton",
			"CensusPlusOptionsRadioButton_C5a",
			CensusPlusOptions,
			"UIRadioButtonTemplate"
		)
	CensusPlusOptionsRadioButton_C5a:SetHeight(20)
	CensusPlusOptionsRadioButton_C5a:SetWidth(20)
	CensusPlusOptionsRadioButton_C5a:SetHitRectInsets(0, -5, 0, 0)
	CensusPlusOptionsRadioButton_C5a:ClearAllPoints()
	CensusPlusOptionsRadioButton_C5a:SetPoint(
		"TOPLEFT",
		CensusPlusCheckButton5,
		"TOPRIGHT",
		210,
		0
	)
	CensusPlusOptionsRadioButton_C5a:SetChecked(false)
	CensusPlusOptionsRadioButton_C5a:SetScript("OnEnter", function(self)
		if self.tooltipText then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1)
		end
		if self.tooltipRequirement then
			GameTooltip:AddLine(self.tooltipRequirement, 1.0, 1.0, 1.0, 1.0)
			GameTooltip:Show()
		end
	end)
	CensusPlusOptionsRadioButton_C5a:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	CensusPlusOptionsRadioButton_C5a:SetScript("OnClick", function(self)
		local g_CO_CPAuto = CensusPlusOptionsRadioButton_C5a:GetChecked()
		if g_CO_CPAuto then
			CensusPlusOptionsRadioButton_C5b:SetChecked(false)
			CensusPlusOptionsRadioButton_C5c:SetChecked(false)
			CensusPlus_PerCharInfo["AutoCensus"] = true
			CensusPlus_PerCharInfo["AutoCensusTimer"] = 1800
			CensusPlusSlider1:SetValue(30)
			-- enable new override.. reset timer to 30 and disabled
			--print(CPp.AutoStartTimer) -- revert to AW settings
		elseif not CensusPlusOptionsRadioButton_C5b:GetChecked() then
			CensusPlusOptionsRadioButton_C5c:SetChecked(true)
			CensusPlus_PerCharInfo["AutoCensus"] = nil
			CensusPlus_PerCharInfo["AutoCensusTimer"] = 1800
			CensusPlusSlider1:SetValue(30)
			if CensusPlusCheckButton5:GetChecked() then
				CensusPlusSlider1:SetValue(CensusPlus_Database["Info"]["AutoCensusTimer"] / 60)
			else
			end
		end
		CPp.Options:CensusPlus_SetAutoCensus(self)
	end)
	CensusPlusOptionsRadioButton_C5a.tooltipText = ENABLE

	--Create Frame tri-selector button (CO - CENSUS_OPTIONS_AUTOCENSUS - disable)
	CensusPlusOptionsRadioButton_C5b =
		CreateFrame(
			"CheckButton",
			"CensusPlusOptionsRadioButton_C5b",
			CensusPlusOptions,
			"UIRadioButtonTemplate"
		)
	CensusPlusOptionsRadioButton_C5b:SetHeight(20)
	CensusPlusOptionsRadioButton_C5b:SetWidth(20)
	CensusPlusOptionsRadioButton_C5b:SetHitRectInsets(0, -5, 0, 0)
	CensusPlusOptionsRadioButton_C5b:ClearAllPoints()
	CensusPlusOptionsRadioButton_C5b:SetPoint(
		"TOPLEFT",
		CensusPlusOptionsRadioButton_C5a,
		"TOPRIGHT",
		20,
		0
	)
	CensusPlusOptionsRadioButton_C5b:SetChecked(false)
	CensusPlusOptionsRadioButton_C5b:SetScript("OnEnter", function(self)
		if self.tooltipText then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1)
		end
		if self.tooltipRequirement then
			GameTooltip:AddLine(self.tooltipRequirement, 1.0, 1.0, 1.0, 1.0)
			GameTooltip:Show()
		end
	end)
	CensusPlusOptionsRadioButton_C5b:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	CensusPlusOptionsRadioButton_C5b:SetScript("OnClick", function(self)
		local g_CO_CPAuto = CensusPlusOptionsRadioButton_C5b:GetChecked()
		if g_CO_CPAuto then
			CensusPlusOptionsRadioButton_C5a:SetChecked(false)
			CensusPlusOptionsRadioButton_C5c:SetChecked(false)
			CensusPlus_PerCharInfo["AutoCensus"] = false
			-- enable new override.. reset timer to 30 and disabled
			CensusPlus_PerCharInfo["AutoCensusTimer"] = 1800
			CensusPlusSlider1:SetValue(30)
			CPp.AutoStartText =
				CPp.AutoStartTimer .. " " .. CENSUS_OPTIONS_AUTOSTART .. " " .. ADDON_DISABLED
		elseif not CensusPlusOptionsRadioButton_C5a:GetChecked() then
			CensusPlusOptionsRadioButton_C5c:SetChecked(true)
			CensusPlus_PerCharInfo["AutoCensus"] = nil
			if CensusPlusCheckButton5:GetChecked() then
				CensusPlusSlider1:SetValue(CensusPlus_Database["Info"]["AutoCensusTimer"] / 60)
			end
		end
		CPp.Options:CensusPlus_SetAutoCensus(self)
	end)
	CensusPlusOptionsRadioButton_C5b.tooltipText = DISABLE

	--Create Frame tri-selector button (CO - CENSUS_OPTIONS_AUTOCENSUS - remove)
	CensusPlusOptionsRadioButton_C5c =
		CreateFrame(
			"CheckButton",
			"CensusPlusOptionsRadioButton_C5c",
			CensusPlusOptions,
			"UIRadioButtonTemplate"
		)
	CensusPlusOptionsRadioButton_C5c:SetHeight(20)
	CensusPlusOptionsRadioButton_C5c:SetWidth(20)
	CensusPlusOptionsRadioButton_C5c:SetHitRectInsets(0, -5, 0, 0)
	CensusPlusOptionsRadioButton_C5c:ClearAllPoints()
	CensusPlusOptionsRadioButton_C5c:SetPoint(
		"TOPLEFT",
		CensusPlusOptionsRadioButton_C5b,
		"TOPRIGHT",
		20,
		0
	)
	CensusPlusOptionsRadioButton_C5c:SetChecked(true)
	_G[CensusPlusOptionsRadioButton_C5c:GetName() .. "Text"]:SetText(
		CENSUS_OPTIONS_AUTOCENSUS .. " " .. CENSUSPLUS_OPTIONS_OVERRIDE
	)
	CensusPlusOptionsRadioButton_C5c:SetScript("OnEnter", function(self)
		if self.tooltipText then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1)
		end
		if self.tooltipRequirement then
			GameTooltip:AddLine(self.tooltipRequirement, 1.0, 1.0, 1.0, 1.0)
			GameTooltip:Show()
		end
	end)
	CensusPlusOptionsRadioButton_C5c:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	CensusPlusOptionsRadioButton_C5c:SetScript("OnClick", function(self)
		local g_CO_CPAuto = CensusPlusOptionsRadioButton_C5c:GetChecked()
		if g_CO_CPAuto then
			CensusPlusOptionsRadioButton_C5b:SetChecked(false)
			CensusPlusOptionsRadioButton_C5a:SetChecked(false)
			CensusPlus_PerCharInfo["AutoCensus"] = nil
			-- enable new override.. reset timer to 30 and disabled
			CensusPlus_PerCharInfo["AutoCensusTimer"] = 1800
			if CensusPlusCheckButton5:GetChecked() then
				CensusPlusSlider1:SetValue(CensusPlus_Database["Info"]["AutoCensusTimer"] / 60)
			else
				CensusPlusSlider1:SetValue(30)
			end
			CPp.Options:CensusPlus_SetAutoCensus(self)
		end
	end)
	CensusPlusOptionsRadioButton_C5c.tooltipText =
		CENSUS_OPTIONS_CCO_REMOVE_OVERRIDE

	--Create Frame Timer Slider
	CensusPlusSlider1 =
		CreateFrame(
			"Slider",
			"CensusPlusSlider1",
			CensusPlusOptions,
			"OptionsSliderTemplate"
		)
	CensusPlusSlider1:SetWidth(100)
	CensusPlusSlider1:SetHeight(20)
	CensusPlusSlider1:SetOrientation("HORIZONTAL")
	CensusPlusSlider1:SetMinMaxValues(5, 30)
	CensusPlusSlider1:SetObeyStepOnDrag(true)
	CensusPlusSlider1:SetValueStep(1)
	CensusPlusSlider1:SetValue(15)
	CensusPlusSlider1:SetThumbTexture(
		"Interface\\Buttons\\UI-SliderBar-Button-Horizontal"
	)
	CensusPlusSlider1:SetPoint(
		"TOPLEFT",
		CensusPlusCheckButton5,
		"BOTTOMLEFT",
		68,
		-8
	)
	CensusPlusSlider1:SetScript("OnValueChanged", function(self, value)
		CPp.AutoStartTimer = CensusPlusSlider1:GetValue()
	end)
	CensusPlusSlider1:SetScript("OnMouseUp", function(self, value)
		local value = CensusPlusSlider1:GetValue()
		local ovrride = false
		if CensusPlusOptionsRadioButton_C5a:GetChecked() then
			ovrride = true
		else
			ovrride = false
		end
		CensusPlus_TimerSet(self, value, ovrride)
	end)
	CensusPlusSlider1.tooltipText = CENSUS_OPTIONS_TIMER_TOOLTIP --Creates a tooltip on mouseover.
	_G[CensusPlusSlider1:GetName() .. "Low"]:SetText("5") --Sets the left-side slider text (default is "Low").
	_G[CensusPlusSlider1:GetName() .. "High"]:SetText("30") --Sets the right-side slider text (default is "High").
	_G[CensusPlusSlider1:GetName() .. "Text"]:SetText(
		CENSUSPLUS_AUTOCENSUS_DELAYTIME
	) --Sets the "title" text (top-centre of slider).
	CensusPlusSlider1:Enable()

	--Create Frame Enable FinishSound
	CensusPlusCheckButton6 =
		CreateFrame(
			"CheckButton",
			"CensusPlusCheckButton6",
			CensusPlusOptions,
			"InterfaceOptionsCheckButtonTemplate"
		)
	CensusPlusCheckButton6:SetPoint(
		"TOPLEFT",
		CensusPlusSlider1,
		"BOTTOMLEFT",
		-68,
		-12
	)
	CensusPlusCheckButton6:SetScript("OnClick", function(self)
		local g_AW_FinishSound = CensusPlusCheckButton6:GetChecked()
		if g_AW_FinishSound then
			CensusPlus_Database["Info"]["PlayFinishSound"] = true
		else
			CensusPlus_Database["Info"]["PlayFinishSound"] = false
		end
		CensusPlus_FinishSound(self)
	end)
	CensusPlusCheckButton6Text:SetText(CENSUS_OPTIONS_SOUND_ON_COMPLETE)
	CensusPlusCheckButton6.tooltipText = CENSUS_OPTIONS_SOUND_TOOLTIP

	--Create Frame tri-selector button (CO - CENSUS_OPTIONS_FinishSound- enable)
	CensusPlusOptionsRadioButton_C6a =
		CreateFrame(
			"CheckButton",
			"CensusPlusOptionsRadioButton_C6a",
			CensusPlusOptions,
			"UIRadioButtonTemplate"
		)
	CensusPlusOptionsRadioButton_C6a:SetHeight(20)
	CensusPlusOptionsRadioButton_C6a:SetWidth(20)
	CensusPlusOptionsRadioButton_C6a:SetHitRectInsets(0, -5, 0, 0)
	CensusPlusOptionsRadioButton_C6a:ClearAllPoints()
	CensusPlusOptionsRadioButton_C6a:SetPoint(
		"TOPLEFT",
		CensusPlusCheckButton6,
		"TOPRIGHT",
		210,
		0
	)
	CensusPlusOptionsRadioButton_C6a:SetChecked(false)
	CensusPlusOptionsRadioButton_C6a:SetScript("OnEnter", function(self)
		if self.tooltipText then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1)
		end
		if self.tooltipRequirement then
			GameTooltip:AddLine(self.tooltipRequirement, 1.0, 1.0, 1.0, 1.0)
			GameTooltip:Show()
		end
	end)
	CensusPlusOptionsRadioButton_C6a:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	CensusPlusOptionsRadioButton_C6a:SetScript("OnClick", function(self)
		local g_CO_CPSound = CensusPlusOptionsRadioButton_C6a:GetChecked()
		if g_CO_CPSound then
			CensusPlusOptionsRadioButton_C6b:SetChecked(false)
			CensusPlusOptionsRadioButton_C6c:SetChecked(false)
			CensusPlus_PerCharInfo["PlayFinishSound"] = true
		elseif not CensusPlusOptionsRadioButton_C6b:GetChecked() then
			CensusPlusOptionsRadioButton_C6c:SetChecked(true)
			CensusPlus_PerCharInfo["PlayFinishSound"] = nil
		end
		CensusPlus_FinishSound(self)
	end)
	CensusPlusOptionsRadioButton_C6a.tooltipText = ENABLE

	--Create Frame tri-selector button (CO - CENSUS_OPTIONS_FinishSound - disable)
	CensusPlusOptionsRadioButton_C6b =
		CreateFrame(
			"CheckButton",
			"CensusPlusOptionsRadioButton_C6b",
			CensusPlusOptions,
			"UIRadioButtonTemplate"
		)
	CensusPlusOptionsRadioButton_C6b:SetHeight(20)
	CensusPlusOptionsRadioButton_C6b:SetWidth(20)
	CensusPlusOptionsRadioButton_C6b:SetHitRectInsets(0, -5, 0, 0)
	CensusPlusOptionsRadioButton_C6b:ClearAllPoints()
	CensusPlusOptionsRadioButton_C6b:SetPoint(
		"TOPLEFT",
		CensusPlusOptionsRadioButton_C6a,
		"TOPRIGHT",
		20,
		0
	)
	CensusPlusOptionsRadioButton_C6b:SetChecked(false)
	CensusPlusOptionsRadioButton_C6b:SetScript("OnEnter", function(self)
		if self.tooltipText then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1)
		end
		if self.tooltipRequirement then
			GameTooltip:AddLine(self.tooltipRequirement, 1.0, 1.0, 1.0, 1.0)
			GameTooltip:Show()
		end
	end)
	CensusPlusOptionsRadioButton_C6b:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	CensusPlusOptionsRadioButton_C6b:SetScript("OnClick", function(self)
		local g_CO_CPSound = CensusPlusOptionsRadioButton_C6b:GetChecked()
		if g_CO_CPSound then
			CensusPlusOptionsRadioButton_C6a:SetChecked(false)
			CensusPlusOptionsRadioButton_C6c:SetChecked(false)
			CensusPlus_PerCharInfo["PlayFinishSound"] = false
		elseif not CensusPlusOptionsRadioButton_C6a:GetChecked() then
			CensusPlusOptionsRadioButton_C6c:SetChecked(true)
			CensusPlus_PerCharInfo["PlayFinishSound"] = nil
		end
		CensusPlus_FinishSound(self)
	end)
	CensusPlusOptionsRadioButton_C6b.tooltipText = DISABLE

	--Create Frame tri-selector button (CO - CENSUS_OPTIONS_FinishSound- remove)
	CensusPlusOptionsRadioButton_C6c =
		CreateFrame(
			"CheckButton",
			"CensusPlusOptionsRadioButton_C6c",
			CensusPlusOptions,
			"UIRadioButtonTemplate"
		)
	CensusPlusOptionsRadioButton_C6c:SetHeight(20)
	CensusPlusOptionsRadioButton_C6c:SetWidth(20)
	CensusPlusOptionsRadioButton_C6c:SetHitRectInsets(0, -5, 0, 0)
	CensusPlusOptionsRadioButton_C6c:ClearAllPoints()
	CensusPlusOptionsRadioButton_C6c:SetPoint(
		"TOPLEFT",
		CensusPlusOptionsRadioButton_C6b,
		"TOPRIGHT",
		20,
		0
	)
	CensusPlusOptionsRadioButton_C6c:SetChecked(true)
	_G[CensusPlusOptionsRadioButton_C6c:GetName() .. "Text"]:SetText(
		CENSUS_OPTIONS_SOUND_ON_COMPLETE .. " " .. CENSUSPLUS_OPTIONS_OVERRIDE
	)
	CensusPlusOptionsRadioButton_C6c:SetScript("OnEnter", function(self)
		if self.tooltipText then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1)
		end
		if self.tooltipRequirement then
			GameTooltip:AddLine(self.tooltipRequirement, 1.0, 1.0, 1.0, 1.0)
			GameTooltip:Show()
		end
	end)
	CensusPlusOptionsRadioButton_C6c:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	CensusPlusOptionsRadioButton_C6c:SetScript("OnClick", function(self)
		local g_CO_CPSound = CensusPlusOptionsRadioButton_C6c:GetChecked()
		if g_CO_CPSound then
			CensusPlusOptionsRadioButton_C6b:SetChecked(false)
			CensusPlusOptionsRadioButton_C6a:SetChecked(false)
			CensusPlus_PerCharInfo["PlayFinishSound"] = nil
		elseif not (CensusPlusOptionsRadioButton_C6a:GetChecked() or CensusPlusOptionsRadioButton_C6b:GetChecked()) then
			CensusPlusOptionsRadioButton_C6c:SetChecked(true)
			CensusPlus_PerCharInfo["PlayFinishSound"] = nil
		end
		CensusPlus_FinishSound(self)
	end)
	CensusPlusOptionsRadioButton_C6c.tooltipText =
		CENSUS_OPTIONS_CCO_REMOVE_OVERRIDE

	--Create Frame SoundFilesHeader
	CensusPlusOptionsSoundFilesHeader =
		CensusPlusOptions:CreateFontString(nil, "ARTWORK")
	CensusPlusOptionsSoundFilesHeader:SetFontObject(GameFontWhite)
	CensusPlusOptionsSoundFilesHeader:SetJustifyH("LEFT")
	CensusPlusOptionsSoundFilesHeader:SetJustifyV("TOP")
	CensusPlusOptionsSoundFilesHeader:ClearAllPoints()
	CensusPlusOptionsSoundFilesHeader:SetPoint(
		"TOPLEFT",
		CensusPlusCheckButton6,
		"BOTTOMLEFT",
		120,
		-4
	)
	CensusPlusOptionsSoundFilesHeader:SetText(CENSUS_OPTIONS_SOUNDFILETEXT)

	--Create Frame SoundFile select1
	CensusPlusSoundFile1Button =
		CreateFrame(
			"Button",
			"CensusPlusSoundFile1Button",
			CensusPlusOptions,
			"UIPanelButtonTemplate"
		)
	CensusPlusSoundFile1Button:SetWidth(25)
	CensusPlusSoundFile1Button:SetHeight(25)
	CensusPlusSoundFile1Button:SetPoint(
		"TOPLEFT",
		CensusPlusOptionsSoundFilesHeader,
		0,
		-15
	)
	CensusPlusSoundFile1Button:Enable()
	CensusPlusSoundFile1Button:SetText("1")
	CensusPlusSoundFile1Button:SetScript("OnClick", function(self)
		local willplay =
			PlaySoundFile(
				"Interface\\AddOns\\CensusPlusClassic\\sounds\\CensusComplete1.ogg",
				"Master"
			)
		if not willplay then
			PlaySoundFile(
				"Interface\\AddOns\\CensusPlusClassic\\sounds\\CensusComplete1.mp3",
				"Master"
			)
		end
		g_FinishSoundNumber = 1
		if CensusPlusOptionsRadioButton_C6a:GetChecked() then
			CensusPlus_PerCharInfo["SoundFile"] = g_FinishSoundNumber
		elseif CensusPlus_Database["Info"]["PlayFinishSound"] then
			CensusPlus_Database["Info"]["SoundFile"] = g_FinishSoundNumber
		end
	end)
	--CensusPlusSoundFile1Button:SetScript("OnMouseUp", function(self)
	--	PlaySoundFile("Interface\\AddOns\\CensusPlusClassic\\sounds\\CensusComplete1.ogg")
	--end)
	CensusPlusSoundFile1Button.tooltipText =
		CENSUS_OPTIONS_SOUNDFILEDEFAULT .. "1"

	--Create Frame SoundFile select2
	CensusPlusSoundFile2Button =
		CreateFrame(
			"Button",
			"CensusPlusSoundFile2Button",
			CensusPlusOptions,
			"UIPanelButtonTemplate"
		)
	CensusPlusSoundFile2Button:SetWidth(25)
	CensusPlusSoundFile2Button:SetHeight(25)
	CensusPlusSoundFile2Button:SetPoint(
		"TOPLEFT",
		CensusPlusSoundFile1Button,
		80,
		0
	)
	CensusPlusSoundFile2Button:Enable()
	CensusPlusSoundFile2Button:SetText("2")
	CensusPlusSoundFile2Button:SetScript("OnClick", function(self)
		local willplay =
			PlaySoundFile(
				"Interface\\AddOns\\CensusPlusClassic\\sounds\\CensusComplete2.ogg",
				"Master"
			)
		if not willplay then
			PlaySoundFile(
				"Interface\\AddOns\\CensusPlusClassic\\sounds\\CensusComplete2.mp3",
				"Master"
			)
		end
		g_FinishSoundNumber = 2
		if CensusPlusOptionsRadioButton_C6a:GetChecked() then
			CensusPlus_PerCharInfo["SoundFile"] = g_FinishSoundNumber
		elseif CensusPlus_Database["Info"]["PlayFinishSound"] then
			CensusPlus_Database["Info"]["SoundFile"] = g_FinishSoundNumber
		end
	end)
	--CensusPlusSoundFile2Button:SetScript("OnMouseUp", function(self)
	--	PlaySoundFile("Interface\\AddOns\\CensusPlusClassic\\sounds\\CensusComplete2.ogg")
	--end)
	CensusPlusSoundFile2Button.tooltipText =
		CENSUS_OPTIONS_SOUNDFILEDEFAULT .. "2"

	--Create Frame SoundFile select3
	CensusPlusSoundFile3Button =
		CreateFrame(
			"Button",
			"CensusPlusSoundFile2Button",
			CensusPlusOptions,
			"UIPanelButtonTemplate"
		)
	CensusPlusSoundFile3Button:SetWidth(25)
	CensusPlusSoundFile3Button:SetHeight(25)
	CensusPlusSoundFile3Button:SetPoint(
		"TOPLEFT",
		CensusPlusSoundFile2Button,
		80,
		0
	)
	CensusPlusSoundFile3Button:Enable()
	CensusPlusSoundFile3Button:SetText("3")
	CensusPlusSoundFile3Button:SetScript("OnClick", function(self)
		local willplay =
			PlaySoundFile(
				"Interface\\AddOns\\CensusPlusClassic\\sounds\\CensusComplete3.ogg",
				"Master"
			)
		if not willplay then
			PlaySoundFile(
				"Interface\\AddOns\\CensusPlusClassic\\sounds\\CensusComplete3.mp3",
				"Master"
			)
		end
		g_FinishSoundNumber = 3
		if CensusPlusOptionsRadioButton_C6a:GetChecked() then
			CensusPlus_PerCharInfo["SoundFile"] = g_FinishSoundNumber
		elseif CensusPlus_Database["Info"]["PlayFinishSound"] then
			CensusPlus_Database["Info"]["SoundFile"] = g_FinishSoundNumber
		end
	end)
	--CensusPlusSoundFile3Button:SetScript("OnMouseUp", function(self)
	--	PlaySoundFile("Interface\\AddOns\\CensusPlusClassic\\sounds\\CensusComplete3.ogg")
	--end)
	CensusPlusSoundFile3Button.tooltipText =
		CENSUS_OPTIONS_SOUNDFILEDEFAULT .. "3"

	--Create another frame..
	CensusPlusOptionsWMZ = CensusPlusOptions:CreateFontString(nil, "ARTWORK")
	CensusPlusOptionsWMZ:SetFontObject(GameFontWhite)
	CensusPlusOptionsWMZ:SetJustifyH("LEFT")
	CensusPlusOptionsWMZ:SetJustifyV("TOP")
	CensusPlusOptionsWMZ:ClearAllPoints()
	CensusPlusOptionsWMZ:SetPoint(
		"TOPLEFT",
		CensusPlusSoundFile1Button,
		"BOTTOMLEFT",
		-120,
		-4
	)
	CensusPlusOptionsWMZ:SetText(CENSUSPLUS_ACCOUNT_WIDE_ONLY_OPTIONS)

	--Create Frame Logarithmic  bars
	CensusPlusCheckButton7 =
		CreateFrame(
			"CheckButton",
			"CensusPlusCheckButton7",
			CensusPlusOptions,
			"InterfaceOptionsCheckButtonTemplate"
		)
	CensusPlusCheckButton7:SetPoint(
		"TOPLEFT",
		CensusPlusOptionsWMZ,
		"BOTTOMLEFT",
		0,
		-6
	)
	CensusPlusCheckButton7:SetChecked(true)
	CensusPlusCheckButton7:SetScript("OnClick", function(self)
		local g_AW_LogBars = CensusPlusCheckButton7:GetChecked()
		if g_AW_LogBars then
			CensusPlus_Database["Info"]["UseLogBars"] = true
		else
			CensusPlus_Database["Info"]["UseLogBars"] = false
		end
		--CensusPlus_FinishSound(self)
	end)
	CensusPlusCheckButton7Text:SetText(CENSUS_OPTIONS_LOG_BARS) --
	CensusPlusCheckButton7.tooltipText = CENSUS_OPTIONS_LOG_BARSTEXT

	--Create CensusPlusClassic.Background:alpha Slider
	local g_CPWin_background_alpha = 0.5
	CensusPlusSlider2 =
		CreateFrame(
			"Slider",
			"CensusPlusSlider2",
			CensusPlusOptions,
			"OptionsSliderTemplate"
		)
	CensusPlusSlider2:SetWidth(100)
	CensusPlusSlider2:SetHeight(20)
	CensusPlusSlider2:SetOrientation("HORIZONTAL")
	CensusPlusSlider2:SetMinMaxValues(0.1, 1.0)
	CensusPlusSlider2:SetObeyStepOnDrag(true)
	CensusPlusSlider2:SetValueStep(0.1)
	CensusPlusSlider2:SetValue(0.5)
	CensusPlusSlider2:SetThumbTexture(
		"Interface\\Buttons\\UI-SliderBar-Button-Horizontal"
	)
	CensusPlusSlider2:SetPoint(
		"TOPLEFT",
		CensusPlusCheckButton7,
		"BOTTOMLEFT",
		48,
		-15
	)
	CensusPlusSlider2:SetScript("OnValueChanged", function(self, value)
		g_CPWin_background_alpha = CensusPlusSlider2:GetValue()
	end)
	CensusPlusSlider2:SetScript("OnMouseUp", function(self, value)
		Options:SetBackgroundAlpha(g_CPWin_background_alpha)
		CensusPlusBackground:SetAlpha(g_CPWin_background_alpha)
		CensusPlayerListBackground:SetAlpha(g_CPWin_background_alpha)
	end)
	CensusPlusSlider2.tooltipText =
		CENSUS_OPTIONS_BACKGROUND_TRANSPARENCY_TOOLTIP --Creates a tooltip on mouseover.
	_G[CensusPlusSlider2:GetName() .. "Low"]:SetText("0.1") --Sets the left-side slider text (default is "Low").
	_G[CensusPlusSlider2:GetName() .. "High"]:SetText("1.0") --Sets the right-side slider text (default is "High").
	_G[CensusPlusSlider2:GetName() .. "Text"]:SetText(CENSUSPLUS_TRANSPARENCY) --Sets the "title" text (top-centre of slider).
	CensusPlusSlider2:Enable()


	--Create another frame..
	CensusPlusOptionsExperimental = CensusPlusOptions:CreateFontString(nil, "ARTWORK")
	CensusPlusOptionsExperimental:SetFontObject(GameFontWhite)
	CensusPlusOptionsExperimental:SetJustifyH("LEFT")
	CensusPlusOptionsExperimental:SetJustifyV("TOP")
	CensusPlusOptionsExperimental:ClearAllPoints()
	CensusPlusOptionsExperimental:SetPoint(
		"TOPLEFT",
		CensusPlusSlider2,
		"BOTTOMLEFT",
		-50,
		-20
	)
	CensusPlusOptionsExperimental:SetText("Semi automatic requests (requires UI reload)")

	CensusPlusCheckButton8 =
		CreateFrame(
			"CheckButton",
			"CensusPlusCheckButton8",
			CensusPlusOptions,
			"InterfaceOptionsCheckButtonTemplate"
		)
	CensusPlusCheckButton8:SetPoint(
		"TOPLEFT",
		CensusPlusOptionsExperimental,
		"BOTTOMLEFT",
		0,
		-6
	)
	CensusPlusCheckButton8:SetChecked(true)
	CensusPlusCheckButton8:SetScript("OnClick", function(self)
		currentOption = CensusPlus_Database["Info"]["UseWorldFrameClicks"]
		if currentOption then
			CensusPlus_Database["Info"]["UseWorldFrameClicks"] = false
		else
			CensusPlus_Database["Info"]["UseWorldFrameClicks"] = true
		end
	end)
	CensusPlusCheckButton8Text:SetText("Send who request on mouse clicks in world") --
	CensusPlusCheckButton8.tooltipText = "Sends a who request each time the user clicks into the 3D world. At minimum every 5 seconds."

end

function Options:CensusPlusCloseOptions() -- reset Interface Options frame to Blizzard default CONTROLS_LABEL =='Game.Controls'
	InterfaceOptionsFrame_OpenToCategory(CONTROLS_LABEL)
end


-- Then the Initialize function
function Options:Initialize()
    Options:CensusPlusBlizzardOptions()
end


-- Make Options module available to addon
CPp.Options = Options
