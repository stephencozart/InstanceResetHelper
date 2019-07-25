----------------------------------------------------------------------
-- Namespaces
----------------------------------------------------------------------
local __addonName, core = ...

local UI = core.UI

local defaults = {
    xOffset = 0,
    yOffset = -20,
    anchor = "TOPLEFT",
    hideObjectiveTracker = false,
    map = {
        hide = false
    }
}

function init(self, event, name)    
    if (event == "PLAYER_ENTERING_WORLD") then
        local inInstance, instanceType = IsInInstance()
        
        if (instanceType == "party" and inInstance) then

            if (ObjectiveTrackerFrame:IsShown() and InstanceResetHelperDB["hideObjectiveTracker"]) then
                ObjectiveTrackerFrame:Hide()
            end

            UI:SetInInstance(true)
                
            UI.frame:SetShown(true)
            if (UI.isTicking == false) then
                UI:StartTicker()
            end
            

            local name, _, difficultyIndex, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapId, lfgID = GetInstanceInfo()
            UI:SetDungeonName(name)
        end

        if (inInstance == false) then
            UI:SetInInstance(false)
        end

        if (inInstance == false and UI.dungeonName ~= nil) then
            StaticPopup_Show("InstanceResetHelper_Confirm")
            ObjectiveTrackerFrame:Show()
        end
    end
end


local frame = CreateFrame('Frame', 'InstanceResetHelper_Frame')

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript('OnEvent', function(self, eventName, addonName)
    if (addonName == 'InstanceResetHelper') then
        InstanceResetHelperDB = core:copyDefaults(defaults, InstanceResetHelperDB)
        core:InitUI(InstanceResetHelperDB)        
        local configPanel = core:InitConfigUI(InstanceResetHelperDB, UI)
        UI.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        UI.frame:SetScript('OnEvent', init)    

        -- setup minimap icon
        local ldb = LibStub("LibDataBroker-1.1"):NewDataObject("Instance Reset Helper", {
            type = "data source",
            text = "Instance Reset Helper",
            icon = "Interface\\Icons\\INV_Chest_Cloth_17",
            OnClick = function(self, buttonName) 
                
                if (buttonName == 'LeftButton') then
                    UI:Toggle()
                elseif (buttonName == 'RightButton') then
                    InterfaceOptionsFrame_OpenToCategory(configPanel)
                end
            end,
        })

        local icon = LibStub("LibDBIcon-1.0")
        icon:Register("Instance Reset Helper", ldb, InstanceResetHelperDB.map)
    end    
end)
