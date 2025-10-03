--村好剑

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local TheBestWeapon = mod.IBS_Class.Item(mod.IBS_ItemID.TheBestWeapon)

--属性
function TheBestWeapon:OnEvaluateCache(player, flag)
	if player:HasCollectible(self.ID) then	
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + 5*player:GetCollectibleNum(self.ID)
		end
	end	
end
TheBestWeapon:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 300, 'OnEvaluateCache')

--调整伤害
function TheBestWeapon:OnTakeDMG(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end
	if self._Ents:IsEnemy(ent, true) then
		local offset = 0
		
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)			
			if player:HasCollectible(self.ID) then
				local mult = player:GetCollectibleNum(self.ID)
				
				--正邪增强(东方mod)
				if mod.IBS_Compat.THI:SeijaBuff(player) then
					offset = offset + 4*mult
					
					--里正邪等级兼容
					local seijaLevel =  mod.IBS_Compat.THI:GetSeijaBLevel(player)
					if seijaLevel >= 2 then
						offset = offset + 4*(seijaLevel-1)
					end
				end
					
				offset = offset - 4*mult
			end
		end
		
		return {Damage = math.max(0, dmg + offset), DamageFlags = flag, DamageCountdown = cd}
	end
end
TheBestWeapon:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -100000, 'OnTakeDMG')

return TheBestWeapon