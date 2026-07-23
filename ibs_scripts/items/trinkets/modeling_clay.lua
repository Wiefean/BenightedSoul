--塑型黏土II

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local ModelingClay = mod.IBS_Class.Trinket(mod.IBS_TrinketID.ModelingClay)

local IconID = 0
local Icon = Sprite('gfx/ibs/ui/items/any.anm2')
Icon:Play('Idle')
Icon.Color = Color(0.5, 0.25, 0.25, 1)

--获取可复制的道具
function ModelingClay:GetItemToCopy(pos, quality)
	local pickup = self._Finds:ClosestCollectible(pos)
	if pickup and pickup.SubType > 0 and pickup.Position:Distance(pos) <= 60 then
		local itemConfig = config:GetCollectible(pickup.SubType)
		if itemConfig and itemConfig.Type ~= 3 and itemConfig.Quality <= quality and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
			return pickup.SubType
		end	
	end
end

--更新掉落物贴图
function ModelingClay:UpdatePickupSprite(pickup, id)
	local spr = pickup:GetSprite()
	local itemConfig = config:GetCollectible(id)
	if itemConfig and itemConfig.GfxFileName then
		spr.Color = Color(0.5, 0.25, 0.25, 1)
		spr:ReplaceSpritesheet(0, itemConfig.GfxFileName, true)
	end
end

--更新效果
function ModelingClay:UpdateEffect(id)
	local data = self:GetIBSData('temp')
	local last = nil
	
	if id ~= nil then
		last = data.ModelingClayCopy
	else
		id = data.ModelingClayCopy
	end
	
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasTrinket(self.ID) then
			local num = self._Players:GetTrinketNum(player, self.ID)
			
			--移除之前给予的效果
			if last then
				player:AddInnateCollectible(last, -num)
			end
			
			if id then			
				player:AddInnateCollectible(id, num)
			end
		end
	end
	
	if id then	
		data.ModelingClayCopy = id
	end
end

--更新饰品栏贴图
function ModelingClay:UpdateIconSprite(id)
	id = id or self:GetIBSData('temp').ModelingClayCopy; if not id then return end
	local gfx = ''
	local itemConfig = config:GetCollectible(id)

	if itemConfig then   
		gfx = itemConfig.GfxFileName
	end

	if gfx == '' or not gfx then
		gfx = 'gfx/items/collectibles/placeholder.png'
	end

	IconID = id
	Icon:ReplaceSpritesheet(0, gfx, true)
end

--更新
function ModelingClay:OnTrinketUpdate(pickup)
	local golden = (pickup.SubType == self.ID + 32768)
	if not (pickup.SubType == self.ID or golden) then return end
	
	--用于丢下时立刻更新贴图
	if IconID > 0 and pickup.FrameCount <= 1 then
		self:UpdatePickupSprite(pickup, IconID)
	end
	
	if not pickup:IsFrame(90,0) then return end
	
	local box = PlayerManager.AnyoneHasCollectible(439)
	local quality = 2
	
	--提升品质限制
	if golden then
		quality = quality + 1
	end
	if box then
		quality = quality + 1
	end
	
	local id = self:GetItemToCopy(pickup.Position, quality)
	if not id then
		id = self:GetIBSData('temp').ModelingClayCopy
	end
	
	if id and IconID ~= id then
		self:UpdateEffect(id)
		self:UpdateIconSprite(id)
		
		--替换所有地上的饰品贴图
		for _,ent in ipairs(Isaac.FindByType(5,350)) do
			if ent.SubType == self.ID or ent.SubType == self.ID + 32768 then			
				self:UpdatePickupSprite(ent, IconID)
				Isaac.Spawn(1000,15,0, ent.Position, Vector.Zero, nil)
			end
		end
	end
end
ModelingClay:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'OnTrinketUpdate', PickupVariant.PICKUP_TRINKET)

--获得饰品
function ModelingClay:OnGainTrinket(player)
	local id = self:GetIBSData('temp').ModelingClayCopy
	if id then
		player:AddInnateCollectible(id, 1)
	end	
end
ModelingClay:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, 'OnGainTrinket', ModelingClay.ID)
ModelingClay:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, 'OnGainTrinket', ModelingClay.ID + 32768)

--失去饰品
function ModelingClay:OnLoseTrinket(player)
	local id = self:GetIBSData('temp').ModelingClayCopy
	if id then
		player:AddInnateCollectible(id, -1)
		
		--失去装扮
		if player:GetCollectibleNum(id) <= 0 then
			player:RemoveCostume(config:GetCollectible(id))
		end
	end
end
ModelingClay:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, 'OnLoseTrinket', ModelingClay.ID)
ModelingClay:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, 'OnLoseTrinket', ModelingClay.ID + 32768)

--载入游戏
function ModelingClay:OnGameStarted(isContinued)
	if isContinued then
		self:UpdateEffect()
		self:UpdateIconSprite()
	end
end
ModelingClay:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, "OnGameStarted")

--饰品栏渲染
function ModelingClay:OnTrinketRender(slot, pos, scale, player)
	local trinket = player:GetTrinket(slot)
	if trinket ~= self.ID and trinket ~= self.ID + 32768 then return end
	
	if IconID > 0 then
		Icon.Scale = Vector(scale, scale)
		Icon:Render(pos + Vector(16*scale, 16*scale))
		return true
	end
end
ModelingClay:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_TRINKET_RENDER, 'OnTrinketRender')


return ModelingClay