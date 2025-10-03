--写生

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local Sketch = mod.IBS_Class.Item(mod.IBS_ItemID.Sketch)

--获取数据
function Sketch:GetData(player)
	local data = self._Players:GetData(player)
	if not data.Sketch then
		data.Sketch = {Tag1 = nil, Tag2 = nil, ItemID = 0}
	end
	return data.Sketch
end

--可用标签
Sketch.AvailableTags = {
	[0] = {zh = '(空)', en = '(None)'},
	[1<<0] = {zh = '死亡', en = 'Dead'},
	[1<<1] = {zh = '注射器', en = 'Syringe'},
	[1<<2] = {zh = '妈妈', en = 'Mom'},
	[1<<3] = {zh = '科技', en = 'Tech'},
	[1<<4] = {zh = '电池', en = 'Battery'},
	[1<<5] = {zh = '嗝屁猫', en = 'Guppy'},
	[1<<6] = {zh = '苍蝇', en = 'Fly'},
	[1<<7] = {zh = '鲍勃', en = 'Bob'},
	[1<<8] = {zh = '蘑菇', en = 'Mushroom'},
	[1<<9] = {zh = '宝宝', en = 'Baby'},
	[1<<10] = {zh = '天使', en = 'Angel'},
	[1<<11] = {zh = '恶魔', en = 'Devil'},
	[1<<12] = {zh = '便便', en = 'Poop'},
	[1<<13] = {zh = '书', en = 'Book'},
	[1<<14] = {zh = '蜘蛛', en = 'Spider'},
	[1<<18] = {zh = '食物', en = 'Food'},
	[1<<20] = {zh = '攻击性', en = 'Offensive'},
	[1<<23] = {zh = '星星', en = 'Stars'},
}

