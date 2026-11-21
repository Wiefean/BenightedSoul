--多米诺选择

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local Dominoptions = mod.IBS_Class.Item(mod.IBS_ItemID.Dominoptions)

--找到符合要求的道具(品质最高,非任务道具)
function Dominoptions:FindItem()
	local pickup = nil
	local highestQ = 0

	for _,ent in ipairs(Isaac.FindByType(5, 100, -1, true)) do
		if (ent.SubType > 0) then
			local itemConfig = config:GetCollectible(ent.SubType)
			if itemConfig and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
				local quality = itemConfig.Quality
				if quality >= highestQ then
					pickup = ent:ToPickup()
					highestQ = quality
				end
			end
		end	
	end

	return pickup, highestQ
end

--新房间
function Dominoptions:OnNewRoom()
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local dimension = game:GetLevel():GetDimension()
	if dimension ~= 0 and dimension ~= 1 then return end

	local room = game:GetRoom()

	--新房间额外道具选择
	--(延迟触发,以实现视觉效果和模组兼容)
	if room:IsFirstVisit() then
		self:DelayFunction(function()
			local pickup, quality = self:FindItem()
			local itemPool = game:GetItemPool()
			
			if pickup and quality > 0 then
				local seed = self._Levels:GetRoomUniqueSeed()
				local pos = pickup.Position
				local scale = 0.8
				local index = pickup.OptionsPickupIndex

				if index == 0 then
					pickup.OptionsPickupIndex = self._Pickups:GetUniqueOptionsIndex()
					index = pickup.OptionsPickupIndex
				end				
				
				for Q = quality-1,0,-1 do				
					pos = pos + Vector(0,40)
					if room:IsPositionInRoom(pos, 10) then
						local pool = itemPool:GetRandomPool(RNG(seed))
						local id = self._Pools:GetCollectibleWithQuality(seed, Q, pool, true)
						if id > 0 and id ~= 25 then
							local item = Isaac.Spawn(5, 100, id, pos, Vector.Zero, nil):ToPickup()
							item.OptionsPickupIndex = index
							item.SpriteScale = Vector(scale,scale)
							item:SetSize(item.Size, Vector(scale,scale), 16)
							seed = math.max(1, seed - 1)
							scale = math.max(0.1, scale - 0.15)
						else
							return
						end
					else
						return
					end
				end
			end
		end, 3)
	end	
end
Dominoptions:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')


return Dominoptions