----------------------------------------------------------------------
-- Namespaces
----------------------------------------------------------------------
local __addonName, core = ...

local UI = core.UI

local defaults = {
    xOffset = 0,
    yOffset = -20,
    anchor = "TOPLEFT",
    hideObjectiveTracker = false
}

local trackedItems = core.trackedItems

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
        initLootFrame()
    end    
end)

local IRH_LOOT_ITEM_SELF = LOOT_ITEM_SELF:gsub("%%s", "(.+)")
local IRH_LOOT_ITEM_SELF_MULTIPLE = LOOT_ITEM_SELF_MULTIPLE:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)")

UI.lootFrame = {}

function initLootFrame(database)
    -- parent UI.lootFrame
    UI.lootFrame = CreateFrame('Frame', __addonName .. '_LootFrame', UIParent, 'GlowBoxTemplate')
    UI.lootFrame:SetShown(true)
    UI.lootFrame:SetPoint("TOPLEFT", UI.frame, "TOPRIGHT", 20, 0)
    UI.lootFrame:SetSize(400, 240)


    -- scrollframe
    UI.lootFrame.ScrollFrame = CreateFrame('ScrollFrame', nill, UI.lootFrame, "UIPanelScrollFrameTemplate")

    UI.lootFrame.ScrollFrame:SetPoint("TOPLEFT", UI.lootFrame, "TOPLEFT")
    UI.lootFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", UI.lootFrame, "BOTTOMRIGHT")

    UI.lootFrame:RegisterEvent("CHAT_MSG_LOOT")
    UI.lootFrame:RegisterEvent("LOOT_CLOSED")
    UI.lootFrame:SetScript("OnEvent", function(self, eventName, msg)
        if (eventName == "CHAT_MSG_LOOT") then

            if msg:match(IRH_LOOT_ITEM_SELF_MULTIPLE) then			
                itemLink, quantity = string.match(msg, IRH_LOOT_ITEM_SELF_MULTIPLE)

            elseif msg:match(IRH_LOOT_ITEM_SELF) then			
                itemLink = string.match(msg, IRH_LOOT_ITEM_SELF)
                quantity = 1
            end

            -- UI.lootFrame:AddItem(itemLink, quantity)
        end

        if (eventName == "LOOT_CLOSED") then
            UI.lootFrame:RenderLootTable()
        end
    end)

    function UI.lootFrame:RenderLootTable()
        local child = CreateFrame("Frame", __addonName .. 'ScrollChild', UI.lootFrame.ScrollFrame)
    

        UI.lootFrame.ScrollFrame:SetScrollChild(child)
        local i = 1
        for k,v in pairs(trackedItems) do

            local itemName, itemLink, _, _, _, _, _, _, _, itemIcon = GetItemInfo(k)
            local itemCount = GetItemCount(k, true)
            
            itemFrame = CreateFrame("Frame", 'itemFrame' .. i, child)
            itemFrame:SetPoint("TOPLEFT", child, "TOPLEFT", 20, -25 * i)
            itemFrame:SetSize(400, 15)
            itemFrame:SetScript("OnEnter", function() 
                if (itemLink) then
                    GameTooltip:SetOwner(UI.frame, "ANCHOR_CURSOR")
                    GameTooltip:SetHyperlink(itemLink)
                    GameTooltip:Show()
                end
            end)
            itemFrame:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
            itemFrame.bg = itemFrame:CreateTexture(nil, "BACKGROUND")
            itemFrame.bg:SetPoint("LEFT", itemFrame, "LEFT")
            itemFrame.bg:SetTexture(itemIcon)
            itemFrame.bg:SetSize(20, 20)

            itemFrame.itemName = itemFrame:CreateFontString(__addonName .. 'itemName' .. i, "Overlay")
            itemFrame.itemName:SetFontObject("Game15Font")
            itemFrame.itemName:SetText(k)
            itemFrame.itemName:SetPoint("TOPLEFT", itemFrame, "TOPLEFT", 25, 0)

            itemFrame.itemCount = itemFrame:CreateFontString(nil, "Overlay")
            itemFrame.itemCount:SetFontObject("Game15Font")
            itemFrame.itemCount:SetPoint("TOPRIGHT", itemFrame, "TOPRIGHT", -40, 0)
            itemFrame.itemCount:SetText("|cffffd700" .. itemCount .. "|r")

            i = i + 1
            
        end

        child:SetSize(400, i * 25)
    end

    UI.lootFrame:RenderLootTable()
end
