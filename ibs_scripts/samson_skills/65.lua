--参孙技能
--倒隐者

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(65, {
	IsReversed = true,
})

--检测硬币持有数量更新
function Skill:OnPlayerUpdate(player)
	if not self:HasCard(player) then return end
	local data = self:GetTempData(player)
	local coins = player:GetNumCoins()
	
	data.Coins = data.Coins or 0

	if data.Coins ~= coins then
		data.Coins = coins
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
	end
end
Skill:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)

--属性
function Skill:OnEvalueateCache(player, flag)
	if self:HasCard(player) and flag == CacheFlag.CACHE_DAMAGE then
		self._Stats:Damage(player, self:GetCardNum(player) * 0.04 * player:GetNumCoins())
	end	
end
Skill:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvalueateCache')

return Skill