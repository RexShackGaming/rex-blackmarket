local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

---------------------------------------------
-- bloodmoney callback
---------------------------------------------
RSGCore.Functions.CreateCallback('rex-blackmarket:server:bloodmoneycallback', function(source, cb)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local playerbloodmoney = Player.PlayerData.money['bloodmoney']
    if playerbloodmoney then
        cb(playerbloodmoney)
    else
        cb(nil)
    end
end)

---------------------------------
-- get outlaw status
---------------------------------
RSGCore.Functions.CreateCallback('rex-blackmarket:server:getoutlawstatus', function(source, cb)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if Player ~= nil then
        MySQL.query('SELECT outlawstatus FROM players WHERE citizenid = ?', {Player.PlayerData.citizenid}, function(result)
            if result[1] then
                cb(result)
            else
                cb(nil)
            end
        end)
    end
end)

---------------------------------------------
-- wash bloodmoney
---------------------------------------------
RegisterNetEvent('rex-blackmarket:server:washmoney', function(amount, outlawstatus)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.RemoveMoney('bloodmoney', amount)
    Player.Functions.AddMoney('cash', amount)
    -- udpate outlaw status
    local newoutlawstatus = (outlawstatus + Config.OutLawIncrease)
    MySQL.update('UPDATE players SET outlawstatus = ? WHERE citizenid = ?', { newoutlawstatus, Player.PlayerData.citizenid })
end)

--------------------------------------
-- register shop
--------------------------------------
CreateThread(function() 
    exports['rsg-inventory']:CreateShop({
        name = 'blackmarket',
        label = 'Blackmarket Shop',
        slots = #Config.BlackmarketShopItems,
        items = Config.BlackmarketShopItems,
        persistentStock = Config.PersistStock,
    })
end)

--------------------------------------
-- open shop
--------------------------------------
RegisterNetEvent('rex-blackmarket:server:openShop', function() 
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local playerjobtype = Player.PlayerData.job.type
    if playerjobtype == 'leo' then return end
    exports['rsg-inventory']:OpenShop(src, 'blackmarket')
end)