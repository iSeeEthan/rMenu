# rMenu
**A lightweight, open-source menu system for RedM**

rMenu is a versatile and user-friendly menu designed for RedM, offering players a seamless way to access weapons, vehicles, outfits, spawn locations, and more. Built with simplicity and customization in mind, this free and open-source tool is perfect for enhancing your RedM experience.

---

## Features

- **Modular Menu System**: Navigate through nested menus for weapons, vehicles, spawns, and more.  
- **Weapon Management**: Equip firearms, melee weapons, and misc items with ammo support.  
- **Teleportation**: Instantly travel to towns, camps, and landmarks.  
- **Character Customization**: Change outfits and ped models on the fly.  
- **Vehicle Spawning**: Spawn carriages, horses, and boats with ease.  
- **Health & Inventory**: Heal your character or clear your inventory with a single click.  
- **Persistent State**: Retains weapons, outfits, and ped models after respawn.  
- **Customizable**: Easily extend functionality via the `Config` tables.  

---

## Usage

- Open the menu with the command: `/rmenu`  
- Navigate using the on-screen prompts.  
- Select items to equip weapons, spawn vehicles, teleport, or modify your character.  

### Commands
- `/rmenu` - Opens the main menu.  
- `/dv` - Deletes your current horse, carriage or boat.   `v1.0.5`
---

## Dependencies

- **RedM**
- **jo_libs**: https://github.com/Jump-On-Studios/RedM-jo_libs
- **spawnmanager**

---

## Configuration

The menu is driven by configuration tables (assumed to be in a separate `Config.lua`). Modify these to add or remove options:

- `Config.Firearms`: List of firearms with hashes, ammo, and titles.  
- `Config.Towns`: Teleport coordinates for towns.  
- `Config.Horses`: Horse models for spawning.  
- *(See the full list in the code or Config.lua)*  

Example:  
```lua
Config.Towns = {
    { title = "Valentine", coords = { x = -179.22, y = 627.72, z = 113.09 } },
    { title = "Saint Denis", coords = { x = 2515.43, y = -1308.93, z = 48.95 } }
}
```

## Contributing

Contributions are welcome! Here’s how you can help:
Please ensure your code follows the existing style and includes comments where necessary.

---

*Last updated: March 12, 2025*  
