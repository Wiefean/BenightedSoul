--口袋物品Class(不包括药丸)

local mod = Isaac_BenightedSoul

local Component = mod.IBS_Class.Component

local Pocket = mod.Class(Component, function(self, id)
	Component._ctor(self)

	self.ID = id

end, { {expectedType = 'number'} })

return Pocket





