local	addon_name, addonTable = ...  
local CPp = addonTable.CPp or {}

print(CPp.Msg)
-- Create module if it doesn't exist
if not CPp.Options then
    CPp.Options = {}
end

local Options = CPp.Options

local g_Options_confirm_txt = true;			-- enable chatty confirm of options until user no longer desires

function Options:CensusPlus_ResetConfig() -- reset to defaults
	CensusPlus_Database["Info"]["AutoCensus"] = true
	CensusPlus_PerCharInfo["AutoCensus"] = nil
	CensusPlus_Database["Info"]["Verbose"] = false
	CensusPlus_PerCharInfo["Verbose"] = nil
	CensusPlus_Database["Info"]["Stealth"] = false
	CensusPlus_PerCharInfo["Stealth"] = nil
	CensusPlus_Database["Info"]["PlayFinishSound"] = false
	CensusPlus_PerCharInfo["PlayFinishSound"] = nil
	CensusPlus_Database["Info"]["SoundFile"] = 1
	CensusPlus_PerCharInfo["SoundFile"] = 1
	CensusPlus_Database["Info"]["AutoCensusTimer"] = 1800
	CensusPlus_PerCharInfo["AutoCensusTimer"] = 1800
	CensusPlus_Database["Info"]["CensusButtonShown"] = true
	CensusPlus_PerCharInfo["CensusButtonShown"] = nil
	CensusPlus_Database["Info"]["CensusButtonAnimi"] = true
	CensusPlus_PerCharInfo["CensusButtonAnimi"] = nil
	CensusPlus_Database["Info"]["CPWindow_Transparency"] = 0.5
	CensusPlus_Database["Info"]["UseLogBars"] = true
	CensusPlus_Database["Info"]["UseWorldFrameClicks"] = false
	print("ResetConfig")
	Options:CensusPlusSetCheckButtonState()
end

