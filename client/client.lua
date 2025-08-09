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
            SetBlipSprite(BlackmarketBlip, joaat(Config.Blip.blipSprite), true)
            SetBlipScale(BlackmarketBlip, Config.Blip.blipScale)
            Citizen.InvokeNative(0x9CB1A1623062F402, BlackmarketBlip, v.name)
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
    RSGCore.Functions.TriggerCallback('rex-blackmarket:server:bloodmoneycallback', function(bloodmoney)
        LocalPlayer.state:set("inv_busy", true, true)
        local input = lib.inputDialog(locale('cl_lang_5')..Config.MaxWash..')', {
            { 
                label = locale('cl_lang_6'),
                description = locale('cl_lang_7') ..bloodmoney,
                type = 'input',
                icon = 'fa-solid fa-hashtag',
                required = true
            },
        })
        if not input then return end
        local washmoney = tonumber(input[1])
        if washmoney <= Config.MaxWash then
            if bloodmoney >= washmoney then
                if lib.progressBar({
                    duration = Config.WashTime * washmoney,
                    position = 'bottom',
                    useWhileDead = false,
                    canCancel = false,
                    disableControl = true,
                    disable = {
                        move = true,
                        mouse = true,
                    },
                    anim = {
                        dict = 'mech_inventory@crafting@fallbacks',
                        clip = 'full_craft_and_stow',
                        flag = 27,
                    },
                    label = locale('cl_lang_8'),
                }) then
                    RSGCore.Functions.TriggerCallback('rex-blackmarket:server:getoutlawstatus', function(result)
                        if Config.LawAlertActive then
                            local random = math.random(100)
                            if random <= Config.LawAlertChance then
                                local coords = GetEntityCoords(cache.ped)
                                TriggerEvent('rsg-lawman:client:lawmanAlert', coords, locale('cl_lang_11'))
                            end
                        end
                        outlawstatus = result[1].outlawstatus
                        TriggerServerEvent('rex-blackmarket:server:washmoney', washmoney, outlawstatus)
                    end)
                end
            else
                lib.notify({ title = locale('cl_lang_9'), type = 'error', duration = 7000 })
            end
        else
            lib.notify({ title = locale('cl_lang_10')..Config.MaxWash, type = 'error', duration = 7000 })
        end
        LocalPlayer.state:set("inv_busy", false, true)
    end)
end)
