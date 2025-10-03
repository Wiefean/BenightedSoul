--D4D

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local D4D = mod.IBS_Class.Item(mod.IBS_ItemID.D4D)

--功能表
D4D.DirectionFunc = {
	[Direction.LEFT] = function(id) id = id + 1 return id end,
	[Direction.RIGHT] = function(id) id = id - 1 return id end,
	[Direction.UP] = function(id) id = id * 2 return id end,
	[Direction.DOWN] = function(id) id = id / 2 return id end
}


--效果
function D4D:ChangeItemID(item, rng, player, flags)
	if (flags & UseFlag.USE_CARBATTERY <= 0) and (flags & UseFlag.USE_VOID <= 0) then--拒绝车载电池和虚空
		local itemPool = game:GetItemPool()
		local item = self._Finds:ClosestCollectible(player.Position)
		
		if item ~= nil then
			item = item:ToPickup()
			local pool = self._Pools:GetRoomPool(self._Levels:GetRoomUniqueSeed())
			local id = item.SubType
			local dir = self._Maths:VectorToDirection((player.Position - item.Position):Normalized())
			local func = self.DirectionFunc[dir]
			
			--正邪削弱(东方mod)
			--随机方位效果
			if mod.IBS_Compat.THI:SeijaNerf(player) then
				func = self.DirectionFunc[rng:RandomInt(0,3)] or func
			end
			
			--根据离最近道具的方向改变id
			id = func(id)
			id = math.floor(id+0.5) --四舍五入

			local itemConfig = config:GetCollectible(id)
			if itemConfig and itemConfig:IsAvailable() then
				item:Morph(5, 100, id, true, false, true)
				item.Touched = false
			else --彼列书将无效道具变为五芒星
				if self._Players:AnyHasCollectible(59) then
					item:Morph(5, 100, 51, true, false, true)
				else
					item:TryRemoveCollectible()
				end
			end

			game:ShowHallucination(60, game:GetRoom():GetBackdropType()) --特效
			
			return {ShowAnim = false, Discharge = true}
		end	

		return {ShowAnim = false, Discharge = false}
	end	
end
D4D:AddCallback(ModCallbacks.MC_USE_ITEM, 'ChangeItemID', D4D.ID)


return D4D