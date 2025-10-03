--亚波伦之翼

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local game = Game()

local WOA = mod.IBS_Class.Item(mod.IBS_ItemID.WOA)

--频率限制(防止循环刷新属性)
local Timeout = 0
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	if Timeout > 0 then
		Timeout = Timeout - 1
	end
end)

--获得
function WOA:OnGain(item, charge, first, slot, varData, player)
	if first then
		local itemPool = game:GetItemPool()
		local pillColor = itemPool:ForceAddPillEffect(48)
		itemPool:IdentifyPill(pillColor)
		Isaac.Spawn(5,70, pillColor, player.Position, Vector.Zero, nil)
	end
end
WOA:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', WOA.ID)

--属性
function WOA:OnEvaluateCache(player, flag)
	if player:HasCollectible(self.ID) then
		if flag == CacheFlag.CACHE_SHOTSPEED then
			Stats:ShotSpeed(player, 0.16*player:GetCollectibleNum(self.ID))
			
			if Timeout <= 0 then
				Timeout = 1
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_LUCK, true)
			end
		end
		
		local mult = player.ShotSpeed - 0.3
		if mult > 1.5 then mult = 1.5 end
		if mult < 0.9 then mult = 0.9 end

		if flag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed * mult
		end
		if flag == CacheFlag.CACHE_FIREDELAY then
			Stats:TearsMultiples(player, mult)
		end
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * mult
		end
		if flag == CacheFlag.CACHE_RANGE then
			player.TearRange = player.TearRange * mult
		end
		if flag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck * mult
		end
		
		--亚波伦飞行
		if flag == CacheFlag.CACHE_FLYING then
			local playerType = player:GetPlayerType()
			if (playerType == PlayerType.PLAYER_APOLLYON) or (playerType == PlayerType.PLAYER_APOLLYON_B) then
				player.CanFly = true
			end
		end			
	end	
end
WOA:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 200, 'OnEvaluateCache')


--翅膀装饰
function WOA:FlyCostume(player)
	local playerType = player:GetPlayerType()
	if (playerType == PlayerType.PLAYER_APOLLYON) or (playerType == PlayerType.PLAYER_APOLLYON_B) then
		if player:HasCollectible(self.ID) then
			local effect = player:GetEffects()
			if not effect:HasCollectibleEffect(179) then
				effect:AddCollectibleEffect(179, true)
			end
		end	
	end
end
WOA:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, 'FlyCostume')


return WOA