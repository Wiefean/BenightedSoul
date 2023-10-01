--用于切换至昧化角色的光柱

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local Finds = mod.IBS_Lib.Finds
local Ents = mod.IBS_Lib.Ents

local Variant = Isaac.GetEntityVariantByName("IBS_Benighting")

--将角色ID转换为字符串索引
local PlayerTypeToKey = {
	[PlayerType.PLAYER_ISAAC] = "bisaac",
	[PlayerType.PLAYER_MAGDALENE] = "bmaggy",
	
	[PlayerType.PLAYER_JUDAS] = "bjudas",
}
local function ToKey(playerType)
	local key = PlayerTypeToKey[playerType]

	return key or "NILLLLLLLLLLLLLLLLLL"
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
			Isaac.Spawn(1000, Variant, 0, pos, Vector.Zero, nil)
		end
	end
end)

--更新动画,触发回调
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_,effect)
	local spr = effect:GetSprite()
	if spr:IsFinished("Appear") or not spr:IsPlaying("Appear") then
		local player = Finds:ClosestPlayer(effect.Position):ToPlayer()
		local playerType = player:GetPlayerType()
		local KEY = ToKey(playerType)
		local mark = IBS_Data.Setting[KEY]
		
		if mark and mark.Unlocked and CanHenshin() then
			spr:Play(KEY, false)
			local data = Ents:GetTempData(player)
			local dist = (effect.Position - player.Position):Length()

			if dist <= 15 then
				if data.BenightingTimeOut == nil then data.BenightingTimeOut = 0 end
				
				if data.BenightingTimeOut < 50 then
					data.BenightingTimeOut = data.BenightingTimeOut + 1
				else
					data.BenightingTimeOut = 0
					Isaac.RunCallbackWithParam(IBS_Callback.BENIGHTED_HENSHIN, playerType, player, playerType)
				end
			elseif data.BenightingTimeOut ~= nil then
				data.BenightingTimeOut = nil
			end
		else
			spr:Play("Disappear", false)
		end
	end
end, Variant)
