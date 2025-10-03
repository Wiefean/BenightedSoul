--孢子云

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local SporeCloud = mod.IBS_Class.Trinket(mod.IBS_TrinketID.SporeCloud)

--受伤发射毛霉菌病眼泪
function SporeCloud:OnTakeDMG(ent, dmg, flag, source)
	local player = ent:ToPlayer()
	if player and player:HasTrinket(self.ID) then
		local mult = player:GetTrinketMultiplier(self.ID)
		for i = 1,8 do
			local tear = Isaac.Spawn(2, 48, 0, player.Position, 10*Vector.FromAngle(i*45), player):ToTear()
			tear:AddTearFlags(TearFlags.TEAR_SPORE | TearFlags.TEAR_HOMING)
			tear.CollisionDamage = player.Damage * mult
		end
	end
end
SporeCloud:AddCallback(ModCallbacks.MC_POST_TAKE_DMG, 'OnTakeDMG')

return SporeCloud