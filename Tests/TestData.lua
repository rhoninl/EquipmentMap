-- MythicLootMap Data Loading Tests

local MythicLootMap = MythicLootMap

local TestData = {}
MythicLootMap.TestData = TestData

function TestData:Run(t)
    self:TestEquipLocToSlot(t)
    self:TestBuildItemEntry(t)
    self:TestParseDungeonList(t)
    self:TestItemDataStructure(t)
    self:TestMultiSlotMapping(t)
    self:TestArmorTypeMapping(t)
end

function TestData:TestEquipLocToSlot(t)
    local map = MythicLootMap.EQUIPLOC_TO_SLOT

    t:AssertNotNil(map, "EQUIPLOC_TO_SLOT should exist")
    t:AssertEqual(1, map["INVTYPE_HEAD"], "Head slot")
    t:AssertEqual(2, map["INVTYPE_NECK"], "Neck slot")
    t:AssertEqual(3, map["INVTYPE_SHOULDER"], "Shoulder slot")
    t:AssertEqual(5, map["INVTYPE_CHEST"], "Chest slot")
    t:AssertEqual(5, map["INVTYPE_ROBE"], "Robe -> Chest slot")
    t:AssertEqual(6, map["INVTYPE_WAIST"], "Waist slot")
    t:AssertEqual(7, map["INVTYPE_LEGS"], "Legs slot")
    t:AssertEqual(8, map["INVTYPE_FEET"], "Feet slot")
    t:AssertEqual(9, map["INVTYPE_WRIST"], "Wrist slot")
    t:AssertEqual(10, map["INVTYPE_HAND"], "Hand slot")
    t:AssertEqual(15, map["INVTYPE_CLOAK"], "Cloak -> Back slot")
    t:AssertEqual(16, map["INVTYPE_2HWEAPON"], "2H weapon -> MH slot")
    t:AssertEqual(16, map["INVTYPE_WEAPONMAINHAND"], "Main hand slot")
    t:AssertEqual(17, map["INVTYPE_WEAPONOFFHAND"], "Off hand slot")
    t:AssertEqual(17, map["INVTYPE_SHIELD"], "Shield -> OH slot")
    t:AssertEqual(17, map["INVTYPE_HOLDABLE"], "Holdable -> OH slot")
    t:AssertNil(map["INVTYPE_BAG"], "Bag slot should not exist")
end

function TestData:TestMultiSlotMapping(t)
    local multiSlots = MythicLootMap.MULTI_SLOT_EQUIPLOCS

    t:AssertNotNil(multiSlots, "MULTI_SLOT_EQUIPLOCS should exist")
    t:AssertNotNil(multiSlots["INVTYPE_FINGER"], "Finger should be multi-slot")
    t:AssertEqual(11, multiSlots["INVTYPE_FINGER"][1], "Finger slot 1")
    t:AssertEqual(12, multiSlots["INVTYPE_FINGER"][2], "Finger slot 2")
    t:AssertNotNil(multiSlots["INVTYPE_TRINKET"], "Trinket should be multi-slot")
    t:AssertEqual(13, multiSlots["INVTYPE_TRINKET"][1], "Trinket slot 1")
    t:AssertEqual(14, multiSlots["INVTYPE_TRINKET"][2], "Trinket slot 2")
    t:AssertNotNil(multiSlots["INVTYPE_WEAPON"], "Weapon should be multi-slot")
    t:AssertEqual(16, multiSlots["INVTYPE_WEAPON"][1], "Weapon slot 1")
    t:AssertEqual(17, multiSlots["INVTYPE_WEAPON"][2], "Weapon slot 2")
end

function TestData:TestBuildItemEntry(t)
    local entry = MythicLootMap.Data:BuildItemEntry({
        itemID = 12345,
        name = "Test Helm",
        icon = 12345,
        slot = "INVTYPE_HEAD",
        armorType = "Plate",
        itemLink = "|cff0070dd|Hitem:12345|h[Test Helm]|h|r",
        encounterID = 100,
        encounterName = "Test Boss",
        instanceID = 200,
        dungeonName = "Test Dungeon",
    })

    t:AssertNotNil(entry, "BuildItemEntry should return a table")
    t:AssertEqual(12345, entry.itemID, "Item ID")
    t:AssertEqual("Test Helm", entry.name, "Item name")
    t:AssertEqual("INVTYPE_HEAD", entry.slot, "Item slot")
    t:AssertEqual(1, entry.slotID, "Resolved slot ID")
    t:AssertEqual("Plate", entry.armorType, "Armor type")
    t:AssertEqual(100, entry.encounterID, "Encounter ID")
    t:AssertEqual("Test Boss", entry.encounterName, "Encounter name")
    t:AssertEqual(200, entry.instanceID, "Instance ID")
    t:AssertEqual("Test Dungeon", entry.dungeonName, "Dungeon name")
end

function TestData:TestParseDungeonList(t)
    -- Test with empty map table
    local dungeons = MythicLootMap.Data:ParseDungeonList({})
    t:AssertNotNil(dungeons, "ParseDungeonList should return a table")
    t:AssertTableLength(dungeons, 0, "Empty map table -> empty dungeon list")
end

function TestData:TestItemDataStructure(t)
    -- Test the full data structure initialization
    t:AssertNotNil(MythicLootMap.db, "MythicLootMap.db should exist")
    t:AssertNotNil(MythicLootMap.db.dungeons, "MythicLootMap.db.dungeons should exist")
    t:AssertNotNil(MythicLootMap.db.items, "MythicLootMap.db.items should exist")
end

function TestData:TestArmorTypeMapping(t)
    local map = MythicLootMap.ARMOR_TYPES

    t:AssertNotNil(map, "ARMOR_TYPES should exist")
    t:AssertNotNil(map["Cloth"], "Cloth armor type")
    t:AssertNotNil(map["Leather"], "Leather armor type")
    t:AssertNotNil(map["Mail"], "Mail armor type")
    t:AssertNotNil(map["Plate"], "Plate armor type")
end