function Options:CensusPlusSetCheckButtonState() -- set option check buttons and radio button states to match existing saved variables both AW and CCO - populate backup options tables
	CensusPlusCheckButton1:SetChecked(CensusPlus_Database["Info"]["Verbose"])
	CPp.Options_Holder["AccountWide"]["Verbose"] =
		CensusPlus_Database["Info"]["Verbose"]
	CPp.Options_Holder["CCOverrides"]["Verbose"] =
		CensusPlus_PerCharInfo["Verbose"]
	if (CensusPlus_PerCharInfo["Verbose"] == nil) then
		CensusPlusOptionsRadioButton_C1a:SetChecked(false)
		CensusPlusOptionsRadioButton_C1b:SetChecked(false)
		CensusPlusOptionsRadioButton_C1c:SetChecked(true)
	elseif (CensusPlus_PerCharInfo["Verbose"] == true) then
		CensusPlusOptionsRadioButton_C1a:SetChecked(true)
		CensusPlusOptionsRadioButton_C1b:SetChecked(false)
		CensusPlusOptionsRadioButton_C1c:SetChecked(false)
	else
		CensusPlusOptionsRadioButton_C1a:SetChecked(false)
		CensusPlusOptionsRadioButton_C1b:SetChecked(true)
		CensusPlusOptionsRadioButton_C1c:SetChecked(false)
	end
	Options:CensusPlus_Verbose(self)

	CensusPlusCheckButton2:SetChecked(CensusPlus_Database["Info"]["Stealth"])
	CPp.Options_Holder["AccountWide"]["Stealth"] =
		CensusPlus_Database["Info"]["Stealth"]
	CPp.Options_Holder["CCOverrides"]["Stealth"] =
		CensusPlus_PerCharInfo["Stealth"]
	if (CensusPlus_PerCharInfo["Stealth"] == nil) then
		CensusPlusOptionsRadioButton_C2a:SetChecked(false)
		CensusPlusOptionsRadioButton_C2b:SetChecked(false)
		CensusPlusOptionsRadioButton_C2c:SetChecked(true)
	elseif (CensusPlus_PerCharInfo["Stealth"] == true) then
		CensusPlusOptionsRadioButton_C2a:SetChecked(true)
		CensusPlusOptionsRadioButton_C2b:SetChecked(false)
		CensusPlusOptionsRadioButton_C2c:SetChecked(false)
	else
		CensusPlusOptionsRadioButton_C2a:SetChecked(false)
		CensusPlusOptionsRadioButton_C2b:SetChecked(true)
		CensusPlusOptionsRadioButton_C2c:SetChecked(false)
	end
	Options:CensusPlus_Stealth(self)

	CensusPlusCheckButton3:SetChecked(
		CensusPlus_Database["Info"]["CensusButtonShown"]
	)
	CPp.Options_Holder["AccountWide"]["CensusButtonShown"] =
		CensusPlus_Database["Info"]["CensusButtonShown"]
	CPp.Options_Holder["CCOverrides"]["CensusButtonShown"] =
		CensusPlus_PerCharInfo["CensusButtonShown"]
	if (CensusPlus_PerCharInfo["CensusButtonShown"] == nil) then
		CensusPlusOptionsRadioButton_C3a:SetChecked(false)
		CensusPlusOptionsRadioButton_C3b:SetChecked(false)
		CensusPlusOptionsRadioButton_C3c:SetChecked(true)
	elseif (CensusPlus_PerCharInfo["CensusButtonShown"] == true) then
		CensusPlusOptionsRadioButton_C3a:SetChecked(true)
		CensusPlusOptionsRadioButton_C3b:SetChecked(false)
		CensusPlusOptionsRadioButton_C3c:SetChecked(false)
	else
		CensusPlusOptionsRadioButton_C3a:SetChecked(false)
		CensusPlusOptionsRadioButton_C3b:SetChecked(true)
		CensusPlusOptionsRadioButton_C3c:SetChecked(false)
	end
	Options:CensusPlus_CensusButtonShown(self)

	CensusPlusCheckButton4:SetChecked(
		CensusPlus_Database["Info"]["CensusButtonAnimi"]
	)
	CPp.Options_Holder["AccountWide"]["CensusButtonAnimi"] =
		CensusPlus_Database["Info"]["CensusButtonAnimi"]
	CPp.Options_Holder["CCOverrides"]["CensusButtonAnimi"] =
		CensusPlus_PerCharInfo["CensusButtonAnimi"]
	if (CensusPlus_PerCharInfo["CensusButtonAnimi"] == nil) then
		CensusPlusOptionsRadioButton_C4a:SetChecked(false)
		CensusPlusOptionsRadioButton_C4b:SetChecked(false)
		CensusPlusOptionsRadioButton_C4c:SetChecked(true)
	elseif (CensusPlus_PerCharInfo["CensusButtonAnimi"] == true) then
		CensusPlusOptionsRadioButton_C4a:SetChecked(true)
		CensusPlusOptionsRadioButton_C4b:SetChecked(false)
		CensusPlusOptionsRadioButton_C4c:SetChecked(false)
	else
		CensusPlusOptionsRadioButton_C4a:SetChecked(false)
		CensusPlusOptionsRadioButton_C4b:SetChecked(true)
		CensusPlusOptionsRadioButton_C4c:SetChecked(false)
	end
	Options:CensusPlus_CensusButtonAnimi(self)

	CensusPlusCheckButton5:SetChecked(CensusPlus_Database["Info"]["AutoCensus"])
	CPp.Options_Holder["AccountWide"]["AutoCensus"] =
		CensusPlus_Database["Info"]["AutoCensus"]
	CPp.Options_Holder["CCOverrides"]["AutoCensus"] =
		CensusPlus_PerCharInfo["AutoCensus"]
	if (CensusPlus_PerCharInfo["AutoCensus"] == nil) then
		CensusPlusOptionsRadioButton_C5a:SetChecked(false)
		CensusPlusOptionsRadioButton_C5b:SetChecked(false)
		CensusPlusOptionsRadioButton_C5c:SetChecked(true)
	elseif (CensusPlus_PerCharInfo["AutoCensus"] == true) then
		CensusPlusOptionsRadioButton_C5a:SetChecked(true)
		CensusPlusOptionsRadioButton_C5b:SetChecked(false)
		CensusPlusOptionsRadioButton_C5c:SetChecked(false)
	else
		CensusPlusOptionsRadioButton_C5a:SetChecked(false)
		CensusPlusOptionsRadioButton_C5b:SetChecked(true)
		CensusPlusOptionsRadioButton_C5c:SetChecked(false)
	end
	Options:CensusPlus_SetAutoCensus(self)

	if (CensusPlus_PerCharInfo["AutoCensus"] == true) then
		CensusPlusSlider1:SetValue(
			CensusPlus_PerCharInfo["AutoCensusTimer"] / 60
		)
		CPp.Options_Holder["CCOverrides"]["AutoCensusTimer"] =
			CensusPlus_PerCharInfo["AutoCensusTimer"]
		CPp.AutoStartTimer = CensusPlus_PerCharInfo["AutoCensusTimer"] / 60
	end
	if ((CensusPlus_PerCharInfo["AutoCensus"] == nil) and (CensusPlus_Database["Info"]["AutoCensus"] == true)) then
		CensusPlusSlider1:SetValue(
			CensusPlus_Database["Info"]["AutoCensusTimer"] / 60
		)
		CPp.Options_Holder["AccountWide"]["AutoCensusTimer"] =
			CensusPlus_Database["Info"]["AutoCensusTimer"]
		CPp.AutoStartTimer = CensusPlus_Database["Info"]["AutoCensusTimer"] / 60
	end
	if ((CensusPlus_Database["Info"]["AutoCensus"] == false) and not (CensusPlus_PerCharInfo["AutoCensus"] == true)) then
		CensusPlusSlider1:SetValue(30)
	end

	CensusPlusSlider2:SetValue(
		CensusPlus_Database["Info"]["CPWindow_Transparency"]
	)
	CPp.Options_Holder["AccountWide"]["CPWindow_Transparency"] =
		CensusPlus_Database["Info"]["CPWindow_Transparency"]
	CensusPlusBackground:SetAlpha(
		CensusPlus_Database["Info"]["CPWindow_Transparency"]
	)
	CensusPlayerListBackground:SetAlpha(
		CensusPlus_Database["Info"]["CPWindow_Transparency"]
	)

	CensusPlusCheckButton6:SetChecked(
		CensusPlus_Database["Info"]["PlayFinishSound"]
	)
	CPp.Options_Holder["AccountWide"]["PlayFinishSound"] =
		CensusPlus_Database["Info"]["PlayFinishSound"]
	CPp.Options_Holder["CCOverrides"]["PlayFinishSound"] =
		CensusPlus_PerCharInfo["PlayFinishSound"]
	if (CensusPlus_PerCharInfo["PlayFinishSound"] == nil) then
		CensusPlusOptionsRadioButton_C6a:SetChecked(false)
		CensusPlusOptionsRadioButton_C6b:SetChecked(false)
		CensusPlusOptionsRadioButton_C6c:SetChecked(true)
	elseif (CensusPlus_PerCharInfo["PlayFinishSound"] == true) then
		CensusPlusOptionsRadioButton_C6a:SetChecked(true)
		CensusPlusOptionsRadioButton_C6b:SetChecked(false)
		CensusPlusOptionsRadioButton_C6c:SetChecked(false)
	else
		CensusPlusOptionsRadioButton_C6a:SetChecked(false)
		CensusPlusOptionsRadioButton_C6b:SetChecked(true)
		CensusPlusOptionsRadioButton_C6c:SetChecked(false)
	end

	CPp.Options_Holder["AccountWide"]["SoundFile"] =
		CensusPlus_Database["Info"]["SoundFile"]
	CPp.Options_Holder["CCOverrides"]["SoundFile"] =
		CensusPlus_PerCharInfo["SoundFile"]

	CPp.Options_Holder["AccountWide"]["UseLogBars"] =
		CensusPlus_Database["Info"]["UseLogBars"]
	CensusPlusCheckButton7:SetChecked(CensusPlus_Database["Info"]["UseLogBars"])
	g_AW_LogBars = CensusPlus_Database["Info"]["UseLogBars"]

	CensusPlusCheckButton8:SetChecked(CensusPlus_Database["Info"]["UseWorldFrameClicks"])

	--	CensusPlusCheckButton8:SetChecked(CensusPlus2["WMZ party4"])
	--	CensusPlusCheckButton9:SetChecked(CensusPlus2["show decimals"])
