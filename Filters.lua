-- MythicLootMap Filter Logic

local ADDON_NAME, ns = ...
local MythicLootMap = ns

local Filters = {}
MythicLootMap.Filters = Filters

-- Current active filter state
Filters.current = {
    slotID = nil,        -- nil = all slots
    instanceID = nil,    -- nil = all dungeons
    armorType = nil,     -- nil = all; "Cloth", "Leather", "Mail", "Plate"
    specFilter = false,  -- use EJ class/spec filter
    stat1 = nil,         -- nil = any; "crit", "haste", "mastery", "vers"
    stat2 = nil,         -- nil = any; second optional stat filter
}

function Filters:Apply(items, filterOverrides)
    local filters = filterOverrides or self.current
    local result = {}

    for _, item in ipairs(items) do
        if self:MatchesFilters(item, filters) then
            result[#result + 1] = item
        end
    end

    return result
end

function Filters:MatchesFilters(item, filters)
    if filters.slotID and filters.slotID > 0 then
        if not self:MatchesSlot(item, filters.slotID) then
            return false
        end
    end

    if filters.instanceID and filters.instanceID > 0 then
        if item.instanceID ~= filters.instanceID then
            return false
        end
    end

    if filters.armorType then
        if item.armorType ~= filters.armorType then
            return false
        end
    end

    -- Stat filters: item must have both selected stats (if set)
    if filters.stat1 then
        local value = item[filters.stat1]
        if not value or value <= 0 then
            return false
        end
    end

    if filters.stat2 then
        local value = item[filters.stat2]
        if not value or value <= 0 then
            return false
        end
    end

    return true
end

function Filters:MatchesSlot(item, filterSlotID)
    if item.slotID == filterSlotID then
        return true
    end

    if filterSlotID == 11 and item.slotID == 12 then return true end
    if filterSlotID == 12 and item.slotID == 11 then return true end
    if filterSlotID == 13 and item.slotID == 14 then return true end
    if filterSlotID == 14 and item.slotID == 13 then return true end

    return false
end

function Filters:Reset()
    self.current.slotID = nil
    self.current.instanceID = nil
    self.current.armorType = nil
    self.current.specFilter = false
    self.current.stat1 = nil
    self.current.stat2 = nil
end

function Filters:SetSlot(slotID)
    self.current.slotID = (slotID and slotID > 0) and slotID or nil
end

function Filters:SetDungeon(instanceID)
    self.current.instanceID = (instanceID and instanceID > 0) and instanceID or nil
end

function Filters:SetArmorType(armorType)
    self.current.armorType = armorType
end

function Filters:SetSpecFilter(enabled)
    self.current.specFilter = enabled
end

function Filters:SetStat1(stat)
    self.current.stat1 = stat
end

function Filters:SetStat2(stat)
    self.current.stat2 = stat
end

function Filters:GetFilteredItems()
    return self:Apply(MythicLootMap.db.items, self.current)
end
