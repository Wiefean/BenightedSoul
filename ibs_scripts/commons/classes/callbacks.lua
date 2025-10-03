--回调合集Class

local mod = Isaac_BenightedSoul

local Component = mod.IBS_Class.Component

local Callbacks = mod.Class(Component, function(self, IDs)
	Component._ctor(self)

	self.IDs = {}
	for k,v in pairs(IDs) do
		self.IDs[k] = v
	end

	function self:Run(callbackID, ...)
		return Isaac.RunCallback(callbackID, ...)
	end
	function self:RunWithParam(callbackID, param, ...)
		return Isaac.RunCallbackWithParam(callbackID, param, ...)
	end
	function self:Get(callbackID)
		return Isaac.GetCallbacks(callbackID)
	end

end, { {expectedType = 'table'} })

return Callbacks





