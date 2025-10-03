--微笑世界

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local SmileWorld = mod.IBS_Class.Item(mod.IBS_ItemID.SmileWorld)

--增伤
function SmileWorld:OnTakeDMG(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end
	if self._Ents:IsEnemy(ent, true) then
		local extra = 0
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)			
			if player:HasCollectible(self.ID) then
				local mult = player:GetCollectibleNum(self.ID)
				for id,num in pairs(player:GetCollectiblesList()) do
					if num > 0 then
						extra = extra + 0.1 * num * mult
					end
				end
			end
		end
		
		return {Damage = dmg + extra, DamageFlags = flag, DamageCountdown = cd}
	end
end
SmileWorld:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -100000, 'OnTakeDMG')

return SmileWorld