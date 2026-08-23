--四维骰EID

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local config = Isaac.GetItemConfig()

--翻译
local function Translate(text_zh, text_en, LANG)
	return (LANG == 'zh_cn' and text_zh) or text_en
end

--ID转EID贴图
local function ToIcon(LANG, id)
	id = math.floor(id+0.5) --四舍五入
	local icon = ''
	local itemConfig = config:GetCollectible(id)

	if itemConfig and itemConfig:IsAvailable() then
		icon = '{{Collectible'..tostring(id)..'}}'
	else
		if PlayerManager.AnyoneHasCollectible(59) then --彼列书
			icon = '{{Collectible51}}'
		else
			icon = Translate('无', 'N/A', LANG)
		end
	end
	
	return icon
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
		
		if (Type == 5) and (Variant == 100) and (SubType > 0) then
			return PlayerManager.AnyoneHasCollectible(IBS_ItemID.D4D)
		end
			
		return false
	end

	--添加额外内容
	local function callback(desc)
		local id = desc.ObjSubType
		local col1 = ToIcon(LANG,(id+1))
		local col2 = ToIcon(LANG,(id-1))
		local col3 = ToIcon(LANG,(id*2))
		local col4 = ToIcon(LANG,(id/2))
		local L = '{{ButtonDLeft}}'
		local R = '{{ButtonDRight}}'
		local U = '{{ButtonDUp}}'
		local D = '{{ButtonDDown}}'
		
		local add = '#{{Collectible'..IBS_ItemID.D4D..'}} '..
					L..col1..';'..R..col2..';'..U..col3..';'..D..col4
					
		EID:appendToDescription(desc, add)
		
		return desc
	end
	EID:addDescriptionModifier('ibsD4D'..'_'..LANG, condition, callback)
end