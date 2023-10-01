--禁果

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local Pools = mod.IBS_Lib.Pools
local Players = mod.IBS_Lib.Players

--品质1或3
local function Quality1Or3(itemConfig)
	local quality = itemConfig.Quality
	if (quality == 1) or (quality == 3) then
		return true
	end
	return false
end

--品质1或3,彼列书
local function Quality1Or3_B(itemConfig)
	local quality = itemConfig.Quality
	if (quality ~= 1) and (quality ~= 3) then
		return 0
	end
end

--使用效果
local function OnUse(_,item, rng, player, flags, slot)
	if (flags & UseFlag.USE_OWNED > 0 or flags & UseFlag.USE_VOID > 0) and (flags & UseFlag.USE_CARBATTERY <= 0) then
		local data = mod:GetIBSData("Temp")
		local game = Game()
		local level = game:GetLevel()
		local itemPool = game:GetItemPool()
		
		for _,item in pairs(Pools:GetCollectibles(Quality1Or3)) do
			itemPool:RemoveCollectible(item)
		end
		
		--彼列书
		if player:HasCollectible(59) then

			--移除美德书的时也添加魂火
			if player:HasCollectible(584) then
				player:AddWisp(IBS_Item.ffruit, player.Position)
				player:AddWisp(IBS_Item.ffruit, player.Position)
			end		
			
			local effect = player:GetEffects()
			local items,totalNum = Players:GetPlayerCollectibles(player, Quality1Or3_B)

			for id,num in pairs(items) do
				for i = 1,num do
					player:RemoveCollectible(id, true)
					effect:AddNullEffect(NullItemID.ID_JUDAS_BIRTHRIGHT_PERMANENT)
					effect:AddNullEffect(NullItemID.ID_JUDAS_BIRTHRIGHT_PERMANENT)
				end	
			end
			player:UseActiveItem(34, false, false)
		end
	
		--特效
		game:Darken(1, 666)
		game:ShakeScreen(66)
		SFXManager():Play(SoundEffect.SOUND_SATAN_APPEAR, 3, 2, false, 0.666)
		
		level:RemoveCurses(LevelCurse.CURSE_OF_THE_UNKNOWN | LevelCurse.CURSE_OF_BLIND)
		if not data.forbiddenFruitUsed then data.forbiddenFruitUsed = true end
		
		return {ShowAnim = true, Remove = true}
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, OnUse, IBS_Item.ffruit)

--新层移除未知和致盲诅咒
local function NewLevel()
	local data = mod:GetIBSData("Temp")
	if data.forbiddenFruitUsed then
		Game():GetLevel():RemoveCurses(LevelCurse.CURSE_OF_THE_UNKNOWN | LevelCurse.CURSE_OF_BLIND)
	end	
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.LATE, NewLevel)
