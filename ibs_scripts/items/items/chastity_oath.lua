--贞洁之誓

local mod = Isaac_BenightedSoul
local Damage = mod.IBS_Class.Damage()
local AbandonedItem = mod.IBS_Effect.AbandonedItem

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local OOC = mod.IBS_Class.Item(mod.IBS_ItemID.OOC)

--获取数据
function OOC:GetData(player)
	local data = self._Players:GetData(player)
	data.OathOfChastity = data.OathOfChastity or {Left = 7}
	return data.OathOfChastity
end

--新层刷新
function OOC:OnNewLevel()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = self._Players:GetData(player).OathOfChastity
		if data then
			data.Left = 7
		end
	end
end
OOC:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, -7777, 'OnNewLevel')

--抵挡面前子弹,受伤清除子弹,爆炸伤害以半心替代
function OOC:OnTakeDMG(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end
	local player = ent:ToPlayer(); if not player then return end
	if not Damage:IsPenalt(player, flag, source) then return end
	if not player:HasCollectible(self.ID) then return end

	local data = self:GetData(player)
	if data.Left > 0 then
		data.Left = data.Left - 1
		sfx:Play(568, 1, 2, false, 0.7)
		local effect = Isaac.Spawn(1000,16,2, player.Position, Vector.Zero, nil):ToEffect()
		effect:FollowParent(player)
		effect.Color = Color(1,1,1,1,0,1,1)
		return {Damage = 1, DamageFlags = flag | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_NO_MODIFIERS, DamageCountdown = cd}
	elseif player:HasCollectible(self.ID, true) then
		--失去
		player:RemoveCollectible(self.ID)
		sfx:Play(267)
		local itemConfig = config:GetCollectible(self.ID)
		if itemConfig.GfxFileName then
			AbandonedItem:Spawn(player.Position, itemConfig.GfxFileName, RandomVector() * 0.1 * math.random(10, 15))
		end		
	end
end
OOC:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 7777, 'OnTakeDMG')

--秒杀乌列/加百列
function OOC:OnNPCUpdate(npc)
	if npc.Variant > 1 then return end
	if npc.Type ~= 271 and npc.Type ~= 272 then return end
	if npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then return end
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	npc.HitPoints = npc.HitPoints - 0.1*npc.MaxHitPoints
	if npc.HitPoints <= 0 then
		npc:Die()
	end
end
OOC:AddCallback(ModCallbacks.MC_NPC_UPDATE, 'OnNPCUpdate')

--属性
function OOC:OnEvalueateCache(player, flag)
	if player:HasCollectible(self.ID) then
		if flag == CacheFlag.CACHE_LUCK then
			self._Stats:Luck(player, 3*player:GetCollectibleNum(self.ID))
		end
	end	
end
OOC:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvalueateCache')

return OOC