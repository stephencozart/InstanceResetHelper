----------------------------------------------------------------------
-- Namespaces
----------------------------------------------------------------------
local _, core = ...

local UI = core.UI

local defaults = {
    xOffset = 0,
    yOffset = -20,
    anchor = "TOPLEFT",
    hideObjectiveTracker = false
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
        core:InitConfigUI(InstanceResetHelperDB, UI)
        UI.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        UI.frame:SetScript('OnEvent', init)
    end    
end)