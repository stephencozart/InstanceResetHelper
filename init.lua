----------------------------------------------------------------------
-- Namespaces
----------------------------------------------------------------------
local _, core = ...

local irh = core.irh

function init(self, event, name)
    print('init called')
    if (event == "PLAYER_ENTERING_WORLD") then
        local inInstance, instanceType = IsInInstance()
        
        if (instanceType == "party" and inInstance) then
            if (irh.dungeonName == nil) then
                core.Config:Toggle()
            end
            local name, _, difficultyIndex, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapId, lfgID = GetInstanceInfo()
            irh:setDungeonName(name)            
        end

        if (inInstance == false and core.irh.dungeonName ~= nil) then
            StaticPopup_Show("InstanceResetHelper_Confirm")            
        end        
    end

end


local frame = CreateFrame('Frame', 'InstanceResetHelper_Frame')

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript('OnEvent', init)