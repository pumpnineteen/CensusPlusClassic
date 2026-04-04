local	addon_name, addonTable = ...  
local CPp = addonTable.CPp or {}

local Layout = {}
CPp.Layout = Layout

-- Box definitions with default positions and sizes
local BOX_LAYOUTS = {
    default = {
        race = {
            x = 8,
            y = -107,
            width = 155,
            height = 121
        },
        class = {
            x = 210, 
            y = -107,
            width = 310,
            height = 121
        },
        guild = {
            x = 616,
            y = -107, 
            width = 212,
            height = 153
        },
        level = {
            x = 8,
            y = -309,
            width = 840,
            height = 123
        }
    }
}

function Layout:ApplyBoxLayout(boxName, layout)
    local box = BOX_LAYOUTS[layout or "default"][boxName]
    if not box then return end
    
    -- Get all existing box textures
    local upperName = boxName:upper()
    local frame = _G["CensusPlusClassic"]
    
    -- Find and adjust corner textures by searching through frame regions
    local function AdjustTexture(pattern, point, x, y)
        for _, region in ipairs({frame:GetRegions()}) do
            if region.GetTexCoord and region:GetPoint(1) and region:GetPoint(1):find(pattern) then
                region:ClearAllPoints()
                region:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
                break
            end
        end
    end
    
    -- Adjust corners
    AdjustTexture(boxName .. "%-TopLeft", "TOPLEFT", box.x, box.y)
    AdjustTexture(boxName .. "%-TopRight", "TOPLEFT", box.x + box.width - 32, box.y)
    AdjustTexture(boxName .. "%-BottomLeft", "TOPLEFT", box.x, box.y - box.height + 32)
    AdjustTexture(boxName .. "%-BottomRight", "TOPLEFT", box.x + box.width - 32, box.y - box.height + 32)
    
    -- Adjust borders
    AdjustTexture(boxName .. "%-Left", "TOPLEFT", box.x + 1, box.y - 15)
    AdjustTexture(boxName .. "%-Right", "TOPLEFT", box.x + box.width - 16, box.y - 15)
    AdjustTexture(boxName .. "%-Top", "TOPLEFT", box.x + 32, box.y - 1)
    AdjustTexture(boxName .. "%-Bottom", "TOPLEFT", box.x + 32, box.y - box.height + 16)
    
    -- Adjust border sizes
    for _, region in ipairs({frame:GetRegions()}) do
        if region.GetTexCoord and region:GetPoint(1) then
            local point = region:GetPoint(1)
            if point:find(boxName .. "%-Left") or point:find(boxName .. "%-Right") then
                region:SetHeight(box.height - 30)
            elseif point:find(boxName .. "%-Top") or point:find(boxName .. "%-Bottom") then
                region:SetWidth(box.width - 64)
            end
        end
    end
end

function Layout:ApplyLayout(layoutName)
    local layout = BOX_LAYOUTS[layoutName]
    if not layout then return end
    
    -- Apply each box layout without modifying frame anchors
    self:ApplyBoxLayout("race", layoutName)
    self:ApplyBoxLayout("class", layoutName)
    self:ApplyBoxLayout("guild", layoutName)
    self:ApplyBoxLayout("level", layoutName)
end

function Layout:Initialize()
    self:ApplyLayout("default")
end

return Layout


