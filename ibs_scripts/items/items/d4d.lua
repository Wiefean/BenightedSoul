--D4D

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local Pools = mod.IBS_Lib.Pools
local Finds = mod.IBS_Lib.Finds
local Maths = mod.IBS_Lib.Maths


--功能表
local D4D_Func = {
	[Direction.LEFT] = function(id) id = id + 1 return id end,
	[Direction.RIGHT] = function(id) id = id - 1 return id end,
	[Direction.UP] = function(id) id = id * 2 return id end,
	[Direction.DOWN] = function(id) id = id / 2 return id end
}


--效果
local function roll(_,col,rng,player,flags)
if (flags & UseFlag.USE_CARBATTERY <= 0) and (flags & UseFlag.USE_VOID <= 0) then--拒绝车载电池和虚空
	local itemPool = Game():GetItemPool()
	local MAX = Isaac.GetItemConfig():GetCollectibles().Size - 1
	local item = Finds:ClosestCollectible(player.Position)
	
	if item ~= nil then
		local seed = rng:GetSeed()
		local pool = Pools:GetRoomPool(seed)
		local id = item.SubType
		local dir = Maths:VectorToDirection((player.Position - item.Position):Normalized())
		local func = D4D_Func[dir]
		
		--根据离最近道具的方向改变id
		id = func(id)
		id = math.floor(id+0.5) --四舍五入
		
		--彼列书
		if player:HasCollectible(59) then
			if id <= 0 then id = 51 end
			if id >= MAX then id = 51 end
		else
			if id <= 0 then id = 0 end
			if id >= MAX then id = 0 end
		end

		if id > 0 then
			item:ToPickup():Morph(5,100,id,true,false,true)
			item:ToPickup().Touched = false
		else
			item:Remove()
		end
				
		Game():ShowHallucination(60, Game():GetRoom():GetBackdropType()) --特效
		
		return {ShowAnim = false, Discharge = true}
	end	

	return {ShowAnim = false, Discharge = false}
end	
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, roll, IBS_Item.d4d)

