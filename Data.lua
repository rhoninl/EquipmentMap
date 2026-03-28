-- EquipMap Data Loading
-- Loads dungeon and loot data from WoW Encounter Journal API

local ADDON_NAME, ns = ...
local EquipMap = ns

local Data = {}
EquipMap.Data = Data

-- Pending item data requests for async loading
local pendingItems = {}

function Data:LoadDungeonData()
    EquipMap.db.dungeons = {}
    EquipMap.db.items = {}

    local challengeModeIDs = C_ChallengeMode.GetMapTable()
    if not challengeModeIDs or #challengeModeIDs == 0 then
        EquipMap:Print(EquipMap.L["NoDungeons"])
        return
    end

    -- Reset ALL EJ state before querying (must be in this exact order)
    EJ_ClearSearch()
    C_EncounterJournal.ResetSlotFilter()
    EJ_ResetLootFilter()

    -- Apply class/spec filter if enabled
    if EquipMap.Filters.current.specFilter then
        local _, _, classID = UnitClass("player")
        local specIndex = GetSpecialization()
        if specIndex then
            local specID = GetSpecializationInfo(specIndex)
            EJ_SetLootFilter(classID, specID)
        end
    end

    -- Build EJ instanceID lookup from all tiers (fallback for EJ_GetInstanceForMap)
    local ejLookupByName = self:BuildEJNameLookup()

    -- Set Mythic (M0) difficulty for loot queries
    EJ_SetDifficulty(EquipMap.MYTHIC_DIFFICULTY)

    for _, cmID in ipairs(challengeModeIDs) do
        local name, _, _, _, _, uiMapID = C_ChallengeMode.GetMapUIInfo(cmID)
        if name then
            local ejInstanceID = self:ResolveEJInstanceID(name, uiMapID, ejLookupByName)
            if ejInstanceID and ejInstanceID > 0 then
                EquipMap.db.dungeons[ejInstanceID] = {
                    name = name,
                    challengeModeID = cmID,
                    uiMapID = uiMapID,
                    instanceID = ejInstanceID,
                    encounters = {},
                }
                self:LoadInstanceLoot(ejInstanceID, name)
            end
        end
    end

    self:RequestMissingItemData()
    EquipMap:Print(string.format(EquipMap.L["Loaded"], #EquipMap.db.items, self:CountDungeons()))
end

function Data:ResolveEJInstanceID(dungeonName, uiMapID, ejLookupByName)
    if uiMapID and EJ_GetInstanceForMap then
        local id = EJ_GetInstanceForMap(uiMapID)
        if id and id > 0 then
            return id
        end
    end

    if dungeonName and ejLookupByName then
        return ejLookupByName[dungeonName]
    end

    return nil
end

function Data:BuildEJNameLookup()
    local lookup = {}
    local numTiers = EJ_GetNumTiers()
    if not numTiers or numTiers == 0 then return lookup end

    local savedTier = EJ_GetCurrentTier()

    for tierIndex = 1, numTiers do
        EJ_SelectTier(tierIndex)
        local instanceIndex = 1
        while true do
            local instanceID, instanceName = EJ_GetInstanceByIndex(instanceIndex, false)
            if not instanceID then break end
            if instanceName then
                lookup[instanceName] = instanceID
            end
            instanceIndex = instanceIndex + 1
        end
    end

    if savedTier then
        EJ_SelectTier(savedTier)
    end

    return lookup
end

function Data:LoadInstanceLoot(instanceID, dungeonName)
    -- Difficulty and preview level are already set in LoadDungeonData
    EJ_SelectInstance(instanceID)

    local numLoot = EJ_GetNumLoot()
    local dungeon = EquipMap.db.dungeons[instanceID]

    for lootIndex = 1, numLoot do
        local itemInfo = C_EncounterJournal.GetLootInfoByIndex(lootIndex)
        if itemInfo and itemInfo.itemID then
            local encounterName = ""
            local encounterID = itemInfo.encounterID
            if encounterID then
                local name = EJ_GetEncounterInfo(encounterID)
                encounterName = name or ""
                if not dungeon.encounters[encounterID] then
                    dungeon.encounters[encounterID] = {
                        name = encounterName,
                        items = {},
                    }
                end
            end

            local entry = self:BuildItemEntry({
                itemID = itemInfo.itemID,
                name = itemInfo.name,
                icon = itemInfo.icon,
                slot = itemInfo.slot,
                armorType = itemInfo.armorType,
                itemLink = itemInfo.link,
                encounterID = encounterID,
                encounterName = encounterName,
                instanceID = instanceID,
                dungeonName = dungeonName,
            })

            -- Skip items with no known equipment slot
            if not entry.slotID then
                -- skip
            else
                if encounterID and dungeon.encounters[encounterID] then
                    table.insert(dungeon.encounters[encounterID].items, entry)
                end
                table.insert(EquipMap.db.items, entry)
            end

            if not itemInfo.name or itemInfo.name == "" then
                pendingItems[itemInfo.itemID] = entry
            end
        end
    end
end

function Data:BuildItemEntry(info)
    local slotID = EquipMap:ResolveSlotID(info.slot)

    local entry = {
        itemID = info.itemID,
        name = info.name or "",
        icon = info.icon,
        slot = info.slot,
        slotID = slotID,
        armorType = info.armorType,
        itemLink = info.itemLink,
        ilvl = 0,
        crit = 0,
        haste = 0,
        mastery = 0,
        vers = 0,
        encounterID = info.encounterID,
        encounterName = info.encounterName,
        instanceID = info.instanceID,
        dungeonName = info.dungeonName,
        owned = false,
        ilvlDelta = 0,
    }

    self:EnrichItemEntry(entry)

    return entry
end

function Data:EnrichItemEntry(entry)
    -- Use the EJ link (has correct difficulty bonus IDs) if available
    local source = entry.itemLink or entry.itemID
    local itemName, itemLink, itemQuality, itemLevel, _, _, _, _, itemEquipLoc, itemTexture =
        GetItemInfo(source)

    if itemName then
        if not entry.name or entry.name == "" then
            entry.name = itemName
        end
        entry.ilvl = itemLevel or 0
        entry.icon = entry.icon or itemTexture
        if itemEquipLoc and itemEquipLoc ~= "" then
            entry.slot = itemEquipLoc
            entry.slotID = EquipMap:ResolveSlotID(itemEquipLoc)
        end
        if not entry.itemLink and itemLink then
            entry.itemLink = itemLink
        end

        -- Extract secondary stats (only works when item data is cached)
        local statsLink = entry.itemLink or itemLink
        if statsLink then
            local stats = C_Item.GetItemStats(statsLink)
            if stats then
                entry.crit = stats["ITEM_MOD_CRIT_RATING_SHORT"] or 0
                entry.haste = stats["ITEM_MOD_HASTE_RATING_SHORT"] or 0
                entry.mastery = stats["ITEM_MOD_MASTERY_RATING_SHORT"] or 0
                entry.vers = stats["ITEM_MOD_VERSATILITY"] or 0
            end
        end
    else
        pendingItems[entry.itemID] = entry
    end

    if C_TransmogCollection and C_TransmogCollection.PlayerHasTransmog then
        entry.owned = C_TransmogCollection.PlayerHasTransmog(entry.itemID, 0)
    end
end

function Data:RequestMissingItemData()
    for itemID, _ in pairs(pendingItems) do
        C_Item.RequestLoadItemDataByID(itemID)
    end
end

function Data:OnItemDataLoaded(itemID, success)
    if not success then return end

    local entry = pendingItems[itemID]
    if entry then
        self:EnrichItemEntry(entry)
        pendingItems[itemID] = nil
    end
end

function Data:UpdateComparisons()
    local equipped = EquipMap.Compare:GetPlayerEquipment()

    for _, item in ipairs(EquipMap.db.items) do
        item.ilvlDelta = EquipMap.Compare:CompareItem(item, equipped)
    end
end

function Data:ParseDungeonList(mapIDs)
    local dungeons = {}
    if not mapIDs then return dungeons end

    for _, cmID in ipairs(mapIDs) do
        local name = C_ChallengeMode.GetMapUIInfo(cmID)
        if name then
            dungeons[cmID] = { name = name, challengeModeID = cmID }
        end
    end
    return dungeons
end

function Data:CountDungeons()
    local count = 0
    for _ in pairs(EquipMap.db.dungeons) do
        count = count + 1
    end
    return count
end

function Data:GetDungeonList()
    local list = {}
    for instanceID, dungeon in pairs(EquipMap.db.dungeons) do
        table.insert(list, { instanceID = instanceID, name = dungeon.name })
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end
