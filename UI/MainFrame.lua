-- MythicLootMap Main UI Frame
-- Uses modern WoW 12.0 APIs: ScrollBox, DropdownButton, MenuUtil

local ADDON_NAME, ns = ...
local MythicLootMap = ns

local MainFrame = {}
MythicLootMap.MainFrame = MainFrame

local FRAME_WIDTH = 960
local FRAME_HEIGHT = 560
local ROW_HEIGHT = 28
local HEADER_HEIGHT = 24
local FILTER_BAR_HEIGHT = 36

local frame = nil
local scrollBox = nil
local dataProvider = nil
local statusText = nil

function MainFrame:Create()
    if frame then return frame end

    frame = CreateFrame("Frame", "MythicLootMapFrame", UIParent, "BackdropTemplate")
    frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("HIGH")
    frame:SetClampedToScreen(true)

    -- ESC to close
    tinsert(UISpecialFrames, "MythicLootMapFrame")

    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -16)
    title:SetText(MythicLootMap.L["Title"])

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -6, -6)

    -- Reload button
    local reloadBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    reloadBtn:SetSize(70, 22)
    reloadBtn:SetPoint("TOPRIGHT", closeBtn, "TOPLEFT", -4, -4)
    reloadBtn:SetText("Reload")
    reloadBtn:SetScript("OnClick", function()
        MythicLootMap.DoReload()
        MythicLootMap:Print(MythicLootMap.L["DataReloaded"])
    end)

    -- Settings button
    local settingsBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    settingsBtn:SetSize(22, 22)
    settingsBtn:SetPoint("RIGHT", reloadBtn, "LEFT", -4, 0)
    settingsBtn:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
    settingsBtn:SetScript("OnClick", function()
        MainFrame:ToggleSettings()
    end)

    self:CreateFilterBar(frame)
    self:CreateHeaders(frame)
    self:CreateScrollBox(frame)

    -- Status bar
    statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusText:SetPoint("BOTTOMLEFT", 16, 12)
    statusText:SetTextColor(0.7, 0.7, 0.7)

    frame:Hide()
    return frame
end

---------------------------------------------------------------------------
-- Filter Bar (modern DropdownButton API)
---------------------------------------------------------------------------

