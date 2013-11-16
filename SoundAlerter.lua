--[[
SoundAlerter by Trolollolol
If you have any issues or concerns with the addon, Send me an ingame message at  
Trolollolol - Realm:Ragnaros Server:Molten-WoW.com, or message me on the forums at
http://forum.molten-wow.com/member.php?u=856331
Known Bugs: 
-Server interrupt bug
 Bug report here: http://forum.molten-wow.com/bugtraq.php?do=view&vbug_id=10253
-Vanish bug - not reported yet but there is no combat log event for vanish for some reason.
]]
SoundAlerter = LibStub("AceAddon-3.0"):NewAddon("SoundAlerter", "AceEvent-3.0","AceConsole-3.0","AceTimer-3.0")

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("SoundAlerter")
local LSM = LibStub("LibSharedMedia-3.0")
local self ,SoundAlerter = SoundAlerter ,SoundAlerter
local playerName = UnitName("player")
local icondir = "\124TInterface\\Icons\\"
local icondir2 = ".blp:24\124t"

local getSpellDescription
do
	local cache = {}
	local scanner = CreateFrame("GameTooltip")
	scanner:SetOwner(WorldFrame, "ANCHOR_NONE")
	local lcache, rcache = {}, {}
	for i = 1, 4 do
		lcache[i], rcache[i] = scanner:CreateFontString(), scanner:CreateFontString()
		lcache[i]:SetFontObject(GameFontNormal); rcache[i]:SetFontObject(GameFontNormal)
		scanner:AddFontStrings(lcache[i], rcache[i])
	end
	function getSpellDescription(spellId)
		if cache[spellId] then return cache[spellId] end
		scanner:ClearLines()
		scanner:SetHyperlink("spell:"..spellId)
		for i = scanner:NumLines(), 1, -1  do
			local desc = lcache[i] and lcache[i]:GetText()
			if desc then
				cache[spellId] = desc
				return desc
			end
		end
	end
end

function SoundAlerter:GetSpellDescription(spellID)
	local s = getSpellDescription(spellID)
	if s then
		return s
	else
		return "SpellID: " .. tostring(spellID)
	end
end

SA_LOCALEPATH = {
	enUS = "SoundAlerter\\Voice_enUS",
	zhTW = "SoundAlerter\\Voice",
	zhCN = "SoundAlerter\\Voice"
}
self.SA_LOCALEPATH = SA_LOCALEPATH
local SA_LANGUAGE = {
	["SoundAlerter\\Voice_enUS"] = L["English (Female)"],
}
local SA_CHATGROUP = {
	["SAY"] = L["Say"],
	["PARTY"] = L["Party"],
	["RAID"] = L["Raid"],
	["BATTLEGROUND"] = "Battleground",
}
self.SA_CHATGROUP = SA_CHATGROUP
self.SA_LANGUAGE = SA_LANGUAGE
local SA_EVENT = {
	SPELL_CAST_SUCCESS = L["Spell was successfully casted"],
	SPELL_CAST_START = L["Spell is casting"],
	SPELL_AURA_APPLIED = L["Spell buff has been casted"],
	SPELL_AURA_REMOVED = L["Spell buff is down"],
	SPELL_INTERRUPT = L["Spell is interrupted"],
	SPELL_SUMMON = L["Summoning spell"]
	--UNIT_AURA = "Unit aura changed",
}
local SA_UNIT = {
	any = L["Any"],
	player = L["Player"],
	target = L["Target"],
	focus = L["Focus"],
	mouseover = L["Mouseover"],
	party = L["Party"],
--	raid = L["Raid"],
	arena = L["Arena (enemy)"],
--	boss = L["Boss"],
	custom = L["Custom"], 
}
local SA_TYPE = {
	[COMBATLOG_FILTER_EVERYTHING] = L["Any"],
	[COMBATLOG_FILTER_FRIENDLY_UNITS] = L["Friendly"],
	[COMBATLOG_FILTER_HOSTILE_PLAYERS] = L["Hostile player"],
	[COMBATLOG_FILTER_HOSTILE_UNITS] = L["Hostile unit"],
	[COMBATLOG_FILTER_NEUTRAL_UNITS] = L["Neutral"],
	[COMBATLOG_FILTER_ME] = L["Myself"],
	[COMBATLOG_FILTER_MINE] = L["Mine"],
	[COMBATLOG_FILTER_MY_PET] = L["My pet"],
}
local sourcetype,sourceuid,desttype,destuid = {},{},{},{}
local sadb
local PlaySoundFile = PlaySoundFile

local function log(msg) DEFAULT_CHAT_FRAME:AddMessage("|cFF33FF22SA|r:"..msg) end

function SoundAlerter:OnInitialize()
	if not self.spellList then
		self.spellList = self:GetSpellList()
	end
	for _,v in pairs(self.spellList) do
		for _,spell in pairs(v) do
			if dbDefaults.profile[spell] == nil then dbDefaults.profile[spell] = true end
		end
	end
	self.db1 = LibStub("AceDB-3.0"):New("SoundAlerterDB",dbDefaults, "Default");
	DEFAULT_CHAT_FRAME:AddMessage("|cffFF7D0ASoundAlerter|r for 4.3.4 by |cff0070DETrolollolol|r - Ragnaros - molten-wow.com - /SOUNDALERTER ");
	--DEFAULT_CHAT_FRAME:AddMessage(SA_TEXT .. SA_VERSION .. SA_AUTHOR .."  - /SA ");
	--LibStub("AceConfig-3.0"):RegisterOptionsTable("SoundAlerter", SoundAlerter.Options, {"SoundAlerter", "SS"})
	self:RegisterChatCommand("SoundAlerter", "ShowConfig")
	self:RegisterChatCommand("SA", "ShowConfig")
	self:RegisterChatCommand("SALERTER", "ShowConfig")
	self.db1.RegisterCallback(self, "OnProfileChanged", "ChangeProfile")
	self.db1.RegisterCallback(self, "OnProfileCopied", "ChangeProfile")
	self.db1.RegisterCallback(self, "OnProfileReset", "ChangeProfile")
	sadb = self.db1.profile
	SoundAlerter.options = {
		name = "SoundAlerter",
		desc = L["PVP Voice Alert"],
		type = 'group',
		args = {},
	}
	local bliz_options = CopyTable(SoundAlerter.options)
	bliz_options.args.load = {
		name = L["Load Configuration"],
		desc = L["Load Configuration Options"],
		type = 'execute',
		func = "ShowConfig",
		handler = SoundAlerter,
	}
	LibStub("AceConfig-3.0"):RegisterOptionsTable("SoundAlerter_bliz", bliz_options)
	AceConfigDialog:AddToBlizOptions("SoundAlerter_bliz", "SoundAlerter")
end

function SoundAlerter:OnEnable()
	SoundAlerter:RegisterEvent("PLAYER_ENTERING_WORLD")
	SoundAlerter:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
