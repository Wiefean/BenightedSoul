--表表店硬币饰品额外描述EID

local mod = Isaac_BenightedSoul
local IBS_PlayerID = mod.IBS_PlayerID
local Pools = mod.IBS_Lib.Pools

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
		
		if (Type == 5) and (Variant == 350) and Pools:IsPennyTrinket(SubType) and PlayerManager.AnyoneIsPlayerType(IBS_PlayerID.BKeeper) then
			return true
		end
			
		return false
	end

	--添加额外内容
	local function callback(desc)
		local SubType = desc.ObjSubType
		local add = Translate('影响乞丐道具池', 'Affect beggar item pools', LANG)
		add = '#{{Player'..(IBS_PlayerID.BKeeper)..'}} '..add
	
		--诅咒硬币
		if SubType == 172 then
			local add = Translate('乞丐有可能返还资源', 'Beggers may return the resources', LANG)
			add = '#{{Player'..(IBS_PlayerID.BKeeper)..'}} '..add		
		end
	
		EID:appendToDescription(desc, add)
		return desc
	end
	EID:addDescriptionModifier('ibsBKeeperPennyTrinket'..'_'..LANG, condition, callback)
end