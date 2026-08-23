--店主的伪忆EID

local mod = Isaac_BenightedSoul
local IBS_PocketID = mod.IBS_PocketID

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
		
		if (Type == 5) and (Variant == 300) and (SubType == IBS_PocketID.BKeeper) then
			return true
		end
			
		return false
	end

	--添加额外内容
	local function callback(desc)
		local data = mod:GetIBSData('temp').FalsehoodBKeeper
		local times = 0

		if data and data.Points then
			times = data.Points
		end
		
		local add = Translate('#(已捐助次数：', '#(Donation Times: ', LANG)..times..')'
		EID:appendToDescription(desc, add)

		return desc
	end
	EID:addDescriptionModifier('ibsBKeeperFalsehood'..'_'..LANG, condition, callback)
end