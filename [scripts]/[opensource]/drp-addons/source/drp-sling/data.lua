---@diagnostic disable: undefined-global, lowercase-global
--- Weapon Sling System - Data
--- Weapon attachment positions and compatible weapons

---@class WeaponPosition
---@field bone number Ped bone to attach weapon
---@field x number Up/down offset (positive = up, negative = down)
---@field y number Forward/backward offset (positive = forward, negative = backward)
---@field z number Left/right offset (positive = right, negative = left)
---@field x_rotation number Rotation around X-axis (degrees)
---@field y_rotation number Rotation around Y-axis (degrees)
---@field z_rotation number Rotation around Z-axis (degrees)

---@class WeaponData
---@field model string Weapon model name
---@field hash number Weapon hash
---@field type 'Melee'|'Firearm'|'Pistol' Weapon type

---@type table<string, table<string, WeaponPosition>> Weapon attachment positions
SlingConfig.Positions = {
	Melee = {
		["Back"] = {
			bone = 24818,             -- Ped bone to attach weapon (Spine3)
			x = 0.25,                 -- Up/down offset (positive = up, negative = down)
			y = -0.15,                -- Forward/backward offset (positive = forward, negative = backward)
			z = -0.12,                -- Left/right offset (positive = right, negative = left)
			x_rotation = 0.0,         -- Rotation around X-axis (degrees)
			y_rotation = 300.0,       -- Rotation around Y-axis (degrees)
			z_rotation = 0.0          -- Rotation around Z-axis (degrees)
		}
	},
	Pistol = {
		["Hip"] = {
			bone = 51826,            -- SKEL_R_Thigh (RIGHT thigh - correct bone!)
			x = 0.0,                 -- Up/down offset
			y = 0.00,                -- Forward/backward offset
			z = 0.1,                -- Left/right offset
			x_rotation = 270.0,      -- Rotation around X-axis (pointing down)
			y_rotation = 0.0,        -- Rotation around Y-axis
			z_rotation = 0.0         -- Rotation around Z-axis
		},
		-- ALTERNATIVE: Try this if the above doesn't work
		["Hip_Alt"] = {
			bone = 11816,            -- SKEL_Pelvis (pelvis bone - more centered)
			x = -0.05,               -- Up/down offset
			y = 0.0,                 -- Forward/backward offset
			z = 0.3,                -- Left/right offset (right side)
			x_rotation = 270.0,      -- Rotation around X-axis
			y_rotation = 0.0,        -- Rotation around Y-axis
			z_rotation = 0.0         -- Rotation around Z-axis
		}
	},
	Firearm = {
		["Back"] = {
			bone = 24818,             -- Ped bone to attach weapon (Spine3)
			x = 0.1,                  -- Up/down offset (positive = up, negative = down)
			y = -0.15,                -- Forward/backward offset (positive = forward, negative = backward)
			z = 0.02,                 -- Left/right offset (positive = right, negative = left)
			x_rotation = 0.0,         -- Rotation around X-axis (degrees)
			y_rotation = 165.0,       -- Rotation around Y-axis (degrees)
			z_rotation = 0.0          -- Rotation around Z-axis (degrees)
		},
		["Front"] = {
			bone = 10706,            -- Ped bone to attach weapon (SKEL_R_Clavicle)
			x = 0.0,                 -- Up/down offset (positive = up, negative = down)
			y = 0.15,                -- Forward/backward offset (positive = forward, negative = backward, reduced to bring closer)
			z = -0.15,               -- Left/right offset (positive = right, negative = left, reduced to bring closer)
			x_rotation = 0.0,        -- Rotation around X-axis (degrees)
			y_rotation = 75.0,       -- Rotation around Y-axis (degrees)
			z_rotation = 180.0       -- Rotation around Z-axis (degrees)
		}
	}
}

