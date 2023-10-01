--爸约

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Trinket = mod.IBS_Trinket


--拾取尝试添加计时器
local function TryAddTimer()
	local data = mod:GetIBSData("Temp")

	if data.dadsPromiseTimer == nil then
		data.dadsPromiseTimer = 0
	end
end
mod:AddCallback(IBS_Callback.PICK_TRINKET, TryAddTimer, IBS_Trinket.dadspromise)

--计时器
local function Timer()
	local data = mod:GetIBSData("Temp")
	
	if data.dadsPromiseTimer ~= nil then
		data.dadsPromiseTimer = data.dadsPromiseTimer + 1
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, Timer)

--重置计时
local function ResetTimer()
	local data = mod:GetIBSData("Temp")
	local has = false
	
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasTrinket(IBS_Trinket.dadspromise) then	
			has = true
			break
		end
	end
	
	if has then
		data.dadsPromiseTimer = 0
	else	
		data.dadsPromiseTimer = nil
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, ResetTimer)

--尝试生成骰子碎片
local function Dice()
	local game = Game()
	local room = game:GetRoom()
	local level = game:GetLevel()
	local stage = level:GetStage()
	
	if (room:GetType() == RoomType.ROOM_BOSS) then
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasTrinket(IBS_Trinket.dadspromise) then
				local data = mod:GetIBSData("Temp")
				local mult = player:GetTrinketMultiplier(IBS_Trinket.dadspromise) - 1
			
				if (not data.dadsPromiseTimer) or data.dadsPromiseTimer <= 30*(45 + stage*(15 + 5*mult)) then
					local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, 49, pos, Vector.Zero, player)
				end
			end
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, Dice)


