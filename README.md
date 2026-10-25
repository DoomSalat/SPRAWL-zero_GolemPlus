# Golem Plus

*[Русская версия](README.ru.md)*

Small quality-of-life and combat tweaks for **SPRAWL zero**, written as a Lua mod for UE4SS. Every tweak can be switched off from an in-game panel (press **F1**). The name comes from the game: some enemies call the player a golem.

| | |
|---|---|
| **Version** | 1.0.0 |
| **Tested on** | SPRAWL zero (Steam AppID 3748520), build 25787069, Unreal Engine 5.7.4 |
| **Needs** | [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental-latest), experimental-latest build (tested with 3.0.1-1181-g83330635) |
| **Changes game files** | No |
| **License** | Public domain ([The Unlicense](LICENSE)) |

The mod reads Blueprint and C++ names from the game, so a future game update may break individual tweaks. Everything else keeps working: a failing tweak only writes a line to the log.

## Features

- **Sprint keeps the grabbed object.** Starting a sprint no longer drops what the gravity gloves are holding.
- **Pullable syringes.** Health syringes dropped by enemies can be pulled with the gravity gloves button. They fly to you and heal. The mod reads the button from the game's own bindings, so it always matches your controls (mouse and keyboard buttons; gamepad buttons are not supported yet).
- **Kill marker.** A fading red "LIQUIDATED" text with a sound appears next to the crosshair when an enemy dies, so a kill is easy to tell apart from a hit.
- **No slowdown while aiming.** Every weapon keeps full movement speed when you aim down sights.
- **Alt scan.** When the Alt ability fires, enemies (not allies) within 25 m are highlighted for 10 seconds, and relic fragments and codex tablets within 25 m get an outline. It only runs when the ability is off cooldown.
- **Punch with a weapon in hand.** A button (mouse 4 by default) drops the weapon, punches with the gravity gloves and picks the same weapon back up with the same ammo. This is an experimental workaround, see Known issues.

## Requirements

Install [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental-latest) first (the experimental-latest build, file `UE4SS_v3.0.1-...zip`). Unpack it into `SPRAWL 0/Silas/Binaries/Win64/` so that `dwmapi.dll` and the `ue4ss` folder sit next to `Silas-Win64-Shipping.exe`.

## Install

1. Install UE4SS (see above) and start the game once.
2. Unpack this archive into the game folder (`SPRAWL 0`). The files go to `Silas/Binaries/Win64/ue4ss/Mods/GolemPlus/`.
3. Start the game. The file `Silas/Binaries/Win64/ue4ss/UE4SS.log` must contain `[GolemPlus] loaded`.

## Uninstall

Delete the folder `Silas/Binaries/Win64/ue4ss/Mods/GolemPlus`. To remove UE4SS as well, delete `dwmapi.dll` and the `ue4ss` folder from `Silas/Binaries/Win64`.

## Settings

Press **F1** in game to open the panel. It follows the game language (English, Russian, German, Spanish, French, Japanese, Korean, Polish, Simplified and Traditional Chinese, Brazilian Portuguese).

| Key | Action |
|---|---|
| F1 | open and close the panel |
| Up / Down | choose a line |
| Enter | switch the tweak on and off, or change the punch button (mouse 4, mouse 5, mouse wheel click, V, F) |

Your choices are stored in `Mods/GolemPlus/settings.cfg` and survive restarts.

## Known issues

- **Punch with a weapon** is a workaround: the game drops the weapon and the mod returns it. Early versions crashed the game here. If the weapon ever stays on the floor, pick it up by hand and switch the tweak off in the panel.
- Each punch leaves an invisible weapon pickup in the level until the level changes.
- Switching off "Pullable syringes" does not remove the glove target that was already added to syringes lying in the level; it only stops the button from pulling them.
- The kill marker and the Alt scan work through polling, so the first 3 seconds after a level loads they are inactive, and they can react up to about 0.2 seconds late.
- The gravity gloves button for syringes is detected for mouse and keyboard only.
- Do not use the UE4SS hot reload (`Ctrl+R`) during normal play. It is off in a fresh UE4SS install; if you turn it on, repeated reloads can leave old callbacks behind and crash the game.

## Troubleshooting

- **Crashes.** First try the exclusive fullscreen mode: in the author's tests the crashes stopped after switching the display mode, but the cause is not confirmed. You can also switch off the other mods bundled with UE4SS in `ue4ss/Mods/mods.txt` (set `: 0`); this mod does not need them.
- **Nothing happens.** Open `Silas/Binaries/Win64/ue4ss/UE4SS.log` and search for `GolemPlus`. Lines with `ERROR` name the tweak that failed.
- **The game does not start.** Remove `dwmapi.dll` from `Silas/Binaries/Win64` to disable UE4SS.

## Credits

Built on [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS). SPRAWL zero belongs to its developers; this mod is unofficial.

## License

Public domain ([The Unlicense](LICENSE)). Copy, change and redistribute the mod however you like.