---@type table<string, WeaponData> Compatible weapon definitions
SlingConfig.compatable_weapon_hashes = {
	-- Melee Weapons
	["WEAPON_BAT"] = { model = "w_me_bat", hash = GetHashKey("WEAPON_BAT"), type = "Melee" },
	["WEAPON_GOLFCLUB"] = { model = "w_me_gclub", hash = GetHashKey("WEAPON_GOLFCLUB"), type = "Melee" },
	["WEAPON_MACHETE"] = { model = "w_me_machette_lr", hash = GetHashKey("WEAPON_MACHETE"), type = "Melee" },
	["WEAPON_POOLCUE"] = { model = "w_me_poolcue", hash = GetHashKey("WEAPON_POOLCUE"), type = "Melee" },

	-- Pistols
	["WEAPON_APPISTOL"] = { model = "w_pi_appistol", hash = GetHashKey("WEAPON_APPISTOL"), type = "Pistol" },
	["WEAPON_CERAMICPISTOL"] = { model = "w_pi_ceramicpistol", hash = GetHashKey("WEAPON_CERAMICPISTOL"), type = "Pistol" },
	["WEAPON_PISTOLXM3"] = { model = "w_pi_pistolxm3", hash = GetHashKey("WEAPON_PISTOLXM3"), type = "Pistol" },
	["WEAPON_COMBATPISTOL"] = { model = "w_pi_combatpistol", hash = GetHashKey("WEAPON_COMBATPISTOL"), type = "Pistol" },
	["WEAPON_DOUBLEACTION"] = { model = "w_pi_doubleaction", hash = GetHashKey("WEAPON_DOUBLEACTION"), type = "Pistol" },
	["WEAPON_FLAREGUN"] = { model = "w_pi_flaregun", hash = GetHashKey("WEAPON_FLAREGUN"), type = "Pistol" },
	["WEAPON_HEAVYPISTOL"] = { model = "w_pi_heavypistol", hash = GetHashKey("WEAPON_HEAVYPISTOL"), type = "Pistol" },
	["WEAPON_MARKSMANPISTOL"] = { model = "w_pi_marksmanpistol", hash = GetHashKey("WEAPON_MARKSMANPISTOL"), type = "Pistol" },
	["WEAPON_NAVYREVOLVER"] = { model = "w_pi_navyrevolver", hash = GetHashKey("WEAPON_NAVYREVOLVER"), type = "Pistol" },
	["WEAPON_PISTOL"] = { model = "w_pi_pistol", hash = GetHashKey("WEAPON_PISTOL"), type = "Pistol" },
	["WEAPON_PISTOL50"] = { model = "w_pi_pistol50", hash = GetHashKey("WEAPON_PISTOL50"), type = "Pistol" },
	["WEAPON_PISTOL_MK2"] = { model = "w_pi_pistolmk2", hash = GetHashKey("WEAPON_PISTOL_MK2"), type = "Pistol" },
	["WEAPON_RAYPISTOL"] = { model = "w_pi_raypistol", hash = GetHashKey("WEAPON_RAYPISTOL"), type = "Pistol" },
	["WEAPON_REVOLVER"] = { model = "w_pi_revolver", hash = GetHashKey("WEAPON_REVOLVER"), type = "Pistol" },
	["WEAPON_REVOLVER_MK2"] = { model = "w_pi_revolvermk2", hash = GetHashKey("WEAPON_REVOLVER_MK2"), type = "Pistol" },
	["WEAPON_SNSPISTOL"] = { model = "w_pi_snspistol", hash = GetHashKey("WEAPON_SNSPISTOL"), type = "Pistol" },
	["WEAPON_SNSPISTOL_MK2"] = { model = "w_pi_snspistolmk2", hash = GetHashKey("WEAPON_SNSPISTOL_MK2"), type = "Pistol" },
	["WEAPON_VINTAGEPISTOL"] = { model = "w_pi_vintagepistol", hash = GetHashKey("WEAPON_VINTAGEPISTOL"), type = "Pistol" },
	["WEAPON_TECPISTOL"] = { model = "w_pi_tecpistol", hash = GetHashKey("WEAPON_TECPISTOL"), type = "Pistol" },

	-- KYROS PISTOLS (NEW)
	["WEAPON_CTP9SF"] = { model = "w_pi_kyrosctp9sf", hash = GetHashKey("WEAPON_CTP9SF"), type = "Pistol" },
	["WEAPON_T19XD"] = { model = "w_pi_kyrost19xd", hash = GetHashKey("WEAPON_T19XD"), type = "Pistol" },
	["WEAPON_T17B"] = { model = "w_pi_kyrost17b", hash = GetHashKey("WEAPON_T17B"), type = "Pistol" },
	["WEAPON_TITAN18"] = { model = "w_pi_kyrostitan18", hash = GetHashKey("WEAPON_TITAN18"), type = "Pistol" },
	["WEAPON_TITAN20S"] = { model = "w_pi_kyrostitan20s", hash = GetHashKey("WEAPON_TITAN20S"), type = "Pistol" },
	["WEAPON_TITAN22"] = { model = "w_pi_kyrostitan22", hash = GetHashKey("WEAPON_TITAN22"), type = "Pistol" },
	["WEAPON_TITAN22S"] = { model = "w_pi_kyrostitan22s", hash = GetHashKey("WEAPON_TITAN22S"), type = "Pistol" },
	["WEAPON_TITAN45"] = { model = "w_pi_kyrostitan45", hash = GetHashKey("WEAPON_TITAN45"), type = "Pistol" },
	["WEAPON_TITANDEMON"] = { model = "w_pi_kyrostitandemon", hash = GetHashKey("WEAPON_TITANDEMON"), type = "Pistol" },
	["WEAPON_P9A3"] = { model = "w_pi_kyrosp9a3", hash = GetHashKey("WEAPON_P9A3"), type = "Pistol" },
	["WEAPON_ILLTITAN19X"] = { model = "w_pi_kyrosilltitan19x", hash = GetHashKey("WEAPON_ILLTITAN19X"), type = "Pistol" },
	["WEAPON_RSR9"] = { model = "w_pi_kyrosrsr9", hash = GetHashKey("WEAPON_RSR9"), type = "Pistol" },
	["WEAPON_GGX4"] = { model = "w_pi_kyrosggx4", hash = GetHashKey("WEAPON_GGX4"), type = "Pistol" },
	["WEAPON_TTITAN45"] = { model = "w_pi_kyrosttitan45", hash = GetHashKey("WEAPON_TTITAN45"), type = "Pistol" },
	["WEAPON_PEIX9"] = { model = "w_pi_kyrospeix9", hash = GetHashKey("WEAPON_PEIX9"), type = "Pistol" },

	-- Firearms (Rifles, SMGs, Shotguns, etc.)
	["WEAPON_ADVANCEDRIFLE"] = { model = "w_ar_advancedrifle", hash = GetHashKey("WEAPON_ADVANCEDRIFLE"), type = "Firearm" },
	["WEAPON_ASSAULTRIFLE"] = { model = "w_ar_assaultrifle", hash = GetHashKey("WEAPON_ASSAULTRIFLE"), type = "Firearm" },
	["WEAPON_ASSAULTRIFLE_MK2"] = { model = "w_ar_assaultriflemk2", hash = GetHashKey("WEAPON_ASSAULTRIFLE_MK2"), type = "Firearm" },
	["WEAPON_ASSAULTSHOTGUN"] = { model = "w_sg_assaultshotgun", hash = GetHashKey("WEAPON_ASSAULTSHOTGUN"), type = "Firearm" },
	["WEAPON_ASSAULTSMG"] = { model = "w_sb_assaultsmg", hash = GetHashKey("WEAPON_ASSAULTSMG"), type = "Firearm" },
	["WEAPON_BATTLERIFLE"] = { model = "w_ar_battlerifle", hash = GetHashKey("WEAPON_BATTLERIFLE"), type = "Firearm" },
	["WEAPON_BULLPUPRIFLE"] = { model = "w_ar_bullpuprifle", hash = GetHashKey("WEAPON_BULLPUPRIFLE"), type = "Firearm" },
	["WEAPON_BULLPUPRIFLE_MK2"] = { model = "w_ar_bullpupriflemk2", hash = GetHashKey("WEAPON_BULLPUPRIFLE_MK2"), type = "Firearm" },
	["WEAPON_BULLPUPSHOTGUN"] = { model = "w_sg_bullpupshotgun", hash = GetHashKey("WEAPON_BULLPUPSHOTGUN"), type = "Firearm" },
	["WEAPON_CARBINERIFLE"] = { model = "w_ar_carbinerifle", hash = GetHashKey("WEAPON_CARBINERIFLE"), type = "Firearm" },
	["WEAPON_CARBINERIFLE_MK2"] = { model = "w_ar_carbineriflemk2", hash = GetHashKey("WEAPON_CARBINERIFLE_MK2"), type = "Firearm" },
	["WEAPON_COMBATMG"] = { model = "w_mg_combatmg", hash = GetHashKey("WEAPON_COMBATMG"), type = "Firearm" },
	["WEAPON_COMBATMG_MK2"] = { model = "w_mg_combatmgmk2", hash = GetHashKey("WEAPON_COMBATMG_MK2"), type = "Firearm" },
	["WEAPON_COMBATPDW"] = { model = "w_sb_pdw", hash = GetHashKey("WEAPON_COMBATPDW"), type = "Firearm" },
	["WEAPON_COMBATSHOTGUN"] = { model = "w_sg_pumpshotgunh4", hash = GetHashKey("WEAPON_COMBATSHOTGUN"), type = "Firearm" },
	["WEAPON_COMPACTLAUNCHER"] = { model = "w_lr_compactgl", hash = GetHashKey("WEAPON_COMPACTLAUNCHER"), type = "Firearm" },
	["WEAPON_COMPACTRIFLE"] = { model = "w_ar_compactrifle", hash = GetHashKey("WEAPON_COMPACTRIFLE"), type = "Firearm" },
	["WEAPON_DBSHOTGUN"] = { model = "w_sg_doublebarrel", hash = GetHashKey("WEAPON_DBSHOTGUN"), type = "Firearm" },
	["WEAPON_EMPLAUNCHER"] = { model = "w_lr_emplauncher", hash = GetHashKey("WEAPON_EMPLAUNCHER"), type = "Firearm" },
	["WEAPON_FIREWORK"] = { model = "w_lr_firework", hash = GetHashKey("WEAPON_FIREWORK"), type = "Firearm" },
	["WEAPON_GUSENBERG"] = { model = "w_sb_gusenberg", hash = GetHashKey("WEAPON_GUSENBERG"), type = "Firearm" },
	["WEAPON_HEAVYRIFLE"] = { model = "w_ar_heavyrifleh", hash = GetHashKey("WEAPON_HEAVYRIFLE"), type = "Firearm" },
	["WEAPON_HEAVYSHOTGUN"] = { model = "w_sg_heavyshotgun", hash = GetHashKey("WEAPON_HEAVYSHOTGUN"), type = "Firearm" },
	["WEAPON_HEAVYSNIPER"] = { model = "w_sr_heavysniper", hash = GetHashKey("WEAPON_HEAVYSNIPER"), type = "Firearm" },
	["WEAPON_HEAVYSNIPER_MK2"] = { model = "w_sr_heavysnipermk2", hash = GetHashKey("WEAPON_HEAVYSNIPER_MK2"), type = "Firearm" },
	["WEAPON_HOMINGLAUNCHER"] = { model = "w_lr_homing", hash = GetHashKey("WEAPON_HOMINGLAUNCHER"), type = "Firearm" },
	["WEAPON_MACHINEPISTOL"] = { model = "w_sb_compactsmg", hash = GetHashKey("WEAPON_MACHINEPISTOL"), type = "Firearm" },
	["WEAPON_MARKSMANRIFLE"] = { model = "w_sr_marksmanrifle", hash = GetHashKey("WEAPON_MARKSMANRIFLE"), type = "Firearm" },
	["WEAPON_MARKSMANRIFLE_MK2"] = { model = "w_sr_marksmanriflemk2", hash = GetHashKey("WEAPON_MARKSMANRIFLE_MK2"), type = "Firearm" },
	["WEAPON_MG"] = { model = "w_mg_mg", hash = GetHashKey("WEAPON_MG"), type = "Firearm" },
	["WEAPON_MICROSMG"] = { model = "w_sb_microsmg", hash = GetHashKey("WEAPON_MICROSMG"), type = "Firearm" },
	["WEAPON_MILITARYRIFLE"] = { model = "w_ar_bullpuprifleh4", hash = GetHashKey("WEAPON_MILITARYRIFLE"), type = "Firearm" },
	["WEAPON_MINISMG"] = { model = "w_sb_minismg", hash = GetHashKey("WEAPON_MINISMG"), type = "Firearm" },
	["WEAPON_MUSKET"] = { model = "w_ar_musket", hash = GetHashKey("WEAPON_MUSKET"), type = "Firearm" },
	["WEAPON_PUMPSHOTGUN"] = { model = "w_sg_pumpshotgun", hash = GetHashKey("WEAPON_PUMPSHOTGUN"), type = "Firearm" },
	["WEAPON_PUMPSHOTGUN_MK2"] = { model = "w_sg_pumpshotgunmk2", hash = GetHashKey("WEAPON_PUMPSHOTGUN_MK2"), type = "Firearm" },
	["WEAPON_RAILGUN"] = { model = "w_ar_railgun", hash = GetHashKey("WEAPON_RAILGUN"), type = "Firearm" },
	["WEAPON_RAILGUNXM3"] = { model = "w_ar_railgunxm3", hash = GetHashKey("WEAPON_RAILGUNXM3"), type = "Firearm" },
	["WEAPON_RAYCARBINE"] = { model = "w_ar_srifle", hash = GetHashKey("WEAPON_RAYCARBINE"), type = "Firearm" },
	["WEAPON_RPG"] = { model = "w_lr_rpg", hash = GetHashKey("WEAPON_RPG"), type = "Firearm" },
	["WEAPON_SAWNOFFSHOTGUN"] = { model = "w_sg_sawnoff", hash = GetHashKey("WEAPON_SAWNOFFSHOTGUN"), type = "Firearm" },
	["WEAPON_SMG"] = { model = "w_sb_smg", hash = GetHashKey("WEAPON_SMG"), type = "Firearm" },
	["WEAPON_SMG_MK2"] = { model = "w_sb_smgmk2", hash = GetHashKey("WEAPON_SMG_MK2"), type = "Firearm" },
	["WEAPON_SNIPERRIFLE"] = { model = "w_sr_sniperrifle", hash = GetHashKey("WEAPON_SNIPERRIFLE"), type = "Firearm" },
	["WEAPON_SPECIALCARBINE"] = { model = "w_ar_specialcarbine", hash = GetHashKey("WEAPON_SPECIALCARBINE"), type = "Firearm" },
	["WEAPON_SPECIALCARBINE_MK2"] = { model = "w_ar_specialcarbinemk2", hash = GetHashKey("WEAPON_SPECIALCARBINE_MK2"), type = "Firearm" },
	["WEAPON_AUTOSHOTGUN"] = { model = "w_sg_sweeper", hash = GetHashKey("WEAPON_AUTOSHOTGUN"), type = "Firearm" },
	["WEAPON_RAYMINIGUN"] = { model = "w_mg_sminigun", hash = GetHashKey("WEAPON_RAYMINIGUN"), type = "Firearm" },
	["WEAPON_PRECISIONRIFLE"] = { model = "w_sr_precisionrifle", hash = GetHashKey("WEAPON_PRECISIONRIFLE"), type = "Firearm" },
	["WEAPON_TACTICALRIFLE"] = { model = "w_ar_tacticalrifle", hash = GetHashKey("WEAPON_TACTICALRIFLE"), type = "Firearm" },
	["WEAPON_SNOWLAUNCHER"] = { model = "w_lr_snowlauncher", hash = GetHashKey("WEAPON_SNOWLAUNCHER"), type = "Firearm" },
	["WEAPON_MINIGUN"] = { model = "w_mg_minigun", hash = GetHashKey("WEAPON_MINIGUN"), type = "Firearm" },
	["WEAPON_GRENADELAUNCHER"] = { model = "w_lr_grenadelauncher", hash = GetHashKey("WEAPON_GRENADELAUNCHER"), type = "Firearm" },

	-- KYROS RIFLES (NEW)
	["WEAPON_BLUEARP"] = { model = "w_ar_kyrosbluearp", hash = GetHashKey("WEAPON_BLUEARP"), type = "Firearm" },
	["WEAPON_DVIPER"] = { model = "w_ar_kyrosdviper", hash = GetHashKey("WEAPON_DVIPER"), type = "Firearm" },
	["WEAPON_AR16"] = { model = "w_ar_kyrosar16", hash = GetHashKey("WEAPON_AR16"), type = "Firearm" },
	["WEAPON_STKLANCE"] = { model = "w_ar_kyrosstklance", hash = GetHashKey("WEAPON_STKLANCE"), type = "Firearm" },
	["WEAPON_TMK47"] = { model = "w_ar_kyrostmk47", hash = GetHashKey("WEAPON_TMK47"), type = "Firearm" },
	["WEAPON_RAVEN7K"] = { model = "w_ar_kyrosraven7k", hash = GetHashKey("WEAPON_RAVEN7K"), type = "Firearm" },
	["WEAPON_CBREN"] = { model = "w_ar_kyroscbren", hash = GetHashKey("WEAPON_CBREN"), type = "Firearm" },
	["WEAPON_MKALASH"] = { model = "w_ar_kyrosmkalash", hash = GetHashKey("WEAPON_MKALASH"), type = "Firearm" },

	-- KYROS SMGs (NEW)
	["WEAPON_RAPEX"] = { model = "w_sb_kyrosrapex", hash = GetHashKey("WEAPON_RAPEX"), type = "Firearm" },
	["WEAPON_KSUB2000"] = { model = "w_sb_kyrosksub2000", hash = GetHashKey("WEAPON_KSUB2000"), type = "Firearm" },
	["WEAPON_MAYO41"] = { model = "w_sb_kyrosmayo41", hash = GetHashKey("WEAPON_MAYO41"), type = "Firearm" },
	["WEAPON_MSTORM"] = { model = "w_sb_kyrosmstorm", hash = GetHashKey("WEAPON_MSTORM"), type = "Firearm" },
	["WEAPON_RAVEN9D"] = { model = "w_sb_kyrosraven9d", hash = GetHashKey("WEAPON_RAVEN9D"), type = "Firearm" },

	-- KYROS SHOTGUNS (NEW)
	["WEAPON_BH1301"] = { model = "w_sg_kyrosbh1301", hash = GetHashKey("WEAPON_BH1301"), type = "Firearm" },
	["WEAPON_MINISHOTGUN"] = { model = "w_sg_kyrosminishotgun", hash = GetHashKey("WEAPON_MINISHOTGUN"), type = "Firearm" },
}
