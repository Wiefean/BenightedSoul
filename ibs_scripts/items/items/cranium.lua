--奇怪的头骨

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local Players = mod.IBS_Lib.Players

--下层记录
local function OnNewLevel()
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		
		if player:HasCollectible(IBS_Item.cranium) then
			local data = Players:GetData(player)
			local effect = player:GetEffects()
			data.WeirdCranium = true
			if not effect:HasNullEffect(NullItemID.ID_LOST_CURSE) then
				effect:AddNullEffect(NullItemID.ID_LOST_CURSE)
			end
		else
			data.WeirdCranium = nil
		end	
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, OnNewLevel)

--检测状态
local function OnNewRoom()
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local effect = player:GetEffects()
		local data = Players:GetData(player)
		
		if not player:HasCollectible(IBS_Item.cranium) then
			data.WeirdCranium = nil
		end
		
		if data.WeirdCranium then
			if not effect:HasNullEffect(NullItemID.ID_LOST_CURSE) then
				effect:AddNullEffect(NullItemID.ID_LOST_CURSE)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, OnNewRoom)

--完成Boss房清除记录
local function OnBoss()
	if (Game():GetRoom():GetType() == RoomType.ROOM_BOSS) then
		for i = 0, Game():GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			local data = Players:GetData(player)
			
			if data.WeirdCranium then
				player:AddBlackHearts(6)			
				SFXManager():Play(SoundEffect.SOUND_UNHOLY)
				data.WeirdCranium = nil
				if not Game():GetRoom():IsMirrorWorld() then --不在镜子里
					if effect:HasNullEffect(NullItemID.ID_LOST_CURSE) then
						effect:RemoveNullEffect(NullItemID.ID_LOST_CURSE)
					end
				end					
			end
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, OnBoss)