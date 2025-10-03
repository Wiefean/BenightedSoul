--红钩

local mod = Isaac_BenightedSoul
local Damage = mod.IBS_Class.Damage()

local game = Game()

local RedHook = mod.IBS_Class.Item(mod.IBS_ItemID.RedHook)


--受伤概率翻倍
function RedHook:PreTakeDMG(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end
	local level = game:GetLevel()
	if level:GetCurses() & LevelCurse.CURSE_OF_DARKNESS <= 0 then return end --检测黑暗诅咒
	local player = ent:ToPlayer()

	if player then
		if player:HasCollectible(self.ID) and Damage:IsPenalt(player, flag, source) then
			local chance = 8 + 4 * level:GetStage()
			if player:GetCollectibleRNG(self.ID):RandomInt(100) < chance then	
				Isaac.Spawn(1000,2,0, player.Position, Vector.Zero, nil)
				return {Damage = dmg * 2}
			end
		end	
	elseif self._Ents:IsEnemy(ent) then
		local chance = 16 + 8 * level:GetStage()
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)		
			if player:HasCollectible(self.ID) and player:GetCollectibleRNG(self.ID):RandomInt(100) < chance then
				Isaac.Spawn(1000,2,0, ent.Position, Vector.Zero, nil)
				return {Damage = dmg * 2}
			end
		end
	end
end
RedHook:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -10, 'PreTakeDMG')

--黑暗诅咒代替其他诅咒
function RedHook:OnApplyCurse(curse)
	if PlayerManager.AnyoneHasCollectible(self.ID) then
		return LevelCurse.CURSE_OF_DARKNESS
	end
end
RedHook:AddPriorityCallback(ModCallbacks.MC_POST_CURSE_EVAL, -666, 'OnApplyCurse')

--属性
function RedHook:OnEvaluateCache(player, flag)
    if player:HasCollectible(self.ID) then
        local num = player:GetCollectibleNum(self.ID)
        if (flag == CacheFlag.CACHE_DAMAGE) then
            self._Stats:Damage(player, 0.3*num)
		end
    end
end
RedHook:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')

return RedHook