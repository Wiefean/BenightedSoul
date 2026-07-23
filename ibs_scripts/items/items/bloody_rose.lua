--血染玫瑰

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local BloodyRose = mod.IBS_Class.Item(mod.IBS_ItemID.BloodyRose)

--商店额外道具
function BloodyRose:OnNewRoom()
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	
	--只能在主世界或镜世界触发
	local dimension = game:GetLevel():GetDimension()
	if dimension ~= 0 and dimension ~= 1 then return end
	
	local room = game:GetRoom()

	--新房间额外道具选择
	--(延迟触发,以实现视觉效果和模组兼容)
	if room:IsFirstVisit() then
		self:DelayFunction(function()
			local itemPool = game:GetItemPool()
			local pool = self._Pools:GetRoomPool(self._Levels:GetRoomUniqueSeed())
			
			for _,ent in ipairs(Isaac.FindByType(5,100)) do
				local id = ent.SubType
				local itemConfig = config:GetCollectible(id)
				local pickup = ent:ToPickup()
				
				if id > 0 and pickup and itemConfig and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
					local seed = pickup.InitSeed
					local id = itemPool:GetCollectible(pool, true, seed)
					local pos = room:FindFreePickupSpawnPosition(pickup.Position + Vector(40,0), 0, true)
					local item = Isaac.Spawn(5, 100, id, pos, Vector.Zero, nil):ToPickup()
					
					self._Pickups:SetSpikePrice(item)

					--设置单选
					local index = pickup.OptionsPickupIndex
					if index == 0 then
						local newIndex = self._Pickups:GetUniqueOptionsIndex()
						item.OptionsPickupIndex = newIndex
						pickup.OptionsPickupIndex = newIndex					
					else
						item.OptionsPickupIndex = index	
					end					
				end
			end

		end, 3)
	end	
end
BloodyRose:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--获取品质2的道具
function BloodyRose:FindQ2Items()
	local result = {}

	for _,ent in ipairs(Isaac.FindByType(5,100)) do
		if ent.SubType > 0 then
			local itemConfig = config:GetCollectible(ent.SubType)
			if itemConfig and itemConfig.Quality == 2 then
				table.insert(result, ent)
			end
		end
	end
	
	return result
end

--必须先拾取品质2的道具
function BloodyRose:PrePickupCollision(pickup, other)
	if pickup.SubType <= 0 then return end
	local player = other:ToPlayer()
	
	if player and player:HasCollectible(self.ID) then
		local itemConfig = config:GetCollectible(pickup.SubType)
		
		if itemConfig and itemConfig.Quality ~= 2 and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
			local items = self:FindQ2Items()
			if #items > 0 then
			
				--提示
				if pickup:IsFrame(10,0) then
					sfx:Play(316, 2, 30, false, 0.01*math.random(120,150))		
					for _,ent in ipairs(items) do
						ent:SetColor(Color(1,1,1,1,1,0,0),30,6,true)
					end
				end
				
				return false
			end
		end
	end	
end
BloodyRose:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, 'PrePickupCollision', PickupVariant.PICKUP_COLLECTIBLE)


return BloodyRose