return {
  General = {
    name = 'Shop',
    blip = {
      id = 59,
      colour = 11,
      scale = 0.8
    },
    inventory = {
      { name = 'phone',              price = 3200 },
      --{ name = 'weed_papers',        price = 550 },
      { name = 'water',          price = 500 },
      { name = 'burger', price = 500 },
      { name = 'bandage',            price = 100 }
    },
    locations = {
      vector3(24.40, -1345.55, 28.5),    -- STRAWBERRY 24/7
      vector3(373.0, 328.13, 103.57),    -- VINEWOOD 24/7
      vector3(549.36, 2669.48, 41.16),   -- HARMONY 24/7
      vector3(812.45, -780.79, 26.18),   -- LA MESA
      vector3(1959.16, 3741.39, 32.34),  -- SANDY SHORES 24/7
      vector3(2555.49, 380.83, 108.62),  -- PALOMINO FWY 24/7
      vector3(2676.58, 3280.23, 55.24),  -- SENORA FWY 24/7
      vector3(-3243.94, 1000.01, 12.83), -- CHUMASH 24/7
      vector3(-3040.59, 583.74, 7.91)    -- CHUMASH 2 24/7
    },
    targets = {
      { loc = vector3(24.40, -1345.55, 28.5),    heading = 255.0,  ped = 'mp_m_shopkeep_01', scenario = 'WORLD_HUMAN_SMOKING', distance = 3.0 }, -- STRAWBERRY
      { loc = vector3(373.0, 328.13, 102.57),    heading = 250.0,  ped = 's_f_y_clubbar_01', scenario = 'WORLD_HUMAN_SMOKING', distance = 3.0 }, -- VINEWOOD
      { loc = vector3(549.36, 2669.48, 40.16),   heading = 95.0,   ped = 'mp_m_shopkeep_01', scenario = 'WORLD_HUMAN_SMOKING', distance = 3.0 }, -- HARMONY
      { loc = vector3(1959.16, 3741.39, 31.34),  heading = 304.0,  ped = 's_f_y_clubbar_01', scenario = 'WORLD_HUMAN_SMOKING', distance = 3.0 }, -- SANDY SHORES
      { loc = vector3(2555.49, 380.83, 107.62),  heading = 0.0,    ped = 'mp_m_shopkeep_01', scenario = 'WORLD_HUMAN_SMOKING', distance = 3.0 }, -- PALOMINO FWY
      { loc = vector3(2676.58, 3280.23, 54.24),  heading = 330.0,  ped = 'mp_m_shopkeep_01', scenario = 'WORLD_HUMAN_SMOKING', distance = 3.0 }, -- SENORA FWY
      { loc = vector3(-3243.94, 1000.01, 11.83), heading = 350.0,  ped = 'mp_m_shopkeep_01', scenario = 'WORLD_HUMAN_SMOKING', distance = 3.0 }, -- CHUMASH
      { loc = vector3(-3040.59, 583.74, 6.91),   heading = 15.0,   ped = 's_f_y_clubbar_01', scenario = 'WORLD_HUMAN_SMOKING', distance = 3.0 }, -- CHUMASH 2
      { loc = vector3(160.32, 6641.73, 30.7),    heading = 220.63, ped = 's_f_y_clubbar_01', scenario = 'WORLD_HUMAN_SMOKING', distance = 3.0 }  -- PALETO 24/7
    }
  },
  LTD = {
    name = 'LTD Gasoline',
    blip = {
      id = 59,
      colour = 69,
      scale = 0.8
    },
    inventory = {
      { name = 'icecoffee',          price = 500 },
      { name = 'doublecheeseburger', price = 500 },
      { name = 'weed_papers',        price = 200 },
      { name = 'repairkit_basic',    price = 2500 }
    },
    locations = {
      vector3(1164.9, -323.71, 69.21),  -- MIRROR PARK
      vector3(1697.06, 4923.28, 42.06), -- GRAPESEED
      vector3(-706.02, -914.6, 19.22),  -- LITTLE SEOUL
      vector3(-47.62, -1759.38, 29.42)  -- GROVE
    },
    targets = {
      { loc = vector3(1164.9, -323.71, 68.21),  heading = 105.0, ped = 'mp_m_shopkeep_01', scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 3.0 }, -- MIRROR PARK
      { loc = vector3(1697.06, 4923.28, 41.06), heading = 320.0, ped = 's_f_y_shop_low',   scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 3.0 }, -- GRAPESEED
      { loc = vector3(-706.02, -914.6, 18.22),  heading = 90.0,  ped = 's_f_y_shop_low',   scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 3.0 }, -- LITTLE SEOUL
      { loc = vector3(-47.62, -1759.38, 28.42), heading = 50.57, ped = 's_f_y_shop_low',   scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 3.0 }  -- GROVE
    }
  },
  Liquor = {
    name = 'Liquor Store',
    blip = {
      id = 93,
      colour = 69,
      scale = 0.8
    },
    inventory = {
      { name = 'water', price = 10 },
      { name = 'cola',  price = 10 },
      { name = 'beer',  price = 10 }
    },
    locations = {
      vector3(1134.16, -983.17, 46.42),  -- MURRIETA
      vector3(-1221.28, -908.07, 12.33), -- VESPUCCI
      vector3(-1486.77, -377.48, 40.16), -- MORNINGWOOD
      vector3(-2966.39, 391.51, 15.04),  -- BANHAM CANYON
      vector3(1165.48, 2710.9, 38.16)    -- ROUTE 68
    },
    targets = {
      { loc = vector3(1134.16, -983.17, 45.42),  heading = 285.0, ped = 'a_m_m_salton_03', scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 3.0 }, -- MURRIETA
      { loc = vector3(-1221.28, -908.07, 11.33), heading = 35.0,  ped = 'a_m_m_salton_04', scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 3.0 }, -- VESPUCCI
      { loc = vector3(-1486.77, -377.48, 39.16), heading = 135.0, ped = 'a_m_m_salton_03', scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 3.0 }, -- MORNINGWOOD
      { loc = vector3(-2966.39, 391.51, 14.04),  heading = 95.0,  ped = 'a_m_m_salton_04', scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 3.0 }, -- BANHAM CANYON
      { loc = vector3(1165.48, 2710.9, 37.16),   heading = 185.0, ped = 'a_m_m_salton_04', scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 3.0 }  -- ROUTE 68
    }
  },
  DigitalDen = {
    name = 'DigitalDen',
    blip = {
      id = 459,   -- Blip ID for PC/Computer (tech-related)
      colour = 3, -- Blue color for tech shop
      scale = 0.8
    },
    inventory = {
      { name = 'radio', price = 1500 },
      { name = 'phone', price = 3200 }
    },
    locations = {
      vector3(-1530.12, -401.62, 34.64) -- Provided coordinates
    },
    targets = {
      { loc = vector3(-1530.12, -401.62, 34.64), heading = 224.34, ped = 'mp_m_waremech_01', scenario = 'WORLD_HUMAN_CLIPBOARD', distance = 3.0 }
    }
  },
  YouTool = {
    name = 'YouTool',
    blip = {
      id = 402,
      colour = 69,
      scale = 0.8
    },
    inventory = {
      { name = 'lockpick',        price = 1000 },
      { name = 'blowtorch',       price = 1600 },
      { name = 'kq_outfitbag',    price = 3000 },
      { name = 'repairkit_basic', price = 1500 },
      { name = 'cleaningkit', price = 100},
      --{ name = 'metaldetector',   price = 15000 }
    },
    locations = {
      vector3(2747.76, 3472.93, 55.67), -- SENORA FWY
      vector3(55.2, -1739.43, 29.59)    -- DAVIS
    },
    targets = {
      { loc = vector3(2747.76, 3472.93, 54.67), heading = 250.0, ped = 'mp_m_waremech_01', scenario = 'WORLD_HUMAN_CLIPBOARD', distance = 3.0 }, -- SENORA FWY
      { loc = vector3(55.2, -1739.43, 28.59),   heading = 55.0,  ped = 'mp_m_waremech_01', scenario = 'WORLD_HUMAN_CLIPBOARD', distance = 3.0 }  -- DAVIS
    }
  },
  --[[ Chemist = {
    name = 'Pillbox Chemist',
    blip = {
      id = 403,
      colour = 69,
      scale = 0.8
    },
    inventory = {
      { name = 'bandage', price = 200 }
    },
    locations = {
      vector3(-663.72, 321.77, 83.08) -- DARNELL BROS
    },
    targets = {
      { loc = vector3(-663.72, 321.77, 82.08), heading = 170.07, ped = 's_m_m_doctor_01', scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 3.0 } -- DARNELL BROS
    }
  },]]
  adventure = {
    name = 'Adventure Shop',
    blip = {
      id = 59,
      colour = 69,
      scale = 0.8
    },
    inventory = {
      { name = 'parachute', price = 2000 }
    },
    locations = {
      vector3(-663.72, 321.77, 83.08) -- DARNELL BROS
    },
    targets = {
      { loc = vector3(-1686.62, -1072.48, 12.14), heading = 51.02, ped = 'a_m_y_beach_02', scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 3.0 } -- DARNELL BROS
    }
  },
 --[[ hospcafe = {
    name = 'Hospital Cafe',
    blip = {
      id = 59,
      colour = 11,
      scale = 0.8
    },
    inventory = {
      { name = 'chocolate_cream_frappuccino', price = 2000 },
      { name = 'cold_brew_latte',             price = 500 },
      { name = 'caremel_frappucino',          price = 500 }, -- Fixed typo: 'caremel' to 'caramel'
      { name = 'bolognese',                   price = 500 },
      { name = 'eggsbacon',                   price = 500 },
      { name = 'sausageroll',                 price = 500 }
    },
    locations = {
      vector3(-794.55, -1255.17, 5.7) -- DARNELL BROS
    },
    targets = {
      { loc = vector3(-794.55, -1255.17, 5.7), heading = 233.54, ped = 's_f_y_shop_low', scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 4.0 } -- DARNELL BROS
    }
  },
  BlackMarket = {
    name = 'Dirty Deals',
    blip = {
      id = 110,
      colour = 1,
      scale = 0.8
    },
    inventory = {
      { name = 'lockpick',         price = 10 },
      { name = 'baggy_empty',      price = 50 },
      { name = 'advancedlockpick', price = 2000,  currency = 'black_money' },
      { name = 'drill',            price = 3000,  currency = 'black_money' },
      { name = 'ropehook',         price = 4000,  currency = 'black_money' },
      { name = 'thermite',         price = 1000,  currency = 'black_money' },
      { name = 'handsaw',          price = 5000,  currency = 'black_money' },
      { name = 'wirecutters',      price = 4000,  currency = 'black_money' },
      { name = 'pincracker',       price = 7000,  currency = 'black_money' },
      { name = 'c4',               price = 30000, currency = 'black_money' },
      { name = 'light_armor',      price = 25000, currency = 'black_money' },
      { name = 'heavy_armor',      price = 50000, currency = 'black_money' }
    },
    locations = {
      vector3(2937.73, 4620.63, 48.7) -- FARM BOY
    },
    targets = {
      { loc = vector3(2937.73, 4620.63, 48.7), heading = 250.0, ped = 'g_m_y_lost_03', scenario = 'WORLD_HUMAN_SMOKING_POT', distance = 2.0 } -- FARM BOY
    }
  },]]
  Ammunation = {
    name = 'Ammunation',
    blip = {
      id = 110,
      colour = 69,
      scale = 0.8
    },
    inventory = {
      { name = 'ammo-9-box',    price = 2000 },
      { name = 'WEAPON_BAT',    price = 15000 },
      { name = 'WEAPON_PISTOL', price = 40000, metadata = { registered = true }, license = 'weapon' }
    },
    locations = {
      vector3(-661.92, -933.46, 21.83),  -- LITTLE SEOUL
      vector3(809.71, -2159.06, 29.62),  -- CYPRESS FLATS
      vector3(1692.33, 3761.17, 34.71),  -- SANDY
      vector3(-331.4, 6085.33, 31.45),   -- PALETO
      vector3(253.83, -50.9, 69.94),     -- HAWICK
      vector3(23.09, -1105.69, 29.8),    -- PILLBOX HILL
      vector3(2567.46, 292.54, 108.73),  -- PALOMINO FWY
      vector3(-1118.72, 2700.04, 18.55), -- ROUTE 68
      vector3(841.99, -1035.38, 28.19),  -- LA MESA
      vector3(-1316.10, -390.08, 36.47)  -- GYM
    },
    targets = {
      { loc = vector3(-661.92, -933.46, 20.83),  heading = 175.0, ped = 'ig_hunter', scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 3.0 }, -- LITTLE SEOUL
      { loc = vector3(809.71, -2159.06, 28.62),  heading = 350.0, ped = 'ig_hunter', scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 3.0 }, -- CYPRESS FLATS
      { loc = vector3(1692.33, 3761.17, 33.71),  heading = 240.0, ped = 'ig_hunter', scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 3.0 }, -- SANDY
      { loc = vector3(-331.4, 6085.33, 30.45),   heading = 220.0, ped = 'ig_hunter', scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 3.0 }, -- PALETO
      { loc = vector3(253.83, -50.9, 68.94),     heading = 65.0,  ped = 'ig_hunter', scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 3.0 }, -- HAWICK
      { loc = vector3(23.09, -1105.69, 28.8),    heading = 155.0, ped = 'ig_hunter', scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 3.0 }, -- PILLBOX HILL
      { loc = vector3(2567.46, 292.54, 107.73),  heading = 1.0,   ped = 'ig_hunter', scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 3.0 }, -- PALOMINO FWY
      { loc = vector3(-1118.72, 2700.04, 17.55), heading = 220.0, ped = 'ig_hunter', scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 3.0 }, -- ROUTE 68
      { loc = vector3(841.99, -1035.38, 27.19),  heading = 350.0, ped = 'ig_hunter', scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 3.0 }, -- LA MESA
      { loc = vector3(-1304.14, -395.39, 35.69), heading = 65.20, ped = 'ig_hunter', scenario = 'WORLD_HUMAN_STAND_IDLE', distance = 3.0 }  -- GYM
    }
  },
  VendingMachineDrinks = {
    name = 'Drinks Machine',
    inventory = {
      { name = 'water',  price = 20 },
      { name = 'cola',   price = 10 },
      { name = 'sprunk', price = 10 }
    },
    model = {
      'prop_vend_soda_02',
      'prop_vend_fridge01',
      'prop_vend_water_01',
      'prop_vend_soda_01'
    }
  },
  CoffeeMachines = {
    name = 'Coffee Machine',
    inventory = {
      { name = 'water', price = 10 }
    },
    model = {
      'prop_coffee_mac_02',
      'prop_vend_coffe_01',
      'prop_coffee_mac_01'
    }
  },
  SnackMachines = {
    name = 'Snack Machine',
    inventory = {
      { name = 'burger', price = 10 }
    },
    model = {
      'prop_vend_snak_01'
    }
  },
  WaterCooler = {
    name = 'Water Cooler',
    inventory = {
      { name = 'water', price = 10 }
    },
    model = {
      'prop_watercooler'
    }
  }
}
