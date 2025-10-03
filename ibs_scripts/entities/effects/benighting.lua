--用于切换至昧化角色的光柱,现仅用于多人模式

local mod = Isaac_BenightedSoul
local IBS_EffectID = mod.IBS_EffectID

local game = Game()
local sfx = SFXManager()

local Benighting = mod.IBS_Class.Effect{
	Variant = IBS_EffectID.Benighting.Variant,
	SubType = IBS_EffectID.Benighting.SubType,
	Name = {zh = '愚光', en = 'Benighting'}
}

--角色列表
Benighting.List = {
	[PlayerType.PLAYER_ISAAC] = 'BIsaac',
	[PlayerType.PLAYER_MAGDALENE] = 'BMaggy',
	[PlayerType.PLAYER_CAIN] = 'BCBA',
	[PlayerType.PLAYER_JUDAS] = 'BJudas',
	[PlayerType.PLAYER_BLUEBABY] = 'BXXX',
	[PlayerType.PLAYER_EDEN] = 'BEden',
	[PlayerType.PLAYER_KEEPER] = 'BKeeper',
}

--临时数据
function Benighting:GetData(effect)
	local data = self._Ents:GetTempData(effect)
	data.Benighting_Effect = data.Benighting_Effect or {Timeout = 21}
	return data.Benighting_Effect
end

--检测联机模式
function Benighting:IsCoopMode()
	if Isaac.GetChallenge() > 0 then return false end --挑战
	if game:GetVictoryLap() > 0 then return false end --跑圈
	local playerNum = 0
	local controllers = {}

	--计算玩家数
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local cid = player.ControllerIndex

		if (not controllers[cid]) and (player.Variant == 0) and not player:IsCoopGhost() and not player.Parent then
			playerNum = playerNum + 1
		end

		controllers[cid] = true
	end

	--需要至少两个玩家
	return (playerNum >= 2)
end

--检测变身条件
function Benighting:CanBenight(playerType)
	--检测角色是否解锁
	local mark = self:GetIBSData('persis')[self.List[playerType] or '']
	if mark and mark.Unlocked then
		return true
	end
	return false
end

--是否有角色能变身
function Benighting:AnyCanBenight()
	for i = 0, game:GetNumPlayers() -1 do
		if self:CanBenight(Isaac.GetPlayer(i):GetPlayerType()) then
			return true
		end
	end
	return false
end


--更新
function Benighting:OnUpdate(effect)
	local data = self:GetData(effect)
	local spr = effect:GetSprite()

	--非联机模式收起光柱
	if not self:IsCoopMode() then
		data.Timeout = 21
		spr:Play("Disappear")
		return		
	end

	--房间未清理时收起光柱,主要用于贪婪模式
	if not game:GetRoom():IsClear() then
		data.Timeout = 21
		spr:Play("Disappear")
		return
	end

	local player = self._Finds:ClosestPlayer(effect.Position):ToPlayer()
	
	if player and self:CanBenight(player:GetPlayerType()) then
		local playerType = player:GetPlayerType()

		if not spr:IsPlaying("Appear") then
			spr:Play("Appear", false)
		end

		if effect.Position:Distance(player.Position) <= 17 then
			if data.Timeout > 0 then
				data.Timeout = data.Timeout - 1
			else
				data.Timeout = 21
				Isaac.RunCallbackWithParam(mod.IBS_CallbackID.BENIGHTED, playerType, player, false)
			end
		else
			data.Timeout = 21
		end
	else
		data.Timeout = 21
		spr:Play("Disappear", false)
	end
end
Benighting:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnUpdate', Benighting.Variant)



--开局生成光柱
function Benighting:OnGameStarted()
	local level = game:GetLevel()
	local offset = Vector(0,0)
	if game:IsGreedMode() then
		offset = Vector(0,-100)
	end

	if level:GetStartingRoomIndex() == level:GetCurrentRoomIndex() then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos() + offset, 0, true)
		local effect = Isaac.Spawn(1000, Benighting.Variant, 0, pos, Vector.Zero, nil)

		if not self:IsCoopMode() or not self:AnyCanBenight() then
			effect:GetSprite():SetFrame("Disappear", 700)
		end
	end
end
Benighting:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, 'OnGameStarted')


return Benighting