--	SoundAlerter:RegisterEvent("UNIT_AURA")
	--SoundAlerter:RegisterEvent("CHAT_MSG_ADDON")
	if not SA_LANGUAGE[sadb.path] then sadb.path = SA_LOCALEPATH[GetLocale()] end
	self.throttled = {}
	self.smarter = 0
end
function SoundAlerter:OnDisable()
end
local function initOptions()
	--[[if SoundAlerter.options.args.general then
		return
	end]]

	SoundAlerter:OnOptionsCreate()

	for k, v in SoundAlerter:IterateModules() do
		if type(v.OnOptionsCreate) == "function" then
			v:OnOptionsCreate()
		end
	end
	AceConfig:RegisterOptionsTable("SoundAlerter", SoundAlerter.options)
end
function SoundAlerter:ShowConfig()
	initOptions()
	AceConfigDialog:SetDefaultSize("SoundAlerter",800, 500)
	AceConfigDialog:Open("SoundAlerter")
end
function SoundAlerter:ChangeProfile()
	sadb = self.db1.profile
	for k,v in SoundAlerter:IterateModules() do
		if type(v.ChangeProfile) == 'function' then
			v:ChangeProfile()
		end
	end
end
function SoundAlerter:AddOption(key, table)
	self.options.args[key] = table
end

