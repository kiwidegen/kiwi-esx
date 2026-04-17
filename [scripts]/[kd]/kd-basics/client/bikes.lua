-- ╔══════════════════════════════╗
-- ║       Bike Handlebars        ║
-- ╚══════════════════════════════╝
if not Config.Modules.Bikes then return end

local mounted    = false
local mountedVeh = nil

-- ─── Helpers ─────────────────────────────────────────────────────────────────

local function loadAnim(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end

local function getNearestBike()
    local ped     = cache.ped
    local myCoords = GetEntityCoords(ped)
    local best, bestDist = nil, Config.Bikes.promptRange

    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if GetVehicleClass(veh) == 13 and Config.Bikes.models[GetEntityModel(veh)] then
            local d = #(myCoords - GetEntityCoords(veh))
            if d < bestDist then
                best, bestDist = veh, d
            end
        end
    end

    return best
end

-- ─── Mount / dismount ────────────────────────────────────────────────────────

local function dismount()
    local ped    = cache.ped
    local coords = GetEntityCoords(ped)

    DetachEntity(ped, false, true)
    SetEntityCoords(ped, coords.x + 1.0, coords.y + 1.0, coords.z - 1.0)
    ClearPedTasks(ped)

    if mountedVeh then
        Entity(mountedVeh).state:set('bikeOccupied', false, true)
    end

    mounted    = false
    mountedVeh = nil
end

local function mount(veh)
    local ped    = cache.ped
    local offset = Config.Bikes.models[GetEntityModel(veh)]

    loadAnim(Config.Bikes.animDict)

    AttachEntityToEntity(
        ped, veh, 0,
        offset[1], offset[2], offset[3],
        offset[4], offset[5], offset[6],
        true, false, false, false, 0, true
    )

    TaskPlayAnim(ped, Config.Bikes.animDict, Config.Bikes.animName, 3.0, 3.0, -1, 1, 0, false, false, false)

    Entity(veh).state:set('bikeOccupied', true, true)
    mounted    = true
    mountedVeh = veh
end

-- ─── Key command ─────────────────────────────────────────────────────────────

RegisterCommand('handlebars', function()
    local ped = cache.ped

    -- bail if already in a vehicle
    if cache.vehicle then return end

    if mounted then
        dismount()
        return
    end

    local veh = getNearestBike()
    if not veh then return end

    -- check if another player is already on the handlebars
    if Entity(veh).state.bikeOccupied then
        lib.notify({ title = 'Bike', description = 'Someone is already on the handlebars.', type = 'error' })
        return
    end

    mount(veh)
end, false)

RegisterKeyMapping('handlebars', 'Sit on bike handlebars', 'keyboard', 'g')

-- ─── Proximity hint ──────────────────────────────────────────────────────────

local hintShown = false

CreateThread(function()
    while true do
        if not mounted then
            local near = getNearestBike() ~= nil

            if near and not hintShown then
                lib.showTextUI('[G] Sit on handlebars', { position = 'bottom-center' })
                hintShown = true
            elseif not near and hintShown then
                lib.hideTextUI()
                hintShown = false
            end
        elseif hintShown then
            lib.hideTextUI()
            hintShown = false
        end

        Wait(500)
    end
end)

-- ─── Safety check ────────────────────────────────────────────────────────────
-- dismount if bike disappears or player gets into a vehicle while mounted

CreateThread(function()
    while true do
        Wait(1000)

        if mounted then
            if cache.vehicle or not mountedVeh or not DoesEntityExist(mountedVeh) then
                dismount()
            end
        end
    end
end)
