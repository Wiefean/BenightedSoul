--我果EID

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()

--翻译
local function Translate(text_zh, text_en, LANG)
	return (LANG == 'zh_cn' and text_zh) or text_en
end

local AnotherPage = false --用于切换显示内容
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	for idx = 0,4 do
		if Input.IsActionTriggered(ButtonAction.ACTION_MAP, idx) then
			AnotherPage = not AnotherPage
			break
		end
	end
end)
mod:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, function()
	for idx = 0,4 do
		if Input.IsActionTriggered(ButtonAction.ACTION_MAP, idx) then
			AnotherPage = not AnotherPage
			break
		end
	end
end)

local BlessList = include('ibs_scripts.compats.EID.descriptions.my_fruit')

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
		
		if (Type == 5) and (Variant == 100) and (SubType == IBS_ItemID.MyFruit) then
			return AnotherPage
		end
			
		return false
	end

	--修改描述
	local function callback(desc)
		if AnotherPage then
			local newDesc = ''
			local greed = game:IsGreedMode()
			local colon = Translate('：', ': ', LANG)
			local greedDisabled = Translate('({{GreedMode}}禁用)', '({{GreedMode}}DISABLED)', LANG)
			
			for _,bless in ipairs(BlessList) do
				local N = mod:ChooseLanguageInTable(bless.name)
				local D = ''
				if (not bless.noGreed) or (not greed) then
					D = mod:ChooseLanguageInTable(bless.desc)
				else
					D = greedDisabled
				end
				newDesc = newDesc..'#'..N..colon..D
			end
			
			desc.Description = newDesc
		end
		return desc
	end
	EID:addDescriptionModifier('ibsMyFruit'..'_'..LANG, condition, callback)
end