local RSGCore = exports['rsg-core']:GetCoreObject()
local ox_target = exports.ox_target
local SpawnedBlackmarketBlips, pooledPeds = {}, {}

CreateThread(function()
    for _, location in pairs(Config.BlackmarketLocations) do
        if location.showblip then
            local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, location.coords)
            SetBlipSprite(blip, joaat(Config.Blip.blipSprite), true)
            SetBlipScale(blip, Config.Blip.blipScale)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, location.name)
            SpawnedBlackmarketBlips[#SpawnedBlackmarketBlips + 1] = blip
        end
    end
end)

RegisterNetEvent('rex-blackmarket:client:washbloodmoney', function()
    LocalPlayer.state:set("inv_busy", true, true)
    RSGCore.Functions.TriggerCallback('rex-blackmarket:server:bloodmoneycallback', function(bloodmoney)
        local input = lib.inputDialog(locale('cl_lang_5', Config.MaxWash), {
            {label = locale('cl_lang_6'), description = locale('cl_lang_7', bloodmoney), type = 'input', icon = 'fa-solid fa-hashtag', required = true},
        })
        if not input then return LocalPlayer.state:set("inv_busy", false, true) end
        local washmoney = tonumber(input[1])
        if not washmoney or washmoney <= 0 or washmoney > Config.MaxWash then
            lib.notify({ title = locale('cl_lang_10', Config.MaxWash), type = 'error', duration = 7000 })
            return LocalPlayer.state:set("inv_busy", false, true)
        end
        if bloodmoney < washmoney then
            lib.notify({ title = locale('cl_lang_9'), type = 'error', duration = 7000 })
            return LocalPlayer.state:set("inv_busy", false, true)
        end
        local success = lib.progressBar({
            duration = Config.WashTime * washmoney, position = 'bottom',
            useWhileDead = false, canCancel = false, disableControl = true,
            disable = { move = true, mouse = true },
            anim = { dict = 'mech_inventory@crafting@fallbacks', clip = 'full_craft_and_stow', flag = 27 },
            label = locale('cl_lang_8'),
        })
        if success then
            RSGCore.Functions.TriggerCallback('rex-blackmarket:server:getoutlawstatus', function(result)
                local outlawstatus = result and result[1] and result[1].outlawstatus or 0
                if Config.LawAlertActive and math.random(100) <= Config.LawAlertChance then
                    TriggerEvent('rsg-lawman:client:lawmanAlert', GetEntityCoords(cache.ped), locale('cl_lang_11'))
                end
                TriggerServerEvent('rex-blackmarket:server:washmoney', washmoney, outlawstatus)
            end)
        end
        LocalPlayer.state:set("inv_busy", false, true)
    end)
end)

local function OpenBlackMarketMenu()
    lib.registerContext({
        id = 'main_menu', title = locale('cl_lang_2'), position = 'top-right',
        options = {
            { title = locale('cl_lang_3'), icon = 'fa-solid fa-hand-sparkles', event = 'rex-blackmarket:client:washbloodmoney', arrow = true },
            { title = locale('cl_lang_4'), icon = 'fa-solid fa-shop', serverEvent = 'rex-blackmarket:server:openShop', arrow = true },
        }
    })
    lib.showContext('main_menu')
end

local function CreatePooledPed(npcmodel, coords)
    RequestModel(npcmodel)
    while not HasModelLoaded(npcmodel) do Wait(50) end
    local ped = CreatePed(npcmodel, coords.x, coords.y, coords.z - 1.0, coords.w, false, false, 0, 0)
    SetEntityAlpha(ped, 0, false)
    SetRandomOutfitVariation(ped, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanBeTargetted(ped, false)
    SetPedFleeAttributes(ped, 0, false)
    ox_target:addLocalEntity(ped, {
        { name = 'npc_blackmarket', icon = 'far fa-eye', label = locale('cl_lang_1'), onSelect = OpenBlackMarketMenu, distance = 3.0 }
    })
    return ped
end

CreateThread(function()
    for k, v in pairs(Config.BlackmarketLocations) do
        pooledPeds[k] = { ped = CreatePooledPed(v.npcmodel, v.npccoords), coords = v.npccoords, visible = false }
    end
    while true do
        local playerCoords = GetEntityCoords(cache.ped)
        local anyVisible = false
        for _, data in pairs(pooledPeds) do
            local dist = #(playerCoords - data.coords.xyz)
            local shouldShow = dist < Config.DistanceSpawn
            if shouldShow and not data.visible then
                if Config.FadeIn then for i = 0, 255, 51 do Wait(10) SetEntityAlpha(data.ped, i, false) end else SetEntityAlpha(data.ped, 255, false) end
                data.visible = true
            elseif not shouldShow and data.visible then
                if Config.FadeIn then for i = 255, 0, -51 do Wait(10) SetEntityAlpha(data.ped, i, false) end else SetEntityAlpha(data.ped, 0, false) end
                data.visible = false
            end
            if data.visible then anyVisible = true end
        end
        Wait(anyVisible and 0 or 1000)
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, data in pairs(pooledPeds) do if data.ped then DeletePed(data.ped) end end
end)