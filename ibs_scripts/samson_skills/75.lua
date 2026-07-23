--参孙技能
--倒太阳

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(75, {
	IsReversed = true,
})

function Skill:OnPlayerUpdate(player)
	if not self:HasCard(player) then return end
	local data = self:GetTempData(player)
	local state = self:GetBSamsonState(player)
	data.State = data.State or 0
	
	if data.State ~= state then
		data.State = state
		data.Mult = 1.9 * self:GetCardNum(player)
		data.MaxMult = data.Mult
	end

	if player:IsFrame(3,0) and data.Mult and data.Mult > 1 and data.MaxMult then
		data.Mult = math.max(1, data.Mult - 0.02 * data.MaxMult)
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
	end
end
Skill:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, "OnPlayerUpdate", 0)

--属性
function Skill:OnEvalueateCache(player, flag)
	if self:HasCard(player) and flag == CacheFlag.CACHE_FIREDELAY then
		local data = self:GetTempData(player, true)
		if data and data.Mult and data.Mult > 1 then		
			self._Stats:TearsMultiples(player, data.Mult)
		end
	end	
end
Skill:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 100, 'OnEvalueateCache')

return Skill