function MainFrame:CreateFilterBar(parent)
    local bar = CreateFrame("Frame", nil, parent)
    bar:SetPoint("TOPLEFT", 12, -42)
    bar:SetPoint("TOPRIGHT", -12, -42)
    bar:SetHeight(FILTER_BAR_HEIGHT)

    -- Slot dropdown
    local slotDropdown = CreateFrame("DropdownButton", nil, bar, "WowStyle1DropdownTemplate")
    slotDropdown:SetPoint("LEFT", 4, 0)
    local L = MythicLootMap.L
    slotDropdown:SetDefaultText(L["AllSlots"])
    self.slotDropdown = slotDropdown

    local selectedSlot = 0
    slotDropdown:SetupMenu(function(dropdown, rootDescription)
        for _, slot in ipairs(MythicLootMap.FILTER_SLOTS) do
            rootDescription:CreateRadio(
                slot.name,
                function() return selectedSlot == slot.id end,
                function()
                    selectedSlot = slot.id
                    MythicLootMap.Filters:SetSlot(slot.id)
                    MainFrame:Refresh()
                end
            )
        end
    end)

    -- Armor type dropdown
    local armorDropdown = CreateFrame("DropdownButton", nil, bar, "WowStyle1DropdownTemplate")
    armorDropdown:SetPoint("LEFT", slotDropdown, "RIGHT", 10, 0)
    armorDropdown:SetDefaultText(L["AllArmor"])

    local selectedArmor = nil
    armorDropdown:SetupMenu(function(dropdown, rootDescription)
        local armorOptions = {
            { key = nil, name = L["AllArmor"] },
            { key = "Cloth", name = L["Cloth"] },
            { key = "Leather", name = L["Leather"] },
            { key = "Mail", name = L["Mail"] },
            { key = "Plate", name = L["Plate"] },
        }
        for _, opt in ipairs(armorOptions) do
            rootDescription:CreateRadio(
                opt.name,
                function() return selectedArmor == opt.key end,
                function()
                    selectedArmor = opt.key
                    MythicLootMap.Filters:SetArmorType(opt.key)
                    MainFrame:Refresh()
                end
            )
        end
    end)

    -- Dungeon dropdown (generator queries dungeon list dynamically each time)
    local dungeonDropdown = CreateFrame("DropdownButton", nil, bar, "WowStyle1DropdownTemplate")
    dungeonDropdown:SetPoint("LEFT", armorDropdown, "RIGHT", 10, 0)
    dungeonDropdown:SetDefaultText(L["AllDungeons"])
    self.dungeonDropdown = dungeonDropdown

    local selectedDungeon = 0
    dungeonDropdown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateRadio(
            L["AllDungeons"],
            function() return selectedDungeon == 0 end,
            function()
                selectedDungeon = 0
                MythicLootMap.Filters:SetDungeon(nil)
                MainFrame:Refresh()
            end
        )
        local dungeons = MythicLootMap.Data:GetDungeonList()
        for _, d in ipairs(dungeons) do
            rootDescription:CreateRadio(
                d.name,
                function() return selectedDungeon == d.instanceID end,
                function()
                    selectedDungeon = d.instanceID
                    MythicLootMap.Filters:SetDungeon(d.instanceID)
                    MainFrame:Refresh()
                end
            )
        end
    end)

    -- Stat filter dropdowns
    local statOptions = {
        { key = nil,       name = L["Any"] },
        { key = "crit",    name = L["Crit"] },
        { key = "haste",   name = L["Haste"] },
        { key = "mastery", name = L["Mastery"] },
        { key = "vers",    name = L["Vers"] },
    }

    local selectedStat1 = nil
    local stat1Dropdown = CreateFrame("DropdownButton", nil, bar, "WowStyle1DropdownTemplate")
    stat1Dropdown:SetPoint("LEFT", dungeonDropdown, "RIGHT", 10, 0)
    stat1Dropdown:SetDefaultText(L["Stat1"])
    stat1Dropdown:SetupMenu(function(dropdown, rootDescription)
        for _, opt in ipairs(statOptions) do
            rootDescription:CreateRadio(
                opt.name,
                function() return selectedStat1 == opt.key end,
                function()
                    selectedStat1 = opt.key
                    MythicLootMap.Filters:SetStat1(opt.key)
                    MainFrame:Refresh()
                end
            )
        end
    end)

    local selectedStat2 = nil
    local stat2Dropdown = CreateFrame("DropdownButton", nil, bar, "WowStyle1DropdownTemplate")
    stat2Dropdown:SetPoint("LEFT", stat1Dropdown, "RIGHT", 4, 0)
    stat2Dropdown:SetDefaultText(L["Stat2"])
    stat2Dropdown:SetupMenu(function(dropdown, rootDescription)
        for _, opt in ipairs(statOptions) do
            rootDescription:CreateRadio(
                opt.name,
                function() return selectedStat2 == opt.key end,
                function()
                    selectedStat2 = opt.key
                    MythicLootMap.Filters:SetStat2(opt.key)
                    MainFrame:Refresh()
                end
            )
        end
    end)

    -- Spec filter checkbox
    local specCheck = self:CreateCheckbox(bar, L["MySpec"], function(checked)
        MythicLootMap.Filters:SetSpecFilter(checked)
        if checked then
            local _, _, classID = UnitClass("player")
            local specIndex = GetSpecialization()
            if specIndex then
                local specID = GetSpecializationInfo(specIndex)
                EJ_SetLootFilter(classID, specID)
            end
        else
            EJ_ResetLootFilter()
        end
        MythicLootMap.Data:LoadDungeonData()
        MythicLootMap.Data:UpdateComparisons()
        MainFrame:Refresh()
    end)
    specCheck:SetPoint("LEFT", stat2Dropdown, "RIGHT", 10, 0)
    self.specCheck = specCheck

end

function MainFrame:CreateCheckbox(parent, label, onClick)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetSize(24, 24)
    check.text = check:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    check.text:SetPoint("LEFT", check, "RIGHT", 2, 0)
    check.text:SetText(label)
    check:SetScript("OnClick", function(self)
        onClick(self:GetChecked())
    end)
    return check
