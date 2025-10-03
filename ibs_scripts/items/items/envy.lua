--嫉妒

local mod = Isaac_BenightedSoul
local Pools = mod.IBS_Lib.Pools
local IBS_CallbackID = mod.IBS_CallbackID

local game = Game()
local config = Isaac.GetItemConfig()

local Envy = mod.IBS_Class.Item(mod.IBS_ItemID.Envy)

--设置将该道具移出道具池
function Envy:RemoveFromPool(id, pool, decrease, seed)
	if self:GetIBSData('persis')['envyRemove'] and id == self.ID then
		local itemPool = game:GetItemPool()
		itemPool:RemoveCollectible(id)
		return itemPool:GetCollectible(pool, decrease, seed)
	end
end
Envy:AddPriorityCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, CallbackPriority.IMPORTANT, 'RemoveFromPool')


--获取数据
function Envy:GetData()
	return self:GetIBSData('temp')
end


--图标,用于提示嫉妒等级
local alpha = 0 --图标不透明度
local Icon = Sprite()
Icon:Load('gfx/ibs/ui/items/envy.anm2', true)
Icon:Play('0')

--跳脸预备
local JumpScareTimeout = 0

function Envy:OnRender()
	local envyLevel = self:GetData().EnvyLevel or 0
	Icon:Play(tostring(envyLevel))
	Icon.Color = Color(1,1,1,alpha)

	if not game:IsPaused() then
		Icon:Update()
		if alpha > 0 then
			alpha = alpha - 0.0025
		end
		if JumpScareTimeout > 0 then
			JumpScareTimeout = JumpScareTimeout - 1
		end
	end
end
Envy:AddCallback(ModCallbacks.MC_POST_RENDER, 'OnRender')

--渲染图标
function Envy:OnPlayerRender(player, offset)
	if game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then return end
	if alpha > 0 and player:HasCollectible(self.ID) then
		Icon:Render(self._Screens:GetEntityRenderPosition(player, Vector(0,-40) + offset))
	end
end
Envy:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, 'OnPlayerRender', 0)

--展示图标
function Envy:ShowIcon(envyLevel)
	if envyLevel > 0 then
		local volume = 1 + envyLevel * 0.3
		local pitch = 1.3 - envyLevel * 0.2
		SFXManager():Play(316, volume, 2, false, pitch) --阴效
		alpha = 1
	end
end

--拾取道具更改点数
function Envy:OnPickItem(player, item, touched)
	if touched then return end 

	--跳脸
	if item == self.ID and JumpScareTimeout > 0 then
		if self:GetIBSData('persis').envyJS then 
			ItemOverlay.Show(Isaac.GetGiantBookIdByName('IBS_Envy'))

			if self:GetIBSData('persis')['otto'] then
				SFXManager():Play(mod.IBS_Sound.OTTO, 2, 2, false, 1.3) --特殊跳脸音效❤
			else
				SFXManager():Play(101, 2, 2, false, 1.3)
			end	
		end
	elseif player:HasCollectible(self.ID) then
		local data= self:GetData()
		local quality = (config:GetCollectible(item) and config:GetCollectible(item).Quality) or 0

		--初始化
		if not data.EnvyLevel then data.EnvyLevel = 1 end

		--调整等级
		if quality > 2 then
			data.EnvyLevel = data.EnvyLevel + 1
		elseif quality < 2 then
			data.EnvyLevel = data.EnvyLevel - 1
		end
		if data.EnvyLevel < 0 then data.EnvyLevel = 0 end
		if data.EnvyLevel > 4 then data.EnvyLevel = 4 end
		
		if quality ~= 2 then
			self:ShowIcon(data.EnvyLevel)
		end

		--刷新角色属性
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_LUCK, true)
	end
end
Envy:AddPriorityCallback(IBS_CallbackID.PICK_COLLECTIBLE, CallbackPriority.LATE, 'OnPickItem')

--属性变动
function Envy:OnEvalueateCache(player, flag)
	if player:HasCollectible(self.ID) then
		local envyLevel = self:GetData().EnvyLevel or 0

		if flag == CacheFlag.CACHE_LUCK and envyLevel < 2 then
			player.Luck = player.Luck * 1.6
		end
		if flag == CacheFlag.CACHE_DAMAGE and envyLevel < 3 then
			player.Damage = player.Damage * 1.3
		end
	end	
end
Envy:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvalueateCache')

--获取4级道具(用于替换贴图)
local function Quality4(itemConfig)
	local quality = itemConfig.Quality
	if (quality >= 4) then
		return true
	end
	return false
end

local Q4Items = Pools:GetCollectibles(Quality4)
mod:DelayFunction2(function()
	Q4Items = Pools:GetCollectibles(Quality4)
end, 1)

--4级道具贴图伪装
function Envy:Disguise(pickup)
	if pickup.SubType == (self.ID) and self:GetIBSData('persis')['envyDisguise'] then
		local rng = RNG(pickup.InitSeed)
		local id = Q4Items[rng:RandomInt(#Q4Items) + 1] or 182
		pickup:GetSprite():ReplaceSpritesheet(1, config:GetCollectible(id).GfxFileName, true)
		self._Ents:GetTempData(pickup).EnvyDisguise = id
	end
end
Envy:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'Disguise')


function Envy:OnPickupUpdate(pickup)
	local id = pickup.SubType
	local disguise = self._Ents:GetTempData(pickup).EnvyDisguise

	--玩家靠近嫉妒时换回贴图
	if id == self.ID then
		if disguise ~= nil then
			local pos = pickup.Position
			local player = self._Finds:ClosestPlayer(pos)

			if player and pos:Distance(player.Position) < 35 then
				pickup:GetSprite():ReplaceSpritesheet(1, config:GetCollectible(self.ID).GfxFileName, true)
				self._Ents:GetTempData(pickup).EnvyDisguise = nil
				JumpScareTimeout = 30
				
				--移出道具池
				game:GetItemPool():RemoveCollectible(self.ID)
			end
		end
	elseif id > 0 then
		local quality = (config:GetCollectible(id) and config:GetCollectible(id).Quality) or 0
		if quality > 2 and disguise == nil then
			local envyLevel = self:GetData().EnvyLevel or 0

			 --点数到4时替换3级及以上道具,并伪装
			if envyLevel >= 4 then
				pickup:Morph(5,100, self.ID, true, true, true)
				pickup:GetSprite():ReplaceSpritesheet(1, config:GetCollectible(id).GfxFileName, true)
				self._Ents:GetTempData(pickup).EnvyDisguise = id
				JumpScareTimeout = 30				
			end
		end
	end	
end
Envy:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'OnPickupUpdate', 100)


return Envy