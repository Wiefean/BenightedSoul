--北落师门

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()

local Fomalhaut = mod.IBS_Class.Item(mod.IBS_ItemID.Fomalhaut)

--获得时光效
function Fomalhaut:OnGain(item, charge, first, slot, varData, player)
	if player:GetCollectibleNum(self.ID) == 1 then
		self._Ents:ApplyLight(player, 7, Color(0,0,1,10, 0.15, 0.15, 0.15), function(effect)
			--被移除时失去光效
			if not player:HasCollectible(IBS_ItemID.Fomalhaut) then
				effect:Remove()
			end
		end)
	end
end
Fomalhaut:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', Fomalhaut.ID)

--角色初始化时光效
function Fomalhaut:OnPlayerInit(player)
	if player:HasCollectible(self.ID) then
		self._Ents:ApplyLight(player, 7, Color(0,0,1,10, 0.15, 0.15, 0.15), function(effect)
			--被移除时失去光效
			if not player:HasCollectible(IBS_ItemID.Fomalhaut) then
				effect:Remove()
			end
		end)
	end
end
Fomalhaut:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, 'OnPlayerInit')

--角色火焰和爆炸
function Fomalhaut:PrePlayerTakeDMG(player, dmg, flag, source)

	--忽略白火伤害
	if source and source.Type == 33 and source.Variant == 4 then
		return
	end

	if player:HasCollectible(self.ID) and (flag & DamageFlag.DAMAGE_FIRE > 0 or flag & DamageFlag.DAMAGE_EXPLOSION > 0) then
		return false
	end
end
Fomalhaut:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, -800, 'PrePlayerTakeDMG')

--受伤触发
function Fomalhaut:OnTakeDamage(ent, dmg, flag, source)
	if dmg <= 0 then return end
	if not self._Ents:IsEnemy(ent) then return end
	
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			local data = self._Ents:GetTempData(ent)
			if not data.FomalhautTriggered then
				data.FomalhautTriggered = true
				local fire = Isaac.Spawn(1000, 10, 0, ent.Position, RandomVector(), player):ToEffect()
				local scale = (ent.Size / 20)
				fire.Parent = player
				fire.CollisionDamage = math.max(3.5, player.Damage) * scale
				fire.Timeout = 540
				fire.Scale = scale
			end
		end
	end
	
end
Fomalhaut:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDamage')

return Fomalhaut