local _, core = ...

local UI = core.UI

local Config = core.Config

SLASH_InstanceResetHelper1 = '/irh'

SlashCmdList["InstanceResetHelper"] = function(msg)
    if (msg == 'show') then
        UI.frame:SetShown(true)
    elseif (msg == 'hide') then
        UI.frame:SetShown(false)
    elseif(msg == 'pause') then
        -- pause the timer
        if (UI.isTicking) then
            UI:CancelTicker()
        end

    elseif(msg == 'resume') then
        -- resume the timer
        if (UI.isTicking == false) then
            UI:StartTicker()
        end

    elseif(msg == 'reset') then
        -- reset counter to 1
        UI:ResetCounter()
        -- reset elapsed time to zero
        UI:ResetTimer()
        -- cancel timer
        if (UI.isTicking) then
            UI:CancelTicker()
        end
        UI.timerFrame:Update()
        UI:Refresh()
    elseif(msg == 'config') then
        Config:Toggle()
    else 
        print("Instance Reset Helper Commands:")
        print("/irh config")
        print("/irh show")
        print("/irh hide")
        print("/irh pause")
        print("/irh resume")
        print("/irh reset")
    end
end