function SoundAlerter:GetSpellList () 
	return {
		auraApplied ={					-- aura applied [spellid] = ".mp3 file name",
			--general
			--druid
		--	[61336] = "survivalInstincts", 2.4
			[29166] = "innervate",
			[22812] = "barkskin",
			[17116] = "naturesSwiftness",
			[16689] = "naturesGrasp",
			[22842] = "frenziedRegeneration",
			[5229] = "enrage",
			[1850] = "dash",
			--[50334] = "berserk", 2.4
			--[48505] = "starfall", 2.4
		--	[69369] = "predatorSwiftness", 2.4
			--paladin
			[31821] = "auraMastery",
			[1022] = "handOfProtection",
			[1044] = "handOfFreedom",
			[1020] = "divineShield",
			[642] = "divineShield",
			[6940] = "sacrifice",
			--[54428] = "divinePlea", 2.4
			--[85696] = "zealotry", 2.4
			[31884] = "avengingWrath",
			--rogue
		--	[51713] = "shadowDance", 2.4
			[2983] = "sprint",
			[11305] = "sprint",
			[31224] = "cloakOfShadows",
			[13750] = "adrenalineRush",
			[5277] = "evasion",
			[26669] = "evasion",
		--	[74001] = "combatReadiness", 2.4
			--warrior
			--[55694] = "enragedRegeneration", 2.4
			[871] = "shieldWall",					--untested
			[18499] = "berserkerRage",				--WORKS
			[12975] = "lastStand",					--WORKS
			[20230] = "retaliation",				--WORKS
			[23920] = "spellReflection",			--WORKS
			[12328] = "sweepingStrikes",			--WORKS
			[12292] = "deathWish",					--WORKS
			[1719] = "recklessness",				--WORKS
			--priest
			[33206] = "painSuppression",
			[37274] = "powerInfusion",
			[6346] = "fearWard",
		--	[47585] = "dispersion", 2.4
		--	[89485] = "innerFocus", 2.4
		--	[87153] = "darkArchangel", 2.4
		--	[87152] = "archangel", 2.4
		--	[47788] = "guardianSpirit", 2.4
			--shaman
			[30823] = "shamanisticRage",
			[974] = "earthShield",
			[16188] = "naturesSwiftness2",
			--[79206] = "spiritwalkersGrace", 2.4
			[16166] = "elementalMastery",
			--mage
			[12042] = "arcanePower",
			[12472] = "icyVeins",
			[45438] = "iceBlock",
			[12043] = "PresenceofMind",
		--[[	dk 2.4
			[49222] = "boneshield",
			[49039] = "lichborne",
			[48792] = "iceboundFortitude",
			[55233] = "vampiricBlood",
			[49016] = "unholyFrenzy",
			[51271] = "pillarofFrost",]]
			--hunter
			[34471] = "theBeastWithin",
			[19263] = "deterrence",
			[3045] = "rapidFire",
		--	[54216] = "mastersCall", 2.4
		},
		auraRemoved = {	
			--druid
		--	[48505] = "starfalldown",
			--dk 2.4
		--[[
			[49039] = "lichborneDown",
			[48792] = "iceboundFortitudeDown",]]
			--warr
			[12292] = "deathWishdown",
			[1719] = "recklessnessdown",
			[871] = "shieldWallDown",
			--paladin
			[642] = "bubbleDown",
			[1020] = "bubbleDown",
			[1022] = "protectionDown",
			--priest
		--	[47585] = "dispersionDown", 2.4
			[33206] = "PSDown",
			--rogue
			[31224] = "cloakDown",
			--[74001] = "combatReadinessDown", 2.4
			[5277] = "evasionDown",
			[26669] = "evasionDown",
			--mage
			[45438] = "iceBlockDown",
			--[34471] = "theBeastWithinDown",
			--hunter
			[19263] = "deterrenceDown",
		},
		castStart = {--1856 = vanish
			--general
			[2060] = "bigHeal",
			[82326] = "bigHeal",
			[77472] = "bigHeal",
			[5185] = "bigHeal",
			[2006] = "resurrection",
			[7328] = "resurrection",
			[2008] = "resurrection",
			[50769] = "resurrection",
			--hunter
			[982] = "revivePet",
			[19434] = "aimedshot",
			[1513] = "scareBeast",
			--druid
			[2637] = "hibernate",
			[33786] = "cyclone",
			[2912] = "starfire",
			--paladin
			--rogue
			--warrior
			--preist		
			[8129] = "manaBurn",
			[9484] = "shackleUndead",
			[605] = "mindControl",
			--shaman
			--[51514] = "hex", 2.4 FIXME
		--	[76780] = "bindElemental", 2.4
			--mage
			[118] = "polymorph",
			[28272] = "polymorph",
			[61305] = "polymorph",
			[61721] = "polymorph",
			[61025] = "polymorph",
			[61780] = "polymorph",
			[12826] = "polymorph",
			[28271] = "polymorph",
			--dk
		--[49203] = "hungeringCold", 2.4
			--warlock
			[710] = "banish",
			[5782] = "fear",
			[5484] = "fear2",
			[691] = "summonDemon",
			[712] = "summonDemon",
			[697] = "summonDemon",
			[688] = "summonDemon",
		},
		castSuccess = {
			--general
			[20572] = "BloodFury", 
			[33702] = "BloodFury", 
		--	[58984] = "shadowmeld", 2.4
			[26297] = "berserking",
			[28880] = "giftofthenaaru",
			[20594] = "stoneform",
			[7744] = "willOfTheForsaken",
			[42292] = "trinket",
			--[59752] = "Trinket", 2.4
			--druid
		--	[80964] = "skullBash", 2.4
		--	[80965] = "skullBash", 2.4
			[740] = "tranquility", 
		--	[78675] = "solarBeam", 2.4
			--paladin
		--	[96231] = "rebuke", 2.4
			[20066] = "repentance",
			[853] = "hammerofjustice",
			--rogue
			[13877] = "bladeflurry",
			[1784] = "stealth",
			[1787] = "stealth",
			[6770] = "sap",
			[11297] = "sap",
			--[51722] = "disarm2", 2.4
			[2094] = "blind", 
			[1766] = "kick",
			[14185] = "preparation",
			[1856] = "vanish",
		--	[76577] = "smokeBomb", 2.4
			[14177] = "coldblood",
		--	[73981] = "redirect", 2.4
			--warrior
			[676] = "disarm",					--WORKS
			[5246] = "fear3",					--WORKS (intimidating shout)
			[6552] = "pummel",					--WORKS
			[6554] = "pummel",					--WORKS
			[29704] = "shieldBash",
			--[85388] = "throwdown",  2.4
			[2457] = "battlestance",
			[71] = "defensestance",
			[2458] = "berserkerstance",
			--priest
			[10890] = "fear4",
			[8122] = "fear4",
			[34433] = "shadowFiend",
		--	[64044] = "disarm3", 2.4
			[15487] = "silence",
		--	[64843] = "divineHymn", 2.4
			[19236] = "desperatePrayer",
			--shaman
			--[52127] = "waterShield", 2.4
			[8177] = "grounding",
			[16190] = "manaTide",
			[8143] = "tremorTotem",
		--	[98008] = "spiritlinktotem", 2.4
			--mage
			[11129] = "Combustion",
			[11958] = "coldSnap",
			--[44572] = "deepFreeze", 2.4
			[2139] = "counterspell",
			[66] = "invisibility",
		--	[82676] = "ringOfFrost", 2.4
			[12051] = "evocation",
			--dk
			--[[[61606] = "markofblood", 2.4
			[47528] = "mindFreeze",
			[47476] = "strangulate",
			[47568] = "runeWeapon",
			[49206] = "gargoyle",
			[77606] = "darkSimulacrum", ]]
			--hunter
			[19386] = "wyvernSting",
			[23989] = "readiness",
			--[51755] = "camouflage",
			[19503] = "scattershot",
			[34490] = "silencingshot",
			[1499] = "freezingTrap",
		--	[60192] = "freezingTrap2", 2.4
			--warlock
			[6789] = "deathCoil",
			[5484] = "fear2", 
			[19647] = "spellLock", 
			--[48020] = "demonicCircleTeleport", 2.4
			--[77801] = "demonSoul", 2.4
		},
		friendlyInterrupt = {
			[19647] = "lockout", -- Spell Lock
			[2139] = "lockout", -- Counter Spell
			[1766] = "lockout", -- Kick
			[6552] = "lockout", -- Pummel
			[47528] = "lockout", -- Mind Freeze
			--[96231] = "lockout", -- Rebuke  2.4
			[93985] = "lockout", -- Skull Bash
			[97547] = "lockout", -- Solar Beam
		},
		enemyDebuffs = {
			[2094] = "Enemyblinded",
			[6770] = "Enemysapped",
			[11297] = "Enemysapped",
		--	[51514] = "Enemyhexxed", 2.4 FIXME
			[28272] = "Enemypollied",
			[118] = "EnemyPollied",
			[12826] = "EnemyPollied",
			[33786] = "Enemycycloned",
		},
		enemyDebuffdown = {
			[2094] = "Blinddown",
			[6770] = "Sapdown",
			[11297] = "Sapdown",
		--	[51514] = "Hexdown", 2.4 FIXME
			[12826] = "Polydown",
			[28272] = "Polydown",
			[118] = "Polydown",
			[33786] = "cyclonedown",
		},
		friendCCcast = {
			[33786] = "cyclonefriend",
			--[51514] = "hexfriend",  2.4 FIXME
			[118] = "polyfriend",
			[12826] = "polyfriend",
			[28272] = "polyfriend",
			[61305] = "polyfriend", 
			[61721] = "polyfriend", 
			[61025] = "polyfriend", 
			[61780] = "polyfriend", 
			[28271] = "polyfriend", 
			[5782] = "fearfriend",
		},
		friendCCSuccess = {
			[2094] = "blindfriend",
			[5246] = "friendfeared",
			[6770] = "friendsapped",
			[11297] = "friendsapped",
			[33786] = "friendcycloned",
			[853] = "friendstunned",
			--[51514] = "friendhexxed", 2.4 FIXME
			[118] = "friendpollied",
			[5782] = "friendfeared",
			[8122] = "friendfeared",
			[5484] = "friendfeared",
		},
	}
end

