--超立方

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local Hypercube = mod.IBS_Class.Item(mod.IBS_ItemID.Hypercube)


--获取数据
function Hypercube:GetData()
	local data = self:GetIBSData('temp')
	if not data.Hypercube then
		data.Hypercube = {ItemID = 0}		
	end

	return data.Hypercube
end

--道具图标
local Icon = Sprite()
local IconID = 0
Icon:Load("gfx/ibs/ui/items/Hypercube.anm2", true)
Icon:Play(Icon:GetDefaultAnimation())


--使用效果
function Hypercube:OnUse(item, rng, player, flags)
	if (flags & UseFlag.USE_CARBATTERY <= 0) and (flags & UseFlag.USE_VOID <= 0) then--拒绝车载电池和虚空
		local data = self:GetData()
		
		if data.ItemID > 0 then
			for _,ent in pairs(Isaac.FindByType(5, 100)) do
				local item = ent:ToPickup()
				if item and item.SubType ~= 0 then
					item:Morph(5, 100, data.ItemID, true)
					item.Touched = false
					item:SetColor(Color(1,1,1,0,1,1,1),6,3,true)
					SFXManager():Play(81)
				end
			end
			data.ItemID = 0
		else
			local item = self._Finds:ClosestCollectible(player.Position)
			if item ~= nil and item.SubType > 0 then
				local itemConfig = config:GetCollectible(item.SubType)
				if itemConfig and itemConfig.GfxFileName then
					data.ItemID = item.SubType
					Icon:ReplaceSpritesheet(1, itemConfig.GfxFileName)
					Icon:LoadGraphics()
					item:SetColor(Color(0,0,0,0),6,3,true)
					game:GetItemPool():RemoveCollectible(item.SubType)
					SFXManager():Play(81)
				else
					data.ItemID = 0
				end
			end
		end
		
		
		return {ShowAnim = false}
	end
end
Hypercube:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', Hypercube.ID)



--把记录的道具贴图贴在主动槽上
function Hypercube:OnActiveRender(player, slot, offset, alpha, scale)
	if player:GetActiveItem(slot) ~= self.ID then return end
	local data = mod:GetIBSData("temp").Hypercube

	if data and (data.ItemID > 0) then
		local itemConfig = config:GetCollectible(data.ItemID)

		if itemConfig and IconID ~= data.ItemID then
			IconID = data.ItemID
			Icon:ReplaceSpritesheet(1, itemConfig.GfxFileName)
			Icon:LoadGraphics()			
		end

		if IconID ~= 0 then
			Icon.Scale = Vector(scale, scale)
			Icon.Color = Color(1,1,1,alpha)
			Icon:Render(offset + Vector(16*scale,16*scale))
		end
	end
end
Hypercube:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, 'OnActiveRender')


return Hypercube

