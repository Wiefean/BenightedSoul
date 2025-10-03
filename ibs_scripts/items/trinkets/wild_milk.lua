--猛牛牛奶

local mod = Isaac_BenightedSoul
local Damage = mod.IBS_Class.Damage()

local game = Game()

local WildMilk = mod.IBS_Class.Trinket(mod.IBS_TrinketID.WildMilk)

--设置触发状态
function WildMilk:SetTriggered(player, bool)
	local data = self._Ents:GetTempData(player)
	data.WildMilkTriggered = bool
end

--是否已经触发
function WildMilk:IsTriggered(player)
	local data = self._Ents:GetTempData(player)
	return (data.WildMilkTriggered ~= nil) and data.WildMilkTriggered
end

--是否能触发
function WildMilk:ShouldTrigger(player, flag, source)
	if self:IsTriggered(player) then
		return false
	end
	return Damage:IsPenalt(player, flag, source)
end

--切换房间重置数据
function WildMilk:OnNewRoom()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		self:SetTriggered(player, nil)
	end
end
WildMilk:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--减少受伤
function WildMilk:OnTakeDMG(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end
	local player = ent:ToPlayer()
	if player and player:HasTrinket(self.ID) and self:ShouldTrigger(player, flag, source) then
		local mult = player:GetTrinketMultiplier(self.ID)
		
		dmg = math.max(0, dmg - mult)
		
		--伤害为0时设置为假伤害
		if dmg <= 0 then
			dmg = 1
			flag = flag | DamageFlag.DAMAGE_FAKE
		end
		flag = flag | DamageFlag.DAMAGE_NO_PENALTIES

		self:SetTriggered(player, true)
		
		self:DelayFunction(function()
			player:ResetDamageCooldown()
			player:SetMinDamageCooldown(1)
		end, 1)
		
		return {Damage = dmg, DamageFlags = flag}
	end
end
WildMilk:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.IMPORTANT, 'OnTakeDMG')


return WildMilk