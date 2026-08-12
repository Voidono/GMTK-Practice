# Debug mode

Debug mode is available only when Godot runs a debug build (including the editor). It never opens in a release export, including an itch.io Web export.

## Playtest controls

| Key | Action |
| --- | --- |
| F3 | Open or close the overlay |
| F4 | Refill the player's countdown time |
| F5 | Ask every `EnemySpawner` to spawn one enemy now |
| F6 | Spawn the map boss now (only once) |
| F7 | Toggle every spawner's min/max spawn-ring visualization |
| Alt+P | Switch to simulated Mobile controls |
| Alt+O | Switch to simulated PC controls |

The overlay reports player time and position, boss status, and the live count/cap of every spawner.

## Architecture

`DebugTools.gd` is an autoload and owns input plus high-level playtest actions. `DebugOverlay.gd` only displays state. Gameplay systems expose small `debug_*` methods instead of letting the autoload change their private fields directly.

```
DebugTools (hotkeys) -> debug_* API -> gameplay system
                         \-> DebugOverlay (read-only status)
```

This separation keeps debug additions out of normal gameplay code and makes the system safe to refactor.

## Add a new debug command

1. Add a `debug_*` method to the gameplay component. For example, a dash component could expose `debug_reset_cooldown()`.
2. Add a new key branch to `DebugTools._unhandled_input()` that finds the component and calls that method.
3. Add the shortcut to `DebugOverlay.refresh()` and the table above.
4. Keep the command behind `enabled`, which is set by `OS.is_debug_build()`.

For a mechanic with many related tools, create a dedicated debug component (for example `CombatDebugTools.gd`) and have `DebugTools` delegate to it. Do not grow one giant hotkey method indefinitely.

## Add a new line to the overlay

Query a public value or a `debug_*` getter in `DebugOverlay.refresh()`, then append a formatted string to `lines`. Avoid having the overlay mutate game state; it should stay read-only.

## Add a new enemy type

Duplicate an `EnemySpawner` node in the map, assign the enemy's scene, and tune its `spawn_start_delay`, interval, and cap. It automatically appears in the debug overlay and responds to F5/F7. The `MatchDirector` remains independent, so these spawners never affect boss timing.
