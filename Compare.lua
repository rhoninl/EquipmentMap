-- MythicLootMap Item Comparison
-- Compares loot items against currently equipped gear

local ADDON_NAME, ns = ...
local MythicLootMap = ns

local Compare = {}
MythicLootMap.Compare = Compare

function Compare:GetPlayerEquipment()
    local equipped = {}
    for slotID = 1, 17 do
        local link = GetInventoryItemLink("player", slotID)
        if link then
            local _, _, _, itemLevel = GetItemInfo(link)
            equipped[slotID] = {
                itemLink = link,
                ilvl = itemLevel or 0,
                itemID = GetInventoryItemID("player", slotID),
            }
        end
    end
    return equipped
end

function Compare:CompareItem(item, equipped)
    if not item or not item.slot then return 0 end

    local equipLoc = item.slot

    -- Two-hand weapon: special comparison
    if equipLoc == "INVTYPE_2HWEAPON" then
        local mhIlvl = equipped[16] and equipped[16].ilvl or nil
        local ohIlvl = equipped[17] and equipped[17].ilvl or nil
        return self:CalcTwoHandDelta(item.ilvl, mhIlvl, ohIlvl)
    end

    -- Multi-slot items (rings, trinkets, 1H weapons)
    local multiSlots = MythicLootMap.MULTI_SLOT_EQUIPLOCS[equipLoc]
    if multiSlots then
        local ilvls = {}
        for _, slotID in ipairs(multiSlots) do
            local eq = equipped[slotID]
            ilvls[#ilvls + 1] = eq and eq.ilvl or nil
        end
        return self:CalcBestDeltaForSlots(item.ilvl, ilvls)
    end

    -- Single-slot items
    local slotID = MythicLootMap.EQUIPLOC_TO_SLOT[equipLoc]
    if not slotID then return 0 end

    local eq = equipped[slotID]
    local equippedIlvl = eq and eq.ilvl or nil
    return self:CalcIlvlDelta(item.ilvl, equippedIlvl)
end

function Compare:CalcIlvlDelta(itemIlvl, equippedIlvl)
    if not equippedIlvl or equippedIlvl == 0 then
        return itemIlvl
    end
    return itemIlvl - equippedIlvl
end

function Compare:CalcBestDeltaForSlots(itemIlvl, equippedIlvls)
    -- Find the slot where this item provides the biggest upgrade
    -- If any slot is empty, that's the best (full ilvl as delta)
    local bestDelta = nil

    for _, ilvl in ipairs(equippedIlvls) do
        if not ilvl or ilvl == 0 then
            return itemIlvl -- empty slot = always an upgrade
        end

        local delta = itemIlvl - ilvl
        if not bestDelta or delta > bestDelta then
            bestDelta = delta
        end
    end

    if #equippedIlvls == 0 then
        return itemIlvl
    end

    return bestDelta or 0
end

function Compare:CalcTwoHandDelta(itemIlvl, mhIlvl, ohIlvl)
    if (not mhIlvl or mhIlvl == 0) and (not ohIlvl or ohIlvl == 0) then
        return itemIlvl
    end

    if not ohIlvl or ohIlvl == 0 then
        return self:CalcIlvlDelta(itemIlvl, mhIlvl)
    end

    if not mhIlvl or mhIlvl == 0 then
        return self:CalcIlvlDelta(itemIlvl, ohIlvl)
    end

    -- Compare against the average of MH + OH
    local avgEquipped = math.floor((mhIlvl + ohIlvl) / 2)
    return itemIlvl - avgEquipped
end

function Compare:GetSlotIDsForEquipLoc(equipLoc)
    local multi = MythicLootMap.MULTI_SLOT_EQUIPLOCS[equipLoc]
    if multi then
        return { multi[1], multi[2] }
    end

    local slotID = MythicLootMap.EQUIPLOC_TO_SLOT[equipLoc]
    if slotID then
        return { slotID }
    end

    return {}
end

function Compare:FormatDelta(delta)
    if not delta or delta == 0 then
        return MythicLootMap.COLORS.NEUTRAL .. "0" .. MythicLootMap.COLORS.RESET
    elseif delta > 0 then
        return MythicLootMap.COLORS.UPGRADE .. "+" .. delta .. MythicLootMap.COLORS.RESET
    else
        return MythicLootMap.COLORS.DOWNGRADE .. delta .. MythicLootMap.COLORS.RESET
    end
end
