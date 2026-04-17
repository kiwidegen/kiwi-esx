return {
	{
        name = 'debug_crafting',
		items = {
			{
				name = 'lockpick',
				ingredients = {
					scrapmetal = 5,
					WEAPON_HAMMER = 0.05
				},
				duration = 5000,
				count = 2,
			},
		},
		points = {
			vec3(-1147.083008, -2002.662109, 13.180260),
			vec3(-345.374969, -130.687088, 39.009613)
		},
		zones = {
			{
				coords = vec3(-1146.2, -2002.05, 13.2),
				size = vec3(3.8, 1.05, 0.15),
				distance = 1.5,
				rotation = 315.0,
			},
			{
				coords = vec3(-346.1, -130.45, 39.0),
				size = vec3(3.8, 1.05, 2.0),
				distance = 1.5,
				rotation = 70.0,
			},
		},
		blip = { id = 566, colour = 31, scale = 0.8 },
	},  -- <-- COMMA HERE IS CRITICAL
	{
		name = 'lscustoms_crafting',
		items = {
			{
				name = 'adv_repairkit',
				ingredients = {
					steel = 25,
					metalscrap = 25,
				},
				duration = 3000,
				count = 1,
			},
		},
		groups = { lscustoms = 0 },
		points = {
			vec3(-320.02, -120.55, 39.00),
		},
		zones = {
			{
				coords = vec3(-320.02, -120.55, 39.00),
				size = vec3(6.0, 4.0, 3.0),
				distance = 3.0,
				rotation = 345.83,
			},
		},
		blip = { id = 566, colour = 31, scale = 0.8 },
	},
}
