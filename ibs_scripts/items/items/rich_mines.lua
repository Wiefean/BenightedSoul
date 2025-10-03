--富饶矿脉

local mod = Isaac_BenightedSoul

local game = Game()

local RichMines = mod.IBS_Class.Item(mod.IBS_ItemID.RichMines)

--魂火列表
RichMines.WispList = {
	3+65536, --钻石
}
for i = 1,67 do --煤
	table.insert(RichMines.WispList, 65536)
end
for i = 1,25 do --铁
	table.insert(RichMines.WispList, 1+65536)
end
for i = 1,4 do --金
	table.insert(RichMines.WispList, 2+65536)
end
for i = 1,3 do --红石
	table.insert(RichMines.WispList, 4+65536)
end

--魂火对应道具
RichMines.WispToItem = {
	[0+65536] = 132, --煤块
	[1+65536] = 201, --铁块
	[2+65536] = 202, --金块
	[3+65536] = mod.IBS_ItemID.Diamoond, --钻石
	[4+65536] = 68, --科技
}

--查找魂火
function RichMines:FindWisps(player, id)
	local result = {}

	for _,ent in ipairs(Isaac.FindByType(3, 206, id)) do
		local familiar = ent:ToFamiliar()
		if familiar and self._Ents:IsTheSame(familiar.Player, player) then
			table.insert(result, familiar)
		end
	end
	
	return result
end


--生成魂火
function RichMines:AddWisp(player, id, pos)
	local rng = player:GetCollectibleRNG(self.ID)
	id = id or self.WispList[rng:RandomInt(1,#self.WispList)] or 65536
	
	local wisp = player:AddWisp(id, pos or player.Position, true)
	wisp.MaxHitPoints = wisp.MaxHitPoints * 2
	wisp.HitPoints = wisp.MaxHitPoints

	return wisp
end

--获得时生成魂火
function RichMines:OnGainItem(item, charge, first, slot, varData, player)
	if first then
		for i = 0,4 do
			local wisp = player:AddWisp(i+65536, player.Position, true)
			wisp.MaxHitPoints = wisp.MaxHitPoints * 4
			wisp.HitPoints = wisp.MaxHitPoints
		end
	end
end
RichMines:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', RichMines.ID)

--是否为岩石
local function IsRock(gridType)
	if gridType >= 2 and gridType <= 6 then
		return true
	end
	if gridType == 11 or gridType == 22 or gridType == 24 or gridType == 25 or gridType == 27 then
		return true
	end
	return false
end

--摧毁障碍物时触发
function RichMines:OnRockDestory(gridEnt, gridType)
	if not IsRock(gridType) then return end
	local pos = gridEnt.Position
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			local rng = player:GetCollectibleRNG(self.ID)

			--概率生成魂火
			if rng:RandomInt(100) < 25 then
				self:AddWisp(player, nil, pos)
			end

			--铁块/锁块/铁柱/刺石头出铁魂火
			--(不知为何只有刺石头生效,不过也没什么大影响)
			if gridType == 3 or gridType == 11 or gridType == 24 or gridType == 25 then
				self:AddWisp(player, 1+65536, pos)
			elseif gridType == 27 then --愚人金出金魂火
				self:AddWisp(player, 2+65536, pos)
			elseif gridType == 4 then --标记石头出钻石魂火
				self:AddWisp(player, 3+65536, pos)
			elseif gridType == 22 then --超级标记石头出3钻石魂火
				for i2 = 1,3 do
					self:AddWisp(player, 3+65536, pos)
				end
			elseif gridType == 6 and gridEnt:GetAltRockType(game:GetRoom():GetBackdropType()) == 4 then
				--血瘤出红石魂火
				self:AddWisp(player, 4+65536, pos)
			end
		end
	end
end
RichMines:AddCallback(ModCallbacks.MC_POST_GRID_ROCK_DESTROY, 'OnRockDestory')

--9矿石魂火变为道具魂火
function RichMines:OnPlayerUpdate(player)
	if not player:IsFrame(3,0) then return end --频率限制
	if not player:HasCollectible(self.ID) then return end
	for i = 0,4 do
		local wisps = self:FindWisps(player, i+65536)
		if #wisps >= 9 then
			local num = 0
			for _,wisp in ipairs(wisps) do
				wisp:Die()
				num = num + 1
				if num >= 9 then
					local itemWisp = player:AddItemWisp(self.WispToItem[i+65536] or 132, player.Position)
					itemWisp.MaxHitPoints = itemWisp.MaxHitPoints * ((i == 0 and 1) or (i == 3 and 5) or 3)
					itemWisp.HitPoints = itemWisp.MaxHitPoints
					break
				end
			end
		end
	end
end
RichMines:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate')

return RichMines