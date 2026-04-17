return {
    ['binoculars'] = {
        label       = 'Binoculars',
        weight      = 500,
        stack       = false,
        close       = true,
        description = 'Police-issued binoculars for long-range observation.',
        server      = {
            export = 'kd-basics.useBinoculars'
        },
    },


    ['drpcase'] = {
    label = 'DRP Mystery Case',
    weight = 500,
    stack = true,
    close = true,
    description = 'A mysterious case containing random rewards. Rare items inside!',
    rarity = 'demon',
    client = {
        usetime = 500,
    },
    server = {
        export = 'drp-cases.useLootbox'
    },
    consume = 1
},

['drpcase1'] = {
    label = 'DRP Premium Case',
    weight = 500,
    stack = true,
    close = true,
    description = 'A premium case with a chance for legendary rewards!',
    rarity = 'demon',
    client = {
        usetime = 500,
    },
    server = {
        export = 'drp-cases.useLootbox'
    },
    consume = 1
},
    ["id_card"] = {
		label = "ID Card",
		weight = 0,
		stack = false,
		close = false,
		description = "A card containing all your information to identify yourself",
	},

    ["driver_license"] = {
		label = "Drivers License",
		weight = 0,
		stack = false,
		close = false,
		description = "Permit to show you can drive a vehicle",
	},

	["weaponlicense"] = {
		label = "Weapon License",
		weight = 0,
		stack = false,
		close = true,
		description = "Weapon License",
	},
    ['thermite_bomb'] = {
    label = 'Thermite Bomb',
    weight = 160,
},
['hack_usb'] = {
    label = 'Hack USB',
    weight = 160,
},
['big_bomb'] = {
    label = 'Big Bomb',
    weight = 160,
},
['bag'] = {
    label = 'Bag',
    weight = 160,
},
['cutter'] = {
    label = 'Cutter',
    weight = 160,
},
['drill'] = {
    label = 'Drill',
    weight = 160,
},
['gold_uzi'] = {
    label = 'Gold Uzi',
    weight = 160,
},
['pistol_ammo'] = {
    label = 'Pistol Ammo',
    weight = 160,
},
['rifle_ammo'] = {
    label = 'Rifle Ammo',
    weight = 160,
},
['smg_ammo'] = {
    label = 'SMG Ammo',
    weight = 160,
},
['crowbar'] = {
    label = 'Crowbar',
    weight = 160,
},
    ['spray_can'] = {
    label = 'Spray Can',
    weight = 500,
    stack = false,
    close = true,
    description = 'Used to tag and claim drug territory.',
},

['gang_bandana'] = {
    label = 'Gang Bandana',
    weight = 100,
    stack = false,
    close = false,
    description = 'Allows you to sell in gang territory.',
},

['weed'] = {
    label = 'Weed',
    weight = 30,
    stack = true,
    close = true,
    description = 'Illegal substance.',
},

['cocaine'] = {
    label = 'Cocaine',
    weight = 30,
    stack = true,
    close = true,
    description = 'Illegal substance.',
},

['meth'] = {
    label = 'Meth',
    weight = 30,
    stack = true,
    close = true,
    description = 'Illegal substance.',
},

['heroin'] = {
    label = 'Heroin',
    weight = 30,
    stack = true,
    close = true,
    description = 'Illegal substance.',
},

['mdma'] = {
    label = 'MDMA',
    weight = 30,
    stack = true,
    close = true,
    description = 'Illegal substance.',
},
    ['carkeys'] = {
    label = 'Car Keys',
    weight = 100,
    stack = false,
    close = true,
},

    ['drpcase'] = {
    label = 'Mystery Case',
    weight = 50,
    stack = true,
    close = true,
    description = 'A mysterious case containing random rewards. Rare items inside!',
    rarity = 'rare',
    server = {
        export = 'drp-cases.useLootbox'
    },
    consume = 1
},

['drpcase1'] = {
    label = 'Premium Case',
    weight = 100,
    stack = true,
    close = true,
    description = 'A premium case with a chance for legendary rewards!',
    rarity = 'demon',
    server = {
        export = 'drp-cases.useLootbox'
    },
    consume = 1
},
    ['backpack'] = {
    label = 'Backpack',
    weight = 2000,
    stack = false,
    description = 'A durable backpack for carrying more items.',
    container = { slots = 24, maxWeight = 15000 },
    client = {
        image = 'backpack.png',
        backpackProp = 'p_michael_backpack_s',
        backpackBone = 24818,
        backpackPos = vec3(0.08, -0.11, -0.04),
        backpackRot = vec3(0.0, -90.0, 180.0)
    }
},


    ['blowtorch'] = {
      label = 'Blowtorch',
      weight = 20,
      stack = false,
      close = true,
      description = 'A blowtorch for scrapping vehicles',
      client = {
          image = 'blowtorch.png',
      },
      durability = 100
  },
    ['repairkit'] = {
      label = 'Repair Kit',
      weight = 1500,
      stack = true,
      close = true,
      description = 'A basic vehicle repair kit',
      client = {
          export = 'drp-repair.useRepairKit'
      }
  },

  ['adv_repairkit'] = {
      label = 'Advanced Repair Kit',
      weight = 2000,
      stack = true,
      close = true,
      description = 'An advanced vehicle repair kit for major damage',
      client = {
          export = 'drp-repair.useAdvRepairKit'
      }
  },
    ['brassingot'] = {
    label = 'brass ingot',
    weight = 1,
    stack = true,
    close = true,
    description = 'brass ingot'
},
    ['pickaxe'] = {
    label = 'Pickaxe',
    weight = 1000,
    stack = false,
    close = true,
    description = 'A sturdy pickaxe for mining',
    client = {
        image = 'pickaxe.png'
    }
},

['coal_ore'] = {
    label = 'Coal Ore',
    weight = 100,
    stack = true,
    close = true,
    description = 'Raw coal ore',
    client = {
        image = 'coal.png'
    }
},

['copper_ore'] = {
    label = 'Copper Ore',
    weight = 100,
    stack = true,
    close = true,
    description = 'Raw copper ore',
    client = {
        image = 'copper_ore.png'
    }
},

['iron_ore'] = {
    label = 'Iron Ore',
    weight = 100,
    stack = true,
    close = true,
    description = 'Raw iron ore',
    client = {
        image = 'iron_ore.png'
    }
},

['silver_ore'] = {
    label = 'Silver Ore',
    weight = 100,
    stack = true,
    close = true,
    description = 'Raw silver ore',
    client = {
        image = 'silver_ore.png'
    }
},

['gold_ore'] = {
    label = 'Gold Ore',
    weight = 100,
    stack = true,
    close = true,
    description = 'Raw gold ore',
    client = {
        image = 'gold_ore.png'
    }
},

['zinc_ore'] = {
    label = 'Zinc Ore',
    weight = 100,
    stack = true,
    close = true,
    description = 'Raw zinc ore',
    client = {
        image = 'zinc_ore.png'
    }
},

['copper_ingot'] = {
    label = 'Copper Ingot',
    weight = 500,
    stack = true,
    close = true,
    description = 'Smelted copper ingot',
    client = {
        image = 'copper_ingot.png'
    }
},

['iron_ingot'] = {
    label = 'Iron Ingot',
    weight = 500,
    stack = true,
    close = true,
    description = 'Smelted iron ingot',
    client = {
        image = 'iron_ingot.png'
    }
},

['silver_ingot'] = {
    label = 'Silver Ingot',
    weight = 500,
    stack = true,
    close = true,
    description = 'Smelted silver ingot',
    client = {
        image = 'silver_ingot.png'
    }
},

['gold_ingot'] = {
    label = 'Gold Ingot',
    weight = 500,
    stack = true,
    close = true,
    description = 'Smelted gold ingot',
    client = {
        image = 'gold_ingot.png'
    }
},

['zinc_ingot'] = {
    label = 'Zinc Ingot',
    weight = 500,
    stack = true,
    close = true,
    description = 'Smelted zinc ingot',
    client = {
        image = 'zinc_ingot.png'
    }
},

-- Miscellaneous Items
['bullet_casings'] = {
    label = 'Bullet Casings',
    weight = 50,
    stack = true,
    close = true,
    description = 'Empty bullet casings',
    client = {
        image = 'bullet_casings.png'
    }
},

['weapon_parts'] = {
    label = 'Weapon Parts',
    weight = 1000,
    stack = true,
    close = true,
    description = 'Various weapon parts',
    client = {
        image = 'weapon_parts.png'
    }
},


-- Weapon Parts (Level 5 Only)

['weapon_parts'] = {
    label = 'weapon parts',
    weight = 1,
    stack = true,
    close = true,
    description = 'weapon parts'
},

    ['brown_trout'] = {
    label = 'Brown Trout',
    weight = 800,
    stack = true,
    close = true,
    description = 'A common freshwater fish with distinctive brown coloring.',
    client = {
        image = 'brown_trout.png',
    }
},
['anchovy'] = {
    label = 'Anchovy',
    weight = 200,
    stack = true,
    close = true,
    description = 'A small, common saltwater fish.',
    client = {
        image = 'anchovy.png',
    }
},

['barramundi'] = {
    label = 'Barramundi',
    weight = 1200,
    stack = true,
    close = true,
    description = 'A popular sport fish found in both fresh and saltwater.',
    client = {
        image = 'barramundi.png',
    }
},

['bream'] = {
    label = 'Bream',
    weight = 700,
    stack = true,
    close = true,
    description = 'A common saltwater fish found near the coast.',
    client = {
        image = 'bream.png',
    }
},

['flathead'] = {
    label = 'Flathead',
    weight = 1000,
    stack = true,
    close = true,
    description = 'A bottom-dwelling fish with a distinctive flat head.',
    client = {
        image = 'flathead.png',
    }
},

['haddock'] = {
    label = 'Haddock',
    weight = 1100,
    stack = true,
    close = true,
    description = 'A popular food fish found in saltwater.',
    client = {
        image = 'haddock.png',
    }
},

['mullet'] = {
    label = 'Mullet',
    weight = 500,
    stack = true,
    close = true,
    description = 'A common coastal fish, often used as bait.',
    client = {
        image = 'mullet.png',
    }
},

['red_snapper'] = {
    label = 'Red Snapper',
    weight = 1800,
    stack = true,
    close = true,
    description = 'A valuable fish with vibrant red coloring.',
    client = {
        image = 'red_snapper.png',
    }
},

['sea_bass'] = {
    label = 'Sea Bass',
    weight = 1300,
    stack = true,
    close = true,
    description = 'A popular saltwater fish with delicate white flesh.',
    client = {
        image = 'sea_bass.png',
    }
},

['grouper'] = {
    label = 'Grouper',
    weight = 1600,
    stack = true,
    close = true,
    description = 'A large, meaty fish found in deeper waters.',
    client = {
        image = 'grouper.png',
    }
},
['mahimahi'] = {
    label = 'Mahi-Mahi',
    weight = 2000,
    stack = true,
    close = true,
    description = 'A colorful and delicious deep water sport fish.',
    client = {
        image = 'mahimahi.png',
    }
},

['marlin'] = {
    label = 'Marlin',
    weight = 2500,
    stack = true,
    close = true,
    description = 'A prized deep water game fish known for its fighting ability.',
    client = {
        image = 'marlin.png',
    }
},

['bluefin_tuna'] = {
    label = 'Bluefin Tuna',
    weight = 3500,
    stack = true,
    close = true,
    description = 'An extremely valuable and rare deep sea fish.',
    client = {
        image = 'bluefin_tuna.png',
    }
},

['tuna'] = {
    label = 'Tuna',
    weight = 3000,
    stack = true,
    close = true,
    description = 'A large, powerful fish found in deep waters.',
    client = {
        image = 'tuna.png',
    }
},

['shark'] = {
    label = 'Shark',
    weight = 5000,
    stack = true,
    close = true,
    description = 'A legendary deep sea predator. Extremely rare and valuable!',
    client = {
        image = 'shark.png',
    },
    rarity = 'legendary'
},

['trout'] = {
    label = 'Rainbow Trout',
    weight = 900,
    stack = true,
    close = true,
    description = 'A beautiful rainbow trout found in freshwater.',
    client = {
        image = 'rainbow_trout.png',
    }
},

['salmon'] = {
    label = 'Salmon',
    weight = 1500,
    stack = true,
    close = true,
    description = 'A prized freshwater fish known for its rich flavor.',
    client = {
        image = 'salmon.png',
    }
},

['piranha'] = {
    label = 'Piranha',
    weight = 600,
    stack = true,
    close = true,
    description = 'A rare and dangerous freshwater predator. Handle with care!',
    client = {
        image = 'piranha.png',
    }
},
    ['worms'] = {
    label = 'Worms',
    weight = 50,
    stack = true,
    close = true,
    description = 'Basic fishing bait. Works for most common fish.',
    client = {
        image = 'worms.png',
    }
},

['mussel'] = {
    label = 'Mussel Bait',
    weight = 75,
    stack = true,
    close = true,
    description = 'Mid-tier bait that reduces wait time. Attracts better fish. Requires Level 2.',
    client = {
        image = 'mussel.png',
    }
},

['pilchards'] = {
    label = 'Pilchards',
    weight = 100,
    stack = true,
    close = true,
    description = 'Premium bait for experienced fishermen. Significantly reduces wait time. Requires Level 3.',
    client = {
        image = 'pilchards.png',
    }
},
['security_card_01'] = {
    label = 'Security Card',
    weight = 50,
    stack = true,
    close = true,
    description = 'A security access card for bank systems'
},

['electronickit'] = {
    label = 'Electronic Kit',
    weight = 1000,
    stack = true,
    close = true,
    description = 'Advanced electronic hacking tools'
},

['goldbar'] = {
    label = 'Gold Bar',
    weight = 1000,
    stack = true,
    close = true,
    description = 'A shiny gold bar'
},

['diamond'] = {
    label = 'Diamond',
    weight = 100,
    stack = true,
    close = true,
    description = 'A precious diamond'
},
    ['basic_rod'] = {
    label = 'Basic Fishing Rod',
    weight = 2000,
    stack = false,
    close = true,
    description = 'A basic fishing rod for beginners. Loses 5% durability per use.',
    client = {
        image = 'basic_rod.png',
    },
    durability = 100
},

['graphite_rod'] = {
    label = 'Graphite Fishing Rod',
    weight = 1800,
    stack = false,
    close = true,
    description = 'A quality graphite rod for experienced anglers. Loses 3% durability per use. Requires Level 2.',
    client = {
        image = 'graphite_rod.png',
    },
    durability = 100
},

['titanium_rod'] = {
    label = 'Titanium Fishing Rod',
    weight = 1500,
    stack = false,
    close = true,
    description = 'The ultimate fishing rod made from titanium. Loses 1% durability per use. Requires Level 3.',
    client = {
        image = 'titanium_rod.png',
    },
    durability = 100
},
    ['iron'] = {
    label = 'Iron',
    weight = 500,
    stack = true,
    close = true,
    description = 'Raw iron material salvaged from scrap',
    client = {
        image = 'iron.png',
    }
},

['aluminum'] = {
    label = 'Aluminum',
    weight = 300,
    stack = true,
    close = true,
    description = 'Lightweight aluminum material from recycled sources',
    client = {
        image = 'aluminum.png',
    }
},

['rubber'] = {
    label = 'Rubber',
    weight = 200,
    stack = true,
    close = true,
    description = 'Recycled rubber material',
    client = {
        image = 'rubber.png',
    }
},

['glass'] = {
    label = 'Glass',
    weight = 400,
    stack = true,
    close = true,
    description = 'Broken glass pieces that can be recycled',
    client = {
        image = 'glass.png',
    }
},

['copper'] = {
    label = 'Copper',
    weight = 450,
    stack = true,
    close = true,
    description = 'Copper wire and pieces from electronics',
    client = {
        image = 'copper.png',
    }
},

['steel'] = {
    label = 'Steel',
    weight = 600,
    stack = true,
    close = true,
    description = 'Heavy steel material from scrap',
    client = {
        image = 'steel.png',
    }
},

['plastic'] = {
    label = 'Plastic',
    weight = 150,
    stack = true,
    close = true,
    description = 'Various plastic materials for recycling',
    client = {
        image = 'plastic.png',
    }
},
['recyclablematerial'] = {
    label = 'Recyclable Material',
    weight = 100,
    stack = true,
    close = true,
    description = 'Unsorted recyclable material from the recycling center that can be traded for specific materials',
    client = {
        image = 'recyclablematerial.png',
    }
},
['can'] = {
    label = 'Empty Can',
    weight = 50,
    stack = true,
    close = true,
    description = 'Empty aluminum can that can be recycled',
    client = {
        image = 'can.png',
    }
},

['bottle'] = {
    label = 'Empty Bottle',
    weight = 100,
    stack = true,
    close = true,
    description = 'Empty glass bottle that can be recycled',
    client = {
        image = 'bottle.png',
    }
},

['metalscrap'] = {
    label = 'Metal Scrap',
    weight = 550,
    stack = true,
    close = true,
    description = 'Mixed metal scraps',
    client = {
        image = 'metalscrap.png',
    }
},
    ['tobacco'] = {
    label = 'Tobacco Leaves',
    weight = 50,
    stack = true,
    close = true,
    description = 'Fresh tobacco leaves ready for processing'
},

['iron_ore'] = {
    label = 'Iron Ore',
    weight = 200,
    stack = true,
    close = true,
    description = 'Raw iron ore from the mine'
},

['tomato'] = {
    label = 'Tomato',
    weight = 25,
    stack = true,
    close = true,
    description = 'Fresh ripe tomato'
},

['gold_ore'] = {
    label = 'Gold Ore',
    weight = 250,
    stack = true,
    close = true,
    description = 'Raw gold ore from the mine'
},

['wood'] = {
    label = 'Wood Log',
    weight = 150,
    stack = true,
    close = true,
    description = 'Freshly cut wood log'
},

['grapes'] = {
    label = 'Grapes',
    weight = 50,
    stack = true,
    close = true,
    description = 'Fresh wine grapes'
},

-- Illegal Raw Materials
['weed_buds'] = {
    label = 'Weed Buds',
    weight = 30,
    stack = true,
    close = true,
    description = 'Unprocessed cannabis buds',
    illegal = true
},

['coca_leaves'] = {
    label = 'Coca Leaves',
    weight = 40,
    stack = true,
    close = true,
    description = 'Fresh coca leaves',
    illegal = true
},

['ephedrine'] = {
    label = 'Ephedrine',
    weight = 35,
    stack = true,
    close = true,
    description = 'Chemical precursor for methamphetamine',
    illegal = true
},

['ammonia'] = {
    label = 'Ammonia',
    weight = 100,
    stack = true,
    close = true,
    description = 'Industrial ammonia',
    illegal = true
},

['steel'] = {
    label = 'Steel',
    weight = 180,
    stack = true,
    close = true,
    description = 'Raw steel material',
    illegal = true
},

['metal'] = {
    label = 'Metal Scrap',
    weight = 150,
    stack = true,
    close = true,
    description = 'Scrap metal pieces',
    illegal = true
},

--============================================================
--  DRP-LYRIC: PROCESSED MATERIALS
--============================================================

-- Legal Processed Items
['cigarette'] = {
    label = 'Cigarette Pack',
    weight = 20,
    stack = true,
    close = true,
    description = 'Pack of cigarettes'
},

['iron_bar'] = {
    label = 'Iron Bar',
    weight = 500,
    stack = true,
    close = true,
    description = 'Smelted iron bar'
},

['tomato_crate'] = {
    label = 'Tomato Crate',
    weight = 100,
    stack = true,
    close = true,
    description = 'Crate of packaged tomatoes'
},

['gold_bar'] = {
    label = 'Gold Bar',
    weight = 800,
    stack = true,
    close = true,
    description = 'Pure gold bar'
},

['wood_plank'] = {
    label = 'Wood Plank',
    weight = 250,
    stack = true,
    close = true,
    description = 'Processed wood plank'
},

['wine'] = {
    label = 'Wine Bottle',
    weight = 300,
    stack = true,
    close = true,
    description = 'Bottle of wine'
},

--============================================================
--  DRP-LYRIC: ILLEGAL PROCESSED/CRAFTED ITEMS
--============================================================

['joint'] = {
    label = 'Joint',
    weight = 5,
    stack = true,
    close = true,
    description = 'Rolled marijuana joint',
    illegal = true
},

['cocaine'] = {
    label = 'Cocaine',
    weight = 10,
    stack = true,
    close = true,
    description = 'Processed cocaine',
    illegal = true
},

['crack'] = {
    label = 'Crack',
    weight = 8,
    stack = true,
    close = true,
    description = 'Crack cocaine',
    illegal = true
},

['cartridge'] = {
    label = 'Cartridge',
    weight = 5,
    stack = true,
    close = true,
    description = 'Ammunition cartridge',
    illegal = true
},

['thread'] = {
    label = 'Thread',
    weight = 10,
    stack = true,
    close = true,
    description = 'Metal thread for weapon attachments',
    illegal = true
},

-- Ammunition
['light_ammo'] = {
    label = 'Light Ammunition',
    weight = 50,
    stack = true,
    close = true,
    description = 'Ammunition for pistols and SMGs'
},

['heavy_ammo'] = {
    label = 'Heavy Ammunition',
    weight = 75,
    stack = true,
    close = true,
    description = 'Ammunition for rifles and heavy weapons'
},

-- Weapon Attachments
['compensator'] = {
    label = 'Compensator',
    weight = 100,
    stack = true,
    close = true,
    description = 'Weapon compensator attachment'
},

['clip_extended'] = {
    label = 'Extended Magazine',
    weight = 120,
    stack = true,
    close = true,
    description = 'Extended magazine attachment'
},

['scope'] = {
    label = 'Mk2 Scope',
    weight = 150,
    stack = true,
    close = true,
    description = 'Weapon scope attachment'
},

['suppressor'] = {
    label = 'Suppressor',
    weight = 130,
    stack = true,
    close = true,
    description = 'Weapon suppressor attachment'
},
    ['handcuffs'] = {
    label = 'Handcuffs',
    weight = 200,
    stack = false,
    close = true,
    description = 'Metal handcuffs used to restrain individuals',
    client = {
        image = 'handcuffs.png',
    }
},

['zipties'] = {
    label = 'Zip Ties',
    weight = 50,
    stack = true,
    close = true,
    description = 'Plastic zip ties for restraining',
    client = {
        image = 'zipties.png',
    }
},

['bolt_cutters'] = {
    label = 'Bolt Cutters',
    weight = 2000,
    stack = false,
    close = true,
    description = 'Heavy duty bolt cutters',
    client = {
        image = 'bolt_cutters.png',
    }
},

['cleaningkit'] = {
    label = 'Cleaning Kit',
    weight = 1000,
    stack = true,
    close = true,
    description = 'A kit for cleaning vehicles',
    client = {
        image = 'cleaningkit.png',
    }
},
    ['packed_outfit'] = {
      label = 'Packed Outfit',
      weight = 25,
      stack = false,
      close = true,
      description = 'A packed outfit ready to wear',
      client = {
          image = 'packed_outfit.png',
      },
      server = {
          export = 'illenium-appearance.usePackedOutfit'
      }
  },
    -- armor
    ['armor_light'] = {
      label = 'Light Armor Vest',
      weight = 3000,
      stack = true,          -- NOW STACKABLE
      close = true,
      description = 'Provides 50% protection. Durability: 100',
      client = {
          image = 'armor_light.png'
      },
      server = {
          export = 'drp-armor.useArmor'
      }
  },

  ['armor_heavy'] = {
      label = 'Heavy Armor Vest',
      weight = 8000,
      stack = true,          -- NOW STACKABLE
      close = true,
      description = 'Provides 100% protection. Durability: 100',
      client = {
          image = 'armor_heavy.png'
      },
      server = {
          export = 'drp-armor.useArmor'
      }
  },

  ['armor_police'] = {
      label = 'Police Tactical Armor',
      weight = 6000,
      stack = true,          -- NOW STACKABLE
      close = true,
      description = 'Provides 100% protection with enhanced durability. Durability: 170. Police only.',
      client = {
          image = 'armor_police.png'
      },
      server = {
          export = 'drp-armor.useArmor'
      }
  },

    ['testburger'] = {
        label = 'Test Burger',
        weight = 220,
        degrade = 60,
        client = {
            image = 'burger_chicken.png',
            status = { hunger = 200000 },
            anim = 'eating',
            prop = 'burger',
            usetime = 2500,
            export = 'ox_inventory_examples.testburger'
        },
        server = {
            export = 'ox_inventory_examples.testburger',
            test = 'what an amazingly delicious burger, amirite?'
        },
        buttons = {
            {
                label = 'Lick it',
                action = function(slot)
                    print('You licked the burger')
                end
            },
            {
                label = 'Squeeze it',
                action = function(slot)
                    print('You squeezed the burger :(')
                end
            },
            {
                label = 'What do you call a vegan burger?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('A misteak.')
                end
            },
            {
                label = 'What do frogs like to eat with their hamburgers?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('French flies.')
                end
            },
            {
                label = 'Why were the burger and fries running?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('Because they\'re fast food.')
                end
            }
        },
        consume = 0.3
    },

    ['bandage'] = {
        label = 'Bandage',
        weight = 115
    },

    ['burger'] = {
        label = 'Burger',
        weight = 220,
        client = {
            status = { hunger = 200000 },
            anim = 'eating',
            prop = 'burger',
            usetime = 2500,
            notification = 'You ate a delicious burger'
        },
    },

    ["megaphone"] = {
        label = "Megaphone",
        weight = 500,
        stack = false,
        close = true,
        description = "A usable megaphone"
    },

    ["ttt_teleporter"] = {
        label = "Teleporter Beacon",
        weight = 500,
        stack = false,
        close = true,
        consume = 0,
        description = "Advanced teleportation device. Place a beacon and teleport back to it when needed.",
        client = {
            image = "ttt_teleporter.png",
        },
        server = {
            export = 'sd-ttt.useTtt_teleporter'
        }
    },

    ["ttt_portable_tester"] = {
        label = "Portable DNA Scanner",
        weight = 300,
        stack = false,
        close = true,
        consume = 1,
        description = "Single-use device that can identify if a player is a traitor. Detective equipment only.",
        client = {
            image = "ttt_portable_tester.png",
        },
        server = {
            export = 'sd-ttt.useTtt_portable_tester'
        }
    },

    ["ttt_health_station"] = {
        label = "Health Station",
        weight = 1000,
        stack = false,
        close = true,
        consume = 1,
        description = "Deployable medical station that heals nearby innocents. Contains 200HP worth of healing.",
        client = {
            image = "ttt_health_station.png",
        },
        server = {
            export = 'sd-ttt.useTtt_health_station'
        }
    },

    ["ttt_c4"] = {
        label = "C4 Explosive",
        weight = 800,
        stack = true,
        close = true,
        consume = 1,
        description = "Remote detonated explosive with adjustable timer. Massive area damage. Traitor equipment.",
        client = {
            image = "ttt_c4.png",
        },
        server = {
            export = 'sd-ttt.useTtt_c4'
        }
    },

    ["ttt_defuser"] = {
        label = "Bomb Defuser Kit",
        weight = 200,
        stack = false,
        close = true,
        consume = 0,
        description = "Professional defusal kit that reduces bomb defuse time by 50%. Detective equipment.",
        client = {
            image = "ttt_defuser.png",
        },
        server = {
            export = 'sd-ttt.useTtt_defuser'
        }
    },

    ["ttt_radar"] = {
        label = "Player Radar",
        weight = 250,
        stack = false,
        close = true,
        consume = 0,
        description = "Shows all player positions for 5 seconds. 15 second cooldown between uses.",
        client = {
            image = "ttt_radar.png",
        },
        server = {
            export = 'sd-ttt.useTtt_radar'
        }
    },

    ["ttt_fake_id"] = {
        label = "Innocent ID Card",
        weight = 50,
        stack = false,
        close = true,
        consume = 1,
        description = "Shows as innocent when tested. Single use. Traitor equipment.",
        client = {
            image = "ttt_fake_id.png",
        },
        server = {
            export = 'sd-ttt.useTtt_fake_id'
        }
    },

    ["ttt_flare_gun"] = {
        label = "Flare Gun",
        weight = 400,
        stack = false,
        close = true,
        consume = 0,
        description = "Burns corpses to hide evidence. Single shot. Traitor equipment.",
        client = {
            image = "ttt_flare_gun.png",
        },
        server = {
            export = 'sd-ttt.useTtt_flare_gun'
        }
    },

    ["ttt_poison_smoke"] = {
        label = "Poison Smoke Grenade",
        weight = 300,
        stack = true,
        close = true,
        consume = 1,
        description = "Toxic gas grenade that damages over time. Area denial weapon. Traitor equipment.",
        client = {
            image = "ttt_poison_smoke.png",
        },
        server = {
            export = 'sd-ttt.useTtt_poison_smoke'
        }
    },

    ["ttt_dna_scanner"] = {
        label = "DNA Scanner",
        weight = 200,
        stack = false,
        close = true,
        consume = 0,
        description = "Scan corpses to find the killer's last location. Detective equipment.",
        client = {
            image = "ttt_dna_scanner.png",
        },
        server = {
            export = 'sd-ttt.useTtt_dna_scanner'
        }
    },

    ['sprunk'] = {
        label = 'Sprunk',
        weight = 350,
        client = {
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
            usetime = 2500,
            notification = 'You quenched your thirst with a sprunk'
        }
    },

    ['parachute'] = {
        label = 'Parachute',
        weight = 8000,
        stack = false,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 1500
        }
    },

    ['garbage'] = {
        label = 'Garbage',
    },

    ["bands"] = {
        label = "Band Of Notes",
        weight = 100,
        stack = true,
        close = false,
        description = "A band of small notes..",
        consume = 0,
        client = {
            image = "bands.png",
        }
    },

    ["rolls"] = {
        label = "Roll Of Small Notes",
        weight = 100,
        stack = true,
        close = false,
        description = "A roll of small notes..",
        consume = 0,
        client = {
            image = "rolls.png",
        }
    },

    ["fleeca_case"] = {
        label = "Fleeca Bank Case",
        weight = 2000,
        stack = true,
        close = true,
        description = "A mysterious case from a Fleeca Bank heist. Contains random loot.",
        consume = 0,
        client = {
            image = "case_1.png",
        },
        server = {
            export = 'sd-cases.useFleeca_case',
        }
    },

    ["house_case"] = {
        label = "House Robbery Case",
        weight = 2000,
        stack = true,
        close = true,
        description = "A case filled with items from house burglaries. Contents unknown.",
        consume = 0,
        client = {
            image = "case_2.png",
        },
        server = {
            export = 'sd-cases.useHouse_case',
        }
    },

    ["chopshop_case"] = {
        label = "Chop Shop Case",
        weight = 2500,
        stack = true,
        close = true,
        description = "A case containing random car parts from the chop shop.",
        consume = 0,
        client = {
            image = "case_3.png",
        },
        server = {
            export = 'sd-cases.useChopshop_case',
        }
    },

    ["jewelry_case"] = {
        label = "Jewelry Store Case",
        weight = 1500,
        stack = true,
        close = true,
        description = "A luxury case from Vangelico's. May contain valuable jewelry.",
        consume = 0,
        client = {
            image = "case_4.png",
        },
        server = {
            export = 'sd-cases.useJewelry_case',
        }
    },

    ["pacific_case"] = {
        label = "Pacific Bank Case",
        weight = 3000,
        stack = true,
        close = true,
        description = "A high-security case from the Pacific Standard vault. Extremely valuable.",
        consume = 0,
        client = {
            image = "case_5.png",
        },
        server = {
            export = 'sd-cases.usePacific_case',
        }
    },

    ["casino_case"] = {
        label = "Casino Heist Case",
        weight = 2500,
        stack = true,
        close = true,
        description = "A case stolen from the Diamond Casino vault. Contains premium loot.",
        consume = 0,
        client = {
            image = "case_6.png",
        },
        server = {
            export = 'sd-cases.useCasino_case',
        }
    },

    ["package"] = {
        label = "Suspicious Package",
        weight = 10000,
        stack = false,
        close = false,
        description = "A mysterious package.. Scary!",
        consume = 0,
        client = {
            image = "package.png",
        }
    },

    ['hunting_bait_1'] = {
        label = 'Basic Bait',
        weight = 150,
        stack = true,
        close = true,
        description = 'Simple grain mixture - takes 3-5 minutes to attract nearby wildlife',
        client = {
            image = 'hunting_bait_1.png',
        },
        server = {
            export = 'sd-civjobs.useHuntingBait'
        }
    },

    ['hunting_bait_2'] = {
        label = 'Scented Bait',
        weight = 200,
        stack = true,
        close = true,
        description = 'Aromatic blend with natural scents - attracts animals in 2-4 minutes',
        client = {
            image = 'hunting_bait_2.png',
        },
        server = {
            export = 'sd-civjobs.useHuntingBait'
        }
    },

    ['hunting_bait_3'] = {
        label = 'Premium Bait',
        weight = 250,
        stack = true,
        close = true,
        description = 'Enhanced formula with pheromones - draws wildlife within 1-3 minutes',
        client = {
            image = 'hunting_bait_3.png',
        },
        server = {
            export = 'sd-civjobs.useHuntingBait'
        }
    },

    ['hunting_bait_4'] = {
        label = 'Professional Bait',
        weight = 300,
        stack = true,
        close = true,
        description = 'Concentrated attractant blend - animals respond in 30-90 seconds',
        client = {
            image = 'hunting_bait_4.png',
        },
        server = {
            export = 'sd-civjobs.useHuntingBait'
        }
    },

    ['hunting_bait_5'] = {
        label = 'Master Hunter Bait',
        weight = 350,
        stack = true,
        close = true,
        description = 'Irresistible expert formula - instant attraction within 15-45 seconds',
        client = {
            image = 'hunting_bait_5.png',
        },
        server = {
            export = 'sd-civjobs.useHuntingBait'
        }
    },

    -- Deer Carcass Items (3 tiers)
    ['carcass_1'] = {
        label = 'Poor Deer Carcass',
        weight = 2000,
        stack = true,
        close = true,
        description = 'Low quality deer carcass - damaged during hunt',
        client = {
            image = 'carcass_1.png',
        }
    },

    ['carcass_2'] = {
        label = 'Good Deer Carcass',
        weight = 2500,
        stack = true,
        close = true,
        description = 'Good quality deer carcass - cleanly hunted',
        client = {
            image = 'carcass_2.png',
        }
    },

    ['carcass_3'] = {
        label = 'Perfect Deer Carcass',
        weight = 3000,
        stack = true,
        close = true,
        description = 'Pristine deer carcass - expertly hunted',
        client = {
            image = 'carcass_3.png',
        }
    },

    -- Mountain Lion Carcass Items (3 tiers)
    ['redcarcass_1'] = {
        label = 'Poor Mountain Lion Carcass',
        weight = 3000,
        stack = true,
        close = true,
        description = 'Low quality mountain lion carcass - damaged pelt',
        client = {
            image = 'redcarcass_1.png',
        }
    },

    ['redcarcass_2'] = {
        label = 'Good Mountain Lion Carcass',
        weight = 3500,
        stack = true,
        close = true,
        description = 'Good quality mountain lion carcass - valuable game',
        client = {
            image = 'redcarcass_2.png',
        }
    },

    ['redcarcass_3'] = {
        label = 'Perfect Mountain Lion Carcass',
        weight = 4000,
        stack = true,
        close = true,
        description = 'Pristine mountain lion carcass - trophy quality',
        client = {
            image = 'redcarcass_3.png',
        }
    },

    -- Single tier items (no quality variations)
    ['deerhide'] = {
        label = 'Deer Hide',
        weight = 800,
        stack = true,
        close = true,
        description = 'Quality deer hide suitable for leather crafting',
        client = {
            image = 'deerhide.png',
        }
    },

    ['antlers'] = {
        label = 'Deer Antlers',
        weight = 600,
        stack = true,
        close = true,
        description = 'Pristine deer antlers - valuable trophy item',
        client = {
            image = 'antlers.png',
        }
    },

    ['mtlionpelt'] = {
        label = 'Mountain Lion Pelt',
        weight = 1200,
        stack = true,
        close = true,
        description = 'Rare mountain lion pelt - highly valued by traders',
        client = {
            image = 'mtlionpelt.png',
        }
    },

    ['mtlionfang'] = {
        label = 'Mountain Lion Fangs',
        weight = 150,
        stack = true,
        close = true,
        description = 'Sharp predator fangs - prized collector item',
        client = {
            image = 'mtlionfang.png',
        }
    },

    ['coyotepelt'] = {
        label = 'Coyote Pelt',
        weight = 600,
        stack = true,
        close = true,
        description = 'Warm coyote fur pelt - good for crafting',
        client = {
            image = 'coyotepelt.png',
        }
    },

    ['boarmeat'] = {
        label = 'Wild Boar Meat',
        weight = 1800,
        stack = true,
        close = true,
        description = 'Fresh wild boar meat - a hearty game meat',
        client = {
            image = 'boarmeat.png',
        }
    },


    ['paperbag'] = {
        label = 'Paper Bag',
        weight = 1,
        stack = false,
        close = false,
        consume = 0
    },

    ['panties'] = {
        label = 'Knickers',
        weight = 10,
        consume = 0,
        client = {
            status = { thirst = -100000, stress = -25000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
            usetime = 2500,
        }
    },

    ['lockpick'] = {
        label = 'Lockpick',
        weight = 160
    },

    ['phone'] = {
        label = 'Phone',
        weight = 190,
        stack = false,
        consume = 0,
        client = {
            add = function(total)
                if total > 0 then
                    pcall(function() return exports.npwd:setPhoneDisabled(false) end)
                end
            end,

            remove = function(total)
                if total < 1 then
                    pcall(function() return exports.npwd:setPhoneDisabled(true) end)
                end
            end
        }
    },

    ['mustard'] = {
        label = 'Mustard',
        weight = 500,
        client = {
            status = { hunger = 25000, thirst = 25000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_food_mustard`, pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
            usetime = 2500,
            notification = 'You... drank mustard'
        }
    },

    ['water'] = {
        label = 'Water',
        weight = 500,
        client = {
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
            usetime = 2500,
            cancel = true,
            notification = 'You drank some refreshing water'
        }
    },

    ['armour'] = {
        label = 'Bulletproof Vest',
        weight = 3000,
        stack = false,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 3500
        }
    },

    ['clothing'] = {
        label = 'Clothing',
        consume = 0,
    },

    ['money'] = {
        label = 'Money'
    },

    ['black_money'] = {
        label = 'Dirty Money'
    },

    ['id_card'] = {
        label = 'Identification Card',
    },

    ["metaldetector_1"] = {
        label = "Basic Metal Detector",
        weight = 2500,
        stack = false,
        close = true,
        consume = 0,
        description = "Entry-level detector with 5m range and 60% accuracy. Use to start detecting metals.",
        client = {
            image = "metaldetector_1.png",
        },
        server = {
            export = 'sd-civjobs.useMetalDetector'
        }
    },

    ["metaldetector_2"] = {
        label = "Amateur Metal Detector",
        weight = 2300,
        stack = false,
        close = true,
        consume = 0,
        description = "Improved detector with 7m range and 70% accuracy. Use to start detecting metals.",
        client = {
            image = "metaldetector_2.png",
        },
        server = {
            export = 'sd-civjobs.useMetalDetector'
        }
    },

    ["metaldetector_3"] = {
        label = "Professional Metal Detector",
        weight = 2100,
        stack = false,
        close = true,
        consume = 0,
        description = "Professional-grade detector with 9m range and 80% accuracy. Use to start detecting metals.",
        client = {
            image = "metaldetector_3.png",
        },
        server = {
            export = 'sd-civjobs.useMetalDetector'
        }
    },

    ["metaldetector_4"] = {
        label = "Advanced Metal Detector",
        weight = 2000,
        stack = false,
        close = true,
        consume = 0,
        description = "Advanced detector with 11m range and 90% accuracy. Use to start detecting metals.",
        client = {
            image = "metaldetector_4.png",
        },
        server = {
            export = 'sd-civjobs.useMetalDetector'
        }
    },

    ["metaldetector_5"] = {
        label = "Elite Metal Detector",
        weight = 1800,
        stack = false,
        close = true,
        consume = 0,
        description = "Top-tier detector with 13m range and 95% accuracy. Use to start detecting metals.",
        client = {
            image = "metaldetector_5.png",
        },
        server = {
            export = 'sd-civjobs.useMetalDetector'
        }
    },

    ["detecting_shovel"] = {
        label = "Shovel",
        weight = 1500,
        stack = false,
        close = true,
        consume = 0,
        description = "High-quality shovel for metal detecting excavations.",
        client = {
            image = "detecting_shovel.png",
        }
    },

    ['md_brokenjunk'] = {
		label = 'Broken Junk',
		weight = 25
	},

	['md_crushedcan'] = {
		label = 'Crushed Can',
		weight = 25
	},

	['md_lighter'] = {
		label = 'Lighter',
		weight = 25
	},

	['md_metalcan'] = {
		label = 'Metal Can',
		weight = 25
	},

	['md_nails'] = {
		label = 'Nails',
		weight = 25
	},

	['md_needle'] = {
		label = 'Needle',
		weight = 25
	},

	['md_nickle'] = {
		label = 'Nickle',
		weight = 25
	},

	['md_nut'] = {
		label = 'Nut',
		weight = 25
	},

	['md_oldshotgunshell'] = {
		label = 'Old Shotgun Shell',
		weight = 25
	},

	['md_paperclip'] = {
		label = 'Paper Clip',
		weight = 25
	},

	['md_pulltab'] = {
		label = 'Pull Tab',
		weight = 25
	},

	['md_quarter'] = {
		label = 'Quarter',
		weight = 25
	},

	['md_rustyball'] = {
		label = 'Rusty Ball',
		weight = 25
	},

	['md_rustyironball'] = {
		label = 'Rusty Iron Ball',
		weight = 25
	},

	['md_rustyjunk'] = {
		label = 'Rusty Junk',
		weight = 25
	},

	['md_rustynails'] = {
		label = 'Rusty Nails',
		weight = 25
	},

	['md_rustypliers'] = {
		label = 'Rusty Pliers',
		weight = 25
	},

	['md_rustyring'] = {
		label = 'Rusty Ring',
		weight = 25
	},

	['md_rustyscissors'] = {
		label = 'Rusty Scissors',
		weight = 25
	},

	['md_rustyscrewdriver'] = {
		label = 'Rusty Screwdriver',
		weight = 25
	},

	['md_rustyspring'] = {
		label = 'Rusty Spring',
		weight = 25
	},

	['md_screw'] = {
		label = 'Screw',
		weight = 25
	},

	['md_wheatpenny'] = {
		label = 'Wheat Penny',
		weight = 25
	},

	['md_ancientcoin'] = {
		label = 'Ancient Coin',
		weight = 25
	},

	['md_blackwatch'] = {
		label = 'Watch',
		weight = 25
	},

	['md_coppernugget'] = {
		label = 'Copper Nugget',
		weight = 25
	},

	['md_diamondearings'] = {
		label = 'Diamond Earings',
		weight = 25
	},

	['md_diamondnecklace'] = {
		label = 'Diamond Necklace',
		weight = 25
	},

	['md_diamondring'] = {
		label = 'Diamond Ring',
		weight = 25
	},

	['md_earpod'] = {
		label = 'Ear Pod',
		weight = 25
	},

	['md_golddollar'] = {
		label = 'Gold Dollar',
		weight = 25
	},

	['md_goldearings'] = {
		label = 'Gold Earings',
		weight = 25
	},

	['md_goldnecklace'] = {
		label = 'Gold Necklace',
		weight = 25
	},

	['md_goldnugget'] = {
		label = 'Gold Nugget',
		weight = 25
	},

	['md_goldounce'] = {
		label = '1oz Gold Bar',
		weight = 25
	},

	['md_goldring'] = {
		label = 'Gold Ring',
		weight = 25
	},

	['md_halfdollar'] = {
		label = 'Half Dollar',
		weight = 25
	},

	['md_ironnugget'] = {
		label = 'Iron Nugget',
		weight = 25
	},

	['md_platinumnugget'] = {
		label = 'Platinum Nugget',
		weight = 25
	},

	['md_presidentialwatch'] = {
		label = 'Presidential Watch',
		weight = 25
	},

	['md_relicrevolver'] = {
		label = 'Relic Revolver',
		weight = 25
	},

	['md_silverdime'] = {
		label = 'Silver Dime',
		weight = 25
	},

	['md_silverearings'] = {
		label = 'Silver Earings',
		weight = 25
	},

	['md_silverounce'] = {
		label = '1oz Silver Bar',
		weight = 25
	},

	['md_silverring'] = {
		label = 'Silver Ring',
		weight = 25
	},

    ['driver_license'] = {
        label = 'Drivers License',
    },

    ['weaponlicense'] = {
        label = 'Weapon License',
    },

    ['lawyerpass'] = {
        label = 'Lawyer Pass',
    },

    ["bee-smoker"] = {
        label       = "Bee Smoker",
        weight      = 1500,
        stack       = false,
        description = "A handheld smoker used to calm bees, making bee management safer and easier.",
        consume     = 0,
        client = {
            image = "bee-smoker.png",
        }
    },

    ["bee-hive"] = {
        label = "Bee Hive",
        weight = 1000,
        stack = false,
        close = true,
        description = "",
        consume = 0,
        client = {
            image = "bee-hive.png",
        },
        server = {
            export = 'sd-beekeeping.useBee-hive',
        }
    },

    -- Bee Honey (Basic)
    ["bee-honey"] = {
        label = "Bee Honey",
        weight = 1000,
        stack = true,
        close = true,
        description = "Pure honey harvested directly from the hive, rich in natural sweetness.",
        consume = 0,
        client = {
            image = "bee-honey.png",
        }
    },

    -- Chiliad Honey
    ["chiliad-honey"] = {
        label = "Chiliad Honey",
        weight = 1000,
        stack = true,
        close = true,
        description = "A robust honey infused with the essence of Chiliad's wild flora.",
        consume = 0,
        client = {
            image = "chiliad-honey.png",
        }
    },

    -- Green Hills Honey
    ["green-hills-honey"] = {
        label = "Green Hills Honey",
        weight = 1000,
        stack = true,
        close = true,
        description = "Delicate honey crafted from the abundant clover fields of Green Hills.",
        consume = 0,
        client = {
            image = "green-hills-honey.png",
        }
    },

    -- Alamo Honey
    ["alamo-honey"] = {
        label = "Alamo Honey",
        weight = 1000,
        stack = true,
        close = true,
        description = "Exquisite honey sourced from the serene Alamo Grove, known for its unique taste.",
        consume = 0,
        client = {
            image = "alamo-honey.png",
        }
    },

    -- Bee Wax
    ["bee-wax"] = {
        label = "Bee Wax",
        weight = 500,
        stack = true,
        close = true,
        description = "Versatile beeswax, perfect for crafting candles, cosmetics, and artisanal goods.",
        consume = 0,
        client = {
            image = "bee-wax.png",
        }
    },

    ["bee-house"] = {
        label = "Bee House",
        weight = 1000,
        stack = false,
        close = true,
        description = "",
        consume = 0,
        client = {
            image = "bee-house.png",
        },
        server = {
            export = 'sd-beekeeping.useBee-house',
        }
    },

    ["bee-queen"] = {
        label = "Bee Queen",
        weight = 1000,
        stack = true,
        close = true,
        description = "",
        consume = 0,
        client = {
            image = "bee-queen.png",
        }
    },

    ["bee-worker"] = {
        label = "Worker Bee",
        weight = 1000,
        stack = true,
        close = true,
        description = "",
        consume = 0,
        client = {
            image = "bee-worker.png",
        }
    },

    ["thymol"] = {
        label = "Thymol",
        weight = 500,
        stack = true,
        close = true,
        description = "A natural treatment derived from thyme oil, effective in combating hive infections and supporting bee health.",
        consume = 0,
        client = {
            image = "thymol.png",
        }
    },

    ["yachtcodes"] = {
        label = "Yacht Access Codes",
        weight = 200,
        stack = false,
        close = true,
        description = "The first half of codes for the Yacht",
        consume = 0,
        client = {
            image = "yachtcodes.png",
        },
        server = {
            export = 'sd-yacht.useYachtcodes',
        }
    },

    ["casinocodes"] = {
        label = "Casino Access Codes",
        weight = 200,
        stack = false,
        close = true,
        description = "The first half of codes for the Casino",
        consume = 0,
        client = {
            image = "casinocodes.png",
        },
        server = {
            export = 'sd-yacht.useCasinocodes',
        }
    },

    ["secured_safe"] = {
        label = "Safe",
        weight = 200,
        stack = false,
        close = true,
        description = "Meant to protect valuables",
        consume = 0,
        client = {
            image = "secured_safe.png",
        },
    },

    ["expensive_champagne"] = {
        label = "Champagne",
        weight = 200,
        stack = true,
        close = true,
        description = "A sparkling wine from France",
        consume = 0,
        client = {
            image = "expensive_champagne.png",
        },
    },

    ["default_gateway_override"] = {
        label = "Gateway Override",
        weight = 200,
        stack = false,
        close = true,
        description = "A default gateway override on a usb",
        consume = 0,
        client = {
            image = "default_gateway_override.png",
        },
    },

    ['prescription'] = {
		label = 'Prescription',
		weight = 300,
		stack = false,
		close = true,
		description = "A piece of paper used for pharmacies"
	},
	['prescriptionpad'] = {
		label = 'Prescription Pad',
		weight = 300,
		stack = false,
		close = true,
		description = "A prescription pad used by doctors to write prescriptions"
	},

    ["revivekit"] = {
        label = "Revival Kit",
        weight = 3000,
        stack = false,
        close = false,
        description = "When your pal needs that pick me up",
        consume = 0,
        client = {
            image = "revivekit.png",
        },
        server = {
            export = 'sd-yacht.useRevivekit',
        }
    },


    ['radio'] = {
        label = 'Radio',
        weight = 1000,
        allowArmed = true,
        consume = 0,
        client = {
            event = 'mm_radio:client:use'
        }
    },

    ['jammer'] = {
        label = 'Radio Jammer',
        weight = 10000,
        allowArmed = true,
        client = {
            event = 'mm_radio:client:usejammer'
        }
    },

    ['radiocell'] = {
        label = 'AAA Cells',
        weight = 1000,
        stack = true,
        allowArmed = true,
        client = {
            event = 'mm_radio:client:recharge'
        }
    },

    ['advancedlockpick'] = {
        label = 'Advanced Lockpick',
        weight = 500,
    },

    ['screwdriverset'] = {
        label = 'Screwdriver Set',
        weight = 500,
    },

    ['electronickit'] = {
        label = 'Electronic Kit',
        weight = 500,
    },

    ['cleaningkit'] = {
        label = 'Cleaning Kit',
        weight = 500,
    },

    ['repairkit'] = {
        label = 'Repair Kit',
        weight = 2500,
    },

    ['advancedrepairkit'] = {
        label = 'Advanced Repair Kit',
        weight = 4000,
    },

    ['diamond_ring'] = {
        label = 'Diamond',
        weight = 1500,
    },

    ['rolex'] = {
        label = 'Golden Watch',
        weight = 1500,
    },

    ['goldbar'] = {
        label = 'Gold Bar',
        weight = 1500,
    },

    ['goldchain'] = {
        label = 'Golden Chain',
        weight = 1500,
    },

    ['crack_baggy'] = {
        label = 'Crack Baggy',
        weight = 100,
    },

    ['cokebaggy'] = {
        label = 'Bag of Coke',
        weight = 100,
    },

    ['coke_brick'] = {
        label = 'Coke Brick',
        weight = 2000,
    },

    ['coke_small_brick'] = {
        label = 'Coke Package',
        weight = 1000,
    },

    ['xtcbaggy'] = {
        label = 'Bag of Ecstasy',
        weight = 100,
    },

    ['meth'] = {
        label = 'Methamphetamine',
        weight = 100,
    },

    ['oxy'] = {
        label = 'Oxycodone',
        weight = 100,
    },

    ['weed_ak47'] = {
        label = 'AK47 2g',
        weight = 200,
    },

    ['weed_ak47_seed'] = {
        label = 'AK47 Seed',
        weight = 1,
    },

    ['weed_skunk'] = {
        label = 'Skunk 2g',
        weight = 200,
    },

    ['weed_skunk_seed'] = {
        label = 'Skunk Seed',
        weight = 1,
    },

    ['weed_amnesia'] = {
        label = 'Amnesia 2g',
        weight = 200,
    },

    ['weed_amnesia_seed'] = {
        label = 'Amnesia Seed',
        weight = 1,
    },

    ['weed_og-kush'] = {
        label = 'OGKush 2g',
        weight = 200,
    },

    ['weed_og-kush_seed'] = {
        label = 'OGKush Seed',
        weight = 1,
    },

    ['weed_white-widow'] = {
        label = 'OGKush 2g',
        weight = 200,
    },

    ['weed_white-widow_seed'] = {
        label = 'White Widow Seed',
        weight = 1,
    },

    ['weed_purple-haze'] = {
        label = 'Purple Haze 2g',
        weight = 200,
    },

    ['weed_purple-haze_seed'] = {
        label = 'Purple Haze Seed',
        weight = 1,
    },

    ['weed_brick'] = {
        label = 'Weed Brick',
        weight = 2000,
    },

    ["wood"] = {
        label = "Wood",
        weight = 500,
        stack = true,
        close = false,
        consume = 0,
        description = "A piece of raw wood that can be processed into planks.",
        client = {
            image = "wood.png",
        }
    },

    ["powersaw"] = {
        label = "Power Saw",
        weight = 2000,
        stack = false,
        close = false,
        consume = 0,
        description = "A powerful electric saw used for cutting trees and logs.",
        client = {
            image = "powersaw.png",
        }
    },

    ['wood_planks'] = {
        label = 'Wood Planks',
        weight = 90,
        stack = true,
        close = false,
        consume = 0,
        description = 'Several short, rough-cut wooden planks. Useful for repairs or crafting.',
        client = {
            image = "wood_planks.png",
        }
    },

    ['weed_nutrition'] = {
        label = 'Plant Fertilizer',
        weight = 2000,
    },

    ['joint'] = {
        label = 'Joint',
        weight = 200,
    },

    ['rolling_paper'] = {
        label = 'Rolling Paper',
        weight = 0,
    },

    ['empty_weed_bag'] = {
        label = 'Empty Weed Bag',
        weight = 0,
    },

    ['firstaid'] = {
        label = 'First Aid',
        weight = 2500,
    },

    ['ifaks'] = {
        label = 'Individual First Aid Kit',
        weight = 2500,
    },

    ['painkillers'] = {
        label = 'Painkillers',
        weight = 400,
    },

    ['firework1'] = {
        label = '2Brothers',
        weight = 1000,
    },

    ['firework2'] = {
        label = 'Poppelers',
        weight = 1000,
    },

    ['firework3'] = {
        label = 'WipeOut',
        weight = 1000,
    },

    ['firework4'] = {
        label = 'Weeping Willow',
        weight = 1000,
    },

    ['steel'] = {
        label = 'Steel',
        weight = 100,
    },

    ['rubber'] = {
        label = 'Rubber',
        weight = 100,
    },

    ['metalscrap'] = {
        label = 'Metal Scrap',
        weight = 100,
    },

    ['iron'] = {
        label = 'Iron',
        weight = 100,
    },

    ['copper'] = {
        label = 'Copper',
        weight = 100,
    },

    ['aluminium'] = {
        label = 'Aluminium',
        weight = 100,
    },

    ['plastic'] = {
        label = 'Plastic',
        weight = 100,
    },

    ['glass'] = {
        label = 'Glass',
        weight = 100,
    },

    ['gatecrack'] = {
        label = 'Gatecrack',
        weight = 1000,
    },

    ['cryptostick'] = {
        label = 'Crypto Stick',
        weight = 100,
    },

    ['trojan_usb'] = {
        label = 'Trojan USB',
        weight = 100,
    },

    ['toaster'] = {
        label = 'Toaster',
        weight = 5000,
    },

    ['small_tv'] = {
        label = 'Small TV',
        weight = 100,
    },

    ['security_card_01'] = {
        label = 'Security Card A',
        weight = 100,
    },

    ['security_card_02'] = {
        label = 'Security Card B',
        weight = 100,
    },

    ['drill'] = {
        label = 'Drill',
        weight = 5000,
    },

    ['thermite'] = {
        label = 'Thermite',
        weight = 1000,
    },

    ["flower"] = {
        label = "Fresh Flower",
        weight = 50,
        stack = true,
        close = true,
        consume = 0,
        description = "A beautiful fresh flower picked from the garden. Can be used for decoration or sold.",
        client = {
            image = "flower.png",
        }
    },

-- Add this to your regular items.lua (or replace if they already exist)
["diving_gear_1"] = {
    label = "Basic Scuba Gear",
    weight = 1000,
    stack = false,
    close = true,
    consume = 0,
    description = "Basic diving equipment with 120 seconds of oxygen. Use to put on diving suit.",
    client = {
        image = "diving_gear_1.png",
    },
    server = {
        export = 'sd-civjobs.useDivingGear'
    }
},

["diving_gear_2"] = {
    label = "Improved Scuba Gear",
    weight = 1000,
    stack = false,
    close = true,
    consume = 0,
    description = "Improved diving equipment with 180 seconds of oxygen. Use to put on diving suit.",
    client = {
        image = "diving_gear_2.png",
    },
    server = {
        export = 'sd-civjobs.useDivingGear'
    }
},

["diving_gear_3"] = {
    label = "Advanced Scuba Gear",
    weight = 1000,
    stack = false,
    close = true,
    consume = 0,
    description = "Advanced diving equipment with 240 seconds of oxygen. Use to put on diving suit.",
    client = {
        image = "diving_gear_3.png",
    },
    server = {
        export = 'sd-civjobs.useDivingGear'
    }
},

["diving_gear_4"] = {
    label = "Professional Scuba Gear",
    weight = 1000,
    stack = false,
    close = true,
    consume = 0,
    description = "Professional diving equipment with 300 seconds of oxygen. Use to put on diving suit.",
    client = {
        image = "diving_gear_4.png",
    },
    server = {
        export = 'sd-civjobs.useDivingGear'
    }
},

["diving_gear_5"] = {
    label = "Elite Scuba Gear",
    weight = 1000,
    stack = false,
    close = true,
    consume = 0,
    description = "Elite diving equipment with 360 seconds of oxygen. Use to put on diving suit.",
    client = {
        image = "diving_gear_5.png",
    },
    server = {
        export = 'sd-civjobs.useDivingGear'
    }
},

    ["diving_fill"] = {
        label = "Diving Tube",
        weight = 1000,
        stack = false,
        close = true,
        consume = 0,
        description = "Refill your oxygen tank with this diving tube.",
        client = {
            image = "diving_tube.png",
        },
        server = {
            export = 'sd-civjobs.useDivingFill'
        }
    },

    ["welding_torch"] = {
        label = "Welding Torch",
        weight = 2000,
        stack = false,
        close = true,
        consume = 0,
        description = "Professional welding torch for electrical repairs. Use near electrical equipment.",
        client = {
            image = "welding_torch.png",
        },
        server = {
            export = 'sd-civjobs.useWeldingTorch'
        }
    },

    ["diving_crate"] = {
        label = "Diving Crate",
        weight = 500,
        stack = true,
        close = true,
        consume = 0,
        description = "A mysterious crate found while diving. Use to open and discover its contents.",
        client = {
            image = "diving_crate.png",
        },
        server = {
            export = 'sd-civjobs.openDivingCrate'
        }
    },
    ["garden_shovel"] = {
        label = "Garden Shovel",
        weight = 500,
        stack = true,
        close = true,
        consume = 0,
        description = "A sturdy garden shovel required for picking flowers. Essential tool for florist work.",
        client = {
            image = "garden_shovel.png",
        }
    },

    ["rose"] = {
        label = "Rose",
        weight = 40,
        stack = true,
        close = true,
        consume = 0,
        description = "A beautiful red rose with a sweet fragrance. A classic symbol of love and romance.",
        client = {
            image = "flowers.png",
        }
    },

    ["tulip"] = {
        label = "Tulip",
        weight = 35,
        stack = true,
        close = true,
        consume = 0,
        description = "A colorful tulip flower. Perfect for brightening up any space.",
        client = {
            image = "flowers.png",
        }
    },

    ["sunflower"] = {
        label = "Sunflower",
        weight = 60,
        stack = true,
        close = true,
        consume = 0,
        description = "A large, bright sunflower that always faces the sun. Symbol of happiness and positivity.",
        client = {
            image = "flowers.png",
        }
    },

    ["lily"] = {
        label = "Lily",
        weight = 45,
        stack = true,
        close = true,
        consume = 0,
        description = "An elegant lily flower with a delicate fragrance. Often used in formal arrangements.",
        client = {
            image = "flowers.png",
        }
    },

    ["orchid"] = {
        label = "Orchid",
        weight = 30,
        stack = true,
        close = true,
        consume = 0,
        description = "A rare and exotic orchid. Highly prized by collectors and florists.",
        client = {
            image = "flowers.png",
        }
    },

    ['antipatharia_coral'] = {
        label = 'Antipatharia',
        weight = 1000,
    },

    ['dendrogyra_coral'] = {
        label = 'Dendrogyra',
        weight = 1000,
    },

    ['jerry_can'] = {
        label = 'Jerrycan',
        weight = 3000,
    },

    ['nitrous'] = {
        label = 'Nitrous',
        weight = 1000,
    },

    ['wine'] = {
        label = 'Wine',
        weight = 500,
    },

    ['grape'] = {
        label = 'Grape',
        weight = 10,
    },

    ['grapejuice'] = {
        label = 'Grape Juice',
        weight = 200,
    },

    ['coffee'] = {
        label = 'Coffee',
        weight = 200,
    },

    ['vodka'] = {
        label = 'Vodka',
        weight = 500,
    },

    ['whiskey'] = {
        label = 'Whiskey',
        weight = 200,
    },

    ['beer'] = {
        label = 'beer',
        weight = 200,
    },

    ['sandwich'] = {
        label = 'beer',
        weight = 200,
    },

    ['walking_stick'] = {
        label = 'Walking Stick',
        weight = 1000,
    },

    ['lighter'] = {
        label = 'Lighter',
        weight = 200,
    },

    ['stickynote'] = {
        label = 'Sticky Note',
        weight = 0,
    },

    ['empty_evidence_bag'] = {
        label = 'Empty Evidence Bag',
        weight = 200,
    },

    ['filled_evidence_bag'] = {
        label = 'Filled Evidence Bag',
        weight = 200,
    },

    ['harness'] = {
        label = 'Harness',
        weight = 200,
    },

    ['handcuffs'] = {
        label = 'Handcuffs',
        weight = 200,
    },

["workbench"] = {
    label = "Basic Workbench",
    weight = 5000,
    stack = false,
    close = true,
    description = "A small workbench for crafting basic stuff.",
    consume = 0,
    client = {
        image = "workbench.png",
    },
    server = {
        export = 'sd-crafting.useWorkbench',
    }
},

["advanced_workbench"] = {
    label = "Advanced Workbench",
    weight = 10000,
    stack = false,
    close = true,
    description = "A high-tech workbench with advanced crafting capabilities.",
    consume = 0,
    client = {
        image = "advanced_workbench.png",
    },
    server = {
        export = 'sd-crafting.useAdvanced_workbench',
    }
},

-- Crafting Blueprints
["blueprint_advancedlockpick"] = {
    label = "Advanced Lockpick Blueprint",
    weight = 100,
    stack = true,
    close = true,
    description = "A blueprint containing instructions for crafting an advanced lockpick. Add to crafting inventory to unlock the recipe.",
    consume = 0,
    client = {
        image = "blueprint_advancedlockpick.png",
    }
},

	["alive_chicken"] = {
		label = "Living chicken",
		weight = 1,
		stack = true,
		close = true,
	},

	["blowpipe"] = {
		label = "Blowtorch",
		weight = 2,
		stack = true,
		close = true,
	},

	["bread"] = {
		label = "Bread",
		weight = 1,
		stack = true,
		close = true,
	},

	["cannabis"] = {
		label = "Cannabis",
		weight = 3,
		stack = true,
		close = true,
	},

	["carokit"] = {
		label = "Body Kit",
		weight = 3,
		stack = true,
		close = true,
	},

	["carotool"] = {
		label = "Tools",
		weight = 2,
		stack = true,
		close = true,
	},

	["clothe"] = {
		label = "Cloth",
		weight = 1,
		stack = true,
		close = true,
	},

	["cutted_wood"] = {
		label = "Cut wood",
		weight = 1,
		stack = true,
		close = true,
	},

	["diamond"] = {
		label = "Diamond",
		weight = 1,
		stack = true,
		close = true
	},

	["essence"] = {
		label = "Gas",
		weight = 1,
		stack = true,
		close = true,
	},

	["fabric"] = {
		label = "Fabric",
		weight = 1,
		stack = true,
		close = true,
	},

	["fish"] = {
		label = "Fish",
		weight = 1,
		stack = true,
		close = true,
	},

	["fixkit"] = {
		label = "Repair Kit",
		weight = 3,
		stack = true,
		close = true,
	},

	["fixtool"] = {
		label = "Repair Tools",
		weight = 2,
		stack = true,
		close = true,
	},

	["gazbottle"] = {
		label = "Gas Bottle",
		weight = 2,
		stack = true,
		close = true,
	},

	["gold"] = {
		label = "Gold",
		weight = 1,
		stack = true,
		close = true,
	},

	["marijuana"] = {
		label = "Marijuana",
		weight = 2,
		stack = true,
		close = true,
	},

	["medikit"] = {
		label = "Medikit",
		weight = 2,
		stack = true,
		close = true,
	},

	["packaged_chicken"] = {
		label = "Chicken fillet",
		weight = 1,
		stack = true,
		close = true,
	},

	["packaged_plank"] = {
		label = "Packaged wood",
		weight = 1,
		stack = true,
		close = true,
	},

	["petrol"] = {
		label = "Oil",
		weight = 1,
		stack = true,
		close = true,
	},

	["petrol_raffin"] = {
		label = "Processed oil",
		weight = 1,
		stack = true,
		close = true,
	},

	["slaughtered_chicken"] = {
		label = "Slaughtered chicken",
		weight = 1,
		stack = true,
		close = true,
	},

	["stone"] = {
		label = "Stone",
		weight = 1,
		stack = true,
		close = true,
	},

	["washed_stone"] = {
		label = "Washed stone",
		weight = 1,
		stack = true,
		close = true,
	},

	["wool"] = {
		label = "Wool",
		weight = 1,
		stack = true,
		close = true,
	},

	["mastercard"] = {
		label = "Bank Card",
		weight = 0,
		stack = false,
		close = true,
		consume = 0,
		description = "A bank card linked to your account.",
		client = {
			image = "mastercard.png",
			export = "pefcl.useCard",
		}
	},
    --mechanics
     ["engine_oil"] = {
    label = "Engine Oil",
    weight = 1000,
  },
  ["tyre_replacement"] = {
    label = "Tyre Replacement",
    weight = 1000,
  },
  ["clutch_replacement"] = {
    label = "Clutch Replacement",
    weight = 1000,
  },
  ["air_filter"] = {
    label = "Air Filter",
    weight = 100,
  },
  ["spark_plug"] = {
    label = "Spark Plug",
    weight = 1000,
  },
  ["brakepad_replacement"] = {
    label = "Brakepad Replacement",
    weight = 1000,
  },
  ["suspension_parts"] = {
    label = "Suspension Parts",
    weight = 1000,
  },
  -- Engine Items
  ["i4_engine"] = {
    label = "I4 Engine",
    weight = 1000,
  },
  ["v6_engine"] = {
    label = "V6 Engine",
    weight = 1000,
  },
  ["v8_engine"] = {
    label = "V8 Engine",
    weight = 1000,
  },
  ["v12_engine"] = {
    label = "V12 Engine",
    weight = 1000,
  },
  ["turbocharger"] = {
    label = "Turbocharger",
    weight = 1000,
  },
  -- Electric Engines
  ["ev_motor"] = {
    label = "EV Motor",
    weight = 1000,
  },
  ["ev_battery"] = {
    label = "EV Battery",
    weight = 1000,
  },
  ["ev_coolant"] = {
    label = "EV Coolant",
    weight = 1000,
  },
  -- Drivetrain Items
  ["awd_drivetrain"] = {
    label = "AWD Drivetrain",
    weight = 1000,
  },
  ["rwd_drivetrain"] = {
    label = "RWD Drivetrain",
    weight = 1000,
  },
  ["fwd_drivetrain"] = {
    label = "FWD Drivetrain",
    weight = 1000,
  },
  -- Tuning Items
  ["slick_tyres"] = {
    label = "Slick Tyres",
    weight = 1000,
  },
  ["semi_slick_tyres"] = {
    label = "Semi Slick Tyres",
    weight = 1000,
  },
  ["offroad_tyres"] = {
    label = "Offroad Tyres",
    weight = 1000,
  },
  ["drift_tuning_kit"] = {
    label = "Drift Tuning Kit",
    weight = 1000,
  },
  ["ceramic_brakes"] = {
    label = "Ceramic Brakes",
    weight = 1000,
  },
  -- Cosmetic Items
  ["lighting_controller"] = {
    label = "Lighting Controller",
    weight = 100,
    client = {
      event = "jg-mechanic:client:show-lighting-controller",
    }
  },
  ["stancing_kit"] = {
    label = "Stancer Kit",
    weight = 100,
    client = {
      event = "jg-mechanic:client:show-stancer-kit",
    }
  },
  ["cosmetic_part"] = {
    label = "Cosmetic Parts",
    weight = 100,
  },
  ["respray_kit"] = {
    label = "Respray Kit",
    weight = 1000,
  },
  ["vehicle_wheels"] = {
    label = "Vehicle Wheels Set",
    weight = 1000,
  },
  ["tyre_smoke_kit"] = {
    label = "Tyre Smoke Kit",
    weight = 1000,
  },
  ["bulletproof_tyres"] = {
    label = "Bulletproof Tyres",
    weight = 1000,
  },
  ["extras_kit"] = {
    label = "Extras Kit",
    weight = 1000,
  },
  -- Nitrous & Cleaning Items
  ["nitrous_bottle"] = {
    label = "Nitrous Bottle",
    weight = 1000,
    client = {
      event = "jg-mechanic:client:use-nitrous-bottle",
    }
  },
  ["empty_nitrous_bottle"] = {
    label = "Empty Nitrous Bottle",
    weight = 1000,
  },
  ["nitrous_install_kit"] = {
    label = "Nitrous Install Kit",
    weight = 1000,
  },
  ["cleaning_kit"] = {
    label = "Cleaning Kit",
    weight = 1000,
    client = {
      event = "jg-mechanic:client:clean-vehicle",
    }
  },
  ["repair_kit"] = {
    label = "Repair Kit",
    weight = 1000,
    client = {
      event = "jg-mechanic:client:repair-vehicle",
    }
  },
  ["duct_tape"] = {
    label = "Duct Tape",
    weight = 1000,
    client = {
      event = "jg-mechanic:client:use-duct-tape",
    }
  },
  -- Performance Item
  ["performance_part"] = {
    label = "Performance Parts",
    weight = 1000,
  },
  -- Mechanic Tablet Item
  ["mechanic_tablet"] = {
    label = "Mechanic Tablet",
    weight = 1000,
    client = {
      event = "jg-mechanic:client:use-tablet",
    }
  },
  -- Gearbox
  ["manual_gearbox"] = {
    label = "Manual Gearbox",
    weight = 1000,
  },
  --ems
  		['medikit'] = { -- Make sure not already a medikit
			label = 'Medikit',
			weight = 165,
			stack = true,
			close = true,
		},
		['medbag'] = {
			label = 'Medical Bag',
			weight = 165,
			stack = false,
			close = true,
		},

		['tweezers'] = {
			label = 'Tweezers',
			weight = 2,
			stack = true,
			close = true,
		},

		['suturekit'] = {
			label = 'Suture Kit',
			weight = 15,
			stack = true,
			close = true,
		},

		['icepack'] = {
			label = 'Ice Pack',
			weight = 29,
			stack = true,
			close = true,
		},

		['burncream'] = {
			label = 'Burn Cream',
			weight = 19,
			stack = true,
			close = true,
		},

		['defib'] = {
			label = 'Defibrillator',
			weight = 225,
			stack = false,
			close = true,
		},

		['sedative'] = {
			label = 'Sedative',
			weight = 15,
			stack = true,
			close = true,
		},

		['morphine30'] = {
			label = 'Morphine 30MG',
			weight = 2,
			stack = true,
			close = true,
		},

		['morphine15'] = {
			label = 'Morphine 15MG',
			weight = 2,
			stack = true,
			close = true,
		},

		['perc30'] = {
			label = 'Percocet 30MG',
			weight = 2,
			stack = true,
			close = true,
		},

		['perc10'] = {
			label = 'Percocet 10MG',
			weight = 2,
			stack = true,
			close = true,
		},

		['perc5'] = {
			label = 'Percocet 5MG',
			weight = 2,
			stack = true,
			close = true,
		},

		['vic10'] = {
			label = 'Vicodin 10MG',
			weight = 2,
			stack = true,
			close = true,
		},

		['vic5'] = {
			label = 'Vicodin 5MG',
			weight = 2,
			stack = true,
			close = true,
		},

		['recoveredbullet'] = {
			label = 'Recovered Bullet',
			weight = 1,
			stack = true,
			close = false,
		},
        --armor
--armor
-- EXACT ANIMATION FROM YOUR CLOTHING SCRIPT FOR VEST

['armor_light'] = {
    label = 'Light Armor',
    weight = 100,
    stack = true,
    close = true,
    description = 'Lightweight body armor providing 50% protection. Takes approximately 3 shots.',
    client = {
        image = 'armor_light.png',
        anim = {
            dict = 'clothingtie',
            clip = 'try_tie_negative_a',
        },
        usetime = 1200,
    },
    server = {
        export = 'drp-armor.armor_light'
    }
},
['armor_heavy'] = {
    label = 'Heavy Armor',
    weight = 100,
    stack = true,
    close = true,
    description = 'Heavy-duty body armor providing 100% protection. Takes approximately 5 shots.',
    client = {
        image = 'armor_heavy.png',
        anim = {
            dict = 'clothingtie',
            clip = 'try_tie_negative_a',
        },
        usetime = 1200,
    },
    server = {
        export = 'drp-armor.armor_heavy'
    }
},
['armor_police'] = {
    label = 'Police Armor',
    weight = 100,
    stack = true,
    close = true,
    description = 'Advanced police body armor providing 100% protection. Takes approximately 8 shots. POLICE ONLY.',
    client = {
        image = 'armor_police.png',
        anim = {
            dict = 'clothingtie',
            clip = 'try_tie_negative_a',
        },
        usetime = 1200,
    },
    server = {
        export = 'drp-armor.armor_police'
    }
},

['ditto'] = {
    label = 'Ditto Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Ditto',
    rarity = 'common'
},

['eevee'] = {
    label = 'Eevee Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Eevee',
    rarity = 'uncommon'
},

['electabuzz'] = {
    label = 'Electabuzz Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Electabuzz',
    rarity = 'rare'
},

['electrode'] = {
    label = 'Electrode Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Electrode',
    rarity = 'rare'
},

['flareon'] = {
    label = 'Flareon Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Flareon',
    rarity = 'rare'
},

['golduck'] = {
    label = 'Golduck Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Golduck',
    rarity = 'rare'
},

['gyarados'] = {
    label = 'Gyarados Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Gyarados',
    rarity = 'legendary'
},

['hitmonchan'] = {
    label = 'Hitmonchan Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Hitmonchan',
    rarity = 'rare'
},

['hitmonlee'] = {
    label = 'Hitmonlee Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Hitmonlee',
    rarity = 'rare'
},

['jigglypuff'] = {
    label = 'Jigglypuff Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Jigglypuff',
    rarity = 'uncommon'
},

['jolteon'] = {
    label = 'Jolteon Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Jolteon',
    rarity = 'rare'
},

['jynx'] = {
    label = 'Jynx Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Jynx',
    rarity = 'rare'
},

['kadabra'] = {
    label = 'Kadabra Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Kadabra',
    rarity = 'rare'
},

['kangaskhan'] = {
    label = 'Kangaskhan Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Kangaskhan',
    rarity = 'rare'
},

['lapras'] = {
    label = 'Lapras Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Lapras',
    rarity = 'rare'
},

['machamp'] = {
    label = 'Machamp Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Machamp',
    rarity = 'legendary'
},

['magmar'] = {
    label = 'Magmar Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Magmar',
    rarity = 'rare'
},

['nidoking'] = {
    label = 'Nidoking Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Nidoking',
    rarity = 'legendary'
},

['nidoqueen'] = {
    label = 'Nidoqueen Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Nidoqueen',
    rarity = 'legendary'
},

['ninetails'] = {
    label = 'Ninetails Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Ninetails',
    rarity = 'rare'
},

['onix'] = {
    label = 'Onix Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Onix',
    rarity = 'rare'
},

['pidgeot'] = {
    label = 'Pidgeot Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Pidgeot',
    rarity = 'legendary'
},

['raichu'] = {
    label = 'Raichu Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Raichu',
    rarity = 'rare'
},

['rapidash'] = {
    label = 'Rapidash Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Rapidash',
    rarity = 'rare'
},

['rhydon'] = {
    label = 'Rhydon Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Rhydon',
    rarity = 'rare'
},

['scyther'] = {
    label = 'Scyther Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Scyther',
    rarity = 'rare'
},

['starmie'] = {
    label = 'Starmie Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Starmie',
    rarity = 'rare'
},

['tangela'] = {
    label = 'Tangela Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Tangela',
    rarity = 'rare'
},

['tauros'] = {
    label = 'Tauros Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Tauros',
    rarity = 'rare'
},

['togepi'] = {
    label = 'Togepi Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Togepi',
    rarity = 'uncommon'
},

['vaporeon'] = {
    label = 'Vaporeon Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Vaporeon',
    rarity = 'rare'
},

['venomoth'] = {
    label = 'Venomoth Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Venomoth',
    rarity = 'rare'
},

['venusaur'] = {
    label = 'Venusaur Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Venusaur',
    rarity = 'rare'
},

['victreebel'] = {
    label = 'Victreebel Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Victreebel',
    rarity = 'legendary'
},

['vileplume'] = {
    label = 'Vileplume Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Vileplume',
    rarity = 'rare'
},

['wigglytuff'] = {
    label = 'Wigglytuff Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Wigglytuff',
    rarity = 'rare'
},

['aerodactyl'] = {
    label = 'Aerodactyl Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A legendary Pokemon trading card featuring Aerodactyl',
    rarity = 'legendary'
},

['articuno'] = {
    label = 'Articuno Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A legendary Pokemon trading card featuring Articuno',
    rarity = 'legendary'
},

['blastoise'] = {
    label = 'Blastoise Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A legendary Pokemon trading card featuring Blastoise',
    rarity = 'legendary'
},

['charizard'] = {
    label = 'Charizard Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A legendary Pokemon trading card featuring Charizard',
    rarity = 'legendary'
},

['dragonair'] = {
    label = 'Dragonair Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A legendary Pokemon trading card featuring Dragonair',
    rarity = 'legendary'
},

['dragonite'] = {
    label = 'Dragonite Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A legendary Pokemon trading card featuring Dragonite',
    rarity = 'legendary'
},

['dratini'] = {
    label = 'Dratini Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A legendary Pokemon trading card featuring Dratini',
    rarity = 'legendary'
},

['kabuto'] = {
    label = 'Kabuto Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A legendary Pokemon trading card featuring Kabuto',
    rarity = 'legendary'
},

['kabutops'] = {
    label = 'Kabutops Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A legendary Pokemon trading card featuring Kabutops',
    rarity = 'legendary'
},

['mew'] = {
    label = 'Mew Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A legendary Pokemon trading card featuring Mew',
    rarity = 'legendary'
},

['mewtwo'] = {
    label = 'Mewtwo Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A legendary Pokemon trading card featuring Mewtwo',
    rarity = 'legendary'
},

['moltres'] = {
    label = 'Moltres Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A legendary Pokemon trading card featuring Moltres',
    rarity = 'legendary'
},

['omanyte'] = {
    label = 'Omanyte Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A legendary Pokemon trading card featuring Omanyte',
    rarity = 'legendary'
},

['omastar'] = {
    label = 'Omastar Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A legendary Pokemon trading card featuring Omastar',
    rarity = 'legendary'
},

['porygon'] = {
    label = 'Porygon Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A legendary Pokemon trading card featuring Porygon',
    rarity = 'legendary'
},

['snorlax'] = {
    label = 'Snorlax Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A legendary Pokemon trading card featuring Snorlax',
    rarity = 'legendary'
},

['zapdos'] = {
    label = 'Zapdos Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A legendary Pokemon trading card featuring Zapdos',
    rarity = 'legendary'
},

['blastoisev'] = {
    label = 'Blastoise V Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'An epic V-tier Pokemon trading card featuring Blastoise',
    rarity = 'epic'
},

['charizardv'] = {
    label = 'Charizard V Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'An epic V-tier Pokemon trading card featuring Charizard',
    rarity = 'epic'
},

['mewv'] = {
    label = 'Mew V Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'An epic V-tier Pokemon trading card featuring Mew',
    rarity = 'epic'
},

['pikachuv'] = {
    label = 'Pikachu V Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'An epic V-tier Pokemon trading card featuring Pikachu',
    rarity = 'epic'
},

['snorlaxv'] = {
    label = 'Snorlax V Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'An epic V-tier Pokemon trading card featuring Snorlax',
    rarity = 'epic'
},

['venusaurv'] = {
    label = 'Venusaur V Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'An epic V-tier Pokemon trading card featuring Venusaur',
    rarity = 'epic'
},

['blastoisevmax'] = {
    label = 'Blastoise VMAX Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'An epic VMAX Pokemon trading card featuring Blastoise',
    rarity = 'epic'
},

['mewtwogx'] = {
    label = 'Mewtwo GX Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'An epic GX Pokemon trading card featuring Mewtwo',
    rarity = 'epic'
},

['snorlaxvmax'] = {
    label = 'Snorlax VMAX Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'An epic VMAX Pokemon trading card featuring Snorlax',
    rarity = 'epic'
},

['venusaurvmax'] = {
    label = 'Venusaur VMAX Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'An epic VMAX Pokemon trading card featuring Venusaur',
    rarity = 'epic'
},

['vmaxcharizard'] = {
    label = 'Charizard VMAX Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'An epic VMAX Pokemon trading card featuring Charizard',
    rarity = 'epic'
},

['vmaxpikachu'] = {
    label = 'Pikachu VMAX Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'An epic VMAX Pokemon trading card featuring Pikachu',
    rarity = 'epic'
},

['rainbowmewtwogx'] = {
    label = 'Rainbow Mewtwo GX Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'An ultra-rare rainbow GX Pokemon trading card featuring Mewtwo',
    rarity = 'epic'
},

['rainbowvmaxcharizard'] = {
    label = 'Rainbow Charizard VMAX Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'An ultra-rare rainbow VMAX Pokemon trading card featuring Charizard',
    rarity = 'epic'
},

['rainbowvmaxpikachu'] = {
    label = 'Rainbow Pikachu VMAX Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'An ultra-rare rainbow VMAX Pokemon trading card featuring Pikachu',
    rarity = 'epic'
},

['snorlaxvmaxrainbow'] = {
    label = 'Rainbow Snorlax VMAX Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'An ultra-rare rainbow VMAX Pokemon trading card featuring Snorlax',
    rarity = 'epic'
},

['boosterbox'] = {
    label = 'Booster Box',
    weight = 500,
    stack = true,
    close = true,
    description = 'A sealed Pokemon booster box containing multiple packs',
    rarity = 'epic'
},

['boosterpack'] = {
    label = 'Booster Pack',
    weight = 50,
    stack = true,
    close = true,
    description = 'A sealed Pokemon booster pack',
    rarity = 'rare'
},

['boulderbadge'] = {
    label = 'Boulder Badge',
    weight = 10,
    stack = true,
    close = true,
    description = 'A gym badge earned from defeating Brock',
    rarity = 'epic'
},

['cascadebadge'] = {
    label = 'Cascade Badge',
    weight = 10,
    stack = true,
    close = true,
    description = 'A gym badge earned from defeating Misty',
    rarity = 'epic'
},

['thunderbadge'] = {
    label = 'Thunder Badge',
    weight = 10,
    stack = true,
    close = true,
    description = 'A gym badge earned from defeating Lt. Surge',
    rarity = 'epic'
},

['rainbowbadge'] = {
    label = 'Rainbow Badge',
    weight = 10,
    stack = true,
    close = true,
    description = 'A gym badge earned from defeating Erika',
    rarity = 'epic'
},

['soulbadge'] = {
    label = 'Soul Badge',
    weight = 10,
    stack = true,
    close = true,
    description = 'A gym badge earned from defeating Koga',
    rarity = 'epic'
},

['marshbadge'] = {
    label = 'Marsh Badge',
    weight = 10,
    stack = true,
    close = true,
    description = 'A gym badge earned from defeating Sabrina',
    rarity = 'epic'
},

['volcanobadge'] = {
    label = 'Volcano Badge',
    weight = 10,
    stack = true,
    close = true,
    description = 'A gym badge earned from defeating Blaine',
    rarity = 'epic'
},

['earthbadge'] = {
    label = 'Earth Badge',
    weight = 10,
    stack = true,
    close = true,
    description = 'A gym badge earned from defeating Giovanni',
    rarity = 'epic'
},

['trophybadge'] = {
    label = 'Trophy Badge',
    weight = 10,
    stack = true,
    close = true,
    description = 'A special trophy badge for completing the Pokemon journey',
    rarity = 'epic'
},

['pokebox'] = {
    label = 'Pokemon Storage Box',
    weight = 100,
    stack = true,
    close = true,
    description = 'A storage box for organizing Pokemon cards',
    rarity = 'rare'
},

['abra'] = {
    label = 'Abra Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Abra',
    rarity = 'uncommon'
},

['alakazam'] = {
    label = 'Alakazam Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Alakazam',
    rarity = 'legendary'
},

['arbok'] = {
    label = 'Arbok Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Arbok',
    rarity = 'rare'
},

['arcanine'] = {
    label = 'Arcanine Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Arcanine',
    rarity = 'legendary'
},

['beedrill'] = {
    label = 'Beedrill Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Beedrill',
    rarity = 'legendary'
},

['bellsprout'] = {
    label = 'Bellsprout Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Bellsprout',
    rarity = 'common'
},

['bulbasaur'] = {
    label = 'Bulbasaur Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Bulbasaur',
    rarity = 'uncommon'
},

['butterfree'] = {
    label = 'Butterfree Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Butterfree',
    rarity = 'legendary'
},

['caterpie'] = {
    label = 'Caterpie Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Caterpie',
    rarity = 'common'
},

['chansey'] = {
    label = 'Chansey Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Chansey',
    rarity = 'rare'
},

['charmander'] = {
    label = 'Charmander Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Charmander',
    rarity = 'uncommon'
},

['charmeleon'] = {
    label = 'Charmeleon Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Charmeleon',
    rarity = 'rare'
},

['clefable'] = {
    label = 'Clefable Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Clefable',
    rarity = 'rare'
},

['clefairy'] = {
    label = 'Clefairy Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Clefairy',
    rarity = 'uncommon'
},

['cloyster'] = {
    label = 'Cloyster Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Cloyster',
    rarity = 'legendary'
},

['cubone'] = {
    label = 'Cubone Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Cubone',
    rarity = 'uncommon'
},

['dewgong'] = {
    label = 'Dewgong Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Dewgong',
    rarity = 'rare'
},

['diglett'] = {
    label = 'Diglett Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Diglett',
    rarity = 'common'
},

['dodrio'] = {
    label = 'Dodrio Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Dodrio',
    rarity = 'rare'
},

['doduo'] = {
    label = 'Doduo Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Doduo',
    rarity = 'common'
},

['drowzee'] = {
    label = 'Drowzee Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Drowzee',
    rarity = 'uncommon'
},

['dugtrio'] = {
    label = 'Dugtrio Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Dugtrio',
    rarity = 'rare'
},

['ekans'] = {
    label = 'Ekans Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Ekans',
    rarity = 'common'
},

['exeggcute'] = {
    label = 'Exeggcute Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Exeggcute',
    rarity = 'rare'
},

['exeggutor'] = {
    label = 'Exeggutor Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Exeggutor',
    rarity = 'legendary'
},

['farfetchd'] = {
    label = "Farfetch'd Card",
    weight = 10,
    stack = true,
    close = true,
    description = "A rare Pokemon trading card featuring Farfetch'd",
    rarity = 'rare'
},

['fearow'] = {
    label = 'Fearow Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Fearow',
    rarity = 'rare'
},

['gastly'] = {
    label = 'Gastly Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Gastly',
    rarity = 'uncommon'
},

['gengar'] = {
    label = 'Gengar Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Gengar',
    rarity = 'legendary'
},

['geodude'] = {
    label = 'Geodude Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Geodude',
    rarity = 'common'
},

['gloom'] = {
    label = 'Gloom Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Gloom',
    rarity = 'rare'
},

['golbat'] = {
    label = 'Golbat Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Golbat',
    rarity = 'rare'
},

['goldeen'] = {
    label = 'Goldeen Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Goldeen',
    rarity = 'common'
},

['golem'] = {
    label = 'Golem Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Golem',
    rarity = 'legendary'
},

['graveler'] = {
    label = 'Graveler Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Graveler',
    rarity = 'rare'
},

['grimer'] = {
    label = 'Grimer Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Grimer',
    rarity = 'uncommon'
},

['growlithe'] = {
    label = 'Growlithe Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Growlithe',
    rarity = 'uncommon'
},

['haunter'] = {
    label = 'Haunter Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Haunter',
    rarity = 'rare'
},

['horsea'] = {
    label = 'Horsea Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Horsea',
    rarity = 'common'
},

['hypno'] = {
    label = 'Hypno Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Hypno',
    rarity = 'rare'
},

['ivysaur'] = {
    label = 'Ivysaur Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Ivysaur',
    rarity = 'rare'
},

['kakuna'] = {
    label = 'Kakuna Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Kakuna',
    rarity = 'common'
},

['kingler'] = {
    label = 'Kingler Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Kingler',
    rarity = 'rare'
},

['koffing'] = {
    label = 'Koffing Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Koffing',
    rarity = 'uncommon'
},

['krabby'] = {
    label = 'Krabby Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Krabby',
    rarity = 'common'
},

['lickitung'] = {
    label = 'Lickitung Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Lickitung',
    rarity = 'rare'
},

['machoke'] = {
    label = 'Machoke Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Machoke',
    rarity = 'rare'
},

['machop'] = {
    label = 'Machop Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Machop',
    rarity = 'uncommon'
},

['magikarp'] = {
    label = 'Magikarp Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Magikarp',
    rarity = 'common'
},

['magnemite'] = {
    label = 'Magnemite Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Magnemite',
    rarity = 'rare'
},

['magneton'] = {
    label = 'Magneton Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Magneton',
    rarity = 'rare'
},

['mankey'] = {
    label = 'Mankey Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Mankey',
    rarity = 'uncommon'
},

['marowak'] = {
    label = 'Marowak Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Marowak',
    rarity = 'rare'
},

['meowth'] = {
    label = 'Meowth Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Meowth',
    rarity = 'common'
},

['metapod'] = {
    label = 'Metapod Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Metapod',
    rarity = 'common'
},

['mr_mime'] = {
    label = 'Mr. Mime Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Mr. Mime',
    rarity = 'rare'
},

['muk'] = {
    label = 'Muk Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Muk',
    rarity = 'rare'
},

['nidoran'] = {
    label = 'Nidoran Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Nidoran',
    rarity = 'common'
},

['nidorina'] = {
    label = 'Nidorina Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Nidorina',
    rarity = 'rare'
},

['nidorino'] = {
    label = 'Nidorino Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Nidorino',
    rarity = 'rare'
},

['oddish'] = {
    label = 'Oddish Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Oddish',
    rarity = 'common'
},

['paras'] = {
    label = 'Paras Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Paras',
    rarity = 'common'
},

['parasect'] = {
    label = 'Parasect Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Parasect',
    rarity = 'rare'
},

['persian'] = {
    label = 'Persian Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Persian',
    rarity = 'rare'
},

['pidgeotto'] = {
    label = 'Pidgeotto Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Pidgeotto',
    rarity = 'rare'
},

['pidgey'] = {
    label = 'Pidgey Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Pidgey',
    rarity = 'common'
},

['pikachu'] = {
    label = 'Pikachu Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Pikachu',
    rarity = 'uncommon'
},

['pinsir'] = {
    label = 'Pinsir Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Pinsir',
    rarity = 'rare'
},

['poliwag'] = {
    label = 'Poliwag Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Poliwag',
    rarity = 'common'
},

['poliwhirl'] = {
    label = 'Poliwhirl Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Poliwhirl',
    rarity = 'rare'
},

['poliwrath'] = {
    label = 'Poliwrath Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Poliwrath',
    rarity = 'legendary'
},

['ponyta'] = {
    label = 'Ponyta Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Ponyta',
    rarity = 'uncommon'
},

['primeape'] = {
    label = 'Primeape Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Primeape',
    rarity = 'rare'
},

['psyduck'] = {
    label = 'Psyduck Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Psyduck',
    rarity = 'common'
},

['raticate'] = {
    label = 'Raticate Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Raticate',
    rarity = 'rare'
},

['rattata'] = {
    label = 'Rattata Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Rattata',
    rarity = 'common'
},

['rhyhorn'] = {
    label = 'Rhyhorn Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Rhyhorn',
    rarity = 'rare'
},

['sandshrew'] = {
    label = 'Sandshrew Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Sandshrew',
    rarity = 'common'
},

['sandslash'] = {
    label = 'Sandslash Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Sandslash',
    rarity = 'rare'
},

['seadra'] = {
    label = 'Seadra Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Seadra',
    rarity = 'rare'
},

['seaking'] = {
    label = 'Seaking Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Seaking',
    rarity = 'rare'
},

['seel'] = {
    label = 'Seel Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Seel',
    rarity = 'uncommon'
},

['shellder'] = {
    label = 'Shellder Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Shellder',
    rarity = 'uncommon'
},

['slowbro'] = {
    label = 'Slowbro Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Slowbro',
    rarity = 'rare'
},

['slowpoke'] = {
    label = 'Slowpoke Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Slowpoke',
    rarity = 'uncommon'
},

['spearow'] = {
    label = 'Spearow Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Spearow',
    rarity = 'common'
},

['squirtle'] = {
    label = 'Squirtle Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Squirtle',
    rarity = 'uncommon'
},

['staryu'] = {
    label = 'Staryu Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Staryu',
    rarity = 'common'
},

['tentacool'] = {
    label = 'Tentacool Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Tentacool',
    rarity = 'common'
},

['tentacruel'] = {
    label = 'Tentacruel Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Tentacruel',
    rarity = 'rare'
},

['venonat'] = {
    label = 'Venonat Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Venonat',
    rarity = 'common'
},

['voltorb'] = {
    label = 'Voltorb Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Voltorb',
    rarity = 'common'
},

['vulpix'] = {
    label = 'Vulpix Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Vulpix',
    rarity = 'rare'
},

['wartortle'] = {
    label = 'Wartortle Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Wartortle',
    rarity = 'rare'
},

['weedle'] = {
    label = 'Weedle Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Weedle',
    rarity = 'common'
},

['weepinbell'] = {
    label = 'Weepinbell Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Weepinbell',
    rarity = 'rare'
},

['weezing'] = {
    label = 'Weezing Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Weezing',
    rarity = 'demon'
},

['zubat'] = {
    label = 'Zubat Card',
    weight = 10,
    stack = true,
    close = true,
    description = 'A rare Pokemon trading card featuring Zubat',
    rarity = 'gold'
},
--gym
['protein'] = {
    label = 'Protein',
    weight = 1,
    stack = true
},

['runbooster'] = {
    label = 'Run-Booster',
    weight = 1,
    stack = true
},
['ammonium_nitrate'] = {
    label = 'Ammonium nitrate',
    weight = 500,
    stack = true,
    close = false,
},

['carbon'] = {
    label = 'Carbon',
    weight = 500,
    stack = true,
    close = false,
},

['codeine'] = {
    label = 'Codeine',
    weight = 500,
    stack = true,
    close = false,
},

['drink_sprite'] = {
    label = 'Sprite',
    weight = 500,
    stack = true,
    close = false,
},

['drug_ecstasy'] = {
    label = 'Ecstasy',
    weight = 500,
    stack = true,
    close = false,
},

['drug_lean'] = {
    label = 'Lean',
    weight = 500,
    stack = true,
    close = false,
},

['drug_lsd'] = {
    label = 'LSD',
    weight = 500,
    stack = true,
    close = false,
},

['drug_meth'] = {
    label = 'Meth',
    weight = 500,
    stack = true,
    close = false,
},

['hydrogen'] = {
    label = 'Hydrogen',
    weight = 500,
    stack = true,
    close = false,
},

['ice'] = {
    label = 'Ice',
    weight = 500,
    stack = true,
    close = false,
},

['jolly_ranchers'] = {
    label = 'Jolly Ranchers',
    weight = 500,
    stack = true,
    close = false,
},

['liquid_sulfur'] = {
    label = 'Liquid Sulfur',
    weight = 500,
    stack = true,
    close = false,
},

['muriatic_acid'] = {
    label = 'Muriatic Acid',
    weight = 500,
    stack = true,
    close = false,
},

['nitrogen'] = {
    label = 'Nitrogen',
    weight = 500,
    stack = true,
    close = false,
},

['oxygen'] = {
    label = 'Oxygen',
    weight = 500,
    stack = true,
    close = false,
},

['pseudoefedrine'] = {
    label = 'Pseudoefedrine',
    weight = 500,
    stack = true,
    close = false,
},

['red_sulfur'] = {
    label = 'Red Sulfur',
    weight = 500,
    stack = true,
    close = false,
},

['sodium_hydroxide'] = {
    label = 'Sodium hydroxide',
    weight = 500,
    stack = true,
    close = false,
},

['cannabis'] = {
    label = 'Cannabis',
    weight = 500,
    stack = true,
    close = false,
},

['green_gelato_cannabis'] = {
    label = 'Green Gelato Cannabis',
    weight = 500,
    stack = true,
    close = false,
},

['opium'] = {
    label = 'Opium',
    weight = 500,
    stack = true,
    close = false,
},

['cocaine'] = {
    label = 'Cocaine',
    weight = 500,
    stack = true,
    close = false,
},

['ammo-22-box'] = {
    label = '.22 LR Ammo Box (75 rounds)',
    weight = 225,
    stack = true,
    close = true,
    description = 'Box containing 75 rounds of .22 Long Rifle ammunition',
    server = {
        export = 'ox_inventory.unpack_ammo_22_box'
    }
},

['ammo-38-box'] = {
    label = '.38 LC Ammo Box (75 rounds)',
    weight = 1125,
    stack = true,
    close = true,
    description = 'Box containing 75 rounds of .38 LC ammunition',
    server = {
        export = 'ox_inventory.unpack_ammo_38_box'
    }
},

['ammo-44-box'] = {
    label = '.44 Magnum Ammo Box (75 rounds)',
    weight = 1200,
    stack = true,
    close = true,
    description = 'Box containing 75 rounds of .44 Magnum ammunition',
    server = {
        export = 'ox_inventory.unpack_ammo_44_box'
    }
},

['ammo-45-box'] = {
    label = '.45 ACP Ammo Box (75 rounds)',
    weight = 1125,
    stack = true,
    close = true,
    description = 'Box containing 75 rounds of .45 ACP ammunition',
    server = {
        export = 'ox_inventory.unpack_ammo_45_box'
    }
},

['ammo-50-box'] = {
    label = '.50 AE Ammo Box (75 rounds)',
    weight = 3375,
    stack = true,
    close = true,
    description = 'Box containing 75 rounds of .50 AE ammunition',
    server = {
        export = 'ox_inventory.unpack_ammo_50_box'
    }
},

['ammo-9-box'] = {
    label = '9mm Ammo Box (75 rounds)',
    weight = 525,
    stack = true,
    close = true,
    description = 'Box containing 75 rounds of 9mm ammunition',
    server = {
        export = 'ox_inventory.unpack_ammo_9_box'
    }
},

['ammo-rifle-box'] = {
    label = '5.56x45 Ammo Box (100 rounds)',
    weight = 400,
    stack = true,
    close = true,
    description = 'Box containing 100 rounds of 5.56x45 rifle ammunition',
    server = {
        export = 'ox_inventory.unpack_ammo_rifle_box'
    }
},

['ammo-rifle2-box'] = {
    label = '7.62x39 Ammo Box (100 rounds)',
    weight = 800,
    stack = true,
    close = true,
    description = 'Box containing 100 rounds of 7.62x39 rifle ammunition',
    server = {
        export = 'ox_inventory.unpack_ammo_rifle2_box'
    }
},

['ammo-sniper-box'] = {
    label = '7.62x51 Ammo Box (100 rounds)',
    weight = 900,
    stack = true,
    close = true,
    description = 'Box containing 100 rounds of 7.62x51 sniper ammunition',
    server = {
        export = 'ox_inventory.unpack_ammo_sniper_box'
    }
},

['ammo-heavysniper-box'] = {
    label = '.50 BMG Ammo Box (100 rounds)',
    weight = 5100,
    stack = true,
    close = true,
    description = 'Box containing 100 rounds of .50 BMG heavy sniper ammunition',
    server = {
        export = 'ox_inventory.unpack_ammo_heavysniper_box'
    }
},

['ammo-shotgun-box'] = {
    label = '12 Gauge Ammo Box (100 rounds)',
    weight = 3800,
    stack = true,
    close = true,
    description = 'Box containing 100 rounds of 12 gauge shotgun shells',
    server = {
        export = 'ox_inventory.unpack_ammo_shotgun_box'
    }
},

['ammo-musket-box'] = {
    label = '.50 Ball Ammo Box (100 rounds)',
    weight = 3800,
    stack = true,
    close = true,
    description = 'Box containing 100 rounds of .50 Ball musket ammunition',
    server = {
        export = 'ox_inventory.unpack_ammo_musket_box'
    }
},

['mdt_tablet'] = {
    label = 'MDT Tablet',
    weight = 500,
    stack = false,
    close = true,
    description = 'A police MDT tablet for accessing the department database',
    client = {
        export = 'wasabi_mdt.OpenMDT'
    }
},
}
