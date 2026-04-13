# Ox Inventory Items Configuration

Add these items to your `ox_inventory/data/items.lua` file:

## Fishing Rods

```lua
['basic_rod'] = {
    label = 'Basic Fishing Rod',
    weight = 2000,
    stack = false,
    close = true,
    description = 'A basic fishing rod for beginners. 20% break chance.',
    client = {
        image = 'basic_rod.png',
    }
},

['graphite_rod'] = {
    label = 'Graphite Fishing Rod',
    weight = 1800,
    stack = false,
    close = true,
    description = 'A quality graphite rod for experienced anglers. 10% break chance. Requires Level 2.',
    client = {
        image = 'graphite_rod.png',
    }
},

['titanium_rod'] = {
    label = 'Titanium Fishing Rod',
    weight = 1500,
    stack = false,
    close = true,
    description = 'The ultimate fishing rod made from titanium. 1% break chance. Requires Level 3.',
    client = {
        image = 'titanium_rod.png',
    }
},
```

## Fishing Baits

```lua
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
```

## Freshwater Fish

```lua
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
```

## Saltwater Fish

```lua
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
```

## Deep Water Fish

```lua
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
    }
},
```

## Installation Instructions

1. Copy all the items above
2. Open `ox_inventory/data/items.lua`
3. Add these items to the existing items table
4. Copy all images from `drp-fishing/install/images/` to `ox_inventory/web/images/`
5. Restart your ox_inventory resource
6. Restart drp-fishing

## Image Files Required

Make sure these image files are in `ox_inventory/web/images/`:

**Rods:**
- basic_rod.png
- graphite_rod.png
- titanium_rod.png

**Baits:**
- worms.png
- mussel.png
- pilchards.png

**Freshwater Fish:**
- brown_trout.png
- rainbow_trout.png
- salmon.png
- piranha.png

**Saltwater Fish:**
- anchovy.png
- barramundi.png
- bream.png
- flathead.png
- haddock.png
- mullet.png
- red_snapper.png
- sea_bass.png
- grouper.png

**Deep Water Fish:**
- mahimahi.png
- marlin.png
- bluefin_tuna.png
- tuna.png
- shark.png

## Fish Categorization

### Freshwater (Level 1+)
- Brown Trout
- Rainbow Trout
- Salmon
- Barramundi (also in saltwater)
- Piranha

### Saltwater (Level 2+)
- Anchovy
- Barramundi (also in freshwater)
- Bream
- Flathead
- Haddock
- Mullet
- Red Snapper
- Sea Bass
- Grouper

### Deep Water (Level 3+)
- Mahi-Mahi
- Marlin
- Tuna
- Bluefin Tuna
- Shark
