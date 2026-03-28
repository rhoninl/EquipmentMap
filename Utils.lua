-- EquipMap Utilities and Constants

local ADDON_NAME, ns = ...
local EquipMap = ns

-- Safety fallback: if Locales.lua failed to load, create L with key-as-value fallback
if not EquipMap.L then
    EquipMap.L = setmetatable({}, { __index = function(_, k) return k end })
end

-- Equipment location -> inventory slot ID (single slot items)
EquipMap.EQUIPLOC_TO_SLOT = {
    INVTYPE_HEAD = 1,
    INVTYPE_NECK = 2,
    INVTYPE_SHOULDER = 3,
    INVTYPE_CHEST = 5,
    INVTYPE_ROBE = 5,
    INVTYPE_WAIST = 6,
    INVTYPE_LEGS = 7,
    INVTYPE_FEET = 8,
    INVTYPE_WRIST = 9,
    INVTYPE_HAND = 10,
    INVTYPE_CLOAK = 15,
    INVTYPE_2HWEAPON = 16,
    INVTYPE_WEAPONMAINHAND = 16,
    INVTYPE_WEAPONOFFHAND = 17,
    INVTYPE_SHIELD = 17,
    INVTYPE_HOLDABLE = 17,
    INVTYPE_RANGED = 16,
    INVTYPE_RANGEDRIGHT = 16,
}

-- Equipment locations that map to multiple slots
EquipMap.MULTI_SLOT_EQUIPLOCS = {
    INVTYPE_FINGER = { 11, 12 },
    INVTYPE_TRINKET = { 13, 14 },
    INVTYPE_WEAPON = { 16, 17 },
}

-- Armor type constants
EquipMap.ARMOR_TYPES = {
    Cloth = 1,
    Leather = 2,
    Mail = 3,
    Plate = 4,
}

-- Armor subclassID -> normalized type string (locale-independent)
-- Enum.ItemArmorSubclass: 1=Cloth, 2=Leather, 3=Mail, 4=Plate
EquipMap.ARMOR_SUBCLASS_TO_TYPE = {
    [1] = "Cloth",
    [2] = "Leather",
    [3] = "Mail",
    [4] = "Plate",
}

-- Slot ID -> display name (localized)
local L = EquipMap.L
EquipMap.SLOT_NAMES = {
    [1] = L["Head"],
    [2] = L["Neck"],
    [3] = L["Shoulder"],
    [5] = L["Chest"],
    [6] = L["Waist"],
    [7] = L["Legs"],
    [8] = L["Feet"],
    [9] = L["Wrist"],
    [10] = L["Hands"],
    [11] = L["Ring"],
    [12] = L["Ring"],
    [13] = L["Trinket"],
    [14] = L["Trinket"],
    [15] = L["Back"],
    [16] = L["MainHand"],
    [17] = L["OffHand"],
}

-- Unique slot IDs for filter dropdown (no duplicates)
EquipMap.FILTER_SLOTS = {
    { id = 0, name = L["AllSlots"] },
    { id = 1, name = L["Head"] },
    { id = 2, name = L["Neck"] },
    { id = 3, name = L["Shoulder"] },
    { id = 15, name = L["Back"] },
    { id = 5, name = L["Chest"] },
    { id = 9, name = L["Wrist"] },
    { id = 10, name = L["Hands"] },
    { id = 6, name = L["Waist"] },
    { id = 7, name = L["Legs"] },
    { id = 8, name = L["Feet"] },
    { id = 11, name = L["Ring"] },
    { id = 13, name = L["Trinket"] },
    { id = 16, name = L["MainHand"] },
    { id = 17, name = L["OffHand"] },
}

-- Mythic (M0) difficulty ID for Encounter Journal
EquipMap.MYTHIC_DIFFICULTY = 23

-- Color codes
EquipMap.COLORS = {
    UPGRADE = "|cFF00FF00",    -- green
    DOWNGRADE = "|cFFFF0000",  -- red
    NEUTRAL = "|cFFFFFFFF",    -- white
    OWNED = "|cFF888888",      -- gray
    HEADER = "|cFFFFD100",     -- gold
    RESET = "|r",
}

function EquipMap:Print(msg)
    print(EquipMap.COLORS.HEADER .. "EquipMap:|r " .. msg)
end

function EquipMap:GetSlotName(slotID)
    return self.SLOT_NAMES[slotID] or "Unknown"
end

function EquipMap:ResolveSlotID(equipLoc)
    if not equipLoc then return nil end

    local multi = self.MULTI_SLOT_EQUIPLOCS[equipLoc]
    if multi then
        return multi[1]
    end

    return self.EQUIPLOC_TO_SLOT[equipLoc]
end

function EquipMap:FormatStatNames(item)
    local names = {}
    if item.crit and item.crit > 0 then names[#names + 1] = L["Crit"] end
    if item.haste and item.haste > 0 then names[#names + 1] = L["Haste"] end
    if item.mastery and item.mastery > 0 then names[#names + 1] = L["Mastery"] end
    if item.vers and item.vers > 0 then names[#names + 1] = L["Vers"] end
    return table.concat(names, " / ")
end
