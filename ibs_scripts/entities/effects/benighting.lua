--用于切换至昧化角色的光柱

local mod = Isaac_BenightedSoul
local IBS_API = mod.IBS_API
local IBS_Callback = mod.IBS_Callback
local Finds = mod.IBS_Lib.Finds
local Ents = mod.IBS_Lib.Ents

local BenightingVariant = mod.IBS_Effect.Benighting.Variant
local ErrorTipName = "IBS_API"

--将角色ID转换为字符串索引
local PlayerTypeToKey = {
	[PlayerType.PLAYER_ISAAC] = "bisaac",
	[PlayerType.PLAYER_MAGDALENE] = "bmaggy",
	[PlayerType.PLAYER_CAIN] = "bcain_and_babel",
	[PlayerType.PLAYER_JUDAS] = "bjudas",
}
local function ToKey(playerType)
	local key = PlayerTypeToKey[playerType]

	return key or "NILLLLLLLLLLLLLLLLLL"
end

--用于模组角色兼容
local ModPlayer = {}

function IBS_API:RegisterBenightableCharacter(id, gfxPath, condition)
	local err,mes = mod:CheckArgType(id, "number", nil, 1, ErrorTipName)
	if err then error(mes, 2) end
	err,mes = mod:CheckArgType(gfxPath, "string", nil, 2, ErrorTipName, true)
	if err then error(mes, 2) end
	err,mes = mod:CheckArgType(condition, "function", nil, 3, ErrorTipName, true)
	if err then error(mes, 2) end
	
	gfxPath = gfxPath or ""
	
	ModPlayer[id] = {Gfx = gfxPath, Condition = condition}
end

--临时数据
local function GetEffectData(effect)
	local data = Ents:GetTempData(effect)
	data.Benighting_Effect = data.Benighting_Effect or {
		TimeOut = 21,
		LastModPlayer = 0
	}
	return data.Benighting_Effect
end

--变身条件
local function CanHenshin()
	local notInChallenge = Isaac.GetChallenge() <= 0
	local notInLap = Game():GetVictoryLap() <= 0
	
	--非挑战,非跑圈
	return notInChallenge and notInLap 
end

--初始房间生成光柱
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	local game = Game()
	if (game:GetFrameCount() == 30) and CanHenshin() then --开局1秒
		local level = game:GetLevel()
		local offset = Vector(0,0)
		if game:IsGreedMode() then
			offset = Vector(0,-100)
		end
		
		if level:GetStartingRoomIndex() == level:GetCurrentRoomIndex() then
			local room = game:GetRoom()
			local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos() + offset, 0, true)
			Isaac.Spawn(1000, BenightingVariant, 0, pos, Vector.Zero, nil)
		end
	end
end)

--更新动画,触发回调
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_,effect)
	local spr = effect:GetSprite()
	if spr:IsFinished("Appear") or not spr:IsPlaying("Appear") then
		local data = GetEffectData(effect)
		local player = Finds:ClosestPlayer(effect.Position):ToPlayer()
		local playerType = player:GetPlayerType()
		local KEY = ToKey(playerType)
		local mark = IBS_Data.Setting[KEY]
		local modPlayer = ModPlayer[playerType]
		local ready = false
		
		if CanHenshin() then
			if mark and mark.Unlocked then
				spr:Play(KEY, false)
				ready = true
			elseif modPlayer and (not modPlayer.Condition or modPlayer.Condition(player)) then
				if data.LastModPlayer ~= playerType then
					data.LastModPlayer = playerType
					spr:ReplaceSpritesheet(3, modPlayer.Gfx)
					spr:LoadGraphics()
				end
				spr:Play("Mod", false)
				ready = true
			else
				spr:Play("Disappear", false)
			end
			
			if ready then
				local dist = (effect.Position - player.Position):Length()

				if dist <= 17 then
					if data.TimeOut == nil then data.TimeOut = 0 end
					
					if data.TimeOut > 0 then
						data.TimeOut = data.TimeOut - 1
					else
						data.TimeOut = 21
						Isaac.RunCallbackWithParam(IBS_Callback.BENIGHTED_HENSHIN, playerType, player, playerType)
					end
				elseif data.TimeOut ~= 21 then
					data.TimeOut = 21
				end
			end
		else
			spr:Play("Disappear", false)
		end
	end
end, BenightingVariant)
