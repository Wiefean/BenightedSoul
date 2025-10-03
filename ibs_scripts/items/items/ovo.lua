--OvO

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats
local Swing = mod.IBS_Effect.Swing

local game = Game()
local sfx = SFXManager()

local OvO = mod.IBS_Class.Item(mod.IBS_ItemID.OvO)

--获取数据
function OvO:GetData(player)
	local data = self._Ents:GetTempData(player)
	data.OvO = data.OvO or {Left = 20}
	return data.OvO
end

--取中间值
local function Lerp(vec1, vec2, percent)
    return vec1 * (1 - percent) + vec2 * percent
end

--角色更新
function OvO:OnPLayerUpdate(player)
	if player:IsFrame(4,0) and player:HasCollectible(self.ID) then
		local data = self:GetData(player)
		
		--造成伤害直到机会耗尽
		if data.Left > 0 then
			local target = self._Finds:ClosestEnemy(player.Position)
			if target ~= nil and target.Position:Distance(player.Position) <= 80 + 1.2*target.Size then
				data.Left = data.Left - 1
				target:SetBossStatusEffectCooldown(0)
				target:AddFreeze(EntityRef(player), 15)
				target:TakeDamage(math.max(3.3, 0.666*player.Damage), 0, EntityRef(player), 0)
				
				Swing:Spawn(Lerp(player.Position, target.Position, 0.4), 90 + (player.Position - target.Position):GetAngleDegrees(), player)
				sfx:Play(252)
			end		
		end
		
	end
end
OvO:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPLayerUpdate', 0)

--切换房间重置
function OvO:ResetData()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		self._Ents:GetTempData(player).OvO = nil
	end
end
OvO:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'ResetData')
OvO:AddCallback(mod.IBS_CallbackID.GREED_WAVE_CHANGE, 'ResetData') --贪婪模式波次切换

--属性改动
function OvO:OnEvaluateCache(player, flag)
	if not player:HasCollectible(self.ID) then return end
	if flag == CacheFlag.CACHE_SPEED then
		Stats:Speed(player, 0.3*player:GetCollectibleNum(self.ID))
	end
end
OvO:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


return OvO