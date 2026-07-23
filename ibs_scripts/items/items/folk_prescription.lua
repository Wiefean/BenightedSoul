--偏方

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local FolkPrescription = mod.IBS_Class.Item(mod.IBS_ItemID.FolkPrescription)

--采集用时(实际用时多1.5秒)
FolkPrescription.MaxCharge = 30

--采集距离
FolkPrescription.MaxDistance = 50

--临时数据
function FolkPrescription:GetData(player)
	local data = self._Ents:GetTempData(player)
	if not data.FolkPrescription then
		--蓄力条动画
		local bar = Sprite('gfx/ibs/ui/chargebar.anm2')
		bar:SetFrame("Disappear", 99)		
		data.FolkPrescription = {
			GridIdx = 0,
			LastGridIdx = 0,
			Charge = 0,
			ChargeBar = bar,
		}
	end
	return data.FolkPrescription
end

--使用药丸
function FolkPrescription:OnUsePill(pill, player, flags)
	if not player:HasCollectible(self.ID) then return end
	local pillConfig = config:GetPillEffect(pill)
	if pillConfig and pillConfig.EffectSubClass ~= 2 then
		player:AddHearts(2)
	end
end
FolkPrescription:AddCallback(ModCallbacks.MC_USE_PILL, 'OnUsePill')


--是否可采集
function FolkPrescription:CanHarvest(gridEnt)
	local desc = gridEnt.Desc
	if desc and desc.SpawnSeed then
		return RNG(desc.SpawnSeed):RandomInt(100) < 13
	end
	return false
end

--用于缓存地面装饰物位置
local CachedGrid = {}
local CachedGrid2 = {}
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	for k,_ in pairs(CachedGrid) do
		CachedGrid[k] = nil
		CachedGrid2[k] = nil
	end
end)

--地面装饰物更新
function FolkPrescription:OnDecoUpdate(gridEnt)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local desc = gridEnt.Desc
	local seed = (desc and desc.SpawnSeed) or nil; if not seed then return end
	if CachedGrid[seed] or CachedGrid2[seed] then return end
	
	--缓存
	if self:CanHarvest(gridEnt) then
		CachedGrid[seed] = gridEnt
	else
		CachedGrid2[seed] = gridEnt
	end
end
FolkPrescription:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_DECORATION_UPDATE, 'OnDecoUpdate')


--获取可采集装饰物
function FolkPrescription:GetDeco()
	local result = {}

	for seed,gridEnt in pairs(CachedGrid) do
		if gridEnt:GetType() == GridEntityType.GRID_DECORATION then
			result[gridEnt:GetGridIndex()] = gridEnt
		else
			CachedGrid[seed] = nil
		end
	end	
	
	return result
end

--获取距离最近的可采集装饰物
function FolkPrescription:GetClosestDeco(pos)
	local closest = nil
	local closestDist = 114514

	for _,gridEnt in pairs(self:GetDeco()) do
		local dist = pos:Distance(gridEnt.Position)
		if dist < closestDist then
			closestDist = dist
			closest = gridEnt
		end
	end
	
	return closest
end


--角色更新
function FolkPrescription:OnPlayerUpdate(player)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local gridEnt = self:GetClosestDeco(player.Position); if not gridEnt then return end
	local data = self:GetData(player)
	
	--检测距离
	if player.Position:Distance(gridEnt.Position) > self.MaxDistance then
		data.Charge = 0
		return
	end	
	
	local gridIdx = gridEnt:GetGridIndex()

	data.GridIdx = gridIdx
			
	if data.LastGridIdx ~= data.GridIdx then
		data.Charge = 0
		data.LastGridIdx = data.GridIdx
	end

	if player:IsFrame(1,0) then
		data.Charge = data.Charge + 1
	end

	--采集
	local room = game:GetRoom()
	if data.Charge > self.MaxCharge + 45 and room:GetGridEntity(gridIdx) then
		data.Charge = 0
		
		local itemPool = game:GetItemPool()
		local pillColor = itemPool:GetPill(player:GetCollectibleRNG(self.ID):Next())
		Isaac.Spawn(5, 70, pillColor, gridEnt.Position, Vector.Zero, player)
		sfx:Play(268)
		
		--无PHD或DHP,变为未识别状态
		if not (PlayerManager.AnyoneHasCollectible(75) or PlayerManager.AnyoneHasCollectible(654)) then				
			itemPool:UnidentifyPill(pillColor)
			--EID兼容,也清除EID的药丸记录
			if EID then
				EID.UsedPillColors[tostring(pillColor)] = nil				
			end
		end
		
		room:RemoveGridEntity(gridIdx, 0, false)
		
		--清除缓存
		local desc = gridEnt.Desc
		local seed = (desc and desc.SpawnSeed) or nil; if not seed then return end
		CachedGrid[seed] = nil
	end
end
FolkPrescription:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate')

--标记动画
local MarkSpr = Sprite('gfx/005.100_collectible.anm2')
MarkSpr:ReplaceSpritesheet(1, 'gfx/ibs/items/collectibles/folk_prescription.png', true)
MarkSpr.Scale = Vector(0.5, 0.5)
MarkSpr.Color = Color(1,1,1,0.1)
MarkSpr:Play('Idle')
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	MarkSpr:Update()
end)

--渲染
function FolkPrescription:OnRender()
	local room = game:GetRoom()
	if game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then return end
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	
	--标记提示
	for _,gridEnt in pairs(self:GetDeco()) do
		MarkSpr:Render(self._Screens:WorldToScreen(gridEnt.Position, nil, true))
	end
	
	--蓄力条
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = self:GetData(player)
		if data.GridIdx >= 0 and data.Charge > 45 then
			local pos = room:GetGridPosition(data.GridIdx)
			data.ChargeBar:SetFrame("Charging", math.floor(100*(data.Charge-45)/self.MaxCharge))
			data.ChargeBar:Render(self._Screens:WorldToScreen(pos, nil, true))
		end
	end
end
FolkPrescription:AddCallback(ModCallbacks.MC_POST_RENDER, 'OnRender')


return FolkPrescription