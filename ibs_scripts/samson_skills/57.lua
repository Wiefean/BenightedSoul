--参孙技能
--倒魔术师

local mod = Isaac_BenightedSoul
local Screens = mod.IBS_Lib.Screens
local Damage = mod.IBS_Class.Damage()

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(57, {
	IsReversed = true,
})

--属性
function Skill:OnEvalueateCache(player, flag)
	if self:HasCard(player) and flag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage * 2 * self:GetCardNum(player)
	end	
end
Skill:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 100, 'OnEvalueateCache')

--受伤标记
function Skill:OnTakeDMG(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end
	local player = ent:ToPlayer()
	
	if player and self:HasCard(player) and Damage:IsPenalt(player, flag, source) then
		local data = self:GetPlayerData(player)
		data.Mark = (data.Mark or 0) + self:GetCardNum(player)
	end
end
Skill:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDMG')

--标记额外受伤
function Skill:PreTakeDMG(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end
	local player = ent:ToPlayer()

	if player and self:HasCard(player) and Damage:IsPenalt(player, flag, source) then
		local data = self:GetPlayerData(player)
		return {Damage = dmg + (data.Mark or 0)}
	end
end
Skill:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -101, 'PreTakeDMG')

--新层清除标记
function Skill:OnNewLevel()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = self:GetPlayerData(player, true)
		if data then
			data.Mark = nil
		end
	end	
end
Skill:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')



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
function Skill:OnPlayerRender(player, offset)
	local data = self:GetPlayerData(player, true)
	
	if data and data.Mark and data.Mark > 0 then
		local numbers = SplitNumber(data.Mark)

		--获取尺寸和第一个数字的位置修正
		local length = #numbers
		local scale = math.max(0.4, 1 / length)
		local firstOffset = offset + Vector(-6*scale*length, scale*length)
		markSpr.Scale = Vector(scale,scale)

		for k,v in ipairs(numbers) do
			local offset2 = firstOffset + Vector(11*scale*k,0)
			local pos = Screens:WorldToScreen(player.Position, offset2)
			markSpr:SetFrame(v)
			markSpr:Render(pos)
		end
	end
end
Skill:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, "OnPlayerRender", 0)


return Skill