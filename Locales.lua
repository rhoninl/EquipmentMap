-- EquipMap Localization
-- Language is configurable via /equipmap lang <code>

local ADDON_NAME, ns = ...
local EquipMap = ns

local translations = {}
EquipMap.translations = translations
EquipMap.supportedLocales = { "enUS", "zhCN", "zhTW" }

-- English
translations["enUS"] = {
    Title = "EquipMap - Mythic+ Loot Browser",
    AllSlots = "All Slots",
    AllDungeons = "All Dungeons",
    Stat1 = "Stat 1",
    Stat2 = "Stat 2",
    Any = "Any",
    Crit = "Crit",
    Haste = "Haste",
    Mastery = "Mastery",
    Vers = "Vers",
    MySpec = "My Spec",
    Item = "Item",
    Slot = "Slot",
    Stats = "Stats",
    Dungeon = "Dungeon",
    Boss = "Boss",
    Unknown = "Unknown",
    Showing = "Showing %d / %d items",
    Loaded = "Loaded %d items from %d dungeons.",
    NoDungeons = "No M+ dungeons found for current season.",
    DataReloaded = "Data reloaded.",
    LoadedMsg = "Loaded. Type /equipmap to open.",
    Commands = "Commands:",
    CmdToggle = "  /equipmap - Toggle loot browser window",
    CmdReload = "  /equipmap reload - Reload dungeon data",
    CmdTest = "  /equipmap test - Run test suite",
    CmdHelp = "  /equipmap help - Show this help",
    CmdLang = "  /equipmap lang <enUS|zhCN|zhTW> - Set language",
    LangSet = "Language set to: %s (reload UI to apply)",
    LangCurrent = "Current language: %s",
    Head = "Head",
    Neck = "Neck",
    Shoulder = "Shoulder",
    Back = "Back",
    Chest = "Chest",
    Wrist = "Wrist",
    Hands = "Hands",
    Waist = "Waist",
    Legs = "Legs",
    Feet = "Feet",
    Ring = "Ring",
    Trinket = "Trinket",
    MainHand = "Main Hand",
    OffHand = "Off Hand",
}

-- Simplified Chinese
translations["zhCN"] = {
    Title = "EquipMap - \229\143\178\232\175\151\229\137\175\232\163\133\229\164\135\230\181\143\232\167\136\229\153\168",
    AllSlots = "\230\137\128\230\156\137\233\131\168\228\189\141",
    AllDungeons = "\230\137\128\230\156\137\229\137\175\230\156\172",
    Stat1 = "\229\177\158\230\128\167 1",
    Stat2 = "\229\177\158\230\128\167 2",
    Any = "\228\184\141\233\153\144",
    Crit = "\230\154\180\229\135\187",
    Haste = "\230\128\165\233\128\159",
    Mastery = "\231\178\190\233\128\154",
    Vers = "\229\133\168\232\131\189",
    MySpec = "\230\136\145\231\154\132\228\184\147\231\178\190",
    Item = "\231\137\169\229\147\129",
    Slot = "\233\131\168\228\189\141",
    Stats = "\229\177\158\230\128\167",
    Dungeon = "\229\137\175\230\156\172",
    Boss = "\233\166\150\233\162\134",
    Unknown = "\230\156\170\231\159\165",
    Showing = "\230\152\190\231\164\186 %d / %d \228\187\182",
    Loaded = "\229\183\178\229\138\160\232\189\189 %d \228\187\182, \230\157\165\232\135\170 %d \228\184\170\229\137\175\230\156\172",
    NoDungeons = "\230\156\172\232\181\155\229\173\163\230\178\161\230\156\137\229\143\178\232\175\151\229\137\175\229\137\175\230\156\172",
    DataReloaded = "\230\149\176\230\141\174\229\183\178\233\135\141\230\150\176\229\138\160\232\189\189",
    LoadedMsg = "\229\183\178\229\138\160\232\189\189, \232\190\147\229\133\165 /equipmap \230\137\147\229\188\128",
    Commands = "\229\145\189\228\187\164:",
    CmdToggle = "  /equipmap - \230\137\147\229\188\128/\229\133\179\233\151\173\230\181\143\232\167\136\229\153\168",
    CmdReload = "  /equipmap reload - \233\135\141\230\150\176\229\138\160\232\189\189\230\149\176\230\141\174",
    CmdTest = "  /equipmap test - \232\191\144\232\161\140\230\181\139\232\175\149",
    CmdHelp = "  /equipmap help - \230\152\190\231\164\186\229\184\174\229\138\169",
    CmdLang = "  /equipmap lang <enUS|zhCN|zhTW> - \232\174\190\231\189\174\232\175\173\232\168\128",
    LangSet = "\232\175\173\232\168\128\229\183\178\232\174\190\231\189\174\228\184\186: %s (\233\135\141\232\189\189UI\231\148\159\230\149\136)",
    LangCurrent = "\229\189\147\229\137\141\232\175\173\232\168\128: %s",
    Head = "\229\164\180",
    Neck = "\233\162\136",
    Shoulder = "\232\130\169",
    Back = "\232\131\140",
    Chest = "\232\131\184",
    Wrist = "\232\133\149",
    Hands = "\230\137\139",
    Waist = "\232\133\176",
    Legs = "\232\133\191",
    Feet = "\232\132\154",
    Ring = "\230\136\146\230\140\135",
    Trinket = "\233\165\176\229\147\129",
    MainHand = "\228\184\187\230\137\139",
    OffHand = "\229\137\175\230\137\139",
}

