ClearWeatherTypePersist()
local playerVehicles = {}
local savedWeapons = {}
local respawnCoords = nil
local currentPedModel = nil
local currentOutfit = 0
local menus = {}

local function saveWeapons()
    savedWeapons = {}
    local ped = PlayerPedId()
    for _, weapon in ipairs(Config.Firearms) do
        if HasPedGotWeapon(ped, GetHashKey(weapon.hash), false) then
            savedWeapons[weapon.hash] = {ammoHash = weapon.ammoHash, ammoCount = weapon.ammoCount}
        end
    end
    for _, melee in ipairs(Config.Melees) do
        if HasPedGotWeapon(ped, GetHashKey(melee.hash), false) then
            savedWeapons[melee.hash] = {ammoHash = melee.ammoHash, ammoCount = melee.ammoCount}
        end
    end
    for _, item in ipairs(Config.MiscItems) do
        if HasPedGotWeapon(ped, GetHashKey(item.hash), false) then
            savedWeapons[item.hash] = {ammoHash = item.ammoHash, ammoCount = item.ammoCount}
        end
    end
end

local function clearInventory()
    RemoveAllPedWeapons(PlayerPedId(), true)
    savedWeapons = {}
end

local function restoreWeapons()
    local ped = PlayerPedId()
    for weaponHash, data in pairs(savedWeapons) do
        GiveWeaponToPed(ped, GetHashKey(weaponHash), 0, true, false)
        if data.ammoHash then
            SetPedAmmoByType(ped, GetHashKey(data.ammoHash), data.ammoCount)
        end
    end
end

local function restorePedAndOutfit()
    if currentPedModel then
        local playerId = PlayerId()
        local modelHash = GetHashKey(currentPedModel)
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(100)
        end
        SetPlayerModel(playerId, modelHash)
        SetPedOutfitPreset(PlayerPedId(), currentOutfit, false)
        UpdatePedVariation(PlayerPedId())
        SetModelAsNoLongerNeeded(modelHash)
    end
end

local function spawnVehicle(modelHash, entityType, applyRandomVariation)
    local ped = PlayerPedId()
    local playerId = PlayerId()
    local x, y, z = table.unpack(GetEntityCoords(ped))
    local heading = GetEntityHeading(ped)
    local hash = GetHashKey(modelHash)
    
    RequestModel(hash)
    local timeout = 5000
    while not HasModelLoaded(hash) and timeout > 0 do
        Wait(100)
        timeout = timeout - 100
    end
    
    if not HasModelLoaded(hash) then return end
    
    local spawnX, spawnY, spawnZ = x + 2.0, y + 2.0, z + 10.0
    local foundGround, groundZ = GetGroundZFor_3dCoord(spawnX, spawnY, spawnZ, false)
    spawnZ = foundGround and (groundZ + 1.0) or z
    
    if playerVehicles[playerId] and DoesEntityExist(playerVehicles[playerId]) then
        DeleteEntity(playerVehicles[playerId])
        playerVehicles[playerId] = nil
    end
    
    local entity = entityType == "ped" and 
        CreatePed(hash, spawnX, spawnY, spawnZ, heading, true, false, false) or 
        CreateVehicle(hash, spawnX, spawnY, spawnZ, heading, true, false)
    
    if not DoesEntityExist(entity) then
        SetModelAsNoLongerNeeded(hash)
        return
    end
    
    SetEntityAsMissionEntity(entity, true, true)
    if applyRandomVariation then
        Citizen.InvokeNative(0x283978A15512B2FE, entity, true)
    end
    SetEntityCollision(entity, true, true)
    
    if entityType == "ped" then
        TaskWarpPedIntoVehicle(ped, entity, -1)
    else
        SetPedIntoVehicle(ped, entity, -1)
    end
    
    SetModelAsNoLongerNeeded(hash)
    playerVehicles[playerId] = entity
end

local function createMenu(id, title, subtitle, numberOnScreen, onBack)
    menus[id] = jo.menu.create(id, {title = title, subtitle = subtitle, numberOnScreen = numberOnScreen, onBack = onBack})
end

local function addMenuItem(menuId, title, description, price, child, onClick)
    menus[menuId]:addItem({title = title, description = description, price = price, child = child, onClick = onClick})
end

