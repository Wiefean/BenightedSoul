--昧化参孙EID

local mod = Isaac_BenightedSoul
local IBS_PlayerID = mod.IBS_PlayerID
local IBS_ItemID = mod.IBS_ItemID
local Players = mod.IBS_Lib.Players

local config = Isaac.GetItemConfig()

--翻译
local function Translate(text_zh, text_en, LANG)
	return (LANG == 'zh_cn' and text_zh) or text_en
end

local _BSamsonEID = include('ibs_scripts.compats.EID.descriptions.bsamson')


return function(LANG)
	local KEY = (LANG == 'zh_cn' and 'zh') or 'en'
	if not _BSamsonEID[KEY] then return end
	
	local BSamsonEID = _BSamsonEID[KEY]

	--触发条件
	local function condition(desc)
		local Type = desc.ObjType
		local Variant = desc.ObjVariant
		local SubType = desc.ObjSubType
		
		--检查语言
		local lang = EID:getLanguage()
		if lang ~= 'zh_cn' then lang = 'en_us' end
		if lang ~= LANG then
			return false
		end
		
		if (Type == 5) and (Variant == 300) 
			and ((SubType >= 1 and SubType <= 22) or (SubType >= 56 and SubType <= 77))
			and desc.Entity
		then
			local player = EID:ClosestPlayerTo(desc.Entity)
			if player and player:HasCollectible(IBS_ItemID.Posture, true) then
				return true
			end
		end

		return false
	end

	--添加额外内容
	local function callback(desc)
		local SubType = desc.ObjSubType
		local player = desc.Entity and EID:ClosestPlayerTo(desc.Entity)
		local PostureIcon = '{{Collectible'..(IBS_ItemID.Posture)..'}} '
		local CalmIcon = '{{IBSSamsonCalm}} '
		local WrathIcon = '{{IBSSamsonWrath}} '
		local add = ''
		
		if player and Players:IsHoldingItem(player, IBS_ItemID.Posture) then
			local isBSamson = player:GetPlayerType() == (IBS_PlayerID.BSamson)
			local skill = BSamsonEID[SubType]
			if skill then				
				--暴怒普攻 / 其他角色使用架势
				if isBSamson then
					add = add..'#{{Player'..(IBS_PlayerID.BSamson)..'}} '..(skill.BSamson or skill.Common)
					
					if skill.Calm then
						add = add..'#'..PostureIcon..CalmIcon..skill.Calm						
					end
					if skill.Wrath then						
						add = add..'#'..PostureIcon..WrathIcon..skill.Wrath
					end
				else
					add = add..'#'..PostureIcon..skill.Common
				end
			end
		end
		
		EID:appendToDescription(desc, add)
		
		return desc
	end
	
	EID:addDescriptionModifier('ibsBSamson'..'_'..LANG, condition, callback)
end