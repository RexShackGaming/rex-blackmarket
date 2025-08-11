local RSGCore = exports['rsg-core']:GetCoreObject()

RSGCore.Functions.CreateCallback('rex-blackmarket:server:bloodmoneycallback', function(source, cb)
    local Player = RSGCore.Functions.GetPlayer(source)
    cb(Player and Player.PlayerData.money['bloodmoney'] or 0)
end)

RSGCore.Functions.CreateCallback('rex-blackmarket:server:getoutlawstatus', function(source, cb)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return cb(0) end
    MySQL.query('SELECT outlawstatus FROM players WHERE citizenid = ? LIMIT 1', { Player.PlayerData.citizenid }, function(result)
        cb(result[1] and result[1].outlawstatus or 0)
    end)
end)

RegisterNetEvent('rex-blackmarket:server:washmoney', function(amount, outlawstatus)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    amount = tonumber(amount)
    outlawstatus = tonumber(outlawstatus) or 0
    if not amount or amount <= 0 then return end

    local currentBlood = Player.PlayerData.money['bloodmoney'] or 0
    if currentBlood < amount then return end

    Player.Functions.RemoveMoney('bloodmoney', amount)
    Player.Functions.AddMoney('cash', amount)

    local newStatus = outlawstatus + Config.OutLawIncrease
    MySQL.update('UPDATE players SET outlawstatus = ? WHERE citizenid = ?', { newStatus, Player.PlayerData.citizenid })
end)

CreateThread(function()
    exports['rsg-inventory']:CreateShop({
        name = 'blackmarket',
        label = 'Blackmarket Shop',
        slots = #Config.BlackmarketShopItems,
        items = Config.BlackmarketShopItems,
        persistentStock = Config.PersistStock,
    })
end)

RegisterNetEvent('rex-blackmarket:server:openShop', function()
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.type == 'leo' then return end
    exports['rsg-inventory']:OpenShop(source, 'blackmarket')
end)