-- Traditional Chinese
translations["zhTW"] = {
    Title = "EquipMap - \229\130\179\232\168\142\229\137\175\232\163\157\229\130\153\231\128\143\232\166\189\229\153\168",
    AllSlots = "\230\137\128\230\156\137\233\131\168\228\189\141",
    AllDungeons = "\230\137\128\230\156\137\229\137\175\230\156\172",
    Stat1 = "\229\177\172\230\128\167 1",
    Stat2 = "\229\177\172\230\128\167 2",
    Any = "\228\184\141\233\153\144",
    Crit = "\231\136\134\230\147\138",
    Haste = "\230\128\165\233\128\159",
    Mastery = "\231\178\190\233\128\154",
    Vers = "\232\144\172\232\131\189",
    MySpec = "\230\136\145\231\154\132\229\176\136\231\178\190",
    Item = "\231\137\169\229\147\129",
    Slot = "\233\131\168\228\189\141",
    Stats = "\229\177\172\230\128\167",
    Dungeon = "\229\137\175\230\156\172",
    Boss = "\233\166\150\233\160\152",
    Unknown = "\230\156\170\231\159\165",
    Showing = "\233\161\175\231\164\186 %d / %d \228\187\182",
    Loaded = "\229\183\178\232\188\137\229\133\165 %d \228\187\182, \228\190\134\232\135\170 %d \229\128\139\229\137\175\230\156\172",
    NoDungeons = "\230\156\172\232\179\189\230\178\146\230\156\137\229\130\179\232\168\142\229\137\175\229\137\175\230\156\172",
    DataReloaded = "\232\179\135\230\150\153\229\183\178\233\135\141\230\150\176\232\188\137\229\133\165",
    LoadedMsg = "\229\183\178\232\188\137\229\133\165, \232\188\270\229\133\165 /equipmap \233\150\139\229\149\159",
    Commands = "\229\145\189\228\187\164:",
    CmdToggle = "  /equipmap - \233\150\139\229\149\159/\233\151\156\233\150\137\231\128\143\232\166\189\229\153\168",
    CmdReload = "  /equipmap reload - \233\135\141\230\150\176\232\188\137\229\133\165\232\179\135\230\150\153",
    CmdTest = "  /equipmap test - \229\159\183\232\161\140\230\184\172\232\169\166",
    CmdHelp = "  /equipmap help - \233\161\175\231\164\186\229\185\171\229\138\169",
    CmdLang = "  /equipmap lang <enUS|zhCN|zhTW> - \232\168\173\229\174\154\232\170\158\232\168\128",
    LangSet = "\232\170\158\232\168\128\229\183\178\232\168\173\229\174\154\231\130\186: %s (\233\135\141\232\188\137UI\231\148\159\230\149\136)",
    LangCurrent = "\231\155\174\229\137\141\232\170\158\232\168\128: %s",
    Head = "\233\160\173",
    Neck = "\233\160\184",
    Shoulder = "\232\130\169",
    Back = "\232\131\140",
    Chest = "\232\131\184",
    Wrist = "\232\133\149",
    Hands = "\230\137\139",
    Waist = "\232\133\176",
    Legs = "\232\133\191",
    Feet = "\232\133\179",
    Ring = "\230\136\146\230\140\135",
    Trinket = "\233\163\190\229\147\129",
    MainHand = "\228\184\187\230\137\139",
    OffHand = "\229\137\175\230\137\139",
}

-- Apply language: called from Core.lua after SavedVariables load
function EquipMap:ApplyLocale(localeCode)
    local t = translations[localeCode] or translations["enUS"]
    for k, v in pairs(t) do
        EquipMap.L[k] = v
    end
end

-- Default to client locale on first load
EquipMap:ApplyLocale(GetLocale())
