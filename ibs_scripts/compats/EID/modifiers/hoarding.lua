--收集癖EID

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local config = Isaac.GetItemConfig()

--翻译
local function Translate(text_zh, text_en, LANG)
	return (LANG == 'zh_cn' and text_zh) or text_en
end

local HoardingEID = include('ibs_scripts.compats.EID.descriptions.hoarding')


return function(LANG)
	local KEY = (LANG == 'zh_cn' and 'zh') or 'en'
	if not HoardingEID[KEY] then return end
	
	local FormList, StompyFrom, IBSFormList = HoardingEID[KEY].FormList, HoardingEID[KEY].StompyFrom, HoardingEID[KEY].IBSFormList

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
		
		--检查道具
		if not PlayerManager.AnyoneHasCollectible(IBS_ItemID.Hoarding) then
			return false
		end
		
		--道具或药丸
		if (Type == 5) and (Variant == 100 or Variant == 70) then
			return true
		end
			
		return false
	end

	--添加额外内容
	local function callback(desc)
		local Variant = desc.ObjVariant
		local SubType = desc.ObjSubType
		local prefix = '#{{Collectible'..(IBS_ItemID.Hoarding)..'}} '
		local add = ''
	
		--道具
		if Variant == 100 then
			local itemConfig = config:GetCollectible(SubType)
			if itemConfig then
				for tag,desc in pairs(FormList) do
					if itemConfig:HasTags(tag) then
						add = add..prefix..desc
					end
				end
				if StompyFrom[SubType] then --践踏套装
					add = add..prefix..(StompyFrom.info)
				end
				
				--愚昧套装
				if mod.IBS_Transformation then				
					for key,desc in pairs(IBSFormList) do
						local trans = mod.IBS_Transformation[key]
						if trans and trans.ItemList[SubType] then
							add = add..prefix..desc
						end
					end				
				end
			end
		end			
	
		--药丸
		if Variant == 70 then
			--成人套装
			if SubType == 9 then
				add = add..prefix..'{{Adult}} '..Translate('+ 1{{EternalHeart}}永恒之心', '+ 1 {{EternalHeart}}Eternal Heart')
			end
			
			--践踏套装
			if SubType == 32 then
				add = add..prefix..(StompyFrom.info)
			end
		end
	
		if add ~= '' then			
			EID:appendToDescription(desc, add)
		end
		
		return desc
	end
	EID:addDescriptionModifier('ibsHoardingTransformation'..'_'..LANG, condition, callback)
end