-- MythicLootMap Compare Tests

local MythicLootMap = MythicLootMap

local TestCompare = {}
MythicLootMap.TestCompare = TestCompare

function TestCompare:Run(t)
    self:TestIlvlDelta(t)
    self:TestEmptySlotComparison(t)
    self:TestMultiSlotComparison(t)
    self:TestTwoHandComparison(t)
    self:TestGetSlotIDsForEquipLoc(t)
end

function TestCompare:TestIlvlDelta(t)
    -- Upgrade: item is higher ilvl
    local delta = MythicLootMap.Compare:CalcIlvlDelta(619, 610)
    t:AssertEqual(9, delta, "619 vs 610 should be +9")

    -- Downgrade: item is lower ilvl
    delta = MythicLootMap.Compare:CalcIlvlDelta(600, 619)
    t:AssertEqual(-19, delta, "600 vs 619 should be -19")

    -- Same ilvl
    delta = MythicLootMap.Compare:CalcIlvlDelta(619, 619)
    t:AssertEqual(0, delta, "Same ilvl should be 0")
end

function TestCompare:TestEmptySlotComparison(t)
    -- When no item is equipped, delta should indicate upgrade (item ilvl vs 0)
    local delta = MythicLootMap.Compare:CalcIlvlDelta(619, 0)
    t:AssertEqual(619, delta, "Empty slot should show full ilvl as upgrade")

    delta = MythicLootMap.Compare:CalcIlvlDelta(619, nil)
    t:AssertEqual(619, delta, "Nil equipped ilvl should show full ilvl as upgrade")
end

function TestCompare:TestMultiSlotComparison(t)
    -- For rings/trinkets, compare against the LOWER ilvl of the two slots
    local delta = MythicLootMap.Compare:CalcBestDeltaForSlots(619, {610, 615})
    t:AssertEqual(9, delta, "Should compare against lower of two slots (610)")

    -- Both slots same ilvl
    delta = MythicLootMap.Compare:CalcBestDeltaForSlots(619, {615, 615})
    t:AssertEqual(4, delta, "Both slots same -> delta against either")

    -- Both slots higher
    delta = MythicLootMap.Compare:CalcBestDeltaForSlots(610, {619, 622})
    t:AssertEqual(-9, delta, "Both higher -> compare against lower (619)")

    -- One slot empty
    delta = MythicLootMap.Compare:CalcBestDeltaForSlots(619, {610, nil})
    t:AssertEqual(619, delta, "One empty slot -> full ilvl upgrade")

    -- Both slots empty
    delta = MythicLootMap.Compare:CalcBestDeltaForSlots(619, {nil, nil})
    t:AssertEqual(619, delta, "Both empty -> full ilvl upgrade")
end

function TestCompare:TestTwoHandComparison(t)
    -- 2H weapon: compare against combined MH+OH average
    local delta = MythicLootMap.Compare:CalcTwoHandDelta(619, 610, 605)
    -- Average of equipped = (610+605)/2 = 607.5, delta = 619-607.5 = 11.5 -> 11 (floor)
    t:AssertEqual(11, delta, "2H vs MH(610)+OH(605) avg")

    -- 2H with only MH equipped
    delta = MythicLootMap.Compare:CalcTwoHandDelta(619, 610, nil)
    t:AssertEqual(9, delta, "2H vs MH only")

    -- 2H with nothing equipped
    delta = MythicLootMap.Compare:CalcTwoHandDelta(619, nil, nil)
    t:AssertEqual(619, delta, "2H vs nothing equipped")
end

function TestCompare:TestGetSlotIDsForEquipLoc(t)
    local slots = MythicLootMap.Compare:GetSlotIDsForEquipLoc("INVTYPE_HEAD")
    t:AssertNotNil(slots, "Should return slots for HEAD")
    t:AssertEqual(1, #slots, "HEAD has 1 slot")
    t:AssertEqual(1, slots[1], "HEAD slot ID is 1")

    slots = MythicLootMap.Compare:GetSlotIDsForEquipLoc("INVTYPE_FINGER")
    t:AssertNotNil(slots, "Should return slots for FINGER")
    t:AssertEqual(2, #slots, "FINGER has 2 slots")

    slots = MythicLootMap.Compare:GetSlotIDsForEquipLoc("INVTYPE_TRINKET")
    t:AssertEqual(2, #slots, "TRINKET has 2 slots")

    slots = MythicLootMap.Compare:GetSlotIDsForEquipLoc("INVTYPE_WEAPON")
    t:AssertEqual(2, #slots, "WEAPON has 2 slots")

    slots = MythicLootMap.Compare:GetSlotIDsForEquipLoc("INVTYPE_2HWEAPON")
    t:AssertEqual(1, #slots, "2HWEAPON has 1 slot")
    t:AssertEqual(16, slots[1], "2HWEAPON slot is 16")
end
