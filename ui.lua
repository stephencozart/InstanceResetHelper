----------------------------------------------------------------------
-- Namespaces
----------------------------------------------------------------------
local _, core = ...

function core:CreateUIFrame()
    local frame = CreateFrame('Frame', 'InstanceResetHelper_CounterFrame', UIParent, 'GlowBoxTemplate')
    frame:SetShown(false)
    frame:SetPoint("LEFT", UIParent, "LEFT")
    frame:SetSize(90,90)
    return frame
end

core.UI = {
    dungeonName = nil,
    counter = 1,
    timeElapsed = 0,
    isTicking = false,
    inInstance = false,
    SetInInstance = function(self, arg)
        self.inInstance = arg
    end,
    SetDungeonName = function(self, dungeonName)
        self.dungeonName = dungeonName
    end,
    ResetCounter = function(self)
        self.counter = 1
    end,
    IncrementCounter = function(self)
        self.counter = self.counter + 1
    end,
    IncrementTimer = function(self)
        self.timeElapsed = self.timeElapsed + 1
    end,
    ResetTimer = function(self)
        self.timeElapsed = 0
    end,
    SecondsToClock = function(self)
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
    end,
    StartTicker = function(self)
        self.isTicking = true
        local ui = self
        self.ticker = C_Timer.NewTicker(1, function()
            ui:IncrementTimer()
            ui.timerFrame:Update()
        end)
    end,
    CancelTicker = function(self)
        self.isTicking = false
        self.ticker:Cancel()
    end
}

local UI = core.UI

function UI:Refresh()
    self.frame:SetPoint(InstanceResetHelperDB['anchor'], UIParent, InstanceResetHelperDB['anchor'], InstanceResetHelperDB["xOffset"], InstanceResetHelperDB["yOffset"] * -1)
    self.count:SetText("|cffffd700" .. self.counter .. "|r")
end

function UI:Toggle()
    self.frame:SetShown(not self.frame:IsShown())    
end

local Config = core.Config

function core:InitUI(config)
    
    UI.frame = core:CreateUIFrame(config.anchor, config.xOffset, config.yOffset)

    -- enable frame to be movable
    UI.frame:SetMovable(true)
    UI.frame:EnableMouse(true)
    UI.frame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and not self.isMoving then
            self:StartMoving();
            self.isMoving = true;
        end
    end)
    UI.frame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.isMoving then
            self:StopMovingOrSizing();
            self.isMoving = false;
        end
    end)
    -- end movable frame

    UI.count = UI.frame:CreateFontString(nil, "Overlay")
    UI.count:SetFontObject("Game27Font")
    UI.count:SetPoint("CENTER", UI.frame, "CENTER")
    UI.count:SetText("|cffffd700" .. UI.counter .. "|r")

    UI.closeButton = CreateFrame('BUTTON', "InstanceResetHelper_CloseButton", UI.frame, 'UIPanelCloseButton')
    UI.closeButton:SetPoint('TOPRIGHT', UI.frame, 'TOPRIGHT', 5, 5)

    UI.timerFrame = CreateFrame('Frame', 'InstanceResetHelper_TimerFrame', UI.frame, 'GlowBoxTemplate')
    UI.timerFrame:SetPoint("Bottom", UI.frame, "Bottom", 0, -35)
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

    UI.timerFrame.Update = function()
        local clock = UI:SecondsToClock()
        UI.timerFrame.seconds:SetText("|cffffd700: " .. clock[3] .. "|r")
        UI.timerFrame.minutes:SetText("|cffffd700: " .. clock[2] .. "|r")
        UI.timerFrame.hours:SetText("|cffffd700" .. clock[1] .. "|r")
    end

    UI.timerFrame:Update()

    UI.ticker = {}

    StaticPopupDialogs["InstanceResetHelper_Confirm"] = {
        text = "Reset all instances?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function() 
            if (UI.counter == 10) then
                UI:ResetCounter()
                UI:ResetTimer()
                UI:CancelTicker()
                UI:SetDungeonName(nil)            
            else
                UI:IncrementCounter()
            end
            UI.count:SetText("|cffffd700" .. UI.counter .. "|r")
            ResetInstances()
            
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = false,
        preferredIndex = 3
    }
end
