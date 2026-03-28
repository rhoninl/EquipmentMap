-- MythicLootMap Core
-- Main addon initialization, event handling, and slash commands

local ADDON_NAME, ns = ...

-- Global reference for tests and external access
MythicLootMap = ns

-- Internal data store
ns.db = {
    dungeons = {},
    items = {},
}

-- Event frame
local eventFrame = CreateFrame("Frame")

local EVENTS = {
    "ADDON_LOADED",
    "PLAYER_ENTERING_WORLD",
    "CHALLENGE_MODE_MAPS_UPDATE",
    "ITEM_DATA_LOAD_RESULT",
    "PLAYER_EQUIPMENT_CHANGED",
    "TRANSMOG_COLLECTION_UPDATED",
}

for _, event in ipairs(EVENTS) do
    eventFrame:RegisterEvent(event)
end

local dataLoaded = false
local isLoadingData = false

-- Debounce: batch ITEM_DATA_LOAD_RESULT refreshes into a single UI update
local refreshPending = false
local REFRESH_DELAY = 0.3

local function ScheduleRefresh()
    if refreshPending then return end
    refreshPending = true
    C_Timer.After(REFRESH_DELAY, function()
        refreshPending = false
        ns.Data:UpdateComparisons()
        ns.MainFrame:Refresh()
    end)
end

local function DoReload()
    isLoadingData = true
    ns.db.dungeons = {}
    ns.db.items = {}
    ns.Data:LoadDungeonData()
    ns.Data:UpdateComparisons()
    ns.MainFrame:InitDungeonDropdown()
    ns.MainFrame:Refresh()
    isLoadingData = false
end

-- Expose reload for the UI button
ns.DoReload = DoReload

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == ADDON_NAME then
            -- Initialize SavedVariables
            MythicLootMapDB = MythicLootMapDB or {}
            if MythicLootMapDB.locale then
                ns:ApplyLocale(MythicLootMapDB.locale)
            end
            eventFrame:UnregisterEvent("ADDON_LOADED")
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        C_MythicPlus.RequestMapInfo()

    elseif event == "CHALLENGE_MODE_MAPS_UPDATE" then
        if not dataLoaded and not isLoadingData then
            isLoadingData = true
            dataLoaded = true
            ns.Data:LoadDungeonData()
            ns.Data:UpdateComparisons()
            ns.MainFrame:InitDungeonDropdown()
            isLoadingData = false
        end

    elseif event == "ITEM_DATA_LOAD_RESULT" then
        local itemID, success = ...
        ns.Data:OnItemDataLoaded(itemID, success)
        if not isLoadingData then
            ScheduleRefresh()
        end

    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        if dataLoaded and not isLoadingData then
            ScheduleRefresh()
        end

    elseif event == "TRANSMOG_COLLECTION_UPDATED" then
        if dataLoaded and not isLoadingData then
            for _, item in ipairs(ns.db.items) do
                if C_TransmogCollection and C_TransmogCollection.PlayerHasTransmog then
                    item.owned = C_TransmogCollection.PlayerHasTransmog(item.itemID, 0)
                end
            end
            ScheduleRefresh()
        end
    end
end)

-- Minimap button via LibDataBroker pattern (no library needed)
local minimapButton = CreateFrame("Button", "MythicLootMapMinimapButton", Minimap)
minimapButton:SetSize(32, 32)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetFrameLevel(8)
minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 2, -2)
minimapButton:SetMovable(true)
minimapButton:SetClampedToScreen(true)

local minimapIcon = minimapButton:CreateTexture(nil, "ARTWORK")
minimapIcon:SetSize(20, 20)
minimapIcon:SetPoint("CENTER")
minimapIcon:SetTexture("Interface\\Icons\\INV_Misc_Map02")

local minimapBorder = minimapButton:CreateTexture(nil, "OVERLAY")
minimapBorder:SetSize(54, 54)
minimapBorder:SetPoint("CENTER")
minimapBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

local minimapHighlight = minimapButton:CreateTexture(nil, "HIGHLIGHT")
minimapHighlight:SetSize(24, 24)
minimapHighlight:SetPoint("CENTER")
minimapHighlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

minimapButton:SetScript("OnClick", function(self, button)
    ns.MainFrame:Toggle()
end)

minimapButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("MythicLootMap")
    GameTooltip:AddLine(ns.L["CmdToggle"], 1, 1, 1, true)
    GameTooltip:Show()
end)

minimapButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Draggable around minimap edge
local isDragging = false
minimapButton:RegisterForDrag("LeftButton")
minimapButton:SetScript("OnDragStart", function(self)
    isDragging = true
    self:SetScript("OnUpdate", function(self)
        local mx, my = Minimap:GetCenter()
        local cx, cy = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        cx, cy = cx / scale, cy / scale
        local angle = math.atan2(cy - my, cx - mx)
        local radius = (Minimap:GetWidth() / 2) + 5
        self:ClearAllPoints()
        self:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
    end)
end)

minimapButton:SetScript("OnDragStop", function(self)
    isDragging = false
    self:SetScript("OnUpdate", nil)
end)

-- Slash commands
SLASH_MYTHICLOOTMAP1 = "/mlm"
SLASH_MYTHICLOOTMAP2 = "/equipmap"

SlashCmdList["MYTHICLOOTMAP"] = function(msg)
    msg = strtrim(msg):lower()

    if msg == "test" then
        if ns.TestRunner then
            ns.TestRunner:RunAll()
        else
            ns:Print("Test suite not loaded.")
        end
        return
    end

    if msg == "reload" then
        DoReload()
        ns:Print(ns.L["DataReloaded"])
        return
    end

    if msg == "help" then
        ns:Print(ns.L["Commands"])
        print(ns.L["CmdToggle"])
        print(ns.L["CmdReload"])
        print(ns.L["CmdTest"])
        print(ns.L["CmdHelp"])
        return
    end

    -- Default: toggle window
    ns.MainFrame:Toggle()
end

ns:Print(ns.L["LoadedMsg"])
