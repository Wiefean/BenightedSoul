--参孙技能
--倒审判

local mod = Isaac_BenightedSoul
local BigLight = mod.IBS_Effect.BigLight

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(76, {
	IsReversed = true,
})


--生成光柱
function Skill:Judgement(player)
	local dmg = math.max(2.45, 0.7*(player.Damage))
	local scale = math.min(4, 1.5 * math.max(1, player.SpriteScale.X))
	local hurtPlayer = false
	local followEnemy = false
	local followPlayer = true
	local timeout = 105 * self:GetCardNum(player)
	local effect = BigLight:Spawn(player, dmg, scale, hurtPlayer, followEnemy, followPlayer, timeout, player.Position, 0.5)

	effect:GetSprite().Color = Color(1,1,1,0.2)

	return effect
end

function Skill:OnPlayerUpdate(player)
	if not self:HasCard(player) then return end
	local data = self:GetTempData(player)
	local state = self:GetBSamsonState(player)
	data.State = data.State or 0
	
	if data.State ~= state then
		data.State = state

		if state == 0 and #Isaac.FindByType(1000, BigLight.Variant, 0) <= 0 then
			self:Judgement(player)
		end
	end
end
Skill:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, "OnPlayerUpdate", 0)


return Skill