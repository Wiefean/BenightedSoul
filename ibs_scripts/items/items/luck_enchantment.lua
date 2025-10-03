--幸运附魔

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local game = Game()

local LuckEnchantment = mod.IBS_Class.Item(mod.IBS_ItemID.LuckEnchantment)

--增伤
function LuckEnchantment:OnTakeDMG(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end
	if self._Ents:IsEnemy(ent, true) then
		local extra = 0
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)			
			if player:HasCollectible(self.ID) then
				extra = extra + math.max(0, 0.2 * player.Luck)
			end
		end
		
		return {Damage = dmg + extra, DamageFlags = flag, DamageCountdown = cd}
	end
end
LuckEnchantment:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -100000, 'OnTakeDMG')

--属性
function LuckEnchantment:OnEvaluateCache(player, flag)
	if player:HasCollectible(self.ID) then
		local num = player:GetCollectibleNum(self.ID)
		if flag == CacheFlag.CACHE_LUCK then
			Stats:Luck(player, 3*num)
		end	
	end	
end
LuckEnchantment:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


return LuckEnchantment