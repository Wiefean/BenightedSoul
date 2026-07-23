--参孙技能
--命运之轮

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(11, {
	CalmStateTrans = 1,
	WrathStateTrans = 1,
	
	CalmCost = 0,
	WrathCost = 3,
})

--准备攻击
Skill.PreAttack = function(player, compats, params)
	params.Size = params.Size * 1.1
	
	--收集信息
	local data = Skill:GetTempData(player)
	data.Radius = 0.7 * params.Size * params.Scale
end

--传送攻击
function Skill:TeleportAttack(player)
	local radius = self:GetTempData(player).Radius or 30
	local targets = {}
	
	for _,ent in ipairs(Isaac.GetRoomEntities()) do
		if self._Ents:IsEnemy(ent) then
			table.insert(targets, ent)
		end
	end	
	
	if #targets > 0 then	
		self:ShuffleTable(targets, math.random(1,#targets)) --打乱顺序
		for _,target in ipairs(targets) do
			local pos = target.Position
			radius = radius + target.Size

			local X = (-1)^math.random(1,2) * radius
			local Y = (-1)^math.random(1,2) * radius
			
			pos = pos + Vector(X, Y)
			self._Players:TeleportToPosition(player, pos, true, true, 30)
			
			mod.IBS_Item.Posture:DoAttack(player, (target.Position - player.Position):Normalized(), true)
			
			return target
		end
	end
end

--计算攻击次数
function Skill:CalculateTimes(player)
	local times = 0

	local rng = player:GetCardRNG(self.ID)
	local luck = player.Luck + 3
	if luck > 0 then
		luck = math.min(14, math.floor(luck))
		for i = 1,luck do
			if rng:RandomInt(100) < 50 then
				times = times + 1
			end
		end
	end
	
	return times
end

--平静使用
Skill.CalmOnUse = function(player, compats)
	Skill:TeleportAttack(player)
end

--暴怒使用
Skill.WrathOnUse = function(player, compats)
	local self = Skill
	
	if self:TeleportAttack(player) then
		--概率重复多次
		local times = self:CalculateTimes(player)
		if times > 0 then
			for i = 1,times do
				self:DelayFunction(function()
					self:ChangeSamsonState(player, 1)
					self:TeleportAttack(player)
				end, i * 3)
			end
		end	
	end
end

--属性
function Skill:OnEvalueateCache(player, flag)
	if self:HasCard(player) and flag == CacheFlag.CACHE_FLYING then
		player.CanFly = true
	end	
end
Skill:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvalueateCache')

return Skill