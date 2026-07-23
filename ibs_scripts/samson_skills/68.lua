--参孙技能
--倒倒吊人

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(68, {
	IsReversed = true,
})

--颜色
Skill.SwingColor = Color(0.9,0.7,0.1,1)

--准备攻击
Skill.PreAttack = function(player, compats, params)
	if not params._K68 and Skill:GetTempData(player).Midas then
		params._K68 = true
		params.Color = params.Color * Skill.SwingColor
	end
end

--点金
function Skill:AddMidas(player, ent)
	ent:SetBossStatusEffectCooldown(0)
	ent:AddMidasFreeze(EntityRef(player), 60)
	if ent:GetMidasFreezeCountdown() < 60 then
		ent:SetMidasFreezeCountdown(60)
	end		
end

--攻击
Skill.OnAttack = function(player, compats, targets)
	local self = Skill
	local data = self:GetTempData(player)
	
	if data.Midas then	
		for _,ent in ipairs(targets) do
			if self._Ents:IsEnemy(ent) then
				self:AddMidas(player, ent)
			end
		end
	end
end

--攻击后
Skill.PostAttack = function(player, compats)
	local data = Skill:GetTempData(player)
	if data.Midas and not data.MidasDecreased then
		if data.Midas > 1 then
			data.Midas = data.Midas - 1
		else
			data.Midas = nil
		end
		data.MidasDecreased = true
	end
end

function Skill:OnPlayerUpdate(player)
	local data = self:GetTempData(player, true)
	if data and data.MidasDecreased then
		data.MidasDecreased = nil
	end
end
Skill:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, "OnPlayerUpdate", 0)

--切换房间触发
function Skill:OnNewRoom()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if self:HasCard(player) then
			self:GetTempData(player).Midas = self:GetCardNum(player)
		else
			self:GetTempData(player).Midas = nil
		end
	end	
end
Skill:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')


return Skill