end

function Options:CensusPlusRestoreSettings() -- reset any changes to saved settings back to previous saved in backups
	-- account wide and CCO overrides
	CensusPlus_Database["Info"]["Verbose"] =
		CPp.Options_Holder["AccountWide"]["Verbose"]
	CensusPlus_PerCharInfo["Verbose"] =
		CPp.Options_Holder["CCOverrides"]["Verbose"]
	CensusPlus_Database["Info"]["Stealth"] =
		CPp.Options_Holder["AccountWide"]["Stealth"]
	CensusPlus_PerCharInfo["Stealth"] =
		CPp.Options_Holder["CCOverrides"]["Stealth"]
	CensusPlus_Database["Info"]["CensusButtonShown"] =
		CPp.Options_Holder["AccountWide"]["CensusButtonShown"]
	CensusPlus_PerCharInfo["CensusButtonShown"] =
		CPp.Options_Holder["CCOverrides"]["CensusButtonShown"]
	CensusPlus_Database["Info"]["CensusButtonAnimi"] =
		CPp.Options_Holder["AccountWide"]["CensusButtonAnimi"]
	CensusPlus_PerCharInfo["CensusButtonAnimi"] =
		CPp.Options_Holder["CCOverrides"]["CensusButtonAnimi"]
	CensusPlus_Database["Info"]["AutoCensus"] =
		CPp.Options_Holder["AccountWide"]["AutoCensus"]
	CensusPlus_PerCharInfo["AutoCensus"] =
		CPp.Options_Holder["CCOverrides"]["AutoCensus"]
	CensusPlus_Database["Info"]["AutoCensusTimer"] =
		CPp.Options_Holder["AccountWide"]["AutoCensusTimer"]
	CensusPlus_PerCharInfo["AutoCensusTimer"] =
		CPp.Options_Holder["CCOverrides"]["AutoCensusTimer"]
	CensusPlus_Database["Info"]["PlayFinishSound"] =
		CPp.Options_Holder["AccountWide"]["PlayFinishSound"]
	CensusPlus_PerCharInfo["PlayFinishSound"] =
		CPp.Options_Holder["CCOverrides"]["PlayFinishSound"]
	CensusPlus_Database["Info"]["SoundFile"] =
		CPp.Options_Holder["AccountWide"]["SoundFile"]
	CensusPlus_PerCharInfo["SoundFile"] =
		CPp.Options_Holder["CCOverrides"]["SoundFile"]
	-- account wide only
	CensusPlus_Database["Info"]["CPWindow_Transparency"] =
		CPp.Options_Holder["AccountWide"]["CPWindow_Transparency"]
	CensusPlus_Database["Info"]["UseLogBars"] =
		CPp.Options_Holder["AccountWide"]["UseLogBars"]
	Options:CensusPlusCloseOptions()