end

---------------------------------------------------------------------------
-- Column headers
---------------------------------------------------------------------------

function MainFrame:CreateHeaders(parent)
    local headerRow = CreateFrame("Frame", nil, parent)
    headerRow:SetPoint("TOPLEFT", 12, -(42 + FILTER_BAR_HEIGHT + 4))
    headerRow:SetPoint("TOPRIGHT", -28, -(42 + FILTER_BAR_HEIGHT + 4))
    headerRow:SetHeight(HEADER_HEIGHT)

    local L = MythicLootMap.L
    local headers = {
        { text = "", width = 30 },
        { text = L["Item"], width = 200 },
        { text = L["Slot"], width = 80 },
        { text = L["Stats"], width = 120 },
        { text = L["Dungeon"], width = 200 },
        { text = L["Boss"], width = 200 },
    }

    local xOffset = 0
    for _, h in ipairs(headers) do
        local text = headerRow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", xOffset, 0)
        text:SetWidth(h.width)
        text:SetText(MythicLootMap.COLORS.HEADER .. h.text .. MythicLootMap.COLORS.RESET)
        text:SetJustifyH("LEFT")
        xOffset = xOffset + h.width
    end

    local sep = headerRow:CreateTexture(nil, "ARTWORK")
    sep:SetPoint("BOTTOMLEFT", 0, 0)
    sep:SetPoint("BOTTOMRIGHT", 0, 0)
    sep:SetHeight(1)
    sep:SetColorTexture(0.5, 0.5, 0.5, 0.5)
end

---------------------------------------------------------------------------
-- ScrollBox (modern WoW 10.1+ / 12.0 API)
---------------------------------------------------------------------------

function MainFrame:CreateScrollBox(parent)
    local topOffset = 42 + FILTER_BAR_HEIGHT + 4 + HEADER_HEIGHT + 4

    scrollBox = CreateFrame("Frame", nil, parent, "WowScrollBoxList")
    scrollBox:SetPoint("TOPLEFT", 12, -topOffset)
    scrollBox:SetPoint("BOTTOMRIGHT", -28, 30)

    local scrollBar = CreateFrame("EventFrame", nil, parent, "MinimalScrollBar")
    scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 4, 0)
    scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT", 4, 0)

    local scrollView = CreateScrollBoxListLinearView()
    scrollView:SetElementExtent(ROW_HEIGHT)

    scrollView:SetElementInitializer("Frame", function(row, data)
        self:InitRow(row, data)
    end)

    ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, scrollView)

    dataProvider = CreateDataProvider()
    scrollBox:SetDataProvider(dataProvider)
end

---------------------------------------------------------------------------
-- Row initialization (called by ScrollBox for each visible row)
---------------------------------------------------------------------------

function MainFrame:InitRow(row, data)
    if not row.initialized then
        self:SetupRowWidgets(row)
        row.initialized = true
    end

    self:SetRowData(row, data)
end

function MainFrame:SetupRowWidgets(row)
    row:SetHeight(ROW_HEIGHT)

    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(1, 1, 1, 0.1)

    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetPoint("LEFT", 4, 0)
    row.icon:SetSize(24, 24)

    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.nameText:SetPoint("LEFT", 34, 0)
    row.nameText:SetWidth(196)
    row.nameText:SetJustifyH("LEFT")

    row.slotText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.slotText:SetPoint("LEFT", 230, 0)
    row.slotText:SetWidth(80)
    row.slotText:SetJustifyH("LEFT")

    row.statsText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.statsText:SetPoint("LEFT", 310, 0)
    row.statsText:SetWidth(120)
    row.statsText:SetJustifyH("LEFT")

    row.dungeonText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.dungeonText:SetPoint("LEFT", 430, 0)
    row.dungeonText:SetWidth(200)
    row.dungeonText:SetJustifyH("LEFT")

    row.bossText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.bossText:SetPoint("LEFT", 630, 0)
    row.bossText:SetWidth(200)
    row.bossText:SetJustifyH("LEFT")

    row:EnableMouse(true)
    row:SetScript("OnEnter", function(self)
        if self.itemLink then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local ok = pcall(GameTooltip.SetHyperlink, GameTooltip, self.itemLink)
            if ok then
                GameTooltip:Show()
            end
        end
    end)
    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    row:SetScript("OnMouseUp", function(self, button)
        if IsModifiedClick("CHATLINK") and self.itemLink then
            ChatEdit_InsertLink(self.itemLink)
        end
    end)
