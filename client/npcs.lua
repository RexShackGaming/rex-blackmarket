
local RSGCore = exports['rsg-core']:GetCoreObject()
local ox_target = exports.ox_target
local spawnedPeds = {}



local function OpenBlackMarketMenu()
    lib.registerContext(
        {
            id = 'main_menu',
            title = locale('cl_lang_2'),
            position = 'top-right',
            options = {
                {
                    title = locale('cl_lang_3'),
                    icon = 'fa-solid fa-hand-sparkles',
                    event = 'rex-blackmarket:client:washbloodmoney',
                    arrow = true
                },
                {
                    title = locale('cl_lang_4'),
                    icon = 'fa-solid fa-shop',
                    serverEvent = 'rex-blackmarket:server:openShop',
                    arrow = true
                },
            }
        }
    )
    lib.showContext('main_menu')
end


local function NearPed(npcmodel, npccoords)
    RequestModel(npcmodel)
    while not HasModelLoaded(npcmodel) do
        Wait(50)
    end
    local spawnedPed = CreatePed(npcmodel, npccoords.x, npccoords.y, npccoords.z - 1.0, npccoords.w, false, false, 0, 0)
    SetEntityAlpha(spawnedPed, 0, false)
    SetRandomOutfitVariation(spawnedPed, true)
    SetEntityCanBeDamaged(spawnedPed, false)
    SetEntityInvincible(spawnedPed, true)
    FreezeEntityPosition(spawnedPed, true)
    SetBlockingOfNonTemporaryEvents(spawnedPed, true)
    SetPedCanBeTargetted(spawnedPed, false)
    SetPedFleeAttributes(spawnedPed, 0, false)
    if Config.FadeIn then
        for i = 0, 255, 51 do
            Wait(50)
            SetEntityAlpha(spawnedPed, i, false)
        end
    end
    ox_target:addLocalEntity(spawnedPed, {
        {
            name = 'npc_blackmarket',
            icon = 'far fa-eye',
            label = locale('cl_lang_1'),
            onSelect = function()
                OpenBlackMarketMenu()
            end,
            distance = 3.0
        }
    })
    return spawnedPed
end

CreateThread(function()
    while true do
        local isNearAnyPed = false
        for k,v in pairs(Config.BlackmarketLocations) do
            local playerCoords = GetEntityCoords(cache.ped)
            local distance = #(playerCoords - v.npccoords.xyz)

            if distance < Config.DistanceSpawn and not spawnedPeds[k] then
                local spawnedPed = NearPed(v.npcmodel, v.npccoords)
                spawnedPeds[k] = { spawnedPed = spawnedPed }
                isNearAnyPed = true
            elseif distance < Config.DistanceSpawn and spawnedPeds[k] then
                isNearAnyPed = true
            end
            
            if distance >= Config.DistanceSpawn and spawnedPeds[k] then
                if Config.FadeIn then
                    for i = 255, 0, -51 do
                        Wait(50)
                        SetEntityAlpha(spawnedPeds[k].spawnedPed, i, false)
                    end
                end
                DeletePed(spawnedPeds[k].spawnedPed)
                spawnedPeds[k] = nil
            end
        end

        if not isNearAnyPed then
            Wait(1000) 
        else
            Wait(0) 
        end
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for k,v in pairs(spawnedPeds) do
        if spawnedPeds[k] and spawnedPeds[k].spawnedPed then
            DeletePed(spawnedPeds[k].spawnedPed)
        end
    end
end)
