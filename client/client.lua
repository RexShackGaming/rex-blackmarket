local RSGCore = exports['rsg-core']:GetCoreObject()
local SpawnedBlackmarketBilps = {}
lib.locale()

-----------------------------------------------------------------
-- blips
-----------------------------------------------------------------
Citizen.CreateThread(function()
    for _,v in pairs(Config.BlackmarketLocations) do
        if v.showblip == true then
            local BlackmarketBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.coords)
            SetBlipSprite(BlackmarketBlip, joaat(v.blipsprite), true)
            SetBlipScale(BlackmarketBlip, v.blipscale)
            Citizen.InvokeNative(0x9CB1A1623062F402, BlackmarketBlip, v.blipname)
            table.insert(SpawnedBlackmarketBilps, BlackmarketBlip)
        end
    end
end)

-- blackmarket npc main menu
RegisterNetEvent('rex-blackmarket:client:mainmenu', function()
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
end)

-- wash bloodmoney
RegisterNetEvent('rex-blackmarket:client:washbloodmoney', function()
    LocalPlayer.state:set("inv_busy", true, true)
    RSGCore.Functions.TriggerCallback('rex-blackmarket:server:bloodmoneycallback', function(bloodmoney)
        local input = lib.inputDialog(locale('cl_lang_5')..Config.MaxWash..')', {
            {label = locale('cl_lang_6'), description = locale('cl_lang_7')..bloodmoney, type = 'input', icon = 'fa-solid fa-hashtag', required = true},
        })
        if not input then return LocalPlayer.state:set("inv_busy", false, true) end
        local washmoney = tonumber(input[1])
        if not washmoney or washmoney <= 0 or washmoney > Config.MaxWash then
            lib.notify({ title = locale('cl_lang_10')..Config.MaxWash, type = 'error', duration = 7000 })
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
