--米迦勒的赐福EID

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local config = Isaac.GetItemConfig()

--翻译
local function Translate(text_zh, text_en, LANG)
	return (LANG == 'zh_cn' and text_zh) or text_en
end

local _BlessingOfMichaelEID = include('ibs_scripts.compats.EID.descriptions.blessing_of_michael')


return function(LANG)
	local KEY = (LANG == 'zh_cn' and 'zh') or 'en'
	if not _BlessingOfMichaelEID[KEY] then return end
	
	local BlessingOfMichaelEID = _BlessingOfMichaelEID[KEY]

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
		
		--道具
		if (Type == 5) and (Variant == 100) and BlessingOfMichaelEID[SubType] and desc.Entity then
			local player = EID:ClosestPlayerTo(desc.Entity)
			if player and player:HasCollectible(IBS_ItemID.BlessingOfMichael) then
				return true
			end
		end
			
		return false
	end

	--添加额外内容
	local function callback(desc)
		local Variant = desc.ObjVariant
		local SubType = desc.ObjSubType
		local prefix = '#{{Collectible'..(IBS_ItemID.BlessingOfMichael)..'}} '
		local add = ''
	
		--道具
		if Variant == 100 then
			local itemConfig = config:GetCollectible(SubType)
			if itemConfig and BlessingOfMichaelEID[SubType] then
				add = add..BlessingOfMichaelEID[SubType]
			end
		end
	
		if add ~= '' then
			EID:appendToDescription(desc, prefix..add)
		end
		
		return desc
	end
	EID:addDescriptionModifier('ibsBlessingOfMichael'..'_'..LANG, condition, callback)
end