--掌门

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()
local sfx = SFXManager()

local Doormaker = mod.IBS_Class.Transformation("trans_doormaker", {
	Name = {
		zh = '掌门！',
		en = 'Doormaker!',
	},

	CostumeID = Isaac.GetCostumeIdByPath('gfx/ibs/characters/trans_doormaker.anm2'),

	ItemList = {
		[17] = true, --骷髅钥匙
		[175] = true, --爸爸的钥匙
		[199] = true, --妈妈的钥匙
		[343] = true, --弹簧锁钥匙
		[580] = true, --红钥匙
		[623] = true, --尖头钥匙
		[636] = true, --R键

		[IBS_ItemID.TreasureKey] = true, --宝库钥匙
		[IBS_ItemID.AKEY47] = true, --AKEY47
		[IBS_ItemID.SilverKey] = true, --银之钥
		[IBS_ItemID.Knock] = true, --洞开之启
		[IBS_ItemID.MomsOldKey] = true, --妈妈的旧钥匙
		[IBS_ItemID.BrokenRKey] = true, --损坏的R键
		[IBS_ItemID.ToyKeys] = true, --玩具钥匙
		[IBS_ItemID.KeyWalker] = true, --钥匙行者
		[IBS_ItemID.SpiderKeys] = true, --蜘蛛钥匙
		[IBS_ItemID.MrDynamax] = true, --极巨化钥匙
		[IBS_ItemID.BrimstoneKeys] = true, --硫磺火钥匙
		[IBS_ItemID.BobsBlessing] = true, --鲍勃的祝福
		[IBS_ItemID.MrKey] = true, --钥匙先生
		[IBS_ItemID.HeatKeys] = true, --炽热钥匙
		[IBS_ItemID.Kear] = true, --钥湿
		[IBS_ItemID.BulletJar] = true, --罐中枪子
		[IBS_ItemID.MontezumasHeritage] = true, --蒙特祖玛的遗产
		[IBS_ItemID.ScatterKeys] = true, --分裂钥匙
		[IBS_ItemID.BomberKey] = true, --炸钥人
		[IBS_ItemID.KKEKK] = true, --是匕是匕
		[IBS_ItemID.BloodKeys] = true, --鲜血钥匙
		[IBS_ItemID.SoulKeys] = true, --魂匙
		[IBS_ItemID.DiscountKey] = true, --折扣钥匙
	},
})

--生成红房间
function Doormaker:TryMakeDoor(seed)
	if game:GetLevel():GetCurrentRoomIndex() < 0 then return false end

	local room = game:GetRoom()
	local level = game:GetLevel()
	local idx = level:GetCurrentRoomIndex()
	
	--概率计算
	local chance = 15
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if self:IsOwned(player) and player:HasCollectible(IBS_ItemID.Hoarding) then
			chance = chance + 5 * self:GetCount(player)
		end
	end	
	
	if RNG(seed):RandomInt(100) > chance then
		return false
	end
	
	--贪婪模式
	if game:IsGreedMode() then
		if level:GetStartingRoomIndex() == level:GetCurrentRoomDesc().SafeGridIndex then
			for slot = 0,7 do
				if level:MakeRedRoomDoor(idx, slot) then
					local door = room:GetDoor(slot)
					if door then
						door:SetLocked(true)
						return true
					end
				end
			end
		end
	else	
		for _,slot in ipairs(self._Levels:GetCurrentRoomSpareDoorSlots()) do
			if level:MakeRedRoomDoor(idx, slot) then
				local door = room:GetDoor(slot)
				
				if door then
				
					--第三个必定为宝库
					local count = self:GetIBSData('level').DoormakerCount
					if count and count == 2 then					
						local desc = level:GetRoomByIdx(door.TargetRoomIndex)
						
						if desc ~= nil and desc.GridIndex > 0 and desc.Data then
							local roomData = desc.Data
							if roomData.Type ~= RoomType.ROOM_CHEST then
								local newData = self._Levels:CreateRoomData{
									Type = RoomType.ROOM_CHEST,
									Shape = roomData.Shape,
									Doors = roomData.Doors
								}				
								if newData then
									desc.Data = newData
									level:UpdateVisibility()
								end
							end
						end
					end

					self:DelayFunction2(function()
						door:SetLocked(true)
					end, 0)
					
					return true
				end
			end
		end	
	end
	

	return false
end

--清理房间
function Doormaker:OnRoomCleaned()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if self:IsOwned(player) then
			local limit = (game:IsGreedMode() and 1) or 3
			local data = self:GetIBSData('level')
			data.DoormakerCount = data.DoormakerCount or 0
			
			if data.DoormakerCount < limit then
				if self:TryMakeDoor(player:GetCardRNG(78):Next()) then
					data.DoormakerCount = data.DoormakerCount + 1				
				end
			end
			
			break
		end
	end
end
Doormaker:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, -1, 'OnRoomCleaned')

return Doormaker