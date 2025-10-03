--独立回调Class

local mod = Isaac_BenightedSoul

local Component = mod.IBS_Class.Component

local Callback = mod.Class(Component, function(self, id)
	Component._ctor(self)

	self.ID = id

	function self:Run(...)
		return Isaac.RunCallback(self.ID, ...)
	end
	function self:RunWithParam(param, ...)
		return Isaac.RunCallbackWithParam(self.ID, param, ...)
	end
	function self:Get()
		return Isaac.GetCallbacks(self.ID)
	end

end, { {expectedType = 'string'} })

return Callback





