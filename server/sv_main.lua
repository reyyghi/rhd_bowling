lib.callback.register('bp-bowling:purchaseItem', function(src, key, lane, price)
    local jumlahDuit = exports.ox_inventory:Search(src, 'count', 'money')
    if(lane == true) then
        if jumlahDuit >= tonumber(price) then
            exports.ox_inventory:RemoveItem(src, 'money', price)

            info = {
                lane = key
            }

            exports.ox_inventory:AddItem(src, 'bowlingreceipt', 1, info)
            value = true
        else
            TriggerClientEvent('rhd:notify', src, 'Not Enough Money', 'error')
        end
    else
        if jumlahDuit >= tonumber(price) then
            value = true
            exports.ox_inventory:RemoveItem(src, 'money', price)
            exports.ox_inventory:AddItem(src, 'bowlingball', 1)
        else
            TriggerClientEvent('rhd:notify', src, 'Not Enough Money', 'error')
        end
    end
    return value
end)

lib.callback.register('bp-bowling:getLaneAccess', function(_, currentid)
    local value = false
    if(currentid == info.lane) then
        value = true
    end
    return value
end)

RegisterNetEvent('removeItem', function(item, count)
    exports.ox_inventory:RemoveItem(source, item, count)
end)
