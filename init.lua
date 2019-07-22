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

local lootTable = core.lootTable

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

    -- track loot


    if (addonName == 'InstanceResetHelper') then
        InstanceResetHelperDB = core:copyDefaults(defaults, InstanceResetHelperDB)
        core:InitUI(InstanceResetHelperDB)        
        core:InitConfigUI(InstanceResetHelperDB, UI)
        UI.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        UI.frame:SetScript('OnEvent', init)
    end    
end)

local IRH_LOOT_ITEM_SELF = LOOT_ITEM_SELF:gsub("%%s", "(.+)")
local IRH_LOOT_ITEM_SELF_MULTIPLE = LOOT_ITEM_SELF_MULTIPLE:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)")

-- parent UI.lootFrame
UI.lootFrame = CreateFrame('Frame', __addonName .. '_LootFrame', UIParent, 'GlowBoxTemplate')
UI.lootFrame:SetShown(true)
UI.lootFrame:SetPoint("LEFT", UIParent, "LEFT")
UI.lootFrame:SetSize(400, 300)
UI.lootFrame:SetClipsChildren(true)

-- scrollframe
UI.lootFrame.ScrollFrame = CreateFrame('ScrollFrame', nill, UI.lootFrame, "UIPanelScrollFrameTemplate")

UI.lootFrame.ScrollFrame:SetPoint("TOPLEFT", UI.lootFrame, "TOPLEFT")
UI.lootFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", UI.lootFrame, "BOTTOMRIGHT")
UI.lootFrame.ScrollFrame:SetSize(400, 300)


function UI.lootFrame:AddItem(itemLink, quantity)

    itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, 
isCraftingReagent = GetItemInfo(itemLink) 
        
    if (lootTable[itemName] == nill) then
    
        lootTable[itemName] = {
            quantity = quantity,
            itemName = itemName,
            itemLink = itemLink,
            frame = UI.lootFrame:CreateFontString(nil, "Overlay")
        }
        lootTable[itemName].frame:SetFontObject("Game15Font")
    else
        lootTable[itemName].quantity = lootTable[itemName].quantity + quantity
    end

end

local lastItem = nil

function UI.lootFrame:RenderLootTable()

    local child = CreateFrame("Frame", nil, UI.lootFrame.ScrollFrame)
    
    for k,v in pairs(lootTable) do

        local point = "BOTTOMLEFT"
        local anchor = lastItem
        if (lastItem == nil) then
            point = "TOPLEFT"
            anchor = child
        else
            anchor = lastItem
        end

    

        lootTable[k].frame:SetPoint("TOPLEFT", child, point)
        lootTable[k].frame:SetText(lootTable[k].itemName .. '@' .. lootTable[k].quantity)
        lastItem = lootTable[k].frame

    end

    child:SetSize(400, 600)

    UI.lootFrame.ScrollFrame:SetScrollChild(child)
    
end



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

        UI.lootFrame:AddItem(itemLink, quantity)
    end

    if (eventName == "LOOT_CLOSED") then
        UI.lootFrame:RenderLootTable()
    end
end)