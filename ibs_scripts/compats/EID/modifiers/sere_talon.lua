--原初之爪EID

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

--翻译
local function Translate(text_zh, text_en, LANG)
	return (LANG == 'zh_cn' and text_zh) or text_en
end


return function(LANG)
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
		
		if (Type == 5) and (Variant == 300) and (SubType == 49) and desc.Entity then
			local player = EID:ClosestPlayerTo(desc.Entity)
			if player and player:HasCollectible(IBS_ItemID.SereTalon) then
				return true
			end
		end
			
		return false
	end

	--添加额外内容
	local function callback(desc)
		local Variant = desc.ObjVariant
		local SubType = desc.ObjSubType
		local add = '#{{Collectible'..(IBS_ItemID.SereTalon)..'}} '

		add = add..Translate(
			"改为将道具重置为{{Quality2}}品质2及以上的道具#!!! {{ColorRed}}获得随机{{Quality0}}品质0被动道具{{CR}}",
			"Instead, reroll items into {{Quality2}}Q2-or-above ones#!!! {{ColorRed}}Gain a random {{Quality0}}Q0 passive item{{CR}}",
		LANG)
		EID:appendToDescription(desc, add)		
			
		return desc
	end
	EID:addDescriptionModifier('ibsSereTalon'..'_'..LANG, condition, callback)
end