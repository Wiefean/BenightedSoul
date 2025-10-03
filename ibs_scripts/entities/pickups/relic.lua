--遗物泡影

local mod = Isaac_BenightedSoul
local IBS_PickupID = mod.IBS_PickupID
local IBS_ItemID = mod.IBS_ItemID
local Pickups = mod.IBS_Lib.Pickups

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local Relic = mod.IBS_Class.Pickup{
	Variant = IBS_PickupID.Relic.Variant,
	SubType = IBS_PickupID.Relic.SubType,
	Name = {zh = '遗物泡影', en = 'Phantom Relic'}
}

--获取数据
function Relic:GetData()
	local data = self:GetIBSData('temp')
	data.PhantomRelic = data.PhantomRelic or {}
	return data.PhantomRelic
end

--道具列表
Relic.ItemList = {
	58, --影之书
	78, --启示录
	83, --钉子
	97, --七原罪之书
	146, --祈祷卡
	158, --水晶球
	160, --撕裂苍穹
	292, --撒旦圣经
	293, --坎卜斯的头
	479, --熔炉
	516, --洒水器
	556, --炼金硫磺

	--愚昧
	IBS_ItemID.GlowingHeart, --发光的心
	IBS_ItemID.BonyKnife, --骨刀
	IBS_ItemID.RulesBook, --规则书
	IBS_ItemID.PortableFarm, --移动农场
	IBS_ItemID.Goatify, --变羊术
	IBS_ItemID.Diecry, --日寄
}

--获取池中道具
function Relic:GetItemFromPool(seed)
	local key = RNG(seed):RandomInt(1, #self.ItemList)
	return self.ItemList[key] or 58
end

--更新记录
function Relic:UpdateRecord(id)
	local data = self:GetData()
	if id and id > 0 then table.insert(data, 1, id) end
	if #data >= 5 then
		for i = 5,#data do
			data[i] = nil
		end
	end
end

--生成
function Relic:Spawn(itemID, pos, spawner)
	local room = game:GetRoom()
	pos = pos or room:FindFreePickupSpawnPosition((room:GetCenterPos() + Vector(200,200)), 0, true)
	itemID = itemID or self:GetItemFromPool(self._Levels:GetRoomUniqueSeed())
	local pickup = Isaac.Spawn(5, Relic.Variant, Relic.SubType, pos, Vector.Zero, spawner):ToPickup()
	local itemConfig = config:GetCollectible(itemID)
	
	if itemConfig and itemConfig.GfxFileName then		
		pickup:SetVarData(itemID)
		pickup:GetSprite():ReplaceSpritesheet(2, itemConfig.GfxFileName, true)
	end

	return pickup
end


--更新贴图 
function Relic:UpdateSprite()
	for _,ent in ipairs(Isaac.FindByType(5, self.Variant, self.SubType)) do
		local pickup = ent:ToPickup()
		local itemID = pickup:GetVarData()
		if itemID > 0 then
			local itemConfig = config:GetCollectible(itemID)
			if itemConfig and itemConfig.GfxFileName then
				pickup:GetSprite():ReplaceSpritesheet(2, itemConfig.GfxFileName, true)
			end
		end
	end
end
Relic:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'UpdateSprite')
Relic:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, 'UpdateSprite')

--初始化
function Relic:OnPickupInit(pickup) 
	self._Ents:ApplyLight(pickup, 0.7, Color(0.3,0.3,1,1.8))
end
Relic:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnPickupInit', Relic.Variant)


--更新
function Relic:OnPickupUpdate(pickup)
	local spr = pickup:GetSprite()
	if spr:IsFinished("Appear") then spr:Play("Idle") end
end
Relic:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'OnPickupUpdate', Relic.Variant)

--拾取
function Relic:OnCollision(pickup, collider)
	local player = collider:ToPlayer()
	if player and Pickups:CanCollect(pickup, player) then
		Pickups:PlayCollectAnim(pickup)

		--更新记录
		local itemID = pickup:GetVarData()
		if itemID > 0 then
			self:UpdateRecord(itemID)
		end

		pickup:Remove()
		sfx:Play(SoundEffect.SOUND_POWERUP2, 1, 2, false, 3)
	end	
end
Relic:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, 'OnCollision', Relic.Variant)


return Relic