local function initializeMenu()
    while not jo do Wait(100) end
    if IsPlayerDead(PlayerId()) or not NetworkIsPlayerActive(PlayerId()) then return end

    createMenu('rCoreMenu', "rMenu", "rMenu", 6, function() jo.menu.show(false) end)
    createMenu('weaponsMenu', "rMenu", "rMenu", 8, function() jo.menu.setCurrentMenu('rCoreMenu', true, true) jo.menu.show(true) end)
    createMenu('meleesMenu', "rMenu", "rMenu", 8, function() jo.menu.setCurrentMenu('rCoreMenu', true, true) jo.menu.show(true) end)
    createMenu('miscMenu', "rMenu", "rMenu", 8, function() jo.menu.setCurrentMenu('rCoreMenu', true, true) jo.menu.show(true) end)
    createMenu('spawnsMenu', "rMenu", "rMenu", 8, function() jo.menu.setCurrentMenu('rCoreMenu', true, true) jo.menu.show(true) end)
    createMenu('townsMenu', "rMenu", "Towns", 8, function() jo.menu.setCurrentMenu('spawnsMenu', true, true) jo.menu.show(true) end)
    createMenu('campsMenu', "rMenu", "Camps", 8, function() jo.menu.setCurrentMenu('spawnsMenu', true, true) jo.menu.show(true) end)
    createMenu('landmarksMenu', "rMenu", "Landmarks", 8, function() jo.menu.setCurrentMenu('spawnsMenu', true, true) jo.menu.show(true) end)
    createMenu('outfitsMenu', "rMenu", "rMenu", 8, function() jo.menu.setCurrentMenu('rCoreMenu', true, true) jo.menu.show(true) end)
    createMenu('pedsMenu', "rMenu", "rMenu", 8, function() jo.menu.setCurrentMenu('rCoreMenu', true, true) jo.menu.show(true) end)
    createMenu('vehiclesMenu', "rMenu", "Vehicles", 8, function() jo.menu.setCurrentMenu('rCoreMenu', true, true) jo.menu.show(true) end)
    createMenu('carriagesMenu', "rMenu", "Carriages", 8, function() jo.menu.setCurrentMenu('vehiclesMenu', true, true) jo.menu.show(true) end)
    createMenu('horsesMenu', "rMenu", "Horses", 8, function() jo.menu.setCurrentMenu('vehiclesMenu', true, true) jo.menu.show(true) end)
    createMenu('boatsMenu', "rMenu", "Boats", 8, function() jo.menu.setCurrentMenu('vehiclesMenu', true, true) jo.menu.show(true) end)
    createMenu('storyPedsMenu', "rMenu", "Story Characters", 8, function() jo.menu.setCurrentMenu('pedsMenu', true, true) jo.menu.show(true) end)
    createMenu('animalsMenu', "rMenu", "Animals", 8, function() jo.menu.setCurrentMenu('pedsMenu', true, true) jo.menu.show(true) end)
    createMenu('civiliansMenu', "rMenu", "Civilians", 8, function() jo.menu.setCurrentMenu('pedsMenu', true, true) jo.menu.show(true) end)
    createMenu('gangMembersMenu', "rMenu", "Gang Members", 8, function() jo.menu.setCurrentMenu('pedsMenu', true, true) jo.menu.show(true) end)
    createMenu('lawmenMenu', "rMenu", "Lawmen", 8, function() jo.menu.setCurrentMenu('pedsMenu', true, true) jo.menu.show(true) end)

    for _, weapon in ipairs(Config.Firearms) do
        addMenuItem('weaponsMenu', weapon.title, "Equip this firearm", {money = 10.0}, nil, function()
            local ped = PlayerPedId()
            GiveWeaponToPed(ped, GetHashKey(weapon.hash), 0, true, false)
            if weapon.ammoHash then SetPedAmmoByType(ped, GetHashKey(weapon.ammoHash), weapon.ammoCount) end
            saveWeapons()
        end)
    end

    for _, melee in ipairs(Config.Melees) do
        addMenuItem('meleesMenu', melee.title, "Equip this melee weapon", {money = 5.0}, nil, function()
            local ped = PlayerPedId()
            GiveWeaponToPed(ped, GetHashKey(melee.hash), 0, true, false)
            if melee.ammoHash then SetPedAmmoByType(ped, GetHashKey(melee.ammoHash), melee.ammoCount) end
            saveWeapons()
        end)
    end

    for _, item in ipairs(Config.MiscItems) do
        addMenuItem('miscMenu', item.title, "Equip this item", {money = 3.0}, nil, function()
            local ped = PlayerPedId()
            GiveWeaponToPed(ped, GetHashKey(item.hash), 0, true, false)
            if item.ammoHash then SetPedAmmoByType(ped, GetHashKey(item.ammoHash), item.ammoCount) end
            saveWeapons()
        end)
    end

    for _, town in ipairs(Config.Towns) do
        addMenuItem('townsMenu', town.title, "Teleport to " .. town.title, nil, nil, function()
            local ped = PlayerPedId()
            SetEntityCoords(ped, town.coords.x, town.coords.y, town.coords.z, false, false, false, true)
            respawnCoords = town.coords
        end)
    end

    for _, camp in ipairs(Config.Camps) do
        addMenuItem('campsMenu', camp.title, "Teleport to " .. camp.title, nil, nil, function()
            local ped = PlayerPedId()
            SetEntityCoords(ped, camp.coords.x, camp.coords.y, camp.coords.z, false, false, false, true)
            respawnCoords = camp.coords
        end)
    end

    for _, landmark in ipairs(Config.Landmarks) do
        addMenuItem('landmarksMenu', landmark.title, "Teleport to " .. landmark.title, nil, nil, function()
            local ped = PlayerPedId()
            SetEntityCoords(ped, landmark.coords.x, landmark.coords.y, landmark.coords.z, false, false, false, true)
            respawnCoords = landmark.coords
        end)
    end

    for i = 0, 19 do
        addMenuItem('outfitsMenu', "Outfit " .. i, "Apply outfit preset " .. i, nil, nil, function()
            SetPedOutfitPreset(PlayerPedId(), i, false)
            currentOutfit = i
        end)
    end

    local function addPedChange(menuId, pedData)
        addMenuItem(menuId, pedData.title, "Change to " .. pedData.title, nil, nil, function()
            local playerId = PlayerId()
            local modelHash = GetHashKey(pedData.hash)
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do Wait(100) end
            SetPlayerModel(playerId, modelHash)
            SetPedOutfitPreset(PlayerPedId(), currentOutfit, false)
            UpdatePedVariation(PlayerPedId())
            SetModelAsNoLongerNeeded(modelHash)
            currentPedModel = pedData.hash
        end)
    end

    for _, pedData in ipairs(Config.StoryPeds) do addPedChange('storyPedsMenu', pedData) end
    for _, pedData in ipairs(Config.Animals) do addPedChange('animalsMenu', pedData) end
    for _, pedData in ipairs(Config.Civilians) do addPedChange('civiliansMenu', pedData) end
    for _, pedData in ipairs(Config.GangMembers) do addPedChange('gangMembersMenu', pedData) end
    for _, pedData in ipairs(Config.Lawmen) do addPedChange('lawmenMenu', pedData) end

    for _, horse in ipairs(Config.Horses) do
        addMenuItem('horsesMenu', horse.title, "Spawn a " .. horse.title, nil, nil, function()
            spawnVehicle(horse.hash, "ped", true)
        end)
    end

    for _, carriage in ipairs(Config.Carriages) do
        addMenuItem('carriagesMenu', carriage.title, "Spawn a " .. carriage.title, nil, nil, function()
            spawnVehicle(carriage.hash, "vehicle", true)
        end)
    end

    for _, boat in ipairs(Config.Boats) do
        addMenuItem('boatsMenu', boat.title, "Spawn a " .. boat.title, nil, nil, function()
            spawnVehicle(boat.hash, "vehicle", false)
        end)
    end

    addMenuItem('rCoreMenu', "Weapons", "Browse firearms", nil, "weaponsMenu", function() jo.menu.setCurrentMenu('weaponsMenu', true, true) jo.menu.show(true) end)
    addMenuItem('rCoreMenu', "Melees", "Browse melee weapons", nil, "meleesMenu", function() jo.menu.setCurrentMenu('meleesMenu', true, true) jo.menu.show(true) end)
    addMenuItem('rCoreMenu', "Misc", "Browse utility items", nil, "miscMenu", function() jo.menu.setCurrentMenu('miscMenu', true, true) jo.menu.show(true) end)
    addMenuItem('rCoreMenu', "Spawns", "Teleport locations", nil, "spawnsMenu", function() jo.menu.setCurrentMenu('spawnsMenu', true, true) jo.menu.show(true) end)
    addMenuItem('spawnsMenu', "Towns", "Major settlements", nil, "townsMenu", function() jo.menu.setCurrentMenu('townsMenu', true, true) jo.menu.show(true) end)
    addMenuItem('spawnsMenu', "Camps", "Gang hideouts", nil, "campsMenu", function() jo.menu.setCurrentMenu('campsMenu', true, true) jo.menu.show(true) end)
    addMenuItem('spawnsMenu', "Landmarks", "Points of interest", nil, "landmarksMenu", function() jo.menu.setCurrentMenu('landmarksMenu', true, true) jo.menu.show(true) end)
    addMenuItem('rCoreMenu', "Outfits", "Change your outfit", nil, "outfitsMenu", function() jo.menu.setCurrentMenu('outfitsMenu', true, true) jo.menu.show(true) end)
    addMenuItem('rCoreMenu', "Peds", "Change character model", nil, "pedsMenu", function() jo.menu.setCurrentMenu('pedsMenu', true, true) jo.menu.show(true) end)
    addMenuItem('pedsMenu', "Story Characters", "Main story peds", nil, "storyPedsMenu", function() jo.menu.setCurrentMenu('storyPedsMenu', true, true) jo.menu.show(true) end)
    addMenuItem('pedsMenu', "Animals", "Wildlife peds", nil, "animalsMenu", function() jo.menu.setCurrentMenu('animalsMenu', true, true) jo.menu.show(true) end)
    addMenuItem('pedsMenu', "Civilians", "Townsfolk peds", nil, "civiliansMenu", function() jo.menu.setCurrentMenu('civiliansMenu', true, true) jo.menu.show(true) end)
    addMenuItem('pedsMenu', "Gang Members", "Outlaw peds", nil, "gangMembersMenu", function() jo.menu.setCurrentMenu('gangMembersMenu', true, true) jo.menu.show(true) end)
    addMenuItem('pedsMenu', "Lawmen", "Sheriff and deputy peds", nil, "lawmenMenu", function() jo.menu.setCurrentMenu('lawmenMenu', true, true) jo.menu.show(true) end)
    addMenuItem('rCoreMenu', "Vehicles", "Spawn carriages, horses, or boats", nil, "vehiclesMenu", function() jo.menu.setCurrentMenu('vehiclesMenu', true, true) jo.menu.show(true) end)
    addMenuItem('vehiclesMenu', "Carriages", "Spawn a carriage", nil, "carriagesMenu", function() jo.menu.setCurrentMenu('carriagesMenu', true, true) jo.menu.show(true) end)
    addMenuItem('vehiclesMenu', "Horses", "Spawn a horse", nil, "horsesMenu", function() jo.menu.setCurrentMenu('horsesMenu', true, true) jo.menu.show(true) end)
    addMenuItem('vehiclesMenu', "Boats", "Spawn a boat", nil, "boatsMenu", function() jo.menu.setCurrentMenu('boatsMenu', true, true) jo.menu.show(true) end)
    addMenuItem('rCoreMenu', "Heal", "Restore health", nil, nil, function() SetAttributeCoreValue(PlayerPedId(), 0, 100) end)
    addMenuItem('rCoreMenu', "Clear Inventory", "Remove all weapons", nil, nil, clearInventory)

    for _, menu in pairs(menus) do
        menu:send()
    end
