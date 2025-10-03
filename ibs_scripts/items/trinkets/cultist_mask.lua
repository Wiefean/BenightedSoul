--邪教徒头套

local mod = Isaac_BenightedSoul
local IBS_Sound = mod.IBS_Sound

local sfx = SFXManager()

local CultistMask = mod.IBS_Class.Trinket(mod.IBS_TrinketID.CultistMask)

function CultistMask:OnNewRoom()
	local mult = PlayerManager.GetTotalTrinketMultiplier(self.ID)

	if mult > 0 then
		sfx:Play(IBS_Sound.KAKA)
	end
	
	if mult >= 2 then
		for i = 2,mult do
			self:DelayFunction(function()
				sfx:Play(IBS_Sound.KAKA)
			end, i*15)
		end
	end
end
CultistMask:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')


return CultistMask