-- Ensure QBCore is initialized
QBCore = exports['qb-core']:GetCoreObject()

local function spawnPed(pedConfig)
    RequestModel(GetHashKey(pedConfig.model))
    while not HasModelLoaded(GetHashKey(pedConfig.model)) do
        Wait(500)
    end

    local ped = CreatePed(4, GetHashKey(pedConfig.model), pedConfig.coords.x, pedConfig.coords.y, pedConfig.coords.z, pedConfig.coords.w, false, true)
    SetEntityHeading(ped, pedConfig.coords.w)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, pedConfig.scenario, 0, true)

    return ped
end

CreateThread(function()
    for _, pedConfig in pairs(Config.Peds) do
        local ped = spawnPed(pedConfig)

        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                {
                    type = "client",
                    event = "ronakks-shop:openMenu",
                    icon = "fas fa-shopping-cart",
                    label = "Want to purchase",
                    pedConfig = pedConfig
                },
            },
            distance = 2.5
        })
    end
end)

-- Open the main shop menu
RegisterNetEvent('ronakks-shop:openMenu', function(data)
    local pedConfig = data.pedConfig

    local menuOptions = {
        {
            header = "Welcome to " .. pedConfig.shopName,  -- Display shop name
            txt = "",
            isMenuHeader = true -- Ensures this is a header and not clickable
        }
    }

    for _, item in pairs(pedConfig.items) do
        table.insert(menuOptions, {
            header = item.name,
            txt = item.description .. " - $" .. item.cost,
            params = {
                event = 'ronakks-shop:selectQuantity',
                args = {
                    item = item,
                    pedConfig = pedConfig
                }
            }
        })
    end

    table.insert(menuOptions, {
        header = "Close",
        txt = "Close the menu",
        params = {
            event = "qb-menu:closeMenu" -- Corrected event for closing the menu
        }
    })

    exports['qb-menu']:openMenu(menuOptions)
end)

-- Open quantity selection submenu
RegisterNetEvent('ronakks-shop:selectQuantity', function(data)
    local item = data.item
    local pedConfig = data.pedConfig

    local quantityOptions = {
        {qty = 1, label = "1x"},
        {qty = 5, label = "5x"},
        {qty = 10, label = "10x"},
        {qty = 25, label = "25x"},
        {qty = 50, label = "50x"}
    }

    local menuOptions = {
        {
            header = "Select Quantity Of " .. item.name,
            txt = "",
            isMenuHeader = true -- Ensures this is a header and not clickable
        }
    }

    for _, option in ipairs(quantityOptions) do
        local totalCost = item.cost * option.qty
        table.insert(menuOptions, {
            header = option.label .. " - " .. item.name,
            txt = item.description .. " - Total: $" .. totalCost,
            params = {
                event = 'ronakks-shop:purchaseItem',
                args = {
                    item = item,
                    quantity = option.qty,
                    pedConfig = pedConfig
                }
            }
        })
    end

    table.insert(menuOptions, {
        header = "Back",
        txt = "Go back to the item menu",
        params = {
            event = 'ronakks-shop:openMenu',
            args = {
                pedConfig = pedConfig
            }
        }
    })

    exports['qb-menu']:openMenu(menuOptions)
end)

-- Handle item purchase
RegisterNetEvent('ronakks-shop:purchaseItem', function(data)
    local player = QBCore.Functions.GetPlayerData()
    local item = data.item
    local quantity = data.quantity
    local pedConfig = data.pedConfig
    local totalCost = item.cost * quantity

    if player.money.cash >= totalCost then
        -- Deduct money
        TriggerServerEvent('ronakks-shop:deductMoney', totalCost)

        -- Play animation for the ped
        local ped = GetClosestPed(pedConfig.coords.x, pedConfig.coords.y, pedConfig.coords.z)
        local animDict = "mp_common"
        local animName = "givetake1_a"
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(100)
        end
        TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, 2000, 49, 0, false, false, false)

        -- Play animation for the player
        animDict = "mp_common"
        animName = "givetake1_b"
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(100)
        end
        TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, -8.0, 2000, 49, 0, false, false, false)

        -- Wait for animations to complete
        Wait(2000)

        -- Give the item to the player
        TriggerServerEvent('ronakks-shop:giveItem', item.model, quantity)

        -- Notify the player
        QBCore.Functions.Notify("You bought " .. quantity .. "x " .. item.name .. " for $" .. totalCost, "success")

        -- Reset the ped's scenario and continue
        ClearPedTasksImmediately(ped)
        TaskStartScenarioInPlace(ped, pedConfig.scenario, 0, true)
    else
        QBCore.Functions.Notify("You don't have enough money", "error")
    end
end)

-- Helper function to get closest ped
function GetClosestPed(x, y, z)
    local peds = GetGamePool('CPed')
    local closestPed = nil
    local minDistance = 999999
    
    for _, ped in ipairs(peds) do
        local pedCoords = GetEntityCoords(ped)
        local distance = Vdist(x, y, z, pedCoords.x, pedCoords.y, pedCoords.z)
        if distance < minDistance then
            minDistance = distance
            closestPed = ped
        end
    end
    
    return closestPed
end
