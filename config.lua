----------------------------------------------------------------------
-- Namespaces
----------------------------------------------------------------------
local _, core = ...

core.Config = {
    CreateUIFrame = function(self, point, x, y)
        local frame = CreateFrame('Frame', 'InstanceResetHelper_CounterFrame', UIParent, 'GlowBoxTemplate')
        frame:SetShown(false)
        frame:SetPoint(point, UIParent, point, x, y * -1)
        frame:SetSize(90,90)
        return frame
    end
}

-- todo make a way to add to this
core.trackedItems = {
    ["Shimmerscale"] = {
        frame = nil
    },
    ["Coarse Leather"] = {
        frame = nil
    },
    ["Cragscale"] = {
        frame = nil
    },
    ["Dredged Leather"] = {
        frame = nil
    },
    ["Mistscale"] = {
        frame = nil
    },
    ["Tempest Hide"] = {
        frame = nil
    },
    ["Blood-Stained Bone"] = {
        frame = nil
    },
    ["Calcified Bone"] = {
        frame = nil
    }    
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
            dst[k] = copyDefaults(v, dst[k])
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

    ConfigUI = CreateFrame("Frame", "InstanceResetHelper_ConfigOptionsFrame", UIParent, "BasicFrameTemplateWithInset")
    ConfigUI.onCloseCallback = function()
        Config:Toggle()
    end
    ConfigUI:SetSize(450, 360)
    ConfigUI:SetPoint("Center")
    ConfigUI:SetShown(false)

    ConfigUI.title = ConfigUI:CreateFontString(nil, "Ovelay", "GameFontHighlight")
    ConfigUI.title:SetPoint("Center", ConfigUI.TitleBg, "Center")
    ConfigUI.title:SetText("Instance Reset Helper Options")

    ConfigUI.sliderX = CreateFrame("SLIDER", "InstanceResetHelper_SliderX", ConfigUI, "OptionsSliderTemplate")
    ConfigUI.sliderX:ClearAllPoints()
    ConfigUI.sliderX:SetPoint("TOPLEFT", ConfigUI.TitleBg, "BOTTOMLEFT", 30, -50)
    ConfigUI.sliderX:SetMinMaxValues(ScreenXMin, ScreenXMax)
    ConfigUI.sliderX:SetValue(config.xOffset)
    ConfigUI.sliderX:SetValueStep(1)
    ConfigUI.sliderX:SetObeyStepOnDrag(true)

    InstanceResetHelper_SliderXLow:SetText(ScreenXMin)
    InstanceResetHelper_SliderXHigh:SetText(ScreenXMax)
    InstanceResetHelper_SliderXText:SetText("X offset")

    ConfigUI.sliderX:SetScript("OnValueChanged", function(self, event)        
        InstanceResetHelperDB["xOffset"] = event   
        UI:Refresh()     
    end)

    ConfigUI.sliderY = CreateFrame("SLIDER", "InstanceResetHelper_SliderY", ConfigUI, "OptionsSliderTemplate")
    ConfigUI.sliderY:ClearAllPoints()
    ConfigUI.sliderY:SetPoint("TOPRIGHT", ConfigUI.TitleBg, "BOTTOMRIGHT", -15, -50)
    ConfigUI.sliderY:SetMinMaxValues(ScreenYMin, ScreenYMax)
    ConfigUI.sliderY:SetValue(config.yOffset)
    ConfigUI.sliderY:SetValueStep(1)
    ConfigUI.sliderY:SetObeyStepOnDrag(true)

    InstanceResetHelper_SliderYLow:SetText(ScreenYMin)
    InstanceResetHelper_SliderYHigh:SetText(ScreenYMax)
    InstanceResetHelper_SliderYText:SetText("Y offset")

    ConfigUI.sliderY:SetScript("OnValueChanged", function(self, event)        
        InstanceResetHelperDB["yOffset"] = event
        UI:Refresh()        
    end)

    ConfigUI.hideObjectivesCheckBox = CreateFrame("CheckButton", "InstanceHelper_HideObjectivesCheckbox", ConfigUI, "UICheckButtonTemplate")
    ConfigUI.hideObjectivesCheckBox:SetPoint("TOPLEFT", ConfigUI.sliderX, "BOTTOMLEFT", -5, -30)
    ConfigUI.hideObjectivesCheckBox:SetChecked(config.hideObjectiveTracker)
    ConfigUI.hideObjectivesCheckBox:SetScript("OnClick", function(self)
        InstanceResetHelperDB["hideObjectiveTracker"] = self:GetChecked()
    end)

    InstanceHelper_HideObjectivesCheckbox.text:SetText("Hide quest objectives frame when inside of dungeons?")
    InstanceHelper_HideObjectivesCheckbox.text:SetFontObject("Game13Font")


    
end

function Config:Toggle()
    ConfigUI:SetShown(not ConfigUI:IsShown())
    if (UI.inInstance == false) then
        UI.frame:SetShown(ConfigUI:IsShown())
    end
end
