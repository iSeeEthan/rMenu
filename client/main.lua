ClearWeatherTypePersist()
local playerVehicles = {}

Citizen.CreateThread(function()
    while not jo do
        Wait(100)
    end

    -- menus def
    local mainMenu = jo.menu.create('rCoreMenu', {
        title = "rMenu",
        subtitle = "rMenu",
        numberOnScreen = 6,
        onEnter = function(currentData) end,
        onBack = function(currentData) jo.menu.show(false) end,
        onExit = function(currentData) end
    })

    local weaponsMenu = jo.menu.create('weaponsMenu', {
        title = "rMenu",
        subtitle = "rMenu",
        numberOnScreen = 8,
        onEnter = function(currentData) end,
        onBack = function(currentData) jo.menu.setCurrentMenu('rCoreMenu', true, true) jo.menu.show(true) end,
        onExit = function(currentData) end
    })

    local meleesMenu = jo.menu.create('meleesMenu', {
        title = "rMenu",
        subtitle = "rMenu",
        numberOnScreen = 8,
        onEnter = function(currentData) end,
        onBack = function(currentData) jo.menu.setCurrentMenu('rCoreMenu', true, true) jo.menu.show(true) end,
        onExit = function(currentData) end
    })

    local miscMenu = jo.menu.create('miscMenu', {
        title = "rMenu",
        subtitle = "rMenu",
        numberOnScreen = 8,
        onEnter = function(currentData) end,
        onBack = function(currentData) jo.menu.setCurrentMenu('rCoreMenu', true, true) jo.menu.show(true) end,
        onExit = function(currentData) end
    })

    local spawnsMenu = jo.menu.create('spawnsMenu', {
        title = "rMenu",
        subtitle = "rMenu",
        numberOnScreen = 8,
        onEnter = function(currentData) end,
        onBack = function(currentData) jo.menu.setCurrentMenu('rCoreMenu', true, true) jo.menu.show(true) end,
        onExit = function(currentData) end
    })

    local townsMenu = jo.menu.create('townsMenu', {
        title = "rMenu",
        subtitle = "Towns",
        numberOnScreen = 8,
        onEnter = function(currentData) end,
        onBack = function(currentData) jo.menu.setCurrentMenu('spawnsMenu', true, true) jo.menu.show(true) end,
        onExit = function(currentData) end
    })

    local campsMenu = jo.menu.create('campsMenu', {
        title = "rMenu",
        subtitle = "Camps",
        numberOnScreen = 8,
        onEnter = function(currentData) end,
        onBack = function(currentData) jo.menu.setCurrentMenu('spawnsMenu', true, true) jo.menu.show(true) end,
        onExit = function(currentData) end
    })

    local landmarksMenu = jo.menu.create('landmarksMenu', {
        title = "rMenu",
        subtitle = "Landmarks",
        numberOnScreen = 8,
        onEnter = function(currentData) end,
        onBack = function(currentData) jo.menu.setCurrentMenu('spawnsMenu', true, true) jo.menu.show(true) end,
        onExit = function(currentData) end
    })

    local outfitsMenu = jo.menu.create('outfitsMenu', {
        title = "rMenu",
        subtitle = "rMenu",
        numberOnScreen = 8,
        onEnter = function(currentData) end,
        onBack = function(currentData) jo.menu.setCurrentMenu('rCoreMenu', true, true) jo.menu.show(true) end,
        onExit = function(currentData) end
    })

    local pedsMenu = jo.menu.create('pedsMenu', {
        title = "rMenu",
        subtitle = "rMenu",
        numberOnScreen = 8,
        onEnter = function(currentData) end,
        onBack = function(currentData) jo.menu.setCurrentMenu('rCoreMenu', true, true) jo.menu.show(true) end,
        onExit = function(currentData) end
    })

    local vehiclesMenu = jo.menu.create('vehiclesMenu', {
        title = "rMenu",
        subtitle = "Vehicles",
        numberOnScreen = 8,
        onEnter = function(currentData) end,
        onBack = function(currentData) jo.menu.setCurrentMenu('rCoreMenu', true, true) jo.menu.show(true) end,
        onExit = function(currentData) end
    })

    local carriagesMenu = jo.menu.create('carriagesMenu', {
        title = "rMenu",
        subtitle = "Carriages",
        numberOnScreen = 8,
        onEnter = function(currentData) end,
        onBack = function(currentData) jo.menu.setCurrentMenu('vehiclesMenu', true, true) jo.menu.show(true) end,
        onExit = function(currentData) end
    })

    local horsesMenu = jo.menu.create('horsesMenu', {
        title = "rMenu",
        subtitle = "Horses",
        numberOnScreen = 8,
        onEnter = function(currentData) end,
        onBack = function(currentData) jo.menu.setCurrentMenu('vehiclesMenu', true, true) jo.menu.show(true) end,
        onExit = function(currentData) end
    })

    local boatsMenu = jo.menu.create('boatsMenu', {
        title = "rMenu",
        subtitle = "Boats",
        numberOnScreen = 8,
        onEnter = function(currentData) end,
        onBack = function(currentData) jo.menu.setCurrentMenu('vehiclesMenu', true, true) jo.menu.show(true) end,
        onExit = function(currentData) end
    })

    -- vars
    local savedWeapons = {}
    local respawnCoords = nil
    local currentPedModel = nil
    local currentOutfit = 0

    -- functions
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

    local function spawnVehicle(modelHash, applyRandomVariation)
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
        
        if not HasModelLoaded(hash) then
            return nil
        end
        
        local spawnX, spawnY, spawnZ = x + 2.0, y + 2.0, z + 10.0
        local foundGround, groundZ = GetGroundZFor_3dCoord(spawnX, spawnY, spawnZ, false)
        if foundGround then
            spawnZ = groundZ + 1.0
        else
            spawnZ = z
        end
        
        -- delete existing player vehicle/horse if it exists
        if playerVehicles[playerId] and DoesEntityExist(playerVehicles[playerId]) then
            DeleteEntity(playerVehicles[playerId])
            playerVehicles[playerId] = nil
        end
        
        local horse = CreatePed(hash, spawnX, spawnY, spawnZ, heading, true, false, false)
        if not DoesEntityExist(horse) then
            SetModelAsNoLongerNeeded(hash)
            return nil
        end
        
        SetEntityAsMissionEntity(horse, true, true)
        

        -- this needs to be here so horse isn't invisible
        if applyRandomVariation then
            Citizen.InvokeNative(0x283978A15512B2FE, horse, true)
        end
        
        SetEntityCollision(horse, true, true)
        TaskWarpPedIntoVehicle(ped, horse, -1)
        SetModelAsNoLongerNeeded(hash)
        
        -- set as player horse 
        playerVehicles[playerId] = horse
        
        return horse
    end

    -- populate the menus
    for _, weapon in ipairs(Config.Firearms) do
        weaponsMenu:addItem({
            title = weapon.title,
            description = "Equip this firearm",
            price = {money = 10.0},
            onClick = function(currentData)
                local ped = PlayerPedId()
                GiveWeaponToPed(ped, GetHashKey(weapon.hash), 0, true, false)
                if weapon.ammoHash then
                    SetPedAmmoByType(ped, GetHashKey(weapon.ammoHash), weapon.ammoCount)
                end
                saveWeapons()
            end
        })
    end

    for _, melee in ipairs(Config.Melees) do
        meleesMenu:addItem({
            title = melee.title,
            description = "Equip this melee weapon",
            price = {money = 5.0},
            onClick = function(currentData)
                local ped = PlayerPedId()
                GiveWeaponToPed(ped, GetHashKey(melee.hash), 0, true, false)
                if melee.ammoHash then
                    SetPedAmmoByType(ped, GetHashKey(melee.ammoHash), melee.ammoCount)
                end
                saveWeapons()
            end
        })
    end

    for _, item in ipairs(Config.MiscItems) do
        miscMenu:addItem({
            title = item.title,
            description = "Equip this item",
            price = {money = 3.0},
            onClick = function(currentData)
                local ped = PlayerPedId()
                GiveWeaponToPed(ped, GetHashKey(item.hash), 0, true, false)
                if item.ammoHash then
                    SetPedAmmoByType(ped, GetHashKey(item.ammoHash), item.ammoCount)
                end
                saveWeapons()
            end
        })
    end

    for _, town in ipairs(Config.Towns) do
        townsMenu:addItem({
            title = town.title,
            description = "Teleport to " .. town.title,
            onClick = function(currentData)
                local ped = PlayerPedId()
                SetEntityCoords(ped, town.coords.x, town.coords.y, town.coords.z, false, false, false, true)
                respawnCoords = town.coords
            end
        })
    end

    for _, camp in ipairs(Config.Camps) do
        campsMenu:addItem({
            title = camp.title,
            description = "Teleport to " .. camp.title,
            onClick = function(currentData)
                local ped = PlayerPedId()
                SetEntityCoords(ped, camp.coords.x, camp.coords.y, camp.coords.z, false, false, false, true)
                respawnCoords = camp.coords
            end
        })
    end

    for _, landmark in ipairs(Config.Landmarks) do
        landmarksMenu:addItem({
            title = landmark.title,
            description = "Teleport to " .. landmark.title,
            onClick = function(currentData)
                local ped = PlayerPedId()
                SetEntityCoords(ped, landmark.coords.x, landmark.coords.y, landmark.coords.z, false, false, false, true)
                respawnCoords = landmark.coords
            end
        })
    end

    for i = 0, 9 do
        outfitsMenu:addItem({
            title = "Outfit " .. i,
            description = "Apply outfit preset " .. i,
            onClick = function(currentData)
                local ped = PlayerPedId()
                SetPedOutfitPreset(ped, i, false)
                currentOutfit = i
            end
        })
    end

    for _, pedData in ipairs(Config.StoryPeds) do
        pedsMenu:addItem({
            title = pedData.title,
            description = "Change to " .. pedData.title,
            onClick = function(currentData)
                local playerId = PlayerId()
                local modelHash = GetHashKey(pedData.hash)
                RequestModel(modelHash)
                while not HasModelLoaded(modelHash) do
                    Wait(100)
                end
                SetPlayerModel(playerId, modelHash)
                SetPedOutfitPreset(PlayerPedId(), currentOutfit, false)
                UpdatePedVariation(PlayerPedId())
                SetModelAsNoLongerNeeded(modelHash)
                currentPedModel = pedData.hash
            end
        })
    end

    for _, carriage in ipairs(Config.Carriages) do
        carriagesMenu:addItem({
            title = carriage.title,
            description = "Spawn a " .. carriage.title,
            onClick = function(currentData)
                spawnVehicle(carriage.hash, true)
            end
        })
    end

    for _, horse in ipairs(Config.Horses) do
        horsesMenu:addItem({
            title = horse.title,
            description = "Spawn a " .. horse.title,
            onClick = function(currentData)
                spawnVehicle(horse.hash, true)
            end
        })
    end

    for _, boat in ipairs(Config.Boats) do
        boatsMenu:addItem({
            title = boat.title,
            description = "Spawn a " .. boat.title,
            onClick = function(currentData)
                spawnVehicle(boat.hash, false)
            end
        })
    end

    -- Main Menu Items
    mainMenu:addItem({
        title = "Weapons",
        description = "Browse firearms",
        child = "weaponsMenu",
        onClick = function(currentData) jo.menu.setCurrentMenu('weaponsMenu', true, true) jo.menu.show(true) end
    })

    mainMenu:addItem({
        title = "Melees",
        description = "Browse melee weapons",
        child = "meleesMenu",
        onClick = function(currentData) jo.menu.setCurrentMenu('meleesMenu', true, true) jo.menu.show(true) end
    })

    mainMenu:addItem({
        title = "Misc",
        description = "Browse utility items",
        child = "miscMenu",
        onClick = function(currentData) jo.menu.setCurrentMenu('miscMenu', true, true) jo.menu.show(true) end
    })

    mainMenu:addItem({
        title = "Spawns",
        description = "Teleport locations",
        child = "spawnsMenu",
        onClick = function(currentData) jo.menu.setCurrentMenu('spawnsMenu', true, true) jo.menu.show(true) end
    })

    spawnsMenu:addItem({
        title = "Towns",
        description = "Major settlements",
        child = "townsMenu",
        onClick = function(currentData) jo.menu.setCurrentMenu('townsMenu', true, true) jo.menu.show(true) end
    })

    spawnsMenu:addItem({
        title = "Camps",
        description = "Gang hideouts",
        child = "campsMenu",
        onClick = function(currentData) jo.menu.setCurrentMenu('campsMenu', true, true) jo.menu.show(true) end
    })

    spawnsMenu:addItem({
        title = "Landmarks",
        description = "Points of interest",
        child = "landmarksMenu",
        onClick = function(currentData) jo.menu.setCurrentMenu('landmarksMenu', true, true) jo.menu.show(true) end
    })

    mainMenu:addItem({
        title = "Outfits",
        description = "Change your outfit",
        child = "outfitsMenu",
        onClick = function(currentData) jo.menu.setCurrentMenu('outfitsMenu', true, true) jo.menu.show(true) end
    })

    mainMenu:addItem({
        title = "Peds",
        description = "Change character model",
        child = "pedsMenu",
        onClick = function(currentData) jo.menu.setCurrentMenu('pedsMenu', true, true) jo.menu.show(true) end
    })

    mainMenu:addItem({
        title = "Vehicles",
        description = "Spawn carriages, horses, or boats",
        child = "vehiclesMenu",
        onClick = function(currentData) jo.menu.setCurrentMenu('vehiclesMenu', true, true) jo.menu.show(true) end
    })

    vehiclesMenu:addItem({
        title = "Carriages",
        description = "Spawn a carriage",
        child = "carriagesMenu",
        onClick = function(currentData) jo.menu.setCurrentMenu('carriagesMenu', true, true) jo.menu.show(true) end
    })

    vehiclesMenu:addItem({
        title = "Horses",
        description = "Spawn a horse",
        child = "horsesMenu",
        onClick = function(currentData) jo.menu.setCurrentMenu('horsesMenu', true, true) jo.menu.show(true) end
    })

    vehiclesMenu:addItem({
        title = "Boats",
        description = "Spawn a boat",
        child = "boatsMenu",
        onClick = function(currentData) jo.menu.setCurrentMenu('boatsMenu', true, true) jo.menu.show(true) end
    })

    mainMenu:addItem({
        title = "Heal",
        description = "Restore health",
        onClick = function(currentData)
            local ped = PlayerPedId()
            SetAttributeCoreValue(ped, 0, 100)
        end
    })

    mainMenu:addItem({
        title = "Clear Inventory",
        description = "Remove all weapons",
        onClick = function(currentData)
            local ped = PlayerPedId()
            RemoveAllPedWeapons(ped, true)
            savedWeapons = {}
        end
    })

    -- send the menus
    mainMenu:send()
    weaponsMenu:send()
    meleesMenu:send()
    miscMenu:send()
    spawnsMenu:send()
    townsMenu:send()
    campsMenu:send()
    landmarksMenu:send()
    outfitsMenu:send()
    pedsMenu:send()
    vehiclesMenu:send()
    carriagesMenu:send()
    horsesMenu:send()
    boatsMenu:send()

    -- command
    RegisterCommand("rmenu", function()
        jo.menu.setCurrentMenu('rCoreMenu', true, true)
        jo.menu.show(true, true, true)
    end, false)

    -- network stuff
    NetworkSetFriendlyFireOption(true)
    SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("PLAYER"))

    -- respawn thread
    Citizen.CreateThread(function()
        while true do
            Wait(100)
            local ped = PlayerPedId()
            if IsEntityDead(ped) then
                saveWeapons()
                exports.spawnmanager:setAutoSpawn(false)
                Wait(5000)
                ped = PlayerPedId()
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
end)

Citizen.CreateThread(function()
    while true do
        Wait(100)
        SetMinimapType(0)
        DisplayRadar(true)
    end
end)

Citizen.CreateThread(function()
    Citizen.InvokeNative("0xCB5D11F9508A928D", 1, a2, a3, -1845241476, 1084182731, 10, 752097756)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
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