end

AddEventHandler('playerSpawned', initializeMenu)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Citizen.CreateThread(function()
            Wait(1000)
            initializeMenu()
        end)
    end
end)

RegisterCommand("rmenu", function()
    if menus.rCoreMenu then
        jo.menu.setCurrentMenu('rCoreMenu', true, true)
        jo.menu.show(true, true, true)
    end
end, false)

RegisterCommand("dv", function()
    local playerId = PlayerId()
    if playerVehicles[playerId] and DoesEntityExist(playerVehicles[playerId]) then
        DeleteEntity(playerVehicles[playerId])
        playerVehicles[playerId] = nil
    end
end, false)

NetworkSetFriendlyFireOption(true)
SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("PLAYER"))

Citizen.CreateThread(function()
    while true do
        Wait(500)
        local ped = PlayerPedId()
        if IsEntityDead(ped) then
            saveWeapons()
            exports.spawnmanager:setAutoSpawn(false)
            Wait(5000)
            if IsEntityDead(ped) then
                NetworkResurrectLocalPlayer(
                    respawnCoords and respawnCoords.x or -179.22,
                    respawnCoords and respawnCoords.y or 627.72,
                    respawnCoords and respawnCoords.z or 113.09,
                    0.0, 1, false)
                Wait(500)
                restorePedAndOutfit()
                restoreWeapons()
            end
        end
    end
end)

-- map fixes
Citizen.CreateThread(function()
    while true do
        Wait(1000)
        SetMinimapType(0)
        DisplayRadar(true)
    end
end)

-- stamina
Citizen.CreateThread(function()
    Citizen.InvokeNative("0xCB5D11F9508A928D", 1, a2, a3, -1845241476, 1084182731, 10, 752097756)
end)

-- health
Citizen.CreateThread(function()
    while true do
        Wait(1000)
        SetMinimapHideFow(true)
        Citizen.InvokeNative("0xCB5D11F9508A928D", 1, a2, a3, GetHashKey("UPGRADE_STAMINA_TANK_1"), 1084182731, 10, 752097756)
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for playerId, vehicle in pairs(playerVehicles) do
            if DoesEntityExist(vehicle) then
                DeleteEntity(vehicle)
                playerVehicles[playerId] = nil
            end
        end
    end
end)
