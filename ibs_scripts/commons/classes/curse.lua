--诅咒Class

local mod = Isaac_BenightedSoul

local Component = mod.IBS_Class.Component

local Curse = mod.Class(Component, function(self, id)
	Component._ctor(self)

	self.ID = id
	self.Bitmask = 1 << (id-1)

	function self:IsApplied()
		return (Game():GetLevel():GetCurses() & self.Bitmask > 0)
	end

end, { {expectedType = 'number'} })


return Curse





