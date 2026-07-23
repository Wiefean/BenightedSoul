--参孙技能
--倒星星

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(73, {
	IsReversed = true,
})

--属性
function Skill:OnEvalueateCache(player, flag)
	if self:HasCard(player) and flag == CacheFlag.CACHE_LUCK then
		local data = mod.IBS_Item.Posture:GetData(player)
		self._Stats:Luck(player, (-7 + data.ConsumedCount) * self:GetCardNum(player))
	end	
end
Skill:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvalueateCache')

--增伤
function Skill:OnTakeDMG(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end
	if self._Ents:IsEnemy(ent, true) then
		local extra = 0
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)			
			if self:HasCard(player) then
				local luck = player.Luck
				if luck < 0 then
					luck = -luck
				end
				extra = extra + self:GetCardNum(player) * math.max(0, 0.2 * luck)
			end
		end
		return {Damage = dmg + extra}
	end
end
Skill:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -100000, 'OnTakeDMG')

return Skill