end

function Options:CensusPlusCloseOptions() 
    Settings.CloseUI()
end




function Options:CensusPlus_CensusButtonShown()
	--print(CensusPlus_Database["Info"]["CensusButtonShown"])
	--print(CensusPlus_PerCharInfo["CensusButtonShown"])
	if ((CensusPlus_PerCharInfo["CensusButtonShown"] == nil) and (CensusPlus_Database["Info"]["CensusButtonShown"] == true)) then
		Options:CensusPlus_CensusButtonShown_toggle("On")
		--_G[CensusButton:GetName().."Text"]:SetText("C+")
	elseif ((CensusPlus_PerCharInfo["CensusButtonShown"] == nil) and (CensusPlus_Database["Info"]["CensusButtonShown"] == false)) then
		Options:CensusPlus_CensusButtonShown_toggle("Off")
	elseif (CensusPlus_PerCharInfo["CensusButtonShown"] == true) then
		--CensusButton:SetText("30")
		Options:CensusPlus_CensusButtonShown_toggle("On")
	elseif (CensusPlus_PerCharInfo["CensusButtonShown"] == false) then
		Options:CensusPlus_CensusButtonShown_toggle("Off")
	else
	end
end

function Options:CensusPlus_CensusButtonShown_toggle(state)
	if (state == "alter") then
		if (g_CensusButtonShown == true) then
			g_CensusButtonShown = false
			CPp.Msg(CENSUSPLUS_CENSUSBUTTONSHOWNOFF)
			CensusButtonFrame:Hide()
		else
			g_CensusButtonShown = true
			CPp.Msg(CENSUSPLUS_CENSUSBUTTONSHOWNON)
			CensusButtonFrame:Show()
		end
	elseif (state == "On") then
		g_CensusButtonShown = true
		if (g_Options_confirm_txt and not (CPp.FirstLoad == true)) then
			CPp.Msg(CENSUSPLUS_CENSUSBUTTONSHOWNON)
		end
		CensusButtonFrame:Show()
	elseif (state == "Off") then
		g_CensusButtonShown = false
		if (g_Options_confirm_txt and not (CPp.FirstLoad == true)) then
			CPp.Msg(CENSUSPLUS_CENSUSBUTTONSHOWNOFF)
		end
		CensusButtonFrame:Hide()
	end
