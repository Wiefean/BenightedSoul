--道具Class

local mod = Isaac_BenightedSoul

local Component = mod.IBS_Class.Component

local Item = mod.Class(Component, function(self, id)
	Component._ctor(self)

	self.ID = id

end, { {expectedType = 'number'} })

return Item





