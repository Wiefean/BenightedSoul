--参孙技能
--倒愚者

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(56, {
	IsReversed = true,
})

--属性
function Skill:OnEvalueateCache(player, flag)
	if self:HasCard(player) and (flag == CacheFlag.CACHE_DAMAGE or flag == CacheFlag.CACHE_FIREDELAY) then
		local num = 0
	
		for _,id in ipairs(mod.IBS_Item.Posture:GetData(player).Cards2) do
			if id <= 0 then
				num = num + 1
			end
		end

		if flag == CacheFlag.CACHE_DAMAGE then
			self._Stats:Damage(player, num)
		end

		if flag == CacheFlag.CACHE_FIREDELAY then
			self._Stats:TearsModifier(player, num)
		end
	end	
end
Skill:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvalueateCache')

return Skill