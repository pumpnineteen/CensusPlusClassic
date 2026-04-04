local	addon_name, addonTable = ...  
local CPp = addonTable.CPp or {}

-- Create module if it doesn't exist
if not CPp.Options then
    CPp.Options = {}
end

local Options = CPp.Options

-- Create a standard checkbox with label and tooltip
function Options:CreateCheckbox(parent, name, label, tooltip)
    local checkbox = CreateFrame("CheckButton", name, parent, "InterfaceOptionsCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    _G[checkbox:GetName().."Text"]:SetText(label)
    checkbox.tooltipText = tooltip
    return checkbox
end

-- Create a slider with given parameters
function Options:CreateSlider(parent, name, label, minVal, maxVal, step)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetWidth(100)
    slider:SetHeight(20)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    
    _G[slider:GetName().."Text"]:SetText(label)
    _G[slider:GetName().."Low"]:SetText(minVal)
    _G[slider:GetName().."High"]:SetText(maxVal)
    
    return slider
end

-- Create a radio button group
function Options:CreateRadioGroup(parent, name, options)
    local group = CreateFrame("Frame", name, parent)
    group.buttons = {}
    
    for i, option in ipairs(options) do
        local button = CreateFrame("CheckButton", name.."Button"..i, group, "UIRadioButtonTemplate")
        button:SetPoint("TOPLEFT", group, "TOPLEFT", (i-1)*20, 0)
        button.text = option.text
        button.value = option.value
        table.insert(group.buttons, button)
    end
    
    return group
end

-- Create a header text
function Options:CreateHeader(parent, text)
    local header = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge") 
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, -16)
    header:SetText(text)
    return header
end
