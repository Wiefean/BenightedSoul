--劳动明灯

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local game = Game()

local DiligenceLamp = mod.IBS_Effect.DiligenceLamp
local LODI = mod.IBS_Class.Item(mod.IBS_ItemID.LODI)

--新房间触发
function LODI:OnNewRoom()
	--填坑
	if PlayerManager.AnyoneHasCollectible(self.ID) then
		local room = game:GetRoom()
		
		--排除大撒旦房间
		if room:GetBossID() ~= 55 then			
			local size = room:GetGridSize()
			for i = 0,size-1 do
				local grid = room:GetGridEntity(i)
				if grid and (grid.State == 0) and (grid:GetType() == GridEntityType.GRID_PIT) then
					grid:ToPit():MakeBridge(nil)
				end
			end
		end
	end
	
	--移除魂火
	for _,ent in pairs (Isaac.FindByType(3, FamiliarVariant.WISP, self.ID)) do
		ent:Remove()
	end
end
LODI:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--尝试生成灯
function LODI:TrySpawnLamp()
	if game:GetRoom():IsClear() then return end
	local room = game:GetRoom()
	local num = PlayerManager.GetNumCollectibles(self.ID)

	if num <= 0 then return end
	if num > 7 then num = 7 end
	
	--中间生成一个
	if num > 0 and #Isaac.FindByType(1000, DiligenceLamp.Variant) < 1 then
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
		Isaac.Spawn(1000, DiligenceLamp.Variant, DiligenceLamp.SubType, pos, Vector.Zero, nil)	
		Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil)
	end

	--其余随机位置
	if #Isaac.FindByType(1000, DiligenceLamp.Variant) < num then
		local width = room:GetGridWidth()
		local height = room:GetGridHeight()
		local x = math.random(1, width-1)
		local y = math.random(1, height-1)
		local gridIndex = x + y * width
		local pos = room:FindFreePickupSpawnPosition(room:GetGridPosition(gridIndex), 0, true)
		Isaac.Spawn(1000, DiligenceLamp.Variant, DiligenceLamp.SubType, pos, Vector.Zero, nil)
		Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil)
	end
end
LODI:AddCallback(ModCallbacks.MC_POST_UPDATE, 'TrySpawnLamp')

--魂火更新
function LODI:OnWispUpdate(familiar)
    if familiar.SubType ~= self.ID then return end
	
	--追踪
	local target = self._Finds:ClosestEnemy(familiar.Position)
	if target ~= nil then 
		familiar.Position = familiar.Position + (target.Position - familiar.Position):Resized(3)
	end	
end
LODI:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, 'OnWispUpdate', FamiliarVariant.WISP)


return LODI