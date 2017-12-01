# Quick Item Swap

Quick Item Swap is a mod that enables you to quickly change between related items.  For instance, if you're currently
holding a transport belt, the "Next Item Group" keybind will pick up a Fast Transport Belt instead (presuming you 
have one) and the "Next Related Item" keybind will pick up a Splitter instead (again presuming you have one).

A wide variety of items and groups are supported, including transport belts, inserters, train vehicles,
 railway and rail signals, inserters, pipes, and modules.  Support for entities added by other mods is planned.
 
 **Note**: This is the first release of my first mod for Factorio, so expect some bugs.
 
## Known Issues

* Items on the quickbar without filters may change locations if the mod selects them, and the quickbar in
  general may have some odd interactions.  These are harmless (but annoying) and have no good fix until
  Factorio 0.16
  
* Mousewheel bindings do not work consistently due to what appears to be a
  [bug in Factorio](https://forums.factorio.com/viewtopic.php?f=34&t=54327).
  
* Not tested in multiplayer.

## Unknown Issues
   
Found a bug?  Please visit the [Issues page](https://github.com/dewiniaid/QuickItemSwap/issues) to see if it has 
already been reported, and report it if not.

## Planned Features

* Functionality for cycling between blueprint books and/or loose blueprints in inventory.
* Functionality for cycling between different types of selection tools (e.g. blueprints, deconstruction 
  planners, [justarandomgeek's Combinator Graph tool](https://mods.factorio.com/mods/justarandomgeek/combinatorgraph), 
  and the various tools added by Nexela's [Picker Extended](https://mods.factorio.com/mods/Nexela/PickerExtended).)
* API for mod developers (see below)

## For Mod Developers

I plan to add an API to allow other mods to alter the table of related items used by Quick Item Swap.  In the current
implementation, the table is created and initialized at startup; the initial data and code that does this
can be found in [`qis/mappings.lua`](https://github.com/dewiniaid/QuickItemSwap/blob/master/qis/mappings.lua)

Since I'm not the person that will need the API itself, I'd like to gather feedback from those who might want to use it
in order to develop something sane --- rather than presenting something that doesn't entirely fit your needs as a 
developer.
 
For discussion on this topic, find me on IRC or Discord or 
[comment on this issue](https://github.com/dewiniaid/QuickItemSwap/issues/3).

## Changelog

### 0.1.0 (11/30/2017)
* First public release.
 
