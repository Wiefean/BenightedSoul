--超立方

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local IBS_Player = mod.IBS_Player
local Ents = mod.IBS_Lib.Ents
local Pools = mod.IBS_Lib.Pools
local Finds = mod.IBS_Lib.Finds

local config = Isaac.GetItemConfig()

--获取记录
local function GetRecord()
	local data = mod:GetIBSData("Temp")
	if not data.Hypercube then
		data.Hypercube = {ItemID = 0}		
	end

	return data.Hypercube
end

--临时贴图数据
local function GetItemIconData(player)
	local data = Ents:GetTempData(player)
	if not data.Hypercube then
		local spr = Sprite()
		spr:Load("gfx/ibs/ui/items/hypercube.anm2", true)
		spr:Play(spr:GetDefaultAnimation())		
		data.Hypercube = {ItemID = 0, Sprite = spr}
	end
	
	return data.Hypercube
end

--使用效果
local function Copy(_,item, rng, player, flags)
	if (flags & UseFlag.USE_CARBATTERY <= 0) and (flags & UseFlag.USE_VOID <= 0) then--拒绝车载电池和虚空
		local data = GetRecord()
		local icon = GetItemIconData(player)
		
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
			local item = Finds:ClosestCollectible(player.Position)
			if item ~= nil and item.SubType > 0 then
				local itemConfig = config:GetCollectible(item.SubType)
				if itemConfig and itemConfig.GfxFileName then
					data.ItemID = item.SubType
					icon.Sprite:ReplaceSpritesheet(1, itemConfig.GfxFileName)
					icon.Sprite:LoadGraphics()
					item:SetColor(Color(0,0,0,0),6,3,true)
					Game():GetItemPool():RemoveCollectible(item.SubType)
					SFXManager():Play(81)
				else
					data.ItemID = 0
				end
			end
		end
		
		
		return {ShowAnim = false}
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, Copy, IBS_Item.hypercube)

--把记录的道具贴图贴在主动槽上
local function RenderItem(_,item, player, slot, pos, scale)
	local data = mod:GetIBSData("Temp").Hypercube
	local icon = GetItemIconData(player)
	
	if data and (data.ItemID > 0) then
		if icon.ItemID ~= data.ItemID then
			icon.ItemID = data.ItemID
			icon.Sprite:ReplaceSpritesheet(1, config:GetCollectible(data.ItemID).GfxFileName)
			icon.Sprite:LoadGraphics()			
		end		
		icon.Sprite.Scale = scale
		icon.Sprite:Render(pos)
	end
end
mod:AddCallback(IBS_Callback.ACTIVE_SLOT_RENDER, RenderItem, IBS_Item.hypercube)


