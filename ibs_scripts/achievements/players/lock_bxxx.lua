--解锁昧化???

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local CharacterLock = mod.IBS_Class.CharacterLock

local game = Game()
local sfx = SFXManager()

local BXXX = CharacterLock(mod.IBS_PlayerID.BXXX, {'bxxx_unlock'} )

--找到表里蓝人
function BXXX:BlueBabyFound()
	for i = 0, game:GetNumPlayers() -1 do
		local playerType = Isaac.GetPlayer(i):GetPlayerType()
		if (playerType == 4) or (playerType == 25) then
			return true
		end
	end
	return false
end

--进入家层红房间触发
function BXXX:OnNewRoom()
	if self:IsLocked() and not game:AchievementUnlocksDisallowed() then
		local room = game:GetRoom()
		local level = game:GetLevel()
		
		if room:IsFirstVisit() and level:GetStage() == 13 and level:GetCurrentRoomDesc().SafeGridIndex == 94 and self:BlueBabyFound() then
			for _,keeper in pairs(Isaac.FindByType(17)) do
				keeper:Remove()
			end
			for _,pickup in pairs(Isaac.FindByType(5)) do
				pickup:Remove()
			end
			local item = Isaac.Spawn(5, 100, IBS_ItemID.Falowerse, room:GetCenterPos(), Vector.Zero, nil):ToPickup()
			item:Morph(5, 100, IBS_ItemID.Falowerse, true, true, true)
			sfx:Play(mod.IBS_Sound.SecretFound, 1.5)
		end		
	end
end
BXXX:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--在家层获得薇艺时,为表里蓝人时解锁表表蓝人
function BXXX:OnGainItem(item, charge, first, slot, varData, player)
	if slot < 0 or slot > 1 then return end
	if self:IsUnlocked() or game:AchievementUnlocksDisallowed() then return end
	local level = game:GetLevel()
	if level:GetStage() == 13 and level:GetCurrentRoomDesc().SafeGridIndex == 94 then	
		local playerType = player:GetPlayerType()
		if playerType == 4 or playerType == 25 then
			self:Unlock(true, true)
		end
	end
end
BXXX:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', IBS_ItemID.Falowerse)


return BXXX