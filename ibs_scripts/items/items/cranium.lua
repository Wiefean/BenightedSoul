--奇怪的头骨

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local Players = mod.IBS_Lib.Players
local Finds = mod.IBS_Lib.Finds

--下层记录
local function OnNewLevel()
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = Players:GetData(player)
		
		if player:HasCollectible(IBS_Item.cranium) then
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
	local game = Game()
	local room = game:GetRoom()
	
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local effect = player:GetEffects()
		local data = Players:GetData(player)
	
		--没有道具直接清除记录
		if not player:HasCollectible(IBS_Item.cranium) then
			data.WeirdCranium = nil
		end		
		
		if (room:GetType() == RoomType.ROOM_BOSS) then --Boss房
			if data.WeirdCranium then
				player:AddBlackHearts(2)			
				SFXManager():Play(SoundEffect.SOUND_UNHOLY)
				data.WeirdCranium = nil
				if not room:IsMirrorWorld() then --不在镜子里
					if effect:HasNullEffect(NullItemID.ID_LOST_CURSE) then
						effect:RemoveNullEffect(NullItemID.ID_LOST_CURSE)
					end
				end					
			end
		else	
			if data.WeirdCranium then
				if not effect:HasNullEffect(NullItemID.ID_LOST_CURSE) then
					effect:AddNullEffect(NullItemID.ID_LOST_CURSE)
				end
				
				--正邪增强(东方mod)
				if mod:THI_WillSeijaBuff(player) and (Finds:ClosestEnemy(player.Position) ~= nil) then
					player:UseActiveItem(58, false, false)
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, OnNewRoom)

