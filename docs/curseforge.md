# MythicLootMap

## Short Description (for CurseForge summary)

Browse all Mythic+ dungeon loot in one window. Filter by slot, armor type, dungeon, stats, and spec.

---

## Full Description (for CurseForge page)

### MythicLootMap

**MythicLootMap** is a lightweight loot browser that shows every equipment drop from all Mythic+ dungeons in the current season — in a single, filterable window.

Stop alt-tabbing to Wowhead. Stop clicking through the Adventure Journal dungeon by dungeon. MythicLootMap puts everything in one place so you can plan your gear efficiently.

---

### Features

- **All M+ Loot in One Window** — Automatically loads every equipment drop from all current season Mythic+ dungeons via the in-game Encounter Journal API. No hardcoded data, updates every season automatically.

- **Powerful Filters** — Narrow down exactly what you need:
  - **Slot** — Head, Chest, Weapon, Ring, Trinket, etc.
  - **Armor Type** — Cloth, Leather, Mail, Plate
  - **Dungeon** — Filter to a specific dungeon
  - **Stats** — Two independent stat filters (Crit, Haste, Mastery, Versatility). Find that perfect Crit/Haste ring instantly.
  - **My Spec** — Toggle to show only items usable by your current specialization

- **Secondary Stats at a Glance** — Each item shows which secondary stats it has (e.g. "Crit / Haste") right in the list, no tooltip hovering needed.

- **Item Tooltips** — Hover over any item to see the full in-game tooltip with stats and comparison.

- **Shift-Click to Link** — Shift-click any item to link it in chat.

- **Minimap Button** — Draggable minimap icon to toggle the window. Or use `/mlm` (also `/equipmap`).

- **Multi-Language** — Supports English, Simplified Chinese, and Traditional Chinese. Change language from the settings panel (gear icon).

- **ESC to Close** — Press Escape to close the window, just like any other game panel.

- **Zero Dependencies** — No libraries required. Pure lightweight addon.

---

### Slash Commands

| Command | Description |
|---|---|
| `/mlm` | Toggle the loot browser window |
| `/mlm reload` | Reload dungeon data |
| `/mlm help` | Show help |

`/equipmap` also works as an alias.

---

### How It Works

MythicLootMap dynamically queries the WoW Encounter Journal API to load all dungeon loot for the current M+ season. It detects the active dungeon rotation via `C_ChallengeMode.GetMapTable()`, maps each dungeon to the Encounter Journal, and pulls all item data including secondary stats. Everything is loaded in-game — no external data files that go stale.

---

### Compatibility

- **WoW Retail 12.0+** (Midnight)
- Uses modern WoW 12.0 APIs: ScrollBox, DropdownButton, C_EncounterJournal

---

### Feedback & Issues

Report bugs or request features at: https://github.com/rhoninl/EquipmentMap/issues