--根据条件获取道具,没有获取到时用早餐代替
function Sketch:GetItem(player, tag1, tag2, seed)
	seed = seed or 1
	local itemPool = game:GetItemPool()
	local result = 25
	local cache = {}

	for id = 1, config:GetCollectibles().Size do
		if itemPool:HasCollectible(id) then
			local itemConfig = config:GetCollectible(id)
			if itemConfig and (itemConfig.CraftingQuality ~= -1) and itemConfig:IsAvailable() and (itemConfig.Type ~= ItemType.ITEM_ACTIVE) and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
				if (tag1 == 0 or itemConfig:HasTags(tag1)) and (tag2 == 0 or itemConfig:HasTags(tag2)) then
					--美德书兼容
					if (not player:HasCollectible(584)) or itemConfig.Quality >= 2 then
						table.insert(cache, id)
					end	
				end
			end
		end
	end	

	if #cache > 0 then
		result = cache[RNG(seed):RandomInt(1, #cache)]
		if not result then
			--彼列书兼容
			if player:HasCollectible(59) then
				result = 51
			else
				result = 25
			end			
		end
	else
		--彼列书兼容
		if player:HasCollectible(59) then
			result = 51
		end
	end

	return result
end

--计算充能消耗和品质
function Sketch:GetDischarge(player)
	local discharge = 4
	if player:HasCollectible(116) then discharge = discharge - 1 end --9伏特
	return discharge
end

--尝试使用
function Sketch:OnTryUse(slot, player)
	return self:GetDischarge(player)
end
Sketch:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MIN_USABLE_CHARGE, 'OnTryUse', Sketch.ID)

--获取准备记录的标签
function Sketch:GetTagToRecord(player, item)
	local itemConfig = config:GetCollectible(item)
	if itemConfig then
		local data = self:GetData(player)
		for i = 1,32 do
			local tag = (1<<i)
			if (data.Tag1 == nil or tag ~= data.Tag1) and self.AvailableTags[tag] and itemConfig:HasTags(tag) then
				return tag
			end
		end
	end
	return 0
end

--使用效果
function Sketch:OnUse(item, rng, player, flags, slot)
	if slot < 0 or slot > 2 then return end
	if (flags & UseFlag.USE_OWNED > 0) and (flags & UseFlag.USE_CARBATTERY <= 0) and (flags & UseFlag.USE_VOID <= 0) then --拒绝车载电池和虚空
		if not self._Players:DischargeSlot(player, slot, self:GetDischarge(player)) then return {Discharge = false, ShowAnim = false} end
		local data = self:GetData(player)

		if data.ItemID > 0 then
			--里该隐直接获得道具
			if player:GetPlayerType() == PlayerType.PLAYER_CAIN_B then
				player:AddCollectible(data.ItemID)
			else
				local room = game:GetRoom()
				local pos = room:FindFreePickupSpawnPosition((room:GetCenterPos()), 0, true)
				local item = Isaac.Spawn(5, 100, data.ItemID, pos, Vector.Zero, nil):ToPickup()
				item:Morph(5,100, data.ItemID, false, true, true)			
			end
			data.Tag1 = nil
			data.Tag2 = nil
			data.ItemID = 0
			sfx:Play(8)
			
			return {Discharge = false, ShowAnim = true}
		else
			if data.Tag1 == nil or data.Tag2 == nil then
				local item = self._Finds:ClosestCollectible(player.Position)
				if item ~= nil and item.SubType ~- 0 then
					local itemConfig = config:GetCollectible(item.SubType)

					--记录两个标签后再记录品质
					if itemConfig then
						if data.Tag1 == nil then
							for i = 1,32 do
								local tag = (1<<i)
								if self.AvailableTags[tag] and itemConfig:HasTags(tag) then
									data.Tag1 = tag
									break
								end
							end
							if data.Tag1 == nil then
								data.Tag1 = 0
							end
						elseif data.Tag2 == nil then
							for i = 1,32 do
								local tag = (1<<i)
								if tag ~= data.Tag1 and self.AvailableTags[tag] and itemConfig:HasTags(tag) then
									data.Tag2 = tag
									break
								end
							end
							if data.Tag2 == nil then
								data.Tag2 = 0
							end
						end
					end
				end
				sfx:Play(8, 1, 2, false, 2)
			else
				if mod.IBS_Compat.THI:SeijaNerf(player) and rng:RandomInt(100) < 75 then
					--正邪削弱(东方mod)
					player:AnimateSad()
				else
					data.ItemID = self:GetItem(player, data.Tag1, data.Tag2, rng:Next())
					game:GetItemPool():RemoveCollectible(data.ItemID)
					sfx:Play(8, 1, 2, false, 2)				
				end
			end
		end
	end
	
	return {Discharge = false, ShowAnim = false}
end
Sketch:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', Sketch.ID)


--道具图标
local Icon = Sprite('gfx/ibs/ui/items/sketch.anm2')
local IconID = 0
Icon:Play('Icon')

--画笔遮挡
local Tail = Sprite('gfx/ibs/ui/items/sketch.anm2')
Tail:Play('Tail')

local fnt = Font('font/teammeatfontextended10.fnt')
local fnt2 = Font('font/teammeatfont10.fnt')

--提示记录
function Sketch:OnActiveRender(player, slot, offset, alpha, scale)
	if player:GetActiveItem(slot) ~= self.ID then return end
	local data = self:GetData(player)
	local pos = offset + Vector(16*scale,16*scale)
	
	local itemConfig = config:GetCollectible(data.ItemID)
	if itemConfig and IconID ~= data.ItemID then
		IconID = data.ItemID
		Icon:ReplaceSpritesheet(0, itemConfig.GfxFileName)
		Icon:LoadGraphics()
	end

	if data.ItemID > 0 then
		local color = Color(1,1,1,alpha - 0.5)
		color:SetColorize(1,1,1,1)
		Icon.Color = color
		Icon.Scale = Vector(scale, scale)
		Icon:Render(pos)
	else
		local zh = (mod.Language == 'zh')
		local tag1 = self:ChooseLanguageInTable(self.AvailableTags[data.Tag1])
		local tag2 = self:ChooseLanguageInTable(self.AvailableTags[data.Tag2])

		if tag1 == nil or tag2 == nil then
			local item = self._Finds:ClosestCollectible(player.Position)
			if item ~= nil and item.SubType ~ 0 then		
				local tag_ready = self:ChooseLanguageInTable(self.AvailableTags[self:GetTagToRecord(player, item.SubType)])
				if tag_ready then
					local offsetX = (tag1 == nil and -10) or -13
					local offsetY = (tag1 == nil and -10) or -3
				
					if zh then
						fnt:DrawStringScaledUTF8(tag_ready, pos.X + offsetX*scale, pos.Y + offsetY*scale, 0.5*scale, 0.5*scale, KColor(0,0,0,alpha-0.5), 24, true)
					else		
						fnt2:DrawStringScaledUTF8(tag_ready, pos.X + offsetX*scale, pos.Y + offsetY*scale, 0.5*scale, 0.5*scale, KColor(0,0,0,alpha-0.5), 24, true)
					end
				end
			end
		end
		
		if tag1 then
			if zh then
				fnt:DrawStringScaledUTF8(tag1, pos.X - 10*scale, pos.Y - 10*scale, 0.5*scale, 0.5*scale, KColor(0,0,0,alpha), 24, true)
			else		
				fnt2:DrawStringScaledUTF8(tag1, pos.X - 10*scale, pos.Y - 10*scale, 0.5*scale, 0.5*scale, KColor(0,0,0,alpha), 24, true)
			end
		end

		if tag2 then
			if zh then
				fnt:DrawStringScaledUTF8(tag2, pos.X - 13*scale, pos.Y - 3*scale, 0.5*scale, 0.5*scale, KColor(0,0,0,alpha), 24, true)
			else		
				fnt2:DrawStringScaledUTF8(tag2, pos.X - 13*scale, pos.Y - 3*scale, 0.5*scale, 0.5*scale, KColor(0,0,0,alpha), 24, true)
			end	
		end		
	end
	
	Tail:Render(pos)
end
Sketch:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, 'OnActiveRender')



return Sketch

