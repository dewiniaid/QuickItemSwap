# Quick Item Swap

Quick Item Swap is a mod that enables you to quickly change between related items.  For instance, if you're currently
holding a transport belt, the "Next Item Group" keybind will pick up a Fast Transport Belt instead (presuming you 
have one) and the "Next Related Item" keybind will pick up a Splitter instead (again presuming you have one).  By
default, 

A wide variety of items and groups are supported, including transport belts, inserters, train vehicles,
 railway and rail signals, inserters, pipes, and modules.     

New in version 0.3.2 is the ability for item cycling to place ghosts of items you do not have, and the ability to 
whitelist or blacklist specific items. 

 
 Additionally, the following mods are supported.
 
  * [Batteries Not Included](https://mods.factorio.com/mods/dewiniaid/BatteriesNotIncluded)
  * [Electric Vehicles](https://mods.factorio.com/mod/ElectricVehicles3) (locomotive only)
  * [FARL](https://mods.factorio.com/mod/FARL) (locomotive only)
  * [Creative Mode](https://mods.factorio.com/mod/creative-mode-fix)
  * [Logistic Train Network](https://mods.factorio.com/mod/LogisticTrainNetwork)
  * [Train Supply Manager](https://mods.factorio.com/mod/train-pubsub)
  * [Smarter Trains](https://mods.factorio.com/mod/SmartTrains)
  * [Vehicle Wagon](https://mods.factorio.com/mod/Vehicle%20Wagon)
  * [Nixie Tubes](https://mods.factorio.com/mod/nixie-tubes) (Just justarandomgeek's version currently)
   
## Known Issues

* Items on the quickbar without filters may change locations if the mod selects them, and the quickbar in
  general may have some odd interactions.  These are harmless (but annoying) and have no good fix until
  Factorio 0.16
  
* Mousewheel bindings do not work consistently due to what appears to be a
  [bug in Factorio](https://forums.factorio.com/viewtopic.php?f=34&t=54327).
  
* Not tested in multiplayer.  Please report back!

## Unknown Issues
   
Found a bug?  Please visit the [Issues page](https://github.com/dewiniaid/QuickItemSwap/issues) to see if it has 
already been reported, and report it if not.

## Changelog

### 0.3.3 (2020-01-31)
* **Update for Factorio 0.18**

### 0.3.2 (2019-03-14)
*a.k.a. version 0.3.14159*
* QuickItemSwap can now cycle between item ghosts if you lack the actual item.
  * By default, this excludes items that have not been researched.  You can globally disable this in Mod Settings, or you can whitelist specific items.
* You can now whitelist or blacklist items (default keybind: Alt+Y while holding an item)
  * When cycling between related items, blacklisted items will be ignored (unless they are in your inventory)
  * When cycling between related items, whitelisted items will be allowed (even if they are not yet researched)
  * Blacklisting and whitelisting only affects cases when a ghost would be chosen or if an item would be created (in cheat mode).  Items in your inventory are always considered.
  * You can reset your entire blacklist with `/qis-clear-blacklist`
* Added support for the train stops in [Train Supply Manager](https://mods.factorio.com/mod/train-pubsub)
* Fixed possible crash when cycling blueprints.

### 0.3.1 (2019-02-27)
* **Update for Factorio 0.17.**
* Removed all quickbar logic.
* Generate group information for belts/splitters/undergrounds procedurally.  This should automatically add support for modded belts, such as those from Bob's Logistics.

### 0.3.0 (2018-04-23)
* Add support for blueprints, blueprint books, deconstruction planners, and similar items from mods.
  *  Items of a particular type are treated as members of one group.  "Y" will cycle between different blueprint books, for instance.
  * Cycling groups will cycle between selecting a blueprint, a blueprint book, or a deconstruction planner.
  * Other items that have an item_number are also supported when cycling items, but do not support cycling groups.
* Added support for the Artillery Wagon
* Add support for [Electric Vehicles](https://mods.factorio.com/mod/ElectricVehicles3) (locomotives only)
* Add support for [FARL](https://mods.factorio.com/mod/FARL) (locomotives only)

### 0.2.4 (2017-12-23)
* Add support for the unofficial Creative Mode Fix.
* Add Buffer Chests to the Logistic Chests group, and reordered the group to match the inventory window.

### 0.2.3 (2017-12-13)
* **Update for Factorio 0.16**
* Temporarily add support for Batteries Not Included, since [a bug in the current Factorio experimental](https://forums.factorio.com/viewtopic.php?f=182&t=54567&p=321491) prevents that support from working in the opposite direction.
* API: Added more verbose error messaging if another mod submits an invalid patch.
* API: Swapped the order of arguments on `apply_patch` to make it less likely for someone to inadvertently forget to
  specify `source`.

### 0.2.2 (2017-12-11)
* Add support for items from Logistic Train Network, Smarter Trains, Vehicle Wagon, and Nixie Tubes.
* Add speculative support for artillery wagons.

### 0.2.1 (2017-12-05)
* Fix default keybindings for Previous Item and Previous Group.
* Console announcements when a configuration change is detected are now only displayed in debug mode.  They also now 
  are prefixed with `[QuickItemSwap]` to indicate they are coming from this mod.

### 0.2.0 (2017-12-01)
* Made significant internal changes to allow mod integration
* Added support for items from Creative Mode
* Added support for creating items from thin air (rather than skipping over them) when your player is in cheat mode (i.e. as a result of the creative mode mode or `/c game.players[1].cheat_mode = true`).  Can be toggled in settings.  Has no effect when not in cheat mode.
* First pass of an API to allow other mods to add recipes.

### 0.1.1 (2017-11-30)
* Flip logic on modules to make more sense: each tier is now a group, rather than each module type being a group.
 
### 0.1.0 (2017-11-30)
* First public release.

## API for Mod Developers 

For discussion on this topic, find me on IRC or Discord or 
[comment on this issue](https://github.com/dewiniaid/QuickItemSwap/issues/3).

General recommended flow is:

 - Make your mod optionally depend on QuickItemSwap so that QuickItemSwap initializes first.
 - During your mod's `on_init`, `on_configuration_changed` and possibly `on_runtime_mod_settings_changed` events, call
   `apply_patch` with the appropriate information.
 - Listen for the custom events `on_qis_mappings_reset` and, if desired, `on_qis_mappings_patched` (event IDs are 
   published through `get_events`) and resubmit your patches as needed. 

Currently implemented:

#### `remote.call("QuickItemSwap", "debug", [new_setting])`

Returns (and possibly changes) the debug setting for QIS. Note that debug being on will produce an incessant amount
of screen spam.  Set to `true` to enable debugging, `false` to disable, or `nil` to just see what the current setting is.
 
#### `remote.call("QuickItemSwap", "dump_mappings")`

Writes the current mapping table to `script-output/quickitemswap-mappings.txt`

#### `remote.call("QuickItemSwap", "get_events")`

Returns a table of `string = number` containing the custom events used by QuickItemSwap.  Right now, the two events
are:
  
  - `on_qis_mappings_reset` - Triggered when QuickItemSwap or another mod resets the item mappings and rebuilds them
    from scratch.  This can happen on version updates, mod changes, etc.  When this fires, any patches provided by your
    mod will be lost and thus must be resubmitted.
  
    Event table fields:
    
    | Field | Explanation |
    | ----- | ----------- |
    | `why` | Reason for the reset.  May be `"init"` (QIS's `on_init()`), `"settings-changed"` (QIS's mod settings changing), `"configuration-changed"` (Mod versions or startup settings changing) or `"remote"` (a remote caller asked it to reset)  

  - `on_qis_mappings_patched` - Triggered in response to someone (possibly you) calling `apply_patch`.  Allows for mods to react to other mods patching the table if it makes sense to.   
  
    Event table fields:
    
    | Field | Explanation |
    | ----- | ----------- |
    | `patch` | Contents of the patch that was provided.
    | `source` | Source providing the patch.  This is dependant on the caller providing a meaningful `source` parameter.
    
#### `remote.call("QuickItemSwap", "get_mappings", [category, [group, [item]]])`

Returns information on currently defined mappings.  If all 3 parameters are nil, the entire table is returned.  
Otherwise, returns just a subset for a given category, group within a category, or item within a group.

#### `remote.call("QuickItemSwap", "refresh", [only_if_dirty])`

Refreshes the internal state that QIS maintains to properly cycle between things.  If the optional parameter is `true`,
the refresh is only performed if the data is marked as out of date.

This is generally unneccessary -- `apply_patch` marks the data as outdated and it will be rebuilt on the first access
that requires it when outdated.

If `player` is specified, results will be printed to that player; otherwise they are printed using `game.print`
 
Produces no output if everything is valid.

#### `remote.call("QuickItemSwap", "validate_mappings", [player])`

Prints to the console any items in the mapping table that don't have a corresponding item prototype.

If `player` is specified, results will be printed to that player; otherwise they are printed using `game.print`
 
Produces no output if everything is valid.

#### `remote.call("QuickItemSwap", "apply_patch", patch, source)`

Applies a patch to the mapping table.

`source` is the name of your mod, and is used to explains where the patch came from.  It appears in error messages and 
in the `on_qis_mappings_patched` event.  It is recommended you use the `info.json` name of your mod here for
consistency, though nothing enforces this.

`patch` consists of a table formatted similar to the mapping table.  (See `mappings/base.lua` for a reference.)  It will be merged into the mapping table using
the following rules:

- If a category does not exist, it will be created.  If it exists, the groups will be merged.  If the patch explicitly 
  sets the category to `false`, the category will be deleted.  If the patch omits the category or sets it to `nil`, it 
  will be left as-is.
  
- The above logic also applies to groups within a category (with items being merged) and items within a group.

- Groups and items may specify a `default_order` attribute which is equivalent to `order` but won't override the 
  existing value if there is one.
  
Example: You've decided yellow belts are too slow, so your mod rips them out of the game and adds Ludicrous Transport 
Belts instead.
 
A patch accomplishing this will be look like this:

```lua
-- Note that this outer table is always required!
categories = {
    belts = {
        groups = {
            -- Deletes the 'normal' group
            -- normal = false,
                
            -- Addds our new group
            ludicrous = {
                order = 400,
                items = {
                    ['ludicrous-belt'] =             { order = 100, type = 'belt' },
                    ['ludicrous-underground-belt'] = { order = 200, type = 'underground' },
                    ['ludicrous-splitter'] =         { order = 300, type = 'splitter' },
                }
            }
        }
    }
}
```

Note that it is harmless to have items in the mapper that don't have prototypes -- though it will trigger a (probably
unnoticeable) performance hit when cycling items.

#### `remote.call("QuickItemSwap", "dump_inventory", inventory)`

Developer function.  May disappear at any time.

#### `remote.call("QuickItemSwap", "dump_quickbar", player)`

Developer function.  May disappear at any time.
