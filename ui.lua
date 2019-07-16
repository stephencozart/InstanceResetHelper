----------------------------------------------------------------------
-- Namespaces
----------------------------------------------------------------------
local _, core = ...


local Config = core.Config
local UI
local C_TimerAfter = C_Timer.After

local function _print(msg)     
    if Config._debug then
        print(msg)
    end
end

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
    UI.count:SetText("|cffffd700" .. core.irh.counter .. "|r")

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
        local clock = core.irh:secondsToClock()
        UI.timerFrame.seconds:SetText("|cffffd700: " .. clock[3] .. "|r")
        UI.timerFrame.minutes:SetText("|cffffd700: " .. clock[2] .. "|r")
        UI.timerFrame.hours:SetText("|cffffd700" .. clock[1] .. "|r")
    end

    UI.timerFrame.update()

    UI.timer = {}

    UI.timer.callback = function()
        core.irh:incrementTimer()
        UI.timerFrame.update()
        C_TimerAfter(1, UI.timer.callback)
    end

    C_TimerAfter(1, UI.timer.callback)

    UI:SetShown(false)

    return UI;
end

StaticPopupDialogs["InstanceResetHelper_Confirm"] = {
    text = "Reset all instances?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function() 
        if (core.irh.counter == 10) then
            core.irh:resetCounter()
            core.irh:resetTimer()
            UI.timer:Cancel()
        else
            core.irh:incrementCounter()
        end
        UI.count:SetText("|cffffd700" .. core.irh.counter .. "|r")
        ResetInstances()
        
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3
}
