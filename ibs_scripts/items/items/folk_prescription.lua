--偏方

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local FolkPrescription = mod.IBS_Class.Item(mod.IBS_ItemID.FolkPrescription)

--采集用时(实际用时多2秒)
FolkPrescription.MaxCharge = 60

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

--标记动画
local MarkSpr = Sprite('gfx/005.100_collectible.anm2')
MarkSpr:ReplaceSpritesheet(1, 'gfx/ibs/items/collectibles/folk_prescription.png', true)
MarkSpr.Scale = Vector(0.5, 0.5)
MarkSpr.Color = Color(1,1,1,0.1)
MarkSpr:Play('Idle')
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	MarkSpr:Update()
end)


--是否可采集
function FolkPrescription:CanHarvest(gridEnt)
	local desc = gridEnt.Desc
	if desc and desc.SpawnSeed then
		return RNG(desc.SpawnSeed):RandomInt(100) < 13
	end
	return false
end

--地面装饰物渲染
function FolkPrescription:OnDecoRender(gridEnt, offset)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	if not self:CanHarvest(gridEnt) then return end
	local room = game:GetRoom()
	local gridIdx = gridEnt:GetGridIndex()
	local pos = room:GetGridPosition(gridIdx)
	local player = self._Finds:ClosestPlayer(pos)
	
	--标记提示
	MarkSpr:Render(self._Screens:WorldToScreen(pos, offset, true))
	
	if player then
		local data = self:GetData(player)
		
		--检测距离
		if player.Position:Distance(pos)^2 <= 70^2 then
			data.GridIdx = gridIdx
			
			if data.LastGridIdx ~= data.GridIdx then
				data.Charge = 0
				data.LastGridIdx = data.GridIdx
			end

			if game:GetFrameCount() % 2 == 0 and not game:IsPaused() then			
				data.Charge = data.Charge + 1
			end

			--采集
			if data.Charge > self.MaxCharge + 60 then
				data.Charge = 0
				room:RemoveGridEntity(gridIdx, 0, false)
				
				local itemPool = game:GetItemPool()
				local pillColor = itemPool:GetPill(player:GetCollectibleRNG(self.ID):Next())
				Isaac.Spawn(5, 70, pillColor, pos, Vector.Zero, player)
				sfx:Play(268)
				
				--无PHD或DHP,变为未识别状态
				if not (PlayerManager.AnyoneHasCollectible(75) or PlayerManager.AnyoneHasCollectible(654)) then				
					itemPool:UnidentifyPill(pillColor)
					--EID兼容,也清除EID的药丸记录
					if EID then
						EID.UsedPillColors[tostring(pillColor)] = nil				
					end
				end
			end
			
			if data.Charge > 60 then
				data.ChargeBar:SetFrame("Charging", math.floor(100*(data.Charge-60)/self.MaxCharge))
				data.ChargeBar:Render(self._Screens:WorldToScreen(pos, offset, true))
			end
		end
	end
end
FolkPrescription:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_DECORATION_RENDER, 'OnDecoRender')

--使用药丸
function FolkPrescription:OnUsePill(pill, player, flags)
	if not player:HasCollectible(self.ID) then return end
	local pillConfig = config:GetPillEffect(pill)
	if pillConfig and pillConfig.EffectSubClass ~= 2 then
		player:AddHearts(2)
	end
end
FolkPrescription:AddCallback(ModCallbacks.MC_USE_PILL, 'OnUsePill')

return FolkPrescription