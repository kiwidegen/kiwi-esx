RadialConfig = {}

RadialConfig.ExtrasEnabled = true

-- Elevator Config
RadialConfig.Elevators = {
    {
        name = "Hospital Elevator",
        coords = vector3(-674.2553, 323.5964, 140.1228),
        destinations = {
            { label = "Helipad", coords = vec4(-674.2553, 323.5964, 140.1228, 168.4353) },
            { label = "Ground Floor", coords = vec4(-670.5380, 361.7665, 83.0838, 172.2433) },
            { label = "Garage", coords = vec4(-670.5840, 362.0480, 77.7747, 178.2673) },
        }
    },
    {
        name = "Police Elevator",
        coords = vector3(-590.1708, -430.9168, 35.1796),
        destinations = {
            { label = "Garage", coords = vec4(-593.0334, -433.7134, 31.1682, 271.1736), extraCoords = vector3(-593.2449, -430.7381, 31.1729) },
            { label = "Ground Floor", coords = vec4(-590.1708, -430.9168, 35.1796, 264.6177), extraCoords = vector3(-590.2578, -430.8465, 35.1797) },
            { label = "First Floor", coords = vec4(-590.4363, -434.0110, 39.6402, 267.5717), extraCoords = vector3(-590.4020, -431.0800, 39.6403) },
            { label = "Second Floor", coords = vec4(-589.5337, -431.0233, 45.6354, 263.3217), extraCoords = vector3(-589.7179, -434.1706, 45.6355) },
        }
    },
    {
        name = "Arcadius Elevator",
        coords = vector3(-137.0249, -596.0368, 206.9158),
        destinations = {
            { label = "Rooftop", coords = vec4(-137.0249, -596.0368, 206.9158, 253.0476) },
            { label = "Ground Floor", coords = vec4(-118.1156, -607.2143, 36.2807, 249.2891) },
        }
    },
    {
        name = "Recycle Centre",
        coords = vector3(1050.5809, -3095.2766, -38.9999),
        destinations = {
            { label = "Enter Recycle", coords = vec4(1072.0906, -3095.8828, -38.7538, 90.9676) },
            { label = "Exit Recycle", coords = vec4(-195.7534, 6264.8110, 31.4893, 41.1322) },
        }
    }
}

RadialConfig.Key = 289 -- F2 key
RadialConfig.InteractDistance = 2.0
RadialConfig.TextPosition = { x = 0.95, y = 0.5 }

RadialConfig.Locales = {
    ['no_variants'] = "There don't seem to be any variants for this!",
    ['wrong_ped'] = "This ped model does not allow for this option",
    ['already_wearing'] = "You are already wearing that!",
    ['nothing_to_remove'] = "You don't appear to have anything to remove",
}

RadialConfig.Commands = {
    ["top"] = { Func = function() ToggleClothing("Top") end, Sprite = "top", Desc = "Take your shirt off/on", Button = 1, Name = "Torso" },
    ["gloves"] = { Func = function() ToggleClothing("gloves") end, Sprite = "gloves", Desc = "Take your gloves off/on", Button = 2, Name = "Gloves" },
    ["visor"] = { Func = function() ToggleProps("visor") end, Sprite = "visor", Desc = "Toggle hat variation", Button = 3, Name = "Visor" },
    ["bag"] = { Func = function() ToggleClothing("Bag") end, Sprite = "bag", Desc = "Opens or closes your bag", Button = 8, Name = "Bag" },
    ["shoes"] = { Func = function() ToggleClothing("Shoes") end, Sprite = "shoes", Desc = "Take your shoes off/on", Button = 5, Name = "Shoes" },
    ["vest"] = { Func = function() ToggleClothing("Vest") end, Sprite = "vest", Desc = "Take your vest off/on", Button = 14, Name = "Vest" },
    ["hair"] = { Func = function() ToggleClothing("hair") end, Sprite = "hair", Desc = "Put your hair up/down/in a bun/ponytail.", Button = 7, Name = "Hair" },
    ["hat"] = { Func = function() ToggleProps("Hat") end, Sprite = "hat", Desc = "Take your hat off/on", Button = 4, Name = "Hat" },
    ["glasses"] = { Func = function() ToggleProps("Glasses") end, Sprite = "glasses", Desc = "Take your glasses off/on", Button = 9, Name = "Glasses" },
    ["ear"] = { Func = function() ToggleProps("Ear") end, Sprite = "ear", Desc = "Take your ear accessory off/on", Button = 10, Name = "Ear" },
    ["neck"] = { Func = function() ToggleClothing("Neck") end, Sprite = "neck", Desc = "Take your neck accessory off/on", Button = 11, Name = "Neck" },
    ["watch"] = { Func = function() ToggleProps("Watch") end, Sprite = "watch", Desc = "Take your watch off/on", Button = 12, Name = "Watch", Rotation = 5.0 },
    ["bracelet"] = { Func = function() ToggleProps("Bracelet") end, Sprite = "bracelet", Desc = "Take your bracelet off/on", Button = 13, Name = "Bracelet" },
    ["mask"] = { Func = function() ToggleClothing("Mask") end, Sprite = "mask", Desc = "Take your mask off/on", Button = 6, Name = "Mask" }
}

local bags = {[40] = true, [41] = true, [44] = true, [45] = true}

RadialConfig.ExtraCommands = {
    ["pants"] = { Func = function() ToggleClothing("Pants", true) end, Sprite = "pants", Desc = "Take your pants off/on", Name = "Pants", OffsetX = -0.04, OffsetY = 0.0 },
    ["shirt"] = { Func = function() ToggleClothing("Shirt", true) end, Sprite = "shirt", Desc = "Take your shirt off/on", Name = "shirt", OffsetX = 0.04, OffsetY = 0.0 },
    ["reset"] = { Func = function() if not ResetClothing(true) then Notify('Nothing To Reset', 'error') end end, Sprite = "reset", Desc = "Revert everything back to normal", Name = "reset", OffsetX = 0.12, OffsetY = 0.2, Rotate = true },
    ["bagoff"] = { Func = function() ToggleClothing("Bagoff", true) end, Sprite = "bagoff", Desc = "Take your bag off/on", Name = "bagoff", OffsetX = -0.12, OffsetY = 0.2,
        SpriteFunc = function()
            local Bag = GetPedDrawableVariation(PlayerPedId(), 5)
            local BagOff = LastEquipped["Bagoff"]
            if LastEquipped["Bagoff"] then
                if bags[BagOff.Drawable] then return "bagoff" else return "paraoff" end
            end
            if Bag ~= 0 then
                if bags[Bag] then return "bagoff" else return "paraoff" end
            else
                return false
            end
        end
    }
}

-- Emote Menu Items
RadialConfig.EmoteMenuItems = {
    { id = 'surrender', title = 'Surrender', icon = 'hands' },
    { id = 'smoke', title = 'Smoke', icon = 'smoking' },
    { id = 'phone', title = 'Phone', icon = 'mobile-screen' },
    { id = 'whistle', title = 'Whistle', icon = 'wind' },
    { id = 'wait', title = 'Wait', icon = 'clock' },
    { id = 'guard', title = 'Guard', icon = 'shield' },
    { id = 'salute', title = 'Salute', icon = 'hand-salute' },
    { id = 'joint', title = 'Joint', icon = 'cannabis' },
    { id = 'coffee', title = 'Coffee', icon = 'mug-hot' },
    { id = 'eat', title = 'Eat', icon = 'utensils' },
}
