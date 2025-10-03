--接触的G

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID
local AbandonedItem = mod.IBS_Effect.AbandonedItem

local game = Game()
local config = Isaac.GetItemConfig()

local ContactC = mod.IBS_Class.Item(mod.IBS_ItemID.ContactC)

--拾取道具时记录当前房间的道具池
function ContactC:OnPickItem(player, item, touched)
	if player:HasCollectible(self.ID) then
		local data = self:GetIBSData('temp')
		data.ContactCPool = self._Pools:GetRoomPool(player:GetCollectibleRNG(self.ID):Next())
	end
end
ContactC:AddPriorityCallback(IBS_CallbackID.PICK_COLLECTIBLE, CallbackPriority.LATE, 'OnPickItem')

--道具首次出现时触发
function ContactC:OnPickupFirstAppear(pickup)
	local data = self:GetIBSData('temp')
	
	if data.ContactCPool ~= nil and pickup.SubType > 0 then --非错误道具和空底座
		local itemConfig = config:GetCollectible(pickup.SubType)
		
		--非任务道具
		if itemConfig and itemConfig:HasTags(ItemConfig.TAG_QUEST) then
			return
		end

		--重置为记录道具池的道具
		local id = game:GetItemPool():GetCollectible(data.ContactCPool, true, pickup.InitSeed, 25)
		self:DelayFunction2(function()
			pickup:Morph(5, 100, id, true, true, true)
			Isaac.Spawn(1000, 15, 0, pickup.Position, Vector.Zero, nil)
		end, 3)
		
		--特效
		if itemConfig.GfxFileName then
			AbandonedItem:Spawn(pickup.Position, itemConfig.GfxFileName, RandomVector() * 0.1 * math.random(7, 12))
		end	

		data.ContactCPool = nil
	end
end
ContactC:AddCallback(IBS_CallbackID.PICKUP_FIRST_APPEAR, 'OnPickupFirstAppear', 100)


return ContactC