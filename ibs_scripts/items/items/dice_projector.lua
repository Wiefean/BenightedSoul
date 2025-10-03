--骰影仪

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local DiceProjector = mod.IBS_Class.Item(mod.IBS_ItemID.DiceProjector)

--找到符合要求的道具(非任务道具)
function DiceProjector:FindItems()
	local result = {}

	for _,ent in ipairs(Isaac.FindByType(5, 100, -1, true)) do
		local pickup = ent:ToPickup()
		if pickup and (pickup.SubType > 0) then
			local itemConfig = config:GetCollectible(pickup.SubType)
			if itemConfig and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
				table.insert(result, pickup)
			end
		end	
	end

	return result
end

--新房间
function DiceProjector:OnNewRoom()
	local dimension = game:GetLevel():GetDimension()
	if dimension ~= 0 and dimension ~= 1 then return end
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local room = game:GetRoom()
	if not room:IsFirstVisit() then return end

	--额外道具选择
	for _,pickup in ipairs(self:FindItems()) do
		local seed = self._Levels:GetRoomUniqueSeed()
		local pool = self._Pools:GetRoomPool(seed)
		local id = game:GetItemPool():GetCollectible(pool, true, seed)
		local pos = room:FindFreePickupSpawnPosition(pickup.Position + Vector(40,40), 0, true)
		local new = Isaac.Spawn(5, 100, id, pos, Vector.Zero, nil):ToPickup()

		new.Timeout = 100 --存在约3秒
		new.AutoUpdatePrice = false
		new.Price = pickup.Price
		
		--瞎眼特效
		local color = Color(1,1,1,1,0,0,0, 1)
		local spr = new:GetSprite()
		spr:SetRenderFlags(AnimRenderFlags.STATIC)
		spr.Color = color

		--设置单选
		local index = pickup.OptionsPickupIndex
		if index == 0 then
			local newIndex = self._Pickups:GetUniqueOptionsIndex()
			new.OptionsPickupIndex = newIndex
			pickup.OptionsPickupIndex = newIndex					
		else
			new.OptionsPickupIndex = index
		end
	end	
end
DiceProjector:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, 200, 'OnNewRoom')


return DiceProjector