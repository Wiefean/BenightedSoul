--模组组成成分Class(其他Class的基底)

local mod = Isaac_BenightedSoul

local Component = mod.Class(function(self)

	do --调用通用值
		function self:GetIBSData(type)
			return mod:GetIBSData(type)
		end
		function self:SaveIBSData()
			mod:SaveIBSData()
		end
		function self:GetRNG(name)
			return mod:GetRNG(name)
		end
		function self:IsStartingRun()
			return mod:IsStartingRun()
		end
		function self:IsGameContinued()
			return mod:IsGameContinued()
		end
		function self:ChooseLanguage(text_zh, text_en)
			return mod:ChooseLanguage(text_zh, text_en)
		end
		function self:ChooseLanguageInTable(tbl)
			return mod:ChooseLanguageInTable(tbl)
		end
		function self:ShuffleTable(tbl, seed)
			return mod:ShuffleTable(tbl, seed)
		end
		function self:DelayFunction(func, frames, waitCondition, noRewind)		
			mod:DelayFunction(func, frames, waitCondition, noRewind)
		end
		function self:DelayFunction2(func, frames, waitCondition, noRewind)		
			mod:DelayFunction2(func, frames, waitCondition, noRewind)
		end
		for k,v in pairs(mod.IBS_Lib) do
			self['_'..k] = v
		end
	end

	do --回调(这种回调方式可以使得函数被外部修改时,内部自动回应修改)
		function self:AddCallback(callback, funcKey, optional)
			local function func(mod, ...)
				return self[funcKey](self, ...)
			end
			mod:AddCallback(callback, func, optional)
		end
		function self:AddPriorityCallback(callback, priority, funcKey, optional)
			local function func(mod, ...)
				return self[funcKey](self, ...)
			end
			mod:AddPriorityCallback(callback, priority, func, optional)
		end
	end

end)

return Component





