--机制

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local Translations = mod.IBS_Lib.Translations

local LANG = Options.Language
if LANG ~= "zh" then LANG = "en" end


--展示镜子提示
local function ShowMirrorTip()
	local playerType = Isaac.GetPlayer(0):GetPlayerType()
	local KEY = nil
	
	if (playerType == 0) or (playerType == 21) then --以撒
		KEY = "Isaac"
	elseif (playerType == 1) or (playerType == 22) then --抹大拉
		KEY = "Magdalene"
	elseif (playerType == 2) or (playerType == 23) then --该隐
		KEY = "Cain"
	elseif (playerType == 3) or (playerType == 12) or (playerType == 24) then --犹大
		KEY = "Judas"
	end
	
	if KEY then
		local info = Translations[LANG].MirrorTip[KEY]
		Game():GetHUD():ShowItemText(info.Title, info.Sub)
	end
end
mod:AddCallback(IBS_Callback.MIRROR_BROKEN, ShowMirrorTip)

--虚空增强(吸收饰品)
local function VoidUp(_,col,rng,player,flags)
	if (flags & UseFlag.USE_OWNED > 0) then
		if IBS_Data.Setting["voidUp"] then
			player:UseActiveItem(479,false,false) --吞掉身上的饰品
		
			--吞掉地上的饰品
			local ts = Isaac.FindByType(5, 350)
			for i = 1, #ts do
				local item = ts[i]:ToPickup()
				if (item.SubType > 0) and (item.Price == 0) then
					player:AddTrinket(item.SubType, item.Touched)
					player:UseActiveItem(479,false,false)
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, item.Position, Vector.Zero, nil)						
					item:Remove()
				end
			end		
		end
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, VoidUp, 477)


--无底坑增强(吸收饰品)
local function AbyssUp(_,col,rng,player,flags)
	if (flags & UseFlag.USE_OWNED > 0) then
		if IBS_Data.Setting["abyssUp"] then
			local ts = Isaac.FindByType(5, 350)
			
			for i = 1, #ts do
			local item = ts[i]:ToPickup()
				if (item.SubType > 0) and (item.Price == 0) then
					local locust = Isaac.Spawn(3, FamiliarVariant.ABYSS_LOCUST, 2, item.Position, Vector.Zero, player):ToFamiliar()
					locust.Player = player
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, item.Position, Vector.Zero, nil)						
					item:Remove()
				end
			end		
		end
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, AbyssUp, 706)


--无底坑增强(吸收饰品)
local function AbyssUp(_,col,rng,player,flags)
	if (flags & UseFlag.USE_OWNED > 0) then
		if IBS_Data.Setting["abyssUp"] then
			local ts = Isaac.FindByType(5, 350)
			
			for i = 1, #ts do
			local item = ts[i]:ToPickup()
				if (item.SubType > 0) and (item.Price == 0) then
					local locust = Isaac.Spawn(3, FamiliarVariant.ABYSS_LOCUST, 2, item.Position, Vector.Zero, player):ToFamiliar()
					locust.Player = player
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, item.Position, Vector.Zero, nil)						
					item:Remove()
				end
			end		
		end
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, AbyssUp, 706)


--制裁嫉妒
do

local ItemBlackList = {
	IBS_Item.envy
}

--将黑名单道具从池中移除
mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.EARLY, function(_,isContinue)
	if IBS_Data.Setting["correctedData"] then
		local itemPool = Game():GetItemPool()
		
		if not isContinue then
			for _,item in pairs(ItemBlackList) do
				itemPool:RemoveCollectible(item)
			end
		end
	end	
end)

--避免从池中抽取黑名单道具
mod:AddPriorityCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, CallbackPriority.EARLY, function(_,id,pool,decrease,seed)
	if IBS_Data.Setting["correctedData"] then
		local itemPool = Game():GetItemPool()

		for _,item in pairs(ItemBlackList) do
			if id == item then
				itemPool:RemoveCollectible(item)
				return itemPool:GetCollectible(pool,decrease,seed)
			end			
		end
	end	
end)

end