end

function Options:CensusPlus_CensusButtonAnimi()
	--print(CensusPlus_Database["Info"]["CensusButtonAnimi"])
	--print(CensusPlus_PerCharInfo["CensusButtonAnimi"])
	if ((CensusPlus_PerCharInfo["CensusButtonAnimi"] == nil) and (CensusPlus_Database["Info"]["CensusButtonAnimi"] == true)) then
		Options:CensusPlus_CensusButtonAnimi_toggle("On")
		--_G[CensusButton:GetName().."Text"]:SetText("C+")
	elseif ((CensusPlus_PerCharInfo["CensusButtonAnimi"] == nil) and (CensusPlus_Database["Info"]["CensusButtonAnimi"] == false)) then
		--print("CensusButtonAnimi 2")
		Options:CensusPlus_CensusButtonAnimi_toggle("Off")
	elseif (CensusPlus_PerCharInfo["CensusButtonAnimi"] == true) then
		--CensusButton:SetText("30")
		Options:CensusPlus_CensusButtonAnimi_toggle("On")
	elseif (CensusPlus_PerCharInfo["CensusButtonAnimi"] == false) then
		Options:CensusPlus_CensusButtonAnimi_toggle("Off")
	else
	end
end

function Options:CensusPlus_CensusButtonAnimi_toggle(state)
	if (state == "alter") then
		if (g_CensusButtonAnimi == true) then
			g_CensusButtonAnimi = false
			CPp.Msg(CENSUSPLUS_CENSUSBUTTONANIMIOFF)
			CensusButton:SetNormalFontObject(GameFontNormal)
			CensusButton:SetText("C+")
		else
			g_CensusButtonAnimi = true
			CPp.Msg(CENSUSPLUS_CENSUSBUTTONANIMION)
		end
		--CensusButtonFrame:Show()
	elseif (state == "On") then
		g_CensusButtonAnimi = true
		if (g_Options_confirm_txt and not (CPp.FirstLoad == true)) then
			CPp.Msg(CENSUSPLUS_CENSUSBUTTONANIMION)
		end
		--CensusButtonFrame:Show()
	elseif (state == "Off") then
		g_CensusButtonAnimi = false
		if (g_Options_confirm_txt and not (CPp.FirstLoad == true)) then
			CPp.Msg(CENSUSPLUS_CENSUSBUTTONANIMIOFF)
		end
		CensusButton:SetNormalFontObject(GameFontNormal)
		CensusButton:SetText("C+")
	end
end

function Options:CensusPlus_FinishSound(state)
	--print(CensusPlus_Database["Info"]["PlayFinishSound"])
	--print(CensusPlus_PerCharInfo["PlayFinishSound"])
	if ((CensusPlus_PerCharInfo["PlayFinishSound"] == nil) and (CensusPlus_Database["Info"]["PlayFinishSound"] == true)) then
		CensusPlus_FinishSound_toggle("On")
		--_G[CensusButton:GetName().."Text"]:SetText("C+")
	elseif ((CensusPlus_PerCharInfo["PlayFinishSound"] == nil) and (CensusPlus_Database["Info"]["PlayFinishSound"] == false)) then
		CensusPlus_FinishSound_toggle("Off")
	elseif (CensusPlus_PerCharInfo["PlayFinishSound"] == true) then
		--CensusButton:SetText("30")
		CensusPlus_FinishSound_toggle("On")
	elseif (CensusPlus_PerCharInfo["PlayFinishSound"] == false) then
		CensusPlus_FinishSound_toggle("Off")
	else
	end
end

function Options:CensusPlus_FinishSound_toggle(state)
	if (state == "alter") then
		if (g_PlayFinishSound == true) then
			g_PlayFinishSound = false
			CPp.Msg(CENSUSPLUS_PLAYFINISHSOUNDOFF)
		else
			g_PlayFinishSound = true
			CPp.Msg(CENSUSPLUS_PLAYFINISHSOUNDON)
		end
	elseif (state == "On") then
		g_PlayFinishSound = true
		if (g_Options_confirm_txt and not (CPp.FirstLoad == true)) then
			CPp.Msg(CENSUSPLUS_PLAYFINISHSOUNDON)
		end
	elseif (state == "Off") then
		g_PlayFinishSound = false
		if (g_Options_confirm_txt and not (CPp.FirstLoad == true)) then
			CPp.Msg(CENSUSPLUS_PLAYFINISHSOUNDOFF)
		end
	end
