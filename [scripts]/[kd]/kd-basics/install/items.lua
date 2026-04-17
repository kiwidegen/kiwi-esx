-- Add these entries to your ox_inventory/data/items.lua

['binoculars'] = {
    label       = 'Binoculars',
    weight      = 500,
    stack       = false,
    close       = true,
    consume     = 0,
    description = 'Police-issued binoculars for long-range observation.',
    server      = {
        export = 'kd-basics.useBinoculars'  -- server validates job, then fires client event
    },
},
