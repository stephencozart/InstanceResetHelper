----------------------------------------------------------------------
-- Namespaces
----------------------------------------------------------------------
local _, core = ...

local UI = core.UI

function init(self, event, name)    
    if (event == "PLAYER_ENTERING_WORLD") then
        local inInstance, instanceType = IsInInstance()
        
        if (instanceType == "party" and inInstance) then
            if (UI.dungeonName == nil) then        
                UI.frame:SetShown(true)
                if (UI.isTicking == false) then
                    UI:StartTicker()
                end
            end

            local name, _, difficultyIndex, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapId, lfgID = GetInstanceInfo()
            UI:SetDungeonName(name)
        end

        if (inInstance == false and UI.dungeonName ~= nil) then
            StaticPopup_Show("InstanceResetHelper_Confirm")
        end
    end
end


local frame = CreateFrame('Frame', 'InstanceResetHelper_Frame')

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript('OnEvent', init)