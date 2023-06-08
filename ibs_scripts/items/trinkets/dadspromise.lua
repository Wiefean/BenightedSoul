--爸约

local mod = Isaac_BenightedSoul
local IBS_RNG = mod.IBS_RNG
local IBS_Trinket = mod.IBS_Trinket


--初始化数据
local function TryInit()
	if IBS_Data.GameState.Temp.dadspromisetimer == nil then
		IBS_Data.GameState.Temp.dadspromisetimer = 0
	end
end

--计时器
local function Timer()
	TryInit()
	IBS_Data.GameState.Temp.dadspromisetimer = IBS_Data.GameState.Temp.dadspromisetimer + 1
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, Timer)

--重置计时
local function ResetTime()
	TryInit()
	IBS_Data.GameState.Temp.dadspromisetimer = 0
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, ResetTime)

--尝试生成骰子碎片
local function Dice()
	if (Game():GetRoom():GetType() == RoomType.ROOM_BOSS) then
		for i = 0, Game():GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasTrinket(IBS_Trinket.dadspromise) then
				local mult = player:GetTrinketMultiplier(IBS_Trinket.dadspromise) - 1
				local stage = Game():GetLevel():GetStage()
			
				if IBS_Data.GameState.Temp.dadspromisetimer <= 30*(45 + stage*(15 + 5*mult)) then
					local pos = Game():GetRoom():FindFreePickupSpawnPosition((Game():GetLevel():GetCurrentRoom():GetCenterPos()), 0, true)
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, 49, pos, Vector.Zero, player)
				end
			end
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, Dice)


