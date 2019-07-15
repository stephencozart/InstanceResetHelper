----------------------------------------------------------------------
-- Namespaces
----------------------------------------------------------------------
local _, core = ...

core.Config = {
    _debug = true,

}

local Config = core.Config
local UI
local C_TimerAfter = C_Timer.After

local function _print(msg)     
    if Config._debug then
        print(msg)
    end
end

local irh = {
    dungeonName = nil,
    counter = 1,
    timeElapsed = 0,
    setDungeonName = function(self, dungeonName)
        _print('Dungeon name set to ' .. dungeonName)
        self.dungeonName = dungeonName
    end,
    resetCounter = function(self)
        self.counter = 1
    end,
    incrementCounter = function(self)    
        self.counter = self.counter + 1
        _print('Counter incremented to ' .. self.counter)
    end,
    incrementTimer = function(self)
        self.timeElapsed = self.timeElapsed + 1
        --_print("Timer incremented to " .. self.timeElapsed)
    end,
    resetTimer = function(self)
        self.timeElapsed = 0
    end,
    secondsToClock = function(self)
        local seconds = tonumber(self.timeElapsed)
      
        if seconds <= 0 then
          return { '00', '00', '00' }
        else
          hours = string.format("%02.f", math.floor(seconds/3600));
          mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
          secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
          return {
              hours,
              mins,
              secs
          }
        end
      end      
}

function Config:Toggle()
    local menu = UI or Config:CreateUI()
    menu:SetShown(not menu:IsShown()) 
end

function Config:CreateUI()
    UI = CreateFrame('Frame', 'InstanceResetHelper_CounterFrame', UIParent, 'GlowBoxTemplate')

    UI:SetPoint("Top", UIParent, "Top", 0, -20)
    UI:SetSize(90,90)
    UI.count = UI:CreateFontString(nil, "Overlay")
    UI.count:SetFontObject("Game27Font")
    UI.count:SetPoint("Center", UI, "Center")
    UI.count:SetText("|cffffd700" .. irh.counter .. "|r")

    UI.timerFrame = CreateFrame('Frame', 'InstanceResetHelper_TimerFrame', UI, 'GlowBoxTemplate')
    UI.timerFrame:SetPoint("Bottom", UI, "Bottom", 0, -35)
    UI.timerFrame:SetSize(90, 25)

    UI.timerFrame.hours = UI.timerFrame:CreateFontString(nil, "Overlay")
    UI.timerFrame.hours:SetFontObject('Game13Font')
    UI.timerFrame.hours:SetPoint("Left", UI.timerFrame, "Left", 7, 0)

    UI.timerFrame.minutes = UI.timerFrame:CreateFontString(nil, "Overlay")
    UI.timerFrame.minutes:SetFontObject('Game13Font')
    UI.timerFrame.minutes:SetPoint("Left", UI.timerFrame, "Left", 28, 0)

    UI.timerFrame.seconds = UI.timerFrame:CreateFontString(nil, "Overlay")
    UI.timerFrame.seconds:SetFontObject('Game13Font')
    UI.timerFrame.seconds:SetPoint("Left", UI.timerFrame, "Left", 58, 0)

    UI.timerFrame.update = function()
        local clock = irh:secondsToClock()
        UI.timerFrame.seconds:SetText("|cffffd700: " .. clock[3] .. "|r")
        UI.timerFrame.minutes:SetText("|cffffd700: " .. clock[2] .. "|r")
        UI.timerFrame.hours:SetText("|cffffd700" .. clock[1] .. "|r")
    end

    UI.timerFrame.update()

    UI.timer = {}

    UI.timer.callback = function()
        irh:incrementTimer()
        UI.timerFrame.update()
        C_TimerAfter(1, UI.timer.callback)
    end

    C_TimerAfter(1, UI.timer.callback)

    UI:SetShown(false)

    return UI;
end

local function onEventHandler(self, event, ...)
    if (event == "PLAYER_ENTERING_WORLD") then
        local inInstance, instanceType = IsInInstance()
        
        if (instanceType == "party" and inInstance) then
            if (irh.dungeonName == nil) then
                Config:Toggle()
            end
            local name, _, difficultyIndex, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapId, lfgID = GetInstanceInfo()
            irh:setDungeonName(name)            
        end

        if (inInstance == false and irh.dungeonName ~= nil) then
            StaticPopup_Show("InstanceResetHelper_Confirm")            
        end        
    end
end

StaticPopupDialogs["InstanceResetHelper_Confirm"] = {
    text = "Reset all instances?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function() 
        if (irh.counter == 10) then
            irh:resetCounter()
            irh:resetTimer()
            UI.timer:Cancel()
        else
            irh:incrementCounter()
        end
        UI.count:SetText("|cffffd700" .. irh.counter .. "|r")
        ResetInstances()
        
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3
}

local frame = CreateFrame('Frame', 'InstanceResetHelper_Frame')

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript('OnEvent', onEventHandler)
