local _debug_ = true

local function _print(msg)     
    if _debug_ then
        print(msg)
    end
end

local irh = {
    dungeonName = nil,
    counter = 0,
    setDungeonName = function(self, dungeonName)
        _print('Dungeon name set to ' .. dungeonName)
        self.dungeonName = dungeonName
    end,
    incrementCounter = function(self)    
        self.counter = self.counter + 1
        _print('Counter incremented to ' .. self.counter)
    end
}

local function onEventHandler(self, event, ...)
    if (event == "PLAYER_ENTERING_WORLD") then
        inInstance, instanceType = IsInInstance()
        
        if (instanceType == "party" and inInstance) then
            name, type, difficultyIndex, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapId, lfgID = GetInstanceInfo()
            irh:setDungeonName(name)
        end

        if (inInstance == false and irh.dungeonName ~= nil) then
            StaticPopup_Show("InstanceResetHelper_Confirm")
            irh:incrementCounter()
        end        
    end
end

StaticPopupDialogs["InstanceResetHelper_Confirm"] = {
    text = "Reset all instances?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function() 
        ResetInstances()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3
}

local frame = CreateFrame('Frame', 'InstanceResetHelper')

_print("Instance Reset Helper has been loaded")

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript('OnEvent', onEventHandler)