end

-- CensusPlusClassic Auto Census set flag
function Options:CensusPlus_SetAutoCensus()
	--print(CensusPlus_Database["Info"]["AutoCensus"])
	--print(CensusPlus_PerCharInfo["AutoCensus"])
	if ((CensusPlus_PerCharInfo["AutoCensus"] == nil) and (CensusPlus_Database["Info"]["AutoCensus"] == true)) then
		Options:CensusPlus_AutoCensus_toggle("On")
		--_G[CensusButton:GetName().."Text"]:SetText("C+")
	elseif ((CensusPlus_PerCharInfo["AutoCensus"] == nil) and (CensusPlus_Database["Info"]["AutoCensus"] == false)) then
		Options:CensusPlus_AutoCensus_toggle("Off")
	elseif (CensusPlus_PerCharInfo["AutoCensus"] == true) then
	    --CensusButton:SetText("30")
		Options:CensusPlus_AutoCensus_toggle("On")
	elseif (CensusPlus_PerCharInfo["AutoCensus"] == false) then
		Options:CensusPlus_AutoCensus_toggle("Off")
	else
		print("call AutoCensus farm")
	end
end

function Options:CensusPlus_AutoCensus_toggle(state)
	if (state == "alter") then
		if (CPp.AutoCensus == true) then
			CPp.AutoCensus = false
			CPp.Msg(CENSUSPLUS_AUTOCENSUSOFF)
		else
			CPp.AutoCensus = true
			CPp.Msg(CENSUSPLUS_AUTOCENSUSON)
		end
	elseif (state == "On") then
		CPp.AutoCensus = true
		if (g_Options_confirm_txt and not (CPp.FirstLoad == true)) then
			CPp.Msg(CENSUSPLUS_AUTOCENSUSON)
		end
	elseif (state == "Off") then
		CPp.AutoCensus = false
		if (g_Options_confirm_txt and not (CPp.FirstLoad == true)) then
			CPp.Msg(CENSUSPLUS_AUTOCENSUSOFF)
		end
	end
end

function Options:CensusPlus_Stealth()
	--print(CensusPlus_Database["Info"]["Stealth"])
	--print(CensusPlus_PerCharInfo["Stealth"])
	if ((CensusPlus_PerCharInfo["Stealth"] == nil) and (CensusPlus_Database["Info"]["Stealth"] == true)) then
		Options:CensusPlus_Stealth_toggle("On")
	elseif ((CensusPlus_PerCharInfo["Stealth"] == nil) and (CensusPlus_Database["Info"]["Stealth"] == false)) then
		Options:CensusPlus_Stealth_toggle("Off")
	elseif (CensusPlus_PerCharInfo["Stealth"] == true) then
		Options:CensusPlus_Stealth_toggle("On")
	elseif (CensusPlus_PerCharInfo["Stealth"] == false) then
		Options:CensusPlus_Stealth_toggle("Off")
	else
	end
end

function Options:CensusPlus_Stealth_toggle(state)
    local l_stealth = g_stealth
    local l_verbose = g_verbose
	if (state == "alter") then
		if (l_stealth == true) then
			l_stealth = false
			CPp.Msg(CENSUSPLUS_STEALTHOFF)
		else
			l_Verbose = false
			CPp.Msg(CENSUSPLUS_STEALTHON)
			l_stealth = true
		end
	elseif (state == "On") then
		g_Verbose = false
		if (g_Options_confirm_txt and not (CPp.FirstLoad == true)) then
			CPp.Msg(CENSUSPLUS_STEALTHON)
		end
		l_stealth = true
	elseif (state == "Off") then
		l_stealth = false
		if (g_Options_confirm_txt and not (CPp.FirstLoad == true)) then
			CPp.Msg(CENSUSPLUS_STEALTHOFF)
		end
	end
    g_stealth = l_stealth
    g_verbose = l_verbose
end

