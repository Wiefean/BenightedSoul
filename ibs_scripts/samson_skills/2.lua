--参孙技能
--魔术师

local mod = Isaac_BenightedSoul
local Screens = mod.IBS_Lib.Screens
local Swing = mod.IBS_Effect.Swing

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(2, {
	CalmCost = 2,
	WrathCost = 2,
})

--颜色
Skill.SwingColor = Color(1,0.2,1,1)

--施加标记
function Skill:AddMark(ent, num)
	local data = self:GetTempData(ent)
	data.mark = (data.mark or 0) + num
end

--准备攻击
Skill.PreAttack = function(player, compats, params)
	if not params._K2 then
		params._K2 = true
		params.Color = params.Color * Skill.SwingColor
	end
end

--攻击
Skill.OnAttack = function(player, compats, targets)
	local self = Skill
	
	for _,ent in ipairs(targets) do
		if ent:IsActiveEnemy() and self._Ents:IsEnemy(ent, true) then
			self:AddMark(ent, 1)
		end
	end
end

--拆分数字
local function SplitNumber(num)
	local result = {}
	
	local str = tostring(num)
	for i = 1,string.len(str) do
		table.insert(result, tonumber(string.sub(str, i, i)))
	end
	
	return result
end

local markSpr = Sprite()
markSpr:Load("gfx/ibs/ui/price.anm2", true)
markSpr:SetFrame('Shop', 0)
markSpr.Color = Color(1, 0.5, 1, 0.5)

--显示标记数量
function Skill:OnNpcRender(npc, offset)
	local data = self:GetTempData(npc, true)
	
	if data and data.mark and data.mark > 0 then
		local numbers = SplitNumber(data.mark)

		--获取尺寸和第一个数字的位置修正
		local length = #numbers
		local scale = math.max(0.4, 1 / length)
		local firstOffset = offset + Vector(-6*scale*length, scale*length)
		markSpr.Scale = Vector(scale,scale)

		for k,v in ipairs(numbers) do
			local offset2 = firstOffset + Vector(11*scale*k,0)
			local pos = Screens:WorldToScreen(npc.Position, offset2)
			markSpr:SetFrame(v)
			markSpr:Render(pos)
		end
	end
end
Skill:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, "OnNpcRender")

--增伤
function Skill:OnTakeDMG(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end
	if self._Ents:IsEnemy(ent, true) then
		local data = self:GetTempData(ent, true)
		if data and data.mark and data.mark > 0 then		
			return {Damage = dmg + data.mark}
		end
	end
end
Skill:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -1000, 'OnTakeDMG')

--寻找目标
function Skill:FindTargets()
	local result = {}

	for _,ent in ipairs(Isaac.GetRoomEntities()) do
		if self._Ents:IsEnemy(ent, true) then
			table.insert(result, ent)
		end
	end

	return result
end

--生成特效
function Skill:FX(player, target)
	local angle = 90 + (player.Position - target.Position):GetAngleDegrees()
	local effect = Swing:Spawn(target.Position, angle, player)
	local spr = effect:GetSprite()
	
	spr.Scale = Vector(1,0.5)
	spr.Color = Skill.SwingColor
	
	return effect
end

--平静使用
Skill.CalmOnUse = function(player, compats)
	local self = Skill
	local targets = self:FindTargets()
	
	for _,target in ipairs(targets) do
		self:AddMark(target, 10)
		self:FX(player, target)
	end
	sfx:Play(45, 0.7, 2, false, 2)
	sfx:Play(594, 0.5, 10)
	
	--临时弯勺效果
	local effects = player:GetEffects()
	if not effects:HasCollectibleEffect(3) then	
		effects:AddCollectibleEffect(3)
	end
end

--暴怒使用
Skill.WrathOnUse = function(player, compats)
	local self = Skill
	local targets = self:FindTargets(player)
	
	if #targets > 0 then
		for _,target in ipairs(targets) do
			local data = self:GetTempData(target, true)
			if data and data.mark and data.mark > 0 then
				self._Ents:LoseHP(target, 10 * data.mark, true)
				target:BloodExplode()
				Isaac.Spawn(1000,2,0, target.Position, Vector.Zero, nil)
			end
		end
	end
end

--属性
function Skill:OnEvalueateCache(player, flag)
	if self:HasCard(player) and flag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage * 0.5
	end	
end
Skill:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 100, 'OnEvalueateCache')


return Skill