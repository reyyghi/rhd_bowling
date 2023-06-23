local hasActivePins = false
local currentLane = 0
local totalThrown = 0
local totalDowned = 0
local lastBall = 0
local lanes = Config.BowlingLanes
local inBowlingZone = false
local blipMlo = nil
local target = {}

local function canUseLane(pLaneId)
    local shit = false
    local response = lib.callback.await("bp-bowling:getLaneAccess", false, pLaneId)
    if(response == true) then
        shit = true
    end
    Wait(300)
    return shit
end

CreateThread(function()
    lib.zones.box({
        name = "zonaMloBowling",
        coords = vec3(743.35, -774.45, 25.75),
        size = vec3(30.15, 17.0, 5.75),
        rotation = 0.0,
        inside = function ()
            if Config.RemoveStress then
                if Config.RemoveStress['enabled'] then
                    TriggerEvent('esx_status:remove', 'stress', Config.RemoveStress['remove'] * 10000)
                    Wait(Config.RemoveStress['time'] * 60000)
                end
            end
        end,
        onEnter = function ()
            inBowlingZone = true
        end,
        onExit = function ()
            inBowlingZone = false
            TriggerEvent("bp-bowling:RemoveItem")
    
            if (hasActivePins) then
                resetBowling()
                totalDowned = 0
                totalThrown = 0
            end

            for k, v in pairs(lanes) do
                if target[k] ~= nil then

                    lanes[k].enabled = true
                    exports.ox_target:removeZone(target[k])

                end
            end
        end
    })

    local data = {
        id = 'bowling_npc_vendor',
        position = {
            coords = vector3(756.39, -774.74, 25.34),
            heading = 102.85,
        },
        pedType = 4,
        model = "a_m_o_salton_01",
        networked = false,
        distance = 25.0,
        settings = {
            { mode = 'invincible', active = true },
            { mode = 'ignore', active = true },
            { mode = 'freeze', active = true },
        },
        flags = {
            isNPC = true,
        },
    }
    
    blipMlo = RHDFunction.bikinBlip(data.position.coords.xyz, 106, 3, 'Bowling', 0.8)
    
    lib.requestModel(data.model)
    created_ped = CreatePed(data.pedType, data.model , data.position.coords.x,data.position.coords.y,data. position.coords.z, data.position.heading, data.networked, false)
	FreezeEntityPosition(created_ped, true)
	SetEntityInvincible(created_ped, true)
	SetBlockingOfNonTemporaryEvents(created_ped, true)

    exports.ox_target:addLocalEntity(created_ped, {
        {
            event = 'bp-bowling:client:openMenu',
            icon = 'fas fa-bowling-ball',
            label = 'View Store',
            distance = 1.5
        }
    })
end)

local function drawStatusHUD(state, pValues)
    local title = "Bowling - Lane #" .. currentLane
    local values = {}
  
    table.insert(values, "Throws: " .. totalThrown)
    table.insert(values, "Downed: " .. totalDowned)

    if (pValues) then
        for k, v in pairs(pValues) do
        table.insert(values, v)
        end
    end
    
    SendNUIMessage({show = state , t = title , v = values})
end
RegisterNetEvent('bp-bowling:client:openMenu')
AddEventHandler('bp-bowling:client:openMenu' , function()
    local options = Config.BowlingVendor
    local context = {
        id = 'menuToko',
        title = 'Bowling Shop',
        options = {}
    }
    for itemId, item in pairs(options) do

        context.options[#context.options+1] = {
            title = item.name,
            description = 'Price ' .. item.price .. '$',
            onSelect = function ()
                TriggerEvent('bp-bowling:openMenu2', {data = itemId, price = item.price})
            end
        }
    end
    lib.registerContext(context)
    lib.showContext('menuToko')
end)


RegisterNetEvent('bp-bowling:openMenu2')
AddEventHandler('bp-bowling:openMenu2' , function(data)
    if(data.data == 'bowlingreceipt') then
        local context = {
            id = 'tokoBowling',
            title = 'Bowling Shop',
            options = {}
        }

        for k, v in ipairs(lanes) do

            local disable = lanes[k].enabled
            
            disable = not disable
            
            context.options[#context.options+1] = {
                title = "Lane #"..k,
                disabled = disable,
                onSelect = function ()
                    TriggerEvent('bp-bowling:bowlingPurchase', {key = k, price = data.price})
                end
            }
        end

        lib.registerContext(context)
        lib.showContext('tokoBowling')

    else
        TriggerEvent("bp-bowling:bowlingPurchase" , {key = 'b', price = data.price})
    end
end)

