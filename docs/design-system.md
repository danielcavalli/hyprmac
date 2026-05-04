# Design System

Hyprmac uses a Solarpunk Liquid Glass visual system: smoked bronze glass, warm cream text, sun-amber focus, cobalt editorial linework, solar-green healthy state, and coral only for real danger or failure.

## Geometry

```text
SketchyBar height      36
SketchyBar margin      8
SketchyBar radius      14
Item height            26
Item radius            12
Popup radius           18
Yabai gap              10
Top window padding     5
Window border width    6
```

SketchyBar owns the top system surface. `yabai` reserves `46px` for that surface, then applies `5px` top padding so windows sit close to the glass without touching it.

## Materials

Tokens live in `home/.config/sketchybar/theme.sh` and can be overridden from `local.pre.sh`.

- System glass: `BAR_BG`, `POPUP_BG`, `POPUP_BORDER`, `POPUP_SHADOW`
- Passive surfaces: `ITEM_BG`, `ITEM_BG_HOT`, `BRACKET_BG`, `BRACKET_BORDER`
- Workspace nodes: `SPACE_BG`, `SPACE_BORDER`, `SPACE_ACTIVE_BG`, `SPACE_ACTIVE_BORDER`
- Active focus: `ITEM_BG_ACTIVE`, `ITEM_BORDER_ACTIVE`, `AMBER`
- Healthy state: `ITEM_BG_OK`, `ITEM_BORDER_OK`, `LIME`
- Editorial linework: `BLUE`, `CYAN`
- Confirmation: `ITEM_BG_CONFIRM`, `ITEM_BORDER_CONFIRM`, `AMBER`
- Danger: `ITEM_BG_WARN`, `ITEM_BORDER_WARN`, `ROSE`

## Controls

Daily controls are SketchyBar-first:

- `Super+Ctrl+A` toggles the Sound popup.
- `Super+Ctrl+B` toggles the Bluetooth popup.
- `Super+Ctrl+W` toggles the Wi-Fi popup.
- `Super+Escape` toggles the power popup.

Each control keeps a System Settings fallback, and destructive power actions require an explicit confirmation row before `hyprmac power` runs them.

## Terminal And Borders

Ghostty uses the same smoked bronze, cream, amber, cobalt, and solar-green palette as SketchyBar. JankyBorders uses a `6px` amber active border with low-alpha cream inactive borders.