local function setOption(info, value)
	local name = info[#info]
	sadb[name] = value
	if value then 
		PlaySoundFile("Interface\\Addons\\"..sadb.path.."\\"..name..".ogg","Master");
	end
end
local function getOption(info)
	local name = info[#info]
	return sadb[name]
end
	GameTooltip:HookScript("OnTooltipSetUnit", function(tip)
        local name, server = tip:GetUnit()
		local Realm = GetRealmName()
        if (SA_sponsors[name] ) then if ( SA_sponsors[name]["Realm"] == Realm ) then
		tip:AddLine(SA_sponsors[SA_sponsors[name].Type], 1, 0, 0 ) end; end
    end)
local function spellOption(order, spellID, ...)
	local spellname,_,icon = GetSpellInfo(spellID)
	if spellname ~= nil then
	return {
		type = 'toggle',
		name = "\124T"..icon..":24\124t"..spellname,							
		desc = function () 
			return self:GetSpellDescription(spellID)
		end,
		--descStyle = "custom",
		order = order,
	}
	else
	self:Print("error loading spell ID " ..spellID .. " as it seems to not exist (anymore). Check if you're using the correct version of SoundAlerter")
	end
end
local function listOption(spellList, listType, ...)
	local args = {}
	for k,v in pairs(spellList) do
		rawset (args, self.spellList[listType][v] ,spellOption(k, v))
	end
	return args
end
function SoundAlerter:OnOptionsCreate()
	
	self:AddOption("profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db1))
	self.options.args.profiles.order = -1
	self:AddOption('genaral', {
		type = 'group',
		name = L["General"],
		desc = L["General options"],
		set = setOption,
		get = getOption,
		order = 1,
		args = {
			enableArea = {
				type = 'group',
				inline = true,
				name = L["Area sound alert conditions"],
				order = 1,
				args = {
					all = {
						type = 'toggle',
						name = L["Everywhere"],
						desc = L["Sound alerts are enabled everywhere"],
						order = 1,
					},
					arena = {
						type = 'toggle',
						name = L["Arena"],
						desc = L["Sound alerts work in arenas"],
						disabled = function() return sadb.all end,
						order = 2,
					},
					NewLine1 = {
						type= 'description',
						order = 3,
						name= '',
					},
					battleground = {
						type = 'toggle',
						name = L["Battleground"],
						desc = L["Sound alerts work in battlegrounds"],
						disabled = function() return sadb.all end,
						order = 4,
					},
					field = {
						type = 'toggle',
						name = L["World"],
						desc = L["Sound alerts are enabled for outside battlegrounds and arenas"],
						disabled = function() return sadb.all end,
						order = 5,
					}
				},
			},
			volumecontrol = {
					type = 'group',
					inline = true,
					order = 2,
					name = "Sound Options",
					args = {
						path = {
						type = 'select',
						name = L["Voice language"],
						desc = L["Sets langauage for sound alerts"],
						values = SA_LANGUAGE,
						order = 4,
						},
						volumn = {
						type = 'range',
						max = 1,
						min = 0,
						isPercent = true,
						step = 0.01,
						name = "Master Volume",
						desc = "Sets the master volume so sound alerts can be louder/softer",
						set = function (info, value) SetCVar ("Sound_MasterVolume",tostring (value)) end,
						get = function () return tonumber (GetCVar ("Sound_MasterVolume")) end,
						order = 1,
							},
						volumn2 = {
						type = 'execute',
						width = 'normal',
						name = "Addon sounds only",
						desc = "Sets other sounds to minimum, only hearing the addon sounds",
						func = function() 
								SetCVar ("Sound_AmbienceVolume",tostring ("0")); SetCVar ("Sound_SFXVolume",tostring ("0")); SetCVar ("Sound_MusicVolume",tostring ("0")); 
								self:Print("Addons will only be heard by your Client. To undo this, click the 'reset sound options' button.");
							end,
						order = 2,
							},
						volumn3 = {
						type = 'execute',
						width = 'normal',
						name = "Reset volume options",
						desc = "Resets sound options",
						func = function() 
								SetCVar ("Sound_MasterVolume",tostring ("1")); SetCVar ("Sound_AmbienceVolume",tostring ("1")); SetCVar ("Sound_SFXVolume",tostring ("1")); SetCVar ("Sound_MusicVolume",tostring ("1")); 
								self:Print("Sound options reset.");
							end,
						order = 3,
							},
						},
					},
			advance = {
				type = 'group',
				inline = true,
				name = L["Advanced options"],
				order = 3,
				args = {
					smartDisable = {
						type = 'toggle',
						name = L["Smart disable"],
						desc = L["Disable addon for a moment if you're hearing too many alerts at once"],
						order = 1,
					},
					throttle = {
						type = 'range',
						max = 5,
						min = 0,
						step = 0.1,
						name = L["Throttle"],
						desc = L["The minimum interval of each alert"],
						order = 2,
					},
					debugmode = {
						type = 'toggle',
						name = "Debug Mode",
						desc = "Enable Debugging",
						order = 3,
					},
				},
			},
		}
	})
	self:AddOption('spell', {
		type = 'group',
		name = L["Spells"],
		desc = L["Spell options"],
		set = setOption,
		get = getOption,
		order = 2,
		args = {
			spellGeneral = {
				type = 'group',
				name = L["Disable options"],
				desc = L["Disable abilities by type"],
				inline = true,
				order = -1,
				args = {
					aruaApplied = {
						type = 'toggle',
						name = L["Disable Enemy Buffs"],
						desc = L["Disables sound alerts for enemies that gain buffs"],
						order = 1,
					},
					aruaRemoved = {
						type = 'toggle',
						name = L["Disable Enemy Buff Down"],
						desc = L["Disables sound alerts for an enemies buff that has been taken off"],
						order = 2,
					},
					castStart = {
						type = 'toggle',
						name = L["Disable Spell Casting"],
						desc = L["Disables sound alerts for enemies casting spells"],
						order = 3,
					},
					castSuccess = {
						type = 'toggle',
						name = L["Disable enemy cooldown abilities"],
						desc = L["Disables sound alerts for enemies casting cooldown abilities"],
						order = 4,
					},
					interrupt = {
						type = 'toggle',
						name = L["Disable interrupts on enemy"],
						desc = L["Disables sound alerts for interrupting enemies"],
						order = 5,
					},
					chatalerts = {
						type = 'toggle',
						name = "Disable Chat Alerts",
						desc = "Disbles Chat notifications of special abilities in the chat bar",
						order = 6,
					},
					ArenaPartner = {
						type = 'toggle',
						name = "Disable Arena Partner debuff/CC alerts",
						desc = "Check this option to disable notifications of Arena Partner debuff/CC alerts",
						order = 7,
					}
				},
			},
			spellAuraApplied = {
				type = 'group',
				--inline = true,
				name = L["Enemy Buffs"],
				disabled = function() return sadb.aruaApplied end,
				order = 1,
				args = {
					aonlyTF = {
						type = 'toggle',
						name = L["Target and Focus only"],
						desc = L["Alerts you when your target or focus is applicable to a sound alert"],
						order = 1,
					},
					drinking = { 
						type = 'toggle',
						name = L["Alert Drinking"],
						desc = L["Gives a sound alert when an enemy is drinking in arenas"],
						order = 3,
					},
					--[[general = {
						type = 'group',
						inline = true,
						name = L["General"],
						order = 4,
						args = listOption({42292,20594,7744},"auraApplied"),
					},]]
					druid = {
						type = 'group',
						inline = true,
						name = L["|cffFF7D0ADruid|r"],
						order = 5,
						args = listOption({29166,22812,17116,16689,22842,5229,1850},"auraApplied"),	
					},
					paladin = {
						type = 'group',
						inline = true,
						name = L["|cffF58CBAPaladin|r"],
						order = 6,
						args = listOption({31821,1022,1044,1020,6940,31884},"auraApplied"),
					},
					rogue = {
						type = 'group',
						inline = true,
						name = L["|cffFFF569Rogue|r"],
						order = 7,
						args = listOption({2983,31224,13750,5277},"auraApplied"),
					},
					warrior	= {
						type = 'group',
						inline = true,
						name = L["|cffC79C6EWarrior|r"],
						order = 8,
						args = listOption({871,18499,20230,12975,23920,12328,12292,1719},"auraApplied"),	
					},
					priest	= {
						type = 'group',
						inline = true,
						name = L["|cffFFFFFFPriest|r"],
						order = 9,
						args = listOption({33206,37274,6346},"auraApplied"),
					},
					shaman	= {
						type = 'group',
						inline = true,
						name = L["|cff0070DEShaman|r"],
						order = 10,
						args = listOption({30823,974,16188,16166},"auraApplied"),
					},
					mage = {
						type = 'group',
						inline = true,
						name = L["|cff69CCF0Mage|r"],
						order = 11,
						args = listOption({12042,12472,45438,12043},"auraApplied"),
					},
					hunter = {
						type = 'group',
						inline = true,
						name = L["|cffABD473Hunter|r"],
						order = 12,
						args = listOption({34471,19263,3045},"auraApplied"),
					},
				},
			},
			spellAuraRemoved = {
				type = 'group',
				--inline = true,
				name = L["Enemy Buff Down"],
				disabled = function() return sadb.aruaRemoved end,
				order = 2,
				args = {
					ronlyTF = {
						type = 'toggle',
						name = L["Target and Focus only"],
						desc = L["Alerts you when your target or focus is applicable to a sound alert"],
						order = 1,
					},
				--[[	druid = { 2.4
						type = 'group',
						inline = true,
						name = L["|cffFF7D0ADruid|r"],
						order = 2,
						args = listOption({48505},"auraRemoved"),
					},]]
					hunter = {
						type = 'group',
						inline = true,
						name = L["|cffABD473Hunter|r"],
						order = 3,
						args = listOption({19263},"auraRemoved"),
					},
					mage = {
						type = 'group',
						inline = true,
						name = L["|cff69CCF0Mage|r"],
						order = 4,
						args = listOption({45438},"auraRemoved"),
					},
					paladin = {
						type = 'group',
						inline = true,
						name = L["|cffF58CBAPaladin|r"],
						order = 5,
						args = listOption({1022,1020},"auraRemoved"),
					},
					priest	= {
						type = 'group',
						inline = true,
						name = L["|cffFFFFFFPriest|r"],
						order = 6,
						args = listOption({33206},"auraRemoved"),
					},
					rogue = {
						type = 'group',
						inline = true,
						name = L["|cffFFF569Rogue|r"],
						order = 7,
						args = listOption({31224,5277},"auraRemoved"),
					},
					warrior = {
						type = 'group',
						inline = true,
						name = L["|cffC79C6EWarrior|r"],
						order = 13,
						args = listOption({12292,1719,871},"auraRemoved"),
					},
				},
			},
			spellCastStart = {
				type = 'group',
				--inline = true,
				name = L["Enemy Spell Casting"],
				disabled = function() return sadb.castStart end,
				order = 2,
				args = {
					conlyTF = {
						type = 'toggle',
						name = L["Target and Focus only"],
						desc = L["Alerts you when your target or focus is applicable to a sound alert"],
						order = 1,
					},
					general = {
						type = 'group',
						inline = true,
						name = L["General"],
						order = 3,
						args = {
							bigHeal = {
								type = 'toggle',
								name = L["Big Heals"],
								desc = L["Greater Heal, Divine Light, Greater Healing Wave, Healing Touch"],
								order = 1,
							},
							resurrection = {
								type = 'toggle',
								name = L["Resurrection"],
								desc = L["Resurrection, Redemption, Ancestral Spirit, Revive"],
								order = 2,
							},
						}
					},
					druid = {
						type = 'group',
						inline = true,
						name = L["|cffFF7D0ADruid|r"],
						order = 4,
						args = listOption({2637,33786,2912},"castStart"),
					},
					preist	= {
						type = 'group',
						inline = true,
						name = L["|cffFFFFFFPriest|r"],
						order = 6,
						args = listOption({8129,9484,605},"castStart"),
					},
				--[[	shaman	= { --2.4
						type = 'group',
						inline = true,
						name = L["|cff0070DEShaman|r"],
						order = 7,
						args = listOption({51514},"castStart"),
					},]]
					mage = {
						type = 'group',
						inline = true,
						name = L["|cff69CCF0Mage|r"],
						order = 8,
						args = listOption({118},"castStart"),
					},
					hunter = {
						type = 'group',
						inline = true,
						name = L["|cffABD473Hunter|r"],
						order = 9,
						args = listOption({982,1513,19434},"castStart"),
					},
					warlock	= {
						type = 'group',
						inline = true,
						name = L["|cff9482C9Warlock|r"],
						order = 10,
						args = listOption({5782,5484,710,691},"castStart"),
					},
				},
			},
			spellCastSuccess = {
				type = 'group',
				--inline = true,
				name = L["Enemy cooldown abilities"],
				disabled = function() return sadb.castSuccess end,
				order = 3,
				args = {
					sonlyTF = {
						type = 'toggle',
						name = L["Target and Focus only"],
						desc = L["Alerts you when your target or focus is applicable to a sound alert"],
						order = 1,
					},
					class = {
						type = 'toggle',
						name = L["Class PvP Trinket"],
						desc = L["Announce Class name + trinketted in arena"],
						disabled = function() return not sadb.trinket end,
						order = 3,
					},
					general = {
						type = 'group',
						inline = true,
						name = L["General"],
						order = 4,
						args = listOption({20572,26297,28880,20594,7744,42292,42292},"castSuccess"),
					},
					druid = {
						type = 'group',
						inline = true,
						name = L["|cffFF7D0ADruid|r"],
						order = 5,
						args = listOption({740},"castSuccess"),
					},
					paladin = {
						type = 'group',
						inline = true,
						name = L["|cffF58CBAPaladin|r"],
						order = 6,
						args = listOption({20066,853},"castSuccess"),
					},
					rogue = {
						type = 'group',
						inline = true,
						name = L["|cffFFF569Rogue|r"],
						order = 7,
						args = listOption({13877,2094,1766,14185,1856,14177,6770,1784},"castSuccess"),
					},
					warrior	= {
						type = 'group',
						inline = true,
						name = L["|cffC79C6EWarrior|r"],
						order = 8,
						args = listOption({676,5246,6552,2457,71,2458,29704},"castSuccess"),	
					},
					preist	= {
						type = 'group',
						inline = true,
						name = L["|cffFFFFFFPriest|r"],
						order = 9,
						args = listOption({8122,34433,15487,19236},"castSuccess"),
					},
					shaman	= {
						type = 'group',
						inline = true,
						name = L["|cff0070DEShaman|r"],
						order = 10,
						args = listOption({8177,16190,8143},"castSuccess"),
					},
					mage = {
						type = 'group',
						inline = true,
						name = L["|cff69CCF0Mage|r"],
						order = 11,
						args = listOption({11129,11958,2139,66,12051},"castSuccess"),
					},
					hunter = {
						type = 'group',
						inline = true,
						name = L["|cffABD473Hunter|r"],
						order = 12,
						args = listOption({19386,19503,34490,23989,1499},"castSuccess"),
					},
					warlock = {
						type = 'group',
						inline = true,
						name = L["|cff9482C9Warlock|r"],
						order = 13,
						args = listOption({6789,5484,19647},"castSuccess"),
					},
				},
			},
			spellInterrupt = {
				type = 'group',
				--inline = true,
				name = L["Interrupts on enemy"],
				disabled = function() return sadb.interrupt end,
				order = 4,
				args = {
					lockout = {
						type = 'toggle',
						name = L["Interrupts on enemy"],
						desc = L["Spell Lock, Counterspell, Kick, Pummel, Mind Freeze, Skull Bash, Rebuke, Solar Beam"],
						order = 1,
					},
				}
			},
			enemydebuff = {
				type = 'group',
				--inline = true,
				name = "Enemy Debuff",
				desc = "Alerts you when an enemy has a CC",
				disabled = function() return sadb.enemydebuff end,
				order = 5,
				args = {
					fromanyone1 = {
						type = 'group',
						inline = true,
						name = "The spell could be casted by anyone. Applies to target and focus only",
						order = 1,
						args = listOption({2094,6770,118,33786},"enemyDebuffs"),
					},
				},
			},
			enemydebuffdown = {
				type = 'group',
				--inline = true,
				name = "Enemy Debuff Down",
				desc = "Alerts you when someone has casted a CC on your enemy is down",
				disabled = function() return sadb.enemydebuffdown end,
				order = 6,
				args = {
						fromanyone2 = {
						type = 'group',
						inline = true,
						name = "The spell could be casted by anyone. Applies to target and focus only",
						order = 1,
						args = listOption({2094,6770,118,33786},"enemyDebuffdown"),
					},
				},
			},
			chatalerter = {
				type = 'group',
				--inline = true,
				name = "Chat Alerts",
				desc = "Alerts you and others via sending a chat message",
				disabled = function() return sadb.chatalerts end,
				order = 4,
				args = {
					caonlyTF = {
						type = 'toggle',
						name = L["Target and Focus only"],
						desc = L["Alerts you when your target or focus is applicable to a sound alert"],
						order = 1,
					},
					chatgroup = {
						type = 'select',
						name = "What channel to alert in",
						desc = "You send a message to either party, raid, say or battleground with your chat alert",
						values = SA_CHATGROUP,
						order = 2,
					},
					spells = {
						type = 'group',
						inline = true,
						name = "Spells",
						order = 3,
						args = {
							stealthalert = {
								type = 'toggle',
								name = icondir.."Ability_Stealth"..icondir2..GetSpellInfo(1784),
								desc = function ()
									GameTooltip:SetHyperlink(GetSpellLink(1784));
								end,
								order = 1,
							},
							vanishalert = {
								type = 'toggle',
								name = icondir.."Ability_Vanish"..icondir2..GetSpellInfo(1856),
								desc = function ()
									GameTooltip:SetHyperlink(GetSpellLink(1856));
								end,
								order = 2,
							},
							blindonenemychat = {
								type = 'toggle',
								name = icondir.."Spell_Shadow_MindSteal"..icondir2.."Blind on Enemy",
								desc = "Enemies you blind will be alerted in chat",
								order = 3,
							},
							cyclonechat = {
								type = 'toggle',
								name = icondir.."spell_nature_earthbind"..icondir2.."Cyclone on Enemy",
								desc = "Enemies you cyclone will be alerted in chat",
								order = 4,
							},
							hexchat = {
								type = 'toggle',
								name = icondir.."spell_shaman_hex"..icondir2.."Hex on Enemy",
								desc = "Enemies you hex will be alerted in chat",
								order = 5,
							},
							fearchat = {--5782
								type = 'toggle',
								name = icondir.."spell_shadow_possession"..icondir2.."Fear on Enemy",
								desc = "Enemies you fear will be alerted in chat",
								order = 6,
							},
							blindalert = {
								type = 'toggle',
								name = icondir.."Spell_Shadow_MindSteal"..icondir2.."Blind on Self/Friend",
								desc = "Enemies that have blinded you will be alerted",
								order = 7,
							},
							sapalert = {
								type = 'toggle',
								name = icondir.."ability_sap"..icondir2.."Sap on Self/Friend",
								desc = "Enemies that have sapped you will be alerted",
								order = 8,
							},
							sapenemyalert = {
								type = 'toggle',
								name = icondir.."ability_sap"..icondir2.."Sap on Enemy",
								desc = "Enemies you sapped will be alerted",
								order = 8,
							},
							bubblealert = {
							type = 'toggle',
							name = icondir.."Spell_Holy_DivineIntervention"..icondir2.."Divine Shield",
							desc = "Enemies that have casted Divine Shield will be alerted",
							order = 9,
							},
							trinketalert = {
								type = 'toggle',
								name = GetSpellInfo(42292),
								desc = function ()
									GameTooltip:SetHyperlink(GetSpellLink(42292));
								end,
								order = 10,
							},
							interruptalert = {
								type = 'toggle',
								name = "Interrupts on Target",
								desc = "Alerts you if you have interrupted an enemys spell. Note: currently a server bug on Molten",
								order = 11,
							},
						},
					},
					InterruptTextg = {
						type = "group",
						inline = true,
						name = "Interrupt Text",
						order = 9,
						args = {
							InterruptText = {
							name = "Example: 'Interrupted' = Interrupted [PlayerName]: with [SpellName]",
							type = "input",
							order = 1,
							width = "full",
							},
						},
					},
					spelltextg = {
						type = "group",
						inline = true,
						name = icondir.."Ability_Vanish"..icondir2.."Vanish/Stealth Casting Text",
						order = 10,
						args = {
							spelltext = {
							type = "input",
							name = "Example: '[#enemy#] casted #spell#' = [Enemyname] casted [Vanish/Stealth]",
							order = 1,
							width = "full",
							},
						},
					},
					saptextg = {
						type = "group",
						inline = true,
						name = icondir.."ability_sap"..icondir2.."Sap on self",
						order = 11,
						args = {
							saptext = {
							type = "input",
							name = "Note: The WoW client may not know who sapped you, so don't use '#enemy#'",
							order = 1,
							width = "full",
							},
						},
					},
					blindtextg = {
						type = "group",
						inline = true,
						name = icondir.."Spell_Shadow_MindSteal"..icondir2.."Blind on Self",
						order = 12,
						args = {
							blindtext = {
							type = "input",
							name = "Note: #enemy# doesn't work on this",
							order = 1,
							width = "full",
							},
						},
					},
					saptextfriendg = {
						type = "group",
						inline = true,
						name = icondir.."ability_sap"..icondir2.."Sap on arena partner, target, or focus",
						order = 13,
						args = {
							saptextfriend = {
							type = "input",
							name = "Example: '#friend# is sapped!' = FriendName is sapped!",
							order = 1,
							width = "full",
							},
						},
					},
					blindtextfriendg = {
						type = "group",
						inline = true,
						name = icondir.."Spell_Shadow_MindSteal"..icondir2.."Blind on arena partner, target, or focus",
						order = 14,
						args = {
							blindtextfriend = {
							type = "input",
							name = "Example: '#friend# is afflicted by #spell#' = FriendName is afflicted by [Blind]",
							order = 1,
							width = "full",
							},
						},
					},
					ccenemychatg = {
						type = "group",
						inline = true,
						name = icondir.."spell_nature_earthbind"..icondir2.."Blind/Cyclone/Sap/Hex/Fear on enemy text",
						order = 15,
						args = {
							ccenemychat = {
							type = "input",
							name = "Example: '#spell# up on #enemy#' = [Sap] up on [EnemyName]",
							order = 1,
							width = "full",
							},
						},
					},
					bubblealerttextg = {
						type = "group",
						inline = true,
						name = icondir.."Spell_Holy_DivineIntervention"..icondir2.."Bubble text",
						order = 16,	
						args = {
							bubblealerttext = {
							type = 'input',
							name = "Example: '#enemy# casted #spell#!' = Enemyname casted [Divine Shield]!",
							order = 1,
							width = "full",
							},
						},
					},
				trinketalerttextg = {
						type = "group",
						inline = true,
						name = "PvP trinket text",
						order = 17,	
						args = {
							trinketalerttext = {
							type = 'input',
							name = "Example: '#enemy# casted #spell#!' = Enemyname casted [PvP Trinket]!",
							order = 1,
							width = "full",
							},
						},
					},
				},
			},
			FriendDebuff = {
				type = 'group',
				name = "Arena partner Enemy Spell Casting",
				desc = "Alerts you when an enemy is casting a spell to your arena partner",
				disabled = function() return sadb.ArenaPartner end,
				order = 7,
				args = {
					FriendDebuff2 = {
						type = 'group',
						inline = true,
						name = "You will be alerted when an enemy is casting a spell to your arena partner",
						order = 1,
						args = listOption({118,33786,5782},"friendCCcast"),
						},
					},
			},
			FriendDebuffSuccess = {
			type = 'group',
			name = "Friend CCs/Debuffs",
			desc = "Alerts you when your focus, target, or arena partner has got CC'd",
			disabled = function() return sadb.ArenaPartner end,
			order = 8,
			args = {
					friendDebuffSuccess2 = {
						type = 'group',
						inline = true,
						name = "You will be alerted when your friendly target, focus or arena partner has got CC'd",
						order = 1,
						args = listOption({2094,853,118,33786,5782,6770},"friendCCSuccess"),
					},
				}
			}	
		}
	})
	self:AddOption('custom', {
		type = 'group',
		name = L["Custom sound alert"],
		desc = L["Create a custom sound alert with your own ogg sound file"],
		order = 4,
		args = {
			newalert = {
				type = 'execute',
				name = L["New Sound Alert"],
				order = -1,
				func = function()
					sadb.custom[L["New Sound Alert"]] = {
						name = L["New Sound Alert"],
						soundfilepath = "Interface\\SASound\\"..L["New Sound Alert"]..".ogg",
						sourceuidfilter = "any",
						destuidfilter = "any",
						eventtype = {
							SPELL_CAST_SUCCESS = true,
							SPELL_CAST_START = false,
							SPELL_AURA_APPLIED = false,
							SPELL_AURA_REMOVED = false,
							SPELL_INTERRUPT = false,
						},
						sourcetypefilter = COMBATLOG_FILTER_EVERYTHING,
						desttypefilter = COMBATLOG_FILTER_EVERYTHING,
						order = 0,
					}
					self:OnOptionsCreate()
				end,
				disabled = function ()
					if sadb.custom[L["New Sound Alert"]] then
						return true
					else
						return false
					end
				end,
			}
		}
	})
	local function makeoption(key)
		local keytemp = key
		self.options.args.custom.args[key] = {
			type = 'group',
			name = sadb.custom[key].name,
			set = function(info, value) local name = info[#info] sadb.custom[key][name] = value end,
			get = function(info) local name = info[#info] return sadb.custom[key][name] end,
			order = sadb.custom[key].order,
			args = {
				name = {
					name = L["Spell Name"],
					type = 'input',
					set = function(info, value)
						if sadb.custom[value] then log(L["same name already exists"]) return end
						sadb.custom[key].name = value
						sadb.custom[key].order = 100
						sadb.custom[key].soundfilepath = "Interface\\SASound\\"..value..".ogg"
						sadb.custom[value] = sadb.custom[key]
						sadb.custom[key] = nil
						--makeoption(value)
						self.options.args.custom.args[keytemp].name = value
						key = value
					end,
					order = 10,
				},
				spellid = {
					name = L["Spell ID"],
					desc = L["Can be found on WoWhead, in the URL"],
					type = 'input',
					order = 20,
					pattern = "%d+$",
				},
				remove = {
					type = 'execute',
					order = 25,
					name = L["Remove"],
					confirm = true,
					confirmText = L["Are you sure?"],
					func = function() 
						sadb.custom[key] = nil
						self.options.args.custom.args[keytemp] = nil
					end,
				},
				test = {
					type = 'execute',
					order = 28,
					name = L["Test"],
					desc = L["If you don't hear anything, try restarting WoW"],
					func = function() PlaySoundFile(sadb.custom[key].soundfilepath) end,
				},
				soundfilepath = {
					name = L["File Path"],
					type = 'input',
					width = 'double',
					order = 27,
				},
				eventtype = {
					type = 'multiselect',
					order = 50,
					name = L["Event type - it's best to have the least amount of event conditions"],
					values = SA_EVENT,
					get = function(info, k) return sadb.custom[key].eventtype[k] end,
					set = function(info, k, v) sadb.custom[key].eventtype[k] = v end,
				},
				sourceuidfilter = {
					type = 'select',
					order = 61,
					name = L["Source unit"],
					desc = L["Is the person who casted the spell your target/focus/mouseover?"],
					values = SA_UNIT,
				},
				sourcetypefilter = {
					type = 'select',
					order = 60,
					name = L["Source of the spell"],
					desc = L["Who casted the spell? Leave on 'any' if a spell got casted on you"],
					values = SA_TYPE,
				},
				sourcecustomname = {
					type= 'input',
					order = 62,
					name = L["Custom unit name"],
					disabled = function() return not (sadb.custom[key].sourceuidfilter == "custom") end,
				},
				destuidfilter = {
					type = 'select',
					order = 65,
					name = L["Spell destination unit"],
					desc = L["(Leave on 'player' if it's yourself) Was the person afflicted by the spell your target/focus/mouseover?"],
					values = SA_UNIT,
				},
				desttypefilter = {
					type = 'select',
					order = 63,
					name = L["Spell Destination"],
					desc = L["Who was afflicted by the spell? Leave it on 'any' if it's a spell cast or a buff"],
					values = SA_TYPE,
				},
				destcustomname = {
					type= 'input',
					order = 68,
					name = L["Custom unit name"],
					disabled = function() return not (sadb.custom[key].destuidfilter == "custom") end,
				},
				--[[NewLine5 = {
					type = 'header',
					order = 69,
					name = "",
				},]]
			}
		}
	end
	for key, v in pairs(sadb.custom) do
		makeoption(key)
	end
end

function SoundAlerter:PlayTrinket()
	PlaySoundFile("Interface\\Addons\\"..sadb.path.."\\Trinket.ogg","Master")
end
function SoundAlerter:ArenaClass(id)
	for i = 1 , 5 do
		if id == UnitGUID("arena"..i) then
			return select(2, UnitClass ("arena"..i))
		end
	end
end
function SoundAlerter:PLAYER_ENTERING_WORLD()
--[[local _,ZoneType = IsInInstance()
	if ZoneType == "pvp" then
	--self:Print("sent addon message with version "..SA_VERSION)
	SendAddonMessage("SA_Version", SA_VERSION, "BATTLEGROUND")
	end
	CombatLogClearEntries()]]
end

function SoundAlerter:PlaySpell(list, spellID, ...)
	if not list[spellID] then return end
	if not sadb[list[spellID]] then return	end
	if sadb.throttle ~= 0 and self:Throttle("playspell",sadb.throttle) then return end
	if sadb.smartDisable then
		if (GetNumRaidMembers() or 0) > 20 then return end
		if self:Throttle("smarter",20) then
			self.smarter = self.smarter + 1
			if self.smarter > 30 then return end
		else 
			self.smarter = 0
		end
	end
	if sadb.debugmode then
		self:Print("<SA> DEBUG: Playing sound file: "..list[spellID]..".ogg");
	end	
	PlaySoundFile("Interface\\Addons\\"..sadb.path.."\\"..list[spellID]..".ogg","Master");
end
function SoundAlerter:COMBAT_LOG_EVENT_UNFILTERED(event , ...)
--fix friend stunned, but enemy was stunned
--silencing shot, scatter shot, fear3, mind freeze
--[[Todos:
enemy pollied bugged
--]]
local arena1 = UnitName("arena1target")
local arena2 = UnitName("arena2target")
local arena3 = UnitName("arena3target")
local arena4 = UnitName("arena4target")
local arena5 = UnitName("arena5target")
local enemyTarget = UnitName("targettarget")
local myTarget = UnitName("target")
local myFocus = UnitName("focus")
	local _,currentZoneType = IsInInstance()
	if (not ((currentZoneType == "none" and sadb.field) or (currentZoneType == "pvp" and sadb.battleground) or (currentZoneType == "arena" and sadb.arena) or sadb.all)) then
		return
	end
	--local timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,spellID,spellName= select ( 1 , ... );
	local timestamp,event,sourceGUID,sourceName,sourceFlags,destGUID,destName,destFlags,spellID,spellName = select ( 1 , ... );
	--[[if sadb.debugmode then
		log(" Spell Name: "..GetSpellLink(spellID)..", SpellID: "..spellID..", Source Name: "..(sourceName and sourceName or "Unknown")..", Destination Name: "..(destName and destName or "Unknown")..", Spell Event: "..event)
	--	log("Spell detected from a hostile player = "..(desttype[COMBATLOG_FILTER_HOSTILE_PLAYERS] and "true" or "false"))
	--	log("Spell detected from/to a friendly unit = "..(desttype[COMBATLOG_FILTER_FRIENDLY_UNITS] and "true" or "false"))
	--	log("Spell detected from/to me = "..(desttype[COMBATLOG_FILTER_MINE] and "true" or "false"))
	end]]
	if not SA_EVENT[event] then return end
	--self:Print(sourceName,destName,destFlags,event,spellName,spellID);
	--local sourcetype,sourceuid,desttype,destuid = {},{},{},{}
	if (destFlags) then
		for k in pairs(SA_TYPE) do
			desttype[k] = CombatLog_Object_IsA(destFlags,k)
			--log("desttype:"..k.."="..(desttype[k] or "nil"))
		end
	else
		for k in pairs(SA_TYPE) do
			desttype[k] = nil
		end
	end
	if (destGUID) then
		for k in pairs(SA_UNIT) do
			if k == "party" then
				if UnitName("party1") ~= nil then --because UnitInParty always returns true?
					for i = 1, MAX_PARTY_MEMBERS do
						if destGUID == UnitGUID(k..i) then
						destuid[k] = (UnitGUID(k..i) == destGUID)
						break
						end
					end
				end
			elseif k == "arena" then
				if currentZoneType == "arena" then
					for i = 1 , 5 do
						if destGUID == UnitGUID(k..i) then
						destuid[k] = (UnitGUID(k..i) == destGUID)
						break
						end
					end
				end
			else
			destuid[k] = (UnitGUID(k) == destGUID)
			end
			--	log("destuid:"..k.."="..(destuid[k] and "true" or "false"))
		end
	else
		for k in pairs(SA_UNIT) do
			destuid[k] = nil
			--	log("destuid:"..k.."="..(destuid[k] and "true" or "false"))
		end
	end
	destuid.any = true
	if (sourceFlags) then
		for k in pairs(SA_TYPE) do
			sourcetype[k] = CombatLog_Object_IsA(sourceFlags,k)
			--log("sourcetype:"..k.."="..(sourcetype[k] or "nil"))
		end
	else
		for k in pairs(SA_TYPE) do
			sourcetype[k] = nil
			--log("sourcetype:"..k.."="..(sourcetype[k] or "nil"))
		end
	end
	if (sourceGUID) then
		for k in pairs(SA_UNIT) do
			if k == "party" then
				if UnitName("party1") ~= nil then
					for i = 1, MAX_PARTY_MEMBERS do
						if sourceGUID == UnitGUID(k..i) then
						sourceuid[k] = (UnitGUID(k..i) == sourceGUID)
						break
						end
					end
				end
			elseif k == "arena" then
				if currentZoneType == "arena" then
					for i = 1 , 5 do
						if sourceGUID == UnitGUID(k..i) then
						sourceuid[k] = (UnitGUID(k..i) == sourceGUID)
						break
						end
					end
				end
			else
			sourceuid[k] = (UnitGUID(k) == sourceGUID)
			end
			--log("sourceuid:"..k.."="..(sourceuid[k] and "true" or "false"))
		end
	else
		for k in pairs(SA_UNIT) do
			sourceuid[k] = nil
			--log("sourceuid:"..k.."="..(sourceuid[k] and "true" or "false"))
		end
	end
	sourceuid.any = true
	if (event == "SPELL_AURA_APPLIED") then
		if spellID == 6770 or spellID == 11297 or spellID == 12826 --[[polymorph rank 4]]or spellID == 2094 or spellID == 33786 or spellID == 51514 or spellID == 5782 then --sap/blind/cyclone/hex/fear chat & sound alerts	
				if destName == playerName then
					if spellID == 33786 or spellID == 51514 or spellID == 5782 and not sadb.aruaApplied then
					self:PlaySpell (self.spellList.castStart,spellID)
					end
					self:PlaySpell (self.spellList.castSuccess,spellID)
					if not sadb.chatalerts then
						if (spellID == 6770 or spellID == 11297)and sadb.sapalert then
							local saptext = gsub(sadb.saptext, "(#spell#)", GetSpellLink(spellID))--"I'm #spell#ped!"
							SendChatMessage(saptext, sadb.chatgroup, nil, nil)
						elseif spellID == 2094 and sadb.blindalert then
							SendChatMessage(gsub(sadb.blindtext, "(#spell#)", GetSpellLink(spellID)), sadb.chatgroup, nil, nil)
						end
					end
				elseif (desttype[COMBATLOG_FILTER_FRIENDLY_UNITS] and destName ~= playerName and ((destuid.target or destuid.focus) or (currentZoneType == "arena"))) then
						if not sadb.ArenaPartner then
						self:PlaySpell (self.spellList.friendCCSuccess,spellID)
						end
					if not sadb.chatalerts then
						if (spellID == 6770 or spellID == 11297)and sadb.sapalert then --blindonenemychat/blindalert
							local saptextfriend = gsub(sadb.saptextfriend, "(#spell#)", GetSpellLink(spellID))
							SendChatMessage(gsub(sadb.saptextfriend, "(#friend#)", destName), sadb.chatgroup, nil, nil)
						elseif spellID == 2094 and sadb.blindalert then
							SendChatMessage(string.format(sadb.blindtextfriend, destName, GetSpellLink(spellID)), sadb.chatgroup, nil, nil)
						end
					end
				elseif desttype[COMBATLOG_FILTER_HOSTILE_PLAYERS] and (destuid.target or destuid.focus) then
						self:PlaySpell (self.spellList.enemyDebuffs,spellID)
					if not sadb.chatalerts then
						if ((spellID == 6770 or spellID == 11297) and sadb.sapenemyalert) or (spellID == 2094 and sadb.blindonenemychat) or (spellID == 33786 and sadb.cyclonechat) or (spellID == 51514 and sadb.hexchat) or (spellID == 5782 and sadb.fearchat) then
						local ccenemychat = gsub(sadb.ccenemychat, "(#spell#)", GetSpellLink(spellID))
						SendChatMessage(gsub(ccenemychat, "(#enemy#)", destName), sadb.chatgroup, nil, nil)
						end
					end
				end
		elseif not sadb.aruaApplied then
				if destName == PlayerName then --Also includes buffs e.g "Cold Snap" - Should I leave this?
								self:PlaySpell (self.spellList.castSuccess,spellID)
								self:PlaySpell (self.spellList.castStart,spellID)
				elseif (desttype[COMBATLOG_FILTER_FRIENDLY_UNITS] and destName ~= playerName and (destuid.target or destuid.focus or currentZoneType == "arena")) then
                                self:PlaySpell (self.spellList.friendCCSuccess,spellID)
				elseif (destName == playerName and desttype[COMBATLOG_FILTER_MINE] and myTarget ~= sourceName and myFocus ~= sourceName) then
                                self:PlaySpell (self.spellList.castStart,spellID)
				elseif (desttype[COMBATLOG_FILTER_HOSTILE_PLAYERS] and (not sadb.aonlyTF or destuid.target or destuid.focus)) then
                                self:PlaySpell (self.spellList.auraApplied,spellID)
                        end
                end
	elseif (event == "SPELL_AURA_REMOVED" and not sadb.auraRemoved) then
		if destuid.target or destuid.focus or (destName == arena1 or destName == arena2 or destName == arena3 or destName == arena4 or destName == arena5) then --Can only hear sap down if it's your target/focus - source name returns nil
			self:PlaySpell (self.spellList.enemyDebuffdown,spellID)
		end
		if desttype[COMBATLOG_FILTER_HOSTILE_PLAYERS] and (not sadb.ronlyTF or destuid.target or destuid.focus) then
			self:PlaySpell (self.spellList.auraRemoved,spellID)
		end
	elseif (event == "SPELL_CAST_START" and sourcetype[COMBATLOG_FILTER_HOSTILE_PLAYERS] and (not sadb.conlyTF or sourceuid.target or sourceuid.focus) and not sadb.castStart) then
		if currentZoneType == "arena" and (arena1 ~= playerName and arena2 ~= playerName and arena3 ~= playerName and arena4 ~= playerName and arena5 ~= playerName) and (spellID == 33786 or spellID == 51514 or spellID == 118 or spellID == 28272 or spellID == 61305 or spellID == 61721 or spellID == 61025 or spellID == 61780 or spellID == 28271 or spellID == 5782) and not sadb.ArenaPartner then
		self:PlaySpell (self.spellList.friendCCcast,spellID)
		else
		self:PlaySpell (self.spellList.castStart,spellID)
		end
	--elseif event == "SPELL_CAST_SUCCESS" and sourceName == playerName and destName ~= playerName or ((sourceName == party1 or sourceName == party2 or sourceName == party3 or sourceName == party4) and (ZoneType == "arena")) then
	elseif (event == "SPELL_CAST_SUCCESS" and sourcetype[COMBATLOG_FILTER_HOSTILE_PLAYERS]) then
		if ((spellID == 1784 or spellID == 1787 or spellID == 1856 or spellID == 642) and (not sadb.sonlyTF or sourceuid.target or sourceuid.focus) and not sadb.castSuccess) then --vanish/stealth chat alert
				self:PlaySpell (self.spellList.castSuccess,spellID)
				if not sadb.chatalerts and (not sadb.caonlyTF or sourceuid.target or sourceuid.focus) then
					if (sadb.stealthalert and (spellID == 1784 or spellID == 1787)) or (sadb.vanishalert and spellID == 1856) then
						local spelltext = gsub(sadb.spelltext, "(#spell#)", GetSpellLink(spellID))
						SendChatMessage(gsub(spelltext, "(#enemy#)", sourceName), sadb.chatgroup, nil, nil)
					else
					local bubblealerttext = gsub(sadb.bubblealerttext, "(#spell#)", GetSpellLink(spellID))
					SendChatMessage(gsub(sadb.bubblealerttext, "(#enemy#)", sourceName), sadb.chatgroup, nil, nil)
				end	
			end
		elseif (spellID == 42292) then--FIXME - no trinket combat log event??
			if sadb.trinketalert and not sadb.chatalerts and (not sadb.caonlyTF or sourceuid.target or sourceuid.focus) then
				local trinketalerttext = gsub(sadb.trinketalerttext, "(#spell#)", GetSpellLink(spellID))
					SendChatMessage(gsub(trinketalerttext, "(#enemy#)", sourceName), sadb.chatgroup, nil, nil)
			end
			if sadb.class and currentZoneType == "arena" then
				local c = self:ArenaClass(sourceGUID)
				if c then 
					PlaySoundFile("Interface\\Addons\\"..sadb.path.."\\"..c..".ogg","Master");
				end
			elseif (not sadb.sonlyTF or sourceuid.target or sourceuid.focus) then
			self:PlaySpell (self.spellList.castSuccess,spellID)
			end
		elseif spellID ~= 6770 and spellID ~= 11297 and spellID ~= 2094 and (not sadb.sonlyTF or sourceuid.target or sourceuid.focus) then	--to prevent double spam in party 
			self:PlaySpell (self.spellList.castSuccess,spellID)
		end
	elseif (event == "SPELL_INTERRUPT" and desttype[COMBATLOG_FILTER_HOSTILE_PLAYERS] and not sadb.interrupt) then 
		self:PlaySpell (self.spellList.friendlyInterrupt,spellID)
	end
	for k,css in pairs (sadb.custom) do
		if css.destuidfilter == "custom" and destName == css.destcustomname then 
			destuid.custom = true  
		else 
			destuid.custom = false 
		end
		if css.sourceuidfilter == "custom" and sourceName == css.sourcecustomname then
			sourceuid.custom = true  
		else
			sourceuid.custom = false 
		end--custom sound alert
		if sadb.debugmode then
		log(" Custom Sound Alert for "..css.name..": The destination of the spell is "..(destuid[css.destuidfilter] and "true" or "false"))
		log(" Custom Sound Alert for "..css.name..": The destination type is "..(desttype[css.desttypefilter] and "true" or "false"))
		log(" Custom Sound Alert for "..css.name..": The source unit is "..(sourceuid[css.sourceuidfilter] and "true" or "false"))
		log(" Custom Sound Alert for "..css.name..": The source type is "..(sourcetype[css.sourcetypefilter] and "true" or "false"))
		log(" Custom Sound Alert for "..css.name..": The Spell ID is "..(spellID == tonumber(css.spellid) and "true" or "false"))
		end
		if css.eventtype[event] and destuid[css.destuidfilter] and desttype[css.desttypefilter] and sourceuid[css.sourceuidfilter] and sourcetype[css.sourcetypefilter] and spellID == tonumber(css.spellid) then
			if self:Throttle(tostring(spellID)..css.name,0.1) then return end
				if sadb.debugmode then
				self:Print("playing css "..css.soundfilepath)
				end
			PlaySoundFile(css.soundfilepath,"Master")
		end
	end
end--[[
local DRINK_SPELL = GetSpellInfo(57073)
function SoundAlerter:UNIT_AURA(unitId)

	if uid:find("arena") and sadb.drinking then
		if UnitAura (uid,DRINK_SPELL) then
			if self:Throttle(tostring(57073)..uid,3) then return end
			PlaySoundFile("Interface\\Addons\\"..sadb.path.."\\drinking.ogg","Master")
		end
	end
end
function SoundAlerter:CHAT_MSG_ADDON(_, prefix, msg, channel, sender)
self:Print("recieved from "..channel.." addon was "..prefix)
	if prefix == "SA_Version" then
		if ( tonumber(msg) > SA_VERSION ) then 
			self:Print("There is a newer version of SoundAlerter. Go to Molten's World PvP section forum to update.");
		elseif tonumber(msg) == SA_VERSION then
		--	self:Print("recieved "..msg.." sending "..SA_VERSION.." back")
		SendAddonMessage( "SA_Version", SA_VERSION, "WHISPER", sender );
		end
	end
end--]]
function SoundAlerter:Throttle(key,throttle)
	if (not self.throttled) then
		self.throttled = {}
	end
	-- Throttling of Playing
	if (not self.throttled[key]) then
		self.throttled[key] = GetTime()+throttle
		return false
	elseif (self.throttled[key] < GetTime()) then
		self.throttled[key] = GetTime()+throttle
		return false
	else
		return true
	end
end 