function Options:CensusPlus_Verbose()
	-- print("CPD:", CensusPlus_Database["Info"]["Verbose"])
	-- print("CPC:", CensusPlus_PerCharInfo["Verbose"])
	if ((CensusPlus_PerCharInfo["Verbose"] == nil) and (CensusPlus_Database["Info"]["Verbose"] == true)) then
		Options:CensusPlus_Verbose_toggle("On")
	elseif ((CensusPlus_PerCharInfo["Verbose"] == nil) and (CensusPlus_Database["Info"]["Verbose"] == false)) then
		Options:CensusPlus_Verbose_toggle("Off")
	elseif (CensusPlus_PerCharInfo["Verbose"] == true) then
		Options:CensusPlus_Verbose_toggle("On")
	elseif (CensusPlus_PerCharInfo["Verbose"] == false) then
		Options:CensusPlus_Verbose_toggle("Off")
	else
	end
end

function Options:CensusPlus_Verbose_toggle(state)
    -- print("Verbose state: "..state)
	if (state == "alter") then
		if (g_Verbose == true) then
			g_Verbose = false
			CPp.Msg(CENSUSPLUS_VERBOSEOFF)
		else
			g_Verbose = true
			g_stealth = false
			CPp.Msg(CENSUSPLUS_VERBOSEON)
		end
	elseif (state == "On") then
		g_Verbose = true
		g_stealth = false
		if (g_Options_confirm_txt and not (CPp.FirstLoad == true)) then
			CPp.Msg(CENSUSPLUS_VERBOSEON)
		end
	elseif (state == "Off") then
		g_Verbose = false
		if (g_Options_confirm_txt and not (CPp.FirstLoad == true)) then
			CPp.Msg(CENSUSPLUS_VERBOSEOFF)
		end
	end
end

-- Settings Access Functions
function Options:GetBackgroundAlpha()
    return CensusPlus_Database["Info"]["CPWindow_Transparency"] or 0.5
end

function Options:SetBackgroundAlpha(alpha)
    CensusPlus_Database["Info"]["CPWindow_Transparency"] = alpha
    -- Apply change immediately
    if CensusPlusBackground then
        CensusPlusBackground:SetAlpha(alpha)
    end
    if CensusPlayerListBackground then
        CensusPlayerListBackground:SetAlpha(alpha) 
    end
end

function Options:GetVerbose()
    -- Check character override first
    if CensusPlus_PerCharInfo["Verbose"] ~= nil then
        return CensusPlus_PerCharInfo["Verbose"]
    end
    -- Fall back to account-wide setting
    return CensusPlus_Database["Info"]["Verbose"]
end

function Options:SetVerbose(enabled)
    if g_Options_Scope == "CO" then
        CensusPlus_PerCharInfo["Verbose"] = enabled
    else
        CensusPlus_Database["Info"]["Verbose"] = enabled
    end
end

function Options:ResetConfig()
    -- Reset Account-wide settings
    CensusPlus_Database["Info"]["AutoCensus"] = true
    CensusPlus_Database["Info"]["Verbose"] = false
    CensusPlus_Database["Info"]["Stealth"] = false
    CensusPlus_Database["Info"]["PlayFinishSound"] = false
    CensusPlus_Database["Info"]["SoundFile"] = 1
    CensusPlus_Database["Info"]["AutoCensusTimer"] = 1800
    CensusPlus_Database["Info"]["CensusButtonShown"] = true
    CensusPlus_Database["Info"]["CensusButtonAnimi"] = true
    CensusPlus_Database["Info"]["CPWindow_Transparency"] = 0.5
    CensusPlus_Database["Info"]["UseLogBars"] = true
    CensusPlus_Database["Info"]["UseWorldFrameClicks"] = false

    -- Reset character-specific overrides
    CensusPlus_PerCharInfo["AutoCensus"] = nil
    CensusPlus_PerCharInfo["Verbose"] = nil
    CensusPlus_PerCharInfo["Stealth"] = nil
    CensusPlus_PerCharInfo["PlayFinishSound"] = nil
    CensusPlus_PerCharInfo["SoundFile"] = 1
    CensusPlus_PerCharInfo["AutoCensusTimer"] = 1800
    CensusPlus_PerCharInfo["CensusButtonShown"] = nil
    CensusPlus_PerCharInfo["CensusButtonAnimi"] = nil

    print("Settings reset to defaults")
    self:SetCheckButtonState()
end


-- Make Options module available to addon
CPp.Options = Options