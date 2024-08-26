QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('ronakks-shop:deductMoney', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.RemoveMoney('cash', amount)
    else
        print("Error: Player not found when deducting money.")
    end
end)

RegisterNetEvent('ronakks-shop:giveItem', function(itemModel, quantity)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.AddItem(itemModel, quantity)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemModel], 'add', quantity)
    else
        print("Error: Player not found when giving item.")
    end
end)
