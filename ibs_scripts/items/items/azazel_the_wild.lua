--阿撒泻勒的旷野

local mod = Isaac_BenightedSoul
local Pools = mod.IBS_Lib.Pools
local Damage = mod.IBS_Class.Damage()

local game = Game()

local AzazelTheWild = mod.IBS_Class.Item(mod.IBS_ItemID.AzazelTheWild)


function AzazelTheWild:OnPlayerUpdate(player)
	if player:HasCollectible(self.ID) and player:IsFrame(50,0) and self._Players:IsShooting(player) then
		local vec = self._Players:GetAimingVector(player)
		
		self._Players:FireBrimstones(player, function(laser)
			laser.Parent = player
			laser:SetScale(math.min(1.5, self._Maths:TearDamageToScale(player.Damage)))
			laser:SetTimeout(15)
			laser:SetMaxDistance(10 + player.TearRange/5)
		end, player.Position, vec, player, 1)
	end
end
AzazelTheWild:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate')


return AzazelTheWild