end

function MainFrame:SetRowData(row, item)
    row.itemLink = item.itemLink

    if item.icon then
        row.icon:SetTexture(item.icon)
        row.icon:Show()
    else
        row.icon:Hide()
    end

    row.nameText:SetText(item.itemLink or item.name or "Loading...")
    row.slotText:SetText(MythicLootMap:GetSlotName(item.slotID))
    row.statsText:SetText(MythicLootMap:FormatStatNames(item))
    row.dungeonText:SetText(item.dungeonName or "")
    row.bossText:SetText(item.encounterName or "")
end

-- InitDungeonDropdown kept as no-op for backward compat with Core.lua calls
function MainFrame:InitDungeonDropdown() end

---------------------------------------------------------------------------
-- Refresh / Toggle
---------------------------------------------------------------------------

function MainFrame:Refresh()
    if not frame or not frame:IsShown() then return end

    local filteredItems = MythicLootMap.Filters:GetFilteredItems()

    -- Save scroll position before replacing data
    local scrollPct = scrollBox:GetScrollPercentage() or 0

    dataProvider = CreateDataProvider(filteredItems)
    scrollBox:SetDataProvider(dataProvider)

    -- Restore scroll position
    if scrollPct > 0 then
        scrollBox:SetScrollPercentage(scrollPct)
    end

    local totalItems = #MythicLootMap.db.items
    statusText:SetText(string.format(MythicLootMap.L["Showing"], #filteredItems, totalItems))
end

function MainFrame:Toggle()
    if not frame then
        self:Create()
    end

    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        self:Refresh()
    end
end

function MainFrame:Show()
    if not frame then
        self:Create()
    end
    frame:Show()
    self:Refresh()
end

function MainFrame:Hide()
    if frame then
        frame:Hide()
    end
end

function MainFrame:IsShown()
    return frame and frame:IsShown()
end

---------------------------------------------------------------------------
-- Settings panel
---------------------------------------------------------------------------

local settingsFrame = nil

function MainFrame:ToggleSettings()
    if settingsFrame and settingsFrame:IsShown() then
        settingsFrame:Hide()
        return
    end
    if not settingsFrame then
        self:CreateSettings()
    end
    settingsFrame:Show()
end

function MainFrame:CreateSettings()
    settingsFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    settingsFrame:SetSize(220, 100)
    settingsFrame:SetPoint("TOPRIGHT", frame, "TOPLEFT", -4, 0)
    settingsFrame:SetFrameStrata("HIGH")

    settingsFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 24,
        insets = { left = 6, right = 6, top = 6, bottom = 6 },
    })

    local title = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -12)
    title:SetText("Settings")

    -- Language dropdown
    local langLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    langLabel:SetPoint("TOPLEFT", 14, -34)
    langLabel:SetText("Language:")

    local langDropdown = CreateFrame("DropdownButton", nil, settingsFrame, "WowStyle1DropdownTemplate")
    langDropdown:SetPoint("LEFT", langLabel, "RIGHT", 8, 0)

    local currentLang = (MythicLootMapDB and MythicLootMapDB.locale) or GetLocale()

    langDropdown:SetupMenu(function(dropdown, rootDescription)
        local langOptions = {
            { code = "enUS", name = "English" },
            { code = "zhCN", name = "\231\174\128\228\189\147\228\184\173\230\150\135" },
            { code = "zhTW", name = "\231\185\129\233\171\148\228\184\173\230\150\135" },
        }
        for _, opt in ipairs(langOptions) do
            rootDescription:CreateRadio(
                opt.name,
                function() return currentLang == opt.code end,
                function()
                    currentLang = opt.code
                    MythicLootMapDB = MythicLootMapDB or {}
                    MythicLootMapDB.locale = opt.code
                    MythicLootMap:ApplyLocale(opt.code)
                    MythicLootMap:Print(string.format(MythicLootMap.L["LangSet"], opt.code))
                end
            )
        end
    end)
end
