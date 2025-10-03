--连锁挖掘

local mod = Isaac_BenightedSoul

local game = Game()

local VeinMiner = mod.IBS_Class.Item(mod.IBS_ItemID.VeinMiner)

--摧毁名单
VeinMiner.VeinList = {
	[GridEntityType.GRID_ROCK] = true,
	[GridEntityType.GRID_ROCKT] = true,
	[GridEntityType.GRID_ROCK_ALT] = true,
	[GridEntityType.GRID_ROCK_ALT2] = true,
	[GridEntityType.GRID_ROCK_GOLD] = true,
	[GridEntityType.GRID_ROCK_SPIKED] = true,
	[GridEntityType.GRID_ROCK_SS] = true,
}

--连锁摧毁大便
function VeinMiner:OnPoopBreak(gridEnt, ent, variant)	
	--按顺序取玩家
	local player = nil
	for i = 0, game:GetNumPlayers() - 1 do
		local p = Isaac.GetPlayer(i)
		if p:HasCollectible(self.ID) then
			player = p
			break
		end
	end
	if not player then return end
	
	local room = game:GetRoom()
	local pos = (gridEnt and gridEnt.Position) or ent.Position

	--摧毁网格大便
	local width = room:GetGridWidth()
	local height = room:GetGridHeight()
	for x = 1, width - 1 do
		for y = 1, height - 1 do
			local gridIndex = x + y * width
			local gEnt = room:GetGridEntity(gridIndex)
			if gEnt and gEnt.State ~= 1000 and gEnt:GetVariant() == variant then
				gEnt:Hurt(114514, EntityRef(player))
			end
		end
	end	
	
	--摧毁非网格大便(来自大肠杆菌等)
	if variant == 0 or variant == 3 then
		for _,ent in ipairs(Isaac.FindByType(245)) do
			if ent and ent.HitPoints ~= 1 then
				ent:Die()
				
				--对于金大便还得再打几次
				if variant == 3 then				
					for i = 1,7 do
						self:DelayFunction2(function()			
							ent:Die()
						end, i)
					end
				end
			end	
		end
	end
end
VeinMiner:AddCallback(mod.IBS_CallbackID.POOP_BREAK, 'OnPoopBreak')


--连锁摧毁火堆
function VeinMiner:OnFireplaceBreak(fire, variant)
	--按顺序取玩家
	local player = nil
	for i = 0, game:GetNumPlayers() - 1 do
		local p = Isaac.GetPlayer(i)
		if p:HasCollectible(self.ID) then
			player = p
			break
		end
	end
	if not player then return end
	
	for _,ent in ipairs(Isaac.FindByType(fire.Type, variant)) do
		ent:Die()
	end
end
VeinMiner:AddCallback(mod.IBS_CallbackID.FIREPLACE_BREAK, 'OnFireplaceBreak')


--连锁摧毁岩石
function VeinMiner:OnRockDestory(gridEnt, gridType)
	if not self.VeinList[gridType] then return end

	--按顺序取玩家
	local player = nil
	for i = 0, game:GetNumPlayers() - 1 do
		local p = Isaac.GetPlayer(i)
		if p:HasCollectible(self.ID) then
			player = p
			break
		end
	end
	if not player then return end

	local room = game:GetRoom()
	local pos = gridEnt.Position
	local width = room:GetGridWidth()
	local height = room:GetGridHeight()
	for x = 1, width - 1 do
		for y = 1, height - 1 do
			local gridIndex = x + y * width
			local gEnt = room:GetGridEntity(gridIndex)
			if gEnt and gEnt.State ~= 1000 and gEnt:GetType() == gridType then
				gEnt:Destroy(false)
			end
		end
	end	

end
VeinMiner:AddCallback(ModCallbacks.MC_POST_GRID_ROCK_DESTROY, 'OnRockDestory')


return VeinMiner