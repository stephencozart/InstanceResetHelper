----------------------------------------------------------------------
-- Namespaces
----------------------------------------------------------------------
local _, core = ...

core.Config = {
    
}

local Config = core.Config


function core:copyDefaults(src, dst)
    -- If no source (defaults) is specified, return an empty table:
    if type(src) ~= "table" then return {} end
    -- If no target (saved variable) is specified, create a new table:
    if type(dst) ~= "table" then dst = {} end
    -- Loop through the source (defaults):
    for k, v in pairs(src) do
        -- If the value is a sub-table:
        if type(v) == "table" then
            -- Recursively call the function:
            dst[k] = core:copyDefaults(v, dst[k])
        -- Or if the default value type doesn't match the existing value type:
        elseif type(v) ~= type(dst[k]) then
            -- Overwrite the existing value with the default one:
            dst[k] = v
        end
    end
    -- Return the destination table:
    return dst
end

local ConfigUI

local UI = {}

function core:InitConfigUI(config, parent)

    local ScreenXMax = math.floor(GetScreenWidth())
    local ScreenXMin = 0
    local ScreenYMax = math.floor(GetScreenHeight())
    local ScreenYMin = 0;
    
    UI = parent

    ConfigUI = CreateFrame("Frame", "InstanceResetHelper_ConfigOptionsFrame", UIParent)
    ConfigUI.name = "Instance Reset Helper Options"
    ConfigUI.onCloseCallback = function()
        Config:Toggle()
    end
    ConfigUI:SetSize(450, 360)
    --ConfigUI:SetPoint("Center")
    --ConfigUI:SetShown(false)

    ConfigUI.title = ConfigUI:CreateFontString(nil, "Ovelay", "GameFontHighlight")
    ConfigUI.title:SetPoint("TOPLEFT", ConfigUI, "TOPLEFT", 20, -20)
    ConfigUI.title:SetText("Instance Reset Helper Options")

    ConfigUI.hideObjectivesCheckBox = CreateFrame("CheckButton", "InstanceHelper_HideObjectivesCheckbox", ConfigUI, "UICheckButtonTemplate")
    ConfigUI.hideObjectivesCheckBox:SetPoint("TOPLEFT", ConfigUI.title, "BOTTOMLEFT", 0, -30)
    ConfigUI.hideObjectivesCheckBox:SetChecked(config.hideObjectiveTracker)
    ConfigUI.hideObjectivesCheckBox:SetScript("OnClick", function(self)
        InstanceResetHelperDB["hideObjectiveTracker"] = self:GetChecked()
    end)

    InstanceHelper_HideObjectivesCheckbox.text:SetText("Hide quest objectives frame when inside of dungeons?")
    InstanceHelper_HideObjectivesCheckbox.text:SetFontObject("Game13Font")

    InterfaceOptions_AddCategory(ConfigUI)

    return ConfigUI
end

function Config:Toggle()
    --ConfigUI:SetShown(not ConfigUI:IsShown())
    --if (UI.inInstance == false) then
    --    UI.frame:SetShown(ConfigUI:IsShown())
    --end
end