local sheesh = false
function shit(k,v) 
    CreateThread(function()
        while sheesh == true do
            local pos = vec3(v.pos.x, v.pos.y, v.pos.z - 1)
            target[k] = exports.ox_target:addSphereZone({
                coords = pos,
                radius = 1,
                debug = false,
                options = {
                    {
                        onSelect = function ()
                            TriggerEvent('bp-bowling:setupPins', {v = k})
                        end,
                        icon = 'fas fa-arrow-circle-down',
                        label = 'Setup Pins',
                        distance = 2.5
                    }
                }
            })
            sheesh = false
            Wait(0)
        end
    end)

end

local lastlane = 0

RegisterNetEvent('bp-bowling:bowlingPurchase')
AddEventHandler("bp-bowling:bowlingPurchase", function(data)
    local isLane = type(data.key) == "number"
    local response = lib.callback.await("bp-bowling:purchaseItem", false, data.key , isLane, data.price)

    if response == true then
        if(isLane == true) then
            for k, v in pairs(lanes) do

                if(canUseLane(k) == true) then
                    sheesh = true
                    shit(k , v)
                end
            end
            lanes[data.key].enabled = false
            lastlane = data.key
            RHDFunction.notif("You've successfuly bought lane access | Lane: "..data.key.."#", "success")
        else
            RHDFunction.notif("You've successfuly bought a Bowling Ball", "success")
        end
        return
    end  
end)

AddEventHandler('bp-bowling:setupPins', function(pParameters)
    local response = lib.callback.await("bp-bowling:getLaneAccess", false, pParameters.v)
    if response == true then
        local lane = pParameters.v
        if (not lanes[lane]) then return end
        if (hasActivePins) then return end
        hasActivePins = true
        currentLane = lane
        drawStatusHUD(true)
        createPins(lanes[lane].pins)
    else
        RHDFunction.notif("No access to this lane", "error")
    end
end)



local function canUseBall()
    return (lastBall == 0 or lastBall + 6000 < GetGameTimer()) and (inBowlingZone)
end

local function resetBowling()
    removePins()
    hasActivePins = false
    drawStatusHUD(false)
end

local gameState = {}
gameState[1] = {
    onState = function()
        if (totalDowned >= 10) then
            RHDFunction.notif("Strike!")

            drawStatusHUD(true, {"Strike!"})

            Wait(1500)

            resetBowling()
            totalDowned = 0
            totalThrown = 0
        elseif (totalDowned < 10) then
            removeDownedPins()
            drawStatusHUD(true, {"Throw again!"})
        end
    end
}
gameState[2] = {
    onState = function()
        if (totalDowned >= 10) then
            drawStatusHUD(true, {"Spare!"})
            RHDFunction.notif("Spare!")


            Wait(500)

            resetBowling()
        elseif (totalDowned < 10) then
            TriggerEvent("You downed " .. totalDowned .. " pins!")

            Wait(1500)

            resetBowling()
        end

        totalDowned = 0
        totalThrown = 0
    end
}

RegisterNetEvent('bp-bowling:client:itemused')
AddEventHandler('bp-bowling:client:itemused' , function()
    if (IsPedInAnyVehicle(PlayerPedId(), true)) then return end

    -- Cooldown
    if (not canUseBall()) then return end
    startBowling(false, function(ballObject)
        lastBall = GetGameTimer()
        
        if (hasActivePins) then
            totalThrown = totalThrown + 1

            local isRolling = true
            local timeOut = false

            while (isRolling and not timeOut) do
                Wait(100)

                local ballPos = GetEntityCoords(ballObject)
                
                if (lastBall == 0 or lastBall + 10000 < GetGameTimer()) then
                    timeOut = true
                end 

                if (ballPos.x < 730.0) then
                    -- Finish line baby
                    isRolling = false
                end
            end

            Wait(5000)

            totalDowned = getPinsDownedCount()

            if (timeOut) then
                drawStatusHUD(true, {"Time's up!"})
                timeOut = false
            end

            if (gameState[totalThrown]) then
                gameState[totalThrown].onState()
            end

            removeBowlingBall()
            
        end
    end)
end)


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    exports.ox_inventory:displayMetadata({
        lane = 'Lane Access',
    })
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end

    RemoveBlip(blipMlo)
    drawStatusHUD(false)
end)


RegisterNetEvent("bp-bowling:RemoveItem")
AddEventHandler("bp-bowling:RemoveItem" , function()
    if exports.ox_inventory:Search('count', 'bowlingball') > 0 then      
        TriggerServerEvent("removeItem", "bowlingball", 1)
    end

    if exports.ox_inventory:Search('count', 'bowlingreceipt') > 0 then
        TriggerServerEvent("removeItem", "bowlingreceipt", 1)
    end
end)
