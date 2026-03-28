-- MythicLootMap Filter Tests

local MythicLootMap = MythicLootMap

local TestFilters = {}
MythicLootMap.TestFilters = TestFilters

-- Helper: create mock item entries for testing
local function MockItem(overrides)
    local item = {
        itemID = 1000,
        name = "Test Item",
        icon = 12345,
        slot = "INVTYPE_HEAD",
        slotID = 1,
        armorType = "Plate",
        itemLink = "",
        ilvl = 619,
        encounterID = 100,
        encounterName = "Boss",
        instanceID = 200,
        dungeonName = "Dungeon",
        owned = false,
        ilvlDelta = 5,
    }
    if overrides then
        for k, v in pairs(overrides) do
            item[k] = v
        end
    end
    return item
end

function TestFilters:Run(t)
    self:TestSlotFilter(t)
    self:TestDungeonFilter(t)
    self:TestUpgradesOnlyFilter(t)
    self:TestNotCollectedFilter(t)
    self:TestCombinedFilters(t)
    self:TestNoFilters(t)
    self:TestEmptyItemList(t)
end

function TestFilters:TestSlotFilter(t)
    local items = {
        MockItem({ slotID = 1, slot = "INVTYPE_HEAD" }),
        MockItem({ slotID = 5, slot = "INVTYPE_CHEST" }),
        MockItem({ slotID = 7, slot = "INVTYPE_LEGS" }),
        MockItem({ slotID = 1, slot = "INVTYPE_HEAD" }),
    }

    local filtered = MythicLootMap.Filters:Apply(items, { slotID = 1 })
    t:AssertEqual(2, #filtered, "Slot filter: 2 head items")

    filtered = MythicLootMap.Filters:Apply(items, { slotID = 5 })
    t:AssertEqual(1, #filtered, "Slot filter: 1 chest item")

    filtered = MythicLootMap.Filters:Apply(items, { slotID = 10 })
    t:AssertEqual(0, #filtered, "Slot filter: 0 hand items")
end

function TestFilters:TestDungeonFilter(t)
    local items = {
        MockItem({ instanceID = 200, dungeonName = "Rookery" }),
        MockItem({ instanceID = 201, dungeonName = "Stonevault" }),
        MockItem({ instanceID = 200, dungeonName = "Rookery" }),
        MockItem({ instanceID = 202, dungeonName = "Cleft" }),
    }

    local filtered = MythicLootMap.Filters:Apply(items, { instanceID = 200 })
    t:AssertEqual(2, #filtered, "Dungeon filter: 2 Rookery items")

    filtered = MythicLootMap.Filters:Apply(items, { instanceID = 999 })
    t:AssertEqual(0, #filtered, "Dungeon filter: 0 for non-existent dungeon")
end

function TestFilters:TestUpgradesOnlyFilter(t)
    local items = {
        MockItem({ ilvlDelta = 10 }),
        MockItem({ ilvlDelta = -5 }),
        MockItem({ ilvlDelta = 0 }),
        MockItem({ ilvlDelta = 3 }),
    }

    local filtered = MythicLootMap.Filters:Apply(items, { upgradesOnly = true })
    t:AssertEqual(2, #filtered, "Upgrades only: 2 items with positive delta")
end

function TestFilters:TestNotCollectedFilter(t)
    local items = {
        MockItem({ owned = true }),
        MockItem({ owned = false }),
        MockItem({ owned = false }),
        MockItem({ owned = true }),
    }

    local filtered = MythicLootMap.Filters:Apply(items, { notCollected = true })
    t:AssertEqual(2, #filtered, "Not collected: 2 unowned items")
end

function TestFilters:TestCombinedFilters(t)
    local items = {
        MockItem({ slotID = 1, instanceID = 200, ilvlDelta = 10, owned = false }),
        MockItem({ slotID = 1, instanceID = 200, ilvlDelta = -5, owned = false }),
        MockItem({ slotID = 5, instanceID = 200, ilvlDelta = 10, owned = false }),
        MockItem({ slotID = 1, instanceID = 201, ilvlDelta = 10, owned = true }),
        MockItem({ slotID = 1, instanceID = 200, ilvlDelta = 10, owned = true }),
    }

    -- Slot=1 + Dungeon=200 + Upgrades + Not collected
    local filtered = MythicLootMap.Filters:Apply(items, {
        slotID = 1,
        instanceID = 200,
        upgradesOnly = true,
        notCollected = true,
    })
    t:AssertEqual(1, #filtered, "Combined filters: only 1 item matches all")
end

function TestFilters:TestNoFilters(t)
    local items = {
        MockItem({}),
        MockItem({}),
        MockItem({}),
    }

    local filtered = MythicLootMap.Filters:Apply(items, {})
    t:AssertEqual(3, #filtered, "No filters: all items returned")
end

function TestFilters:TestEmptyItemList(t)
    local filtered = MythicLootMap.Filters:Apply({}, { slotID = 1 })
    t:AssertEqual(0, #filtered, "Empty list: 0 items")
end
